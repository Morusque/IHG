
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

Panel[] panels = new Panel[4];

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
  fullScreen(2);
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
  PVector size = new PVector(340, 440);// 85 x 110
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
        thisImage = thisImage.get(817, 367, 1543-817, 1285-367);
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
  if (keyCode==TAB) {
    if (state == 1) save(dataPath("results/"+nf(nbSaved++, 4)+".png"));
    if (state == 2) {
      int exportW = 0;
      int exportH = 0;
      for (int i=0; i<currentPanel+1; i++) {
        if (panels[i].winnerOriginal!=null) {
          PImage thisPanel = panels[i].randomOriginal;
          if (keepFirstAsWinner&&i==0) thisPanel = panels[i].winnerOriginal;
          exportW += thisPanel.width;
          exportH = max(exportH, thisPanel.height);
        }
      }
      PGraphics export = createGraphics(exportW, exportH, JAVA2D);
      export.beginDraw();
      int currentXPos = 0;
      for (int i=0; i<currentPanel+1; i++) {
        if (panels[i].winnerOriginal!=null) {
          PImage thisPanel = panels[i].randomOriginal;
          if (keepFirstAsWinner&&i==0) thisPanel = panels[i].winnerOriginal;
          export.image(thisPanel, currentXPos, 0);
          currentXPos += thisPanel.width;
        }
      }
      export.endDraw();
      export.save(dataPath("results/"+nf(nbSaved++, 4)+".png"));
    }
  }
  println("---");
  println("current state : "+state);
  println("current panel : "+currentPanel);
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
