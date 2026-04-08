
ArrayList<Stem> stems = new ArrayList<Stem>();

boolean dark = false;

void setup() {
  size(1920, 1080);
  fullScreen();
  colorMode(HSB);
  frameRate(20);
  stems.add(new Stem());
}

void draw() {
  background(0xFF);
  for (Stem s : stems) s.extend();
  if (stems.get(stems.size()-1).stuck) {
    stems.add(new Stem());
    if (stems.size()>8) stems.remove(0);
  }
  for (Stem s : stems) s.drawStem();
  for (Stem s : stems) s.drawFlowers();
  if (dark) background(0);
}

class Stem {
  ArrayList<PVector> path = new ArrayList<PVector>();
  color stemColor;
  ArrayList<Flower> flowers = new ArrayList<Flower>();
  float stemWeight = 10;
  boolean stuck = false;
  Stem() {
    path.add(new PVector((float)width/2 + round(random(-10, 10))*50, (float)height/2 + round(random(-10, 10))*50));
    stemColor = color(0x40+random(-20, 20), 0x80, 0x80);
    stemWeight = 5;
  }
  void extend() {
    boolean pointFound = false;
    for (int i=0; i<10 && !pointFound; i++) {
      stuck = false;
      PVector nextP = path.get(path.size()-1).copy();
      nextP.x += round(random(-1, 1))*50;
      nextP.y += round(random(-1, 1))*50;
      for (Stem s : stems) for (PVector p : s.path) if (PVector.dist(nextP, p)<1) stuck = true;
      if (nextP.x<0 || nextP.x>=width || nextP.y<0 || nextP.y>=height) stuck = true;
      if (stuck) continue;
      path.add(nextP);
      pointFound = true;
      if (random(1)<0.1) flowers.add(new Flower(nextP));
      stuck = false;
    }
  }
  void drawStem() {
    strokeWeight(stemWeight);
    stroke(stemColor);
    strokeJoin(ROUND);
    noFill();
    beginShape();
    for (PVector p : path) {
      vertex(p.x, p.y);
    }
    endShape(OPEN);
  }
  void drawFlowers() {
    for (Flower f : flowers) f.draw();
  }
}

class Flower {
  PVector pos;
  int nbLayers;
  int[] nbPetals;
  float[] petalSize;
  color[] c;
  Flower(PVector pos) {
    this.pos = pos;
    nbLayers = floor(random(1, 5));
    c = new color[nbLayers];
    nbPetals = new int[nbLayers];
    petalSize = new float[nbLayers];
    for (int i=0; i<nbLayers; i++) {
      nbPetals[i] = floor(random(1, 12));
      petalSize[i] = random(80.0, 160.0)/(nbPetals[i]+2);
      c[i] = color(random(0x100), random(0x80, 0x100), random(0x80, 0x100));
      if (i!=0 && random(1)<0.7) {
        nbPetals[i] = round(nbPetals[i-1] * pow(2, floor(random(5)/2)));
        petalSize[i] = petalSize[i-1] * random(0.5, 1.5);
        c[i] = lerpColor(c[i-1], c[i], 0.5);
      }
    }
  }
  void draw() {
    noStroke();
    for (int l = 0; l<nbLayers; l++) {
      fill(c[l]);
      for (int i=0; i<nbPetals[l]; i++) {
        float phase = (float)i/nbPetals[l]*TWO_PI;
        float len = petalSize[l];
        if (nbPetals[l]==1) len = 0;
        rectMode(CENTER);
        rect(pos.x+cos(phase)*len, pos.y+sin(phase)*len, petalSize[l], petalSize[l]);
      }
    }
  }
}

void keyPressed() {
  if (keyCode==BACKSPACE) dark^=true;
}
