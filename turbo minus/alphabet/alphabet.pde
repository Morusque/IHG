
// (touches)  affiche la lettre
// BAS  reset sentence
// GAUCHE  next sentence
// BACKSPACE  dark bg
// ENTER  display next letter
// ^  background motif
// $  background uni
// ù  autotempo

ArrayList<Letter> letters = new ArrayList<Letter>();
ArrayList<Sprite> sprites = new ArrayList<Sprite>();

float jumpSpeed = 0.3;// arbitrary scale for the letter jump
float vanishMinimum = 300.0;// minimum default letter display time in ms (overriden by tempo and key presses)

color currentBackground = color(207, 57, 255);

int changeBackgroundOnceEvery = 2;
int changeBackgroundCounter = 0;

float[] xPosChain = new float[]{0.5};
int xPosChainCounter = 0;

boolean[] keys = new boolean[65536];

String[] sentences = new String[]{
  "abcdefghijklmnopqrstuvwxyz",
  "hello world"
};
int sentenceIndex = 0;
int sentenceCharIndex = 0;

color[] typicalColors = new color[]{
  color(0),
  color(255),
  color(255, 223, 230), // rose pâle
  color(207, 57, 255), // violet
  color(0, 255, 161), // vert
  color(255, 74, 45), // rouge
  color(0, 247, 255), // bleu
  color(255, 243, 110)  // jaune
};

boolean dark = false;

ArrayList<PImage> motifs = new ArrayList<PImage>();
PImage[] currentMotif = new PImage[2];

double defaultTempo = 107.2;// BPM
double autoTempo = defaultTempo;
double tempoBeats = 1;
double tempoCounter = 0;

float highestPic = 0;

void setup() {
  fullScreen(P2D);
  frameRate(60);
  thread("loadImages");
  thread("loadMotifs");
}

void draw() {
  if (autoTempo!=-1) {
    double tempoMs = 60000.0*tempoBeats/autoTempo;
    if (millis()-tempoCounter >= tempoMs) {
      displayOneLetter(sentences[sentenceIndex].charAt(sentenceCharIndex), -1, (float)tempoMs);
      sentenceCharIndex = (sentenceCharIndex + 1) % sentences[sentenceIndex].length();
      tempoCounter = millis();
    }
  }
  // delete sprites whose key isn't pressed anymore and has reached vanishing point
  for (int i = sprites.size()-1; i>=0; i--) {
    if (sprites.get(i).keyP!=-1) {
      if (!keys[sprites.get(i).keyP] && millis()-sprites.get(i).apparitionMs>sprites.get(i).vanishMinimum) sprites.remove(i);
    } else {
      if (millis()-sprites.get(i).apparitionMs>sprites.get(i).vanishMinimum) sprites.remove(i);
    }
  }

  // draw
  background(currentBackground);
  int currentMotifIndex = ((millis()%400)<200)?0:1;
  if (currentMotif[currentMotifIndex]!=null) {
    imageMode(CORNER);
    image(currentMotif[currentMotifIndex], 0, 0);
  }
  for (Sprite s : sprites) s.draw();
  if (dark) background(0);
}

void loadImages() {
  String path = dataPath("letters");
  for (String letter : getSubfolders(path)) {
    Letter l = new Letter();
    l.letter = letter;
    if (l.letter.equals("plus")) l.letter = "+";
    if (l.letter.equals("minus")) l.letter = "-";
    if (l.letter.equals("interrogation")) l.letter = "?";
    if (l.letter.equals("equals")) l.letter = "=";
    if (l.letter.equals("exclamation")) l.letter = "!";
    if (l.letter.equals("dot")) l.letter = ".";
    if (l.letter.equals("comma")) l.letter = ",";
    if (l.letter.equals("semicolon")) l.letter = ";";
    if (l.letter.equals("colon")) l.letter = ":";
    if (l.letter.equals("apostrophe")) l.letter = "'";
    if (l.letter.equals("quote")) l.letter = "\"";
    if (l.letter.equals("hyphen")) l.letter = "-";
    if (l.letter.equals("slash")) l.letter = "/";
    if (l.letter.equals("backslash")) l.letter = "\\";
    if (l.letter.equals("pipe")) l.letter = "|";
    if (l.letter.equals("underscore")) l.letter = "_";
    if (l.letter.equals("multiplication")) l.letter = "*";
    if (l.letter.equals("amperstand")) l.letter = "&";
    if (l.letter.equals("percent")) l.letter = "%";
    if (l.letter.equals("dollar")) l.letter = "$";
    if (l.letter.equals("hash")) l.letter = "#";
    if (l.letter.equals("at")) l.letter = "@";
    // use getFiles(path + "/" + letter) to get all files in the subfolder
    String[] files = getAllFilesFrom(path + "/" + letter);
    files = sort(files);
    for (String file : files) {
      try {
        PImage im = loadImage(file);
        if (im != null) {
          synchronized (letters) {
            l.images.add(im);
            highestPic = max(highestPic,im.height);
          }
        }
      }
      catch (Exception e) {
        println(e);
      }
    }
    synchronized (letters) {
      letters.add(l);
    }
  }
}

void loadMotifs() {
  synchronized (motifs) {
    String[] files = getAllFilesFrom(dataPath("motifs"));
    for (String f : files) {
      PImage im = loadImage(f);
      if (im!=null) motifs.add(createBackground(im));
    }
  }
}

PImage createBackground(PImage motif) {
  PGraphics gr = createGraphics(width, height);
  gr.beginDraw();
  float offsetX = ((float)motif.width+floor(((float)width/motif.width))-width)/2.0;
  float offsetY = ((float)motif.height+floor(((float)height/motif.height))-height)/2.0;
  for (int x=round(offsetX); x<width; x+=motif.width) {
    for (int y=round(offsetY); y<height; y+=motif.height) {
      gr.image(motif, x, y);
    }
  }
  gr.endDraw();
  return gr.get();
}

class Letter {
  String letter = "";
  ArrayList<PImage> images = new ArrayList<PImage>();
  int currentLetterIndex = 0;
}

void keyPressed() {
  if (int(keyCode) < keys.length) keys[int(keyCode)] = true;

  if (keyCode!=BACKSPACE) dark = false;

  if (keyCode==39) {
    if (autoTempo==-1) autoTempo = defaultTempo;
    else autoTempo = -1;
    println("autoTempo : "+autoTempo);
  }

  if (keyCode == RIGHT) { // next sentence
    sentenceIndex = (sentenceIndex + 1) % sentences.length;
    sentenceCharIndex = 0;
    println("current sentence : " + sentences[sentenceIndex]);
    return;
  }
  if (keyCode == LEFT) { // reset sentence position
    sentenceCharIndex = 0;
    return;
  }
  if (keyCode == ENTER) { // display next letter
    displayOneLetter(sentences[sentenceIndex].charAt(sentenceCharIndex), int(keyCode), vanishMinimum);
    sentenceCharIndex = (sentenceCharIndex + 1) % sentences[sentenceIndex].length();
    tempoCounter = millis();
    return;
  }

  if (int(keyCode) >= keys.length) {
    println("exotic key : " + key + " : " + int(keyCode));
    return;
  }

  if (keyCode==91) {// ^
    synchronized(motifs) {
      currentMotif[0] = motifs.get(floor(random(motifs.size())));
      currentMotif[1] = motifs.get(floor(random(motifs.size())));
      while (motifs.size()>0&&currentMotif[1]==currentMotif[0]) {
        currentMotif[1] = motifs.get(floor(random(motifs.size())));
      }
    }
  }

  if (keyCode==93) {// $
    currentMotif[0] = null;
    currentMotif[1] = null;
    color newBackground = currentBackground;
    while (newBackground == currentBackground) {
      int index = int(random(typicalColors.length));
      while (index == 0) index = int(random(typicalColors.length));
      newBackground = typicalColors[index];
    }
    currentBackground = newBackground;
  }

  displayOneLetter(key, int(keyCode), vanishMinimum);

  if (keyCode==BACKSPACE) dark^=true;
  if (keyCode!=BACKSPACE) dark=false;
}

void displayOneLetter(char theLetter, int keyCode, float vanishMinimum) {
  synchronized (letters) {
    for (Letter l : letters) {
      if (l.letter.charAt(0) == theLetter) {
        if (l.images.size() == 0) return;
        sprites.add(new Sprite(l.images.get(l.currentLetterIndex), keyCode, vanishMinimum));
        l.currentLetterIndex = (l.currentLetterIndex + 1) % l.images.size();
        if (changeBackgroundCounter >= changeBackgroundOnceEvery) {
          color newBackground = currentBackground;
          while (newBackground == currentBackground) {
            int index = int(random(typicalColors.length));
            while (index == 0) index = int(random(typicalColors.length));
            newBackground = typicalColors[index];
          }
          currentBackground = newBackground;
          changeBackgroundCounter = 0;
        }
        changeBackgroundCounter++;
      }
    }
  }
}

void keyReleased() {
  if (int(keyCode) < keys.length) keys[int(keyCode)] = false;
}

class Sprite {
  float course = 0;// goes from 0 to 1
  PImage im;
  float xPos = 0.5;
  int keyP;
  float vanishMinimum = 0;
  float apparitionMs = 0;
  Sprite(PImage im, int keyP, float vanishMinimum) {
    this.im = im;
    this.keyP = keyP;
    this.vanishMinimum = vanishMinimum;
    xPos = xPosChain[xPosChainCounter] * width;
    xPosChainCounter = (xPosChainCounter + 1) % xPosChain.length;
    apparitionMs = millis();
  }
  void draw() {
    float tweenedCourse = tweenElastic(course);
    float scaleToFitHeight = min((float)height/highestPic,1.0);
    float size = lerp(0.6, 1.0, tweenedCourse) * scaleToFitHeight;
    PVector startingPos = new PVector(xPos, height * 2 / 3);
    PVector endingPos = new PVector(xPos, height / 2);
    course += jumpSpeed;
    imageMode(CENTER);
    synchronized (im) {
      image(im, lerp(startingPos.x, endingPos.x, tweenedCourse), lerp(startingPos.y, endingPos.y, tweenedCourse), im.width * size, im.height * size);      
    }
  }
}

float tweenElastic(float t) {
  float p = 0.3;
  float value = pow(2, -10 * t) * sin((t - p / 4) * (2 * PI) / p) + 1;
  value += sin(min(t, 3.0) * TWO_PI * 2.0) * max(1.0 - (t - 1.0), 0) * 0.15;
  return value;
}
