
// a = Ajoute une note
// z = ajoute une barre de mesure

// f  = Couleur de fond
// p = Change la hauteur de la portée

// e = Fin de la portée
// r = début de la portée

// q = Mitraille les notes

// Constants for the staff
int numLines = 5;
float lineSpacing = 100;
float staffHeight = (numLines - 1) * lineSpacing;

ArrayList<Note> notes;
ArrayList<MeasureBar> measureBars;

float currentMesTime = 0;
float mesTime = 4;

float defaultSpeed = -7;

ArrayList<PImage> images = new ArrayList<PImage>();

float shiftY = 300;
float shiftYTarget = 300;

color[] typicalColors = new color[]{
  color(0),
  color(255),
  color(255, 223, 230), // rose
  color(207, 57, 255),  // violet
  color(0, 255, 161),   // vert
  color(255, 74, 45),   // rouge
  color(0, 247, 255),   // bleu
  color(255, 243, 110)  // jaune
};

color bgColor = color(0xFF);

boolean dark = false;

PImage titreIm;
ArrayList<PImage> keys = new ArrayList<PImage>();
ArrayList<PImage> alterations = new ArrayList<PImage>();

boolean adaptativeSpeed = true;
boolean continuousNotes = false;
int continuousNotesRate = 5;

float mBarToNoteMargin = 100;

boolean staffActiveRight = false;
boolean staffActiveLeft = false;

boolean waving = false;

void setup() {
  fullScreen(P2D, 1);
  frameRate(60);
  notes = new ArrayList<Note>();
  measureBars = new ArrayList<MeasureBar>();
  String[] files = getAllFilesFrom(dataPath("heads"));
  for (String f : files) {
    try {
      PImage im = loadImage(f);
      if (im!=null) images.add(im);
    }
    catch (Exception e) {
      println(e);
    }
  }
  String[] keyFiles = getAllFilesFrom(dataPath("clefs"));
  for (String f : keyFiles) {
    try {
      PImage im = loadImage(f);
      if (im!=null) keys.add(im);
    }
    catch (Exception e) {
      println(e);
    }
  }
  String[] altFiles = getAllFilesFrom(dataPath("alterations"));
  for (String f : altFiles) {
    try {
      PImage im = loadImage(f);
      if (im!=null) alterations.add(im);
    }
    catch (Exception e) {
      println(e);
    }
  }
  titreIm = loadImage(dataPath("elements/titre.png"));
  MeasureBar startBar = new MeasureBar(2);
  measureBars.add(startBar);
}

void draw() {
  // update
  if (waving) shiftYTarget = map(sin((frameCount)/20.0),-1,1,100, height-staffHeight-100);
  if (continuousNotes) {
    if (frameCount%continuousNotesRate==0) {
      Note n = new Note();
      notes.add(n);
    }
  }
  for (int i = notes.size() - 1; i >= 0; i--) {
    Note n = notes.get(i);
    n.update();
    if (n.isOffScreen()) notes.remove(i);
  }
  for (int i = measureBars.size() - 1; i >= 0; i--) {
    MeasureBar m = measureBars.get(i);
    m.update();
    if (m.isOffScreen()) {
      if (m.type==1) staffActiveLeft = false;
      if (m.type==2) staffActiveLeft = true;
      measureBars.remove(i);
    }
  }

  shiftY = lerp(shiftY, shiftYTarget, 0.05f);

  if (adaptativeSpeed) {
    int countElements = notes.size()+measureBars.size();
    defaultSpeed = -(5+(float)countElements*2.0);
    for (Note n : notes) n.xSpeed = defaultSpeed;
    for (MeasureBar m : measureBars) m.xSpeed = defaultSpeed;
  }

  // draw
  background(bgColor);
  // Draw the staff
  pushMatrix();
  translate(0, shiftY);
  drawStaff();
  for (int i = measureBars.size() - 1; i >= 0; i--) measureBars.get(i).draw();
  for (int i = notes.size() - 1; i >= 0; i--) notes.get(i).draw();
  popMatrix();
  imageMode(CORNER);
  image(titreIm, 0, height-titreIm.height-0);
  if (dark) background(0);
}

void drawStaff() {
  stroke(0);
  strokeWeight(5);
  float currentX=0;
  boolean drawing = staffActiveLeft;
  while (currentX<width) {
    // find next event
    MeasureBar nextBar = null;
    for (MeasureBar m : measureBars) {
      if (m.x>currentX) {
        nextBar = m;
        break;
      }
    }
    if (nextBar!=null) {
      if (drawing) {
        // draw the lines
        for (int i = 0; i < numLines; i++) {
          float y = i * lineSpacing;
          line(currentX, y, nextBar.x, y);
        }
      }
      currentX = nextBar.x;
      if (nextBar.type==2) drawing = true;
      if (nextBar.type==1) drawing = false;
    } else {
      if (drawing && staffActiveRight) {
        // draw the lines
        for (int i = 0; i < numLines; i++) {
          float y = i * lineSpacing;
          line(currentX, y, width, y);
        }
      }
      currentX = width;
    }
  }
}

class Note {
  float x, y;
  float scale = 1.0;
  PImage imHead;
  boolean drawShafts = false;
  float xSpeed = defaultSpeed;
  float life = 0;
  float bounceFr = random(1, 3);
  float bounceAmp = random(0.1, 0.3);
  float bounceDuration = (float)frameRate/random(2.0, 5.0);
  int note;

  Note(PImage im, float x, float y) {
    if (im!=null) this.imHead = im;
    this.x = x;
    this.y = y;
    moveToQueue();
  }

  Note() {
    imHead = images.get(floor(random(images.size())));
    note = floor(random(-5, 14))+round(map(shiftY, 0, height-staffHeight, 5, -5));
    if (notes.size()>0) this.note = round(lerp(notes.get(floor(random(notes.size()))).note, this.note, random(random(1.2))));
    this.y = (float)note*lineSpacing/2;
    this.x = width-imHead.width/2-50;
    if (random(1)<0.1) {
      PImage chosenAlt = alterations.get(floor(random(alterations.size())));
      Note n = new Note(chosenAlt, x+imHead.width/2+chosenAlt.width/2, y);
      notes.add(n);
      this.x += chosenAlt.width;
    }
    moveToQueue();
  }

  void moveToQueue() {
    // move x right until it doesn't collide with any other note or measure bar
    while (true) {
      boolean collision = false;
      for (Note n : notes) {
        if (n==this) continue;
        // rectangle to rectangle collision
        if (n.x-n.imHead.width/2*n.scale<x+imHead.width/2*scale && n.x+n.imHead.width/2*n.scale>x-imHead.width/2*scale) {
          if (n.y-n.imHead.height/2*n.scale<y+imHead.height/2*scale && n.y+n.imHead.height/2*n.scale>y-imHead.height/2*scale) {
            collision = true;
            break;
          }
        }
      }
      for (MeasureBar m : measureBars) {
        // line to rectangle horizontal collision
        if (m.x<x+imHead.width/2*scale+mBarToNoteMargin && m.x>x-imHead.width/2*scale-mBarToNoteMargin) {
          collision = true;
          break;
        }
      }
      if (collision) x+=1;
      else break;
    }
  }

  void update() {
    x += xSpeed;
    life += 1;
  }

  void draw() {
    if (imHead!=null) {
      imageMode(CENTER);
      // bouncy effect
      float appearScale = (max(bounceDuration-life, 0)/bounceDuration)*sin(life/bounceFr)*bounceAmp+1.0;
      image(imHead, x, y, imHead.width*scale*appearScale, imHead.height*scale*appearScale);
    }
  }

  boolean isOffScreen() {
    return (x < -imHead.width*scale/2);
  }
}

class MeasureBar {
  float x;
  float xSpeed = defaultSpeed;

  int type = 0;
  //0 = normal
  //1 = end
  //2 = start

  MeasureBar(int type) {
    this.type = type;
    this.x = width;
    // move x right until it doesn't collide with any note within some margin
    while (true) {
      boolean collision = false;
      for (Note n : notes) {
        // line to rectangle horizontal collision
        if (n.x-n.imHead.width/2*n.scale-mBarToNoteMargin<x && n.x+n.imHead.width/2*n.scale+mBarToNoteMargin>x) {
          collision = true;
          break;
        }
      }
      if (collision) x+=1;
      else break;
    }
    if (type==2) {
      PImage chosenKey = keys.get(floor(random(keys.size())));
      Note n = new Note(chosenKey, x+chosenKey.width/2, staffHeight/2);
      notes.add(n);
      staffActiveRight = true;
    }
    if (type==1) {
      staffActiveRight = false;
    }
  }

  void update() {
    x += xSpeed;
  }

  void draw() {
    stroke(0);
    line(x, 0, x, staffHeight);
    if (type==1) {
      line(x-20, 0, x-20, staffHeight);
      noStroke();
      fill(0);
      rect(x, -2, 20, staffHeight+4);
    }
  }

  boolean isOffScreen() {
    return x < 0;
  }
}

void keyPressed() {
  if (keyCode!=BACKSPACE) if (dark) darkMode(false);
  if (keyCode==UP) {
    adaptativeSpeed = true;
    continuousNotesRate = 5;
  }
  if (keyCode==LEFT) {
    defaultSpeed *= 0.7f;
    for (Note n : notes) n.xSpeed *= 0.7f;
    for (MeasureBar m : measureBars) m.xSpeed *= 0.7f;
    continuousNotesRate = ceil(-100.0/defaultSpeed);
    adaptativeSpeed = false;
  }
  if (keyCode==RIGHT) {
    defaultSpeed /= 0.7f;
    for (Note n : notes) n.xSpeed /= 0.7f;
    for (MeasureBar m : measureBars) m.xSpeed /= 0.7f;
    continuousNotesRate = ceil(-100.0/defaultSpeed);
    adaptativeSpeed = false;
  }
  if (key=='f') {
    color newColor = bgColor;
    while (newColor==bgColor) {
      newColor = typicalColors[floor(random(typicalColors.length-1))+1];
    }
    bgColor = newColor;
  }
  if (key=='p') {
    waving = true;
  }
  if (keyCode==BACKSPACE) {
    darkMode(!dark);
  }
  if (key=='a') {
    Note n = new Note();
    notes.add(n);
  }
  if (key=='z') {
    measureBars.add(new MeasureBar(0));
  }
  if (key=='r') {
    measureBars.add(new MeasureBar(2));
  }
  if (key=='e') {
    measureBars.add(new MeasureBar(1));
  }
  if (key=='q') {
    continuousNotes = true;
  }
}

void keyReleased() {
  if (key=='q') {
    continuousNotes = false;
  }
  if (key=='p') {
    waving = false;
  }
}

void darkMode(boolean d) {
  dark = d;
  notes.clear();
  measureBars.clear();
  staffActiveLeft = false;
  MeasureBar startBar = new MeasureBar(2);
  measureBars.add(startBar);
}
