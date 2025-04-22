
import processing.sound.*;
Amplitude amp;
SoundFile file;
SoundFile test;

float gain = 0;
float gaps = 0;
float blink = 0;

boolean play = false;

void setup() {
  //size(800, 800);
  fullScreen(1);
  background(255);
  file = new SoundFile(this, dataPath("sample.wav"));
  test = new SoundFile(this, dataPath("test.wav"));
  amp = new Amplitude(this);
  amp.input(file);
}  

void draw() {
  gain = lerp(gain, amp.analyze(), 0.5f);
  if (gain>0.4) {
    gaps = 0;
  } else {
    gaps += 0.01;
  }
  if (gaps>0.5) {
    blink = min(blink+0.4, 1);
  } else {
    blink *= 0.3;
  }
  background(0);
  noStroke();
  fill(0, 0xFF, 0);
  rect(width*1/3, (float)height*8/10+gain*height*1/10, width*1/3, (float)-gain*height*2/10);
  rect(width*1/5, (float)height*4/10+(1-blink)*1/10, width*1/5, (float)-(1-blink)*height*2/10);
  rect(width*3/5, (float)height*4/10+(1-blink)*1/10, width*1/5, (float)-(1-blink)*height*2/10);
}

void keyPressed() {
  if (keyCode==ENTER) play^=true;
  if (play) {
    file.play();
  }
  else file.pause();
  if (keyCode==TAB) {
    test.stop();
    test.play();
  }
}
