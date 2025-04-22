
ArrayList<PImage> images = new ArrayList<PImage>();
ArrayList<String> doneUrls = new ArrayList<String>();

ArrayList<Sprite> sprites = new ArrayList<Sprite>();
int imageToSwitch = 0;

String mot;
String[] mots;

int counter;

boolean auto = true;

color background = color(250, 130, 50);
color backgroundTarget = color(250, 130, 50);

int mode = 1;
// 0 = mots
// 1 = images

void setup() {
  size(900, 700);
  fullScreen(2);
  frameRate(10);
  colorMode(RGB);
  textFont(loadFont(dataPath("files/OCRAStd-80.vlw")));
  mots = loadStrings(dataPath("files/topics (concret).txt"));
  mot = "";
}

void draw() {
  if (mode == 0) {
    if (counter>0 && auto) counter--;
    if (counter<=0) counter--;
    if (counter<=0) mot = (mots[floor(random(mots.length))]+"-"+mots[floor(random(mots.length))]).toLowerCase();
    if (counter<=-10) {
      background = Color.HSBtoRGB(random(0x100), random(0x50, 0x100), random(0xA0, 0x100));
      counter = 600;
    }
    println(counter);
    background(background);
    textAlign(CENTER, CENTER);
    textSize(50);
    fill(0);
    text(mot, 10, 10, width-20, height-20);
  }
  if (mode == 1) {
    if (random(100)<1) backgroundTarget = Color.HSBtoRGB(random(0x100), random(0x50, 0x100), random(0xA0, 0x100));
    background = lerpColor(background, backgroundTarget, 0.05);
    for (int i=0; i<sprites.size(); i++) sprites.get(i).update();
    for (int i=0; i<sprites.size(); i++) if (sprites.get(i).phase==3) sprites.remove(i);
    if (images.size()>0) {
      if (sprites.size()==0 || random(sprites.size())<0.05) {
        addOneSprite();
      }
    }
    background(background);
    for (int i=0; i<sprites.size(); i++) sprites.get(i).draw();
  }
}

void keyPressed() {
  if (keyCode=='R') {
    counter=0;
  }
  if (keyCode=='S') {
    addOneSprite();
  }
  if (keyCode=='D') {
    for (int i=0; i<sprites.size(); i++) {
      if (sprites.get(i).phase<2) {
        sprites.get(i).phase=2;
        break;
      }
    }
  }
  if (keyCode==CONTROL) {
    thread("loadFiles");
  }
  if (keyCode==RIGHT) {
    mode = (mode+1)%2;
  }
}

void addOneSprite() {
  PVector bestPosition = new PVector(0, 0);
  float furthest = 0;
  for (int x=0; x<width; x+=10) {
    for (int y=0; y<height; y+=10) {
      float closest = width*height;
      for (int s=0; s<sprites.size(); s++) {
        float thisDist = dist(x, y, sprites.get(s).position.x, sprites.get(s).position.y);
        if (thisDist<closest) closest = thisDist;
      }
      if (abs(y-0)<closest) closest = abs(y-0);
      if (abs(y-height)<closest) closest = abs(y-height);
      if (abs(x-0)<closest) closest = abs(x-0);
      if (abs(x-width)<closest) closest = abs(x-width);
      if (closest > furthest) {
        bestPosition = new PVector(x, y);
        furthest = closest;
      }
    }
  }
  if (images.size()>0) sprites.add(new Sprite(images.get(floor(random(images.size()))), bestPosition));
}

PImage cutShape(PImage oIm) {
  PImage im = oIm.get();
  // crop borders
  int margin = min(min(30, floor((float)im.width/2)), floor((float)im.height/2));
  im = im.get(margin, margin, im.width-margin*2, im.height-margin*2);
  // crop shape
  int startX = 0;
  int startY = 0;
  int endX = im.width;
  int endY = im.height;
  float threshold = 1;
  im.loadPixels();
  for (int x = 0; x<im.width && startX==0; x++) {
    float thisDrakness = 0;
    for (int y = 0; y<im.height; y++) {
      color c = im.pixels[x+y*im.width];
      thisDrakness += 0xFF*3-(red(c)+green(c)+blue(c));
    }
    thisDrakness/=im.height;
    if (thisDrakness>threshold) startX=x;
  }
  for (int y = 0; y<im.height && startY==0; y++) {
    float thisDrakness = 0;
    for (int x = 0; x<im.width; x++) {
      color c = im.pixels[x+y*im.width];
      thisDrakness += 0xFF*3-(red(c)+green(c)+blue(c));
    }
    thisDrakness/=im.width;
    if (thisDrakness>threshold) startY=y;
  }
  for (int x = im.width-1; x>=startX && endX==im.width; x--) {
    float thisDrakness = 0;
    for (int y = 0; y<im.height; y++) {
      color c = im.pixels[x+y*im.width];
      thisDrakness += 0xFF*3-(red(c)+green(c)+blue(c));
    }
    thisDrakness/=im.height;
    if (thisDrakness>threshold) endX=x;
  }
  for (int y = im.height-1; y>=startY && endY==im.height; y--) {
    float thisDrakness = 0;
    for (int x = 0; x<im.width; x++) {
      color c = im.pixels[x+y*im.width];
      thisDrakness += 0xFF*3-(red(c)+green(c)+blue(c));
    }
    thisDrakness/=im.width;
    if (thisDrakness>threshold) endY=y;
  }
  im = im.get(startX, startY, endX-startX, endY-startY);
  // add white margin
  PImage largerIm = createImage(im.width+2, im.height+2, RGB);
  largerIm.loadPixels();
  for (int i = 0; i < largerIm.pixels.length; i++) largerIm.pixels[i] = color(0xFF);
  largerIm.updatePixels();
  largerIm.copy(im, 0, 0, im.width, im.height, 1, 1, im.width, im.height);
  im = largerIm;
  // expand cutted zone
  float emptyThreshold = 15;
  boolean[] empty = new boolean[im.width*im.height];
  im.loadPixels();
  for (int x = 0; x<im.width; x++) {
    for (int y = 0; y<im.height; y++) {
      color c = im.pixels[x+y*im.width];
      if (0xFF*3-(red(c)+green(c)+blue(c))>emptyThreshold) empty[x+y*im.width] = false;
      else empty[x+y*im.width] = true;
    }
  }
  boolean[] done = new boolean[im.pixels.length];
  boolean[] toErase = new boolean[im.pixels.length];
  for (int i=0; i<im.pixels.length; i++) {
    done[i] = false;
    toErase[i] = false;
  }
  ArrayList<Integer> toCheck = new ArrayList<Integer>();
  toCheck.add(0);
  done[0] = true;
  while (toCheck.size()>0) {
    // println((float)toCheck.size()/done.length);
    /*
    if (toCheck.size()<50) {
     for (int i : toCheck) print(i+",");
     println("-");
     }
     */
    int thisIndex = toCheck.remove(0);
    if (empty[thisIndex]) {
      toErase[thisIndex] = true;
      if (!done[(thisIndex-1+done.length)%done.length]) {
        toCheck.add((thisIndex-1+done.length)%done.length);
        done[(thisIndex-1+done.length)%done.length] = true;
      }
      if (!done[(thisIndex+1+done.length)%done.length]) {
        toCheck.add((thisIndex+1+done.length)%done.length);
        done[(thisIndex+1+done.length)%done.length] = true;
      }
      if (!done[(thisIndex-im.width+done.length)%done.length]) {
        toCheck.add((thisIndex-im.width+done.length)%done.length);
        done[(thisIndex-im.width+done.length)%done.length] = true;
      }
      if (!done[(thisIndex+im.width+done.length)%done.length]) {
        toCheck.add((thisIndex+im.width+done.length)%done.length);
        done[(thisIndex+im.width+done.length)%done.length] = true;
      }
    }
  }
  PGraphics mask = createGraphics(im.width, im.height, JAVA2D);
  mask.beginDraw();
  for (int x=0; x<im.width; x++) {
    for (int y=0; y<im.height; y++) {
      if (toErase[x+y*im.width]) mask.stroke(0);
      else mask.stroke(0xFF);
      mask.point(x, y);
    }
  }
  mask.endDraw();
  im.mask(mask);
  // TODO trace polygon
  return im;
}

void loadFiles() {
  String[] inputUrl = getAllFilesFrom(dataPath("input"));
  for (int i=0; i<inputUrl.length; i++) {
    if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
      println("loading file : "+inputUrl[i]);
      String fileName = fileName(inputUrl[i]);
      if (new File(dataPath("processed/"+"p_"+fileName)).exists()) {
        PImage cutted = loadImage(dataPath("processed/"+"p_"+fileName));
        images.add(cutted);
      } else {
        PImage cutted = cutShape(loadImage(inputUrl[i]));//.get(495,475,1333,707)
        float reducedRatio = min(300.0f/(float)cutted.width, 300.0f/(float)cutted.height);
        cutted.resize(floor(cutted.width*reducedRatio), floor(cutted.height*reducedRatio));
        cutted.save(dataPath("processed/"+"p_"+fileName));
        images.add(cutted);
      }
      doneUrls.add(inputUrl[i]);
    }
  }
}

class Sprite {
  PImage im;
  float scale = 0;
  float scaleD = 0;
  float rotation = 0;
  float rotationD = 0;
  PVector position;
  int lifetime = 0;
  int phase = 0;
  // 0 = appear
  // 1 = stands
  // 2 = disappear
  // 3 = gone
  Sprite(PImage im, PVector position) {
    this.im = im;
    this.position = position;
    if (random(10)<2) rotationD = random(-0.01, 0.01);
    if (random(10)<2) scaleD = random(-0.01, 0.01);
  }
  void update() {
    if (phase==0) {
      scale+=0.15;
      if (scale>=1.2) phase = 1;
    }
    if (phase==1) {
      if (lifetime>50 && random(100.0/(1.0+lifetime/100))<1) phase = 2;
    }
    if (phase==2) {
      scale = max(scale*0.99-0.15, 0);
      if (scale==0) phase = 3;
    }
    rotation+=rotationD;
    scale+=scaleD;
    lifetime++;
  }
  void draw() {
    pushMatrix();
    translate(position.x, position.y);
    rotate(rotation);
    scale(scale);
    imageMode(CENTER);
    image(im, 0, 0);
    popMatrix();
  }
}
