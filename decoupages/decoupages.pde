
import processing.svg.*;

ArrayList<Segment> segments = new ArrayList<Segment>();

float patternSize = 60;

void setup() {
  size(700, 700);
  frameRate(60);
  generate();
}

void draw() {
  PGraphics svg = createGraphics(width, height, SVG, "result"+nf(nbExported, 4)+".svg");
  svg.beginDraw();
  svg.background(0xFF);
  background(0xFF);
  svg.stroke(0);
  stroke(0);
  for (int i=0; i<segments.size(); i++) {
    Segment thisS = segments.get(i);
    for (int x=-2; x<(float)width/patternSize+2; x++) {
      for (int y=-2; y<(float)height/patternSize+2; y++) {
        PVector offset = new PVector(((float)x-1)*patternSize, ((float)y-1)*patternSize);
        /*
        svg.stroke(thisS.c);
        stroke(thisS.c);
        */
        svg.stroke(0);
        stroke(0);
        svg.line(thisS.a.x+offset.x, thisS.a.y+offset.y, thisS.b.x+offset.x, thisS.b.y+offset.y);
        line(thisS.a.x+offset.x, thisS.a.y+offset.y, thisS.b.x+offset.x, thisS.b.y+offset.y);
      }
    }
    if (thisS.aGrowing||thisS.bGrowing) {
      for (int j=0; j<segments.size(); j++) {
        Segment thisS2 = segments.get(j);
        for (int x=-2; x<(float)width/patternSize+2; x++) {
          for (int y=-2; y<(float)height/patternSize+2; y++) {
            if (thisS != thisS2 || x!=0 || y!=0) {
              PVector offset = new PVector(((float)x-1)*patternSize, ((float)y-1)*patternSize);
              PVector intersection = lineSegmentIntersection(thisS.a, thisS.b, PVector.add(thisS2.a, offset), PVector.add(thisS2.b, offset));
              if (intersection!=null) {
                // circle(intersection.x, intersection.y, 10);
                if (dist(intersection.x, intersection.y, thisS.a.x, thisS.a.y)<1) {
                  thisS.aGrowing = false;
                  thisS.a = intersection;
                }
                if (dist(intersection.x, intersection.y, thisS.b.x, thisS.b.y)<1) {
                  thisS.bGrowing = false;
                  thisS.b = intersection;
                }
              }
            }
          }
        }
      }
      if (thisS.aGrowing) {
        thisS.a.x-=cos(thisS.angle);
        thisS.a.y-=sin(thisS.angle);
      }
      if (thisS.bGrowing) {
        thisS.b.x+=cos(thisS.angle);
        thisS.b.y+=sin(thisS.angle);
      }
    }
  }
  svg.dispose();
  svg.endDraw();
}

class Segment {
  PVector a, b;
  boolean aGrowing = true;
  boolean bGrowing = true;
  float angle;
  color c;
  Segment(float ax, float ay, float bx, float by, color c) {
    this.a = new PVector(ax, ay);
    this.b = new PVector(bx, by);
    this.angle = atan2(b.y-a.y, b.x-a.x);
    this.c = c;
  }
}

int nbExported = 0;
void keyPressed() {
  if (keyCode==TAB) save("result"+nf(nbExported++, 4)+".png");
  generate();
}

void generate() {
  int nbLinesPerPattern = floor(random(2,6));
  float minAngleGap = (HALF_PI/((float)nbLinesPerPattern*1.5));
  segments.clear();
  ArrayList<Float> angles = new ArrayList<Float>();
  for (int i=0; i<nbLinesPerPattern; i++) {
    color c = color(random(0x100), random(0x100), random(0x100));
    PVector pos =  new PVector(random(patternSize), random(patternSize));
    float angle;
    boolean tooClose;
    do {
      angle = random(PI);
      tooClose = false;
      for (float a : angles) {
        if (abs(vrMax(a, angle, PI))<minAngleGap) tooClose = true;
      }
    } while (tooClose);
    angles.add(angle);
    segments.add(new Segment(pos.x, pos.y, pos.x+cos(angle), pos.y+sin(angle), c));
  }
}

public float vrMax(float a, float b, float m) {
  float d1 = b - a;
  if (d1 >  m/2) d1=d1-m;
  if (d1 < -m/2) d1=d1+m;
  return d1;
}
