
import drop.*;
import test.*;

ArrayList<String> doneUrls = new ArrayList<String>();
ArrayList<PImage> images = new ArrayList<PImage>();

int currentIndex;

int autoSwitchEvery = 30;
// -1 = no
// 100 = typical

SDrop drop;

String baseUrl = "";

void setup() {
  // size(1000, 1000);
  fullScreen(2);
  frameRate(10);
  drop = new SDrop(this); 
  // baseUrl = dataPath("../../gribouillis/gribouilliSplit/data/processed/pochettes");
  baseUrl = dataPath("input");
}

void draw() {
  if (autoSwitchEvery!=-1 && frameCount%autoSwitchEvery==0) nextPic();
  background(0);
  imageMode(CENTER);
  if (currentIndex>=0&&currentIndex<images.size()) image(images.get(currentIndex), width/2, height/2, 1000, 1000);
}

void keyPressed() {
  if (keyCode == CONTROL) {
    println("loading...");
    String[] inputUrl = getAllFilesFrom(baseUrl);
    for (int i=0; i<inputUrl.length; i++) {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println("file : "+inputUrl[i]);
        PImage im = loadImage(inputUrl[i]);
        im = im.get();
        images.add(im.get(123,441,1440,1440));
        doneUrls.add(inputUrl[i]);
      }
    }
    println("...done");
  }
  if (keyCode==ENTER) {
    nextPic();
  }
  if (keyCode==BACKSPACE) {
    previousPic();
  }
  if (keyCode=='C') {
    doneUrls.clear();
    images.clear();
  }
  if (keyCode=='A') {
    if (autoSwitchEvery == -1) autoSwitchEvery = 100;
    else autoSwitchEvery = -1;
    println("auto switch : "+autoSwitchEvery);
  }
}

void nextPic() {
  if (images.size()>0) currentIndex = (currentIndex+1+images.size())%images.size();
}

void previousPic() {
  if (images.size()>0) currentIndex = (currentIndex-1+images.size())%images.size();
}

void dropEvent(DropEvent theDropEvent) {
  if (theDropEvent.isImage()) {
    // images.add(loadImage(theDropEvent.file().toString()).get());
    images.add(loadImage(theDropEvent.file().toString()).get(123,441,1440,1440));
  } else {
    baseUrl = theDropEvent.file().toString();
  }
}
