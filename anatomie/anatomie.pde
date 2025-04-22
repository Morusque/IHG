
import processing.svg.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

String[] words;

ArrayList<PVector> positions = new ArrayList<PVector>();

int nbExported = 0;

PGraphics svg;

PFont font;
float textSize = 24;

int nbDivsX = 1;
int nbDivsY = 1;

int currentMode = 0;
int lastGeneratedMode = 0;

boolean isSatisfying = false;

void setup() {
  size(990, 700);
  words = loadStrings(dataPath("files/topics.txt"));
  // font = createFont(dataPath("files/maxeville.otf"), textSize);// appears white, I don't know why
  font = loadFont(dataPath("files/SMMaxeville-Regular-240.vlw"));
  generate();
}

void draw() {
}

void keyPressed() {
  if (keyCode==ENTER) generate();
  if (keyCode == TAB) {
    String sourcePath = sketchPath("temp.svg");
    String filename = "results/" + nf(lastGeneratedMode, 2) + "_" + year() + "_" + nf(month(), 2) + "_" + nf(day(), 2) +
      "_" + nf(hour(), 2) + "_" + nf(minute(), 2) + "_" + nf(second(), 2) + "_" + nf(nbExported, 3) + ".svg";
    String filenameB = "results/" + nf(lastGeneratedMode, 2) + "_" + year() + "_" + nf(month(), 2) + "_" + nf(day(), 2) +
      "_" + nf(hour(), 2) + "_" + nf(minute(), 2) + "_" + nf(second(), 2) + "_" + nf(nbExported, 3) + ".png";
    String destinationPath = sketchPath(filename);
    PShape sourceShape = loadShape(sourcePath);
    PGraphics expGr = createGraphics(14031,9000,JAVA2D);
    expGr.beginDraw();
    expGr.shape(sourceShape,0,0,expGr.width,expGr.height);
    expGr.endDraw();
    expGr.save(filenameB);
    try {
      Files.copy(Paths.get(sourcePath), Paths.get(destinationPath), StandardCopyOption.REPLACE_EXISTING);
      println("SVG copied as " + filename);
      nbExported++;
    }
    catch (IOException e) {
      println("Error copying SVG: " + e.getMessage());
    }
    println("export done");
  }
  if (keyCode==RIGHT) {
    currentMode = (currentMode+1)%4;
    println("currentMode : "+currentMode);
  }
}

void generate() {
  isSatisfying = false;
  while (!isSatisfying) {
    isSatisfying = true;
    svg = createGraphics(width, height, SVG);
    svg.beginDraw();
    svg.background(0xFF);
    svg.textFont(font);
    if (currentMode==0) {
      generateOneBody(floor(random(5, 8)), 0, 0, width, height);
    }
    if (currentMode==1) {
      generateOneBody(floor(random(3, 6)), 0, 0, width/2, height);
      generateOneBody(floor(random(3, 6)), width/2, 0, width/2, height);
    }
    if (currentMode==2) {
      generateOneBody(floor(random(3, 6)), 0, 0, width, height/2);
      generateOneBody(floor(random(3, 6)), 0, height/2, width, height/2);
    }
    if (currentMode==3) {
      generateOneBody(2, 0, 0, width/2, height/2);
      generateOneBody(2, width/2, 0, width/2, height/2);
      generateOneBody(2, 0, height/2, width/2, height/2);
      generateOneBody(2, width/2, height/2, width/2, height/2);
    }
    svg.dispose();
    svg.setPath(sketchPath("temp.svg"));
    svg.endDraw();
  }
  PShape svgS = loadShape(sketchPath("temp.svg"));
  shape(svgS, 0, 0);
  lastGeneratedMode = currentMode;
  println("done");
}

void generateOneBody(int numberOfWords, float posX, float posY, float sizX, float sizY) {
  float borderMargin = 30;
  float labelsMargin = 10;
  float arrowsSize = 40;
  PVector center = new PVector(posX+sizX/2, posY+sizY/2);
  svg.stroke(0x80);
  svg.strokeWeight(1);
  svg.noFill();
  // svg.ellipse(center.x, center.y, 5, 5);
  svg.rectMode(CORNER);
  //svg.rect(posX+borderMargin, posY+borderMargin, sizX-borderMargin*2, sizY-borderMargin*2);
  ArrayList<PVector[]> boundingBoxes = new ArrayList<PVector[]>();
  ArrayList<PVector[]> arrows = new ArrayList<PVector[]>();
  for (int i=0; i<numberOfWords; i++) {
    String word = words[floor(random(words.length))].toUpperCase();
    PVector labelPosCenter;
    PVector[] labelBoundingBox = textSizeOf(word, font, textSize);
    PVector[] finalBoundingBox;
    boolean posOk;
    float angle;
    PVector arrowStart;
    int nbTries = 0;
    do {
      posOk = true;
      // calculate positions and angles
      labelPosCenter = new PVector(random(posX+borderMargin, posX+sizX-borderMargin), random(posY+borderMargin, posY+sizY-borderMargin));
      finalBoundingBox = new PVector[]{
        new PVector(labelPosCenter.x + labelBoundingBox[0].x - labelsMargin, labelPosCenter.y + labelBoundingBox[0].y - labelsMargin),
        new PVector(labelPosCenter.x + labelBoundingBox[1].x + labelsMargin, labelPosCenter.y + labelBoundingBox[1].y + labelsMargin)
      };
      angle = atan2(center.y-labelPosCenter.y, center.x-labelPosCenter.x);
      // check distance to center
      float minDistance = new PVector(sizX, sizY).mag()/10.0;
      if (PVector.dist(labelPosCenter, center) < minDistance) posOk = false;
      // check margins
      if (finalBoundingBox[0].x <  posX + borderMargin) posOk = false;
      if (finalBoundingBox[0].y <  posY + borderMargin) posOk = false;
      if (finalBoundingBox[1].x >= posX + sizX - borderMargin) posOk = false;
      if (finalBoundingBox[1].y >= posY + sizY - borderMargin) posOk = false;
      // check other bounding boxes
      for (PVector[] ps : boundingBoxes) if (boxesIntersect(finalBoundingBox, ps)) posOk = false;
      // check other arrows
      for (PVector[] otherArrow : arrows) if (findIntersection(otherArrow[0], otherArrow[1], finalBoundingBox)!=null) posOk = false;
      // calculate arrow
      arrowStart = findIntersection(labelPosCenter, center, finalBoundingBox);
      if (arrowStart==null) {
        posOk = false;
      } else {
        // check distance to center
        if (PVector.dist(arrowStart, center) < minDistance) posOk = false;
        // check angle
        angle = atan2(center.y-arrowStart.y, center.x-arrowStart.x);
        // Additional checks for arrow intersections with bounding boxes and other arrows
        for (PVector[] otherBox : boundingBoxes) if (findIntersection(arrowStart, new PVector(arrowStart.x + cos(angle) * arrowsSize, arrowStart.y + sin(angle) * arrowsSize), otherBox)!=null) posOk = false;
        for (PVector[] otherArrow : arrows) if (lineIntersectsLine(arrowStart, new PVector(arrowStart.x + cos(angle) * arrowsSize, arrowStart.y + sin(angle) * arrowsSize), otherArrow[0], otherArrow[1])) posOk = false;
      }
      nbTries++;
    }
    while (!posOk && nbTries<1000);
    if (nbTries==1000) isSatisfying = false;
    boundingBoxes.add(finalBoundingBox);
    if (arrowStart==null) arrowStart = labelPosCenter.copy();
    arrows.add(new PVector[]{new PVector(arrowStart.x, arrowStart.y), new PVector(arrowStart.x+cos(angle)*arrowsSize, arrowStart.y+sin(angle)*arrowsSize)});
    PVector arrowEnd = new PVector(arrowStart.x+cos(angle)*arrowsSize, arrowStart.y+sin(angle)*arrowsSize);
    svg.stroke(0);
    svg.strokeWeight(2);
    svg.strokeCap(SQUARE);
    svg.strokeJoin(MITER);
    svg.line(arrowStart.x, arrowStart.y, arrowEnd.x, arrowEnd.y);
    svg.beginShape();
    svg.vertex(arrowEnd.x+cos(angle-PI*3/4)*10, arrowEnd.y+sin(angle-PI*3/4)*10);
    svg.vertex(arrowEnd.x, arrowEnd.y);
    svg.vertex(arrowEnd.x+cos(angle+PI*3/4)*10, arrowEnd.y+sin(angle+PI*3/4)*10);
    svg.endShape();
    svg.fill(0);
    svg.noStroke();
    svg.textAlign(CENTER, CENTER);
    svg.textSize(textSize);
    svg.text(word, labelPosCenter.x, labelPosCenter.y);
    svg.rectMode(CENTER);
    svg.noFill();
    svg.stroke(0);
    svg.rectMode(CORNERS);
    //svg.rect(labelPosCenter.x+labelBoundingBox[0].x, labelPosCenter.y+labelBoundingBox[0].y, labelPosCenter.x+labelBoundingBox[1].x, labelPosCenter.y+labelBoundingBox[1].y);
    //svg.rect(finalBoundingBox[0].x, finalBoundingBox[0].y, finalBoundingBox[1].x, finalBoundingBox[1].y);
  }
}

PVector[] textSizeOf(String text, PFont font, float textSize) {
  PGraphics gr = createGraphics(width, height, JAVA2D);
  gr.beginDraw();
  gr.background(255, 255, 255);  // Set a white background
  gr.fill(0);  // Draw text in black
  gr.textAlign(CENTER, CENTER);  // Center the text vertically and horizontally
  gr.textFont(font);
  gr.textSize(textSize);
  gr.text(text, width / 2, height / 2);
  gr.endDraw();

  // Load the pixel data for analysis
  gr.loadPixels();

  int minX = width;
  int maxX = 0;
  int minY = height;
  int maxY = 0;

  // Scan through all pixels to find the bounding box of the text
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      // Check if the pixel color is not white (i.e., part of the text)
      if (gr.pixels[y * width + x] != -1) {  // White is 0xFFFFFFFF, and -1 in signed int
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }

  // Center-relative coordinates
  PVector topLeft = new PVector(minX - width / 2, minY - height / 2);
  PVector bottomRight = new PVector(maxX - width / 2, maxY - height / 2);

  // Return the bounding box as an array of PVectors
  return new PVector[] {topLeft, bottomRight};
}

boolean boxesIntersect(PVector[] box1, PVector[] box2) {
  // Extract the corners for readability
  PVector topLeft1 = box1[0];
  PVector bottomRight1 = box1[1];
  PVector topLeft2 = box2[0];
  PVector bottomRight2 = box2[1];

  // Check for overlap
  if (topLeft1.x > bottomRight2.x || topLeft2.x > bottomRight1.x) {
    return false; // No overlap horizontally
  }
  if (topLeft1.y > bottomRight2.y || topLeft2.y > bottomRight1.y) {
    return false; // No overlap vertically
  }

  return true; // Overlapping
}

PVector findIntersection(PVector start, PVector end, PVector[] box) {
  float dx = end.x - start.x;
  float dy = end.y - start.y;
  float slope = dy / dx;
  float intercept = start.y - slope * start.x;

  // Store potential intersections
  ArrayList<PVector> intersections = new ArrayList<PVector>();

  // Calculate potential intersection points with each side of the bounding box
  // Intersection with left and right sides of the box
  float leftIntersectY = slope * box[0].x + intercept;
  if (leftIntersectY >= box[0].y && leftIntersectY <= box[1].y)
    intersections.add(new PVector(box[0].x, leftIntersectY));

  float rightIntersectY = slope * box[1].x + intercept;
  if (rightIntersectY >= box[0].y && rightIntersectY <= box[1].y)
    intersections.add(new PVector(box[1].x, rightIntersectY));

  // Intersection with top and bottom sides of the box
  if (dx != 0) {  // Avoid division by zero
    float topIntersectX = (box[0].y - intercept) / slope;
    if (topIntersectX >= box[0].x && topIntersectX <= box[1].x)
      intersections.add(new PVector(topIntersectX, box[0].y));

    float bottomIntersectX = (box[1].y - intercept) / slope;
    if (bottomIntersectX >= box[0].x && bottomIntersectX <= box[1].x)
      intersections.add(new PVector(bottomIntersectX, box[1].y));
  }

  // Find the closest intersection point to the start point in the correct direction
  PVector closestIntersection = null;
  float minDist = Float.MAX_VALUE;
  for (PVector intersection : intersections) {
    if (PVector.sub(intersection, start).dot(PVector.sub(end, start)) > 0) { // Check if intersection is in the direction of the line
      float dist = PVector.dist(start, intersection);
      if (dist < minDist) {
        closestIntersection = intersection;
        minDist = dist;
      }
    }
  }

  return closestIntersection; // May return null if no valid intersection is found
}

boolean lineIntersectsRectangle(PVector p1, PVector p2, PVector[] box) {
  // Check line intersection with each side of the rectangle
  return lineIntersectsLine(p1, p2, box[0], new PVector(box[1].x, box[0].y)) ||
    lineIntersectsLine(p1, p2, new PVector(box[1].x, box[0].y), box[1]) ||
    lineIntersectsLine(p1, p2, box[1], new PVector(box[0].x, box[1].y)) ||
    lineIntersectsLine(p1, p2, new PVector(box[0].x, box[1].y), box[0]);
}

boolean lineIntersectsLine(PVector p1, PVector p2, PVector p3, PVector p4) {
  float denominator = (p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y);
  if (denominator == 0) return false; // lines are parallel

  float ua = ((p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x)) / denominator;
  float ub = ((p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x)) / denominator;

  return (ua >= 0 && ua <= 1 && ub >= 0 && ub <= 1);
}
