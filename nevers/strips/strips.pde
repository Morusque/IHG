
// scan : logo <strips> en haut

// pour exporter des images random
// CTRL, U, N, CTRL, U, N, CTRL, U, R puis TAB
// les images sont dans data/result
// pour que le random concerne aussi la première case changer la ligne : boolean keepFirstAsWinner = false;

// first :
// v for the vote
// t for the tournament

// typical usage loop :
// CTRL (load) when eveything has been scanned
// NUMPAD until winner
// N for next tournament
// change scanner preset

import java.awt.Frame;
import processing.awt.PSurfaceAWT;
import processing.awt.PSurfaceAWT.SmoothCanvas;

Panel[] panels = new Panel[3];

String[] topics = new String[]{"dog", "camel", "jumping", "catching", "reading", "administration", "shelves", "light", "violence", "nose", "gift", "king", "fake", "universe", "numbers"};
int jackpotRate = 0;
int thisJackpotTimer = 0;
String[] currentTopics = new String[]{"", "", "", ""};
boolean[] topicDefined = new boolean[4];

boolean keepFirstAsWinner = true;

color[] contestColors = new color[]{color(0, 0xFF, 0), color(0, 0, 0xFF), color(0xFF, 0xFF, 0), color(0xFF, 0, 0)};

int state = 0;
// 0 = tournament
// 1 = winner
// 2 = alts
// 3 = vote

int currentPanel = 0;

int maxPoolSize = 3; // 4;
int currentPoolSize = maxPoolSize;

boolean[] displayBig = new boolean[maxPoolSize];

void setup() {
  // size(1700, 900);
  fullScreen(1);
  textFont(loadFont(dataPath("files/font/OCRAExtended-70.vlw")));
  for (int i=0; i<panels.length; i++) panels[i] = new Panel(i);
  topics = loadStrings(dataPath("files/topics (fr).txt"));
  // frame.toFront();
  // frame.requestFocus();
  for (int i=0; i<panels.length; i++) {
    File f = new File(dataPath("input/"+nf(i+1, 2)));
    f.mkdir();
  }
  for (int i=0; i<displayBig.length; i++) displayBig[i] = false;
}

void draw() {
  if (state==0) {
    background(0xFF);
    for (int i=0; i<currentPanel; i++) panels[i].shallowWinner();
    panels[currentPanel].tournament();
    for (int i=0; i<displayBig.length; i++) if (displayBig[i]) image(panels[currentPanel].candidates.get(i), 1050, 0, panels[currentPanel].candidates.get(i).width*height/panels[currentPanel].candidates.get(i).height, height);
  }
  if (state==1) {
    background(0xFF);
    for (int i=0; i<panels.length; i++) panels[i].displayWinner();
  }
  if (state==2) {
    if (frameCount%300 == 0) setRandomAlts();
    background(0xFF);
    for (int i=0; i<panels.length; i++) {
      if (i==0 && keepFirstAsWinner) panels[i].alt(true);
      else panels[i].alt(false);
    }
  }
  if (state==3) {
    if (jackpotRate>0) {
      if (thisJackpotTimer==0) {
        if (jackpotRate>10&&random(3)<1) topicDefined[floor(random(topicDefined.length))] = true;
        jackpotRate++;
        thisJackpotTimer = jackpotRate;
        for (int i=0; i<currentTopics.length; i++) {
          if (!topicDefined[i]) {
            boolean found = true;
            while (found) {
              currentTopics[i] = topics[floor(random(topics.length))];
              found = false;
              for (int j=0; j<i; j++) if (currentTopics[i].equals(currentTopics[j])) found = true;
            }
          }
        }
      } else {
        thisJackpotTimer--;
      }
    }
    background(0xFF);
    textAlign(CENTER, CENTER);
    textSize(70);
    noStroke();
    for (int i=0; i<currentTopics.length; i++) {
      if (topicDefined[i]) {
        fill(contestColors[i], 0x80);
        rect(0, i*100+height/3-50, width, 100);
      }
      fill(0);
      text(currentTopics[i], width/7*(i+2), i*100+height/3);
    }
  }
}

class Panel {
  ArrayList<PImage> alternates = new ArrayList<PImage>();
  ArrayList<PImage> candidates = new ArrayList<PImage>();
  ArrayList<PImage> alternatesOriginals = new ArrayList<PImage>();
  ArrayList<PImage> candidatesOriginals = new ArrayList<PImage>();
  PVector position;
  PVector size = new PVector(737*0.7, 659*0.7);// 85 x 110
  PImage winner;
  PImage winnerOriginal;
  PImage random;
  PImage randomOriginal;
  Panel(int index) {
    position = new PVector(index*size.x, 0);
  }
  void clearData() {
    alternates.clear();
    candidates.clear();
    alternatesOriginals.clear();
    candidatesOriginals.clear();
    winner=null;
  }
  void addImages(String path) {
    println("loading...");
    String[] files = getAllFilesFrom(path);
    for (String f : files) {
      try {
        PImage thisImage = loadImage(f);
        // thisImage = thisImage.get(793, 353, 1537-793, 1293-353);
        // thisImage = thisImage.get(817, 367, 1543-817, 1285-367);
        thisImage = thisImage.get(467, 831, 737, 659);
        alternatesOriginals.add(thisImage.copy());
        thisImage.resize(floor(size.x), floor(size.y));
        alternates.add(thisImage);
      }
      catch(Exception e) {
        println(e);
      }
    }
    println("...done");
  }
  void tournament() {
    if (winner==null&&candidates.size()==0) { // start tournament
      for (int i=0; i<alternates.size(); i++) {
        candidates.add(alternates.get(i));
        candidatesOriginals.add(alternatesOriginals.get(i));
      }
      currentPoolSize = maxPoolSize;
    }
    if (candidates.size()>1) {
      // current contestants
      noFill();
      strokeWeight(5);
      for (int i=0; i<currentPoolSize; i++) {
        image(candidates.get(i%candidates.size()), size.x*i+20, position.y+320, size.x, size.y);
        stroke(contestColors[i]);
        rect(size.x*i+2+20, position.y+320, size.x-4, size.y);
      }
      // all contestants
      for (int i=0; i<candidates.size(); i++) {
        float xPos = i*55;
        float yPos = 800;
        while (xPos>=width) {
          xPos -= width;
          yPos += 80;
        }
        image(candidates.get(i), xPos+10, yPos, 50, 70);
      }
      noFill();
      strokeWeight(2);
      for (int i=0; i<currentPoolSize; i++) {
        stroke(contestColors[i]);
        rect(10-2+55*i, 800-3, 50+4, 70+6);
      }
      // last match
      fill(0);
      textAlign(LEFT, BOTTOM);
      if (candidates.size()<=currentPoolSize) text("Last match", position.x*0.7f+50.0f+(size.x*maxPoolSize)/2.0f, position.y+850);
    } else {
      if (candidates.size()==1) {
        winner = candidates.get(0);
        winnerOriginal = candidatesOriginals.get(0);
        candidates.clear();
        state=1;
      }
    }
  }
  void keepContestant(int localWinner) {
    if (localWinner<currentPoolSize) {
      for (int i=0; i<currentPoolSize; i++) {// remove losers
        if (i==localWinner) candidates.add(candidates.remove(0));
        else candidates.remove(0);
      }
      if (candidates.size()>0) {
        currentPoolSize = constrain(floor((float)candidates.size()/2), 2, maxPoolSize);
      }
      if (candidates.size()==1) {
        winner = candidates.get(0);
        winnerOriginal = candidatesOriginals.get(0);
        candidates.clear();
        state=1;
      }
    }
  }
  void instantWinner(int w) {
    if (candidates.size()>w) {
      winner = candidates.get(w);
      winnerOriginal = candidatesOriginals.get(w);
      candidates.clear();
      state=1;
    }
  }
  void displayWinner() {
    if (winner!=null) {
      pushMatrix();
      translate(300, 300);
      image(winner, position.x, position.y, size.x, size.y);
      noFill();
      strokeWeight(5);
      stroke(0, 0, 0);
      rect(position.x, position.y, size.x, size.y);
      popMatrix();
    }
  }
  void shallowWinner() {
    if (winner!=null) image(winner, position.x*0.7f, position.y*0.7f, size.x*0.7f, size.y*0.7f);
  }
  void setRandom() {
    if (alternates.size()>0) {
      int rndIndex = floor(random(alternates.size()));
      random = alternates.get(rndIndex);
      randomOriginal = alternatesOriginals.get(rndIndex);
    }
  }
  void alt(boolean displayWinner) {
    if (random!=null) {
      if (displayWinner) image(winner, position.x, position.y, size.x, size.y);
      else image(random, position.x, position.y, size.x, size.y);
      noFill();
      strokeWeight(5);
      stroke(0, 0xFF, 0);
      if (state==0) rect(position.x, position.y, size.x, size.y);
    }
  }
}

int nbSaved = 0;

void keyPressed() {
  println(keyCode);
  if (keyCode==CONTROL) {
    panels[currentPanel].alternates.clear();
    panels[currentPanel].candidates.clear();
    panels[currentPanel].addImages(dataPath("input/"+nf(currentPanel+1, 2)+"/"));
  }
  if (state==0) {
    if (keyCode==97) panels[currentPanel].keepContestant(0);// numpad1
    if (keyCode==98) panels[currentPanel].keepContestant(1);// numpad2
    if (keyCode==99) panels[currentPanel].keepContestant(2);// numpad3
    if (keyCode==100) panels[currentPanel].keepContestant(3);// numpad4
    if (keyCode==85) panels[currentPanel].instantWinner(0);// u
    if (keyCode==73) panels[currentPanel].instantWinner(1);// i
    if (keyCode==79) panels[currentPanel].instantWinner(2);// o
    if (keyCode==80) panels[currentPanel].instantWinner(3);// p
    if (keyCode==74) if (displayBig.length>0) displayBig[0] = true;
    if (keyCode==75) if (displayBig.length>1) displayBig[1] = true;
    if (keyCode==76) if (displayBig.length>2) displayBig[2] = true;
    if (keyCode==77) if (displayBig.length>3) displayBig[3] = true;
  }
  if (keyCode==84) {// t (go to tournament mode)
    state=0;
  }
  if (keyCode==87) {// w (go to winner mode)
    state=1;
  }
  if (keyCode==82) {// r (go to random mode)
    setRandomAlts();
    state=2;
  }
  if (keyCode==67) {// c (remove pics from current panel)
    panels[currentPanel].clearData();
  }
  if (keyCode==66) {// b (go to previous panel)
    currentPanel=max(0, currentPanel-1);
  }
  if (keyCode==78) {// n (go to next panel and tournament)
    if (currentPanel+1<panels.length) currentPanel=currentPanel+1;
    state=0;
  }
  if (keyCode==70) {// f (keep first as winner)
    keepFirstAsWinner ^= true;
  }
  if (keyCode=='V') {// v vote
    state=3;
    jackpotRate=1;
    for (int i=0; i<topicDefined.length; i++) topicDefined[i]=false;
  }
  if (keyCode==71) { // g
    int exportW = 1050;
    int exportH = 2970;
    float margin = 20;

    // prepare index arrays
    String[] titleFiles = getAllFilesFrom(dataPath("../../accessoires/data/input"));

    Integer[] titleIndexes = new Integer[titleFiles.length];
    Integer[] aIndexes = new Integer[panels[0].alternatesOriginals.size()];
    Integer[] bIndexes = new Integer[panels[1].alternatesOriginals.size()];
    Integer[] cIndexes = new Integer[panels[2].alternatesOriginals.size()];

    for (int i = 0; i < titleIndexes.length; i++) titleIndexes[i] = i;
    for (int i = 0; i < aIndexes.length; i++) aIndexes[i] = i;
    for (int i = 0; i < bIndexes.length; i++) bIndexes[i] = i;
    for (int i = 0; i < cIndexes.length; i++) cIndexes[i] = i;

    java.util.Collections.shuffle(java.util.Arrays.asList(titleIndexes));
    java.util.Collections.shuffle(java.util.Arrays.asList(aIndexes));
    java.util.Collections.shuffle(java.util.Arrays.asList(bIndexes));
    java.util.Collections.shuffle(java.util.Arrays.asList(cIndexes));

    // max export count
    int maxCount = max(titleIndexes.length, max(aIndexes.length, max(bIndexes.length, cIndexes.length)));

    // export loop
    for (int i = 0; i < maxCount; i++) {
      PImage title = null;
      if (titleIndexes.length > 0) {
        title = loadImage(titleFiles[titleIndexes[i % titleIndexes.length]]);
        title = title.get(250, 1413, 2010, 357);  // crop the title zone

        // remove blue pixels
        title.loadPixels();
        color target = color(0xFF9FE7F3); // Couleur cible avec alpha
        float targetThresh = 100;          // Distance max à target
        float blackThresh = 80;           // Distance min au noir
        for (int j = 0; j < title.pixels.length; j++) {
          color c = title.pixels[j];
          float dTarget = dist(red(c), green(c), blue(c), red(target), green(target), blue(target));
          float dBlack = dist(red(c), green(c), blue(c), 0, 0, 0);
          if (dTarget < targetThresh && dBlack > blackThresh) {
            title.pixels[j] = color(255); // Met en blanc
          }
        }
        title.updatePixels();
      }

      PImage[] panelImages = new PImage[3];
      if (aIndexes.length > 0) panelImages[0] = panels[0].alternatesOriginals.get(aIndexes[i % aIndexes.length]);
      if (bIndexes.length > 0) panelImages[1] = panels[1].alternatesOriginals.get(bIndexes[i % bIndexes.length]);
      if (cIndexes.length > 0) panelImages[2] = panels[2].alternatesOriginals.get(cIndexes[i % cIndexes.length]);

      // build final image
      PGraphics export = createGraphics(exportW, exportH, JAVA2D);
      export.beginDraw();
      export.background(255);

      float currentY = margin;

      // draw title
      if (title != null) {
        float scaleT = (exportW - 2 * margin) / (float)title.width;
        float titleH = title.height * scaleT;
        export.image(title, margin, currentY, exportW - 2 * margin, titleH);
        currentY += titleH + margin;
      }

      // draw panels
      float availableH = exportH - currentY - 2 * margin;
      float occupySpaceToBottom = 0.95;
      float panelH = availableH * occupySpaceToBottom / 3.0;

      for (int p = 0; p < 3; p++) {
        PImage img = panelImages[p];
        if (img == null) continue;

        float scale = (exportW - 2 * margin) / (float)img.width;
        float hScaled = img.height * scale;
        if (hScaled > panelH) scale = panelH / (float)img.height;

        float w = img.width * scale;
        float h = img.height * scale;
        float x = (exportW - w) / 2;
        float y = currentY + (panelH - h) / 2;

        export.image(img, x, y, w, h);
        currentY += panelH + margin;
      }

      export.endDraw();
      export.save(dataPath("result/va/" + nf(nbSaved++, 4) + ".png"));
      println("exported " + nbSaved);
    }
  }
  if (keyCode == 72) { // h (gagnants seulement, titre fixe)    
    PImage title = loadImage(dataPath("../../accessoires/data/files/winnerTitle.png"));
    title = title.get(250, 1413, 2010, 357);  // crop title
    title.loadPixels();// nettoyer les pixels bleus
    color target = color(0xFF9FE7F3); // bleu
    float targetThresh = 100;
    float blackThresh = 80;
    for (int j = 0; j < title.pixels.length; j++) {
      color c = title.pixels[j];
      float dTarget = dist(red(c), green(c), blue(c), red(target), green(target), blue(target));
      float dBlack = dist(red(c), green(c), blue(c), 0, 0, 0);
      if (dTarget < targetThresh && dBlack > blackThresh) {
        title.pixels[j] = color(255);
      }
    }
    title.updatePixels();
    
    int exportW = 1050;
    int exportH = 2970;
    float margin = 20;
    PGraphics export = createGraphics(exportW, exportH, JAVA2D);
    export.beginDraw();
    export.background(255);
    float currentY = margin;

    // Draw title
    float scaleT = (exportW - 2 * margin) / (float)title.width;
    float titleH = title.height * scaleT;
    export.image(title, margin, currentY, exportW - 2 * margin, titleH);
    currentY += titleH + margin;

    // Draw panel winners
    float availableH = exportH - currentY - 2 * margin;
    float occupySpaceToBottom = 0.95;
    float panelH = availableH * occupySpaceToBottom / 3.0;

    for (int p = 0; p < 3; p++) {
      PImage img = panels[p].winner;
      float scale = (exportW - 2 * margin) / (float)img.width;
      float hScaled = img.height * scale;
      if (hScaled > panelH) scale = panelH / (float)img.height;
      float w = img.width * scale;
      float h = img.height * scale;
      float x = (exportW - w) / 2;
      float y = currentY + (panelH - h) / 2;
      export.image(img, x, y, w, h);
      currentY += panelH + margin;
    }
    export.endDraw();
    export.save(dataPath("result/winner/winner.png"));
    println("winner export saved: " + nbSaved);
  }
}

void keyReleased() {
  if (keyCode==74) if (displayBig.length>0) displayBig[0] = false;
  if (keyCode==75) if (displayBig.length>1) displayBig[1] = false;
  if (keyCode==76) if (displayBig.length>2) displayBig[2] = false;
  if (keyCode==77) if (displayBig.length>3) displayBig[3] = false;
}

void setRandomAlts() {
  for (int i=0; i<panels.length; i++) panels[i].setRandom();
}
