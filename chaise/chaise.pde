
ArrayList<String> doneUrls = new ArrayList<String>();
ArrayList<PImage> images = new ArrayList<PImage>();

PImage[] currentImages = new PImage[4];

boolean chosenOnce = false;

int nbExported=0;

void setup() {
  size(700, 900);
  for (int i=0; i<currentImages.length; i++) currentImages[i] = createImage(100, 100, RGB);
}

void draw() {
  background(0xFF);
  if (chosenOnce) {
    scale(0.8);
    float yDistance = 250;
    image(currentImages[0].get(50, 50, 733-50, 264), 0, yDistance*0);
    image(currentImages[1].get(50, 318, 733-50, 264), 0, yDistance*1);
    image(currentImages[2].get(50, 596, 733-50, 264), 0, yDistance*2);
    image(currentImages[3].get(50, 863, 733-50, 264), 0, yDistance*3);
  }
}

void keyPressed() {
  if (keyCode == CONTROL) {
    println("loading...");
    String[] inputUrl = getAllFilesFrom(dataPath("input"));
    for (int i=0; i<inputUrl.length; i++) {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println("file : "+inputUrl[i]);
        PImage im = loadImage(inputUrl[i]);
        images.add(im.get());
        doneUrls.add(inputUrl[i]);
      }
    }
    println("...done");
  }
  if (keyCode == 'A') {
    for (int i=0; i<currentImages.length; i++) currentImages[i] = images.get(floor(random(images.size())));
    chosenOnce = true;
  }
  if (keyCode == TAB) {
    save(dataPath("result/"+nf(nbExported++, 4)+".png"));
  }
}
