
import processing.pdf.*;

ArrayList<String> doneUrls = new ArrayList<String>();

ArrayList<Panel> panels = new ArrayList<Panel>();

PVector origSize;

int currentModelId = 0;

XML params;

int state = 0;
// 0 = original
// 1 = last
// 2 = random

boolean autorandom = false;

void setup() {
  size(600, 850);
  frameRate(50);
  sortFiles();
  params = loadXML(dataPath("files/models.xml"));
  loadModel();
}

void draw() {
  if (autorandom&&frameCount%300==0) randomizeIndexes();
  background(0xFF);
  pushMatrix();
  scale(0.6f);
  for (Panel p : panels) {
    p.draw();
  }
  popMatrix();
}

void keyPressed() {
  if (keyCode==CONTROL) {
    loadInputs();
  }
  if (keyCode==LEFT) {
    autorandom^=true;
    println("auto random : "+autorandom);
  }
  if (keyCode==RIGHT) {
    loadInputs();
    // state = (state+1)%3;
    state=2;
    if (state==2) randomizeIndexes();
    println("mode : "+state);
  }
  if (keyCode==UP) {
    currentModelId=(currentModelId+1)%params.getChildren("model").length;
    String title = params.getChildren("model")[currentModelId].getString("title");
    println(title);
    loadModel();
  }
  if (keyCode=='E') {
    println("export...");
    int maxCombinations = 1;
    for (Panel p : panels) p.nbAltUsed.clear();
    for (Panel p : panels) maxCombinations *= p.altImages.size();
    ArrayList<String> combinationsDone = new ArrayList<String>();
    for (int i=0; i<min(100, maxCombinations); i++) {
      boolean ok = false;
      String thisCombination = "";
      while (!ok) {
        for (Panel p : panels) p.randomizeIndex();
        thisCombination = "";
        for (int j=0; j<panels.size(); j++) thisCombination += "_"+panels.get(j).currentIndex;
        ok = true;
        for (String s : combinationsDone) if (s.equals(thisCombination)) ok = false;
        if (ok) combinationsDone.add(thisCombination);
      }
      for (int pa=0; pa<params.getChildren("model")[currentModelId].getChildren("page").length; pa++) {
        int wP = params.getChildren("model")[currentModelId].getChildren("page")[pa].getInt("w");
        int hP = params.getChildren("model")[currentModelId].getChildren("page")[pa].getInt("h");
        XML[] printedPanels = params.getChildren("model")[currentModelId].getChildren("page")[pa].getChildren("panel");
        PGraphics thisPage = createGraphics(wP, hP, JAVA2D);
        thisPage.beginDraw();
        thisPage.background(0xFF);
        for (int j=0; j<printedPanels.length; j++) {
          XML printedPanel = printedPanels[j];
          thisPage.image(panels.get(printedPanel.getInt("id")).getCurrentImage(), printedPanel.getInt("x"), printedPanel.getInt("y"), printedPanel.getInt("w"), printedPanel.getInt("h"));
        }
        thisPage.endDraw();
        thisPage.save(dataPath("result/"+nf(i, 5)+thisCombination+".png"));
      }
    }
    println("...done");
  }
}

void loadInputs() {
  println("loading...");

  sortFiles();

  XML thePic = params.getChildren("model")[currentModelId].getChild("picture");// the picture params

  // for each scanned folder
  for (XML folder : thePic.getChildren("folder")) {

    // for each file in this folder
    String[] inputUrl = getAllFilesFrom(dataPath("input/"+folder.getString("name")));
    for (int i=0; i<inputUrl.length; i++) {

      // if not done already
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println(inputUrl[i]);

        // for each declared panel
        for (XML inputPanel : folder.getChildren("panel")) {

          PImage thisScan = loadImage(inputUrl[i]);
          PImage thisSubScan = thisScan.get(inputPanel.getInt("x"), inputPanel.getInt("y"), inputPanel.getInt("w"), inputPanel.getInt("h"));

          // apply mask if needed
          PImage mask = null;
          if (inputPanel.hasAttribute("mask")) {
            mask = loadImage(dataPath("files/"+inputPanel.getString("mask")));
            mask.resize(thisSubScan.width, thisSubScan.height);
            thisSubScan.mask(mask);
          }

          XML[] possiblePanels = new XML[1];
          possiblePanels[0] = inputPanel;

          process(thisSubScan, inputUrl[i], possiblePanels);
        }

        doneUrls.add(inputUrl[i]);
      }
    }
  }

  println("...done");
}

class Panel {
  PImage orig;
  ArrayList<PImage> altImages = new ArrayList<PImage>();
  ArrayList<String> altUrl = new ArrayList<String>();
  PVector origPos;
  PVector origSize;
  int currentIndex = -1;
  ArrayList<Integer> nbAltUsed = new ArrayList<Integer>();
  Panel(PImage fullPic, int x, int y, int w, int h) {
    orig = fullPic.get(x, y, w, h);
    origPos = new PVector(x, y);
    origSize = new PVector(w, h);
  }
  Panel() {
  }
  void draw() {
    if (origPos!=null&&origSize!=null) {
      image(getCurrentImage(), 0, 0, getCurrentImage().width*0.4, getCurrentImage().height*0.4);
    }
  }
  PImage getCurrentImage() {
    if (state == 0) return orig;
    if (state == 1) {
      if (altImages.size()>0) return altImages.get(altImages.size()-1);
      else return orig;
    }
    if (state == 2) {
      if (altImages.size()>0&&currentIndex>=0) return altImages.get(currentIndex);
      else return orig;
    }
    return null;
  }
  String getCurrentUrl() {
    if (state == 0) return "";
    if (state == 1) {
      if (altImages.size()>0) return altUrl.get(altUrl.size()-1);
      else return "";
    }
    if (state == 2) {
      if (altImages.size()>0&&currentIndex>=0) return altUrl.get(currentIndex);
      else return "";
    }
    return null;
  }
  PImage getAltImageWithUrl(String url) {
    for (int i=0; i<altUrl.size(); i++) {
      if (altUrl.get(i).equals(url)) return altImages.get(i);
    }
    return null;
  }
  void randomizeIndex() {
    int smallestNumberUsed = 0;
    for (int u : nbAltUsed) smallestNumberUsed = max(u, smallestNumberUsed);
    while (nbAltUsed.size()<altImages.size()) nbAltUsed.add(0);
    do {
      currentIndex = floor(random(altImages.size()));
    } while (nbAltUsed.get(currentIndex)>smallestNumberUsed);
    nbAltUsed.set(currentIndex, nbAltUsed.get(currentIndex)+1);
  }
}

void process(PImage input, String url, XML[] panelParams) {
  if (panelParams.length==1) {
    panels.get(panelParams[0].getInt("id")).altImages.add(input);
    panels.get(panelParams[0].getInt("id")).altUrl.add(url);
  } else {
  }
}

float levelOfDarkness(PImage thisPart) {
  float score = 0;
  for (int x=0; x<thisPart.width; x++) {
    for (int y=0; y<thisPart.height; y++) {
      color c = thisPart.get(x, y);
      score += (0xFF-red(c))+(0xFF-green(c))+(0xFF-blue(c));
    }
  }
  return score;
}

void randomizeIndexes() {
  for (Panel p : panels) p.randomizeIndex();
}

void drawFitInRect(PImage thisImage, PGraphics thisPage, PVector panelPos, PVector panelSize, float rotations) {
  float imageScale = min(panelSize.x/thisImage.width, panelSize.y/thisImage.height);
  if (rotations%2==1) imageScale = min(panelSize.x/thisImage.height, panelSize.y/thisImage.width);
  PVector imageSize = new PVector((float)thisImage.width*imageScale, (float)thisImage.height*imageScale);
  thisPage.pushMatrix();
  thisPage.translate(panelPos.x+(panelSize.x-imageSize.x)/2, panelPos.y+(panelSize.y-imageSize.y)/2);
  thisPage.translate(imageSize.x/2.0f, imageSize.y/2.0f);
  thisPage.rotate(rotations*HALF_PI);
  thisPage.translate(-imageSize.x/2.0f, -imageSize.y/2.0f);
  thisPage.image(thisImage, 0, 0, imageSize.x, imageSize.y);
  thisPage.popMatrix();
  thisPage.noFill();
  thisPage.strokeWeight(10);
  // thisPage.rect(panelPos.x, panelPos.y, panelSize.x, panelSize.y);
}

void loadModel() {
  XML thePic = params.getChildren("model")[currentModelId].getChild("picture");
  PImage origPic = loadImage(dataPath("files/"+thePic.getString("filename")));
  origSize = new PVector(origPic.width, origPic.height);
  panels.clear();
  doneUrls.clear();
  for (int i=0; i<thePic.getChild("origPanels").getChildren("panel").length; i++) {
    XML thisPanelParams = thePic.getChild("origPanels").getChildren("panel")[i];
    if (thisPanelParams.hasAttribute("mask")) {
      PImage theMask = loadImage(dataPath("files/"+thisPanelParams.getString("mask")));
      theMask.resize(origPic.width, origPic.height);
      origPic.mask(theMask);
    }
    panels.add(new Panel(origPic, thisPanelParams.getInt("x"), thisPanelParams.getInt("y"), thisPanelParams.getInt("w"), thisPanelParams.getInt("h")));
  }
  for (int i=0; i<thePic.getChild("newPanels").getChildren("panel").length; i++) {
    panels.add(new Panel());
  }
}

PImage toImg(String s, int w, int h) {
  PGraphics gr = createGraphics(w, h, JAVA2D);
  gr.beginDraw();
  gr.fill(0);
  gr.textSize(30);
  gr.textAlign(CENTER, CENTER);
  gr.text(s, 0, 0, w, h);
  gr.endDraw();
  return gr.get();
}

void sortFiles() {
  String[] filesInput = getAllFilesFrom(dataPath("input"));
  for (int i=0; i<filesInput.length; i++) {
    String prefix = filesInput[i];
    if (!prefix.substring(prefix.length()-4, prefix.length()).equals(".png")) prefix = "";
    while (strPos(prefix, "\\")!=-1) prefix=prefix.substring(strPos(prefix, "\\")+1, prefix.length());
    if (prefix.length()>=8) prefix = prefix.substring(0, 8);
    else prefix="";
    if (!prefix.equals("")) {
      File in = new File(filesInput[i]);
      File out = new File(filesInput[i].substring(0, filesInput[i].length()-32)+prefix+"\\"+filesInput[i].substring(filesInput[i].length()-32, filesInput[i].length()));
      try {
        copyFile(in, out);
        in.delete();
        println("moved : "+filesInput[i]);
      }
      catch(Exception e) {
        println(e);
      }
    }
  }
}
