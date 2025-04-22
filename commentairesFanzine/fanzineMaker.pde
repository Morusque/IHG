
class FanzineMaker {
  ArrayList<PImage> images = new ArrayList<PImage>();
  ArrayList<PImage> orderedPages = new ArrayList<PImage>();
  PImage first;
  PImage last;
  int nbSaved = 0;
  int nbZinesMade = 0;
  ArrayList<Page> printedPages = new ArrayList<Page>();
  int nbPages;
  
  FanzineMaker(int preset) {
    try {
      nbZinesMade = getAllFilesFrom(dataPath("result")).length;
    }
    catch(Exception e) {
      println(e);
    }
    nbZinesMade += 33;// already made offset
    if (preset==0) {
      PVector printingSize = new PVector(840*2, 1188*2);
      nbPages = 16;
      printedPages.add(new Page(printingSize, new int[][]{{15, 8}, {0, 7}}, new int[][]{{0, 2}, {0, 2}}));
      printedPages.add(new Page(printingSize, new int[][]{{1, 6}, {14, 9}}, new int[][]{{0, 2}, {0, 2}}));
      printedPages.add(new Page(printingSize, new int[][]{{13, 10}, {2, 5}}, new int[][]{{0, 2}, {0, 2}}));
      printedPages.add(new Page(printingSize, new int[][]{{3, 4}, {12, 11}}, new int[][]{{0, 2}, {0, 2}}));
    }
    if (preset==1) {
      // PVector printingSize = new PVector(840*2, 1188*2);
      PVector printingSize = new PVector(cmToPixels(21), cmToPixels(29.7));
      nbPages = 24;
      printedPages.add(new Page(printingSize, new int[][]{{12, 15}, {11, 8}}, new int[][]{{2, 0}, {2, 0}}));
      printedPages.add(new Page(printingSize, new int[][]{{10, 9}, {13, 14}}, new int[][]{{2, 0}, {2, 0}}));
      printedPages.add(new Page(printingSize, new int[][]{{16, 19}, {7, 4}}, new int[][]{{2, 0}, {2, 0}}));
      printedPages.add(new Page(printingSize, new int[][]{{6, 5}, {17, 18}}, new int[][]{{2, 0}, {2, 0}}));
      printedPages.add(new Page(printingSize, new int[][]{{20, 23}, {3, 0}}, new int[][]{{2, 0}, {2, 0}}));
      printedPages.add(new Page(printingSize, new int[][]{{2, 1}, {21, 22}}, new int[][]{{2, 0}, {2, 0}}));
    }
    if (preset==2) {
      PVector printingSize = new PVector(cmToPixels(21), cmToPixels(29.7));
      nbPages = 24;
      printedPages.add(new Page(printingSize, new int[][]{{23, 12}, {0, 11}}, new int[][]{{0, 2}, {0, 2}}));
      printedPages.add(new Page(printingSize, new int[][]{{1, 10}, {22, 13}}, new int[][]{{0, 2}, {0, 2}}));
      printedPages.add(new Page(printingSize, new int[][]{{21, 14}, {2, 9}}, new int[][]{{0, 2}, {0, 2}}));
      printedPages.add(new Page(printingSize, new int[][]{{3, 8}, {20, 15}}, new int[][]{{0, 2}, {0, 2}}));
      printedPages.add(new Page(printingSize, new int[][]{{19, 16}, {4, 7}}, new int[][]{{0, 2}, {0, 2}}));
      printedPages.add(new Page(printingSize, new int[][]{{5, 6}, {18, 17}}, new int[][]{{0, 2}, {0, 2}}));
    }    
  }

  void load(PImage first, PImage last, ArrayList<PImage> images) {
    println("loading...");
    this.first=first;
    this.last=last;
    this.images=images;
    println("... done");
  }

  void order() {
    println("ordering...");
    orderedPages.clear();
    for (int i=0;i<images.size();i++) orderedPages.add(images.get(i));
    PGraphics blank = createGraphics(50, 50, JAVA2D);
    blank.beginDraw();
    blank.background(0xFF);
    blank.endDraw();
    while (orderedPages.size() < nbPages) orderedPages.add(blank.get());
    println("... done");
  }

  void export() {
    println("exporting...");
    nbSaved=0;
    for (Page p : printedPages) p.export(orderedPages, dataPath("result/"+nf(nbZinesMade, 4)+"/"+nf(nbSaved++, 4)+".png"));
    nbZinesMade++;
    println("... done");
  }
}

ArrayList<PImage> shuffle(ArrayList<PImage> in) {
  ArrayList<PImage> copy = new ArrayList<PImage>();
  for (PImage i : in) copy.add(i);
  ArrayList<PImage> out = new ArrayList<PImage>();
  while (copy.size()>0) {
    PImage rndIm = copy.remove(floor(random(copy.size())));
    out.add(rndIm);
  }
  return out;
}

class Page {
  PVector size;
  int divX;
  int divY;
  int[][] imId;
  int[][] rotations;
  Page(PVector size, int[][] imId, int[][] rotations) {
    this.size=size;
    divY=imId.length;
    divX=imId[0].length;
    this.imId=imId;
    this.rotations=rotations;
  }
  void export(ArrayList<PImage> images, String fileName) {
    PGraphics page = createGraphics(floor(size.x), floor(size.y));
    page.beginDraw();
    for (int y=0; y<divY; y++) {
      for (int x=0; x<divX; x++) {
        PImage thisIm = images.get(imId[x][y]);
        page.pushMatrix();
        page.translate((size.x/divX)/2+x*size.x/divX, (size.y/divY)/2+y*size.y/divY);
        page.rotate(rotations[x][y]*HALF_PI);
        page.translate(-(size.x/divX)/2, -(size.y/divY)/2);
        page.image(thisIm, 0, 0, size.x/divX, size.y/divY);
        page.popMatrix();
      }
    }
    page.endDraw();
    page.save(fileName);
  }
}
