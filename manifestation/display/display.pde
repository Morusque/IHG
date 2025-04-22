
ArrayList<PImage> inserts = new ArrayList<PImage>();
ArrayList<PImage> drawings = new ArrayList<PImage>();

int displayIndex=17;
int displayType=0;

void setup() {
  size(800, 600);
  frameRate(30);
  String[] iUrls = getAllFilesFrom(dataPath("inserts"));
  for (String u : iUrls) inserts.add(loadImage(u));
  String[] dUrls = getAllFilesFrom(dataPath("drawings"));
  for (String u : dUrls) drawings.add(loadImage(u));
}

void draw() {
  // background(0);
  if (displayType==0) {
    if (inserts.size()>0) { 
      PImage thisInsert = inserts.get(displayIndex%inserts.size());
      tint(0xFF, 0x20);
      image(thisInsert, (width-thisInsert.width)/2, (height-thisInsert.height)/2);
    }
  }
  if (displayType==1) if (drawings.size()>0) {
    tint(0xFF, 0x20);
    image(drawings.get(displayIndex%drawings.size()), 0, 0, width, height);
  }
  if (frameCount%80==0) {
    if (displayType==0) {
      displayType=1;
    } else if (displayType==1) {
      displayType=0;
      displayIndex++;
    }
  }
}