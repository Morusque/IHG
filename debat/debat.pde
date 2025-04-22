
ArrayList<PImage> pics = new ArrayList<PImage>();

PImage textA;
PImage textB;
PImage basePic;

void setup() {
  size(1200, 900);
  frameRate(10);
  basePic = loadImage(dataPath("base/basePic03.png"));
}

void draw() {
  background(0xFF);
  if (basePic!=null) image(basePic, 0, 0, width, height);
  if (textA!=null) image(textA, width*1/20, height*3/20, width*3/9, height*5/11);
  if (textB!=null) image(textB, width*12/20, height*3/20, width*3/9, height*5/11);
  if ((frameCount-1)%80==0) loadPics();
}

void loadPics() {
  try {
    String[] inputUrl = getAllFilesFrom(dataPath("input"));
    textA = loadImage(inputUrl[floor(random(inputUrl.length))]);
    textB = loadImage(inputUrl[floor(random(inputUrl.length))]);
    textA = textA.get(textA.width*1/40, textA.height*3/20, textA.width*8/18, textA.height*5/11);
    textB = textB.get(textB.width*23/40, textB.height*3/20, textB.width*7/18, textB.height*5/11);
  } 
  catch(Exception e) {
    println(e);
  }
}

void keyPressed() {
  loadPics();
}

