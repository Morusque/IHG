
ArrayList<String> doneUrls = new ArrayList<String>();
ArrayList<PImage> splashes = new ArrayList<PImage>();
ArrayList<PImage> ribbons = new ArrayList<PImage>();

int mode = 0;
// 0 = ribbon
// 1 = splash

float phasor = 0;

float frequency = 7.5f;

PImage currentRibbon = null;
PImage currentSplash = null;

int frameCount2 = 0;
int targetFrameRate = 50;

void setup() {
  size(1000, 800);
  frameRate(targetFrameRate);
}

void draw() {
  phasor = (((float)frameCount2++)/(targetFrameRate*frequency))%1.0f;
  if (splashes.size()>0 && ribbons.size()>0) {
    if (mode==0) if (random(100)<1) switchMode();
    if (mode==1) if (random(100)<5) switchMode();
    // draw
    if (mode==0) {
      int currentPosition = floor(phasor*currentRibbon.width);
      copy(currentRibbon, currentPosition, 0, 1, currentRibbon.height, 0, 0, width, height);
    }
    if (mode==1) {
      image(currentSplash, 0, 0, width, height);
    }
  } else {
    background(0);
  }
}

void keyPressed() {
  if (keyCode == CONTROL) {
    println("loading...");
    String[] inputUrl = getAllFilesFrom(dataPath("input"));
    for (int i=0; i<inputUrl.length; i++) {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println("file : "+inputUrl[i]);
        PImage im = loadImage(inputUrl[i]);
        ribbons.add(im.get(109, 170, 532, 10));
        splashes.add(im.get(100, 347, 198, 189));
        splashes.add(im.get(397, 344, 207, 196));
        doneUrls.add(inputUrl[i]);
      }
    }
    println("...done");
    choosePics();
  }
}

void switchMode() {
  mode=(mode+1)%2;
  choosePics();
}

void choosePics() {
  currentSplash = splashes.get(floor(random(splashes.size())));
  currentRibbon = ribbons.get(floor(random(ribbons.size())));
}
