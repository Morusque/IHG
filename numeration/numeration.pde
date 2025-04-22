
import ddf.minim.*;
ArrayList<AudioPlayer> sfxFiles = new ArrayList<AudioPlayer>();
Minim minim;

ArrayList<String> doneUrls = new ArrayList<String>(); 

ArrayList<NumSystem> syss = new ArrayList<NumSystem>();

PVector boxSize = new PVector(510, 406);// 520 410 // 490, 390
PVector initMargin = new PVector(88, 83);// 75 75 // 125, 115
PVector interMargin = new PVector(39, 105);// 30 100  // 37, 103

int displayMode = 0;

int displayF=0;

int currentSeqIm = 0;
int currentSeqImIter = 0;
int seqImNbIter = 1;

boolean soundOn = true;
boolean saveResult = false;
boolean allowInput = false;

void setup() {
  size(1200, 1000); // size(962, 760); // ou 1200/1000 // ou 1440, 1080
  //size(floor(boxSize.x*2), floor(boxSize.y*2));
  colorMode(HSB);
  frameRate(5);
  minim = new Minim(this);
  /*
  String[] sfxFilesUrls = getAllFilesFrom(dataPath("sounds"));
   for (String s : sfxFilesUrls) sfxFiles.add(minim.loadFile(s));
   */
}

// int nbS = 0;

void draw() {
  background(0);
  if (allowInput) if (frameCount%1==0) cutPics();
  if (syss.size()>0) {
    if (displayMode==0) displayAll();
    if (displayMode==1) displaySequence();
  }
  // if (syss.size()==9&&nbS<12) save(nf(nbS++,2)+".png");
}

void displayAll() {
  int nbX=ceil(sqrt(syss.size()));
  int nbY=ceil(sqrt(syss.size()));
  int imN=0;
  for (int x=0; x<nbX; x++) {
    for (int y=0; y<nbY; y++) {
      if (imN<syss.size()) {
        tint(0x90, ((x+y)%2)*0x80, 0xFF);
        image(syss.get(imN).digits[displayF], x*(float)width/nbX, y*(float)height/nbY, (float)width/nbX, (float)height/nbY);
        stroke(0);
        strokeWeight(2);
        noFill();
        rect(x*(float)width/nbX, y*(float)height/nbY, (float)width/nbX, (float)height/nbY);
      }
      imN++;
    }
  }
  displayF++;
  if (displayF==12) displayF=0;
}


void displaySequence() {
  tint(0xFF);
  image(syss.get(currentSeqIm).digits[displayF], 0, 0, width, height);
  displayF++;
  if (displayF==12) {
    displayF = 0;
    currentSeqImIter++;
    if (currentSeqImIter>=seqImNbIter) {
      currentSeqIm = (currentSeqIm+1)%syss.size();//random(syss.size()));
      currentSeqImIter=0;
    }
    if (syss.get(currentSeqIm).sfx!=null&&soundOn) {
      syss.get(currentSeqIm).sfx.rewind();
      syss.get(currentSeqIm).sfx.play();
    }
  }
}

void cutPics() {
  String[] inputUrl = getAllFilesFrom(dataPath("input"));
  PImage[] input = new PImage[inputUrl.length];
  int nbDone = 0;
  for (int i=0; i<inputUrl.length && nbDone<1; i++) {
    String num = inputUrl[i].split("_")[inputUrl[i].split("_").length-1];
    num = num.substring(0, num.length()-4);
    if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
      input[i] = loadImage(inputUrl[i]);
      int sfxIndex = -1;
      try {
        String sfxTxtNum = inputUrl[i].split("_")[1];
        sfxIndex = Integer.parseInt(sfxTxtNum)-1;
      }
      catch (Exception e) {
      }
      syss.add(new NumSystem(input[i], Integer.parseInt(num), sfxIndex));
      if (syss.size()>=50) syss.remove(0);
      if (saveResult) syss.get(syss.size()-1).saveDigits();
      doneUrls.add(inputUrl[i]);
      nbDone++;
    } else {
      // syss.add(new NumSystem(Integer.parseInt(num)));
    }
  }
}

class NumSystem {
  int index=0;
  PImage[] digits = new PImage[12];
  AudioPlayer sfx;
  NumSystem(PImage input, int index, int sfxIndex) {
    this.index = index;
    for (int i=0; i<12; i++) {
      int x=floor(initMargin.x+(i%4)*(boxSize.x+interMargin.x));
      int y=floor(initMargin.y+floor((float)i/4)*(boxSize.y+interMargin.y));
      digits[i] = input.get(x, y, floor(boxSize.x), floor(boxSize.y));
    }
    setSfx(sfxIndex);
  }
  NumSystem(int index) {
    this.index = index;
    for (int i=0; i<12; i++) digits[i] = loadImage(dataPath("result/"+nf(index, 3)+"_"+nf(i, 3)+".png"));
    setSfx(-1);
  }
  void setSfx(int sfxIndex) {
    if (sfxIndex!=-1) sfx = sfxFiles.get(sfxIndex);
  }
  void saveDigits() {
    for (int i=0; i<digits.length; i++) {
      digits[i].save(dataPath("result/"+nf(index, 3)+"_"+nf(i, 3)+".png"));
    }
  }
}

boolean inArray(String[] hs, String n) {
  for (String s : hs) {
    if (s.equals(n)) return true;
  }
  return false;
}

void keyPressed() {
  if (keyCode==RIGHT) displayMode=(displayMode+1)%2;
  if (keyCode==CONTROL) {
    allowInput^=true;
    println("allow input : "+allowInput);
  }
  if (keyCode==127) {// delete
    doneUrls.remove(doneUrls.size()-1);
    syss.remove(doneUrls.size()-1);
  }
}
