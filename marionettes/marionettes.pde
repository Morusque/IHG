
ArrayList<String> doneUrls = new ArrayList<String>();
ArrayList<PImage> images = new ArrayList<PImage>();
ArrayList<Sprite> sprites = new ArrayList<Sprite>();

int currentAnim = 0;

color bgColor = color(0xFF);

boolean requestChange = false;

void setup() {
  size(1485, 1050);
  // fullScreen(2);
  frameRate(50);
}

void draw() {
  if (frameCount%300==0 || sprites.size()==0 || requestChange) {
    if (images.size()>0) {
      sprites.clear();
      while (sprites.size()<3) {
        sprites.add(new Sprite(((float)sprites.size()+0.5f)*width/3));
        if (sprites.size()>1) sprites.get(sprites.size()-1).following = sprites.get(floor(random(sprites.size()-2)));
      }
      bgColor = color(random(0x50, 0x100), random(0x50, 0x100), random(0x50, 0x100));
    }
    requestChange = false;
  }
  background(bgColor);
  for (Sprite s : sprites) s.update();
  for (Sprite s : sprites) s.draw();
  // saveFrame(dataPath("result/####.png"));
}

void generate() {
  println("export...");
  PGraphics export = createGraphics(1485, 1050);
  export.beginDraw();
  int nbPoints = 1000;
  int nbX = 1;
  int nbY = 1;
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
      lengths[f][i] = map(lengths[f][i], minLength, maxLength, 50, 500);
    }
  }
  export.background(0xFF);
  export.noFill();
  export.stroke(0);
  export.strokeWeight(5);
  int frameNb = 0;
  for (int y=0; y<nbY; y++) {
    for (int x=0; x<nbX; x++) {
      for (int i=0; i<nbPoints; i++) {
        float a = (float)i/nbPoints*TWO_PI;
        float a2 = ((float)(i+1)%nbPoints)/nbPoints*TWO_PI;
        PVector middle = new PVector((float)export.width*(x+0.5)/nbX, (float)export.height*(y+0.5)/nbY);
        export.line(middle.x+cos(a)*lengths[frameNb][i], middle.y+sin(a)*lengths[frameNb][i], middle.x+cos(a2)*lengths[frameNb][(i+1)%nbPoints], middle.y+sin(a2)*lengths[frameNb][(i+1)%nbPoints]);
      }
      frameNb++;
    }
  }
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
    loadImages();
  }
  if (keyCode == RIGHT) {
    requestChange = true;
  }
}

void loadImages() {
  println("loading...");
  String[] inputUrl = getAllFilesFrom(dataPath("input"));
  for (int i=0; i<inputUrl.length; i++) {
    if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
      println("file : "+inputUrl[i]);
      String fileName = inputUrl[i].substring(dataPath("input").length()+1, inputUrl[i].length());
      if (new File(dataPath("processed/"+"p_"+fileName)).exists()) {
        PImage cutted = loadImage(dataPath("processed/"+"p_"+fileName));
        images.add(cutted);
      } else {
        PImage cutted = cutShape(loadImage(inputUrl[i]).get(20, 300, 1600, 2000));//.get(495,475,1333,707)
        float reducedRatio = min(300.0f/(float)cutted.width, 300.0f/(float)cutted.height);
        cutted.resize(floor(cutted.width*reducedRatio), floor(cutted.height*reducedRatio));
        cutted.save(dataPath("processed/"+"p_"+fileName));
        images.add(cutted);
      }
      doneUrls.add(inputUrl[i]);
    }
  }
  println("...done");
}

PImage cutShape(PImage oIm) {
  PImage im = oIm.get();
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
      if (toErase[x+y*im.width]) mask.stroke(0);
      else mask.stroke(0xFF);
      mask.point(x, y);
    }
  }
  mask.endDraw();
  im.mask(mask);
  // TODO trace polygon
  return im;
}

class Sprite {
  PVector basePosition;
  PVector position = new PVector();
  PImage im;
  float scale = 1.3;
  float rotation = 0;
  float speed = random(0.5, 1.5);
  Sprite following;
  Sprite(float x) {
    im = images.get(floor(random(images.size())));
    basePosition = new PVector(x, random(height*1/3, height*2/3));
  }
  void update() {
    position.y = basePosition.y + sin((float)frameCount/20*speed)*100;
    position.x = basePosition.x + sin((float)frameCount/25*speed)*50;
    rotation = sin((float)frameCount/30*speed)*PI/10;
  }
  void draw() {
    strokeWeight(2);
    stroke(0);
    fill(0xFF);
    quad(position.x-10, position.y+10, position.x+10, position.y+10, basePosition.x+30, height+10, basePosition.x-30, height+10);
    imageMode(CENTER);
    pushMatrix();
    translate(position.x, position.y);
    rotate(rotation);
    scale(scale);
    image(im, 0, 0);
    popMatrix();
  }
}
