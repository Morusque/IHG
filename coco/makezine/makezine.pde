
import processing.pdf.*;

ArrayList<PageWithAlts> pages = new ArrayList<PageWithAlts>();

int nbZinesMade = 0;

PFont font;

void setup() {
  size(500, 500);
  for (int i=0; i<8; i++) pages.add(new PageWithAlts());
  font = loadFont(dataPath("files/HelveticaNeue-30.vlw"));
  println("a");
  pages.get(0).addFromFolder(dataPath("files/page00"));
  println("b");
  pages.get(1).addFromFolder(dataPath("files/page01"));
  println("c");
  pages.get(2).addFromFolder(dataPath("files/page02"));
  println("d");
  pages.get(3).addFromFolder(dataPath("../../evolvingComic/data/result"));
  println("e");
  pages.get(4).addFromFolder(dataPath("files/page05"));
  println("f");
  pages.get(5).addFromFolder(dataPath("../../placealea/data/scan/cropped"));
  println("ready");
}

void draw() {
}

void keyPressed() {
  for (int i=0;i<70;i++) generate();
}

void generate() {
  println("generating...");
  PGraphicsPDF pdf = (PGraphicsPDF) createGraphics(2970, 2100, PDF, dataPath("result/"+nf(nbZinesMade, 4))+"/print_"+nf(nbZinesMade, 4)+".pdf");
  pdf.beginDraw();
  PGraphics grP1 = createGraphics(2970, 2100);
  grP1.beginDraw();
  grP1.background(0xFF);
  grP1.image(pages.get(5).nextImage(), 0, 0, 2970/2, 2100);
  grP1.image(pages.get(0).nextImage(), 2970/2, 0, 2970/2, 2100);
  grP1.fill(0);
  grP1.textSize(30);
  grP1.textFont(font);
  grP1.text("8",2970/4,2080);
  grP1.text("1",2970*3/4,2080);
  grP1.endDraw();
  grP1.save(dataPath("result/"+nf(nbZinesMade, 4)+"/01.png"));
  pdf.image(grP1.get(), 0, 0);
  pdf.nextPage();
  PGraphics grP2 = createGraphics(2970, 2100);
  grP2.beginDraw();
  grP2.background(0xFF);
  grP2.image(pages.get(1).nextImage(), 0, 0, 2970/2, 2100);
  grP2.image(pages.get(5).nextImage(), 2970/2, 0, 2970/2, 2100);
  grP2.fill(0);
  grP2.textSize(30);
  grP2.textFont(font);
  grP2.text("2",2970/4,2080);
  grP2.text("7",2970*3/4,2080);
  grP2.endDraw();
  grP2.save(dataPath("result/"+nf(nbZinesMade, 4)+"/02.png"));
  pdf.image(grP2.get(), 0, 0);
  pdf.nextPage();
  PGraphics grP3 = createGraphics(2970, 2100);
  grP3.beginDraw();
  grP3.background(0xFF);
  grP3.image(pages.get(4).nextImage(), 0 + 30, 0 + 30, 2970/2 - 60, 2100 - 60);
  grP3.image(pages.get(2).nextImage(), 2970/2, 0, 2970/2, 2100);
  grP3.fill(0);
  grP3.textSize(30);
  grP3.textFont(font);  
  grP3.text("6",2970/4,2080);
  grP3.text("3",2970*3/4,2080);
  grP3.endDraw();
  grP3.save(dataPath("result/"+nf(nbZinesMade, 4)+"/03.png"));
  pdf.image(grP3.get(), 0, 0);
  pdf.nextPage();
  PGraphics grP4 = createGraphics(2970, 2100);
  grP4.beginDraw();
  grP4.background(0xFF);
  grP4.image(pages.get(3).nextImage(), 30, 30, 2970/2 - 60, 2100 - 60);
  grP4.image(pages.get(3).nextImage(), 2970/2 + 30, 0 + 30, 2970/2 - 60, 2100 - 60);
  grP4.fill(0);
  grP4.textSize(30);
  grP4.textFont(font);  
  grP4.text("4",2970/4,2080);
  grP4.text("5",2970*3/4,2080);
  grP4.endDraw();
  grP4.save(dataPath("result/"+nf(nbZinesMade, 4)+"/04.png"));
  pdf.image(grP4.get(), 0, 0);
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
