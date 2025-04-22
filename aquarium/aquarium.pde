
ArrayList<String> doneUrls = new ArrayList<String>();
ArrayList<Anim> anims = new ArrayList<Anim>();

int animMode = 0;

int currentAnim = 0;
int currentAnim2 = 0;

color bgColor = color(0x50, 0x50, 0xE0);
int framePhase = 0;
int framePhase2 = 50;

boolean numericMode = false;// numeric or scan

void setup() {
  // size(1485, 1050);
  fullScreen(2);
  frameRate(7);
  background(bgColor);
}

void draw() {
  // background(0xFF);
  /*
  for (int i=0; i<6; i++) {
   if (currentAnim+i<anims.size()) {
   image(anims.get(currentAnim+i).images[frameCount%anims.get(currentAnim+i).images.length], (i%3)*1485/3, floor((float)i/3)*1050/2);
   }
   }
   */
  if (anims.size()>0) {
    if (framePhase>=100) {
      currentAnim = (currentAnim+1)%anims.size();
      framePhase=0;
      animMode = (animMode+1)%3;
      bgColor = color(0x50+random(-20, 20), 0x50+random(-20, 20), 0xE0+random(-20, 20));
    }
    if (framePhase2>=100) {
      currentAnim2 = floor(random(anims.size()));
      framePhase2=0;
    }
    if (animMode==0) {
      background(bgColor);
      imageMode(CENTER);
      PImage currentIm = anims.get(currentAnim).images[framePhase%anims.get(currentAnim).images.length];
      pushMatrix();
      translate(width/2+(framePhase-50)*20, height*1/3);
      scale((50.0-abs((float)framePhase-50.0))*1.5/50.0);
      rotate(((float)framePhase-50.0)/50);
      image(currentIm, 0, 0);
      popMatrix();
      PImage currentIm2 = anims.get(currentAnim2).images[framePhase%anims.get(currentAnim2).images.length];
      pushMatrix();
      translate(width/2-(framePhase2-50)*20, height*2/3);
      scale((50.0-abs((float)framePhase2-50.0))*1.5/50.0);
      rotate(((float)framePhase2-50.0)/50);
      image(currentIm2, 0, 0);
      popMatrix();
      framePhase++;
      framePhase2++;
    }
    if (animMode==1) {
      background(bgColor);
      imageMode(CENTER);
      for (int i=0; i<10; i++) {
        PImage currentIm = anims.get(currentAnim).images[(framePhase+i)%anims.get(currentAnim).images.length];
        pushMatrix();
        translate(width/2+cos((float)i/10*TWO_PI)*300, height*1/2+sin((float)i/10*TWO_PI)*300);
        scale((50.0-abs((float)framePhase-50.0))*0.7/50.0);
        rotate(((float)framePhase-50.0)/50);
        image(currentIm, 0, 0);
        popMatrix();
      }
      framePhase++;
    }
    if (animMode==2) {
      background(bgColor);
      imageMode(CENTER);
      int nbX = 6;
      int nbY = 5;
      for (int x=0; x<nbX; x++) {
        for (int y=0; y<nbY; y++) {
          PImage currentIm = anims.get(((currentAnim+x+y))%anims.size()).images[(framePhase+x+y)%anims.get(((currentAnim+x+y))%anims.size()).images.length];
          pushMatrix();
          translate((x+1)*width/(nbX+1), (y+1)*height/(nbY+1));
          scale(max((50.0-abs((float)framePhase+(x*y)-50.0))*0.5/50.0, 0));
          rotate(((float)framePhase-50.0)/50);
          try {
            image(currentIm, 0, 0);
          }
          catch(Exception e) {
            println(e);
          }
          popMatrix();
        }
      }
      framePhase++;
    }
  }
  // saveFrame(dataPath("result/####.png"));
}

void exportSingles() {
  for (int i=0; i<anims.size(); i++) {
    color bgColor = color(random(0x100), random(0x100), random(0x100));
    for (int j=0; j<anims.get(i).images.length; j++) {
      PGraphics gr = createGraphics(500, 500);
      gr.beginDraw();
      gr.imageMode(CENTER);
      gr.background(bgColor);
      gr.image(anims.get(i).images[j], gr.width/2, gr.height/2, anims.get(i).images[j].width*0.8, anims.get(i).images[j].height*0.8);
      gr.endDraw();
      gr.save(dataPath("result/singles/"+nf(i, 5)+"_"+nf(j, 2)+".png"));
    }
  }
}

void generate() {
  println("export...");
  PGraphics export = createGraphics(1485, 1050);
  export.beginDraw();
  int nbPoints = 1000;
  nbPoints = floor(3+random(random(1000)));
  int nbX = 3;
  int nbY = 2;
  // <export for bousculade>
  nbX = 4;
  nbY = 3;
  // </export for bousculade>
  int nbFrames = nbX*nbY;
  float[][] lengths = new float[nbFrames][nbPoints];
  Oscillator[] oscs = new Oscillator[20];
  for (int i=0; i<oscs.length; i++) {
    oscs[i] = new Oscillator();
  }
  float minLength = -1;
  float maxLength = -1;
  for (int f=0; f<nbFrames; f++) {
    for (int i=0; i<nbPoints; i++) {
      float value = 100;
      for (int j=0; j<oscs.length; j++) value += oscs[j].value(((float)i/nbPoints), ((float)f/nbFrames))*50;
      lengths[f][i] = value;
      if (minLength==-1||minLength>value) minLength = value;
      if (maxLength==-1||maxLength<value) maxLength = value;
    }
  }
  for (int f=0; f<nbFrames; f++) {
    for (int i=0; i<nbPoints; i++) {
      lengths[f][i] = map(lengths[f][i], minLength, maxLength, 30, 140);// 50, 180
    }
  }
  export.background(0xFF);
  export.noFill();
  export.stroke(0);
  int frameNb = 0;


  /*
  for (int y=0; y<nbY; y++) {
   for (int x=0; x<nbX; x++) {
   for (int i=0; i<nbPoints; i++) {
   float a = (float)i/nbPoints*TWO_PI;
   float a2 = ((float)(i+1)%nbPoints)/nbPoints*TWO_PI;
   PVector middle = new PVector((float)export.width*(x+0.5)/nbX, (float)export.height*(y+0.5)/nbY);
   export.strokeWeight(4);
   export.line(middle.x+cos(a)*lengths[frameNb][i], middle.y+sin(a)*lengths[frameNb][i], middle.x+cos(a2)*lengths[frameNb][(i+1)%nbPoints], middle.y+sin(a2)*lengths[frameNb][(i+1)%nbPoints]);
   export.strokeWeight(1);
   export.rect(middle.x-200, middle.y-200, 200*2, 200*2); // for calibration
   }
   frameNb++;
   }
   }
   */


  for (int y=0; y<nbY; y++) {
    for (int x=0; x<nbX; x++) {
      for (int i=0; i<nbPoints; i++) {
        float a = (float)i/nbPoints*TWO_PI;
        float a2 = ((float)(i+1)%nbPoints)/nbPoints*TWO_PI;
        PVector middle = new PVector((float)export.width*(x+0.5)/nbX, (float)export.height*(y+0.5)/nbY);
        export.strokeWeight(4);
        //export.line(middle.x+cos(a)*lengths[frameNb][i], middle.y+sin(a)*lengths[frameNb][i], middle.x+cos(a2)*lengths[frameNb][(i+1)%nbPoints], middle.y+sin(a2)*lengths[frameNb][(i+1)%nbPoints]);
        export.line(middle.x+cos(a)*lengths[frameNb][i], middle.y+sin(a)*lengths[frameNb][i], middle.x+cos(a2)*lengths[frameNb][(i+1)%nbPoints], middle.y+sin(a)*lengths[frameNb][i]);
        export.line(middle.x+cos(a2)*lengths[frameNb][(i+1)%nbPoints], middle.y+sin(a)*lengths[frameNb][i], middle.x+cos(a2)*lengths[frameNb][(i+1)%nbPoints], middle.y+sin(a2)*lengths[frameNb][(i+1)%nbPoints]);
        export.strokeWeight(1);
        export.rect(middle.x-160, middle.y-160, 160*2, 160*2); // for calibration
      }
      frameNb++;
    }
  }


  export.textSize(25);
  export.fill(0);
  export.text("H", 7, 30);
  export.text("B", export.width-20, export.height-10);
  export.endDraw();
  export.save(dataPath("exports/img_"+nf(nbExported++, 4)+".png"));
  println("done");
}

class Oscillator {
  float fr;
  float ph;
  float am;
  float bi;
  float sp;
  float mp;
  float ma;
  Oscillator() {
    fr = floor(random(1, random(1, 8)));
    ph = random(TWO_PI);
    am = random(0, 1);
    bi = 0;
    sp = round(random(-1, 1));
    mp = random(TWO_PI);
    ma = random(-1, 1);
  }
  float value(float t, float p) {
    return sin(((t)*TWO_PI+ph)*fr)*(am*map(sin(p*TWO_PI*sp+mp), -1, 1, 1, ma)+bi);
  }
}

int nbExported = 0;
void keyPressed() {
  if (key == 'e') {
    generate();
  }
  if (keyCode == CONTROL) {
    // thread("loadImages");
    loadImages();
  }
  if (keyCode == RIGHT) {
    framePhase=100;
  }
  if (key == 'g') {
    numericMode ^= true;
    println("numeric : "+numericMode);
  }
  if (key == 's') {
    exportSingles();
  }
}

void loadImages() {
  println("loading...");
  String[] inputUrl = getAllFilesFrom(dataPath("input"));
  for (int i=0; i<inputUrl.length; i++) {
    if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
      println("file : "+inputUrl[i]);
      String fileName = inputUrl[i].substring(dataPath("input").length()+1, inputUrl[i].length()-4);
      if (new File(dataPath("processed/"+"p_"+fileName+"_01"+".png")).exists()) {
        Anim anim = new Anim();
        anim.images = new PImage[6];
        for (int j=0; j < anim.images.length; j++) {
          anim.images[j] = loadImage(dataPath("processed/"+"p_"+fileName+"_"+nf(j, 2)+".png"));
        }
        anims.add(anim);
      } else {
        PImage im = loadImage(inputUrl[i]);
        Anim anim = new Anim();
        //anim.images = new PImage[6];
        anim.images = new PImage[12];
        int nbX = 3;
        int nbY = 2;
        int startX = 109;
        int startY = 125;
        int sizeX = 615;
        int sizeY = 615;
        int spaceX = 761;
        int spaceY = 803;
        int frameNb = 0;
        // bousculade mode
        /*
        nbX = 4;
         nbY = 3;
         startX = 65;
         startY = 32;
         sizeX = 520;
         sizeY = 520;
         spaceX = 525;
         spaceY = 525;
         */
        // weirdly printed mode
        /*
        startX = 189;
         startY = 167;
         sizeX = 569;
         sizeY = 569;
         spaceX = 703;
         spaceY = 745;
         */
        if (numericMode) {
          startX = 47;
          startY = 62;
          sizeX = 401;
          sizeY = 401;
          spaceX = 495;
          spaceY = 525;
        }
        for (int y=0; y<nbY; y++) {
          for (int x=0; x<nbX; x++) {
            PImage cutted = cutShape(im.get(startX+spaceX*x, startY+spaceY*y, sizeX, sizeY));
            anim.images[frameNb] = cutted;
            cutted.save(dataPath("processed/"+"p_"+fileName+"_"+nf(frameNb, 2)+".png"));
            frameNb++;
          }
        }
        anims.add(anim);
      }
      doneUrls.add(inputUrl[i]);
    }
  }
  println("...done");
}

PImage cutShape(PImage oIm) {
  PImage im = oIm.get();
  // crop borders
  int margin = min(min(0, floor((float)im.width/2)), floor((float)im.height/2));
  im = im.get(margin, margin, im.width-margin*2, im.height-margin*2);
  // crop shape
  int startX = 0;
  int startY = 0;
  int endX = im.width;
  int endY = im.height;
  float threshold = 5;
  im.loadPixels();
  for (int x = 0; x<im.width && startX==0; x++) {
    float thisDrakness = 0;
    for (int y = 0; y<im.height; y++) {
      color c = im.pixels[x+y*im.width];
      thisDrakness += 0xFF*3-(red(c)+green(c)+blue(c));
    }
    thisDrakness/=im.height;
    if (thisDrakness>threshold) startX=x;
  }
  for (int y = 0; y<im.height && startY==0; y++) {
    float thisDrakness = 0;
    for (int x = 0; x<im.width; x++) {
      color c = im.pixels[x+y*im.width];
      thisDrakness += 0xFF*3-(red(c)+green(c)+blue(c));
    }
    thisDrakness/=im.width;
    if (thisDrakness>threshold) startY=y;
  }
  for (int x = im.width-1; x>=startX && endX==im.width; x--) {
    float thisDrakness = 0;
    for (int y = 0; y<im.height; y++) {
      color c = im.pixels[x+y*im.width];
      thisDrakness += 0xFF*3-(red(c)+green(c)+blue(c));
    }
    thisDrakness/=im.height;
    if (thisDrakness>threshold) endX=x;
  }
  for (int y = im.height-1; y>=startY && endY==im.height; y--) {
    float thisDrakness = 0;
    for (int x = 0; x<im.width; x++) {
      color c = im.pixels[x+y*im.width];
      thisDrakness += 0xFF*3-(red(c)+green(c)+blue(c));
    }
    thisDrakness/=im.width;
    if (thisDrakness>threshold) endY=y;
  }
  startX-=1;
  startY-=1;
  endX+=1;
  endY+=1;
  // im = im.get(startX, startY, endX-startX, endY-startY);
  // add white margin
  PImage largerIm = createImage(im.width+2, im.height+2, RGB);
  largerIm.loadPixels();
  for (int i = 0; i < largerIm.pixels.length; i++) largerIm.pixels[i] = color(0xFF);
  largerIm.updatePixels();
  largerIm.copy(im, 0, 0, im.width, im.height, 1, 1, im.width, im.height);
  im = largerIm;
  // expand cutted zone
  float emptyThreshold = 35;
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
  // TODO trace polygon
  return im;
}

class Anim {
  PImage[] images;
}
