
PImage first;
PImage last;

FanzineMaker fanzineMaker;

float pixelsPerCm = 100;

PFont font;

ArrayList<String> linesList = new ArrayList<String>();

void setup() {
  size(500, 500);
  fanzineMaker = new FanzineMaker(2);
  font = loadFont(dataPath("files/GroteskRemix-Regular-100.vlw"));
  first = null;
  last = null;
  String[] lines = loadStrings(dataPath("files/list.txt"));
  for (int i=0; i<lines.length; i++) {
    linesList.add(lines[i]);
  }
}

void draw() {
}

void keyPressed() {
  shuffleStr(linesList);
  fanzineMaker.images.clear();
  fanzineMaker.orderedPages.clear();
  ArrayList<PImage> pages = new ArrayList<PImage>();
  pages.add(generatePage("Ce dessin est sur la première page de l'édition #"+nf(fanzineMaker.nbZinesMade, 6)));
  for (int i=0; pages.size()<fanzineMaker.nbPages; i++) {
    if (linesList.size()>0) pages.add(generatePage(linesList.get(i%linesList.size())));
  }
  fanzineMaker.load(first, last, pages);
  fanzineMaker.order();
  fanzineMaker.export();
}

float cmToPixels(float cm) {
  return cm*pixelsPerCm;
}

float pixelToCm(float px) {
  return px/pixelsPerCm;
}

// TODO apply that to every drawing thing so it exports the pdf nicely
/*
  
  dR.beginDraw();
  dR.pushMatrix();
  dR.noStroke();
  dR.fillCMYK(1, 0, 0, 0);
  dR.rect(0, 0, width, height);
  dR.fillCMYK(0, 0, 0, 1);
  dR.rect(20, 20, width-40, height-40);
  dR.fillCMYK(0, 1, 0, 0);
  dR.rect(40, 40, width-80, height-80);
  dR.popMatrix();
  dR.endDraw();
  dR.nextPage();
  dR.dispose();
  
  // draws on the screen
  image(dR.gra, 0, 0);
*/

PImage generatePage(String str) { 
  PGraphics thisPage = createGraphics(floor(cmToPixels(21)), floor(cmToPixels(29.7)), JAVA2D);
  thisPage.beginDraw();
  thisPage.textFont(font);
  thisPage.background(0xFF);
  thisPage.fill(0);
  thisPage.textAlign(LEFT);
  thisPage.textSize(100);
  thisPage.text("            "+str, 100, 150, thisPage.width-100*2-80, 5000);
  thisPage.noFill();
  thisPage.stroke(0);
  thisPage.strokeWeight(5);
  thisPage.endDraw();
  return thisPage.get();
}

void shuffleStr(ArrayList<String> in) {
  ArrayList<String> out = new ArrayList<String>();
  while (in.size()>0) out.add(in.remove(floor(random(in.size()))));
  for (int i=0; i<out.size(); i++) in.add(out.get(i));
}
