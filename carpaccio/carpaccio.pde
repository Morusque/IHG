
ArrayList<PImage> images = new ArrayList<PImage>();
ArrayList<PImage> invertedImages = new ArrayList<PImage>();
ArrayList<String> doneUrls = new ArrayList<String>();

color bgColor = color(0xFF);

int nbShapes = 5;
PImage[] selectedIms = new PImage[nbShapes];
float[] selectedLengths = new float[nbShapes];
int[] nbDivisions = new int[nbShapes];

boolean loadedOnce = false;

boolean export = false;

int nbExported=0;

float pop=0;
PImage poppingIm = null;
float popRotate = 0;

boolean gribouillisMode = false;
boolean invertPics = true;

int mode = 0;
// 0 = colored background,   normal shapes
// 1 = white background,     product shapes,   product colored overlay
// 2 = black background,     inverted shapes,  product colored overlay
// 3 = white background,     product shapes

void setup() {
  size(1600, 1000, P2D);
  // fullScreen(2, P2D);
  fullScreen(2);
  frameRate(30);
  // frame.toFront();
  // frame.requestFocus();
}

void draw() {
  pop = max(pop*0.98f-0.1, 0);
  if (mode==0) background(bgColor);
  if (mode==1) background(bgColor);
  if (mode==2) background(0);
  if (mode==3) background(0xFF);
  if (images.size()>0) {
    if (frameCount%100==1||!loadedOnce) changePattern();
    if (loadedOnce) {
      for (int i=0; i<nbShapes; i++) {
        for (int j=0; j<nbDivisions[i]; j++) {
          pushMatrix();
          translate(width/2, height/2);
          rotate((float)j*TWO_PI/nbDivisions[i]);
          rotate((float)frameCount*(i-2)/300);
          translate(selectedLengths[i], 0);
          scale(0.7f);
          imageMode(CENTER);
          blendMode(NORMAL);
          if (mode==1 || mode==3) blendMode(MULTIPLY);
          image(selectedIms[i], 0, 0);
          popMatrix();
        }
      }
      if (pop>0) {
        pushMatrix();
        translate(width/2, height/2);
        scale(pop);
        rotate(popRotate);
        imageMode(CENTER);
        image(poppingIm, 0, 0);
        popMatrix();
      }
    }
  }
  if (mode==1||mode==2) {
    blendMode(MULTIPLY);
    noStroke();
    fill(bgColor);
    rect(0, 0, width, height);
  }
  if (export) {
    save(dataPath("results/anim/"+nf(frameCount, 4)+".png"));
  }
}

void keyPressed() {
  if (keyCode==CONTROL) {
    thread("loadFiles");
  }
  if (keyCode==ENTER) {
    changePattern();
  }
  if (keyCode==TAB) {
    save(dataPath("results/"+nf(nbExported++, 4)+".png"));
  }
  if (keyCode=='E') {
    export ^= true;
  }
  if (keyCode=='P') {
    if (images.size()>0) {
      pop = 6;
      if (mode==0||mode==1||mode==3) poppingIm = images.get(floor(random(images.size())));
      if (mode==2) poppingIm = invertedImages.get(floor(random(invertedImages.size())));
    }
  }
  if (keyCode=='G') {
    gribouillisMode ^= true;
    println("gribouillisMode : "+gribouillisMode);
  }
  if (key=='0') {
    mode = 0;
    changePattern();
  }
  if (key=='1') {
    mode = 1;
    changePattern();
  }
  if (key=='2') {
    mode = 2;
    changePattern();
  }
  if (key=='3') {
    mode = 3;
    changePattern();
  }
}

void generate() {
}

PImage cutShape(PImage oIm) {
  PImage im = oIm.get();
  // crop borders
  int margin = min(min(30, floor((float)im.width/2)), floor((float)im.height/2));
  if (gribouillisMode) margin = 1;
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
      mask.stroke(0xFF);
      if (toErase[x+y*im.width]) mask.stroke(0);
      for (int x2=-1; x2<2; x2++) {
        for (int y2=-1; y2<2; y2++) {
          if (toErase[((x+x2)+(y+y2)*im.width+toErase.length)%toErase.length]) mask.stroke(0);
        }
      }
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
  if (gribouillisMode) inputUrl = getAllFilesFrom(dataPath("../../gribouillis/gribouilliSplit/data/processed/radis"));
  for (int i=0; i<inputUrl.length; i++) {
    try {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println("loading file : "+inputUrl[i]);
        String fileName = fileName(inputUrl[i]);
        if (new File(dataPath("processed/"+"p_"+fileName)).exists()) {
          try {
            PImage cutted = loadImage(dataPath("processed/"+"p_"+fileName));
            images.add(cutted);
          }
          catch(Exception e) {
            println(e);
          }
          if (invertPics) {
            try {
              PImage inverted = loadImage(dataPath("processed/"+"p_i_"+fileName));
              invertedImages.add(inverted);
            }
            catch(Exception e) {
              println(e);
            }
          }
        } else {
          if (gribouillisMode) {
            PImage cutted = cutShape(loadImage(inputUrl[i]));//.get(495,475,1333,707)
            float reducedRatio = min(300.0f/(float)cutted.width, 300.0f/(float)cutted.height);
            cutted.resize(floor(cutted.width*reducedRatio), floor(cutted.height*reducedRatio));
            cutted.save(dataPath("processed/"+"p_"+fileName));
            images.add(cutted);
          } else {
            PImage cutted = cutShape(loadImage(inputUrl[i]));//.get(495,475,1333,707)
            float reducedRatio = min(300.0f/(float)cutted.width, 300.0f/(float)cutted.height);
            cutted.resize(floor(cutted.width*reducedRatio), floor(cutted.height*reducedRatio));
            cutted.save(dataPath("processed/"+"p_"+fileName));
            images.add(cutted);
            if (invertPics) {
              PGraphics inverted = createGraphics(cutted.width, cutted.height);
              inverted.beginDraw();
              inverted.image(cutted, 0, 0);
              inverted.filter(INVERT);
              inverted.endDraw();
              inverted.get().save(dataPath("processed/"+"p_i_"+fileName));
              invertedImages.add(inverted.get());
            }
          }
        }
        doneUrls.add(inputUrl[i]);
      }
    }
    catch (Exception e) {
      println(e);
    }
  }
}

void changePattern() {
  if ((mode==0||mode==1||mode==3) && images.size()==0) return;
  if ((mode==2) &&  invertedImages.size()==0) return;
  nbShapes = floor(random(4, 8));
  selectedIms = new PImage[nbShapes];
  selectedLengths = new float[nbShapes];
  nbDivisions = new int[nbShapes];
  for (int i=0; i<nbShapes; i++) {
    nbDivisions[i] = floor(random(2, 14));
    if (mode==0||mode==1||mode==3) selectedIms[i] = images.get(floor(random(images.size())));
    if (mode==2) selectedIms[i] = invertedImages.get(floor(random(invertedImages.size())));
    selectedLengths[i] = random(dist(0, 0, width, height)/3.0f);
    bgColor = color(floor(random(0x100)), floor(random(0x100)), floor(random(0x100)));
  }
  loadedOnce = true;
  //POP
  /*
  if (images.size()>0 && random(1)<0.5) {
   pop = 2;
   popRotate = random(TWO_PI);
   poppingIm = images.get(floor(random(images.size())));
   }
   */
}
