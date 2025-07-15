
ArrayList<String> doneUrls = new ArrayList<String>();
ArrayList<PImage> images = new ArrayList<PImage>();

PImage placeMask;

int nbExported = 0;

int currentStickerIndex = 0;

void setup() {
  // fullScreen();
  size(800,600);
  placeMask = loadImage(dataPath("files/placeMask.png"));
  background(0xFF);
  smooth();
}

void draw() {
}

void keyPressed() {
  if (keyCode == CONTROL) {
    println("loading...");
    String[] inputUrl = getAllFilesFrom(dataPath("../../accessoires/data/input"));
    for (int i=0; i<inputUrl.length; i++) {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println("file : "+inputUrl[i]);
        PImage im = loadImage(inputUrl[i]).get(847-40, 355-40, 800+80, 800+80);
        // im = cutShape(im);
        images.add(im.get());
        doneUrls.add(inputUrl[i]);
      }
    }
    println("...done");
  }
  if (keyCode == ENTER || keyCode == RETURN) {
    println("generating...");
    generate();
    println("...generated");
  }
}

void generate() {

  int maxSeeds = 3500;
  float brightnessThreshold = 200;
  float initialRadius = 2;
  float growthStep = 0.5;
  float collisionTolerance = 70;
  int growthIterations = 500;

  ArrayList<Sticker> stickers = new ArrayList<Sticker>();

  PImage img = cutShape(images.get((currentStickerIndex++%images.size())));

  // échantillonnage aléatoire dans les zones claires du masque
  for (int i = 0; i < maxSeeds; i++) {
    float x = random(placeMask.width);
    float y = random(placeMask.height);
    if (brightness(placeMask.get(round(x), round(y))) > brightnessThreshold) {
      float angle = random(TWO_PI);
      stickers.add(new Sticker(new PVector(x, y), initialRadius, angle, img));
    }
  }

  // croissance progressive des stickers
  for (int step = 0; step < growthIterations; step++) {
    for (int i = 0; i < stickers.size(); i++) {
      Sticker s = stickers.get(i);
      if (!s.growing) continue;

      s.radius += growthStep;

      // arrêt si contact avec zone sombre du masque
      if (s.touchesMask(placeMask, brightnessThreshold)) {
        s.radius -= growthStep;
        s.growing = false;
        continue;
      }

      // arrêt si trop proche d'un autre sticker
      /*
      for (int j = 0; j < stickers.size(); j++) {
       if (i == j) continue;
       Sticker o = stickers.get(j);
       if (s.isColliding(o, collisionTolerance)) {
       s.radius -= growthStep;
       s.growing = false;
       break;
       }
       }
       */
    }
  }

  // rendu final
  PGraphics canvas = createGraphics(placeMask.width, placeMask.height, JAVA2D);
  canvas.beginDraw();
  canvas.background(255);
  canvas.imageMode(CENTER);

  for (Sticker s : stickers) {
    if (s.radius<35) continue;
    canvas.pushMatrix();
    canvas.translate(s.pos.x, s.pos.y);
    canvas.rotate(s.angle);
    float scaleFactor = s.radius * 2.0 / max(s.img.width, s.img.height);
    canvas.scale(scaleFactor);
    canvas.image(s.img, 0, 0);
    canvas.popMatrix();
  }

  float stickerDiagonal = dist(0, 0, img.width, img.height);
  float soloScale = 500.0 / stickerDiagonal;
  canvas.image(img, canvas.width*1/4, canvas.height/2, img.width*soloScale, img.height*soloScale);

  canvas.endDraw();
  canvas.save(dataPath("result/tas_" + nf(nbExported++, 4) + ".png"));
  imageMode(CENTER);
  image(canvas, width / 2, height / 2, canvas.width / 4, canvas.height / 4);
}

class Sticker {
  PVector pos;
  float radius;
  float angle;
  PImage img;
  boolean growing = true;

  Sticker(PVector pos, float initialRadius, float angle, PImage img) {
    this.pos = pos;
    this.radius = initialRadius;
    this.angle = angle;
    this.img = img;
  }

  boolean isColliding(Sticker other, float tolerance) {
    float d = dist(pos.x, pos.y, other.pos.x, other.pos.y);
    return d < (this.radius + other.radius - tolerance);
  }

  boolean touchesMask(PImage mask, float brightnessThreshold) {
    int steps = 20;
    for (int i = 0; i < steps; i++) {
      float a = TWO_PI * i / steps;
      int x = round(pos.x + cos(a) * radius);
      int y = round(pos.y + sin(a) * radius);
      if (x < 0 || y < 0 || x >= mask.width || y >= mask.height) return true;
      if (brightness(mask.get(x, y)) < brightnessThreshold) return true;
    }
    return false;
  }
}

PImage cutShape(PImage oIm) {
  PImage im = oIm.get();

  // remove blue pixels
  im.loadPixels();
  color target = color(0xFF9FE7F3); // Couleur cible avec alpha
  float targetThresh = 100;          // Distance max à target
  float blackThresh = 80;           // Distance min au noir
  for (int i = 0; i < im.pixels.length; i++) {
    color c = im.pixels[i];
    float dTarget = dist(red(c), green(c), blue(c), red(target), green(target), blue(target));
    float dBlack = dist(red(c), green(c), blue(c), 0, 0, 0);
    if (dTarget < targetThresh && dBlack > blackThresh) {
      im.pixels[i] = color(255); // Met en blanc
    }
  }
  im.updatePixels();

  // crop borders
  int margin = min(min(30, floor((float)im.width/2)), floor((float)im.height/2));
  im = im.get(margin, margin, im.width-margin*2, im.height-margin*2);
  // crop shape
  int startX = 0;
  int startY = 0;
  int endX = im.width;
  int endY = im.height;
  float threshold = 1;
  im.loadPixels();
  for (int x = 0; x<im.width && startX==0; x++) {
    float thisDarkness = 0;
    for (int y = 0; y<im.height; y++) {
      color c = im.pixels[x+y*im.width];
      thisDarkness += 0xFF*3-(red(c)+green(c)+blue(c));
    }
    thisDarkness/=im.height;
    if (thisDarkness>threshold) startX=x;
  }
  for (int y = 0; y<im.height && startY==0; y++) {
    float thisDarkness = 0;
    for (int x = 0; x<im.width; x++) {
      color c = im.pixels[x+y*im.width];
      thisDarkness += 0xFF*3-(red(c)+green(c)+blue(c));
    }
    thisDarkness/=im.width;
    if (thisDarkness>threshold) startY=y;
  }
  for (int x = im.width-1; x>=startX && endX==im.width; x--) {
    float thisDarkness = 0;
    for (int y = 0; y<im.height; y++) {
      color c = im.pixels[x+y*im.width];
      thisDarkness += 0xFF*3-(red(c)+green(c)+blue(c));
    }
    thisDarkness/=im.height;
    if (thisDarkness>threshold) endX=x;
  }
  for (int y = im.height-1; y>=startY && endY==im.height; y--) {
    float thisDarkness = 0;
    for (int x = 0; x<im.width; x++) {
      color c = im.pixels[x+y*im.width];
      thisDarkness += 0xFF*3-(red(c)+green(c)+blue(c));
    }
    thisDarkness/=im.width;
    if (thisDarkness>threshold) endY=y;
  }
  im = im.get(startX, startY, endX-startX, endY-startY);
  // add white margin
  PImage largerIm = createImage(im.width+2, im.height+2, RGB);
  largerIm.loadPixels();
  for (int i = 0; i < largerIm.pixels.length; i++) largerIm.pixels[i] = color(0xFF);
  largerIm.updatePixels();
  largerIm.copy(im, 0, 0, im.width, im.height, 1, 1, im.width, im.height);
  im = largerIm;
  // expand cutted zone
  float emptyThreshold = 15;
  boolean[] empty = new boolean[im.width*im.height];
  im.loadPixels();
  for (int x = 0; x<im.width; x++) {
    for (int y = 0; y<im.height; y++) {
      color c = im.pixels[x+y*im.width];
      if (0xFF*3-(red(c)+green(c)+blue(c))>emptyThreshold) empty[x+y*im.width] = false;
      else empty[x+y*im.width] = true;
    }
  }
  boolean[] done = new boolean[im.pixels.length];
  boolean[] toErase = new boolean[im.pixels.length];
  for (int i=0; i<im.pixels.length; i++) {
    done[i] = false;
    toErase[i] = false;
  }
  ArrayList<Integer> toCheck = new ArrayList<Integer>();
  toCheck.add(0);
  done[0] = true;
  while (toCheck.size()>0) {
    // println((float)toCheck.size()/done.length);
    /*
    if (toCheck.size()<50) {
     for (int i : toCheck) print(i+",");
     println("-");
     }
     */
    int thisIndex = toCheck.remove(0);
    if (empty[thisIndex]) {
      toErase[thisIndex] = true;
      if (!done[(thisIndex-1+done.length)%done.length]) {
        toCheck.add((thisIndex-1+done.length)%done.length);
        done[(thisIndex-1+done.length)%done.length] = true;
      }
      if (!done[(thisIndex+1+done.length)%done.length]) {
        toCheck.add((thisIndex+1+done.length)%done.length);
        done[(thisIndex+1+done.length)%done.length] = true;
      }
      if (!done[(thisIndex-im.width+done.length)%done.length]) {
        toCheck.add((thisIndex-im.width+done.length)%done.length);
        done[(thisIndex-im.width+done.length)%done.length] = true;
      }
      if (!done[(thisIndex+im.width+done.length)%done.length]) {
        toCheck.add((thisIndex+im.width+done.length)%done.length);
        done[(thisIndex+im.width+done.length)%done.length] = true;
      }
    }
  }
  PGraphics mask = createGraphics(im.width, im.height, JAVA2D);
  mask.beginDraw();
  for (int x=0; x<im.width; x++) {
    for (int y=0; y<im.height; y++) {
      mask.stroke(0xFF);
      if (toErase[x+y*im.width]) mask.stroke(0);
      for (int x2=-1; x2<2; x2++) {
        for (int y2=-1; y2<2; y2++) {
          if (toErase[((x+x2)+(y+y2)*im.width+toErase.length)%toErase.length]) mask.stroke(0);
        }
      }
      mask.point(x, y);
    }
  }
  mask.endDraw();
  im.mask(mask);
  return im;
}
