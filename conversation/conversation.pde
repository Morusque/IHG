
String[] imagesUrl = new String[0];

void setup() {
  size(1400, 1000);
  frameRate(10);
  generate();
}

void draw() {
  if (frameCount%50==0) {
    loadPics();
    generate();
  }
}

void loadPics() {
  try {
    imagesUrl = getAllFilesFrom(dataPath("input"));
  }
  catch(Exception e) {
    println(e);
  }
}

void keyPressed() {
  if (keyCode==CONTROL) loadPics();
  if (keyCode==RIGHT) generate();
}

void generate() {
  background(0xFF);
  if (imagesUrl.length>0) {
    PImage[] rndIms = new PImage[5];
    for (int i=0; i<rndIms.length; i++) rndIms[i] = loadImage(imagesUrl[floor(random(imagesUrl.length))]);
    PGraphics montage = createGraphics(2323, 1660);
    montage.beginDraw();
    montage.image(rndIms[0], 0, 0);
    paste(montage, rndIms[1], 0, 0, 1160, 700);
    paste(montage, rndIms[2], 1171, 0, 1152, 700);
    paste(montage, rndIms[3], 385, 1010, 375, 445);
    paste(montage, rndIms[4], 1583, 1011, 371, 437);
    montage.endDraw();
    image(montage, 0, 0, width, height);
  }
}

void paste(PGraphics gr, PImage im, float x, float y, float w, float h) {
  gr.image(im.get(floor(x), floor(y), floor(w), floor(h)), x, y, w, h);
}
