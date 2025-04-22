
PImage im;
PImage tri;

float triSize = 350;
float rotationOffset = 0;

PVector cutPos = new PVector(random(1), random(1));

int currentPic = 0;
int nbSavedPics = 0;

int phase = 0;
// 0 = image
// 1 = animation
float phaseTimer = 0;

void setup() {
  size(1200, 900, P2D);
  // fullScreen(P2D, 2);
  frameRate(30);
  reload();
}

void draw() {
  // update
  if (phase==0) {
    rotationOffset+=0.03f;
    if (phaseTimer>=70) {
      phase++;
      phaseTimer=0;
    }
  }
  if (phase==1) {
    tri = cut(im, cutPos);
    rotationOffset+=0.03f;
    if (phaseTimer>=100) {
      reload();
    }
  }
  phaseTimer++;

  // draw
  background(0xFF);
  if (phase==0) {
    imageMode(CORNER);
    if (im!=null) image(im, 0, 0, width, height);
    noFill();
    stroke(0, 0, 0xFF);
    strokeWeight(3);
    pushMatrix();
    beginShape();
    for (int i = 0; i<4; i++) {
      float a = (float)i*TWO_PI/3;
      vertex(cutPos.x*width+cos(a-rotationOffset)*triSize*0.5f, cutPos.y*height+sin(a-rotationOffset)*triSize*0.5f);
    }
    endShape();
    popMatrix();
  }
  if (phase==1) {
    pushMatrix();
    translate(width/2, height/2);
    rotate(-rotationOffset);
    translate(-width/2, -height/2);    
    background(0xFF);
    float side = 2*(cos(PI/6)*triSize);
    float hSize = sqrt(sq(side)-sq(side/2));
    translate(-200, -200);
    for (int k=0; k<7; k++) {
      for (int l=0; l<7; l++) {
        pushMatrix();
        translate(k*hSize+(l%2)*hSize/2, l*side*1.5/2);
        scale(0.5f);
        for (int j=0; j<2; j++) {
          pushMatrix();
          scale(j%2==0?1:-1, 1);
          for (int i=0; i<3; i++) {
            float a = (float)i*TWO_PI/3;
            imageMode(CENTER);
            pushMatrix();
            translate(cos(a)*triSize, sin(a)*triSize);
            rotate(a+PI*5/3);
            if (tri!=null) image(tri, 0, 0);
            popMatrix();
          }
          popMatrix();
        }
        popMatrix();
      }
    }
    popMatrix();
  }
}

PImage cut(PImage im, PVector cutPos) {
  PGraphics tri = createGraphics(floor(triSize*2), floor(triSize*2), P2D);
  tri.beginDraw();
  tri.noStroke();
  tri.beginShape();
  tri.texture(im);
  for (int i = 0; i<3; i++) {
    float a = (float)i*TWO_PI/3;
    if (im != null) tri.vertex(triSize+cos(a)*triSize, triSize+sin(a)*triSize, cutPos.x*im.width+cos(a+rotationOffset)*triSize, cutPos.y*im.height+sin(a+rotationOffset)*triSize);
  }
  tri.endShape();
  tri.endDraw();
  return tri.get();
}

void reload() {
  String[] files = getAllFilesFrom(dataPath("input"));
  cutPos = new PVector(random(0.2, 0.8), random(0.25, 0.75));
  if (files.length>0) im = loadImage(files[(currentPic++)%files.length]);
  phase = 0;
  phaseTimer = 0;
}

void keyPressed() {
  if (keyCode==ENTER) reload();
  if (keyCode==TAB) save(dataPath("result/"+nf(nbSavedPics++, 4)+".png"));
}