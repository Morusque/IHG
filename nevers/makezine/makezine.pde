
import processing.pdf.*;

ArrayList<PageWithAlts> pages = new ArrayList<PageWithAlts>();

int nbZinesMade = 0;

PFont font;

void setup() {
  size(500, 500);
  for (int i=0; i<4; i++) pages.add(new PageWithAlts());
  font = loadFont(dataPath("files/HelveticaNeue-Medium-48.vlw"));
  println("check dossier : tournoi gagnant");
  pages.get(0).addFromFolder(dataPath("../../strips/data/result/winner/"));// tournoi gagnant
  println("check dossier : tournoi random");
  pages.get(1).addFromFolder(dataPath("../../strips/data/result/va"));// tournoi random
  println("check dossier : trois éléments");
  pages.get(2).addFromFolder(dataPath("files/page01/"));// trois éléments
  println("check dossier : quantités");
  pages.get(3).addFromFolder(dataPath("../../accessoires/data/result/"));// strips quantités
  for (int i=0; i<pages.get(3).images.size(); i++) {
    PImage im = pages.get(3).images.get(i);
    im = im.get(floor(620+1240*1.0/30.0), floor(0+im.height*1.0/30.0), floor(1240*28.0/30.0), floor(im.height*28.0/30.0));
    im.loadPixels();// nettoyer les pixels bleus
    color target = color(0xFF9FE7F3); // bleu
    float targetThresh = 100;
    float blackThresh = 80;
    for (int j = 0; j < im.pixels.length; j++) {
      color c = im.pixels[j];
      float dTarget = dist(red(c), green(c), blue(c), red(target), green(target), blue(target));
      float dBlack = dist(red(c), green(c), blue(c), 0, 0, 0);
      if (dTarget < targetThresh && dBlack > blackThresh) {
        im.pixels[j] = color(255);
      }
    }
    im.updatePixels();
    pages.get(3).images.set(i, im);
  }
  println("ready");
}

void draw() {
}

int nbZinesToGenerateAtOnce = 5;
void keyPressed() {
  for (int i=0; i<nbZinesToGenerateAtOnce; i++) generate();
}

void generate() {
  println("generating...");
  PGraphicsPDF pdf = (PGraphicsPDF) createGraphics(2100, 2970, PDF, dataPath("result/"+nf(nbZinesMade, 4))+"/print_"+nf(nbZinesMade, 4)+".pdf");
  pdf.beginDraw();
  PGraphics grP1 = createGraphics(2100, 2970);
  grP1.beginDraw();
  grP1.background(0xFF);
  grP1.image(pages.get(0).nextImage(), 0, 0, 2100/2, 2970);
  grP1.image(pages.get(1).nextImage(), 2100/2, 0, 2100/2, 2970);
  grP1.fill(0);
  grP1.textSize(48);
  grP1.textFont(font);
  grP1.text("2", 2100*1/4, 2900);
  grP1.text("3", 2100*3/4, 2900);
  grP1.endDraw();
  grP1.save(dataPath("result/"+nf(nbZinesMade, 4)+"/01.png"));
  pdf.image(grP1.get(), 0, 0);
  pdf.nextPage();
  PGraphics grP2 = createGraphics(2100, 2970);
  grP2.beginDraw();
  grP2.background(0xFF);
  grP2.image(pages.get(3).nextImage(), 0, 0, 2100/2, 2970);
  grP2.image(pages.get(2).nextImage(), 2100/2, 0, 2100/2, 2970);
  grP2.fill(0);
  grP2.textSize(48);
  grP2.textFont(font);
  grP2.text("4", 2100*1/4, 2900);
  grP2.text("1", 2100*3/4, 2900);
  grP2.endDraw();
  grP2.save(dataPath("result/"+nf(nbZinesMade, 4)+"/02.png"));
  pdf.image(grP2.get(), 0, 0);
  pdf.dispose();
  pdf.endDraw();
  nbZinesMade++;
  println(nbZinesMade);
  println("done");
}

class PageWithAlts {
  ArrayList<PImage> images = new ArrayList<PImage>();
  ArrayList<Integer> order = new ArrayList<Integer>();
  int currentIndex=0;
  PageWithAlts() {
  }
  void addFromFolder(String folder) {
    String[] fs = getAllFilesFrom(folder);
    for (String f : fs) images.add(loadImage(f));
    shuffleOrder();
  }
  void shuffleOrder() {
    ArrayList<Integer> origOrder = new ArrayList<Integer>();
    for (int i=0; i<images.size(); i++) origOrder.add(i);
    order.clear();
    while (origOrder.size()>0) order.add(origOrder.remove(floor(random(origOrder.size()))));
    currentIndex=0;
  }
  PImage nextImage() {
    if (order.size()>0) {
      PImage thisImage = images.get(order.get(currentIndex));
      currentIndex++;
      if (currentIndex>=images.size()) shuffleOrder();
      return thisImage;
    } else {
      return createImage(100, 100, RGB);
    }
  }
}
