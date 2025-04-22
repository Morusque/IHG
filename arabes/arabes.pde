
ArrayList<String> doneUrls = new ArrayList<String>();
ArrayList<PImage> images = new ArrayList<PImage>();

void setup() {
  size(1000, 800);
  // frameRate(0.5);
  frameRate(5);
}

void draw() {
  background(0xFF);
  imageMode(CENTER);
  if (images.size()>0) {
    PImage currentImage = images.get(frameCount%images.size());
    float scale = 1.0f;
    image(currentImage, width/2, height/2, currentImage.width*scale, currentImage.height*scale);
  }
  // saveFrame("####.png");
}

void keyPressed() {
  if (keyCode == CONTROL) {
    println("loading...");
    String[] inputUrl = getAllFilesFrom(dataPath("input"));
    inputUrl = sort(inputUrl);
    for (int i=0; i<inputUrl.length; i++) {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println("file : "+inputUrl[i]);
        PImage im = loadImage(inputUrl[i]);
        images.add(im.get(649, 495, 1063, 651));
        doneUrls.add(inputUrl[i]);
      }
    }
    println("...done");
  }
}
