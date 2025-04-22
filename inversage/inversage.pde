
ArrayList<PImage> images = new ArrayList<PImage>(); 
ArrayList<String> doneUrls = new ArrayList<String>();

void setup() {
  size(1200, 900);
  frameRate(50);
  background(0xFF);
}

void draw() {
  if (frameCount%100==1) {
    if (images.size()>0) {
      background(0xFF);
      PImage im = images.get(floor(random(images.size())));
      blend(im, 0, 0, im.width, im.height, 0, 0, width, height, SUBTRACT);
    }
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