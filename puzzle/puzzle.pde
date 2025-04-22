
PImage merged;
PImage nextMerged;
ArrayList<String> todoUrls = new ArrayList<String>();
ArrayList<String> doneUrls = new ArrayList<String>();

ArrayList<PImage> blinkingPics = new ArrayList<PImage>();

float mergingProgress = 1;

float speed = 1.0f/10;//0.005f;

int currentIndex = 0;
int finalFrames = 0;

int nbToSurimpose = 17;

int nbExported = 0;

int mode = 1;
// 0 = normal
// 1 = single

PVector imSize;
PVector imDisplayPos = new PVector();
PVector imDisplaySize = new PVector();

boolean manualAdd = false;

boolean scheduleLoading = false;

void setup() {
  // size(800, 1000);
  fullScreen(2);
  frameRate(30);
  textSize(48);
  noStroke();
  frame.toFront();
  frame.requestFocus();
}

void draw() {
  if (scheduleLoading) loadPics();
  scheduleLoading = false;
  background(0xFF);
  if (imSize==null) {
    String[] inputUrl = getAllFilesFrom(dataPath("input"));
    if (inputUrl.length>0) {
      PImage thisIm = loadImage(inputUrl[0]);
      if (imSize==null) {
        imSize = new PVector(thisIm.width, thisIm.height);
        if (imSize.x>width) {
          float ratio = width/imSize.x;
          imSize.x*=ratio;
          imSize.y*=ratio;
        }
        if (imSize.y>height) {
          float ratio = height/imSize.y;
          imSize.x*=ratio;
          imSize.y*=ratio;
        }
      }
      computeRatios();
    }
    merged = nextMerged = whitePic();
  } else {
    if (mode==0) {
      if (currentIndex>=todoUrls.size()) {
        finalFrames++;
        if (finalFrames>30 && !manualAdd) restart();
        tint(0xFF, 0xFF);
        image(merged, imDisplayPos.x, imDisplayPos.y, imDisplaySize.x, imDisplaySize.y);
      } else {
        mergingProgress=min(mergingProgress+speed, 1);
        if (mergingProgress>=1) {
          mergingProgress=1;
          if (!manualAdd) scheduleLoading = true;
        }
        tint(0xFF, 0xFF);
        image(merged, imDisplayPos.x, imDisplayPos.y, imDisplaySize.x, imDisplaySize.y);
        // tint(0xFF, constrain(mergingProgress*0xFF+abs(0.5f-mergingProgress)*(1-mergingProgress)*sin((float)frameCount)*0xA0, 0, 0xFF));
        tint(0xFF, constrain(pow(mergingProgress, 3)*0xFF, 0, 0xFF));
        image(nextMerged, imDisplayPos.x, imDisplayPos.y, imDisplaySize.x, imDisplaySize.y);
      }
    }
    if (mode==1) {
      if (frameCount%10==0) thread("pushpopLoad");
      if (blinkingPics.size()>0 && imSize!=null) {
        tint(0xFF);
        image(blinkingPics.get(currentIndex%blinkingPics.size()), imDisplayPos.x, imDisplayPos.y, imDisplaySize.x, imDisplaySize.y);
        if (frameCount%3==0) currentIndex=(currentIndex+1)%blinkingPics.size();
      }
    }
  }
}

void pushpopLoad() {
  if (blinkingPics.size()>=24) blinkingPics.remove(0);
  String[] inputUrl = getAllFilesFrom(dataPath("input"));
  if (inputUrl.length>0) {
    PImage thisIm = loadImage(inputUrl[floor(random(inputUrl.length))]);
    thisIm = processScan(thisIm);
    if (imSize==null) imSize = new PVector(thisIm.width, thisIm.height);
    computeRatios();
    blinkingPics.add(thisIm);
  }
}

void loadPics() {
  PImage nextIm = whitePic();
  try {
    println("load : "+todoUrls.get(currentIndex));
    nextIm = loadImage(todoUrls.get(currentIndex));
    nextIm = processScan(nextIm);
    if (imSize==null) imSize = new PVector(nextIm.width, nextIm.height);
    computeRatios();
    doneUrls.add(todoUrls.get(currentIndex));
  }
  catch (Exception e) {
    println(e);
  }
  merged = nextMerged.get();
  PGraphics mergedG = createGraphics(floor(imSize.x), floor(imSize.y), JAVA2D);
  mergedG.beginDraw();
  mergedG.image(merged, 0, 0, floor(imSize.x), floor(imSize.y));
  if (nextIm!=null) mergedG.blend(nextIm, 0, 0, nextIm.width, nextIm.height, 0, 0, floor(imSize.x), floor(imSize.y), DARKEST);
  mergedG.endDraw();
  nextMerged = mergedG.get();
  // nextMerged.loadPixels();
  mergingProgress=0;
  currentIndex++;
}

boolean inArray(String[] hs, String n) {
  for (String s : hs) {
    if (s.equals(n)) return true;
  }
  return false;
}

void restart() {
  println("restart merge");
  merged = nextMerged = whitePic();
  todoUrls.clear();  
  doneUrls.clear();
  currentIndex = 0;
  finalFrames = 0;
  String[] inputUrl = getAllFilesFrom(dataPath("input"));
  if (manualAdd) {
    for (int i=0; i<inputUrl.length; i++) todoUrls.add(inputUrl[i]);
    shuffle(todoUrls);
  } else {
    for (int i=0; i<nbToSurimpose; i++) todoUrls.add(inputUrl[floor(random(inputUrl.length))]);
  }
}

void shuffle(ArrayList a) {
  ArrayList b = new ArrayList();
  for (int i=0; i<a.size(); i++) b.add(a.get(i));
  while (b.size()>0) {
    a.add(b.remove(floor(random(b.size()))));
  }
}

PImage whitePic() {
  PGraphics white = createGraphics(width, height, JAVA2D);
  if (imSize!=null) white = createGraphics(floor(imSize.x), floor(imSize.y), JAVA2D);
  white.beginDraw();
  white.background(0xFF);
  white.endDraw();
  return white.get();
}

void keyPressed() {
  if (keyCode==TAB) {
    println("image saved");
    saveFrame(dataPath("results/result"+nf(nbExported++, 4)+".png"));
  }
  if (keyCode==RIGHT) {
    mode = (mode+1)%2;
    restart();
    println("current mode : "+mode);
  }
  if (keyCode=='M') {
    manualAdd ^= true;
    println("manual add : "+manualAdd);
  }
  if (keyCode=='L') {
    loadPics();
    println("number of pictures merged : "+currentIndex);
  }  
  if (keyCode=='R') {
    restart();
  }
  if (keyCode==UP) {
    nbToSurimpose++;
    println("number to surimpose : "+nbToSurimpose);
  }  
  if (keyCode==DOWN) {
    nbToSurimpose--;
    println("number to surimpose : "+nbToSurimpose);
  }
}


color average(final PImage img) {
  img.loadPixels();
  long r = 0, g = 0, b = 0;
  for (final color c : img.pixels) {
    r += c >> 020 & 0xFF;
    g += c >> 010 & 0xFF;
    b += c        & 0xFF;
  }
  r /= img.pixels.length;
  g /= img.pixels.length;
  b /= img.pixels.length;
  return color((int)r, (int)g, (int)b);
}

PImage processScan(PImage thisIm) {
  color findLogoA = average(thisIm.get(100, 100, 180, 130));
  color findLogoB = average(thisIm.get(1400, 2100, 180, 130));
  /*
  color findLogoA = average(thisIm.get(1113, 51, 150, 112));
   color findLogoB = average(thisIm.get(1073, 1498, 150, 112));
   */
  if (red(findLogoA)>red(findLogoB)) {
    PGraphics reversed = createGraphics(thisIm.width, thisIm.height, JAVA2D);
    reversed.beginDraw();
    reversed.translate((float)thisIm.width, (float)thisIm.height);
    reversed.rotate(PI);
    reversed.image(thisIm, 0, 0);
    reversed.endDraw();
    return reversed.get();
  }
  return thisIm;
}

void computeRatios() {
  float imRatio = imSize.x/imSize.y;
  float screenRatio = (float)width/(float)height;
  if (imRatio>screenRatio) {
    imDisplaySize.x = width;
    imDisplaySize.y = imSize.y*width/imSize.x;
    imDisplayPos.x = 0;
    imDisplayPos.y = (height-imDisplaySize.y)/2;
  } else {
    imDisplaySize.x = imSize.x*height/imSize.y;
    imDisplaySize.y = height;
    imDisplayPos.x = (width-imDisplaySize.x)/2;
    imDisplayPos.y = 0;
  }
}
