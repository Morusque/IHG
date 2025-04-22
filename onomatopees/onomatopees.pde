
import themidibus.*;

MidiBus myBus;

ArrayList<String> doneUrls = new ArrayList<String>();

ArrayList<Onom> onoms = new ArrayList<Onom>();

int noteOffset = 0;

float globalScale = 2.0;

void setup() {
  // size(1000, 800);
  fullScreen(2);
  background(0);
  frameRate(50);

  MidiBus.list();
  myBus = new MidiBus(this, "loopMIDI Port", -1);

  imageMode(CENTER);
  rectMode(CENTER);
}

void draw() {
  background(0xFF);
  for (Onom onom : onoms) onom.update();
  for (Onom onom : onoms) onom.draw();
}

void noteOn(int channel, int pitch, int velocity) {
  // println("note on "+pitch);
  if (onoms.size()==0) return;
  int thisOnomIndex = (pitch+noteOffset)%onoms.size();
  onoms.get(thisOnomIndex).on(velocity);
}

void noteOff(int channel, int pitch, int velocity) {
  if (onoms.size()==0) return;
  int thisOnomIndex = (pitch+noteOffset)%onoms.size();
  onoms.get(thisOnomIndex).off();
}

class Onom {
  boolean on = false;
  float scale = 1;
  PVector pos;
  PVector size;
  PImage im;
  int index;

  Onom(PImage im) {
    this.index = onoms.size();
    this.im = im;
    pos = new PVector(width/2+random(-200, 200), height/2+random(-200, 200));
    size = new PVector(im.width, im.height);
  }

  void update() {
    if (scale>0) scale *= 0.95;
    if (scale<0.01) on = false;
  }

  void draw() {
    if (on) {
      image(im, pos.x, pos.y, size.x*scale*globalScale, size.y*scale*globalScale);
    }
  }

  void on(int velocity) {
    // println("on "+index);
    scale = constrain(scale+1, 1, 2);
    on = true;
  }

  void off() {
    on = false;
  }
}

void keyPressed() {
  if (keyCode == CONTROL) {
    println("loading...");
    String[] inputUrl = getAllFilesFrom(dataPath("input"));
    for (int i=0; i<inputUrl.length; i++) {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println("file : "+inputUrl[i]);
        PImage cutted = cutShape(loadImage(inputUrl[i]));
        float reducedRatio = min(300.0f/(float)cutted.width, 300.0f/(float)cutted.height);
        cutted.resize(floor(cutted.width*reducedRatio), floor(cutted.height*reducedRatio));
        onoms.add(new Onom(cutted));
        doneUrls.add(inputUrl[i]);
      }
    }
    println("...done");
  }
  if (keyCode == RIGHT) {
    noteOffset++;
  }
  if (key == '1') {
    int thisOnomIndex = (1+noteOffset)%onoms.size();
    onoms.get(thisOnomIndex).on(100);
  }
  if (key == '2') {
    int thisOnomIndex = (2+noteOffset)%onoms.size();
    onoms.get(thisOnomIndex).on(100);
  }
  if (key == '3') {
    int thisOnomIndex = (3+noteOffset)%onoms.size();
    onoms.get(thisOnomIndex).on(100);
  }
  if (keyCode == UP) {
    globalScale++;
  }
  if (keyCode == DOWN) {
    globalScale++;
  }
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
