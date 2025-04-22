
import java.util.Collections;

// Marsu
int nbX = 4;
int nbY = 5;

/*
// Brueghel
int nbX = 5;
int nbY = 4;
*/

PVector partSizes;

ArrayList<Part> parts = new ArrayList<Part>();

PImage original;

int nbSaved=0;

boolean displayOriginal = false;
boolean displayGrid = false;

ArrayList<String> doneUrls = new ArrayList<String>();

boolean displayShuffle = true;

void setup() {
  original = loadImage(dataPath("files/original.png"));
  // original = loadImage(dataPath("files/Brueghel01.png"));
  original = original.get(69, 62, 1563-69, 2284-62); // Marsu
  // size(1200, 800);// Brueghel
  size(827, 1170);// Marsu
  frameRate(5);
  surface.setResizable(true);
}

void draw() {
  // update
  partSizes = new PVector((float)width/(float)nbX, (float)height/(float)nbY);
  if (frameCount%70==1&&displayShuffle) {
    Collections.shuffle(parts);
  }
  // draw
  background(0xFF);
  if (displayOriginal) image(original, 0, 0, width, height);
  if (displayShuffle) {
    for (int i=0; i<parts.size(); i++) {
      image(parts.get(i).im, parts.get(i).pX*partSizes.x, parts.get(i).pY*partSizes.y, partSizes.x, partSizes.y);
    }
  }
  if (displayGrid) {
    for (int x=0; x<nbX; x++) {
      for (int y=0; y<nbY; y++) {
        noFill();
        stroke(0xFF);
        strokeWeight(5);
        rect(x*partSizes.x, y*partSizes.y, partSizes.x, partSizes.y);
      }
    }
  }
}

class Part {
  PImage im;
  int pX;
  int pY;
  Part(PImage sourceIm) {
    sourceIm = sourceIm.get(50, 86, 2283-50, 1577-86); // Marsu
    // sourceIm = sourceIm.get(80, 60, 2130-80, 1545-60);// Brueghel

    // Marsu
    PGraphics sourceImRotated = createGraphics(sourceIm.height,sourceIm.width);
    sourceImRotated.beginDraw();
    sourceImRotated.translate(sourceIm.height,0);
    sourceImRotated.rotate(HALF_PI);
    sourceImRotated.image(sourceIm,0,0);
    sourceImRotated.endDraw();
    sourceIm = sourceImRotated.get();
    
    float partXSize = (float)sourceIm.width/nbX;
    float partYSize = (float)sourceIm.height/nbY;
    float bestScore = 0;
    for (int x=0; x<nbX; x++) {
      for (int y=0; y<nbY; y++) {
        PImage thisPart = sourceIm.get(floor(x*partXSize), floor(y*partYSize), floor(partXSize), floor(partYSize));
        float thisScore = levelOfDarknes(thisPart);
        if (thisScore>=bestScore) {
          bestScore=thisScore;
          pX=x;
          pY=y;
        }
      }
    }
    im = sourceIm.get(floor(pX*partXSize), floor(pY*partYSize), floor(partXSize), floor(partYSize));
  }
}

float levelOfDarknes(PImage thisPart) {
  float score = 0;
  for (int x=0; x<thisPart.width; x++) {
    for (int y=0; y<thisPart.height; y++) {
      color c = thisPart.get(x, y);
      score += (0xFF-red(c))+(0xFF-green(c))+(0xFF-blue(c));
    }
  }
  return score;
}

boolean inArray(String[] hs, String n) {
  for (String s : hs) {
    if (s.equals(n)) return true;
  }
  return false;
}

void keyPressed() {
  if (keyCode==CONTROL) {
    println("loading...");
    String[] files = getAllFilesFrom(dataPath("input"));
    for (String f : files) {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), f)) {
        parts.add(new Part(loadImage(f)));
        doneUrls.add(f);
      }
    }
    println("...done");
  }
  if (keyCode==TAB) {
    save(dataPath("results/"+nf(nbSaved++, 4)+".png"));
  }
  if (keyCode==82) {// r
    displayShuffle ^= true;
    println("displayShuffle : "+displayShuffle);
  }
  if (keyCode==79) {// o
    displayOriginal^=true;
  }
  if (keyCode==71) {// g
    displayGrid^=true;
  }
}
