
PImage orig;
ArrayList<String> doneUrls = new ArrayList<String>();
ArrayList<Panel> panels = new ArrayList<Panel>();
int nbExported = 0;

void setup() {
  size(800, 800);
  orig = loadImage(dataPath("orig/orig.png"));
  surface.setResizable(true);
  panels.add(new Panel(200, 533, 770, 1160));
  panels.add(new Panel(993, 533, 1325, 1165));
  panels.add(new Panel(200, 1713, 1430, 1170));
  panels.add(new Panel(1653, 1721, 657, 1161));
  /*
  panels.add(new Panel(135, 511, 797, 1205));
   panels.add(new Panel(989, 511, 1377, 1205));
   panels.add(new Panel(135, 1780, 1495, 1209));
   panels.add(new Panel(1701, 1780, 659, 1209));
   */
}

void draw() {
  float scale = min((float)width/orig.width, (float)height/orig.height);
  scale *= 1.3;
  scale(scale);
  translate(0,-300);
  image(orig, 0, 0);
  background(0xFF);
  for (int j=0; j<panels.size(); j++) {
    if (panels.get(j).currentIndex>=0) image(panels.get(j).alts.get(panels.get(j).currentIndex), panels.get(j).pos.x, panels.get(j).pos.y);
  }
  if (frameCount%100==0) for (int j=0; j<panels.size(); j++) panels.get(j).shuffleIndexes();
}

void keyPressed() {
  if (keyCode == CONTROL) {
    println("loading...");
    String[] inputUrl = getAllFilesFrom(dataPath("input"));
    for (int i=0; i<inputUrl.length; i++) {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println("file : "+inputUrl[i]);
        PImage im = loadImage(inputUrl[i]);
        int bestIndex = -1;
        double bestFilling = -1;
        for (int j=0; j<panels.size(); j++) {
          Panel thisPanel = panels.get(j);
          PImage thisCut = im.get(floor(thisPanel.pos.x), floor(thisPanel.pos.y), floor(thisPanel.siz.x), floor(thisPanel.siz.y));
          double thisFilling = 0;
          for (int x=0; x<thisCut.width; x++) {
            for (int y=0; y<thisCut.height; y++) {
              thisFilling += ((double)brightness(thisCut.get(x, y)))/0x100;
            }
          }
          thisFilling /= (thisCut.width*thisCut.height);
          if (thisFilling<bestFilling || bestFilling==-1) {
            bestFilling = thisFilling;
            bestIndex = j;
          }
        }
        Panel thisPanel = panels.get(bestIndex);
        thisPanel.alts.add(im.get(floor(thisPanel.pos.x), floor(thisPanel.pos.y), floor(thisPanel.siz.x), floor(thisPanel.siz.y)));
        doneUrls.add(inputUrl[i]);
      }
    }
    println("...done");
  }
  if (keyCode == RIGHT) {
    for (int j=0; j<panels.size(); j++) panels.get(j).shuffleIndexes();
  }
  if (keyCode == LEFT) {
    for (int j=0; j<panels.size(); j++) panels.get(j).currentIndex = -1;
  }
  if (keyCode == TAB) {
    save(dataPath("result"+nf(nbExported++,4)+".png"));
  }
}

class Panel {
  PVector pos;
  PVector siz;
  ArrayList<PImage> alts = new ArrayList<PImage>();
  int currentIndex = -1;
  Panel(float x, float y, float w, float h) {
    pos = new PVector(x, y);
    siz = new PVector(w, h);
  }
  void shuffleIndexes() {
    if (alts.size()>0) currentIndex = floor(random(alts.size()));
  }
}
