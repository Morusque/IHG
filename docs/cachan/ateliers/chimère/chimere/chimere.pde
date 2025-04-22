
ArrayList<PImage> images = new ArrayList<PImage>(); 
ArrayList<String> doneUrls = new ArrayList<String>();

void setup() {
  size(1200, 900);
  frameRate(50);
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
}

void generate() {
  background(0);
  if (images.size()>0) {
    image(images.get(floor(random(images.size()))),0,0,width,height);
    int nbPatches = 10;
    for (int i=0;i<nbPatches;i++) {
      PVector pos = new PVector(random(1),random(1));
      PVector size = new PVector(random(0.1,0.2),random(0.1,0.2));
      PImage randomIm = images.get(floor(random(images.size())));
      copy(randomIm, floor(pos.x*randomIm.width),floor(pos.y*randomIm.height),floor(size.x*randomIm.width),floor(size.y*randomIm.height),floor(pos.x*width),floor(pos.y*height),floor(size.x*width),floor(size.y*height));
    }
  }
}