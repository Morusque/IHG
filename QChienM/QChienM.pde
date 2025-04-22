
ArrayList<String> doneUrls = new ArrayList<String>();

PImage frame;
PImage[] backgrounds = new PImage[7];
DogModel[] dogModels = new DogModel[7];

int nbExported = 0;

boolean savePics = true;

PImage firstPic;

void setup() {
  size(930, 699);
  frameRate(10);
  println("loading assets...");
  String[] doneUrlsArray = loadStrings(dataPath("files/done.txt"));
  for (String s : doneUrlsArray) doneUrls.add(s);
  frame = loadImage(dataPath("files/frame_01.png"));
  for (int i=0; i<backgrounds.length; i++) backgrounds[i] = loadImage(dataPath("files/back_"+nf(i+1, 2)+".png"));
  for (int i=0; i<dogModels.length; i++) dogModels[i] = new DogModel(i+1);
  println("...done");
  background(0xFF);
}

void draw() {
  if (frameCount%50==0) generateRandom();
}

class DogModel {
  PImage base;
  PImage text;
  ArrayList<String> shirts = new ArrayList<String>();
  ArrayList<String> speeches = new ArrayList<String>();
  ArrayList<String> options = new ArrayList<String>();
  DogModel(int index) {
    base = loadImage(dataPath("files/dog_"+nf(index, 2)+"_base.png"));
    text = loadImage(dataPath("files/text_"+nf(index, 2)+".png"));
    for (int i=0;; i++) {
      String fileName = dataPath("files/dog_"+nf(index, 2)+"_shirt_"+nf(i+1, 2)+".png");
      if ((new File(dataPath(fileName))).exists()) {
        shirts.add((fileName));
      } else {
        break;
      }
    }
    for (int i=0;; i++) {
      String fileName = dataPath("files/dog_"+nf(index, 2)+"_speech_"+nf(i+1, 2)+".png");
      if ((new File(dataPath(fileName))).exists()) {
        speeches.add((fileName));
      } else {
        break;
      }
    }
    for (int i=0;; i++) {
      String fileName = dataPath("files/dog_"+nf(index, 2)+"_option_"+nf(i+1, 2)+".png");
      if ((new File(dataPath(fileName))).exists()) {
        options.add((fileName));
      } else {
        break;
      }
    }
    println("dog "+(index)+" "+shirts.size()+" "+speeches.size()+" "+options.size());
  }
}

void keyPressed() {
  if (keyCode == CONTROL) {
    println("loading...");
    String[] inputUrl = getAllFilesFrom(dataPath("input"));
    for (int i=0; i<inputUrl.length; i++) {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println("file : "+inputUrl[i]);
        PImage im = loadImage(inputUrl[i]);
        process(im);
        doneUrls.add(inputUrl[i]);
      }
    }
    saveStrings(dataPath("files/done.txt"), doneUrls.toArray(new String[doneUrls.size()]));
    println("...done");
  }
  if (keyCode == RIGHT) {
    generateRandom();
  }
  if (keyCode == BACKSPACE) {
    doneUrls.clear();
    println("done urls list cleared");
  }
}

void generateRandom() {
  generate(new int[]{floor(random(7)), floor(random(7)), floor(random(7)), floor(random(7)), floor(random(7))}, createImage(1489, 127, RGB), false);
}

void process(PImage im) {
  float boxesXStart = 80;
  float boxesXSpace = 317;
  float[] boxesYPos = new float[]{225, 683, 889, 1097, 1301};
  PVector boxesSize = new PVector(70, 70);
  int[] answers = new int[5];
  for (int i=0; i<answers.length; i++) {
    float bestScore = 0;
    for (int j=0; j<7; j++) {
      // im.get(floor(boxesXStart+boxesXSpace*j), floor(boxesYPos[i]), floor(boxesSize.x), floor(boxesSize.y)).save("test_"+i+"_"+j+".png");
      PVector currentPos = new PVector(boxesXStart+boxesXSpace*j, boxesYPos[i]);
      float currentScore = 0;
      for (int x=0; x<boxesSize.x; x++) {
        for (int y=0; y<boxesSize.y; y++) {
          currentScore += 0x100 - brightness(im.get(floor(currentPos.x+x), floor(currentPos.y+y)));
        }
      }
      if (currentScore>bestScore) {
        bestScore = currentScore;
        answers[i]=j;
      }
    }
  }
  for (int i=0; i<answers.length; i++) println(answers[i]);
  generate(answers, im.get(1281, 85, 820, 83), savePics);
}

void generate(int[] answers, PImage name, boolean savePicsB) {
  int dogType = 0;
  float bestScore = 0;
  int[] hashes = new int[3];
  for (int i=0; i<7; i++) hashes[0] += floor(answers[(i+0)%5]*pow(7, i));
  for (int i=0; i<7; i++) hashes[1] += floor(answers[(i+1)%5]*pow(7, i));
  for (int i=0; i<7; i++) hashes[2] += floor(answers[(i+2)%5]*pow(7, i));
  for (int type = 0; type < 7; type++) {
    float score=0;
    for (int i=0; i<answers.length; i++) if (answers[i]==type) score += (1-((float)i/10));
    if (score>bestScore) {
      bestScore = score;
      dogType = type;
    }
  }
  println("dog type : "+dogType);
  // println(totalHash);
  //
  PGraphics pic = createGraphics(3496, 2481, JAVA2D);
  pic.beginDraw();
  pic.image(frame, 0, 0, pic.width, pic.height);
  pic.image(backgrounds[answers[3]], 0, 0, pic.width, pic.height);
  pic.image(dogModels[dogType].base, 0, 0, pic.width, pic.height);
  pic.image(loadImage(dogModels[dogType].shirts.get((hashes[0])%dogModels[dogType].shirts.size())), 0, 0, pic.width, pic.height);
  pic.image(loadImage(dogModels[dogType].speeches.get((hashes[1])%dogModels[dogType].speeches.size())), 0, 0, pic.width, pic.height);
  pic.image(loadImage(dogModels[dogType].options.get((hashes[2])%dogModels[dogType].options.size())), 0, 0, pic.width, pic.height);
  pic.endDraw();
  PGraphics print = createGraphics(3496*2, 4961, JAVA2D);
  print.beginDraw();
  print.background(0xFF);
  print.image(dogModels[dogType].text, 0, 0, dogModels[dogType].text.width, dogModels[dogType].text.height);
  name = paintInBlue(name);
  print.image(name, 665, 321, 1497, 133);
  print.image(pic, 0, 2481, pic.width, pic.height);
  if (savePicsB) {
    if (firstPic==null) {
      print.endDraw();
      firstPic = print.get(); 
      print.save(dataPath("results/result"+nf(nbExported, 4)+".png"));
    } else {
      print.image(firstPic, 3496, 0);
      print.endDraw();
      firstPic = null;
      print.save(dataPath("results/result"+nf(nbExported++, 4)+".png"));
      println("pic saved");
    }
    println("pic saved");
  }
  image(pic.get(), 0, 0, width, height);
}

PImage paintInBlue(PImage in) {
  PGraphics out = createGraphics(in.width, in.height, JAVA2D);
  out.beginDraw();
  for (int x=0; x<in.width; x++) {
    for (int y=0; y<in.height; y++) {
      float level = brightness(in.get(x, y));
      if (level<0x80) {
        out.stroke(0x00, 0x9f, 0xe3);
        out.point(x, y);
      }
    }
  }
  out.endDraw();
  return out.get();
}
