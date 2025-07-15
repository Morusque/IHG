
Panel[] panels = new Panel[3];

color[] contestColors = new color[]{color(0, 0xFF, 0), color(0, 0, 0xFF), color(0xFF, 0xFF, 0), color(0xFF, 0, 0)};

int state = 0;
// 0 = tournament
// 1 = winner
// 2 = alts
// 3 = vote

int currentPanel = 0;

int maxPoolSize = 3;
int currentPoolSize = maxPoolSize;

void setup() {
  // size(1700, 1000);
  fullScreen(2);
  for (int i=0; i<panels.length; i++) panels[i] = new Panel(i);
}

void draw() {
  if (state==0) {
    background(0xFF);
    for (int i=0; i<currentPanel; i++) panels[i].shallowWinner();
    panels[currentPanel].tournament();
  }
  if (state==1) {
    background(0xFF);
    if (panels[0].winner!=null) image(panels[0].winner,20,20+300,panels[0].size.x*0.8,panels[0].size.y*0.8);
    if (panels[1].winner!=null) image(panels[1].winner,20,20,panels[1].size.x*0.7,panels[1].size.y*0.7);
    if (panels[2].winner!=null) image(panels[2].winner,20+700,20+300,panels[2].size.x*0.6,panels[2].size.y*0.6);
  }
  if (state==2) {
    if (frameCount%300 == 0) setRandomAlts();
    background(0xFF);
    for (int i=0; i<panels.length; i++) panels[i].alt();
  }
}

class Panel {
  ArrayList<PImage> alternates = new ArrayList<PImage>();
  ArrayList<PImage> candidates = new ArrayList<PImage>();
  PVector position;
  PVector size = new PVector(408, 752);// 85 x 110
  PImage winner;
  PImage random;
  Panel(int index) {
    position = new PVector(0, 0);
  }
  void clearData() {
    alternates.clear();
    candidates.clear();
    winner=null;
  }
  void addImages(String path, int index) {
    println("loading...");
    String[] files = getAllFilesFrom(path);
    for (String f : files) {
      try {
        PImage thisImage = loadImage(f);
        if (index==0) {
          this.size = new PVector(822, 822);
          thisImage = thisImage.get(830, 340, 840, 840);
          thisImage.resize(floor(size.x), floor(size.y));
        }
        if (index==1) {
          this.size = new PVector(2000, 357);
          thisImage = thisImage.get(249, 1407, 2000, 357);
          thisImage.resize(floor(size.x), floor(size.y));
        }
        if (index==2) {
          this.size = new PVector(1058, 1058);
          thisImage = thisImage.get(720, 2000, 1058, 1058);
          thisImage.resize(floor(size.x), floor(size.y));
        }
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
      for (PImage a : alternates) candidates.add(a);
      currentPoolSize = maxPoolSize;
      currentPoolSize = min(currentPoolSize, candidates.size());
    }
    if (candidates.size()>1) {
      // current contestants
      noFill();
      strokeWeight(5);
      if (currentPanel==0) {
        for (int i=0; i<currentPoolSize; i++) {
          float scale = 0.6f;
          image(candidates.get(i%candidates.size()), size.x*scale*i+20, position.y+120, size.x*scale, size.y*scale);
          stroke(contestColors[i]);
          rect(size.x*scale*i+2+20, position.y+120, size.x*scale-4, size.y*scale);
        }
      }
      if (currentPanel==1) {
        for (int i=0; i<currentPoolSize; i++) {
          float scale = 0.6f;
          image(candidates.get(i%candidates.size()), position.x+20, size.y*scale*i+120, size.x*scale, size.y*scale);
          stroke(contestColors[i]);
          rect(position.x+2+20, size.y*scale*i+120, size.x*scale, size.y*scale-4);
        }
      }
      if (currentPanel==2) {
        for (int i=0; i<currentPoolSize; i++) {
          float scale = 0.5f;
          image(candidates.get(i%candidates.size()), size.x*scale*i+20, position.y+120, size.x*scale, size.y*scale);
          stroke(contestColors[i]);
          rect(size.x*scale*i+2+20, position.y+120, size.x*scale-4, size.y*scale);
        }
      }
      // all contestants
      for (int i=0; i<candidates.size(); i++) {
        float xPos = i*55;
        float yPos = 900;
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
        rect(10-2+55*i, 900-3, 50+4, 70+6);
      }
      // last match
      fill(0);
      textAlign(LEFT, BOTTOM);
      if (candidates.size()<=currentPoolSize) text("Dernier match", position.x*0.7f+50.0f+(size.x*maxPoolSize)/2.0f, position.y+850);
    } else {
      if (candidates.size()==1) {
        winner = candidates.get(0);
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
        candidates.clear();
        state=1;
      }
    }
  }
  void instantWinner(int w) {
    if (candidates.size()>w) {
      winner = candidates.get(w);
      candidates.clear();
      state=1;
    }
  }
  void displayWinner() {
    if (winner!=null) {
      image(winner, position.x, position.y+20, size.x, size.y);
      noFill();
      strokeWeight(5);
      stroke(0, 0, 0);
      // rect(position.x, position.y+20, size.x, size.y);
    }
  }
  void shallowWinner() {
    float scale = 0.15f;
    if (winner!=null) image(winner, position.x*scale, position.y*scale+5, size.x*scale, size.y*scale);
  }
  void setRandom() {
    if (alternates.size()>0) random = alternates.get(floor(random(alternates.size())));
  }
  void alt() {
    if (random!=null) {
      image(random, position.x, position.y, size.x, size.y);
      noFill();
      strokeWeight(5);
      stroke(0, 0xFF, 0);
      rect(position.x, position.y, size.x, size.y);
    }
  }
}

int nbSaved = 0;

// first :
// v for the vote
// t for the tournament

// typical usage loop :
// CTRL (load) only when eveything has been scanned
// NUMPAD until winner
// N for next tournament
// change scanner preset

void keyPressed() {
  println(keyCode);
  if (keyCode==CONTROL) {
    for (int i=0; i<panels.length; i++) {
      panels[i].alternates.clear();
      panels[i].candidates.clear();
      panels[i].addImages(dataPath("input/"), i);
    }
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
    if (currentPanel+1<panels.length) {
      currentPanel=currentPanel+1;
      state=0;
    }
  }
  if (keyCode==TAB) save(dataPath("results/"+nf(nbSaved++, 4)+".png"));
  println("---");
  println("current state : "+state);
  println("current panel : "+currentPanel);
}

void setRandomAlts() {
  for (int i=0; i<panels.length; i++) panels[i].setRandom();
}
