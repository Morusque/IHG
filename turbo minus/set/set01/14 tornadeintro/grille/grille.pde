
// A = Couleur ou Motif
// ENTREE = Refresh (change le mode de disposition des tuiles)
// N = New - Ajoute un carré
// B = Big - Gros carré

// G = Grille
// I = Inverse (switche la couleur de la grille n/b)

// T = Tempo (tap)
// Y = Pause

// P = Paysage (dézoome)
// M = Monochrome (même tile partout)
// BACKSPACE = Tout noir

// E = Supprime les tiles (au profit du blanc ou noir)

// O = Refresh (change le mode de disposition des tuiles, plus aléatoire que R)
// F = Refresh (génère une disposition dans le même mode de disposition)
// Z = déforme la grille une fois
// U = Remplace progressivement un type de tuile par un autre
// L = Dispose les tuiles selon une image
// Q = charge le prochain pack de visages

import java.util.HashSet;

Pattern pattern;
Pattern nextPattern;
Pattern lerpedPattern;

ArrayList<PImage> facesIms = new ArrayList<PImage>();

float patternLerping = 0;

int minLinesEachDirection = 60;

int maxNbFaces = 15;

float lerpingSpeed = 0.0;
float lastTapTime = 0.0;

int fillMode = 0;
// 0 = images
// 1 = solid colors

int mosaicMode = 1;
// -1 nothing
// 0 solid
// 1 diagonals
// 2 zigzags
// 3 chessboard
// 4 vertical
// 5 horizontal

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

int[][] colorIndexes;

boolean displayGrid = true;
boolean blackBg = false;

int replaceFrom = -1;
int replaceTo = -1;
int replacedCheckedIndexX = 0;
int replacedCheckedIndexY = 0;

ArrayList<PImage> messages = new ArrayList<PImage>();

boolean autoType = false;// moby dick mode

float changeDispoEvery = -1.0;// -1 = disabled, otherwise expressed in seconds
float changeDispoEveryTimer = 0.0;

String[] facesSubfolders;
int currentSubfolderIndex = 0;

boolean dark = false;

void setup() {
  // size(1920, 1080);
  fullScreen(2);
  frameRate(50);
  // list all subfolders in dataPath("faces/") and put them in facesSubfolders
  facesSubfolders = getSubfolders(dataPath("faces/"));
  facesSubfolders = sort(facesSubfolders);
  loadFacesImgFiles();
  pattern = new Pattern();
  pattern.generateGrid();
  nextPattern = new Pattern();
  nextPattern.generateGrid();
  lerpedPattern = new Pattern();
  colorIndexes = new color[pattern.gc.xs.size()][pattern.gc.ys.size()];
  generateIndexes(1);
  noSmooth();
  String[] messagesFiles = getAllFilesFrom(dataPath("messages"));
  messagesFiles = sort(messagesFiles);
  for (String f : messagesFiles) {
    try {
      PImage im = loadImage(f);
      if (im!=null) messages.add(im);
    }
    catch (Exception e) {
      println(e);
    }
  }
  float tempoDefault = 108;// BPM
  lerpingSpeed = 1.0 / (frameRate * (60.0/tempoDefault));
}

void draw() {
  if (autoType && random(1)<0.3) keyPressed();
  if (changeDispoEvery>=0) {
    if (((float)millis()-changeDispoEveryTimer) / 1000.0 > changeDispoEvery) {
      mosaicMode+=1;
      if (mosaicMode==2) mosaicMode++;// s'il s'apprête à générer en mode "zigzag" passer directement au suivant
      if (mosaicMode>5) mosaicMode=1;
      generateIndexes(mosaicMode);
      changeDispoEveryTimer = millis();
    }
  }
  if (replaceFrom!=-1 && replaceTo!=-1) {
    for (int i=0; i<2000; i++) {
      int iX = floor(random(colorIndexes.length));
      int iY = floor(random(colorIndexes[0].length));
      /*
      iX=replacedCheckedIndexX;
       iY=replacedCheckedIndexY;
       replacedCheckedIndexX+=1;
       if (replacedCheckedIndexX>=colorIndexes.length) {
       replacedCheckedIndexY+=1;
       replacedCheckedIndexX=0;
       if (replacedCheckedIndexY>=colorIndexes[0].length) {
       replacedCheckedIndexY=0;
       }
       }
       */
      if (colorIndexes[iX][iY]==replaceFrom) colorIndexes[iX][iY]=replaceTo;
    }
  }
  pattern.update();
  nextPattern.update();
  lerpedPattern.createLerpBewteen(pattern, nextPattern, patternLerping);
  if (patternLerping<1) patternLerping = patternLerping+lerpingSpeed;
  if (patternLerping>=1) {
    switchToNewGrid();
  }
  if (blackBg) background(0);
  else background(0xFF);
  lerpedPattern.draw();
  if (dark) background(0);
}

void loadFacesImgFiles() {
  String[] facesImgFiles = getAllFilesFrom(dataPath("faces/"+facesSubfolders[currentSubfolderIndex]));
  facesIms.clear();
  for (String f : facesImgFiles) {
    try {
      PImage im = loadImage(f);
      if (im!=null) facesIms.add(im);
    }
    catch (Exception e) {
      println(e);
    }
  }
  currentSubfolderIndex = (currentSubfolderIndex+1)%facesSubfolders.length;
  println("Loaded "+facesIms.size()+" faces from folder : " + facesSubfolders[currentSubfolderIndex]);
}

class Pattern {
  GridCoordinates gc = new GridCoordinates();
  PVector center = new PVector((float)width/2, (float)height/2);
  float typicalGapX = 30;
  float typicalGapY = 30 ;
  Pattern() {
  }
  void mutateParameters() {
    typicalGapX=0;
    typicalGapY=0;
    for (int i=0; i<gc.xs.size()-1; i++) typicalGapX += (gc.xs.get(i+1)-gc.xs.get(i))/(gc.xs.size()-1);
    for (int i=0; i<gc.ys.size()-1; i++) typicalGapY += (gc.ys.get(i+1)-gc.ys.get(i))/(gc.ys.size()-1);
    if (random(1)<0.1) typicalGapX = random(20, random(20, 150));
    if (random(1)<0.1) typicalGapY = random(20, random(20, 150));
    if (random(1)<0.1) center.x = (float)width/2+random(-50, 50);
    if (random(1)<0.1) center.y = (float)height/2+random(-50, 50);
  }
  void generateGrid() {
    float currentValue = center.x;
    gc.xs = new ArrayList<Float>();
    gc.ys = new ArrayList<Float>();
    for (int i = 0; i < minLinesEachDirection; i++) {
      gc.xs.add(currentValue);
      currentValue+=typicalGapX;
    }
    currentValue = center.x-typicalGapX;
    for (int i = 0; i < minLinesEachDirection; i++) {
      gc.xs.add(0, currentValue);
      currentValue-=typicalGapX;
    }
    currentValue = center.y;
    for (int i = 0; i < minLinesEachDirection; i++) {
      gc.ys.add(currentValue);
      currentValue+=typicalGapY;
    }
    currentValue = center.y-typicalGapY;
    for (int i = 0; i < minLinesEachDirection; i++) {
      gc.ys.add(0, currentValue);
      currentValue-=typicalGapY;
    }
    float sinFreqX = random(0.8);
    float sinAmpX = random(typicalGapX*0.8/sinFreqX);
    float sinFreqY = random(0.8);
    float sinAmpY = random(typicalGapY*0.8/sinFreqY);
    for (int i = 0; i<gc.xs.size(); i++) gc.xs.set(i, gc.xs.get(i)+sinAmpX*sin(((float)i-minLinesEachDirection)*sinFreqX));
    for (int i = 0; i<gc.ys.size(); i++) gc.ys.set(i, gc.ys.get(i)+sinAmpY*sin(((float)i-minLinesEachDirection)*sinFreqY));
  }

  void createLerpBewteen(Pattern a, Pattern b, float lerpFactor) {
    center = PVector.lerp(a.center, b.center, lerpFactor);
    typicalGapX = lerp(a.typicalGapX, b.typicalGapX, lerpFactor);
    typicalGapY = lerp(a.typicalGapY, b.typicalGapY, lerpFactor);
    gc = new GridCoordinates();
    for (int i = 0; i < a.gc.xs.size(); i++) gc.xs.add(lerp(a.gc.xs.get(i), b.gc.xs.get(i), lerpFactor));
    for (int i = 0; i < a.gc.ys.size(); i++) gc.ys.add(lerp(a.gc.ys.get(i), b.gc.ys.get(i), lerpFactor));
  }

  void update() {
  }

  void draw() {
    noStroke();
    rectMode(CORNERS);
    for (int x = 0; x < gc.xs.size() - 1; x++) {
      for (int y = 0; y < gc.ys.size() - 1; y++) {
        float qX1 = gc.xs.get(x);
        float qX2 = gc.xs.get(x + 1);
        float qY1 = gc.ys.get(y);
        float qY2 = gc.ys.get(y + 1);
        if (colorIndexes[x][y]!=-1) {
          if (qX1<width && qY1<height && qX2>=0 && qY2>=0) {// if it's visible
            if (fillMode==1) {
              fill(typicalColors[colorIndexes[x][y]%typicalColors.length]);
              rect(round(qX1), round(qY1), round(qX2), round(qY2));
            }
            if (fillMode==0) {
              if (facesIms.size()>0) image(facesIms.get(colorIndexes[x][y]%facesIms.size()), qX1, qY1, qX2 - qX1, qY2 - qY1);
            }
          }
        }
      }
    }
    if (displayGrid) {
      float sW = 2;
      strokeWeight(sW);
      if (blackBg) stroke(0xFF);
      else stroke(0);
      for (int x = 0; x<gc.xs.size(); x++) {
        float qX = gc.xs.get(x);
        if (qX>=-sW && qX<width+sW) line(qX, 0, qX, height);
      }
      if (blackBg) stroke(0xFF);
      else stroke(0);
      for (int y = 0; y<gc.ys.size(); y++) {
        float qY = gc.ys.get(y);
        if (qY>=-sW && qY<height+sW) line(0, qY, width, qY);
      }
    }
  }

  Pattern copy() {
    Pattern newPattern = new Pattern();
    newPattern.center = center.copy();
    newPattern.typicalGapX = typicalGapX;
    newPattern.typicalGapY = typicalGapY;
    for (int i = 0; i < gc.xs.size(); i++) newPattern.gc.xs.add(gc.xs.get(i));
    for (int i = 0; i < gc.ys.size(); i++) newPattern.gc.ys.add(gc.ys.get(i));
    return newPattern;
  }
  void extendAt(int x, int y, float extension) {
    float gradient = 0;
    for (int i = 0; i < gc.xs.size(); i++) {
      if (i<=x+0) gc.xs.set(i, gc.xs.get(i)-max(0, extension-abs(i-(x+0.5)*gradient)));
      if (i>=x+1) gc.xs.set(i, gc.xs.get(i)+max(0, extension-abs(i-(x+0.5)*gradient)));
    }
    for (int i = 0; i < gc.ys.size(); i++) {
      if (i<=y+0) gc.ys.set(i, gc.ys.get(i)-max(0, extension-abs(i-(y+0.5)*gradient)));
      if (i>=y+1) gc.ys.set(i, gc.ys.get(i)+max(0, extension-abs(i-(y+0.5)*gradient)));
    }
  }
}

class GridCoordinates {
  ArrayList<Float> xs;
  ArrayList<Float> ys;
  GridCoordinates() {
    xs = new ArrayList<Float>();
    ys = new ArrayList<Float>();
  }
}

void keyPressed() {
  if (autoType) key = char(floor(random(128)));
  if (keyCode!=BACKSPACE) dark = false;
  if (key=='b') addBigFace(true);
  if (key=='c') addBigFace(false);
  if (key=='n') addNewFaces();
  if (key=='a') {
    fillMode = (fillMode+1)%2;
  }
  if (key=='e') {
    generateIndexes(-1);
  }
  if (key=='g') {
    displayGrid = !displayGrid;
  }
  if (keyCode==ENTER) {
    mosaicMode+=1;
    if (mosaicMode>5) mosaicMode=1;
    if (mosaicMode==2) mosaicMode++;// s'il s'apprête à générer en mode "zigzag" passer directement au suivant
    generateIndexes(mosaicMode);
  }
  if (key=='o') {
    generateIndexes(floor(random(8)));
  }
  if (key=='f') {
    generateIndexes(mosaicMode);
  }
  if (key=='z') {
    switchToNewGrid();
  }
  if (key=='t') {// tap tempo
    float elapsedSeconds = (millis() - lastTapTime) / 1000.0;
    lerpingSpeed = 1.0 / (frameRate * elapsedSeconds);
    lastTapTime = millis();
  }
  if (key=='y') {// no lerp
    if (lerpingSpeed == 0.0) lerpingSpeed = 0.04;
    else lerpingSpeed = 0.0;
  }
  if (key=='i') {
    blackBg = !blackBg;
  }
  if (keyCode==BACKSPACE) {
    dark ^= true;
  }
  if (key=='m') {
    generateIndexes(0);
  }
  if (key=='p') {
    pattern = lerpedPattern.copy();
    nextPattern = lerpedPattern.copy();
    nextPattern.typicalGapX=25;
    nextPattern.typicalGapY=15;
    nextPattern.center = new PVector(width/2, height/2);
    nextPattern.generateGrid();
    patternLerping = 0;
  }
  if (key=='u') {
    replaceFrom = colorIndexes[floor(random(colorIndexes.length))][floor(random(colorIndexes[0].length))];
    replaceTo = floor(random(facesIms.size()));
    replacedCheckedIndexX = 0;
    replacedCheckedIndexY = 0;
  }
  if (key=='l') {
    displayMessage();
  }
  if (key=='q') {
    loadFacesImgFiles();
  }
}

void displayMessage() {
  PImage message = messages.get(floor(random(messages.size())));
  ArrayList<Integer> uniqueColors = new ArrayList<Integer>();

  // Find unique colors in the message image
  for (int x = 0; x < message.width; x++) {
    for (int y = 0; y < message.height; y++) {
      int c = message.get(x, y);
      if (!uniqueColors.contains(c)) {
        uniqueColors.add(c);
      }
    }
  }

  // Define an array of shuffled indexes spanning from 1 to facesIms.size()
  int[] shuffledIndexes = new int[uniqueColors.size()];
  int[] indexes = new int[facesIms.size()];
  for (int i = 0; i < facesIms.size(); i++) {
    indexes[i] = i + 1; // Fill with 1 to facesIms.size()
  }

  // Shuffle the indexes using Fisher-Yates algorithm
  for (int i = facesIms.size() - 1; i > 0; i--) {
    int j = floor(random(i + 1)); // Random index from 0 to i
    // Swap indexes[i] and indexes[j]
    int temp = indexes[i];
    indexes[i] = indexes[j];
    indexes[j] = temp;
  }

  // Assign shuffled indexes to unique colors
  for (int i = 0; i < uniqueColors.size(); i++) {
    shuffledIndexes[i] = indexes[i % facesIms.size()]; // Cycle if uniqueColors > facesIms.size()
  }

  // find tile index closest to the center of the screen
  int centerIndexX = 0;
  int centerIndexY = 0;
  float centerX = width / 2;
  float centerY = height / 2;
  float closestDistance = Float.MAX_VALUE;
  for (int i = 0; i < colorIndexes.length; i++) {
    float distance = abs(centerX - pattern.gc.xs.get(i));
    if (distance < closestDistance) {
      closestDistance = distance;
      centerIndexX = i;
    }
  }
  closestDistance = Float.MAX_VALUE;
  for (int i = 0; i < colorIndexes[0].length; i++) {
    float distance = abs(centerY - pattern.gc.ys.get(i));
    if (distance < closestDistance) {
      closestDistance = distance;
      centerIndexY = i;
    }
  }

  // Make sure the message is centered
  int startX, startY;
  for (startX = centerIndexX-floor((float)message.width/2.0); startX > 0; startX-=message.width);
  for (startY = centerIndexY-floor((float)message.height/2.0); startY > 0; startY-=message.height);

  // Assign indices based on unique colors
  for (int x = 0; x < colorIndexes.length; x++) {
    for (int y = 0; y < colorIndexes[x].length; y++) {
      int c = message.get((x-startX) % message.width, (y-startY) % message.height);
      // make sur that the message in the middle is centered regardless of the size of the image
      int colorIndex = uniqueColors.indexOf(c); // Find the index of the color
      if (fillMode==0) {
        colorIndex = shuffledIndexes[colorIndex];
      }
      colorIndexes[x][y] = colorIndex;
    }
  }
}

void generateIndexes(int mode) {
  int maxIndex = max(facesIms.size(), typicalColors.length);
  boolean good = false;
  while (!good) {
    int offset = floor(random(maxIndex));
    if (mode==0) {
      while ((offset)%typicalColors.length==0) offset = floor(random(maxIndex));
    }
    int mult = floor(random(1, maxIndex));
    boolean invertY = (random(1)<0.5);
    float xorDivider = random(0.5, 20);
    int zigzagSize = round(random(2, 4));
    int alternateSize = round(random(5, 10));
    HashSet<Integer> seenIndexes = new HashSet<Integer>();
    for (int x=0; x<colorIndexes.length; x++) {
      for (int y=0; y<colorIndexes[x].length; y++) {
        int colorIndex = 0;
        if (mode==-1) colorIndex = -1;
        if (mode==0) colorIndex = offset;
        if (mode==1) colorIndex = ((x+(invertY?colorIndexes[0].length-y:y)) % alternateSize)*mult + offset;
        if (mode==2) colorIndex = ((x+(invertY?colorIndexes[0].length-y:y)%zigzagSize)%alternateSize)*mult + offset;
        if (mode==3) colorIndex = ((x+y) % 2)*mult + offset;
        if (mode==4) colorIndex = ((x) % 3)*mult + offset;
        if (mode==5) colorIndex = ((y) % 3)*mult + offset;
        if (mode==6) colorIndex = floor(random(maxIndex));
        if (mode==7) colorIndex = floor((x^y)/xorDivider+offset);
        colorIndexes[x][y] = colorIndex;
        if (!seenIndexes.contains(colorIndex%typicalColors.length)) {
          seenIndexes.add(colorIndex%typicalColors.length); // Mark the index as seen
        }
      }
    }
    if (seenIndexes.size()>1 || (mode==-1||mode==0)) good = true;
  }
}

void switchToNewGrid() {
  pattern = lerpedPattern.copy();
  nextPattern = lerpedPattern.copy();
  nextPattern.mutateParameters();
  nextPattern.generateGrid();
  patternLerping = 0;
}

void addNewFaces() {
  pattern = lerpedPattern.copy();
  int nbNewFaces = floor(random(1, 3));
  for (int i=0; i<nbNewFaces; i++) {
    int indexX = floor(minLinesEachDirection+random(-minLinesEachDirection, minLinesEachDirection)*0.3);
    int indexY = floor(minLinesEachDirection+random(-minLinesEachDirection, minLinesEachDirection)*0.3);
    int nbTries = 0;
    while ((pattern.gc.xs.get(indexX) < 0 || pattern.gc.xs.get(indexX) >= width ||
      pattern.gc.ys.get(indexY) < 0 || pattern.gc.ys.get(indexY) >= height) &&
      nbTries++ < 1000) {
      indexX = floor(minLinesEachDirection+random(-minLinesEachDirection, minLinesEachDirection)*0.3);
      indexY = floor(minLinesEachDirection+random(-minLinesEachDirection, minLinesEachDirection)*0.3);
    }
    if ((indexX + indexY) % 2 == 1) indexY+=1;
    colorIndexes[indexX][indexY] = floor(random(facesIms.size()));
    nextPattern.extendAt(indexX, indexY, random(50, 200));
  }
  patternLerping = 0;
}

void addBigFace(boolean changeTile) {
  pattern = lerpedPattern.copy();
  nextPattern = lerpedPattern.copy();
  // find line index that is closest to the center of the screen
  float centerX = width / 2;
  float centerY = height / 2;
  float closestDistance = Float.MAX_VALUE;
  int closestIndexX = 0;
  int closestIndexY = 0;
  for (int i = 0; i < nextPattern.gc.xs.size(); i++) {
    float distance = abs(nextPattern.gc.xs.get(i) - centerX);
    if (distance < closestDistance) {
      closestDistance = distance;
      closestIndexX = i;
    }
  }
  closestDistance = Float.MAX_VALUE;
  for (int i = 0; i < nextPattern.gc.ys.size(); i++) {
    float distance = abs(nextPattern.gc.ys.get(i) - centerY);
    if (distance < closestDistance) {
      closestDistance = distance;
      closestIndexY = i;
    }
  }
  if (changeTile) colorIndexes[closestIndexX][closestIndexY] = floor(random(facesIms.size()));
  nextPattern.extendAt(closestIndexX, closestIndexY, 400);
  patternLerping = 0.0;
}

String[] getAllFilesFrom(String folderUrl) {
  File folder = new File(folderUrl);
  File[] filesPath = folder.listFiles();
  String[] result = new String[filesPath.length];
  for (int i=0; i<filesPath.length; i++) {
    result[i]=filesPath[i].toString();
  }
  return result;
}

String[] getSubfolders(String baseFolder) {
  File folder = new File(baseFolder);
  File[] subFolders = folder.listFiles(File::isDirectory);
  ArrayList<String> result = new ArrayList<String>();

  for (File subFolder : subFolders) result.add(subFolder.getName());
  return result.toArray(new String[0]);
}
