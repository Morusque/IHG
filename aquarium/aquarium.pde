
import java.util.ArrayDeque;
import java.util.HashSet;

HashSet<String> doneUrls = new HashSet<String>();
ArrayList<Anim> anims = new ArrayList<Anim>();

int currentAnim = 0;

color bgColor = color(0x90, 0xF0, 0xB0);

final int DISPLAY_MODE_DURATION = 100;
DisplayMode[] displayModes;
int currentDisplayModeIndex = 0;
DisplayMode currentDisplayMode;

LayoutType layoutType = LayoutType.MILLE_FORMES;

boolean exportFramesForAnim = false;

float generateGamma = 0.82;
float generateMinRadius = 65;
float generateCalibrationHalfSize = 210;
float generateRadiusMargin = 16;
float generateDistinctnessThreshold = 12;
int generateMaxDistinctnessAttempts = 40;

PImage[] corner = new PImage[4];
float borderMargins = 130;
PImage hubble;

void setup() {
  // size(1485, 1050);
  fullScreen(2);
  frameRate(13);
  corner[0] = loadImage(dataPath("files/corner01.png"));
  corner[1] = loadImage(dataPath("files/corner02.png"));
  corner[2] = loadImage(dataPath("files/corner03.png"));
  corner[3] = loadImage(dataPath("files/corner04.png"));
  hubble = loadImage(dataPath("files/hubble01.png"));
  background(bgColor);
  initDisplayModes();
  thread("loadImages");
}

void draw() {
  if (anims.size()>0) {
    if (currentDisplayMode.isDone()) goToNextDisplayMode();
    currentDisplayMode.drawFrame();
  }
  if (exportFramesForAnim) saveFrame(dataPath("result/####.png"));
  // borders
  noStroke();
  fill(0);
  rect(0, 0, borderMargins, height);
  rect(width-borderMargins, 0, borderMargins, height);
  rect(0, 0, width, borderMargins);
  rect(0, height-borderMargins, width, borderMargins);
  imageMode(CORNER);
  image(corner[0], borderMargins, borderMargins);
  image(corner[1], width-corner[1].width-borderMargins, borderMargins);
  image(corner[2], borderMargins, height-corner[2].height-borderMargins);
  image(corner[3], width-corner[3].width-borderMargins, height-corner[2].height-borderMargins);
  // image(hubble, 0, 0);
}

void initDisplayModes() {
  displayModes = new DisplayMode[] {
    new PassingMode(),
    new CircleMode(),
    new GridMode(),
    new SpiralMode(),
    new StairsMode(),
    new SingleBounceMode(),
    new SymmetryMode(),
    new EdgeTravelMode(),
    new RainMode(),
    new BackForthMode(),
    new RotateMode(),
    new FullMode()
  };
  currentDisplayModeIndex = 0;
  currentDisplayMode = displayModes[currentDisplayModeIndex];
  currentDisplayMode.enter();
}

void goToNextDisplayMode() {
  currentAnim = (currentAnim+1)%anims.size();
  bgColor = color(0x90+random(-20, 20), 0xF0+random(-20, 20), 0xB0+random(-20, 15));
  if (random(100)<5) bgColor = color(random(0x80,0xFF),random(0x80,0xFF),random(0x80,0xFF));
  currentDisplayModeIndex = (currentDisplayModeIndex+1)%displayModes.length;
  currentDisplayMode = displayModes[currentDisplayModeIndex];
  currentDisplayMode.enter();
  println("enter mode "+currentDisplayMode.getClass());
}

int wrapIndex(int value, int size) {
  if (size<=0) {
    return 0;
  }
  return (value%size+size)%size;
}

int pingPongIndex(int value, int size) {
  if (size<=1) {
    return 0;
  }
  int cycle = (size-1)*2;
  int wrapped = wrapIndex(value, cycle);
  if (wrapped>=size) {
    return cycle-wrapped;
  }
  return wrapped;
}

int randomAnimIndex() {
  return floor(random(anims.size()));
}

int relatedAnimIndex(int step) {
  int variantCount = max(1, min(anims.size(), 3));
  return wrapIndex(currentAnim+wrapIndex(step, variantCount), anims.size());
}

PImage getAnimFrame(int animIndex, int frameIndex) {
  Anim anim = anims.get(wrapIndex(animIndex, anims.size()));
  return anim.images[wrapIndex(frameIndex, anim.images.length)];
}

void drawAnimFrame(int animIndex, int frameIndex, float x, float y, float scaleValue, float rotation, boolean flipHorizontal, boolean flipVertical) {
  PImage im = getAnimFrame(animIndex, frameIndex);
  pushMatrix();
  translate(x, y);
  rotate(rotation);
  scale((flipHorizontal ? -1 : 1)*scaleValue, (flipVertical ? -1 : 1)*scaleValue);
  image(im, 0, 0);
  popMatrix();
}

float perimeterLength(float margin) {
  float usableWidth = max(1, width-margin*2);
  float usableHeight = max(1, height-margin*2);
  return 2*(usableWidth+usableHeight);
}

PVector perimeterPosition(float distance, float margin) {
  float usableWidth = max(1, width-margin*2);
  float usableHeight = max(1, height-margin*2);
  float loop = perimeterLength(margin);
  float wrapped = (distance%loop+loop)%loop;
  if (wrapped<usableWidth) {
    return new PVector(margin+wrapped, margin);
  }
  wrapped -= usableWidth;
  if (wrapped<usableHeight) {
    return new PVector(width-margin, margin+wrapped);
  }
  wrapped -= usableHeight;
  if (wrapped<usableWidth) {
    return new PVector(width-margin-wrapped, height-margin);
  }
  wrapped -= usableWidth;
  return new PVector(margin, height-margin-wrapped);
}

float perimeterDirection(float distance, float margin) {
  float usableWidth = max(1, width-margin*2);
  float usableHeight = max(1, height-margin*2);
  float loop = perimeterLength(margin);
  float wrapped = (distance%loop+loop)%loop;
  if (wrapped<usableWidth) {
    return 0;
  }
  wrapped -= usableWidth;
  if (wrapped<usableHeight) {
    return HALF_PI;
  }
  wrapped -= usableHeight;
  if (wrapped<usableWidth) {
    return PI;
  }
  return HALF_PI*3;
}

float generateMaxRadius() {
  return max(1, generateCalibrationHalfSize-generateRadiusMargin);
}

float averageLengthDifference(float[] shapeA, float[] shapeB) {
  float total = 0;
  for (int i=0; i<shapeA.length; i++) {
    total += abs(shapeA[i]-shapeB[i]);
  }
  return total/max(1, shapeA.length);
}

boolean shapesAreDistinctEnough(float[][] lengths) {
  for (int a=0; a<lengths.length; a++) {
    for (int b=a+1; b<lengths.length; b++) {
      if (averageLengthDifference(lengths[a], lengths[b])<generateDistinctnessThreshold) {
        return false;
      }
    }
  }
  return true;
}

enum LayoutType {
  PAPER_01,
    NUMERIC_01,
    WEIRDLY_PRINTED,
    BOUSCULADE,
    MILLE_FORMES
}

class LayoutConfig {
  int nbX;
  int nbY;
  int startX;
  int startY;
  int sizeX;
  int sizeY;
  int spaceX;
  int spaceY;

  LayoutConfig(int nbX, int nbY, int startX, int startY, int sizeX, int sizeY, int spaceX, int spaceY) {
    this.nbX = nbX;
    this.nbY = nbY;
    this.startX = startX;
    this.startY = startY;
    this.sizeX = sizeX;
    this.sizeY = sizeY;
    this.spaceX = spaceX;
    this.spaceY = spaceY;
  }

  int frameCount() {
    return nbX*nbY;
  }
}

LayoutConfig getLayoutConfig(LayoutType type) {// int nbX, int nbY, int startX, int startY, int sizeX, int sizeY, int spaceX, int spaceY
  if (type==LayoutType.BOUSCULADE) {
    return new LayoutConfig(4, 3, 65, 32, 520, 520, 525, 525);
  }
  if (type==LayoutType.WEIRDLY_PRINTED) {
    return new LayoutConfig(3, 2, 189, 167, 569, 569, 703, 745);
  }
  if (type==LayoutType.NUMERIC_01) {
    return new LayoutConfig(3, 2, 47, 62, 401, 401, 495, 525);
  }
  if (type==LayoutType.MILLE_FORMES) {
    //return new LayoutConfig(3, 2, 95, 111, 639, 632, 753, 790);
    return new LayoutConfig(3, 2, 53, 81, 661, 661, 778, 826);
  }
  return new LayoutConfig(3, 2, 109, 125, 615, 615, 761, 803);
}

String processedFramePath(String fileName, int frameNb) {
  return dataPath("processed/"+"p_"+fileName+"_"+nf(frameNb, 2)+".png");
}

boolean hasProcessedFrames(String fileName, LayoutConfig layout) {
  for (int i=0; i<layout.frameCount(); i++) {
    if (!new File(processedFramePath(fileName, i)).exists()) {
      return false;
    }
  }
  return true;
}

void exportSingles() {
  for (int i=0; i<anims.size(); i++) {
    color bgColor = color(random(0x100), random(0x100), random(0x100));
    for (int j=0; j<anims.get(i).images.length; j++) {
      PGraphics gr = createGraphics(500, 500);
      gr.beginDraw();
      gr.imageMode(CENTER);
      gr.background(bgColor);
      gr.image(anims.get(i).images[j], gr.width/2, gr.height/2, anims.get(i).images[j].width*0.8, anims.get(i).images[j].height*0.8);
      gr.endDraw();
      gr.save(dataPath("result/singles/"+nf(i, 5)+"_"+nf(j, 2)+".png"));
    }
  }
}

void generate() {
  println("export...");
  PGraphics export = createGraphics(1485, 1050);
  export.beginDraw();
  int nbPoints = 1000;
  nbPoints = floor(3+random(random(2000)));
  LayoutConfig layout = getLayoutConfig(layoutType);
  int nbX = layout.nbX;
  int nbY = layout.nbY;
  int nbFrames = nbX*nbY;
  float[][] lengths = new float[nbFrames][nbPoints];
  float maxRadius = generateMaxRadius();
  if (generateMinRadius>=maxRadius) {
    println("invalid generate radius settings");
    export.endDraw();
    return;
  }
  boolean distinctEnough = false;
  for (int attempt=0; attempt<generateMaxDistinctnessAttempts && !distinctEnough; attempt++) {
    Oscillator[] oscs = new Oscillator[20];
    for (int i=0; i<oscs.length; i++) {
      oscs[i] = new Oscillator();
    }
    float minLength = -1;
    float maxLength = -1;
    for (int f=0; f<nbFrames; f++) {
      for (int i=0; i<nbPoints; i++) {
        float value = 100;
        for (int j=0; j<oscs.length; j++) value += oscs[j].value(((float)i/nbPoints), ((float)f/nbFrames))*50;
        lengths[f][i] = value;
        if (minLength==-1||minLength>value) minLength = value;
        if (maxLength==-1||maxLength<value) maxLength = value;
      }
    }
    for (int f=0; f<nbFrames; f++) {
      for (int i=0; i<nbPoints; i++) {
        float normalizedLength = 0.5;
        if (minLength!=maxLength) {
          normalizedLength = constrain(map(lengths[f][i], minLength, maxLength, 0, 1), 0, 1);
        }
        normalizedLength = pow(normalizedLength, generateGamma);
        lengths[f][i] = map(normalizedLength, 0, 1, generateMinRadius, maxRadius);
      }
    }
    distinctEnough = shapesAreDistinctEnough(lengths);
  }
  if (!distinctEnough) {
    println("warning: generate() kept the best available frame set after retry limit");
  }
  export.background(0xFF);
  export.noFill();
  export.stroke(0);
  int frameNb = 0;

  boolean exportCalibration = false;
  boolean exportOrthoMode = false;

  if (!exportOrthoMode) {
    for (int y=0; y<nbY; y++) {
      for (int x=0; x<nbX; x++) {
        PVector middle = new PVector((float)export.width*(x+0.5)/nbX, (float)export.height*(y+0.5)/nbY);
        for (int i=0; i<nbPoints; i++) {
          float a = (float)i/nbPoints*TWO_PI;
          float a2 = ((float)(i+1)%nbPoints)/nbPoints*TWO_PI;
          export.strokeWeight(13);
          export.line(middle.x+cos(a)*lengths[frameNb][i], middle.y+sin(a)*lengths[frameNb][i], middle.x+cos(a2)*lengths[frameNb][(i+1)%nbPoints], middle.y+sin(a2)*lengths[frameNb][(i+1)%nbPoints]);
        }
        if (exportCalibration) {
          export.strokeWeight(1);
          export.rect(middle.x-generateCalibrationHalfSize, middle.y-generateCalibrationHalfSize, generateCalibrationHalfSize*2, generateCalibrationHalfSize*2); // for calibration
        }
        frameNb++;
      }
    }
  } else {
    for (int y=0; y<nbY; y++) {
      for (int x=0; x<nbX; x++) {
        PVector middle = new PVector((float)export.width*(x+0.5)/nbX, (float)export.height*(y+0.5)/nbY);
        for (int i=0; i<nbPoints; i++) {
          float a = (float)i/nbPoints*TWO_PI;
          float a2 = ((float)(i+1)%nbPoints)/nbPoints*TWO_PI;
          export.strokeWeight(13);
          export.line(middle.x+cos(a)*lengths[frameNb][i], middle.y+sin(a)*lengths[frameNb][i], middle.x+cos(a2)*lengths[frameNb][(i+1)%nbPoints], middle.y+sin(a)*lengths[frameNb][i]);
          export.line(middle.x+cos(a2)*lengths[frameNb][(i+1)%nbPoints], middle.y+sin(a)*lengths[frameNb][i], middle.x+cos(a2)*lengths[frameNb][(i+1)%nbPoints], middle.y+sin(a2)*lengths[frameNb][(i+1)%nbPoints]);
        }
        if (exportCalibration) {
          export.strokeWeight(1);
          export.rect(middle.x-generateCalibrationHalfSize, middle.y-generateCalibrationHalfSize, generateCalibrationHalfSize*2, generateCalibrationHalfSize*2); // for calibration
        }
        frameNb++;
      }
    }
  }

  export.textSize(25);
  export.fill(0);
  export.text("H", 7, 30);
  export.text("B", export.width-20, export.height-10);
  export.endDraw();
  export.save(dataPath("exports/img_"+nf(nbExported++, 4)+".tiff"));
  println("done");
}

class Oscillator {
  float fr;
  float ph;
  float am;
  float bi;
  float sp;
  float mp;
  float ma;
  Oscillator() {
    fr = floor(random(1, random(1, 8)));
    ph = random(TWO_PI);
    am = random(0, 1);
    bi = 0;
    sp = round(random(-1, 1));
    mp = random(TWO_PI);
    ma = random(-1, 1);
  }
  float value(float t, float p) {
    return sin(((t)*TWO_PI+ph)*fr)*(am*map(sin(p*TWO_PI*sp+mp), -1, 1, 1, ma)+bi);
  }
}

int nbExported = 0;
void keyPressed() {
  if (key == 'e') {
    for (int i=0; i<1; i++) generate();
  }
  if (keyCode == CONTROL) {
    thread("loadImages");
    // loadImages();
  }
  if (keyCode == RIGHT) {
    currentDisplayMode.forceComplete();
  }
  if (key == 'g') {// cycles through display modes
    LayoutType[] layoutTypes = LayoutType.values();
    layoutType = layoutTypes[(layoutType.ordinal()+1)%layoutTypes.length];
    println("layout type : "+layoutType);
  }
  if (key == 's') {
    exportSingles();
  }
}

void loadImages() {
  println("loading...");
  String[] inputUrl = getAllFilesFrom(dataPath("input"));
  LayoutConfig layout = getLayoutConfig(layoutType);
  for (int i=0; i<inputUrl.length; i++) {
    if (!doneUrls.contains(inputUrl[i])) {
      println("file : "+inputUrl[i]);
      try {
        String fileName = inputUrl[i].substring(dataPath("input").length()+1, inputUrl[i].length()-4);
        if (hasProcessedFrames(fileName, layout)) {
          Anim anim = new Anim(layout.frameCount());
          for (int j=0; j < anim.images.length; j++) {
            anim.images[j] = loadImage(processedFramePath(fileName, j));
          }
          anims.add(anim);
        } else {
          PImage im = loadImage(inputUrl[i]);
          Anim anim = new Anim(layout.frameCount());
          int frameNb = 0;
          for (int y=0; y<layout.nbY; y++) {
            for (int x=0; x<layout.nbX; x++) {
              PImage cutted = cutShape(im.get(layout.startX+layout.spaceX*x, layout.startY+layout.spaceY*y, layout.sizeX, layout.sizeY));
              anim.images[frameNb] = cutted;
              cutted.save(processedFramePath(fileName, frameNb));
              frameNb++;
            }
          }
          anims.add(anim);
        }
        doneUrls.add(inputUrl[i]);
      }
      catch (Exception e) {
        println(e);
      }
    }
  }
  println("...done");
}

PImage cutShape(PImage oIm) {
  PImage im = oIm.get();
  // crop borders
  int margin = min(2, max(0, min(im.width, im.height)/2-1));
  if (margin>0) {
    im = im.get(margin, margin, im.width-margin*2, im.height-margin*2);
  }
  // crop shape
  int startX = 0;
  int startY = 0;
  int endX = im.width;
  int endY = im.height;
  float threshold = 5;
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
  startX-=1;
  startY-=1;
  endX+=1;
  endY+=1;
  // im = im.get(startX, startY, endX-startX, endY-startY);
  // add white margin
  PImage largerIm = createImage(im.width+2, im.height+2, RGB);
  largerIm.loadPixels();
  for (int i = 0; i < largerIm.pixels.length; i++) largerIm.pixels[i] = color(0xFF);
  largerIm.updatePixels();
  largerIm.copy(im, 0, 0, im.width, im.height, 1, 1, im.width, im.height);
  im = largerIm;
  // expand cutted zone
  float emptyThreshold = 35;
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
  ArrayDeque<Integer> toCheck = new ArrayDeque<Integer>();
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
    int thisIndex = toCheck.removeFirst();
    if (empty[thisIndex]) {
      toErase[thisIndex] = true;
      int x = thisIndex%im.width;
      int y = thisIndex/im.width;
      enqueueIfNeeded(x-1, y, im.width, im.height, toCheck, done);
      enqueueIfNeeded(x+1, y, im.width, im.height, toCheck, done);
      enqueueIfNeeded(x, y-1, im.width, im.height, toCheck, done);
      enqueueIfNeeded(x, y+1, im.width, im.height, toCheck, done);
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
          int neighborX = x+x2;
          int neighborY = y+y2;
          if (neighborX>=0 && neighborX<im.width && neighborY>=0 && neighborY<im.height && toErase[neighborX+neighborY*im.width]) {
            mask.stroke(0);
          }
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

class Anim {
  PImage[] images;

  Anim(int nbImages) {
    images = new PImage[nbImages];
  }
}

void enqueueIfNeeded(int x, int y, int width, int height, ArrayDeque<Integer> toCheck, boolean[] done) {
  if (x<0 || x>=width || y<0 || y>=height) {
    return;
  }
  int index = x+y*width;
  if (!done[index]) {
    toCheck.addLast(index);
    done[index] = true;
  }
}
