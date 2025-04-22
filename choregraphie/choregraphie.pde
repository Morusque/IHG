
ArrayList<String> doneUrls = new ArrayList<String>();

ArrayList<Planche> planches = new ArrayList<Planche>();

int currentDisplayedDanceIndex = 0;

ArrayList<Dance> savedDances = new ArrayList<Dance>();
int currentSavedDanceIndex = 0;

float tempo = 130;// bpm
float tapMillis = 0;
int currentNbBeats = 4;

Dance currentDance;
Dance sidekickDance;

float phasorOffset = 0;
float phasorPos = 0;

int currentDanceDisplayedNTimes = 0;

int mode = 0;
// 0 = original dances
// 1 = random dances
// 2 = sidekick dances

int nbGeneratedPoses = 4;

int autoNextEvery = 0;

boolean pause = false;

boolean reverse = false;

boolean gribouillisMode = false;

void setup() {
  // size(1700, 1000);
  fullScreen(2);
  // frame.toFront();
  // frame.requestFocus();
}

void draw() {
  background(0xFF);
  float tempoMs = currentNbBeats*1000.0f*60.0f/tempo;
  if (!pause) {
    phasorPos = millis() - phasorOffset;
    phasorPos /= tempoMs;
    if (reverse) phasorPos = 1 - phasorPos;
  } else {
    phasorOffset += 1000.0f/frameRate;
  }
  while (phasorPos>=1.0f || phasorPos<0.0f) {
    phasorPos=(phasorPos+1.0f)%1.0f;
    phasorOffset = millis();
    currentDanceDisplayedNTimes++;
    if (autoNextEvery>0) {
      if (currentDanceDisplayedNTimes>=autoNextEvery) {
        if (planches.size()>0) {
          currentDisplayedDanceIndex = (currentDisplayedDanceIndex+1)%planches.size();
          currentDanceDisplayedNTimes=0;
          generateDance();
          phasorOffset = millis();
        }
      }
    }
  }
  if (currentDance!=null) currentDance.draw();
  if (sidekickDance!=null && mode==2) sidekickDance.drawSidekick();
  // saveFrame(dataPath("result/result#####.png"));
}

void keyPressed() {
  if (keyCode == CONTROL) {// load
    println("loading...");
    String[] inputUrl = getAllFilesFrom(dataPath("input"));
    if (gribouillisMode) inputUrl = getAllFilesFrom(dataPath("../../gribouillis/gribouilliSplit/data/processed/danse"));
    for (int i=0; i<inputUrl.length; i++) {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println("file : "+inputUrl[i]);
        PImage im = loadImage(inputUrl[i]);
        planches.add(new Planche(im, gribouillisMode));
        doneUrls.add(inputUrl[i]);
      }
    }
    println("...done");
  }
  if (keyCode == ENTER) {// next dance
    if (planches.size()>0) currentDisplayedDanceIndex = (currentDisplayedDanceIndex+1)%planches.size();
    generateDance();
    phasorOffset = millis();
    pause = false;
  }
  if (keyCode == 151) {// * previous dance
    if (planches.size()>0) currentDisplayedDanceIndex = (currentDisplayedDanceIndex-1+planches.size())%planches.size();
    generateDance();
    phasorOffset = millis();
  }
  if (keyCode == RIGHT) {// switch mode
    mode = (mode+1)%3;
    println("mode : "+mode);
  }
  if (keyCode == LEFT) {
    phasorOffset = millis();
  }
  if (keyCode == UP) {
    tempo+=1;
    println("current tempo " + tempo);
  }
  if (keyCode == DOWN) {
    tempo-=1;
    println("current tempo " + tempo);
  }
  if (key == 'o') {
    phasorOffset = millis();
  }
  if (key == 's') {
    savedDances.add(currentDance);
  }
  if (key == 'l'||key == 'k') {
    if (savedDances.size()>0) {
      if (key=='k') currentSavedDanceIndex = (currentSavedDanceIndex-1+savedDances.size())%savedDances.size();
      if (key=='l') currentSavedDanceIndex = (currentSavedDanceIndex+1)%savedDances.size();
      currentDance = savedDances.get(currentSavedDanceIndex);
    }
  }
  if (key == 't') {// tap tempo
    float tempoMs = currentNbBeats*1000.0f*60.0f/tempo;
    float lap = millis()-tapMillis;
    tapMillis = millis();
    if (lap > (1000/frameRate)*2) {
      if (lap < 1000.0f*60.0f/tempo *2) {
        phasorPos = millis() - phasorOffset;
        phasorPos /= tempoMs;
        if (reverse) phasorPos = 1 - phasorPos;
        tempo = 60/(lap/1000);
        tempoMs = currentNbBeats*1000.0f*60.0f/tempo;
        phasorOffset = millis()-(tempoMs*(float)round(phasorPos*currentNbBeats)/currentNbBeats);
      }
    }
  }
  if (key == 'b') {// change number of beats
    currentNbBeats = ((currentNbBeats)%16)+1;
    println("number of beats : "+currentNbBeats);
  }
  if (key=='x') {// auto next beat
    autoNextEvery = (autoNextEvery+1)%9;
    println("auto next every " + autoNextEvery);
  }
  if (key=='p') {// pause
    pause^=true;
    println("pause "+pause);
  }
  if (key=='r') {// reverse
    reverse^=true;
    float tempoMs = currentNbBeats*1000.0f*60.0f/tempo;
    if (reverse) {
      phasorOffset -= (tempoMs-(tempoMs*phasorPos));
      phasorOffset += ((tempoMs*phasorPos));
    } else {
      phasorOffset += (tempoMs-(tempoMs*phasorPos));
      phasorOffset -= ((tempoMs*phasorPos));
    }
    println("reverse "+pause);
  }
  if (key=='g') {// gribouillis
    gribouillisMode ^= true;
    println("gribouillisMode : "+gribouillisMode);
  }
  if (keyCode==TAB) {
    for (currentDisplayedDanceIndex=0; currentDisplayedDanceIndex<planches.size(); currentDisplayedDanceIndex++) {
      currentDance = new Dance();
      for (int i=0;i<currentDance.tdPoses.size();i++) {
        currentDance.tdPoses.get(i).save(dataPath("result/singles/"+nf(currentDisplayedDanceIndex,5)+"_"+nf(i,3)+".png"));
      }
    }
  }
}

class Planche {
  ArrayList<PImage> poses = new ArrayList<PImage>();
  PImage name;
  Planche(PImage scan, boolean gribouillisMode) {
    /*
    poses.add(scan.get(91, 323, 617, 1041));
     poses.add(scan.get(875, 323, 617, 1041));
     poses.add(scan.get(1655, 323, 617, 1041));
     */
    if (gribouillisMode) {
      for (int i=0; i<6; i++) poses.add(scan.get(493*i, 0, 493, 873));
      name = createImage(100, 100, RGB);
    } else {
      poses.add(scan.get(70, 317, 507, 1021));
      poses.add(scan.get(620, 317, 507, 1021));
      poses.add(scan.get(1170, 317, 507, 1021));
      poses.add(scan.get(1720, 317, 507, 1021));
      name = scan.get(525, 1463, 645, 105);
    }
  }
}

class Dance {
  int nbPoses = 0;
  ArrayList<PImage> tdPoses = new ArrayList<PImage>();
  ArrayList<PImage> name = new ArrayList<PImage>();
  ArrayList<Float> tdTimings = new ArrayList<Float>();
  color c;
  Dance() {
    if (planches.size()>0) {
      if (mode==0) {
        Planche chosenPlanche = planches.get(currentDisplayedDanceIndex);
        nbPoses = chosenPlanche.poses.size();
        for (int i=0; i<nbPoses; i++) {
          tdPoses.add(chosenPlanche.poses.get(i));
          tdTimings.add((float)1.0f/nbPoses);
        }
        name.add(chosenPlanche.name);
      }
      if (mode==1) {
        nbPoses = nbGeneratedPoses;
        for (int i=0; i<nbPoses; i++) {
          Planche chosenPlanche = planches.get(floor(random(planches.size())));
          tdPoses.add(chosenPlanche.poses.get(floor(random(chosenPlanche.poses.size()))));
          tdTimings.add((float)1.0f/nbPoses);
          boolean found = false;
          for (PImage n : name) if (n==chosenPlanche.name) found = true;
          if (!found) name.add(chosenPlanche.name);
        }
        /*
        nbPoses = floor(random(2, 5));
         int totalChunks = 0;
         ArrayList<Integer> tdChunckLength = new ArrayList<Integer>();
         for (int i=0; i<nbPoses; i++) {
         int thisChunkLength = floor(random(2, 5));//floor(pow(2, floor(random(4))));
         totalChunks+=thisChunkLength;
         tdChunckLength.add(thisChunkLength);
         }
         */
      }
      if (mode==2) {
        Planche chosenPlanche = planches.get(floor(random(planches.size())));
        nbPoses = chosenPlanche.poses.size();
        for (int i=0; i<nbPoses; i++) {
          tdPoses.add(chosenPlanche.poses.get(i));
          tdTimings.add((float)1.0f/nbPoses);
        }
        name.add(chosenPlanche.name);
      }
    }
    c = color(random(0x50, 0xC0), random(0x50, 0xC0), random(0x50, 0xC0));
  }
  void draw() {
    background(c);
    float cumulativeTiming = 0;
    int currentIndex = -1;
    for (int i=0; i<tdTimings.size() && currentIndex==-1; i++) {
      cumulativeTiming += tdTimings.get(i);
      if (phasorPos <= cumulativeTiming) currentIndex=i;
    }
    if (currentIndex>=0) {
      float scale = 0.7f;
      // image(tdPoses.get(currentIndex), width*1/4-tdPoses.get(currentIndex).width*scale/2, 150, tdPoses.get(currentIndex).width*scale, tdPoses.get(currentIndex).height*scale);
      image(tdPoses.get(currentIndex), width*2/4-tdPoses.get(currentIndex).width*scale/2, 150, tdPoses.get(currentIndex).width*scale, tdPoses.get(currentIndex).height*scale);
      // image(tdPoses.get(currentIndex), width*3/4-tdPoses.get(currentIndex).width*scale/2, 150, tdPoses.get(currentIndex).width*scale, tdPoses.get(currentIndex).height*scale);
    }
    strokeWeight(2);
    cumulativeTiming = 0;
    for (int i=0; i<tdTimings.size(); i++) {
      stroke(0, 0, 0xFF);
      line(cumulativeTiming*width, 0, cumulativeTiming*width, 100);
      image(tdPoses.get(i), cumulativeTiming*width, 0, 50, 100);
      cumulativeTiming += tdTimings.get(i);
    }
    stroke(0xFF);
    line(phasorPos*width-1, 0, phasorPos*width-1, 100);
    stroke(0xFF, 0, 0);
    line(phasorPos*width, 0, phasorPos*width, 100);

    float scale = 0.5f;
    float currentXPos = 50;
    for (int i=0; i<name.size(); i++) {
      if (i>0) {
        textSize(30);
        fill(0);
        text("+", currentXPos+5, height-100+25);
        currentXPos+=35;
      }
      image(name.get(i), currentXPos, height-100, name.get(i).width*scale, name.get(i).height*scale);
      currentXPos += name.get(i).width*scale;
    }
  }
  void drawSidekick() {
    float cumulativeTiming = 0;
    int currentIndex = -1;
    for (int i=0; i<tdTimings.size() && currentIndex==-1; i++) {
      cumulativeTiming += tdTimings.get(i);
      if (phasorPos <= cumulativeTiming) currentIndex=i;
    }
    if (currentIndex>=0) {
      float scale = 0.7f;
      image(tdPoses.get(currentIndex), width*1/4-tdPoses.get(currentIndex).width*scale/2, 150, tdPoses.get(currentIndex).width*scale, tdPoses.get(currentIndex).height*scale);
      pushMatrix();
      translate(width*3/4-tdPoses.get(currentIndex).width*scale/2+tdPoses.get(currentIndex).width*scale, 150);
      scale(-1, 1);
      image(tdPoses.get(currentIndex), 0, 0, tdPoses.get(currentIndex).width*scale, tdPoses.get(currentIndex).height*scale);
      popMatrix();
    }
  }
}

void generateDance() {
  currentDance = new Dance();
  sidekickDance = new Dance();
}
