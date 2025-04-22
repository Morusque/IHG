
// scan : "cadre" vers le haut

ArrayList<PImage> images = new ArrayList<PImage>();
ArrayList<String> doneUrls = new ArrayList<String>();

ArrayList<Pic> pics = new ArrayList<Pic>();

PVector tunnelCenter; // Center of the "tunnel" on the screen
float moveSpeed = 1.03;

boolean invertColors = true;

void setup() {
  // size(900, 700, P2D);
  fullScreen(P2D);
  tunnelCenter = new PVector(width / 2, height / 2);

  // Create the initial pic
  pics.add(new Pic(1.0));
}

void draw() {
  background(0);

  // Update scales and add/remove pics dynamically
  for (Pic pic : pics) {
    pic.scaleDisplay *= moveSpeed;
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
    if (images.size()>0) im = images.get(floor(random(images.size())));
    scaleDisplay = scale;
  }

  void draw() {

    float displayWidth = actualIdealSize.x * scaleDisplay;
    float displayHeight = actualIdealSize.y * scaleDisplay;

    // Calculate the position to center the image at tunnelCenter
    float x = tunnelCenter.x - centerWithin.x * displayWidth;
    float y = tunnelCenter.y - centerWithin.y * displayHeight;

    if (im!=null) {
      image(im, x, y, displayWidth, displayHeight);
    } else {
      noFill();
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
    println("...loading");
    String[] inputUrl = getAllFilesFrom(dataPath("input"));
    for (int i=0; i<inputUrl.length; i++) {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println(inputUrl[i]);
        PImage thisIm = loadImage(inputUrl[i]);
        if (thisIm!=null) {
          if (invertColors) thisIm = invertColors(thisIm);
          thisIm = thisIm.get(cropMargin, cropMargin, thisIm.width-cropMargin*2, thisIm.height-cropMargin*2);
          images.add(thisIm);
        }
        doneUrls.add(inputUrl[i]);
      }
    }
    println("...done");
  }
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
