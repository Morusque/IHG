
ArrayList<String> doneUrls = new ArrayList<String>();

ArrayList<TypoPack> packs = new ArrayList<TypoPack>();
ArrayList<LetterModel> models = new ArrayList<LetterModel>();

int nbPartTypes = 6;

PImage mask;

float autoSwitchPack = 9;

int mode = 2;// 0 = edit, 1 = alphabet = 2 = title display
PartPlace currentPart;
LetterModel currentLetter;
XML typoParams;

int[] currentPacks = new int[4];
int currentPackIndex = 0;

PGraphics global;

void setup() {
  // size(1700, 900);
  fullScreen(2);
  frameRate(30);
  
  mask = loadImage(dataPath("files/mask.png"));
  global = this.g;

  typoParams = loadXML(dataPath("files/typo.xml"));

  XML[] letters = typoParams.getChildren("letter");
  for (XML letter : letters) {
    XML[] parts = letter.getChildren("part");
    LetterModel letterModel;
    letterModel = new LetterModel(letter.getString("char").charAt(0));
    for (XML part : parts) {
      letterModel.addPart(new PartPlace(part.getInt("type"), part.getFloat("x"), part.getFloat("y"), part.getFloat("rotation"), part.getFloat("hScale")));
    }
    models.add(letterModel);
  }

  currentLetter = new LetterModel(' ');
  currentPart = new PartPlace(0, 0, 0, 0, 1);
}

void draw() {
  if (autoSwitchPack!=-1 && frameCount%autoSwitchPack==1 && packs.size()>0) {
    if (mode==0 || mode==1) {
      currentPacks[0] = (currentPacks[0]+1)%packs.size();
    } else if (mode==2) {
      currentPacks[currentPackIndex] = (currentPacks[currentPackIndex]+(currentPackIndex+1))%packs.size();
      currentPackIndex=(currentPackIndex+1)%currentPacks.length;
    }
  }
  if (mode==0) {
    background(0xD0);
    stroke(0x80);
    float stepSize = 10;
    for (int x=0; x<width; x+=stepSize) line(x, 0, x, height);
    for (int y=0; y<height; y+=stepSize) line(0, y, width, y);
    currentLetter.drawAt(0, 0, global, currentPacks[0]);
    if (currentPart!=null) {
      currentPart.position = new PVector(floor((float)mouseX/stepSize)*stepSize, floor((float)mouseY/stepSize)*stepSize);
      currentPart.draw(global,currentPacks[0]);
    }
    noFill();
    stroke(0, 0, 0xFF);
    ellipse(floor((float)mouseX/stepSize)*stepSize, floor((float)mouseY/stepSize)*stepSize, 5, 5);
  } else if (mode==1) {
    if (models.size()>0) {
      if (frameCount%50==0) currentlyDisplayed = (currentlyDisplayed+1)%models.size();
      background(0xD0);
      pushMatrix();
      scale(2.0f);
      models.get(currentlyDisplayed).drawAt(100, 100, global, currentPacks[0]);
      popMatrix();
    }
  } else if (mode==2) {
    if (models.size()>0) {
      background(0);
      drawText("institut", 50, 50, currentPacks[0]);
      drawText("d hypotheses", 50, 300, currentPacks[1]);
      drawText("graphiques", 50, 550, currentPacks[2]);
      drawText("            bienvenue", 50, 850, currentPacks[3]);
    }
  }
}

class TypoPack {
  PImage[] parts = new PImage[6];
  TypoPack(PImage im) {
    // im = im.get(118,103,3310,2346);
    im = im.get(0,-24,3513,2634);
    im.resize(800, 600);
    // im.save("test.png");
    im.mask(mask);
    float mult = 4;
    parts[0] = im.get(28, 146, 116, 283);
    parts[0].resize(floor(20*mult), floor(50*mult));
    parts[1] = im.get(174, 146, 53, 284);
    parts[1].resize(floor(10*mult), floor(50*mult));
    parts[2] = im.get(273, 203, 53, 169);
    parts[2].resize(floor(10*mult), floor(30*mult));
    parts[3] = im.get(371, 231, 53, 113);
    parts[3].resize(floor(10*mult), floor(20*mult));
    parts[4] = im.get(475, 245, 160, 85);
    parts[4].resize(floor(30*mult), floor(15*mult));
    parts[5] = im.get(666, 246, 105, 86);
    parts[5].resize(floor(20*mult), floor(15*mult));
  }
}

int currentlyDisplayed = 0;
int nbExported = 0;

void keyPressed() {
  if (keyCode == SHIFT) {
    mode=(mode+1)%3;
  }
  if (keyCode == UP) currentPacks[0] = (currentPacks[0]+1)%packs.size();
  if (keyCode == DOWN) currentPacks[0] = (currentPacks[0]-1+packs.size())%packs.size();
  if (mode==0) {
    if (keyCode==107) {// +
      currentLetter = models.get((models.indexOf(currentLetter)+1)%models.size());
    }
    if (keyCode==RIGHT) currentPart.partType = (currentPart.partType+1)%nbPartTypes;
    if (keyCode==LEFT) currentPart.partType = (currentPart.partType-1+nbPartTypes)%nbPartTypes;
    if (keyCode==BACKSPACE) if (currentLetter.parts.size()>0) currentLetter.parts.remove(currentLetter.parts.size()-1);
    if (keyCode==ENTER) {
      XML letter = new XML("letter");
      letter.setString("char", str(currentLetter.letter));
      for (PartPlace p : currentLetter.parts) {
        XML part = new XML("part");
        part.setString("type", str(p.partType));
        part.setString("x", str(p.position.x));
        part.setString("y", str(p.position.y));
        part.setString("rotation", str(p.rotation));
        part.setString("hScale", str(p.hScale));
        letter.addChild(part);
      }
      typoParams.addChild(letter);
      if (!models.contains(currentLetter)) models.add(currentLetter);
      currentLetter = new LetterModel(' ');
    }
    if (keyCode==TAB) {
      saveXML(typoParams, dataPath("files/typo.xml"));
    }
  } else {
    if (keyCode==TAB) {
      save(dataPath("result/"+nf(nbExported++, 4)+".png"));
    }
  }
  if (keyCode == CONTROL) {
    println("loading...");
    String[] inputUrl = getAllFilesFrom(dataPath("input"));
    for (int i=0; i<inputUrl.length; i++) {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println("file : "+inputUrl[i]);
        packs.add(new TypoPack(loadImage(inputUrl[i])));
        doneUrls.add(inputUrl[i]);
      }
    }
    println("...done");
  }
}

void mousePressed() {
  if (mode==0) {
    if (mouseButton==LEFT) {
      currentLetter.addPart(currentPart);
      currentPart = new PartPlace(currentPart);
    }
    if (mouseButton==RIGHT) {
      currentPart.rotation = currentPart.rotation+1;
      if (currentPart.rotation==4) {
        currentPart.hScale = -currentPart.hScale;
        currentPart.rotation=0;
      }
    }
  }
}

class PartPlace {
  int partType;
  PVector position;
  float rotation;
  float hScale;
  PartPlace(int partType, float x, float y, float rotation, float hScale) {
    this.partType = partType;
    this.position = new PVector(x, y);
    this.rotation = rotation;
    this.hScale = hScale;
  }
  PartPlace(PartPlace toCopy) {
    this.partType = toCopy.partType;
    this.position = toCopy.position;
    this.rotation = toCopy.rotation;
    this.hScale = toCopy.hScale;
  }
  void draw(PGraphics g, int pack) {
    g.pushMatrix();
    g.translate(position.x, position.y);
    g.scale(hScale, 1);
    g.rotate(rotation*HALF_PI);
    if (packs.size()>0) {
      g.image(packs.get(pack).parts[partType], 0, 0);
      if (mode==0) {
        g.noFill();
        g.stroke(0, 0, 0xFF);
        g.rect(0, 0, packs.get(0).parts[partType].width, packs.get(0).parts[partType].height);
      }
    }
    g.popMatrix();
  }
}

class LetterModel {
  ArrayList<PartPlace> parts = new ArrayList<PartPlace>();
  char letter;
  float letterWidth = -1;
  LetterModel(char letter) {
    this.letter=letter;
  }
  void addPart(PartPlace part) {
    parts.add(part);
  }
  void drawAt(float x, float y, PGraphics context, int pack) {
    for (PartPlace p : parts) {
      pushMatrix();
      translate(x, y);
      p.draw(context,pack);
      popMatrix();
    }
  }
  float letterWidth() {
    if (letterWidth==-1) {
      PGraphics temp = createGraphics(500, 500);
      temp.beginDraw();
      drawAt(0, 0, temp, currentPacks[0]);
      temp.endDraw();
    outerloop :
      for (int x=499; x>=0; x--) {
        for (int y=0; y<500; y++) {
          if (alpha(temp.get(x, y))>0) {
            letterWidth=x+1;
            break outerloop;
          }
        }
      }
    }
    return letterWidth;
  }
}

void drawText(String text, float x, float y, int pack) {
  float pos = 0;
  for (int l=0; l<text.length(); l++) {
    char thisChar = text.charAt(l);
    for (LetterModel model : models) {
      if (model.letter==thisChar) {
        model.drawAt(pos+x, y, global, pack);
        pos += model.letterWidth()+15;
      }
    }
    if (thisChar==' ') {
      pos+=50;
    }
  }
}
