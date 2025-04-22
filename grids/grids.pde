
ArrayList<Polygon> polygons = new ArrayList<Polygon>();
ArrayList<Line> horizontalLines = new ArrayList<Line>();
ArrayList<Line> verticalLines = new ArrayList<Line>();

PImage im;

void setup() {
  size(3000, 3000);
  noSmooth();
}

void draw() {
  background(0xFF);
  if (im!=null) {
    for (Polygon p : polygons) p.draw();
  } else {
    for (Line l : horizontalLines) l.draw();
    for (Line l : verticalLines) l.draw();
  }
}

void keyPressed() {
  if (keyCode==ENTER) generate();
  if (keyCode==TAB) save("result.png");
  if (keyCode=='I') {
    if (im==null) im = loadImage("ret02.png");
    else im = null;
  }
}

class Polygon {
  PVector[] vertices;
  PVector center;
  Polygon(PVector[] verts) {
    vertices = verts;
    center = new PVector(0, 0);
    for (PVector v : vertices) {
      center.x += v.x/vertices.length;
      center.y += v.y/vertices.length;
    }
  }
  void draw() {
    if (im!=null) {
      color c = im.get(constrain(round(center.x), 0, im.width-1), constrain(round(center.y), 0, im.height-1));
      stroke(c);
      fill(c);
    } else {
      stroke(0);
      noFill();
    }
    beginShape();
    for (PVector v : vertices) {
      if (v!=null) {
        vertex(v.x, v.y);
      }
    }
    endShape(CLOSE);
  }
}

class Line {
  PVector[] points = new PVector[2];
  Line(float x1, float y1, float x2, float y2) {
    points[0] = new PVector(x1, y1);
    points[1] = new PVector(x2, y2);
  }
  void draw() {
    stroke(0);
    line(points[0].x, points[0].y, points[1].x, points[1].y);
  }
}

void generate() {
  horizontalLines.clear();
  verticalLines.clear();
  background(0xFF);
  float margin = 500;
  float space = random(10, 40);
  float amp = random(0, space*0.6);
  float fr = random(0, 0.5);
  float phase = random(0, TWO_PI);
  float shift = random(-margin, margin);
  if (random(1)<0.5) shift = 0;
  stroke(0);
  float x = -margin;
  for (int i=0; x<width+margin; i++) {
    x+=space+amp*sin((float)i*fr+phase);
    horizontalLines.add(new Line(x, 0, x+shift, height));
  }
  space = random(10, 40);
  amp = random(0, space*0.6);
  fr = random(0, 0.5);
  phase = random(0, TWO_PI);
  shift = random(-margin, margin);
  if (random(1)<0.5) shift = 0;
  float y = -margin;
  for (int i=0; y<height+margin; i++) {
    y+=space+amp*sin((float)i*fr+phase);
    verticalLines.add(new Line(0, y, width, y+shift));
  }
  polygons.clear();
  for (int i = 0; i < verticalLines.size() - 1; i++) {
    for (int j = 0; j < horizontalLines.size() - 1; j++) {
      PVector topLeft = getIntersection(verticalLines.get(i), horizontalLines.get(j));
      PVector topRight = getIntersection(verticalLines.get(i + 1), horizontalLines.get(j));
      PVector bottomLeft = getIntersection(verticalLines.get(i), horizontalLines.get(j + 1));
      PVector bottomRight = getIntersection(verticalLines.get(i + 1), horizontalLines.get(j + 1));
      PVector[] verts = {topLeft, topRight, bottomRight, bottomLeft};
      polygons.add(new Polygon(verts));
    }
  }
}

PVector getIntersection(Line a, Line b) {
  // Extracting line endpoints
  float x1 = a.points[0].x, y1 = a.points[0].y;
  float x2 = a.points[1].x, y2 = a.points[1].y;
  float x3 = b.points[0].x, y3 = b.points[0].y;
  float x4 = b.points[1].x, y4 = b.points[1].y;

  // Check for vertical lines
  boolean isALineVertical = (x1 == x2);
  boolean isBLineVertical = (x3 == x4);

  // Handle cases where one or both lines are vertical
  if (isALineVertical && isBLineVertical) {
    return null; // Parallel vertical lines do not intersect
  } else if (isALineVertical) {
    float m2 = (y4 - y3) / (x4 - x3);
    float c2 = y3 - m2 * x3;
    float Y = m2 * x1 + c2;
    return new PVector(x1, Y);
  } else if (isBLineVertical) {
    float m1 = (y2 - y1) / (x2 - x1);
    float c1 = y1 - m1 * x1;
    float Y = m1 * x3 + c1;
    return new PVector(x3, Y);
  }

  // Calculate intersection for non-vertical lines
  float m1 = (y2 - y1) / (x2 - x1);
  float m2 = (y4 - y3) / (x4 - x3);

  // Check for parallel lines
  if (m1 == m2) {
    return null; // Parallel lines do not intersect
  }

  // Calculate intersection
  float c1 = y1 - m1 * x1;
  float c2 = y3 - m2 * x3;
  float X = (c2 - c1) / (m1 - m2);
  float Y = m1 * X + c1;

  return new PVector(X, Y);
}
