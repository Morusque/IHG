
ArrayList<String> doneUrls = new ArrayList<String>();
ArrayList<PImage> images = new ArrayList<PImage>();

PFont font;

float pointSize=5.0;

ArrayList<Motif> motifs = new ArrayList<Motif>();

boolean generate = false;
// pour générere l'anim, mettre ça à "true" et le mode de display en "fullScreen()"

float pointSizeDirection = 1.5;

float motifMorph = 0.0;
float motifMorphDirection = 0.0;

float rotationForce = 0.1;

int fI = 0;

boolean dark = false;

void setup() {
  // fullScreen();
  fullScreen(P2D);
  background(255);
  frameRate(60);
  font = createFont("Univers LT 65 Bold", 200);
  load();
  noSmooth();

  if (generate) {
    String text = "Turbo Minus";
    float horizontalShift = 300;
    ArrayList<PVector> points = new ArrayList<PVector>();
    for (char c : text.toCharArray()) {
      PShape textShape = createTextShape(c);
      ArrayList<ArrayList<PVector>> shapes = extractClosedShapes(textShape);
      ArrayList<PVector> thesePoints = new ArrayList<PVector>();
      for (ArrayList<PVector> s : shapes) thesePoints.addAll(extractPointsEvenly(s));
      thesePoints = removeDuplicates(thesePoints);
      float minX = 0;
      float maxX = 0;
      for (int i=0; i<thesePoints.size(); i++) {
        minX = min(minX, thesePoints.get(i).x);
        maxX = max(maxX, thesePoints.get(i).x);
        thesePoints.get(i).x+=horizontalShift;
        thesePoints.get(i).y+=500;
      }
      points.addAll(thesePoints);
      horizontalShift+=max(maxX-minX, 50)+10;
    }
    savePoints(points, "points.txt");
  } else {
    motifs.add(new Motif(dataPath("motifs/01.txt")));
    motifs.add(new Motif(dataPath("motifs/02.txt")));
  }
}

void draw() {
  Motif motif = lerpMotifs(motifs.get(0), motifs.get(1), motifMorph);
  motifMorph = constrain(motifMorph+motifMorphDirection, 0.0, 1.0);
  pointSize = pointSize+pointSizeDirection;
  if (pointSize>300) {
    pointSizeDirection=-1;
    motifMorphDirection=0.005;
  }
  if (pointSize<0) {
    pointSizeDirection=1;
    motifMorphDirection = 0.0;
    motifMorph = 0.0;
    fI = floor(random(images.size()));
  }
  background(255);
  // draw the points
  imageMode(CENTER);
  for (int i = 0; i < motif.points.size() - 1; i++) {
    PVector lPoint = PVector.lerp(motif.points.get(i), motif.points.get(i + 1), 0.0);
    pushMatrix();
    translate(lPoint.x, lPoint.y);
    float angle = radians((((float)frameCount*2.0 + (float)i/5.0)*rotationForce) % 360);
    rotate(angle);
    image(images.get(fI), 0, 0, pointSize, pointSize);
    popMatrix();
  }
  if (dark) background(0);
}

// Création de la forme vectorielle du texte
PShape createTextShape(char c) {
  PShape shape = createShape();

  shape.beginShape();
  shape.fill(0);
  textFont(font);
  textSize(200);
  PShape letter = font.getShape(c);
  if (letter != null) shape.addChild(letter);
  shape.endShape(CLOSE);

  return shape;
}

ArrayList<PVector> extractPoints(ArrayList<PVector> vertices) {
  ArrayList<PVector> points = new ArrayList<>();

  for (int i = 0; i < vertices.size(); i++) {
    PVector v1 = vertices.get(i);
    PVector v2 = vertices.get((i + 1) % vertices.size()); // Wrap around to close the shape
    points.add(v1);

    // Add points between v1 and v2 for smoothness
    int numSteps = round(PVector.dist(v1, v2) / 15.0); // Adjust division factor for resolution
    for (int k = 1; k < numSteps; k++) {
      float t = k / (float) numSteps;
      points.add(PVector.lerp(v1, v2, t));
    }
  }

  return points;
}

ArrayList<PVector> extractPointsEvenly(ArrayList<PVector> vertices) {

  ArrayList<PVector> points = new ArrayList<>();
  ArrayList<Float> segmentLengths = new ArrayList<>();
  float totalPerimeter = 0;

  // Calculate the total perimeter and individual segment lengths
  for (int i = 0; i < vertices.size(); i++) {
    PVector v1 = vertices.get(i);
    PVector v2 = vertices.get((i + 1) % vertices.size()); // Wrap around to close the shape
    float segmentLength = PVector.dist(v1, v2);
    segmentLengths.add(segmentLength);
    totalPerimeter += segmentLength;
  }

  int totalPoints = ceil(totalPerimeter/10);

  // Calculate the spacing between points
  float stepSize = totalPerimeter / totalPoints;

  // Add points evenly distributed along the perimeter
  float accumulatedDistance = 0;
  for (int i = 0; i < vertices.size(); i++) {
    PVector v1 = vertices.get(i);
    PVector v2 = vertices.get((i + 1) % vertices.size());
    float segmentLength = segmentLengths.get(i);

    while (accumulatedDistance < segmentLength) {
      float t = accumulatedDistance / segmentLength;
      points.add(PVector.lerp(v1, v2, t));
      accumulatedDistance += stepSize;
    }

    // Carry over the remaining distance to the next segment
    accumulatedDistance -= segmentLength;
  }

  // Ensure the points list is of the correct size
  if (points.size() > totalPoints) {
    points.subList(totalPoints, points.size()).clear();
  } else if (points.size() < totalPoints) {
    points.add(vertices.get(0)); // Add the starting point if we are short
  }

  return points;
}

void logShapeDetails(PShape shape) {
  if (shape == null) {
    println("Shape is null");
    return;
  }

  println("Shape details:");
  println("  Name: " + shape.getName());
  println("  Family: " + shape.getFamily());
  println("  Child count: " + shape.getChildCount());
  println("  Vertex count: " + shape.getVertexCount());

  // Log vertices
  for (int i = 0; i < shape.getVertexCount(); i++) {
    PVector v = shape.getVertex(i);
    println("    Vertex " + i + ": (" + v.x + ", " + v.y + ")");
  }

  // Log child shapes recursively
  for (int i = 0; i < shape.getChildCount(); i++) {
    println("  Child " + i + ":");
    logShapeDetails(shape.getChild(i));
  }
}

void debugClosedShapes(ArrayList<ArrayList<PVector>> closedShapes) {
  println("Number of closed shapes: " + closedShapes.size());
  for (int i = 0; i < closedShapes.size(); i++) {
    println("Shape " + i + ":");
    for (PVector v : closedShapes.get(i)) {
      println("  (" + v.x + ", " + v.y + ")");
    }
  }
}

ArrayList<ArrayList<PVector>> extractClosedShapes(PShape shape) {
  ArrayList<ArrayList<PVector>> closedShapes = new ArrayList<>();
  ArrayList<PVector> currentShape = new ArrayList<>();

  for (int i = 0; i < shape.getVertexCount(); i++) {
    PVector v = shape.getVertex(i);
    for (int j = 0; j < currentShape.size(); j++) {
      if (v.equals(currentShape.get(j))) { // We've detected a closed shape
        // Remove everything before index j
        ArrayList<PVector> closedShape = new ArrayList<>(currentShape.subList(j, currentShape.size()));
        closedShape.add(v); // Add the closing vertex
        closedShapes.add(closedShape); // Save the closed shape
        currentShape = new ArrayList<>(currentShape.subList(j, currentShape.size())); // Keep only the new shape
        break; // Exit the inner loop after detecting a closed shape
      }
    }
    currentShape.add(v);
  }

  // Add any remaining vertices as a final shape (if not empty)
  if (!currentShape.isEmpty()) {
    closedShapes.add(currentShape);
  }

  // Handle child shapes recursively
  for (int i = 0; i < shape.getChildCount(); i++) {
    PShape child = shape.getChild(i);
    closedShapes.addAll(extractClosedShapes(child));
  }

  return closedShapes;
}

ArrayList<PVector> removeDuplicates(ArrayList<PVector> thesePoints) {
  ArrayList<PVector> uniquePoints = new ArrayList<>();
  for (int i = 0; i < thesePoints.size(); i++) {
    PVector currentPoint = thesePoints.get(i);
    boolean isDuplicate = false;
    // Check against all previously added points
    for (int j = 0; j < uniquePoints.size(); j++) {
      PVector existingPoint = uniquePoints.get(j);
      if (abs(currentPoint.x - existingPoint.x) < 0.001 && abs(currentPoint.y - existingPoint.y) < 0.001) {
        // println("Duplicate point removed: (" + currentPoint.x + ", " + currentPoint.y + ")");
        isDuplicate = true;
        break;
      }
    }
    // Add the point only if it's not a duplicate
    if (!isDuplicate) {
      uniquePoints.add(currentPoint);
    }
  }
  // Replace the old list with the filtered unique points
  return uniquePoints;
}

void keyPressed() {
  if (keyCode == TAB) {
    saveFrame("result-####.png");
  }
  if (key == 'y') {
    if (pointSizeDirection!=0) pointSizeDirection = 0;
    else pointSizeDirection = 1.0;
    println("yoyoyo");
  }
  if (keyCode==BACKSPACE) dark^=true;
}

void load() {
  println("loading...");
  String[] inputUrl = getAllFilesFrom(dataPath("elements"));
  for (int i=0; i<inputUrl.length; i++) {
    if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
      println("file : "+inputUrl[i]);
      try {
        PImage im = loadImage(inputUrl[i]);
        if (im!=null) {
          images.add(im.get());
          doneUrls.add(inputUrl[i]);
        }
      }
      catch (Exception e) {
        println(e);
      }
    }
  }
  println("...done");
}

// Save ArrayList<PVector> points to a file
void savePoints(ArrayList<PVector> points, String filename) {
  String[] lines = new String[points.size()];
  for (int i = 0; i < points.size(); i++) {
    PVector p = points.get(i);
    lines[i] = p.x + "," + p.y; // Format: x,y
  }
  saveStrings(filename, lines); // Save to a file
  println("Saved " + points.size() + " points to " + filename);
}

// Load ArrayList<PVector> points from a file
ArrayList<PVector> loadPoints(String filename) {
  ArrayList<PVector> points = new ArrayList<PVector>();
  String[] lines = loadStrings(filename); // Load from a file
  for (String line : lines) {
    String[] coords = split(line, ','); // Split "x,y"
    if (coords.length == 2) {
      float x = float(coords[0]);
      float y = float(coords[1]);
      points.add(new PVector(x, y));
    }
  }
  println("Loaded " + points.size() + " points from " + filename);
  return points;
}

class Motif {
  ArrayList<PVector> points;
  Motif (String url) {
    if (url!=null) {
      points = loadPoints(url);
    } else {
      points = new ArrayList<PVector>();
    }
  }
}

Motif lerpMotifs(Motif a, Motif b, float le) {
  Motif m = new Motif(null);
  for (int i=0; i<max(a.points.size(), b.points.size()); i++) {
    PVector aP = new PVector(width*2, height*2);
    PVector bP = new PVector(width*2, height*2);
    if (i<a.points.size()) aP = a.points.get(i);
    if (i<b.points.size()) bP = b.points.get(i);
    m.points.add(PVector.lerp(aP, bP, le));
  }
  return m;
}
