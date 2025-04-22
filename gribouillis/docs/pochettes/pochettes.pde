
ArrayList<String> doneUrls = new ArrayList<String>();
ArrayList<PImage> images = new ArrayList<PImage>();

void setup() {
  size(1000, 800);
}

void draw() {
}

void keyPressed() {
  if (keyCode == CONTROL) {
    println("loading...");
    String[] inputUrl = getAllFilesFrom(dataPath("input"));
    for (int i=0; i<inputUrl.length; i++) {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println("file : "+inputUrl[i]);
        PImage im = loadImage(inputUrl[i]);
        PImage im2 = process(im);
        images.add(im2.get());
        im2.save(dataPath("result/"+nf(i, 4)+".png"));
        doneUrls.add(inputUrl[i]);
      }
    }
    println("...done");
  }
}

PImage process(PImage im) {
  PImage im2 = im.get(60, 137, 390, 390);
  int nbBoxes = 4;
  int darkerBoxIndex = -1;
  float darkThreshold = 80;
  float darkerBoxDarkness = -1;
  boolean[] checked = new boolean[nbBoxes];
  for (int i=0; i<4; i++) {
    checked[i] = false;
    PImage thisBox = im.get(522, 168+63*i, 42, 42);
    float thisDarkness = 0;
    for (int x=0; x<thisBox.width; x++) {
      for (int y=0; y<thisBox.height; y++) {
        thisDarkness+=0xFF-brightness(thisBox.get(x, y));
      }
    }
    thisDarkness/=(thisBox.width*thisBox.height);
    if (thisDarkness>darkThreshold) {
      checked[i] = true;
      if (thisDarkness>darkerBoxDarkness) {
        darkerBoxIndex = i;
        darkerBoxDarkness = thisDarkness;
      }
    }
  }
  if (checked[0]) {
    for (int x=0; x<im2.width; x++) {
      for (int y=0; y<im2.height; y++) {
        color c = im2.get(x, y);
        c = blendColor(c, color(0xFF, 0, 0, 0x80), DARKEST);
        im2.set(x, y, c);
      }
    }
  }
  if (checked[1]) {
    for (int x=0; x<im2.width; x++) {
      for (int y=0; y<im2.height; y++) {
        color c = im2.get(x, y);
        c = blendColor(c, color(0, 0xFF, 0, 0x80), DARKEST);
        im2.set(x, y, c);
      }
    }
  }
  if (checked[2]) {
    for (int x=0; x<im2.width; x++) {
      for (int y=0; y<im2.height; y++) {
        color c = im2.get(x, y);
        c = blendColor(c, color(0, 0, 0xFF, 0x80), DARKEST);
        im2.set(x, y, c);
      }
    }
  }
  if (checked[3]) {
    im2.filter(BLUR, 6);
  }
  return im2;
}
