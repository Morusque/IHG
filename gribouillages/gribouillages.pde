
ArrayList<PImage> bases = new ArrayList<PImage>(); 
ArrayList<PImage> images = new ArrayList<PImage>(); 
ArrayList<String> doneUrls = new ArrayList<String>();

int nbSaved = 0;

void setup() {
  size(1200, 900);
  frameRate(50);
  String[] inputUrl = getAllFilesFrom(dataPath("files"));
  for (String f : inputUrl) bases.add(loadImage(f));
}

void draw() {
  if (frameCount%100==1) {
    generate();
  }
}

void keyPressed() {
  if (keyCode==CONTROL) {
    println("loading...");
    String[] inputUrl = getAllFilesFrom(dataPath("input"));
    for (int i=0; i<inputUrl.length; i++) {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        images.add(loadImage(inputUrl[i]));
        doneUrls.add(inputUrl[i]);
      }
    }
    println("...done");
  }
  if (keyCode==TAB) {
    save(dataPath("result/"+nf(nbSaved++, 4)+".png"));
  }
}

void generate() {
  if (bases.size()>0) image(bases.get(floor(random(bases.size()))), 0, 0, width, height);
  if (images.size()>0) {
    PImage im = images.get(floor(random(images.size())));
    blend(im, 0, 0, im.width, im.height, 0, 0, width, height, MULTIPLY);
  }
}