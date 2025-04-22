
ArrayList<PImage> shapes = new ArrayList<PImage>();

ArrayList<Halo> halos = new ArrayList<Halo>();

PImage perso = new PImage();
PVector persoPos = new PVector();
float persoTimer = 0.0;

boolean dark = false;

void setup() {
  fullScreen(P2D, 2);
  perso = loadImage(dataPath("perso/yoga-detoure.png"));
  String[] fs = getAllFilesFrom(dataPath("shapes"));
  for (int i=0; i<fs.length; i++) {
    try {
      PImage im = loadImage(fs[i]);
      if (im!=null) shapes.add(im);
    }
    catch(Exception e) {
      println(e);
    }
  }
  for (int i=0; i<15; i++) halos.add(new Halo());
  background(0);
}

void draw() {

  // draw halos
  for (Halo h : halos) h.draw();

  // dampen the light
  noStroke();
  fill(0, 0x01);
  rect(0, 0, width, height);

  if (persoTimer>0) {
    tint(0xFF, cos(persoTimer*PI)*0x20);
    imageMode(CENTER);
    image(perso, persoPos.x, persoPos.y, (float)perso.width/5.0, (float)perso.height/5.0);
    tint(0xFF);
    persoTimer-=0.05;
  }

  // filter(BLUR, 0.2);

  // add noise
  loadPixels();
  float noiseAmount = 5.0;
  for (int i = 0; i < pixels.length; i++) {
    color original = pixels[i];
    int r = constrain((int)(red(original) + random(-noiseAmount, noiseAmount)), 0, 255);
    int g = constrain((int)(green(original) + random(-noiseAmount, noiseAmount)), 0, 255);
    int b = constrain((int)(blue(original) + random(-noiseAmount, noiseAmount)), 0, 255);
    pixels[i] = color(r, g, b);
  }
  updatePixels();

  // export
  if (export) saveFrame("result/r-#####.png");

  if (dark) background(0);
}

float randomW(float min, float max, float peakValue, float magnet) {
  float rawRandom = random(min, max);                // Random value in full range
  float biasedValue = lerp(rawRandom, peakValue, magnet); // Bias towards peakValue
  if (random(1.0)<magnet) return biasedValue;
  else return rawRandom;
}

class Halo {
  color tint;
  PVector pos;
  PVector size;
  PImage im;
  float alpha = 0;
  float alphaDir = 0;
  Halo() {
    reset();
  }
  void reset() {
    alpha=0;
    alphaDir=random(0.1, 2);
    im = shapes.get(floor(random(shapes.size())));
    pos = new PVector(lerp(random(width), width/2, random(1.0)), lerp(random(height), height/2, random(1.0)));
    float sB = random(0.3, 1.0);
    size = new PVector(im.width*sB, im.height*sB);
    float tintBias = 0.7;
    tint = color(randomW(0, 0x100, 0xA0, tintBias), randomW(0, 0x100, 0x10, tintBias), randomW(0, 0x100, 0xF0, tintBias));
    if (random(1)<0.1) tint = color(0);
  }
  void draw() {
    alpha+=alphaDir;
    if (alpha>=0x20) reset();
    tint(tint, alpha);
    imageMode(CENTER);
    float fuzz = 10;
    image(im, pos.x+random(-fuzz, fuzz), pos.y+random(-fuzz, fuzz), size.x, size.y);
  }
}

boolean export = false;
void keyPressed() {
  if (key==TAB) export = !export;
  if (key=='p') {
    persoPos = new PVector(random(width*1.0/5.0, width*4.0/5.0), random(height*1.0/5.0, height*4.0/5.0));
    persoTimer = 1.0;
  }
  if (keyCode==BACKSPACE) dark^=true;
}
