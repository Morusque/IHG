
ArrayList<Pattern> patterns = new ArrayList<Pattern>();

import processing.svg.*;

float patternSize = 40;

void setup() {
  size(1700, 950);
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
  // draw
  for (int p=0; p<patterns.size(); p++) {
    for (int i=0; i<patterns.get(p).segments.size(); i++) {
      Segment thisS = patterns.get(p).segments.get(i);
      svg.stroke(0);
      stroke(0);
      svg.line(thisS.a.x, thisS.a.y, thisS.b.x, thisS.b.y);
      line(thisS.a.x, thisS.a.y, thisS.b.x, thisS.b.y);
    }
  }
  // check ends
  for (int p=0; p<patterns.size(); p++) {
    for (int i=0; i<patterns.get(p).segments.size(); i++) {
      Segment thisS = patterns.get(p).segments.get(i);
      if (thisS.aGrowing||thisS.bGrowing) {
        for (int p2=0; p2<patterns.size(); p2++) {
          for (int j=0; j<patterns.get(p2).segments.size(); j++) {
            Segment thisS2 = patterns.get(p2).segments.get(j);
            if (thisS != thisS2) {
              PVector intersection = lineSegmentIntersection(thisS.a, thisS.b, thisS2.a, thisS2.b);
              //stroke(0xFF,0,0);
              //line(PVector.add(thisS2.a, offset1).x,PVector.add(thisS2.a, offset1).y,PVector.add(thisS2.b, offset1).x,PVector.add(thisS2.b, offset1).y);
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

class Pattern {
  int minX, minY, maxX, maxY;
  ArrayList<Segment> segments = new ArrayList<Segment>();
}

int nbExported = 0;
void keyPressed() {
  if (keyCode==TAB) save("result"+nf(nbExported++, 4)+".png");
  generate();
}

void generate() {
  patterns.clear();
  for (int pX = 0; pX<5; pX++) {
    for (int pY = 0; pY<3; pY++) {
      Pattern thisPattern = new Pattern();
      thisPattern.minX=pX*10-1;
      thisPattern.minY=pY*10-1;
      thisPattern.maxX=pX*10+8-1;
      thisPattern.maxY=pY*10+8-1;
      thisPattern.segments.clear();
      ArrayList<Float> angles = new ArrayList<Float>();
      int nbLinesPerPattern = floor(random(2, 6));
      float minAngleGap = (HALF_PI/((float)nbLinesPerPattern*1.5));
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
        for (int x=thisPattern.minX; x<thisPattern.maxX; x++) {
          for (int y=thisPattern.minY; y<thisPattern.maxY; y++) {
            thisPattern.segments.add(new Segment(pos.x+x*patternSize, pos.y+y*patternSize, pos.x+cos(angle)+x*patternSize, pos.y+sin(angle)+y*patternSize, c));
          }
        }
      }
      patterns.add(thisPattern);
    }
  }
}

public float vrMax(float a, float b, float m) {
  float d1 = b - a;
  if (d1 >  m/2) d1=d1-m;
  if (d1 < -m/2) d1=d1+m;
  return d1;
}
