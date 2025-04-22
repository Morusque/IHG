
ArrayList<PImage> images = new ArrayList<PImage>();

ArrayList<PImage> tops = new ArrayList<PImage>();
ArrayList<PImage> bottoms = new ArrayList<PImage>();

ArrayList<String> doneUrls = new ArrayList<String>();

void setup() {
  size(1200, 900);
  frameRate(50);
}

void draw() {
  if (frameCount%100==1) {
    generate();
    // saveFrame(dataPath("results/result####.png"));
  }
}

void keyPressed() {
  if (keyCode==CONTROL) {
    println("loading...");
    String[] inputUrl = getAllFilesFrom(dataPath("input/base"));
    for (int i=0; i<inputUrl.length; i++) {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println("file : "+inputUrl[i]);
        PImage cutted = cutShape(loadImage(inputUrl[i]).get(814, 445, 694, 686));        
        float reducedRatio = min(300.0f/(float)cutted.width, 300.0f/(float)cutted.height);
        cutted.resize(floor(cutted.width*reducedRatio), floor(cutted.height*reducedRatio));
        images.add(cutted);
        doneUrls.add(inputUrl[i]);
      }
    }

    inputUrl = getAllFilesFrom(dataPath("input/tops"));
    for (int i=0; i<inputUrl.length; i++) {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println("file : "+inputUrl[i]);
        PImage cutted = cutShape(loadImage(inputUrl[i]).get(814, 445, 694, 686));        
        float reducedRatio = min(300.0f/(float)cutted.width, 300.0f/(float)cutted.height);
        cutted.resize(floor(cutted.width*reducedRatio), floor(cutted.height*reducedRatio));
        tops.add(cutted);
        doneUrls.add(inputUrl[i]);
      }
    }

    inputUrl = getAllFilesFrom(dataPath("input/bottoms"));
    for (int i=0; i<inputUrl.length; i++) {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println("file : "+inputUrl[i]);
        PImage cutted = cutShape(loadImage(inputUrl[i]).get(814, 445, 694, 686));        
        float reducedRatio = min(300.0f/(float)cutted.width, 300.0f/(float)cutted.height);
        cutted.resize(floor(cutted.width*reducedRatio), floor(cutted.height*reducedRatio));
        bottoms.add(cutted);
        doneUrls.add(inputUrl[i]);
      }
    }

    println("...done");
  }
}

void generate() {
  background(0xFF);
  float proximity = 30.0f;
  if (images.size()>0) {
    int nbIngredients = 6;
    float currentY = height-50;
    float toppestY = currentY;
    for (int i=0; i<nbIngredients; i++) {
      PImage randomIm = images.get(floor(random(images.size())));
      if (i==0 && bottoms.size()>0) randomIm = bottoms.get(floor(random(bottoms.size())));
      if (i==nbIngredients-1 && tops.size()>0) randomIm = tops.get(floor(random(tops.size())));
      currentY -= randomIm.height;
      currentY -= proximity;
      toppestY = min(toppestY, currentY);
      if (i==nbIngredients-1) currentY = toppestY - proximity;
      image(randomIm, width/2-randomIm.width/2, currentY, randomIm.width, randomIm.height);
      currentY += randomIm.height;
    }
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
