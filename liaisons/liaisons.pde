
ArrayList<Box> boxes = new ArrayList<Box>();
ArrayList<String> doneUrls = new ArrayList<String>();

ArrayList<Integer> sessionBoxes = new ArrayList<Integer>();

int currentQueryIndex = -1;

PFont font;

int nbZinesExported = 0;
int nbImgExports = 0;

boolean scannerMode = true;

PImage lastPlanche;

int boxPxSize = 0;

int sequenceType = 0;
int sequencePhase = 0;
PImage displayedImage = null;

boolean autoSwitch = false;

void setup() {
  size(1200, 900);
  frameRate(50);
  font = loadFont(dataPath("files/typo/OCRAExtended-150.vlw"));
  if (scannerMode) boxPxSize = 649;
  else boxPxSize = 1500;

  // init();// DEPRECATED !!

  /*
  XML associations;
   String baseUrl = dataPath("files/associations.xml");
   if (new File(baseUrl).exists()) {
   associations = loadXML(baseUrl);
   } else {
   associations = parseXML("<associations/>");
   saveXML(associations, baseUrl);
   }
   */
}

void draw() {
  if (autoSwitch) if (frameCount%1000==0) displaySequence();
}

void keyPressed() {
  if (keyCode=='C') {
    doneUrls.clear();
    boxes.clear();
    load();
  }
  if (keyCode==CONTROL) {
    load();
  }
  if (keyCode==ENTER) {
    displaySequence();
  }
  if (keyCode=='S') {
    autoSwitch ^= true;
  }
  if (keyCode=='Q') {
    generateHumanQuery();
  }
  if (keyCode=='E') {
    println("export...");
    sessionBoxes.clear();
    Box currentBox = boxes.get(floor(random(boxes.size())));
    sessionBoxes.add(currentBox.id);
    PVector boxSize = new PVector(649*1.5f, 649*1.5f);
    PVector pasgeSize = new PVector(2480, 3508);
    PGraphics[] pages = new PGraphics[2];
    for (int p=0; p<pages.length; p++) {
      pages[p] = createGraphics(floor(pasgeSize.x), floor(pasgeSize.y), JAVA2D);
      pages[p].beginDraw();
      pages[p].imageMode(CENTER);
      pages[p].background(0xFF);
    }
    Box[] printedBoxes = new Box[12];
    for (int b=0; b<12; b++) {
      Box lastBox = currentBox;
      currentBox = lastBox.getRandomNext();
      for (int i=0; isInSession(currentBox)&&i<2; i++) currentBox = lastBox.getRandomNext();
      sessionBoxes.add(currentBox.id);
      printedBoxes[b] = currentBox;
    }
    pages[0].image(printedBoxes[0].im, pasgeSize.x*3/4, pasgeSize.y*1/6, boxSize.x, boxSize.y);
    pages[0].image(printedBoxes[1].im, pasgeSize.x*3/4, pasgeSize.y*3/6, boxSize.x, boxSize.y);
    pages[0].image(printedBoxes[2].im, pasgeSize.x*3/4, pasgeSize.y*5/6, boxSize.x, boxSize.y);
    pages[1].image(printedBoxes[3].im, pasgeSize.x*1/4, pasgeSize.y*1/6, boxSize.x, boxSize.y);
    pages[1].image(printedBoxes[4].im, pasgeSize.x*1/4, pasgeSize.y*3/6, boxSize.x, boxSize.y);
    pages[1].image(printedBoxes[5].im, pasgeSize.x*1/4, pasgeSize.y*5/6, boxSize.x, boxSize.y);
    pages[1].image(printedBoxes[6].im, pasgeSize.x*3/4, pasgeSize.y*1/6, boxSize.x, boxSize.y);
    pages[1].image(printedBoxes[7].im, pasgeSize.x*3/4, pasgeSize.y*3/6, boxSize.x, boxSize.y);
    pages[1].image(printedBoxes[8].im, pasgeSize.x*3/4, pasgeSize.y*5/6, boxSize.x, boxSize.y);
    pages[0].image(printedBoxes[9].im, pasgeSize.x*1/4, pasgeSize.y*1/6, boxSize.x, boxSize.y);
    pages[0].image(printedBoxes[10].im, pasgeSize.x*1/4, pasgeSize.y*3/6, boxSize.x, boxSize.y);
    pages[0].image(printedBoxes[11].im, pasgeSize.x*1/4, pasgeSize.y*5/6, boxSize.x, boxSize.y);
    for (int p=0; p<pages.length; p++) {
      pages[p].endDraw();
      pages[p].get().save(dataPath("zine/"+nf(nbZinesExported, 4)+"_"+nf(p, 2)+".png"));
    }
    nbZinesExported++;
    println("...done");
  }
  if (keyCode==RIGHT) {
    currentQueryIndex++;
    println("currentQueryIndex : "+currentQueryIndex);
  }
  if (keyCode==LEFT) {
    currentQueryIndex--;
    println("currentQueryIndex : "+currentQueryIndex);
  }
  if (keyCode==TAB) {
    if (lastPlanche!=null) {
      String path = dataPath("results/"+year()+"_"+nf(month(), 2)+"_"+nf(day(), 2)+"_"+nf(minute(), 2)+"_"+nf(second(), 2)+"_"+nf(millis(), 3)+"_"+nf(nbImgExports, 5)+".png");
      nbImgExports++;
      lastPlanche.save(path);
      println("image saved as "+path);
    } else {
      println("no image to save");
    }
  }
}

void init() {// deprecated
  String[] inputUrl = getAllFilesFrom(dataPath("files/init"));
  for (int i=0; i<inputUrl.length; i++) {
    // name : im_iiii
    Box box = new Box();
    box.im = loadImage(inputUrl[i]);//loadImage(inputUrl[i]).get(307, 185, 252, 252);
    String fileName = (new File(inputUrl[i])).getName();
    int idC = Integer.parseInt(fileName.substring(3, 3+4));
    box.id = idC;
    box.before.add(idC);
    box.after.add(idC);
    boxes.add(box);
  }
}

void generateHumanQuery() {
  println("exporting human query...");
  setQueryToLastIndexs();
  println("currentQueryIndex : "+currentQueryIndex);
  currentQueryIndex++;
  int indexA = constrain(floor((1-pow(random(1.0f), 1.75))*boxes.size()), 0, boxes.size()-1);
  int indexB = constrain(floor((1-pow(random(1.0f), 1.75))*boxes.size()), 0, boxes.size()-1);
  if (boxes.size()>1) {
    while (indexA==indexB) {// don't pick the same box for before and after
      indexB = constrain(floor((1-pow(random(1.0f), 1.75))*boxes.size()), 0, boxes.size()-1);
    }
  }
  if (boxes.size()==0) {
    indexA=0;
    indexB=0;
  }
  println("queries id(internal) : "+indexA+" "+indexB);
  Box boxA = null;
  Box boxB = null;
  if (boxes.size()>0) {
    boxA = boxes.get(indexA);
    boxB = boxes.get(indexB);
  }
  PGraphics page = createGraphics(4900, 2100, JAVA2D);
  float boxWidth = 1500;
  float strokeWeight = 8;
  if (scannerMode) {
    page = createGraphics(2343, 1659, JAVA2D);
    strokeWeight = 5;
    boxWidth = (float)page.width/4.0f;
  }
  float boxHeight = boxWidth;
  page.noSmooth();
  page.beginDraw();
  page.background(0xFF);
  // page.strokeWeight(strokeWeight*2); // original
  page.strokeWeight(strokeWeight*1.3); // anouk
  page.noFill();
  page.stroke(0);
  if (scannerMode) {
    if (boxA!=null) page.image(boxA.im, ((float)page.width-(boxWidth*3))/4.0f-strokeWeight, ((float)page.height-boxHeight)/2.0f-strokeWeight, boxWidth+strokeWeight*2, boxHeight+strokeWeight*2);
    page.rect((floor((float)page.width-(boxWidth*3))*2/4.0f+boxWidth*1.0f), floor(((float)page.height-boxHeight)/2.0f), boxWidth, boxHeight);
    if (boxB!=null) page.image(boxB.im, ((float)page.width-(boxWidth*3))*3/4.0f+boxWidth*2.0f-strokeWeight, ((float)page.height-boxHeight)/2.0f-strokeWeight, boxWidth+strokeWeight*2, boxHeight+strokeWeight*2);
  } else {
    if (boxA!=null) page.image(boxA.im, ((float)page.width-(boxWidth*3))/4.0f-strokeWeight, ((float)page.height-boxHeight)/2.0f-strokeWeight, boxWidth, boxHeight);
    page.rect((floor((float)page.width-(boxWidth*3))*2/4.0f+boxWidth*1.0f), floor(((float)page.height-boxHeight)/2.0f), boxWidth-strokeWeight*2, boxHeight-strokeWeight*2);
    if (boxB!=null) page.image(boxB.im, ((float)page.width-(boxWidth*3))*3/4.0f+boxWidth*2.0f-strokeWeight, ((float)page.height-boxHeight)/2.0f-strokeWeight, boxWidth, boxHeight);
  }
  page.fill(0);
  // page.textFont(font);
  page.textSize(150);
  String fileName = "im_0000_"+nf(currentQueryIndex, 4)+"_0000";
  if (boxA!=null && boxB!=null) fileName = "im_"+nf(boxA.id, 4)+"_"+nf(currentQueryIndex, 4)+"_"+nf(boxB.id, 4);
  if (scannerMode) {
    page.text(fileName, ((float)page.width-(boxWidth*3))/4.0f, ((float)page.height-boxHeight)/2.0f-300);
    page.rect(page.width-50, page.height-50, 20, 20);
  }
  /*
  page.text(nf(boxA.id, 4), ((float)page.width-(boxWidth*3))/4.0f, ((float)page.height-boxHeight)/2.0f-300);
   page.text(nf(currentQueryIndex, 4), ((float)page.width-(boxWidth*3))*2/4.0f+boxWidth*1.0f, ((float)page.height-boxHeight)/2.0f-300);
   page.text(nf(boxB.id, 4), ((float)page.width-(boxWidth*3))*3/4.0f+boxWidth*2.0f, ((float)page.height-boxHeight)/2.0f-300);
   */
  page.endDraw();
  //page.get().save(dataPath("queries/im_"+nf(boxA.id, 4)+"_"+nf(currentQueryIndex, 4)+"_"+nf(boxB.id, 4)+".png"));
  if (scannerMode) {
    page.get().save(dataPath("queries/query_"+nf(currentQueryIndex, 4)+".png"));
  } else {
    page.get().save(dataPath("input/"+fileName+".png"));
  }
  println("...done");
}

class Box {
  PImage im;
  int id;
  ArrayList<Integer> before = new ArrayList<Integer>();
  ArrayList<Integer> after = new ArrayList<Integer>();
  Box() {
  }
  Box getRandomNext() {
    println("next to "+id);
    int chosenIndex = after.get(floor(random(after.size())));
    println("chosenIndex "+chosenIndex);
    for (Box b : boxes) if (b.id==chosenIndex) return b;
    println("no existing next found");
    return null;
  }
  void printIndexes() {
    println("id : "+id);
    print("before :");
    for (int a : before) print(a+" ");
    println("");
    print("after :");
    for (int a : after) print(a+" ");
    println("");
    println("---");
    // println("image : "+!(im==null));
  }
  void autoCropImage() {
    int threshold = 0x80;
    int startX = -1;
    for (int x=0; x<im.width && startX==-1; x++) {
      for (int y=0; y<im.height; y++) {
        if (brightness(im.get(x, y))<threshold) startX = x;
      }
    }
    int endX = -1;
    for (int x=im.width-1; x>=0 && endX==-1; x--) {
      for (int y=0; y<im.height; y++) {
        if (brightness(im.get(x, y))<threshold) endX = x;
      }
    }
    int startY = -1;
    for (int y=0; y<im.height && startY==-1; y++) {
      for (int x=0; x<im.width; x++) {
        if (brightness(im.get(x, y))<threshold) startY = y;
      }
    }
    int endY = -1;
    for (int y=im.height-1; y>=0 && endY==-1; y--) {
      for (int x=0; x<im.width; x++) {
        if (brightness(im.get(x, y))<threshold) endY = y;
      }
    }
    if (startX!=-1&&endX!=-1&&startY!=-1&&endY!=-1) {
      im = im.get(startX, startY, endX-startX, endY-startY);
    }
  }
}

void setQueryToLastIndexs() {
  println("searching for last index...");
  for (Box b : boxes) {
    // if (b.id==currentQueryIndex) currentQueryAlreadyThere = true;
    currentQueryIndex=max(currentQueryIndex, b.id);
  }
  println("checking existing queries...");
  String[] inputUrl = getAllFilesFrom(dataPath("queries"));
  for (int i=0; i<inputUrl.length; i++) {
    try {
      int index = Integer.parseInt((new File(inputUrl[i])).getName().substring(6, 10));
      currentQueryIndex=max(currentQueryIndex, index);
    }
    catch(Exception e) {
      println(e);
    }
  }
}

boolean isInSession(Box box) {
  for (int b : sessionBoxes) {
    if (b==box.id) return true;
  }
  return false;
}

void displaySequence() {
  if (sequenceType == 0) {
    int marginSize = 100;
    int nbBX = 3;
    int nbBY = 2;
    PGraphics planche = createGraphics(marginSize*(nbBX+1)+boxPxSize*nbBX, marginSize*(nbBY+1)+boxPxSize*nbBY);
    planche.noSmooth();
    planche.beginDraw();
    planche.background(0xFF);
    if (boxes.size()>0) {
      sessionBoxes.clear();
      Box currentBox = boxes.get(floor(random(boxes.size())));
      sessionBoxes.add(currentBox.id);
      for (int y=0; y<nbBY; y++) {
        for (int x=0; x<nbBX; x++) {
          println("displaying image "+currentBox.id);
          float posX = marginSize*(x+1)+boxPxSize*x;
          float posY = marginSize*(y+1)+boxPxSize*y;
          planche.image(currentBox.im, floor(posX), floor(posY), boxPxSize, boxPxSize);
          // Box lastBox = currentBox;
          // for (int j=0; isInSession(currentBox) && j<2; j++) currentBox = lastBox.getRandomNext();
          currentBox = currentBox.getRandomNext();
        }
      }
    }
    planche.endDraw();
    lastPlanche = planche.get();
    image(planche, 0, 0, width, height);
  }
  if (sequenceType == 1) {
    if (sequencePhase==0) {
      String[] inputUrl = getAllFilesFrom(dataPath("input"));
      int randomId = floor(random(inputUrl.length));
      if (inputUrl.length>13) randomId = floor(random(13, inputUrl.length));// TODO temporary fix, remove that
      displayedImage = loadImage(inputUrl[randomId]);
      image(displayedImage, 0, 0, width, height);
      noStroke();
      fill(0xFF);
      rect(0, 0, width/3, height);
      rect((float)width*1.8/3, 0, width/3*1.5, height);// TODO temporary + it's ugly
      rect(0, 0, width, height*1/5);
    }
    if (sequencePhase==1) {
      image(displayedImage, 0, 0, width, height);
    }
    sequencePhase = (sequencePhase+1)%2;
  }
}

void load() {
  String[] inputUrl = getAllFilesFrom(dataPath("input"));
  println("loading...");
  for (int i=0; i<inputUrl.length; i++) {
    if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
      // name : im_bbbb_cccc_aaaa
      String fileName = (new File(inputUrl[i])).getName();
      if (fileName.length()>2 && fileName.substring(0, 3).equals("im_")) {
        int idB = Integer.parseInt(fileName.substring(3, 3+4));
        int idC = Integer.parseInt(fileName.substring(8, 8+4));
        int idA = Integer.parseInt(fileName.substring(13, 13+4));
        // b c a = Before Current After
        println("parsing id "+idC);
        Box bBox = new Box();
        Box cBox = new Box();
        Box aBox = new Box();
        boolean bFound = false;
        boolean cFound = false;
        boolean aFound = false;
        for (Box otherBox : boxes) {
          if (otherBox.id==idB) {
            bBox=otherBox;
            bFound=true;
            println("existing found "+idB);
          }
          if (otherBox.id==idC) {
            cBox=otherBox;
            cFound=true;
            println("existing found "+idC);
          }
          if (otherBox.id==idA) {
            aBox=otherBox;
            aFound=true;
            println("existing found "+idA);
          }
        }
        if (scannerMode) {
          // cBox.im = loadImage(inputUrl[i]).get(1181, 755, 975, 975);
          cBox.im = loadImage(inputUrl[i]).get(1249, 741, 1040, 1040);
          cBox.autoCropImage();
        } else cBox.im = loadImage(inputUrl[i]).get(1692, 292, 1500, 1500);
        if (!found(cBox.before, idB)) cBox.before.add(idB);
        cBox.id = idC;
        if (!found(cBox.after, idA)) cBox.after.add(idA);
        if (idB==idC) bFound = true;
        if (idA==idC) aFound = true;
        if (idA==idB) aFound = true;
        bBox.id = idB;
        aBox.id = idA;
        if (!found(bBox.after, idC)) bBox.after.add(idC);
        if (!found(aBox.before, idC)) aBox.before.add(idC);
        if (!bFound) boxes.add(bBox);
        if (!cFound) boxes.add(cBox);
        if (!aFound) boxes.add(aBox);
        doneUrls.add(inputUrl[i]);
      } else {
        println("filename "+fileName+" possibly wrong");
      }
    }
  }
  for (Box b : boxes) b.printIndexes();
  setQueryToLastIndexs();
  println("...done");
}

boolean found(ArrayList<Integer> hs, int n) {
  for (int i=0; i<hs.size(); i++) {
    if (hs.get(i)==n) return true;
  }
  return false;
}
