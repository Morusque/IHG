
// 0 = Normal
// 1 = Total alpha
// 2 = Négatif
// 3 = N&B ( dit mode Yassine )
// 4 = Machine à laver

// BACKSPACE = dark
// CONTROL = load
// ENTER = change
// TAB = screenshot
// E = export
// P = pop
// A = auto change
// RIGHT = quicker
// LEFT = slower
// B = blink
// F = change folder
  
ArrayList<PImage> images = new ArrayList<PImage>();
ArrayList<PImage> invertedImages = new ArrayList<PImage>();
ArrayList<PImage> multipliableImages = new ArrayList<PImage>();
ArrayList<String> doneUrls = new ArrayList<String>();

color bgColor = color(0xA0, 0x50, 0xA0);

int nbShapes = 5;
PImage[] selectedIms = new PImage[nbShapes];
float[] selectedLengths = new float[nbShapes];
int[] nbDivisions = new int[nbShapes];
float[] selectedSpeedMult = new float[nbShapes];

float globalSpeed = 5;

boolean loadedOnce = false;

boolean export = false;

int nbExported=0;

float pop=0;
PImage poppingIm = null;
float popRotate = 0;

boolean invertPics = true;

int specificRotationType = 1;
// 0 = fixed
// 1 = synced to revolution
// 2 = independant

boolean evenlySpaced = false;

float fixedRatio = -1;// use calculated ratios if -1

int mode = 0;
// 0 = colored background,   normal shapes
// 1 = white background,     product shapes,   product colored overlay
// 2 = black background,     inverted shapes,  product colored overlay
// 3 = white background,     product shapes
// 4 = remanent

color[] palette = new color[]{
  //color(0),
  color(255),
  color(255, 223, 230), // rose
  color(207, 57, 255), // violet
  color(0, 255, 161), // vert
  color(255, 74, 45), // rouge
  color(0, 247, 255)     // bleu
};

PImage sparkle;
ArrayList<Sparkle> sparkles = new ArrayList<Sparkle>();
int nbSparkles=0;

boolean cutPictures = false;

String[] folders;
int folderIndex = -1;

boolean autoChangePattern = false;

boolean dark = false;

int blinkingMode = 0;
// 0 = no
// 1 = yes
// 2 = vertical split
// 3 = horizontal split
// 4 = both split
color[] blinkingColors = new color[]{color(0), color(0xFF)};
float blinkDuration = 200.0;

void setup() {
  //size(1920, 1080, P2D);
  fullScreen(P2D, 2);
  // fullScreen(P2D);
  frameRate(60);
  sparkle = loadImage(dataPath("files/sparkle01.png"));
  // frame.toFront();
  // frame.requestFocus();
  folders = getSubfolders(dataPath("input"));
  folders = sort(folders);
}

void draw() {
  pop = max(pop*0.98f-0.1, 0);

  if (mode==4) for (int i=0; i<nbShapes; i++) selectedLengths[i] *= 1.005;

  if (mode==0) background(bgColor);
  if (mode==1) background(bgColor);
  if (mode==2) background(0);
  if (mode==3) background(0xFF);
  if (blinkingMode!=0) {
    noStroke();
    int frameType = millis()%(int)blinkDuration>blinkDuration/2?1:0;
    if (blinkingMode==1) {
      background(blinkingColors[frameType]);
    }
    if (blinkingMode==2) {
      background(blinkingColors[frameType]);
      fill(blinkingColors[(frameType+1)%2]);
      rect(0, height/2, width, height/2);
    }
    if (blinkingMode==3) {
      background(blinkingColors[frameType]);
      fill(blinkingColors[(frameType+1)%2]);
      rect(width/2, 0, width/2, height);
    }
    if (blinkingMode==4) {
      background(blinkingColors[frameType]);
      fill(blinkingColors[(frameType+1)%2]);
      rect(0, 0, width/2, height/2);
      rect(width/2, height/2, width/2, height/2);
    }
  }
  synchronized (images) {
    if (images.size()>0) {
      if ((frameCount%100==1 || !loadedOnce) && autoChangePattern) changePattern();
      if (loadedOnce) {
        for (int i=0; i<nbShapes; i++) {
          for (int j=0; j<nbDivisions[i]; j++) {
            // Calculate center of the screen
            float centerX = width / 2;
            float centerY = height / 2;

            // Calculate combined global rotation
            float angle1 = (float) j * TWO_PI / nbDivisions[i];
            float rotationDir = (i - 2);
            if (rotationDir<=0) rotationDir -= 1;
            float angle2 = (float) frameCount * selectedSpeedMult[i] * rotationDir / 300 * globalSpeed;
            float combinedAngle = angle1 + angle2;

            // Calculate rotated position of the image
            float cosAngle = cos(combinedAngle);
            float sinAngle = sin(combinedAngle);
            float offsetX = selectedLengths[i] * cosAngle;
            float offsetY = selectedLengths[i] * sinAngle;

            // Dimensions of the image after scaling
            float halfWidth = selectedIms[i].width * 0.7f / 2;
            float halfHeight = selectedIms[i].height * 0.7f / 2;

            // Add specific rotation for each object
            float specificRotation = (float) frameCount * (i + 1) / 200; // rotation per object
            if (specificRotationType == 0) specificRotation = 0;
            if (specificRotationType == 1) specificRotation = combinedAngle;
            float cosSpecific = cos(specificRotation);
            float sinSpecific = sin(specificRotation);

            // Calculate the corners of the rotated rectangle, including object-specific rotation
            float x1 = (-halfWidth * cosSpecific - -halfHeight * sinSpecific); // Top-left corner
            float y1 = (-halfWidth * sinSpecific + -halfHeight * cosSpecific);

            float x2 = (halfWidth * cosSpecific - -halfHeight * sinSpecific); // Top-right corner
            float y2 = (halfWidth * sinSpecific + -halfHeight * cosSpecific);

            float x3 = (halfWidth * cosSpecific - halfHeight * sinSpecific); // Bottom-right corner
            float y3 = (halfWidth * sinSpecific + halfHeight * cosSpecific);

            float x4 = (-halfWidth * cosSpecific - halfHeight * sinSpecific); // Bottom-left corner
            float y4 = (-halfWidth * sinSpecific + halfHeight * cosSpecific);

            // Apply the center offsets
            x1 += centerX + offsetX;
            y1 += centerY + offsetY;
            x2 += centerX + offsetX;
            y2 += centerY + offsetY;
            x3 += centerX + offsetX;
            y3 += centerY + offsetY;
            x4 += centerX + offsetX;
            y4 += centerY + offsetY;

            // Set blend mode
            if (mode == 1 || mode == 3) {
              blendMode(MULTIPLY);
            } else {
              blendMode(NORMAL);
            }

            // Draw the image using the corners
            noStroke();
            textureMode(NORMAL);
            beginShape();
            texture(selectedIms[i]);
            vertex(x1, y1, 0, 0);
            vertex(x2, y2, 1, 0);
            vertex(x3, y3, 1, 1);
            vertex(x4, y4, 0, 1);
            endShape(CLOSE);
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
  }
  if (mode==1||mode==2) {
    blendMode(MULTIPLY);
    noStroke();
    fill(bgColor);
    rect(0, 0, width, height);
  }

  if (mode==0||mode==4) {
    while (sparkles.size()<nbSparkles) sparkles.add(new Sparkle());
    for (int i=sparkles.size()-1; i>=0; i--) {
      sparkles.get(i).draw();
      if (sparkles.get(i).size<=0) sparkles.remove(i);
    }
  }

  if (dark) background(0);

  if (export) {
    save(dataPath("results/anim/"+nf(frameCount, 4)+".png"));
  }
}

void keyPressed() {
  if (keyCode!=BACKSPACE) dark=false;
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
    synchronized (images) {
      if (images.size()>0) {
        pop = 6;
        if (mode==0||mode==4) poppingIm = images.get(floor(random(images.size())));
        if (mode==2) poppingIm = invertedImages.get(floor(random(invertedImages.size())));
        if (mode==1||mode==3) poppingIm = multipliableImages.get(floor(random(invertedImages.size())));
      }
    }
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
  if (key=='4') {
    mode = 4;
    changePattern();
  }
  if (key=='a') {
    autoChangePattern ^= true;
    println("autoChangePattern : "+autoChangePattern);
  }
  if (keyCode == RIGHT) {
    globalSpeed *= 1.5;
    println("globalSpeed : "+globalSpeed);
  }
  if (keyCode == LEFT) {
    globalSpeed /= 1.5;
    println("globalSpeed : "+globalSpeed);
  }
  if (keyCode==BACKSPACE) dark^=true;
  if (key=='b') {
    if (blinkingMode==0) blinkingMode = floor(random(4)+1);
    else blinkingMode = 0;
    println("blinkingMode : "+blinkingMode);
    blinkingColors[0] = palette[floor(random(palette.length))];
    while (blinkingColors[1]==blinkingColors[0]) {
      blinkingColors[1] = palette[floor(random(palette.length))];
    }
  }
  if (key=='f') {
    if (folders.length>0) {
      folderIndex = (folderIndex+1)%folders.length;
    }
    doneUrls.clear();
    synchronized (images) {
      images.clear();
    }
    println(images.size());
    thread("loadFiles");
  }
}

void generate() {
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
    float thisDarkness = 0;
    for (int y = 0; y<im.height; y++) {
      color c = im.pixels[x+y*im.width];
      thisDarkness += 0xFF*3-(red(c)+green(c)+blue(c));
    }
    thisDarkness/=im.height;
    if (thisDarkness>threshold) startX=x;
  }
  for (int y = 0; y<im.height && startY==0; y++) {
    float thisDarkness = 0;
    for (int x = 0; x<im.width; x++) {
      color c = im.pixels[x+y*im.width];
      thisDarkness += 0xFF*3-(red(c)+green(c)+blue(c));
    }
    thisDarkness/=im.width;
    if (thisDarkness>threshold) startY=y;
  }
  for (int x = im.width-1; x>=startX && endX==im.width; x--) {
    float thisDarkness = 0;
    for (int y = 0; y<im.height; y++) {
      color c = im.pixels[x+y*im.width];
      thisDarkness += 0xFF*3-(red(c)+green(c)+blue(c));
    }
    thisDarkness/=im.height;
    if (thisDarkness>threshold) endX=x;
  }
  for (int y = im.height-1; y>=startY && endY==im.height; y--) {
    float thisDarkness = 0;
    for (int x = 0; x<im.width; x++) {
      color c = im.pixels[x+y*im.width];
      thisDarkness += 0xFF*3-(red(c)+green(c)+blue(c));
    }
    thisDarkness/=im.width;
    if (thisDarkness>threshold) endY=y;
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
  String folderUrl = dataPath("input");
  if (folderIndex != -1) folderUrl += "/" + folders[folderIndex];
  println("loading images from : "+folderUrl);
  String[] inputUrl = getAllFilesFrom(folderUrl);
  for (int i=0; i<inputUrl.length; i++) {
    try {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println("loading file : "+inputUrl[i]);
        String fileName = fileName(inputUrl[i]);
        if (new File(dataPath("processed/"+"p_"+fileName)).exists() && cutPictures) {
          try {
            PImage cutted = loadImage(dataPath("processed/"+"p_"+fileName));
            synchronized (images) {
              images.add(cutted);
            }
          }
          catch(Exception e) {
            println(e);
          }
          if (invertPics) {
            try {
              PImage inverted = loadImage(dataPath("processed/"+"p_i_"+fileName));
              synchronized (images) {
                invertedImages.add(inverted);
              }
            }
            catch(Exception e) {
              println(e);
            }
          }
        } else {
          PImage cutted = loadImage(inputUrl[i]);
          if (cutPictures) cutted = cutShape(cutted);
          float reducedRatio = min(300.0f/(float)cutted.width, 300.0f/(float)cutted.height);
          if (fixedRatio!=-1) reducedRatio = fixedRatio;
          cutted.resize(floor(cutted.width*reducedRatio), floor(cutted.height*reducedRatio));
          cutted.save(dataPath("processed/"+"p_"+fileName));
          synchronized (images) {
            images.add(cutted);
          }
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
        doneUrls.add(inputUrl[i]);
      }
    }
    catch (Exception e) {
      println(e);
    }
  }
  makeMultipliableImages();
  changePattern();
}

void makeMultipliableImages() {
  synchronized (images) {
    for (PImage img : images) {
      PImage img2 = img.get();
      multipliableImages.add(img2);
      img2.loadPixels();
      for (int i = 0; i < img2.pixels.length; i++) {
        color c = img2.pixels[i];
        if (alpha(c) == 0) { // Check if the pixel is fully transparent
          img2.pixels[i] = color(255, 255, 255, 255); // Set it to opaque white
        }
      }
      img2.updatePixels();
    }
  }
}

void changePattern() {
  synchronized (images) {
    if ((mode==0||mode==4) && images.size()==0) return;
    if ((mode==1||mode==3) && multipliableImages.size()==0) return;
    if ((mode==2) && invertedImages.size()==0) return;
    nbShapes = floor(random(4, 16));// 4, 8
    selectedIms = new PImage[nbShapes];
    selectedLengths = new float[nbShapes];
    selectedSpeedMult = new float[nbShapes];
    nbDivisions = new int[nbShapes];
    for (int i=0; i<nbShapes; i++) {
      if (mode==0||mode==4) selectedIms[i] = images.get(floor(random(images.size())));
      if (mode==1||mode==3) selectedIms[i] = multipliableImages.get(floor(random(multipliableImages.size())));
      if (mode==2) selectedIms[i] = invertedImages.get(floor(random(invertedImages.size())));
      selectedLengths[i] = random(dist(0, 0, width, height)/3.0f);
      nbDivisions[i] = floor(random(2, 16));
      if (random(1)<0.2) nbDivisions[i] = floor((random(2, 30*map(selectedLengths[i], 0, 700, 1, 5)))*random(0.1, 10.0));
      selectedSpeedMult[i] = map(selectedLengths[i], 0, dist(0, 0, width, height)/3.0f, 1.3, 0.3);
      bgColor = palette[floor(random(palette.length))];
      if (evenlySpaced) {
        nbDivisions[i] = floor((selectedLengths[i]*TWO_PI)/max(selectedIms[i].width, selectedIms[i].height));
      }
    }
    loadedOnce = true;
  }
  //POP
  /*
  if (images.size()>0 && random(1)<0.5) {
   pop = 2;
   popRotate = random(TWO_PI);
   poppingIm = images.get(floor(random(images.size())));
   }
   */
}

class Sparkle {
  PVector pos = new PVector(random(width), random(height));
  float size = 1.0;
  float sD = random(1, 2);
  void draw() {
    size+=sD;
    if (size>=50) sD*=-1;
    imageMode(CENTER);
    image(sparkle, pos.x, pos.y, size, size);
  }
}
