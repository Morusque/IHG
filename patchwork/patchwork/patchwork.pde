
ArrayList<PImage> images = new ArrayList<PImage>();
ArrayList<String> doneUrls = new ArrayList<String>();

void setup() {
  size(1200, 900);
  frameRate(50);
}

void draw() {
  if (frameCount%100==0) {
    generate();
  }
}

void keyPressed() {
  if (keyCode==CONTROL) {
    println("loading...");
    String[] inputUrl = getAllFilesFrom(dataPath("input"));
    for (int i=0; i<inputUrl.length; i++) {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        images.add(loadImage(inputUrl[i]).get(349, 468, 1637, 685));
        doneUrls.add(inputUrl[i]);
      }
    }
    println("...done");
  }
}

void generate() {
  background(0);
  rectangle(0, 0, width, height, 0);
}

void rectangle(float x, float y, float w, float h, int r) {
  int mode = floor(random(3));
  if (r==0) mode = 1 + floor(random(2));
  if (r>10) mode = 0;
  if (mode==0) {
    if (images.size()>0) {
      if (w>=h) {
        image(images.get(floor(random(images.size()))), x, y, w, h);
      } else {
        pushMatrix();
        translate(x, y);
        rotate(-HALF_PI);
        image(images.get(floor(random(images.size()))), -h, 0, h, w);
        popMatrix();
        /*
        stroke(0xFF, 0, 0);
        noFill();
        rect(x, y, w, h);
        */
      }
    }
  }
  if (mode==1) {
    rectangle(x, y, w/2, h, r+1);
    rectangle(x+w/2, y, w/2, h, r+1);
  }
  if (mode==2) {
    rectangle(x, y, w, h/2, r+1);
    rectangle(x, y+h/2, w, h/2, r+1);
  }
}