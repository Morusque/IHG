
ArrayList<PImage> images = new ArrayList<PImage>();
ArrayList<Sprite> sprites = new ArrayList<Sprite>();

int imgIndex = 0;

float cooldown = 2.0;// in seconds
float cooldownTimer = 0.5;

color[] typicalColors = new color[]{
  color(0),
  color(255),
  color(255, 223, 230), // rose pâle
  color(207, 57, 255), // violet
  color(0, 255, 161), // vert
  color(255, 74, 45), // rouge
  color(0, 247, 255), // bleu
  color(255, 243, 110)  // jaune
};

boolean dark = false;

// entrée = Invoque la prochaine image
// a = Images présentes out
// c = Effet chelou

ArrayList<CopyRectangle> copyRectangles = new ArrayList<CopyRectangle>();

void setup() {
  fullScreen();
  frameRate(50);
  String[] files = getAllFilesFrom(dataPath("elements"));
  files = sort(files);
  for (String f : files) {
    PImage im = loadImage(f);
    if (im!=null) images.add(im);
  }
  // instanciate sprites
  background(0xFF);
  image(loadImage(dataPath("files/degrade-pot-pourri.png")),0,0,width,height);
}

void draw() {

  // if a leaving sprite isn't visible 
  for (int i = sprites.size() - 1; i >= 0; i--) {
    if (!sprites.get(i).isVisible() && sprites.get(i).leaving) {
      sprites.remove(i);
    }
  }

  // update all sprites
  for (Sprite s : sprites) s.update();
  // draw
  for (Sprite s : sprites) s.draw();

  for (int i=copyRectangles.size()-1; i>=0; i--) {
    copyRectangles.get(i).draw();
    if (!copyRectangles.get(i).isVisible()) copyRectangles.remove(i);
  }

  if (dark) background(0);
}

class Sprite {
  PVector pos;
  PVector dir;
  PImage img;
  color haloColor;
  boolean arriving = true;
  boolean leaving = false;

  Sprite(PImage img) {
    this.img = img;
    int posCase = floor(random(4));
    pos = new PVector();
    if (posCase == 0) pos = new PVector(-img.width, random(height));
    if (posCase == 1) pos = new PVector(random(width), -img.height);
    if (posCase == 2) pos = new PVector(width+img.width, random(height));
    if (posCase == 3) pos = new PVector(random(width), height+img.height);
    // set the direction towards the center of the screen
    dir = new PVector(width/2, height/2);
    dir.sub(pos);
    dir.sub(img.width/2, img.height/2);
    dir.normalize();
    dir.mult(7);
    haloColor = typicalColors[floor(random(typicalColors.length))];
  }

  void update() {
    // make it bounce
    if (pos.x > width - img.width || pos.x < 0) {
      if (!leaving && !arriving) dir.x *= -1;
    }
    if (pos.y > height - img.height || pos.y < 0) {
      if (!leaving && !arriving) dir.y *= -1;
    }
    // if it's entirely visible, it's not arriving anymore
    if (pos.x > 0 && pos.x < width - img.width && pos.y > 0 && pos.y < height - img.height) {
      arriving = false;
    }
    pos.add(dir);
  }

  void draw() {
    // draw a blurred halo behind the picture
    /*
    fill(haloColor, 0x08);
    noStroke();
    for (int i = 0; i < 10; i++) {
      rect(pos.x - i, pos.y - i, img.width + 2 * i, img.height + 2 * i);
    }
    */
    // draw the picture
    image(img, pos.x, pos.y);
  }
  
  boolean isVisible() {
    if (pos.x>width) return false;
    if (pos.x+img.width<0) return false;
    if (pos.y>height) return false;
    if (pos.y+img.height<0) return false;
    return true;
  }
  
}

void keyPressed() {
  if (keyCode==BACKSPACE) {
    dark^=true;
    if (!dark) background(0xFF);
  }
  if (key=='c') {// smear
    for (int i=0; i<1; i++) addNewCopyRectangle();
  }
  if (keyCode==ENTER) {
    sprites.add(new Sprite(images.get(imgIndex)));
    imgIndex = (imgIndex + 1) % images.size();
  }
  if (key=='a') {
    for (Sprite s : sprites) s.leaving = true;
  }
}

void addNewCopyRectangle() {
  CopyRectangle r = new CopyRectangle();
  r.size = new PVector(round(random(50, 700)), round(random(50, 700)));
  r.a = new PVector(random(width-r.size.x), random(height-r.size.y));
  r.dirA = new PVector(random(-5, 5), random(-5, 5));
  r.strokeType = floor(random(2))+1;
  r.strokeLength = floor(random(2, random(2, 200)));
  r.diag = round(random(0, random(-20, 20)));
  copyRectangles.add(r);
}

class CopyRectangle {
  PVector a;
  PVector size;
  PVector dirA;
  int strokeType = 0;
  int strokeLength = 0;
  PImage grabbed;
  float diag = 0;
  void draw() {
    if (isVisible()) {
      grabbed = get(round(a.x), round(a.y), round(size.x), round(size.y));
    }
    a.add(dirA);
    a.x = round(a.x);
    a.y = round(a.y);
    if (grabbed!=null) image(grabbed, a.x, a.y, size.x, size.y);
  }
  boolean isVisible() {
    float margin = 130;
    return (a.x+size.x>=margin && a.x<=width-margin && a.y+size.y>=margin && a.y<=height-margin);
  }
}
