
PImage merged;
PImage nextMerged;
ArrayList<String> doneUrls = new ArrayList<String>();

PImage rejectedPic;

float mergingProgress = 1;

float speed = 0.25f;//0.005f;

float[] currentScore = new float[2];

boolean allowNewInput = false;

int exported = 0;

PImage dangerPic;

int nbAccepted = 0;
int nbRejected = 0;

PImage lastRejected;

int displayRejected=0;

boolean showWinner = false;

PVector nonPosition = new PVector(0, 0);

ArrayList<PVector> wrongPixels = new ArrayList<PVector>();

boolean scheduleLoading = false;

void setup() {
  // size(1415, 1000);
  fullScreen(2);

  merged = nextMerged = rejectedPic = whitePic();
  noStroke();

  // textFont(loadFont(dataPath("files/font/OCRAExtended-70.vlw")));
  textFont(loadFont(dataPath("files/font/OCRAExtended-150.vlw")));

  PGraphics tmpDangerPic = createGraphics(width, height, JAVA2D);
  tmpDangerPic.beginDraw();
  tmpDangerPic.strokeWeight(50);
  tmpDangerPic.stroke(0xFF, 0, 0);
  tmpDangerPic.noFill();
  tmpDangerPic.image(loadImage(dataPath("files/danger/field.png")), 0, 0, tmpDangerPic.width, tmpDangerPic.height);
  tmpDangerPic.endDraw();
  dangerPic = tmpDangerPic.get();

  currentScore[0] = 0;
  currentScore[1] = 0;

  //frame.toFront();
  //frame.requestFocus();
}

void draw() {

  blendMode(NORMAL);

  if (scheduleLoading) loadPics();
  scheduleLoading = false;

  if (mergingProgress>=1) {
    mergingProgress=1;
    if (allowNewInput && displayRejected==0) scheduleLoading = true;
  }

  background(0xFF);
  tint(0xFF, 0xFF);
  image(merged, 0, 0, width, height);
  tint(0xFF, constrain(mergingProgress*0xFF, 0, 0xFF));
  image(nextMerged, 0, 0, width, height);
  if (mergingProgress==0) save(dataPath("result/"+nf(exported++, 4)+".png"));

  mergingProgress=min(mergingProgress+speed, 1);

  boolean rejectedDisplayed = false;
  if (displayRejected>0) {
    rejectedDisplayed=true;
    tint(0xFF);
    image(lastRejected, 0, 0, width, height);
    displayRejected--;
    if (displayRejected==0) lastRejected=null;
  }

  blendMode(MULTIPLY);

  tint(0xFF);
  image(dangerPic, 0, 0);

  if (!rejectedDisplayed) {
    blendMode(NORMAL);
    fill(0);
    textSize(70);
    textAlign(CENTER);
    // text(nbAccepted+" / "+doneUrls.size(), width/2, 70);
    text(int(currentScore[0])+"%", width*1/7, 100);
    text(int(currentScore[1])+"%", width*6/7, 100);
  } else {
    blendMode(NORMAL);
    stroke(0xE0);
    if (frameCount%2==0) for (PVector p : wrongPixels) point(p.x, p.y);
    fill(0xFF, 0, 0);
    if (frameCount%3==0) fill(0);
    textSize(150+sin((float)frameCount/2)*10);
    textAlign(CENTER);
    text("NON", nonPosition.x, nonPosition.y);
  }

  blendMode(NORMAL);
  fill(0);
  textSize(48);
  textAlign(LEFT, CENTER);
  text("approved drawings : "+nf(nbAccepted, 3), 143+38, height-60);
  textAlign(RIGHT, CENTER);
  text("rejected drawings : "+nf(nbRejected, 3), width-143-37, height-60);
  /*
  text("dessins acceptés : "+nf(nbAccepted, 3), width*1/4, height-60);
   text("dessins rejetés : "+nf(nbRejected, 3), width*3/4, height-60);
   */

  if (showWinner) {
    fill(0xFF);
    if (currentScore[0]>currentScore[1]) {
      textSize(150);
      text("WINNER", width*2/7, height/2);
      textSize(100);
      text("loser", width*5/7, height/2);
    }
    if (currentScore[0]<currentScore[1]) {
      textSize(100);
      text("loser", width*2/7, height/2);
      textSize(150);
      text("WINNER", width*5/7, height/2);
    }
    if (currentScore[0]==currentScore[1]) {
      textSize(150);
      text("EXAEQUO", width*1/2, height/2);
    }
  }
}

void loadPics() {
  String[] inputUrl = getAllFilesFrom(dataPath("input"));
  if (inputUrl.length<doneUrls.size()) {
    println("restart merge");
    merged = nextMerged = whitePic();
    doneUrls.clear();
  }
  PImage nextIm = whitePic();
  boolean found = false;
  for (int i=0; i<inputUrl.length && !found; i++) {
    if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
      try {
        println("load : "+inputUrl[i]);
        nextIm = loadImage(inputUrl[i]);
        nextIm.resize(width, height);
        doneUrls.add(inputUrl[i]);
        found=true;
      } 
      catch (Exception e) {
        println(e);
      }
    }
  }
  if (found) {
    boolean accepted = true;
    int wrongs = 0;
    float wrongScore = 0;
    wrongPixels.clear();
    for (int x=50; x<nextIm.width-100; x++) {
      for (int y=50; y<nextIm.height-100; y++) {
        if (dangerPic.get(x, y)==color(0xcc, 0x07, 0x1e)) {
          float thisBrightness = brightness(nextIm.get(x, y));
          // if (brightness(nextIm.get(x, y))<0xF0) {
          if (thisBrightness<0xFF) {
            wrongs++;
            PVector thisPosition = new PVector(x, y);
            wrongPixels.add(thisPosition);
            nonPosition = PVector.lerp(nonPosition, thisPosition, 1.0f/wrongs);
            wrongScore+=0xFF-thisBrightness;
            // if (wrongs>3) accepted = false;
            if (wrongScore>1000) {
              accepted = false;
              // println(wrongScore);
            }
          }
        }
      }
    }
    nonPosition.x=constrain(nonPosition.x, 150, width-150);
    nonPosition.y=constrain(nonPosition.y, 150, height-150);
    if (accepted) {
      merged = nextMerged.get();
      PGraphics mergedG = createGraphics(width, height, JAVA2D);
      mergedG.beginDraw();
      mergedG.image(merged, 0, 0, width, height);
      mergedG.blend(nextIm, 0, 0, nextIm.width, nextIm.height, 0, 0, width, height, MULTIPLY);
      mergedG.endDraw();
      nextMerged = mergedG.get();
      nextMerged.loadPixels();
      currentScore[0]=0;
      currentScore[1]=0;
      long[] pixelsLength = new long[2];
      for (int x=0; x<nextMerged.width; x++) {
        for (int y=0; y<nextMerged.height; y++) {
          if (dangerPic.get(x, y)!=color(0xcc, 0x07, 0x1e)) {          
            color c = nextMerged.pixels[x+y*nextMerged.width];
            if (x<(float)nextMerged.width/2) {
              currentScore[0] += (float)(0x100-brightness(c))/0x100;
              pixelsLength[0]++;
            } else {
              currentScore[1] += (float)(0x100-brightness(c))/0x100;
              pixelsLength[1]++;
            }
          }
        }
      }
      currentScore[0] *= 100.0/pixelsLength[0];
      currentScore[1] *= 100.0/pixelsLength[1];
      mergingProgress=0;
      nbAccepted++;
    } else {
      lastRejected = nextIm;
      PGraphics mergedG = createGraphics(width, height, JAVA2D);
      mergedG.beginDraw();
      mergedG.image(rejectedPic, 0, 0, width, height);
      mergedG.blend(nextIm, 0, 0, nextIm.width, nextIm.height, 0, 0, width, height, MULTIPLY);
      mergedG.endDraw();
      rejectedPic = mergedG.get();
      nextIm.save(dataPath("rejected/"+nf(nbRejected, 4)+".png"));
      rejectedPic.save(dataPath("rejected/total.png"));
      nbRejected++;
      displayRejected=10;
    }
  } else {
    println("loading done, disabling input");
    allowNewInput=false;
  }
}

boolean inArray(String[] hs, String n) {
  for (String s : hs) {
    if (s.equals(n)) return true;
  }
  return false;
}

PImage whitePic() {
  PGraphics white = createGraphics(width, height, JAVA2D);
  white.beginDraw();
  white.background(0xFF);
  white.endDraw();
  return white.get();
}

void keyPressed() {
  if (keyCode==CONTROL) {
    allowNewInput^=true;
    println("allow input : "+allowNewInput);
  }
  if (keyCode=='W') {
    showWinner^=true;
  }
}
