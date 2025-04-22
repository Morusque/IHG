
float marginSize = 120;
PFont font;
String[] mots;
int nbExports = 0;

void setup() {
  size(700, 900);
  font = createFont(dataPath("files/Helvetica.ttf"), 200);
  mots = loadStrings(dataPath("files/mots.txt"));
  generate();
}

void draw() {
}

void keyPressed() {
  generate();
  if (key == TAB) { 
    for (int i=0; i<50; i++) {
      generate();
    }
  }
}

class Box {
  PVector position;
  PVector size;
}

void generate() {
  int nbRaws = floor(random(2, 4));
  int[] nbBoxesPerRaw = new int[nbRaws];
  for (int i=0; i<nbRaws; i++) {
    nbBoxesPerRaw[i] = floor(random(2, 4));
  }
  PGraphics page = createGraphics(5000, 7071);
  page.beginDraw();
  page.background(0xFF);
  float boxHeight = (page.height - (marginSize * (nbRaws + 1)))/nbRaws;
  for (int i=0; i<nbRaws; i++) {
    float boxWidth = (page.width - (marginSize * (nbBoxesPerRaw[i] + 1)))/nbBoxesPerRaw[i];
    for (int j=0; j<nbBoxesPerRaw[i]; j++) {
      page.strokeWeight(40);
      page.stroke(0);
      page.noFill();
      page.rect(marginSize*(j+1) + boxWidth*j, marginSize*(i+1) + boxHeight*i, boxWidth, boxHeight);
      if (random(1)<1.0) {
        page.textFont(font);
        page.textSize(200);
        page.fill(0);
        String mot = mots[floor(random(mots.length))];
        // page.text(mot, marginSize*(j+1) + boxWidth*j + 5 + 20 + random(boxWidth - 10 - 40 - page.textWidth(mot)), marginSize*(i+1) + boxHeight*i + 20 + 20 + 5 + random(boxHeight - 10 - 20 - 40));
        page.text(mot, marginSize*(j+1) + boxWidth*j + 5 + 100 + random(boxWidth - 10 - 200 - page.textWidth(mot)), marginSize*(i+1) + boxHeight*i + 20 + 200 + 5 + random(boxHeight - 10 - 200 - 40));
      }
    }
  }
  page.endDraw();
  image(page, 0, 0);
  page.save(dataPath("export/"+nf(nbExports++,4)+".png"));
}
