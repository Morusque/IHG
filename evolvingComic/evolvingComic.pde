
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

int nbZinesMade = 0;

void setup() {
  size(1500, 500);
  frameRate(50);
  sortFiles();
  params = loadXML(dataPath("files/models.xml"));
  loadModel();
}

void draw() {
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
  if (keyCode==RIGHT) {
    loadInputs();
    // state = (state+1)%3;
    state = 2;
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
    state = 2;
    String title = params.getChildren("model")[currentModelId].getString("title");
    XML printingStats;
    if (new File(dataPath("/zine/"+title+"/stats.xml")).exists()) {
      printingStats = loadXML(dataPath("/zine/"+title+"/stats.xml"));
    } else {
      printingStats = parseXML("<stats><printingDone quantity=\"0\" /></stats>");
      saveXML(printingStats, dataPath("/zine/"+title+"/stats.xml"));
    }
    nbZinesMade = printingStats.getChild("printingDone").getInt("quantity");
    XML[] pagesParams = params.getChildren("model")[currentModelId].getChildren("page");
    XML[] printsParams = params.getChildren("model")[currentModelId].getChildren("print");
    ArrayList<PImage> pages = new ArrayList<PImage>();
    ArrayList<String> urlUsed = new ArrayList<String>();
    for (XML pageParam : pagesParams) {
      for (int variation = 0; variation < pageParam.getInt("quantity"); variation++) {
        randomizeIndexes();
        PGraphics thisPage = createGraphics(pageParam.getInt("w"), pageParam.getInt("h"), JAVA2D);
        thisPage.beginDraw();
        for (XML panelParam : pageParam.getChildren("panel")) {
          Panel thisPanel = panels.get(panelParam.getInt("id"));
          PImage thisImage = thisPanel.getCurrentImage();
          urlUsed.add(thisPanel.getCurrentUrl());
          PVector panelSize = new PVector(panelParam.getInt("w"), panelParam.getInt("h"));
          float rotations = panelParam.getInt("r");
          PVector panelPos = new PVector(panelParam.getInt("x"), panelParam.getInt("y"));        
          drawFitInRect(thisImage, thisPage, panelPos, panelSize, rotations);
        }
        for (XML panelParam : pageParam.getChildren("specialPanel")) {
          if (panelParam.getString("type").equals("edition")) {
            PImage thisImage = toImg("#"+nf(printingStats.getChild("printingDone").getInt("quantity")+1, 4), 1000, 200);
            printingStats.getChild("printingDone").setInt("quantity", printingStats.getChild("printingDone").getInt("quantity")+1);
            saveXML(printingStats, dataPath("/zine/"+title+"/stats.xml"));
            PVector panelSize = new PVector(panelParam.getInt("w"), panelParam.getInt("h"));
            float rotations = panelParam.getInt("r");
            PVector panelPos = new PVector(panelParam.getInt("x"), panelParam.getInt("y"));        
            drawFitInRect(thisImage.get(), thisPage, panelPos, panelSize, rotations);
          }
          if (panelParam.getString("type").equals("author")) {
            String authorUrl = "";
            for (String url : urlUsed) {
              if (authorUrl.equals("")) {
                XML thisAuthor = null;
                for (XML author : printingStats.getChildren("author")) {
                  if (author.getString("url").equals(url)) thisAuthor=author;
                }
                if (thisAuthor==null) {
                  authorUrl = url;
                  thisAuthor = new XML("author");
                  thisAuthor.setString("url", authorUrl);
                  thisAuthor.setInt("quantity", 1);
                  printingStats.addChild(thisAuthor);
                  saveXML(printingStats, dataPath("/zine/"+title+"/stats.xml"));
                } else if (thisAuthor.getInt("quantity")==0) {
                  authorUrl = thisAuthor.getString("url");
                  thisAuthor.setInt("quantity", thisAuthor.getInt("quantity")+1);
                  saveXML(printingStats, dataPath("/zine/"+title+"/stats.xml"));
                }
              }
            }
            if (!authorUrl.equals("")) {
              PImage thisImage = panels.get(panelParam.getInt("id")).getAltImageWithUrl(authorUrl);
              PVector panelSize = new PVector(panelParam.getInt("w"), panelParam.getInt("h"));
              float rotations = panelParam.getInt("r");
              PVector panelPos = new PVector(panelParam.getInt("x"), panelParam.getInt("y"));        
              drawFitInRect(thisImage, thisPage, panelPos, panelSize, rotations);
            }
          }
        }        
        thisPage.endDraw();
        pages.add(thisPage.get());
      }
    }
    ArrayList<PImage> prints = new ArrayList<PImage>();
    for (XML printParams : printsParams) {
      PGraphics thisPrint = createGraphics(printParams.getInt("w"), printParams.getInt("h"), JAVA2D);
      thisPrint.beginDraw();
      thisPrint.background(0xFF);
      XML[] pPagesParams = printParams.getChildren("page");
      for (XML pPagesParam : pPagesParams) {
        PImage thisImage = pages.get(pPagesParam.getInt("id"));
        PVector pagePos = new PVector(pPagesParam.getInt("x"), pPagesParam.getInt("y"));
        PVector pageSize = new PVector(pPagesParam.getInt("w"), pPagesParam.getInt("h"));
        float rotations = pPagesParam.getInt("r");
        drawFitInRect(thisImage, thisPrint, pagePos, pageSize, rotations);
      }
      thisPrint.endDraw();
      prints.add(thisPrint);
    }
    for (int i=0; i<prints.size(); i++) prints.get(i).save(dataPath("/zine/"+title+"/"+nf(nbZinesMade+1, 5)+"/"+i+".png"));
    nbZinesMade++;
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

        for (XML inputPanel : folder.getChildren("choice")) {
          // TODO this
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
  Panel(PImage fullPic, int x, int y, int w, int h) {
    orig = fullPic.get(x, y, w, h);
    origPos = new PVector(x, y);
    origSize = new PVector(w, h);
  }
  Panel() {
  }
  void draw() {
    if (origPos!=null&&origSize!=null) {
      noFill();
      stroke(0);
      strokeWeight(5);
      image(getCurrentImage(), origPos.x, origPos.y, origSize.x, origSize.y);
      rect(origPos.x, origPos.y, origSize.x, origSize.y);
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
    currentIndex = floor(random(altImages.size()));
  }
}

void process(PImage input, String url, XML[] panelParams) {
  if (panelParams.length==1) {
    panels.get(panelParams[0].getInt("id")).altImages.add(input);
    panels.get(panelParams[0].getInt("id")).altUrl.add(url);
  } else {
    /*
      int bestI = -1;
     if (forceId==-1) {
     for (int i=0; i<cuts.size(); i++) {
     if (bestI==-1) bestI = i;
     else if (levelOfDarkness(cuts.get(i))>levelOfDarkness(cuts.get(bestI))) bestI = i;
     }
     } else {
     bestI = forceId;
     }
     if (bestI>-1) {
     panels.get(bestI).altImages.add(cuts.get(bestI));
     panels.get(bestI).altUrl.add(url);
     }
     */
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
