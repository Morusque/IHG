
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

float start = 5*60;//1*60*60+45*60;
float remaining = start;
float elapsed = 0;

boolean dinged = false;
boolean warned = false;
boolean beginSfxPlayed = false;

Minim minim;
AudioPlayer ding;
AudioPlayer warn;
AudioPlayer beginSfx;

boolean minutes = true;

boolean ongoing = false;

float volume = 1.0f;

boolean decorated = true;

int warningTime = 10;

import processing.awt.PSurfaceAWT;
import processing.awt.PSurfaceAWT.SmoothCanvas;

PSurface initSurface() {
  PSurface pSurface = super.initSurface();
  if (!decorated) ((SmoothCanvas) ((PSurfaceAWT)surface).getNative()).getFrame().setUndecorated(true);
  return pSurface;
}

void setup() {
  size(1500, 300);
  textAlign(CENTER, CENTER);
  textSize(220);
  textFont(loadFont(dataPath("OCRAStd-220.vlw")));
  minim = new Minim(this);
  beginSfx = minim.loadFile(dataPath("begin.wav"));
  warn = minim.loadFile(dataPath("warn.wav"));
  ding = minim.loadFile(dataPath("ding.wav"));
}

void draw() {
  background(0);
  if (ongoing) elapsed += (1.0f/frameRate);
  remaining = start-elapsed;
  fill(0, 255, 186);
  if (remaining<warningTime) {
    fill(0xFF, 0, 0);
    if (!warned) {
      warn.rewind();
      warn.setGain(volume);
      warn.play();
      warned = true;
    }
  }
  rect(0, 0, width-width*remaining/start, height);
  fill(0xFF);
  if (remaining<0) {
    fill(0xFF, 0, 0);
    if (!dinged) {
      dinged=true;
      ding.rewind();
      ding.setGain(volume);
      ding.play();
    }
  }
  if (minutes) {
    int minutes = 0;
    while (remaining>=60) {
      remaining-=60;
      minutes+=1;
    }
    text(nf(minutes, 2, 0)+":"+nf(remaining, 2, 2), width/2, height/2);
  } else {
    text(nf(remaining, 2, 2), width/2, height/2);
  }
}

void keyPressed() {
  if (keyCode==ENTER) {
    ongoing ^= true;
    if (!beginSfxPlayed) {
      beginSfx.rewind();
      beginSfx.setGain(volume);
      beginSfx.play();
      beginSfxPlayed=true;
    }
  }
  if (keyCode==UP) {
    start+=1;
    reset();
  }
  if (keyCode==DOWN) {
    start-=1;
    reset();
  }  
  if (keyCode==48) {// 0
    start = 0*60;
    reset();
  }
  if (keyCode==49) {// 1
    start = 1*60;
    reset();
  }
  if (keyCode==50) {// 2
    start = 2*60;
    reset();
  }
  if (keyCode==51) {// 3
    start = 3*60;
    reset();
  }
  if (keyCode==52) {// 4
    start = 4*60;
    reset();
  }
  if (keyCode==53) {// 5
    start = 5*60;
    reset();
  }
  if (key=='a') {
    volume=constrain(volume+=2, -20, 6);
    print("volume : ");
    for (int i=0; i<34; i++) print(i<map(volume, -20, 6, 0, 33)?"#":" ");
    println("||");
  }
  if (key=='q') {
    volume=constrain(volume-=2, -20, 6);
    print("volume : ");
    for (int i=0; i<34; i++) print(i<map(volume, -20, 6, 0, 33)?"#":" ");
    println("||");
  }
}

void reset() {    
  remaining=start;
  elapsed=0;
  ongoing = false;
  dinged = false;
  warned = false;
  beginSfxPlayed = false;
}
