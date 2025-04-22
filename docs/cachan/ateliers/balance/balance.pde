
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;

Box2DProcessing box2d;

ArrayList<CustomShape> polygons = new ArrayList<CustomShape>();
ArrayList<CustomShape> rocks = new ArrayList<CustomShape>();

PImage triangle;

ArrayList<String> doneUrls = new ArrayList<String>();

boolean allowInput = false;

float bestScore = 0;

PImage balance;

int[] nbVegs = new int[2];


void setup() {
  size(1200, 900);
  frameRate(40);
  smooth();

  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, -20);

  ArrayList<PVector> vertices = new ArrayList<PVector>();// create a polygon
  vertices.add(new PVector(-250, -30));
  vertices.add(new PVector(250, -30));
  vertices.add(new PVector(250, 30));
  vertices.add(new PVector(-250, 30));
  polygons.add(new CustomShape(width*1/4, height-350, polygons, 0, BodyType.KINEMATIC, vertices, null, null, 1));
  polygons.add(new CustomShape(width*3/4, height-350, polygons, 0, BodyType.KINEMATIC, vertices, null, null, 1));

  balance = loadImage(dataPath("files/balance.png"));
}

void draw() {
  // update

  if (allowInput && frameCount%10==1) loadPics();

  box2d.step();// We must always step through time!
  for (int i = polygons.size()-1; i >= 0; i--) polygons.get(i).update();

  for (CustomShape cs : rocks) {
    if (cs.life>300) bestScore = max(bestScore, 1-(box2d.getBodyPixelCoord(cs.body).y-cs.imgAnchor.y)/height);
  }

  for (int v=0; v<nbVegs.length; v++) {
    nbVegs[v]=0;
    for (int i=0; i<rocks.size(); i++) {
      Vec2 thisPos = box2d.getBodyPixelCoord(rocks.get(i).body);
      if (thisPos.x > (float)width*v/nbVegs.length && thisPos.x < (float)width*(v+1)/nbVegs.length) nbVegs[v]+=1;
    }
  }

  // draw
  background(255);
  image(balance, 0, 0, width, height);
  for (CustomShape cs : rocks) cs.display();// Display all the shapes
  for (CustomShape cs : polygons) cs.display();// Display all the shapes

  for (int i=0; i<nbVegs.length; i++) {
    text(nbVegs[i], 50, 50+i*30);
  }

  /*
  stroke(0, 0, 0xFF);
   fill(0, 0, 0xFF);
   line(0, height-bestScore*height, width, height-bestScore*height);
   text(bestScore, 20, height-bestScore*height);
   */
}

void loadPics() {
  String[] inputUrl = getAllFilesFrom(dataPath("input"));
  if (inputUrl.length<doneUrls.size()) {
    doneUrls.clear();
  }
  boolean found = false;
  for (int i=0; i<inputUrl.length && !found; i++) {
    if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
      try {
        println("load : "+inputUrl[i]);
        PImage inputIm = loadImage(inputUrl[i]);
        inputIm.resize(floor(inputIm.width/2.0f), floor(inputIm.height/2.0f));
        doneUrls.add(inputUrl[i]);
        found=true;
        extractFromPage(inputIm);
      } 
      catch (Exception e) {
        println(e);
      }
    }
  }
}

void extractFromPage(PImage im) {
  CuttedImage imS = cutShape(im);
  im = imS.im;
  im.resize(im.width/5, im.height/5);
  float placeX = imS.xPos;
  // im.save("cutted"+polygons.size()+".png");
  PVector anchor =  new PVector(im.width/2, im.height/2);
  ArrayList<PVector> shape = new ArrayList<PVector>();
  int nbSides = 5;
  for (int i=0; i<nbSides; i++) {
    shape.add(new PVector(anchor.x*cos((float)i*TWO_PI/nbSides), anchor.y*sin((float)i*TWO_PI/nbSides)));
  }
  ShapeModel shapeModel = new ShapeModel(shape, im, anchor);
  CustomShape thisShape = shapeModel.spawn(placeX*width, height/7, 0, BodyType.DYNAMIC, polygons, 1.0f);
  polygons.add(thisShape);
  rocks.add(thisShape);
}


CuttedImage cutShape(PImage oIm) {
  PImage im = oIm.get();
  // crop borders
  int margin = 70;// min(min(30, floor((float)im.width/2)), floor((float)im.height/2));
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
  CuttedImage cIm = new CuttedImage();
  cIm.im=im;
  cIm.xPos=(((float)startX+endX)/2.0f)/oIm.width;
  return cIm;
}

class CuttedImage {
  PImage im;
  float xPos;
}

class ShapeModel {
  ArrayList<PVector> vertices;
  PImage image;
  PVector anchor;
  float radius;
  ShapeModel(ArrayList<PVector> vertices, PImage image, PVector anchor) {
    this.vertices=vertices;
    this.image=image;
    this.anchor=anchor;
  }
  ShapeModel(float radius, PImage image, PVector anchor) {
    this.radius=radius;
    this.image=image;
    this.anchor=anchor;
  }
  CustomShape spawn(float x, float y, float a, BodyType type, ArrayList<CustomShape> parent, float scale) {
    if (vertices==null) return new CustomShape(x, y, parent, a, type, radius, image, anchor, scale); 
    return new CustomShape(x, y, parent, a, type, vertices, image, anchor, scale);
  }
}

void keyPressed() {
  if (keyCode==CONTROL) {
    allowInput ^= true;
    println("allow input : "+allowInput);
  }
}