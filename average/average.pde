
ArrayList<Pic> pics1 = new ArrayList<Pic>();// couleur
ArrayList<Pic> pics2 = new ArrayList<Pic>();// lignes
ArrayList<Pic> pics3 = new ArrayList<Pic>();// texte
ArrayList<Pic> pics4 = new ArrayList<Pic>();// générique

PImage combo;
PImage merged;

int displayMode=0;

void setup() {
  size(600, 800, JAVA2D);
  frameRate(10);
  reloadPics();
}

void draw() {
  background(0);
  if (displayMode==0) if (pics4.size()>0) image(pics4.get(frameCount%pics4.size()).im, 0, 0, width, height);
  if (displayMode==1) {
    if (merged!=null) image(merged, 0, 0, width, height);
  }
  if (displayMode==2) {
    if (combo==null||frameCount%200==0) combo = generateNewCombo();
    image(combo, 0, 0, width, height);
  }
}

void keyPressed() {
  displayMode=(displayMode+1)%3;
  if (displayMode==1) merged = generateMerged();
}

PImage generateMerged() {
  PGraphics tmp = createGraphics(width, height, JAVA2D);
  tmp.beginDraw();
  tmp.background(0xFF);
  for (int i=0; i<pics4.size(); i++) {
    tmp.tint(0xFF, 0xFF-((float)i*0x100/pics4.size()));
    tmp.image(pics4.get(i).im, 0, 0, width, height);
  }
  for (int x=0; x<tmp.width; x++) {
    for (int y=0; y<tmp.height; y++) {
      tmp.stroke(constrain(map(brightness(tmp.get(x, y)), 0x80, 0x100, 0, 0x100), 0, 0xFF));
      tmp.point(x, y);
    }
  }
  tmp.endDraw();
  tmp.get().save(dataPath("result/merged.png"));
  return tmp.get();
}

PImage generateNewCombo() {
  PGraphics tmp = createGraphics(width, height, JAVA2D);
  tmp.beginDraw();
  tmp.background(0xFF);
  PImage tmpIm1 = pics1.get(floor(random(pics1.size()))).im.get();
  PImage tmpIm2 = pics2.get(floor(random(pics2.size()))).im.get();
  PImage tmpIm3 = pics3.get(floor(random(pics3.size()))).im.get();
  tmpIm1.blend(tmpIm2, 0, 0, width, height, 0, 0, width, height, DARKEST);
  tmpIm1.blend(tmpIm3, 0, 0, width, height, 0, 0, width, height, DARKEST);
  tmp.image(tmpIm1, 0, 0, width, height);
  tmp.endDraw();
  return tmp.get();
}

void reloadPics() {
  pics1 = new ArrayList<Pic>();
  String[] picsUrls;
  picsUrls = getAllFilesFrom(dataPath("1"));
  for (String url : picsUrls) if (!hasLoaded(url, pics1)) pics1.add(new Pic(url));
  picsUrls = getAllFilesFrom(dataPath("2"));
  for (String url : picsUrls) if (!hasLoaded(url, pics2)) pics2.add(new Pic(url));
  picsUrls = getAllFilesFrom(dataPath("3"));
  for (String url : picsUrls) if (!hasLoaded(url, pics3)) pics3.add(new Pic(url));
  picsUrls = getAllFilesFrom(dataPath("4"));
  for (String url : picsUrls) if (!hasLoaded(url, pics4)) pics4.add(new Pic(url));
}

class Pic {
  PImage im;
  String url;
  Pic (String url) {
    this.url=url;
    im = loadImage(url);
    im.resize(floor((float)im.width/3), floor((float)im.height/3));
  }
}

boolean hasLoaded(String url, ArrayList<Pic> pics) {
  for (Pic p : pics) if (p.url.equals(url)) return true;
  return false;
}