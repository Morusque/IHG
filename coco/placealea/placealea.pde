
ArrayList<Sticker> stickers = new ArrayList<Sticker>();
PImage overlay;
ArrayList<Box> boxes = new ArrayList<Box>();

void setup() {
  size(700, 900);
  String[] stickersUrl = getAllFilesFrom(dataPath("files/stickers"));
  for (String url : stickersUrl) {
    stickers.add(new Sticker(url));
  }
  overlay = loadImage(dataPath("files/overlay01.png"));
  boxes.add(new Box(125, 355, 1063, 945));
  boxes.add(new Box(1283, 355, 1063, 945));
  boxes.add(new Box(125, 1392, 1063, 945));
  boxes.add(new Box(1283, 1392, 1063, 945));
  boxes.add(new Box(125, 2430, 1063, 945));
  boxes.add(new Box(1283, 2430, 1063, 945));
}

void draw() {
}

void keyPressed() {
  if (key==ENTER) generate();
  if (key=='1') crop();
}

void crop() {
  println("cropping");
  String[] picsUrl = getAllFilesFrom(dataPath("scan"));
  for (int i=0; i<picsUrl.length; i++) {
    try {
      PImage im = loadImage(picsUrl[i]);
      PImage im2 = im.get(30, 30, im.width-60, im.height-60);
      im2.save(dataPath("scan/cropped/"+nf(i, 4)+".png"));
    }
    catch(Exception e) {
      println(e);
    }
  }
  println("done");
}

void generate() {
  float stickersScale = 0.4;
  PGraphics gr = createGraphics(overlay.width, overlay.height);
  gr.beginDraw();
  gr.background(0xFF);
  for (Box b : boxes) {
    int nbStickers = 1;
    if (random(1)<0.5) nbStickers = floor(random(0, 3));
    for (int i=0; i<nbStickers; i++) {
      Sticker sticker = stickers.get(floor(random(stickers.size())));
      PImage finalSticker = manipulateSticker(sticker.im, stickersScale, random(-sticker.maxRotation/2, sticker.maxRotation/2)/180*PI);
      float maxX = b.pos.x+b.siz.x-finalSticker.width;
      float maxY = b.pos.y+b.siz.y-finalSticker.height;
      gr.pushMatrix();
      gr.translate(random(b.pos.x, maxX), random(b.pos.y, maxY));
      gr.image(finalSticker, 0, 0);
      gr.popMatrix();
    }
  }
  gr.image(overlay, 0, 0);
  gr.endDraw();
  int nbExported = getAllFilesFrom(dataPath("output")).length;
  gr.save(dataPath("output/result"+nf(nbExported, 4)+".png"));
  scale(0.25);
  background(0xFF);
  image(gr, 0, 0);
}

class Box {
  PVector pos;
  PVector siz;
  Box(float x, float y, float w, float h) {
    pos = new PVector(x, y);
    siz = new PVector(w, h);
  }
}

class Sticker {
  PImage im;
  float maxRotation;
  Sticker(String url) {
    this.im = loadImage(url);
    String rotStr = url.split("_")[url.split("_").length-1];
    rotStr = rotStr.substring(0, rotStr.length()-4);
    this.maxRotation = Float.parseFloat(rotStr);
  }
}

PImage manipulateSticker(PImage im, float scale, float rotation) {
  int maxDim = ceil(max(im.width, im.height)*2*scale);
  PGraphics gr = createGraphics(maxDim, maxDim, JAVA2D);
  gr.beginDraw();
  gr.pushMatrix();
  gr.translate(gr.width/2, gr.height/2);
  gr.rotate(rotation);
  gr.scale(scale);
  gr.translate(-im.width/2, -im.height/2);
  gr.image(im, 0, 0);
  gr.popMatrix();
  gr.endDraw();
  float minX=-1;
  float minY=-1;
  float maxX=-1;
  float maxY=-1;
  for (int x=0; x<gr.width && minX==-1; x++) {
    for (int y=0; y<gr.height && minX==-1; y++) {
      if (alpha(gr.get(x, y))>0) {
        minX = x-1;
      }
    }
  }
  for (int y=0; y<gr.height && minY==-1; y++) {
    for (int x=0; x<gr.width && minY==-1; x++) {
      if (alpha(gr.get(x, y))>0) {
        minY = y-1;
      }
    }
  }
  for (int x=gr.width-1; x>=0 && maxX==-1; x--) {
    for (int y=0; y<gr.height && maxX==-1; y++) {
      if (alpha(gr.get(x, y))>0) {
        maxX = x+1;
      }
    }
  }
  for (int y=gr.height-1; y>=0 && maxY==-1; y--) {
    for (int x=0; x<gr.width && maxY==-1; x++) {
      if (alpha(gr.get(x, y))>0) {
        maxY = y+1;
      }
    }
  }
  return gr.get(floor(minX), floor(minY), ceil(maxX-minX), ceil(maxY-minY));
}
