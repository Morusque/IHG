
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

float start = 20;
float remaining = start;

boolean dinged = false;

Minim minim;
AudioPlayer ding;

void setup() {
  size(500, 500);
  textAlign(CENTER, CENTER);
  textSize(100);
  minim = new Minim(this);
  ding = minim.loadFile(dataPath("ding.wav"));
}

void draw() {
  background(0);
  remaining = start-(float)millis()/1000;
  fill(0x80);
  rect(0, 0, width-width*remaining/start, height);
  fill(0xFF);
  if (remaining<0) {
    fill(0xFF, 0, 0);
    if (!dinged) {
      dinged=true;
      ding.play();
    }
  }
  text(nf(remaining, 2, 2), width/2, height/2);
}