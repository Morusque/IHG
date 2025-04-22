
ArrayList<String> doneUrls = new ArrayList<String>();
ArrayList<Compo> compos = new ArrayList<Compo>();

int currentCompo = -1;

int currentX=0;
int currentY=0;

int nbSX = 7;
int nbSY = 5;

void setup() {
  size(1000, 800);
}

void draw() {
  // update
  if (compos.size()>0 && random(1)<0.1f) currentCompo = (currentCompo+1)%compos.size();
  if (random(1)<0.5f) {
    if (random(1)<0.5f) currentX = (currentX+1)%nbSX;
    else currentX = (currentX-1+nbSX)%nbSX;
  } else {
    if (random(1)<0.5f) currentY = (currentY+1)%nbSY;
    else currentY = (currentY-1+nbSY)%nbSY;
  }

  // draw
  if (random(1)<0.1f) background(0);
  if (currentCompo>=0) compos.get(currentCompo).drawPart(currentX, currentY);
}

void keyPressed() {
  if (keyCode == CONTROL) {
    println("loading...");
    String[] inputUrl = getAllFilesFrom(dataPath("input"));
    for (int i=0; i<inputUrl.length; i++) {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println("file : "+inputUrl[i]);
        PImage im = loadImage(inputUrl[i]);
        Compo newCompo = new Compo();
        newCompo.processImage(im.get());
        compos.add(newCompo);
        doneUrls.add(inputUrl[i]);
      }
    }
    println("...done");
  }
}

class Compo {
  PImage[][] parts = new PImage[nbSX][nbSY];
  Compo() {
  }
  void processImage(PImage totalIm) {
    PVector offset = new PVector(96, 112);
    PVector size = new PVector(180, 176);
    for (int x=0; x<nbSX; x++) {
      for (int y=0; y<nbSY; y++) {
        PImage thisIm = totalIm.get(floor(offset.x+size.x*x), floor(offset.y+size.y*y), floor(size.x), floor(size.y));
        parts[x][y] = thisIm;
      }
    }
  }
  void drawPart(int x, int y) {
    image(parts[x][y], (float)width*x/nbSX, (float)height*y/nbSY, (float)width/nbSX, (float)height/nbSY);
  }
  void drawEntire() {
    for (int x=0; x<nbSX; x++) {
      for (int y=0; y<nbSY; y++) {
        if (random(1)<0.5f) drawPart(x, y);
      }
    }
  }
}
