
ArrayList<ArrayList<PImage>> images = new ArrayList<ArrayList<PImage>>();
ArrayList<String> doneUrls = new ArrayList<String>();

String[] folderNames = {"01", "02", "03"};

PImage[] currentImages = new PImage[3];

void setup() {
  size(400, 1000);
  frameRate(50);
  for (int i=0; i<3; i++) images.add(new ArrayList<PImage>());
}

void draw() {
  if (frameCount%50==0) {
    for (int i=0; i<currentImages.length; i++) if (images.get(i).size()>0) currentImages[i] = images.get(i).get(floor(random(images.get(i).size())));
  }
  for (int i=0; i<currentImages.length; i++) if (currentImages[i]!=null) image(currentImages[i], 0, (float)i*height/currentImages.length, width, (float)height*1/currentImages.length);
}

int nbSaved = 0;

void keyPressed() {
  if (keyCode==CONTROL) {
    println("loading...");
    for (int currentPart=0; currentPart<3; currentPart++) {
      String[] inputUrl = getAllFilesFrom(dataPath("input/"+folderNames[currentPart]));
      for (int i=0; i<inputUrl.length; i++) {
        if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
          PImage thisIm = loadImage(inputUrl[i]).get(541, 383, 1771-541, 1364-383);
          thisIm.resize(floor(thisIm.width/2), floor(thisIm.height/3));
          images.get(currentPart).add(thisIm);
          doneUrls.add(inputUrl[i]);
        }
      }
    }
    println("...done");
  }
  if (keyCode==TAB) {
    save(dataPath("result/"+nf(nbSaved++, 4)+".png"));
  }
}