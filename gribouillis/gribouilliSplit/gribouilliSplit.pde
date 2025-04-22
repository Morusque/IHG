
ArrayList<String> doneUrls = new ArrayList<String>();

void setup() {
  size(1000, 800);
  try {
    String[] doneUrlsA = loadStrings("files/doneUrls.txt");
    for (int i=0; i<doneUrlsA.length; i++) doneUrls.add(doneUrlsA[i]);
  }
  catch(Exception e) {
    println(e);
  }
  addPsyche(createImage(500, 500, RGB));
}

void draw() {
}

void keyPressed() {
  if (keyCode == 'C') {
    doneUrls.clear();
    saveStrings(dataPath("files/doneUrls.txt"), doneUrls.toArray(new String[doneUrls.size()]));
    println("urls cleared");
  }
  if (keyCode == CONTROL) {
    println("loading...");
    String[] inputUrl = getAllFilesFrom(dataPath("input"));
    for (int i=0; i<inputUrl.length; i++) {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println("file : "+inputUrl[i]);
        String baseName = fileName(inputUrl[i]);
        baseName = baseName.substring(0, baseName.length()-4);
        PImage im = loadImage(inputUrl[i]);
        int pageNb = Integer.parseInt(inputUrl[i].substring(inputUrl[i].length()-11, inputUrl[i].length()-7));
        if (pageNb%2==0) {// front
          processBack(im, baseName);
        } else {// back
          processFront(im, baseName);
        }
        doneUrls.add(inputUrl[i]);
      }
    }
    saveStrings(dataPath("files/doneUrls.txt"), doneUrls.toArray(new String[doneUrls.size()]));
    println("...done");
  }
}

void processFront(PImage im, String baseName) {
  int frameNb=0;
  PGraphics lined = createGraphics(493*6, 873);
  lined.beginDraw();
  for (int y=0; y<2; y++) {
    for (int x=0; x<3; x++) {
      lined.image(im.get(107+493*x, 241+873*y, 493, 873), 493*frameNb, 0);
      frameNb++;
    }
  }
  lined.endDraw();
  lined.get().save(dataPath("processed/danse/"+baseName+"_danse.png"));
}

void processBack(PImage im, String baseName) {
  // conseils
  im.get(2877, 121, 517, 1477).save(dataPath("processed/conseils/"+baseName+"_conseils.png"));
  // portrait
  im.get(1871, 123, 1015, 1293).save(dataPath("processed/portraits/"+baseName+"_portrait.png"));
  // radis
  PImage radis = im.get(2403, 1595, 969, 639);
  color blueLines = color(205, 251, 249);
  for (int x=0; x<radis.width; x++) {
    for (int y=0; y<radis.height; y++) {
      color thisPixels = radis.get(x, y);
      if (abs(red(thisPixels)   - red(blueLines))+
        abs(green(thisPixels) - green(blueLines))+
        abs(blue(thisPixels)  - blue(blueLines)) < 10) radis.set(x, y, color(0xFF));
    }
  }
  radis = radis.get(10,10,radis.width-20,radis.height-20);
  radis.save(dataPath("processed/radis/"+baseName+"_radis.png"));
  // pochettes
  PImage pochette = im.get(117, 123, 1525, 1525);
  int nbBoxes = 14;
  int darkerBoxIndex = -1;
  float darkThreshold = 10;
  float darkerBoxDarkness = -1;
  boolean[] checked = new boolean[nbBoxes];
  for (int i=0; i<nbBoxes; i++) {
    checked[i] = false;
    PImage thisBox = im.get(608+floor((float)i/7)*524, 1894+floor(((float)i%7)*57), 45, 45);
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
  if (checked[0])  pochette = blendWithColor(pochette, color(0xff, 0x96, 0xdc, 0x80));
  if (checked[1])  pochette = blendWithColor(pochette, color(0x4a, 0x4a, 0x4a, 0x80));
  if (checked[2])  pochette = blendWithColor(pochette, color(0xff, 0x46, 0x7e, 0x80));
  if (checked[3])  pochette = blendWithColor(pochette, color(0xff, 0xd7, 0x1c, 0x80));
  if (checked[4])  pochette = blendWithColor(pochette, color(0xfe, 0x5c, 0x14, 0x80));
  if (checked[5])  pochette = blendWithColor(pochette, color(0xff, 0xff, 0xbc, 0x80));
  if (checked[6])  pochette = blendWithColor(pochette, color(0x28, 0x3e, 0x9d, 0x80));
  if (checked[7])  pochette = addHoles(pochette);
  if (checked[8])  pochette = blendWithColor(pochette, color(0x73, 0x20, 0xe4, 0x80));
  if (checked[9])  pochette = addPsyche(pochette);// psyché
  if (checked[10]) pochette = blendWithColor(pochette, color(0xff, 0xce, 0x80, 0x80));
  if (checked[11]) pochette = blendWithColor(pochette, color(0x56, 0xbf, 0x3e, 0x80));
  if (checked[12]) pochette = addSquares(pochette);
  if (checked[13]) pochette.filter(BLUR, 2);
  pochette.save(dataPath("processed/pochettes/"+baseName+"_pochette.png"));
  /*
  // tests
   for (int j=0; j<nbBoxes; j++) {
   for (int i=0; i<nbBoxes; i++) checked[i] = (i==j);
   pochette = im.get(117, 123, 1525, 1525);
   // processes
   pochette.save(dataPath("processed/pochettes/"+baseName+"_"+j+"_pochette.png"));
   }
   */
}

PImage blendWithColor(PImage im, color cB) {
  PImage im2 = im.get();
  for (int x=0; x<im2.width; x++) {
    for (int y=0; y<im2.height; y++) {
      color c = im2.get(x, y);
      c = blendColor(c, cB, DARKEST);
      im2.set(x, y, c);
    }
  }
  return im2;
}

PImage addSquares(PImage im) {
  PGraphics gr = createGraphics(im.width, im.height);
  gr.beginDraw();
  gr.image(im, 0, 0);
  gr.rectMode(CENTER);
  gr.noStroke();
  for (int i=0; i<500; i++) {
    int x = floor(random(im.width));
    int y = floor(random(im.height));
    color c = im.get(x, y);
    c = color(red(c), green(c), blue(c), 0x50);
    gr.fill(c);
    float sSize = random(10, 100);
    gr.rect(x, y, sSize, sSize);
  }
  for (int x=0; x<im.width; x++) {
    for (int y=0; y<im.height; y++) {
      gr.stroke(random(0x100), random(0x100), random(0x100), random(0x50));
      gr.point(x, y);
    }
  }
  gr.endDraw();
  return gr.get();
}

PImage addHoles(PImage im) {
  PGraphics gr = createGraphics(im.width, im.height);
  gr.beginDraw();
  gr.image(im, 0, 0);
  gr.ellipseMode(CENTER);
  gr.noStroke();
  for (int i=0; i<500; i++) {
    int x = floor(random(im.width));
    int y = floor(random(im.height));
    color c = im.get(x, y);
    c = color(red(c), green(c), blue(c), 0x50);
    gr.fill(c);
    float sSize = random(10, 100);
    gr.ellipse(x, y, sSize, sSize);
  }
  gr.endDraw();
  return gr.get();
}

PImage addPsyche(PImage im) {
  PGraphics gr = createGraphics(im.width, im.height);
  gr.beginDraw();
  float pXR = random(-0.0001, 0.0001);
  float pXG = random(-0.0001, 0.0001);
  float pXB = random(-0.0001, 0.0001);
  float pYR = random(-0.0001, 0.0001);
  float pYG = random(-0.0001, 0.0001);
  float pYB = random(-0.0001, 0.0001);
  float xO = random(-1, 1)*im.width;
  float yO = random(-1, 1)*im.height;
  for (int x=0; x<im.width; x++) {
    for (int y=0; y<im.height; y++) {
      color c = color(
        map(sin(sq(x+xO)*pXR+sq(y+yO)*pYR), -1, 1, 0, 0xFF),
        map(sin(sq(x+xO)*pXG+sq(y+yO)*pYG), -1, 1, 0, 0xFF),
        map(sin(sq(x+xO)*pXB+sq(y+yO)*pYB), -1, 1, 0, 0xFF));
      c = lerpColor(c, color(0), 0.5);
      gr.stroke(c);
      gr.point(x, y);
    }
  }
  PImage im2 = im.get();
  gr.blend(im2, 0, 0, im.width, im.height, 0, 0, im.width, im.height, DIFFERENCE);
  PImage result = gr.get();
  result.filter(POSTERIZE, 16);
  return result;
}
