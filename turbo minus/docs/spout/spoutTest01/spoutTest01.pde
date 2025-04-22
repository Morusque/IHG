
import spout.*;
Spout spout;

ArrayList<PVector[]> segments = new ArrayList<>();

void setup() {
  size(500, 500, P2D);
  spout = new Spout(this);
  for (int i = 0; i < 10; i++) segments.add(new PVector[] {new PVector((i * 23) % width, (i * 47) % height), new PVector((i * 30) % width, (i * 52) % height)});
}

void draw() {
  // update
  for (int i = 0; i < segments.size(); i++) {
    PVector[] thisS = segments.get(i);
    thisS[0].x=(thisS[0].x+i-2)%width;
    thisS[0].y=(thisS[0].y+i-1)%height;
    thisS[1].x=(thisS[1].x+i+1)%width;
    thisS[1].y=(thisS[1].y+i+2)%height;
  }
  ArrayList<PVector[]> shapes = SegmentProcessor.processSegments(segments);
  // draw
  background(0);
  for (PVector[] s : segments) {
    stroke(0xFF);
    line(s[0].x, s[0].y, s[1].x, s[1].y);
  }
  int cI = 0;
  for (PVector[] s : shapes) {
    noStroke();
    fill(color(cI*5%0x100, cI*10%0x100, cI*15%0x100));
    beginShape();
    for (PVector sp : s) vertex(sp.x, sp.y);
    endShape();
    cI++;
  }
  spout.sendTexture();
}
