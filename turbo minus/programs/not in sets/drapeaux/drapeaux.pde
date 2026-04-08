
color[] typicalColors;
int timer = 0;

ArrayList<PImage> symbols = new ArrayList<PImage>();

boolean dark = false;

void setup() {
  size(1920, 1080);
  fullScreen();
  frameRate(30);
  colorMode(RGB);
  imageMode(CENTER);
  String[] files = getAllFilesFrom(dataPath("symbols"));
  for (String f : files) {
    try {
      PImage im = loadImage(f);
      if (im!=null) symbols.add(im);
    }
    catch (Exception e) {
      println(e);
    }
  }
  typicalColors = new color[]{
    color(0),
    color(255),
    color(255, 223, 230), // rose pâle
    color(207, 57, 255), // violet
    color(0, 255, 161), // vert
    color(255, 74, 45), // rouge
    color(0, 247, 255), // bleu
    color(255, 243, 110)  // jaune
  };
  generate();
}

void draw() {
  if (timer>=20) generate();
  timer++;
  if (dark) background(0);
}

void generate() {
  color[] colors = new color[10];
  for (int i=0; i<colors.length; i++) {
    colors[i] = typicalColors[floor(random(typicalColors.length))];
    if (i>0) while (colors[i]==colors[i-1]) colors[i] = typicalColors[floor(random(typicalColors.length))];
  }
  background(colors[0]);
  noStroke();
  int baseType = randomFromWeights(new float[] {
    1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0
    }
    );
  PImage chosenImage = symbols.get(floor(random(symbols.size())));
  if (baseType==0) {// 0 = uni
    fill(colors[1]);
    int symbolType = floor(random(3));
    if (symbolType==1) {
      float circleSize = random(height*1/5, height*4/5);
      ellipse(width/2, height/2, circleSize, circleSize);
      image(chosenImage, width/2, height/2, circleSize*0.8, circleSize*0.8);
    }
    if (symbolType==2) {
      beginShape();
      int nbBranches = 5; // Number of points for the star
      float outerRadius = random(height * 1.0 / 7.0, height * 3.0 / 7.0);  // Outer radius of the star
      float innerRadius = outerRadius * 0.381966; // Inner radius of the star (smaller "circle" radius)
      for (int i = 0; i < nbBranches * 2; i++) { // Loop through twice the number of branches
        float angle = i * TWO_PI / (nbBranches * 2) - HALF_PI; // Calculate angle for each point
        float radius = (i % 2 == 0) ? outerRadius : innerRadius; // Alternate between outer and inner radius
        vertex(width / 2 + cos(angle) * radius, height / 2 + sin(angle) * radius);
      }
      endShape(CLOSE);
    }
  }
  if (baseType==1||baseType==2) {  // 1 = horizontal stripes // 2 = vertical stripes
    int nbStripes = randomFromWeights(new float[] {2.0, 8.0, 1.0, 0.2, 0.6})+2;
    for (int i=0; i<nbStripes; i++) {
      fill((nbStripes%2==0)?colors[i%2]:colors[i]);
      if (baseType==1) rect(0, (float)height*i/nbStripes, width, (float)height/nbStripes);
      if (baseType==2) rect((float)width*i/nbStripes, 0, (float)width/nbStripes, height);
    }
    if (nbStripes%2!=0) image(chosenImage, width/2, height/2, height*1/2, height*1/2);
  }
  if (baseType==3) {// 3 = cross
    int nbCrosses = randomFromWeights(new float[] {
      3.0, 2.0, 1.0
      }
      )+1;
    int wPosition = width/2;
    if (random(1)<0.3) wPosition = width/3;
    for (int i=0; i<nbCrosses; i++) {
      fill(colors[i+1]);
      float lineWeight = width/15*(nbCrosses-i);
      rect(0, height/2-lineWeight, width, lineWeight*2);
      rect(wPosition-lineWeight, 0, lineWeight*2, height);
    }
  }
  if (baseType==4) {// 4 = diagonal
    int nbCrosses = randomFromWeights(new float[] {
      3.0, 2.0, 1.0
      }
      )+1;
    for (int i=0; i<nbCrosses; i++) {
      fill(colors[i+1]);
      float lineWeight = width*(nbCrosses-i)/12;
      quad(0-lineWeight, 0, 0, 0-lineWeight, width+lineWeight, height, width, height+lineWeight);
      quad(width+lineWeight, 0, width, 0-lineWeight, 0-lineWeight, height, 0, height+lineWeight);
    }
  }
  if (baseType==5) {// 5 = triangle
    int nbStripes = randomFromWeights(new float[] {
      2.0, 8.0, 1.0, 0.2, 0.6
      }
      )+2;
    if (random(1)<0.3) nbStripes = 0;
    for (int i=0; i<nbStripes; i++) {
      fill((nbStripes%2==0)?colors[i%2]:colors[i]);
      rect(0, (float)height*i/nbStripes, width, (float)height/nbStripes);
    }
    fill(colors[2]);
    int sideType = floor(random(2));
    if (sideType==0) {
      if (nbStripes==0 && random(1)<0.5) {
        triangle(0, 0, width, height/2, 0, height);
        image(chosenImage, width/3, height/2, height*1/3, height*1/3);
      } else {
        triangle(0, 0, width/2, height/2, 0, height);
        image(chosenImage, width/4, height/2, height*1/3, height*1/3);
      }
    }
    if (sideType==1) rect(0, 0, width/3, height);
  }
  if (baseType==6) {// 6 = cross + diagonal
    int nbCrosses = randomFromWeights(new float[] {
      3.0, 2.0, 1.0
      }
      )+1;
    for (int i=0; i<nbCrosses; i++) {
      fill(colors[i+1]);
      float lineWeight = width*(nbCrosses-i)/25;
      quad(0-lineWeight, 0, 0, 0-lineWeight, width+lineWeight, height, width, height+lineWeight);
      quad(width+lineWeight, 0, width, 0-lineWeight, 0-lineWeight, height, 0, height+lineWeight);
    }
    for (int i=0; i<nbCrosses; i++) {
      fill(colors[i+1]);
      float lineWeight = width*(nbCrosses-i)/25;
      rect(0, height/2-lineWeight, width, lineWeight*2);
      rect(width/2-lineWeight, 0, lineWeight*2, height);
    }
  }
  if (baseType==7) {// 7 = triangle from top
    fill(colors[1]);
    int sideType = floor(random(2));
    if (sideType==0) triangle(0, 0, width, 0, width/2, height);
    if (sideType==1) triangle(0, height, width, height, width/2, 0);
    image(chosenImage, width/2, height/2, height*1/2, height*1/2);
  }
  if (baseType==8) {// 8 = chess
    fill(colors[1]);
    int nbX = floor(random(2)+2);
    int nbY = 2;
    for (int x=0; x<nbX; x++) {
      for (int y=0; y<nbY; y++) {
        if ((x+y)%2==0) {
          rect(x*width/nbX, y*height/nbY, width/nbX, height/nbY);
          image(chosenImage, (x+0.5)*width/nbX, (y+0.5)*height/nbY, height*1/3, height*1/3);
        }
      }
    }
  }
  if (baseType==9) {// 9 = corner
    int nbStripes = randomFromWeights(new float[] {1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0})+6;
    for (int i=0; i<nbStripes; i++) {
      fill((nbStripes%2==0)?colors[i%2]:colors[i%2+1]);
      rect(0, (float)height*i/nbStripes, width, (float)height/nbStripes);
    }
    fill(colors[2]);
    if (random(1)<0.5) fill(colors[1]);
    rect(0, 0, (float)width*1/3, (float)ceil(nbStripes*2/5)*height/nbStripes);
    image(chosenImage, (float)width*1/6, (float)height*3/20, height*1/4, height*1/4);
  }
  if (baseType==10) {// 10 = horizontal stripes, big center
    int nbStripes = 5;
    float yPos = 0;
    for (int i=0; i<nbStripes; i++) {
      fill((colors[abs(2-i)]));
      float ySize = (float)height/nbStripes;
      if (i==2) ySize*=2.0;
      else ySize*=0.75;
      rect(0, yPos, width, ySize);
      yPos += ySize;
    }
    image(chosenImage, width/2, height/2, height*1/3, height*1/3);
  }
  timer=0;
}

int randomFromWeights(float[] weights) {
  float totalWeights = 0;
  for (float w : weights) totalWeights += w;
  float r = random(totalWeights);
  int sum = 0;
  for (int i=0; i<weights.length; i++) {
    sum+=weights[i];
    if (r<sum) return i;
  }
  return weights.length-1;
}

void keyPressed() {
  generate();
  if (keyCode==BACKSPACE) dark^=true;
}
