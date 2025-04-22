
int currentIndex = 0;
PImage im;

boolean hideText = true;

boolean auto = false;

void setup() {
  size(656, 927);
  noStroke();
  fill(0xFF);
}

void draw() {
  background(0xFF);
  if (im!=null) image(im, 0, 0, width, height);
  if (hideText) {
    rect(0, 0, width, height*1/7);
  }
  if (auto && (frameCount%60==0)) {
    String[] inputUrl = getAllFilesFrom(dataPath("input"));
    currentIndex = floor(random(inputUrl.length));
    im = loadImage(inputUrl[currentIndex]);
  }
}

void keyPressed() {
  if (keyCode==CONTROL) {
    String[] inputUrl = getAllFilesFrom(dataPath("input"));
    currentIndex = floor(random(inputUrl.length));
    im = loadImage(inputUrl[currentIndex]);
    println("new pic loaded");
  }
  if (keyCode==ENTER) {
    hideText ^= true;
    println("comments displayed : "+hideText);
  }
  if (keyCode==RIGHT) {
    auto ^= true;
    println("auto display : "+auto);
  }
  if (keyCode==LEFT) {
    String[] inputUrl = getAllFilesFrom(dataPath("input"));
    currentIndex = (currentIndex+1)%inputUrl.length;
    im = loadImage(inputUrl[currentIndex]);
  }
}
