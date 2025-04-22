
ArrayList<String> doneUrls = new ArrayList<String>();
ArrayList<PImage> images = new ArrayList<PImage>();

int currentImageIndex = 0;

void setup() {
  size(1000, 900);
}

void draw() {
  background(0xFF);
  if (images.size()>0) {
    image(images.get(currentImageIndex), 0, 0);
    if (frameCount%10==0) {
      currentImageIndex=(currentImageIndex+1)%images.size();
    }
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
        float ratio = min((float)width/im.width, (float)height/im.height);
        im.resize(floor(im.width*ratio), floor(im.height*ratio));
        for (int j=1; j<7; j++) {
          PImage im2 = extend(im, j, 3, 2);
          images.add(im2);
        }
        image(im, 0, 0);
        doneUrls.add(inputUrl[i]);
      }
    }
    println("...done");
  }
}

PImage extend(PImage imIn, float dist, int pass, int mode) {
  PImage im = imIn.get();
  PImage im2 = im.get();
  im.loadPixels();
  im2.loadPixels();
  for (int i=0; i<3; i++) {
    for (int x = 0; x < im.width; x++) {
      for (int y = 0; y < im.height; y++) {
        for (int x2 = max(0, round(x-dist)); x2 < min(im.width, round(x+dist)); x2++) {
          for (int y2 = max(0, round(y-dist)); y2 < min(im.height, round(y+dist)); y2++) {
            if (sq(x2-x)+sq(y2-y)<sq(dist)) {
              if (mode==1) {
                if (brightness(im.pixels[x+y*im.width])<brightness(im2.pixels[x2+y2*im.width])) {
                  im2.pixels[x2+y2*im.width] = im.pixels[x+y*im.width];
                }
              }
              if (mode==2) {
                color im1Px = im.pixels[x+y*im.width];
                color im2Px = im2.pixels[x2+y2*im.width];
                if (red(im1Px)<red(im2Px)) im2.pixels[x2+y2*im.width] = color(red(im1Px), green(im2Px), blue(im2Px));
                if (green(im1Px)<green(im2Px)) im2.pixels[x2+y2*im.width] = color(red(im2Px), green(im1Px), blue(im2Px));
                if (blue(im1Px)<blue(im2Px)) im2.pixels[x2+y2*im.width] = color(red(im2Px), green(im2Px), blue(im1Px));
              }
            }
          }
        }
      }
    }
    im2.updatePixels();
    im = im2.get();
  }
  return im2;
}
