
FanzineMaker fanzineMaker = new FanzineMaker(1);

void setup() {
  size(500, 500);
}

void draw() {
}

void keyPressed() {
  if (keyCode==76) {// l
    PImage first=loadImage(dataPath("files/first.png"));// la page de couverture
    PImage last=loadImage(dataPath("files/last.png"));// la dernière page
    String[] files = getAllFilesFrom("../../07");// le dossier des pages à l'intérieur
    ArrayList<PImage> images = new ArrayList<PImage>();
    for (String f : files) images.add(loadImage(f));
    fanzineMaker.load(first, last, images);
  }
  if (keyCode==69) {// e
    fanzineMaker.order();
    fanzineMaker.export();
  }
}
