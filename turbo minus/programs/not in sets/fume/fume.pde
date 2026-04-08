
int cols, rows;
float[][] field;

float squareSize = 16;

color insideTint = color(0x80);//color(0xEF, 0xEF, 0xEF);

ArrayList<Ball> balls = new ArrayList<Ball>();

float epsilon = 0.00001;

PImage image;

float noiseForce = 1.0;//0.4;
float isoForce = 0.1;//0.3;
float imageForce = 0.0;//0.3;

boolean dark = false;

void setup() {
  // size(1920, 1080);
  fullScreen();
  frameRate(20);
  image = loadImage(dataPath("image.jpg"));
  cols = ceil(width/squareSize)+1;
  rows = ceil(height/squareSize)+1;
  field = new float[cols][rows];
  for (int i=0; i<6; i++) balls.add(new Ball(new PVector(random(rows), random(cols)), random(1, 6)*(((i%2)-0.5)*2)));
  noiseDetail(8, 0.5);
}

void draw() {
  // update
  for (Ball b : balls) b.move();
  for (int x = 0; x < cols; x++) {
    for (int y = 0; y < rows; y++) {
      float noiseValue = noise(x * 0.01, y * 0.01, (float)frameCount/100);
      float isoValue = 0;
      for (Ball b : balls) isoValue += b.force/(dist(x, y, b.pos.x, b.pos.y)+epsilon);
      float imageValue = 1.0-(brightness(image.get(floor(x*image.width/cols), floor(y*image.height/rows)))/0x100);
      field[x][y] = noiseValue*noiseForce + isoValue*isoForce + imageValue*imageForce;
    }
  }
  // draw
  background(0xFF);
  float threshold = 0.5;
  for (int x = 0; x < cols - 1; x++) {
    for (int y = 0; y < rows - 1; y++) {
      drawMarchingSquare(x, y, threshold);
    }
  }
  if (dark) background(0);
}

void drawMarchingSquare(int x, int y, float threshold) {
  int state = 0;

  // Détermine l'état du carré en fonction des sommets
  if (field[x][y] > threshold) state |= 8;
  if (field[x+1][y] > threshold) state |= 4;
  if (field[x+1][y+1] > threshold) state |= 2;
  if (field[x][y+1] > threshold) state |= 1;

  // Coordonnées des coins du carré
  float x0 = x * squareSize;
  float y0 = y * squareSize;
  float x1 = x0 + squareSize;
  float y1 = y0 + squareSize;

  float hS = squareSize / 2;

  // Draw the lines for the marching squares
  stroke(0);
  strokeWeight(2);
  switch (state) {
  case 1: // 0001
    drawEdge(x0, y0 + hS, x0 + hS, y1, x0, y1);
    break;
  case 2: // 0010
    drawEdge(x1, y0 + hS, x0 + hS, y1, x1, y1);
    break;
  case 3: // 0011
    drawEdge(x0, y0 + hS, x1, y0 + hS, x1, y1, x0, y1);  // Horizontal line at the middle
    break;
  case 4: // 0100
    drawEdge(x1, y0 + hS, x0 + hS, y0, x1, y0);
    break;
  case 5: // 0101
    drawEdge(x0 + hS, y0, x1, y0 + hS, x1, y0);
    drawEdge(x0, y0 + hS, x0 + hS, y1, x0, y1);
    break;
  case 6: // 0110
    drawEdge(x0 + hS, y0, x0 + hS, y1, x1, y1, x1, y0); // Vertical line in the center
    break;
  case 7: // 0111
    drawEdge(x0, y0 + hS, x0 + hS, y0, x1, y0, x1, y1, x0, y1);
    break;
  case 8: // 1000
    drawEdge(x0 + hS, y0, x0, y0 + hS, x0, y0);
    break;
  case 9: // 1001
    drawEdge(x0 + hS, y0, x0 + hS, y1, x0, y1, x0, y0); // Vertical line in the center
    break;
  case 10: // 1010
    drawEdge(x0 + hS, y0, x0, y0 + hS, x0, y0);
    drawEdge(x0 + hS, y1, x1, y0 + hS, x1, y1);
    break;
  case 11: // 1011
    drawEdge(x0 + hS, y0, x1, y0 + hS, x1, y1, x0, y1, x0, y0);
    break;
  case 12: // 1100
    drawEdge(x0, y0 + hS, x1, y0 + hS, x1, y0, x0, y0);
    break;
  case 13: // 1101
    drawEdge(x0 + hS, y1, x1, y0 + hS, x1, y0, x0, y0, x0, y1);
    break;
  case 14: // 1110
    drawEdge(x0, y0 + hS, x0 + hS, y1, x1, y1, x1, y0, x0, y0);
    break;
  case 15: // 1111
    noStroke();
    fill(insideTint);
    rect(x0, y0, x1-x0, y1-y0);
    break;
  }
}

void keyPressed() {
  if (keyCode==BACKSPACE) dark^=true;  
}

void drawEdge(float... points) {
  noStroke();
  fill(insideTint);
  beginShape();
  for (int i=0; i<points.length; i+=2) {
    vertex(points[i], points[i+1]);
  }
  endShape();
  stroke(0);
  strokeWeight(2);
  line (points[0], points[1], points[2], points[3]);
}

class Ball {
  PVector pos;
  PVector dir;
  float force;
  Ball (PVector pos, float force) {
    this.pos = pos;
    this.force = force;
    this.dir = new PVector(random(-1, 1), random(-1, 1));
  }
  void move() {
    pos.x += dir.x;
    pos.y += dir.y;
    if (pos.x<0) dir.x=abs(dir.x);
    if (pos.y<0) dir.y=abs(dir.y);
    if (pos.x>=cols) dir.x=abs(dir.x)*-1;
    if (pos.y>=rows) dir.y=abs(dir.y)*-1;
  }
}

float sqDist(float x1, float y1, float x2, float y2) {
  return sq(x2-x1)+sq(y2-y1);
}
