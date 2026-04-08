
PFont font;
PGraphics pg;
String TEXT = "Turbo Minus";
float fontSize = 230;

float gridStep = 15;

boolean centerText = true;
boolean showMask = false;
int textPadding = 40;

float halfLen = 20.0;

void setup() {
  size(1780, 720);
  smooth(4);
  font = createFont("Univers LT 65 Bold", fontSize);
  pg = createGraphics(width, height);
  renderTextMask();
}

void draw() {
  background(255);
  if (showMask) image(pg, 0, 0);

  pg.loadPixels();

  for (float y = textPadding; y < height - textPadding; y += gridStep) {
    for (float x = textPadding; x < width - textPadding; x += gridStep) {

      int ix = constrain(round(x), 0, width-1);
      int iy = constrain(round(y), 0, height-1);
      int idx = iy * width + ix;
      if (alpha(pg.pixels[idx]) > 8) {
        float dx = mouseX - x;
        float dy = mouseY - y;

        // float a = 1.0+TWO_PI*3.0/(5.0+dist(0,0,dx,dy)/10.0);
        float a = -atan2(dy, dx)*2.0+HALF_PI;

        float dxv = cos(a) * halfLen;
        float dyv = sin(a) * halfLen;

        stroke(0);
        strokeWeight(13.0);
        line(x - dxv, y - dyv, x + dxv, y + dyv);
        strokeWeight(8.0);
        stroke(0xFF);
        line(x - dxv, y - dyv, x + dxv, y + dyv);
      }
    }
  }
}

void renderTextMask() {
  pg.beginDraw();
  pg.background(0, 0); // transparent
  pg.smooth(4);
  pg.textAlign(CENTER, CENTER);
  pg.textFont(font);
  pg.fill(255);
  pg.textSize(fontSize);
  if (centerText) {
    pg.text(TEXT, pg.width * 0.5, pg.height * 0.5);
  } else {
    pg.textAlign(LEFT, TOP);
    pg.text(TEXT, textPadding, textPadding + fontSize * 0.1);
  }
  pg.endDraw();
}

void keyPressed() {
  if (keyCode == LEFT) gridStep = max(2, gridStep - 1);
  if (keyCode == RIGHT) gridStep = min(100, gridStep + 1);

  if (key == 'c' || key == 'C') {
    centerText = !centerText;
    renderTextMask();
  }
  if (key == 'v' || key == 'V') showMask = !showMask;
  if (key == 'r' || key == 'R') renderTextMask();
  if (key == 'f' || key == 'F') {
    fontSize = constrain(fontSize + (key=='F' ? 10 : -10), 24, 600);
    font = createFont("Univers LT 65 Bold", fontSize);
    renderTextMask();
  }
}
