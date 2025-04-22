
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

void setup() {
  size(1200, 900);
  frameRate(40);
  smooth();

  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, -20);

  ArrayList<PVector> vertices = new ArrayList<PVector>();// create a polygon
  vertices.add(new PVector(-300, -30));
   vertices.add(new PVector(300, -30));
   vertices.add(new PVector(300, 30));
   vertices.add(new PVector(-300, 30));
   polygons.add(new CustomShape(width/2, height-30, polygons, 0, BodyType.STATIC, vertices, null, null, 1));
   polygons.add(new CustomShape(width*1/5, height+100, polygons, -1, BodyType.STATIC, vertices, null, null, 1));
   polygons.add(new CustomShape(width*4/5, height+100, polygons, +1, BodyType.STATIC, vertices, null, null, 1));
}

void draw() {
  // update

  if (allowInput) loadPics();

  box2d.step();// We must always step through time!
  for (int i = polygons.size()-1; i >= 0; i--) polygons.get(i).update();

  for (CustomShape cs : rocks) {
    if (cs.life>300) bestScore = max(bestScore, 1-(box2d.getBodyPixelCoord(cs.body).y-cs.imgAnchor.y)/height);
  }

  // draw
  background(255);
  for (CustomShape cs : polygons) cs.display();// Display all the shapes

  stroke(0, 0, 0xFF);
  fill(0, 0, 0xFF);
  line(0, height-bestScore*height, width, height-bestScore*height);
  text(bestScore, 20, height-bestScore*height);
  
  // saveFrame("result/result#####.png");
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
  im = im.get(20, 20, im.width-40, im.height-40);
  im.resize(floor((float)im.width/8.0f), floor((float)im.height/8.0f));
  int startX = 0;
  int startY = 0;
  int endX = im.width;
  int endY = im.height;
  for (int x = 0; x<im.width && startX==0; x++) {
    float thisDrakness = 0;
    for (int y = 0; y<im.height; y++) {
      color c = im.get(x, y);
      thisDrakness += 0xFF*3-(red(c)+green(c)+blue(c));
    }
    if (thisDrakness>1000) startX=x;
  }
  for (int y = 0; y<im.height && startY==0; y++) {
    float thisDrakness = 0;
    for (int x = 0; x<im.width; x++) {
      color c = im.get(x, y);
      thisDrakness += 0xFF*3-(red(c)+green(c)+blue(c));
    }
    if (thisDrakness>1000) startY=y;
  }
  for (int x = im.width-1; x>=startX && endX==im.width; x--) {
    float thisDrakness = 0;
    for (int y = 0; y<im.height; y++) {
      color c = im.get(x, y);
      thisDrakness += 0xFF*3-(red(c)+green(c)+blue(c));
    }
    if (thisDrakness>1000) endX=x;
  }
  for (int y = im.height-1; y>=startY && endY==im.height; y--) {
    float thisDrakness = 0;
    for (int x = 0; x<im.width; x++) {
      color c = im.get(x, y);
      thisDrakness += 0xFF*3-(red(c)+green(c)+blue(c));
    }
    if (thisDrakness>1000) endY=y;
  }
  float placeX = (((float)startX+endX)/2.0f)/im.width;
  im = im.get(startX, startY, endX-startX, endY-startY);
  PGraphics mask = createGraphics(im.width, im.height, JAVA2D);
  mask.beginDraw();
  for (int x=0; x<im.width; x++) {
    for (int y=0; y<im.height; y++) {
      color c = im.get(x, y);
      mask.stroke(constrain((0xFF*3-(red(c)+green(c)+blue(c)))*10, 0, 0xFF));
      mask.point(x, y);
    }
  }
  mask.endDraw();
  im.mask(mask);
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
