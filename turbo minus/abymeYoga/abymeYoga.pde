
// P = Sprite 1
// O = Sprite 2

// scan : "cadre" vers le haut

ArrayList<PImage> images = new ArrayList<PImage>();
ArrayList<String> doneUrls = new ArrayList<String>();

String[] folders;
int folderIndex = 0;

ArrayList<Pic> pics = new ArrayList<Pic>();

PVector tunnelCenter; // Center of the "tunnel" on the screen
float moveSpeed = 1.03;

boolean invertColors = true;

ArrayList<PImage> spritesIm = new ArrayList<PImage>();
ArrayList<Sprite> sprites = new ArrayList<Sprite>();

float lifeEnd = 3.0;// duration of the sprites in seconds
float fadeTime = 1.0;// duration of the fade in and out in seconds

boolean dark = false;

void setup() {
  // size(900, 700, P2D);
  fullScreen(P2D);
  background(0);
  tunnelCenter = new PVector(width / 2, height / 2);
  thread("loadSprites");
  folders = getSubfolders(dataPath("input"));
  folders = sort(folders);
  loadPictures();
  // Create the initial pic
  pics.add(new Pic(1.0));
}

void draw() {
  background(0);

  // Update scales and add/remove pics dynamically
  for (Pic pic : pics) {
    pic.scaleDisplay *= moveSpeed;
  }

  // update sprites and remove them if they are too transparent
  for (int i=sprites.size()-1; i>=0; i--) {
    sprites.get(i).update();
    if (sprites.get(i).lifeDuration>=lifeEnd) {
      sprites.remove(i);
    }
  }

  // Check if the largest pic is big enough
  while (!(pics.get(0).getCoordinates().x<0 && pics.get(0).getCoordinates().x+pics.get(0).getSize().x>=width &&
    pics.get(0).getCoordinates().y<0 && pics.get(0).getCoordinates().y+pics.get(0).getSize().y>=height)) {
    Pic newBiggest = pics.get(0).createLarger();
    pics.add(0, newBiggest);
  }

  // If the second largest pic fills the entire screen, remove the first
  if (pics.size()>1) {
    if (pics.get(1).getCoordinates().x<0 && pics.get(1).getCoordinates().x+pics.get(1).getSize().x>=width &&
      pics.get(1).getCoordinates().y<0 && pics.get(1).getCoordinates().y+pics.get(1).getSize().y>=height) {
      pics.remove(0);
    }
  }

  // If the smallest pic is smaller than 0.5 px, remove it
  if (pics.size()>0) {
    if (pics.get(pics.size() - 1).scaleDisplay * pics.get(pics.size() - 1).actualIdealSize.x < 0.5 &&
      pics.get(pics.size() - 1).scaleDisplay * pics.get(pics.size() - 1).actualIdealSize.y < 0.5) {
      pics.remove(pics.size() - 1);
    }
  }

  // If the smallest pic is larger than 1px, create a smaller one and add it at the end
  if (pics.get(pics.size() - 1).scaleDisplay * pics.get(pics.size() - 1).actualIdealSize.x > 1 &&
    pics.get(pics.size() - 1).scaleDisplay * pics.get(pics.size() - 1).actualIdealSize.y > 1) {
    Pic smallerPic = pics.get(pics.size() - 1).createSmaller();
    pics.add(smallerPic);
  }

  // Display pics from largest to smallest
  for (int i = 0; i < pics.size(); i++) {
    pics.get(i).draw();
  }

  // Display sprites
  for (Sprite sprite : sprites) {
    sprite.draw();
  }

  if (dark) background(0);
}

void loadSprites() {
  synchronized(spritesIm) {
    String[] spritesImFiles = getAllFilesFrom(dataPath("sprites"));
    spritesImFiles = sort(spritesImFiles);
    for (int i=0; i<spritesImFiles.length; i++) {
      PImage im = loadImage(spritesImFiles[i]);
      if (im!=null) spritesIm.add(im);
    }
  }
}

class Pic {
  float bleedMargin = 20;
  PVector actualIdealSize = new PVector(2319.0-cropMargin*2, 1655.0-cropMargin*2);// approx size of the pic in px
  PVector vanishingPointPxPos = new PVector(1164.0-cropMargin, 825.0-cropMargin);// position of the center in px
  PVector centerWithin = new PVector(vanishingPointPxPos.x/actualIdealSize.x, vanishingPointPxPos.y/actualIdealSize.y); // Relative center of the pic as proportion
  PVector insidePicSize = new PVector(585.0+bleedMargin, 418.0+bleedMargin);// size of the small pic inside in px
  float insideProportion = insidePicSize.mag()/actualIdealSize.mag(); // Scaling factor for the recursive effect
  float scaleDisplay;

  PImage im;

  Pic(float scale) {
    synchronized(images) {
      if (images.size()>0) im = images.get(floor(random(images.size())));
    }
    scaleDisplay = scale;
  }

  void draw() {

    float displayWidth = actualIdealSize.x * scaleDisplay;
    float displayHeight = actualIdealSize.y * scaleDisplay;

    // Calculate the position to center the image at tunnelCenter
    float x = tunnelCenter.x - centerWithin.x * displayWidth;
    float y = tunnelCenter.y - centerWithin.y * displayHeight;

    imageMode(CORNER);
    tint(0xFF);

    if (im!=null) {
      image(im, x, y, displayWidth, displayHeight);
    } else {
      fill(0);
      stroke(0xFF);
      rect(x, y, displayWidth, displayHeight);
    }
  }

  // Return actual coordinates and size
  PVector getCoordinates() {
    float displayWidth = actualIdealSize.x * scaleDisplay;
    float displayHeight = actualIdealSize.y * scaleDisplay;
    float x = tunnelCenter.x - centerWithin.x * displayWidth;
    float y = tunnelCenter.y - centerWithin.y * displayHeight;
    return new PVector(x, y);
  }

  PVector getSize() {
    float displayWidth = actualIdealSize.x * scaleDisplay;
    float displayHeight = actualIdealSize.y * scaleDisplay;
    return new PVector(displayWidth, displayHeight);
  }

  Pic createSmaller() {
    return new Pic(scaleDisplay * (insideProportion));
  }

  Pic createLarger() {
    return new Pic(scaleDisplay / (insideProportion));
  }
}

int cropMargin = 20;
void keyPressed() {
  if (key=='-') moveSpeed-=0.01;
  if (key=='+') moveSpeed+=0.01;
  if (keyCode==CONTROL) {
    doneUrls.clear();
    thread("loadPictures");
  }
  if (keyCode==RIGHT) {
    folderIndex=(folderIndex+1)%folders.length;
    println(folders[folderIndex]);
  }
  if (keyCode==LEFT) {
    folderIndex=(folderIndex-1+folders.length)%folders.length;
    println(folders[folderIndex]);
  }
  if (key=='o') {
    // add a sprite somewhere (0)
    synchronized(spritesIm) {
      sprites.add(new Sprite(spritesIm.get(0)));
    }
  }
  if (key=='p') {
    // add a sprite somewhere (1)
    synchronized(spritesIm) {
      sprites.add(new Sprite(spritesIm.get(1)));
    }
  }
  if (keyCode==BACKSPACE) dark^=true;
}

void loadPictures() {
  println("...loading");
  ArrayList<PImage> tempImages = new ArrayList<PImage>();
  println("from : "+dataPath("input/"+folders[folderIndex]));
  String[] inputUrl = getAllFilesFrom(dataPath("input/"+folders[folderIndex]));
  inputUrl = sort(inputUrl);
  for (int i=0; i<inputUrl.length; i++) {
    if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
      println(inputUrl[i]);
      PImage thisIm = loadImage(inputUrl[i]);
      if (thisIm!=null) {
        if (invertColors) thisIm = invertColors(thisIm);
        thisIm = thisIm.get(cropMargin, cropMargin, thisIm.width-cropMargin*2, thisIm.height-cropMargin*2);
        tempImages.add(thisIm);
      }
      doneUrls.add(inputUrl[i]);
    }
  }
  synchronized(images) {
    images.clear();
    images.addAll(tempImages);
  }
  println("...done");
}

PImage invertColors(PImage img) {
  // Create a new PImage of the same size as the input
  PImage result = createImage(img.width, img.height, RGB);

  // Load pixels into the array for manipulation
  img.loadPixels();
  result.loadPixels();

  // Loop over all pixels
  for (int i = 0; i < img.pixels.length; i++) {
    // Get the current pixel
    int pixel = img.pixels[i];

    // Extract the color components
    int r = (pixel >> 16) & 0xFF; // Red component
    int g = (pixel >> 8) & 0xFF;  // Green component
    int b = pixel & 0xFF;         // Blue component

    // Invert each component by subtracting from 255
    r = 255 - r;
    g = 255 - g;
    b = 255 - b;

    // Combine inverted components back into an integer pixel
    result.pixels[i] = (255 << 24) | (r << 16) | (g << 8) | b; // Include alpha channel as fully opaque
  }

  // Update the pixel array for the result image
  result.updatePixels();

  // Return the new image
  return result;
}

class Sprite {
  PImage im;
  PVector pos;
  PVector posDerivative = new PVector(0, 0);
  float scale;
  float scaleDerivative = 0;
  float angle;
  float angleDerivative = 0;
  float alpha = 0.0;
  float lifeDuration = 0.0;

  Sprite(PImage im) {
    this.im = im;
    // random position (not too close to the borders)
    pos = new PVector(random(200, width-200), random(200, height-200));
    scale = 1.0;
  }

  void update() {
    // add noise to the derivatives
    posDerivative.add(new PVector(random(-0.05, 0.05), random(-0.05, 0.05)));
    scaleDerivative += random(-0.0001, 0.0001);
    angleDerivative += random(-0.001, 0.001);
    // update position
    pos.add(posDerivative);
    // update scale
    scale += scaleDerivative;
    // update angle
    angle += angleDerivative;
    // fade alpha in then sustain then fade out over the course of the life
    if (lifeDuration<fadeTime) alpha = lifeDuration;
    if (lifeDuration>lifeEnd-fadeTime) alpha = lifeEnd-lifeDuration;
    lifeDuration += 1.0/((float)frameRate);
  }

  void draw() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(angle);
    scale(scale);
    tint(255, max(alpha*255, 0));
    imageMode(CENTER);
    image(im, 0, 0);
    popMatrix();
  }
}
