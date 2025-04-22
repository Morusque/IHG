
int sceneMode = 0;

Anim chosenAnim = null;

ArrayList<Sprite> handledSprites = new ArrayList<Sprite>();
float angleBias = 0;
float concentricLength = 0;
Sprite singleStar;
Sprite[][] grid;
PVector gravity = new PVector(0, 0);
PVector gravityIncrement = new PVector(0, 0);
float speedScale = 1;
ArrayList<PVector> mergingPoints = new ArrayList<PVector>();
int targetPop = 0;
float attractionStrength = 0;
float rainForce = 1;
float strictSelection = 2.0;
float chosenAnimRate = 1;
float spiralPhase = 0;
float spiralSpeed = 0;
float danceSpawnDensity = 1;
int maxNumSprites = -1;
PVector strokePos = new PVector(0,0);
float strokeAngle = 0;
int rotDirection = 1;
int stairShift = 0;
int stairShiftLimit = 1;

int framesWithoutSprites = 0;

long lastModeSwitch = 0;

int nbSceneModes = 31;

int modeEventScramblePercent = 5;

boolean nextModeScheduled = false;

String sceneName(int i) {
  if (i==0) return "manual";
  if (i==1) return "vagues";
  if (i==2) return "orthogonal";
  if (i==3) return "esther williams";
  if (i==4) return "single";
  if (i==5) return "shivering";
  if (i==6) return "grille";
  if (i==7) return "bounce";
  if (i==8) return "symmetry";
  if (i==9) return "snake";
  if (i==10) return "merge";
  if (i==11) return "lava lamp";
  if (i==12) return "wind";
  if (i==13) return "bords";
  if (i==14) return "curves";
  if (i==15) return "speed scale";
  if (i==16) return "shift direction";
  if (i==17) return "multi merge";
  if (i==18) return "regulate";
  if (i==19) return "gravitation";
  if (i==20) return "pluie";
  if (i==21) return "spiral";
  if (i==22) return "dance spawn";
  if (i==23) return "repulse";
  if (i==24) return "teleportation";
  if (i==25) return "path";
  if (i==26) return "stroke";
  if (i==27) return "cells";
  if (i==28) return "rotate";
  if (i==29) return "stairs";
  if (i==30) return "backforth";
  return "unknown";
}

void nextMode() {
  if (autoNextSwitch) {
    sceneMode=floor(random(nbSceneModes));
    sceneInit();
  }
  println("switch to scene mode : "+nf(sceneMode, 2)+" : "+sceneName(sceneMode));
  // shift distribution
  if (anims.size()>0) {
    Anim elementToPush = anims.remove(min(anims.size()-1, floor(random(5))));
    anims.add(elementToPush);
    strictSelection = random(10);
  }
  lastModeSwitch = millis();
}

void structureTrigger() {
  println("structure trigger");
  int burst = floor(random(0, 6));
  for (int i=0; i<burst; i++) nextMode();
  for (Sprite s : sprites) {
    s.moveSpeed = max(s.moveSpeed*1.1, s.moveSpeed, 2.0);
  }
  int nbActiveLayers = 0;
  for (int i=0; i<bgmLayerActive.length; i++) if (bgmLayerActive[i]) nbActiveLayers++;
  while (sprites.size() < nbActiveLayers) {
    Anim anim = pickWeightedRandomAnim();
    PVector position = new PVector(random(width*1.0/3.0, width*2.0/3.0), random(height*1.0/3.0, height*2.0/3.0));
    float animFR = preferredAFR*pow(2, random(5))*(round(random(1))*2-1);
    if (musicMode==0) animFR = random(2, 10)*(round(random(1))*2-1);
    Sprite newSprite = new Sprite(anim, animFR, position, random(TWO_PI), random(1, 3));
    newSprite.flipHorizontal = random(1)<0.5;
    newSprite.flipVertical = random(1)<0.5;
    sprites.add(newSprite);
    if (useSound) triggerNote(newSprite);
  }
}

Anim pickWeightedRandomAnim() {
  if (anims.isEmpty()) return null;
  double weight = Math.pow(Math.random(), strictSelection);
  int index = (int)(weight * anims.size());
  index = Math.min(index, anims.size() - 1);
  return anims.get(index);
}

void sceneInit() {

  int tempSceneMode = sceneMode;
  if (random(100)<modeEventScramblePercent) tempSceneMode = floor(random(nbSceneModes));
  
  if (tempSceneMode==0) {// rien
    for (Sprite s : sprites) s.leave();
    chosenAnim = null;
  }
  if (tempSceneMode==1) {// vagues de beaucoup
    chosenAnim = null;
  }
  if (tempSceneMode==2) {// orthogonal
    chosenAnim = pickWeightedRandomAnim();
    for (Sprite s : sprites) {
      if (s.anim!=chosenAnim) {
        if (singleStar==null && random(1.0)<0.3) singleStar=s;
        else s.leave();
      }
    }
  }
  if (tempSceneMode==3) {// esther williams
    int nbSwimmers = floor(random(6, 17));
    handledSprites.clear();
    if (sprites.size()>0&&random(1.0)<0.5) chosenAnim = sprites.get(floor(random(sprites.size()))).anim;
    if (chosenAnim==null||random(1.0)<0.5) chosenAnim = pickWeightedRandomAnim();
    if (random(1.0)<0.7) singleStar = null;
    for (Sprite s : sprites) {
      if (s.anim==chosenAnim && handledSprites.size()<nbSwimmers) handledSprites.add(s);
      else {
        if (singleStar==null && random(1.0)<0.3) singleStar=s;
        else s.leave();
      }
    }
    if (singleStar!=null) singleStar.animFrameRate = random(1, 10)*(round(random(1))*2-1);
    while (handledSprites.size()<nbSwimmers) {
      PVector position = new PVector(random(width), random(height));
      if (random(1)<0.5f) position.x = ((random(1)<0.5f) ? -chosenAnim.width/2  : width+chosenAnim.width/2);
      else position.y = ((random(1)<0.5f) ? -chosenAnim.height/2 : height+chosenAnim.height/2);
      Sprite s = new Sprite(chosenAnim, 5, position, 0, 11.0);
      handledSprites.add(s);
      sprites.add(s);
    }
    for (int i=0; i<nbSwimmers; i++) {
      Sprite s = handledSprites.get(i);
      s.moveSpeed = 7.0;
      s.animFrameRate = 5.0;
      s.currentFrame = floor((float)i*12/nbSwimmers);
      concentricLength = random(-100, 200);
      PVector target = new PVector(width/2+cos((float)i*TWO_PI/nbSwimmers)*concentricLength, height/2+sin((float)i*TWO_PI/nbSwimmers)*concentricLength);
      s.target=target;
    }
  }
  if (tempSceneMode==4) {// single
    if (sprites.size()>0) {
      singleStar = sprites.get(floor(random(sprites.size())));
      singleStar.isLeaving = false;
    }
    for (Sprite s : sprites) {
      if (s!=singleStar) {
        s.leave();
      }
    }
  }
  if (tempSceneMode==5) {// shivering
  }
  if (tempSceneMode==6) {// grille
    int nbX = floor(random(1, 9));
    int nbY = floor(random(1, 7));
    grid = new Sprite[nbX][nbY];
    if (chosenAnim==null||random(1.0)<0.7) chosenAnim = pickWeightedRandomAnim();
    handledSprites.clear();
    for (Sprite s : sprites) {
      if (s.anim==chosenAnim && handledSprites.size()<nbX*nbY) handledSprites.add(s);
      else s.leave();
    }
    while (handledSprites.size()<nbX*nbY) {
      PVector position = new PVector(random(width), random(height));
      if (random(1)<0.5f) position.x = ((random(1)<0.5f) ? -chosenAnim.width/2  : width+chosenAnim.width/2);
      else position.y = ((random(1)<0.5f) ? -chosenAnim.height/2 : height+chosenAnim.height/2);
      Sprite s = new Sprite(chosenAnim, 5, position, 0, 5.0);
      handledSprites.add(s);
      sprites.add(s);
    }
    float globalAFR = random(3, 10);
    for (int x=0; x<nbX; x++) {
      for (int y=0; y<nbY; y++) {
        grid[x][y] = handledSprites.get(x+y*nbX);
        grid[x][y].animFrameRate = globalAFR;
        grid[x][y].currentFrame = (((float)x+y)*12.0/((float)nbX*(float)nbY))%12;
        PVector target = new PVector((float)(x+1)*width/(grid.length+1), (float)(y+1)*height/(grid[x].length+1));
        grid[x][y].moveSpeed = PVector.dist(grid[x][y].pos, target)/100.0f;
      }
    }
  }
  if (tempSceneMode==7) {// bounce
    gravity = new PVector(0, 0);
    gravityIncrement = new PVector(random(-0.3, 0.3), random(-0.3, 0.3));
    for (Sprite s : sprites) {
      if (s.pos.x>=width-(s.anim.width/2+s.dir.x) || s.pos.x<=(s.anim.width/2+s.dir.x) ||
        s.pos.y>=height-(s.anim.height/2+s.dir.y) || s.pos.y<=(s.anim.height/2+s.dir.y)) {
        s.target = PVector.lerp(s.pos, new PVector(random(width), random((float)height/2)), 0.5);
        s.moveSpeed = constrain(s.moveSpeed*3, 5, 25);
      }
      if (!s.isVisible()) s.leave();
    }
  }
  if (tempSceneMode==8) {// symmetry
    int symmetryType = floor(random(3));// both, vertical, horizontal
    for (Sprite s : sprites) s.leave();
    int nbSprites = floor(random(1, 4));
    for (int i=0; i<nbSprites; i++) {
      Anim anim = pickWeightedRandomAnim();
      PVector position = new PVector(random(width), random(height));
      if (random(1)<0.5f) position.x = ((random(1)<0.5f) ? -anim.width/2  : width+anim.width/2);
      else position.y = ((random(1)<0.5f) ? -anim.height/2 : height+anim.height/2);
      float angle = atan2((float)height/2-position.y, (float)width/2-position.x)+random(-0.5, 0.5);
      float speed = random(1, 10);
      float animSpeed = preferredAFR*pow(2, random(4))*(round(random(1))*2-1);
      if (musicMode==0) animSpeed = random(2, 10)*(round(random(1))*2-1);
      float frameOffset = random(1.0);
      Sprite s1 = new Sprite(anim, animSpeed, position, angle, speed);
      Sprite s2 = new Sprite(anim, animSpeed, new PVector(width-position.x, position.y), PI-angle, speed);
      Sprite s3 = new Sprite(anim, animSpeed, new PVector(position.x, height-position.y), -angle, speed);
      Sprite s4 = new Sprite(anim, animSpeed, new PVector(width-position.x, height-position.y), angle+PI, speed);
      s2.flipHorizontal = true;
      s3.flipVertical = true;
      s4.flipHorizontal = true;
      s4.flipVertical = true;
      s1.currentFrame = frameOffset;
      s1.currentFrame = frameOffset;
      s1.currentFrame = frameOffset;
      s1.currentFrame = frameOffset;
      sprites.add(s1);
      if (symmetryType==0 || symmetryType==2) sprites.add(s2);
      if (symmetryType==0 || symmetryType==1) sprites.add(s3);
      if (symmetryType==0) sprites.add(s4);
    }
  }
  if (tempSceneMode==9) {// snake
  }
  if (tempSceneMode==10) {// merging
  }
  if (tempSceneMode==11) {// lava lamp
    int nbSpritesToAdd = floor(random(0, 10));
    for (int i=0; i<nbSpritesToAdd; i++) {
      Anim anim = chosenAnim;
      if (random(100)<1.0 || anim==null) anim = pickWeightedRandomAnim();
      PVector position = new PVector(random(width), height+random(1000));
      float angle = HALF_PI*3;
      Sprite newSprite = new Sprite(anim, random(2.5, 3.5), position, angle, random(1, 10));
      sprites.add(newSprite);
    }
    for (Sprite s : sprites) {
      s.moveAngle = HALF_PI*3;
    }
  }
  if (tempSceneMode==12) {// wind
    for (Sprite s : sprites) {
      s.moveAngle = 0+floor(random(2))*PI;
    }
  }
  if (tempSceneMode==13) {// sur les bords
    if (chosenAnim==null||random(1.0)<0.5) chosenAnim = pickWeightedRandomAnim();
    for (Sprite s : sprites) {
      int targetBorder = floor(random(4));
      s.target = new PVector(s.pos.x, s.pos.y);
      if (targetBorder==0) s.target.x = 0;
      if (targetBorder==1) s.target.y = 0;
      if (targetBorder==2) s.target.x = width-1;
      if (targetBorder==3) s.target.y = height-1;
    }
  }
  if (tempSceneMode==14) {// curves
  }
  if (tempSceneMode==15) {// speed scale
    speedScale = random(0.4, 1.1);
  }
  if (tempSceneMode==16) {// shift direction
    float shift = PI;
    if (random(1)<0.5) shift = random(TWO_PI);
    for (Sprite s : sprites) {
      if (!s.isLeaving) s.moveAngle+=shift;
    }
  }
  if (tempSceneMode==17) {// merge to several points
    mergingPoints = new ArrayList<PVector>();
    int nbPoints = floor(random(1, 5));
    for (int i=0; i<nbPoints; i++) {
      if (random(1.0)<0.9) mergingPoints.add(new PVector(random(width*1/5, width*4/5), random(height*1/5, height*4/5)));
      else mergingPoints.add(new PVector(random(-width/5, width*6/5), random(-height/5, height*6/5)));
    }
    for (Sprite s : sprites) {
      s.target = mergingPoints.get(floor(random(mergingPoints.size())));
    }
  }
  if (tempSceneMode==18) {// regulate population
    targetPop = round(random(30, random(0, 60)));
  }
  if (tempSceneMode==19) {// gravitation
    attractionStrength = random(-0.005, 0.03);
    int nbNewSprites = constrain(30-sprites.size(), 0, 3);
    for (int i = 0; i < nbNewSprites; i++) {
      Anim anim = pickWeightedRandomAnim();
      if (chosenAnim!=null) anim = chosenAnim;
      float distance = random(width, width*2);
      float angle = random(TWO_PI);
      PVector position = new PVector(cos(angle) * distance + width/2, sin(angle) * distance + height/2);
      float animFrameRate = preferredAFR*pow(2, random(4))*(round(random(1))*2-1);
      if (musicMode==0) animFrameRate = random(2, 10)*(round(random(1))*2-1);
      float moveSpeed = map(distance, 50, width, 0.1, 10);
      Sprite celestialBody = new Sprite(anim, animFrameRate, position, angle+PI, moveSpeed);
      celestialBody.currentFrame = random(1.0);
      sprites.add(celestialBody);
    }
  }
  if (tempSceneMode==20) {// pluie
    rainForce=random(10);
    for (Sprite s : sprites) {
      s.moveAngle = HALF_PI + ((random(1.0)<0.5)?0.5:-0.5);
      s.moveSpeed = 10;
    }
  }
  if (tempSceneMode==21) {// spiral
    for (Sprite s : sprites) {
      s.leave();
    }
    spiralSpeed = random(-1, 1);
  }
  if (tempSceneMode==22) {// dance spawn
    danceSpawnDensity = random(2);
  }
  if (tempSceneMode==23) {// repulse
  }
  if (tempSceneMode==24) {// teleportation
  }
  if (tempSceneMode==25) {// path
    mergingPoints = new ArrayList<PVector>();
    int nbPoints = floor(random(2, random(2, 16)));
    mergingPoints.add(new PVector(random(width), random(height)));
    while (mergingPoints.size()<nbPoints) {
      boolean ok = false;
      PVector newPoint = new PVector(random(width), random(height));
      int tries = 0;
      while (!ok && tries<100) {
        newPoint = new PVector(random(width), random(height));
        ok = true;
        for (PVector p : mergingPoints) if (abs(p.x-newPoint.x)+abs(p.y-newPoint.y)<300) ok=false;
        tries++;
      }
      mergingPoints.add(newPoint);
    }
    for (Sprite s : sprites) {
      if (!s.isLeaving) {
        s.target = mergingPoints.get(floor(random(mergingPoints.size())));
      }
    }
  }
  if (tempSceneMode==26) {// stroke
    strokePos = new PVector(random(width), random(height));
    strokeAngle = random(TWO_PI);
    if (sprites.size()>0) {
      strokePos.set(sprites.get(sprites.size()-1).pos.x, sprites.get(sprites.size()-1).pos.y);
      strokeAngle = sprites.get(sprites.size()-1).moveAngle;
    }
    chosenAnimRate = preferredAFR*pow(2, random(5))*(round(random(1))*2-1);
    if (musicMode==0) chosenAnimRate = random(2, 10)*(round(random(1))*2-1);
  }
  if (tempSceneMode==27) {// cells
  }
  if (tempSceneMode==28) {// rotate
    rotDirection = random(1)<0.5?1:-1;
  }
  if (tempSceneMode==29) {// stairs
    stairShiftLimit = floor(random(4))+1;
  }
  if (tempSceneMode==30) {// backforth
  }
}

void melodyNotePlayed() {
  if (sceneMode==0) {// rien
    Anim anim = pickWeightedRandomAnim();
    PVector position = new PVector(random(width), random(height));
    Sprite newSprite = new Sprite(anim, 3, position, random(TWO_PI), random(1, 10));
    newSprite.flipHorizontal = random(1)<0.5;
    newSprite.flipVertical = random(1)<0.5;
    sprites.add(newSprite);
    if (useSound) triggerNote(newSprite);
  }
}

void sceneUpdate() {
  
  if (nextModeScheduled) {
    nextModeScheduled=false;
    nextMode();
  }

  // change mode if no sprite for a long time
  if (sprites.size()==0) framesWithoutSprites++;
  else framesWithoutSprites=0;
  if (framesWithoutSprites>frameRate*30) {
    println("no sprite for a lonf time : next mode");
    nextMode();
  }

  // change mode if no activity while playing music
  float wholeMoveLog = 0;
  for (float f : moveLog) wholeMoveLog += f;
  int nbActiveLayers = 0;
  for (int i=0; i<bgmLayerActive.length; i++) if (bgmLayerActive[i]) nbActiveLayers++;
  if (wholeMoveLog<5 && nbActiveLayers>0) {
    println("no activity on music : next mode");
    nextMode();
  }

  // ask exeeding sprites to leave
  if (maxNumSprites!=-1) {
    for (int i=0; i<min(sprites.size()-1, sprites.size()-maxNumSprites); i++) sprites.get(i).leave();
  }

  if (musicMode==0) if (random(frameRate)<avgDanceMovePerSecond) danceMove();

  if (sceneMode==0) {// rien
  }
  if (sceneMode==1) {// vagues de beaucoup
    float density = map(sin((float)millis()/20000.0), -1, 1, 0, 0.4);
    if (random(1)<density) {
      if (deltaTime-(1000.0/targetFrameRate)<frameMsMargin) {// if it's not lagging
        if (sprites.size()<maxNumSprites || maxNumSprites==-1) {
          Anim anim = pickWeightedRandomAnim();
          PVector position = new PVector(random(width), random(height));
          float animFR = preferredAFR*pow(2, random(5))*(round(random(1))*2-1);
          if (musicMode==0) animFR = random(2, 10)*(round(random(1))*2-1);
          Sprite newSprite = new Sprite(anim, animFR, position, random(TWO_PI), random(1, 10));
          newSprite.flipHorizontal = random(1)<0.5;
          newSprite.flipVertical = random(1)<0.5;
          sprites.add(newSprite);
          if (useSound) triggerNote(newSprite);
        }
      }
    }
    for (Sprite s : sprites) {
      if (random(frameRate)<0.2) {
        s.moveAngle = random(TWO_PI);
        s.moveSpeed = random(1, 5);
      }
    }
  }
  if (sceneMode==2) {// orthogonal
    if (random(frameRate)<0.3) {
      if (deltaTime-(1000.0/targetFrameRate)<frameMsMargin) {// if it's not lagging
        if (sprites.size()<maxNumSprites || maxNumSprites==-1) {
          Anim anim = chosenAnim;
          if (random(100)<1.0 || anim==null) anim = pickWeightedRandomAnim();
          PVector position = new PVector(random(width), random(height));
          float angle = 0;
          if (random(1)<0.5f) {
            position.x = ((random(1)<0.5f) ? -anim.width/2  : width+anim.width/2);
            if (position.x<0) angle = 0;
            else angle = PI;
          } else {
            position.y = ((random(1)<0.5f) ? -anim.height/2 : height+anim.height/2);
            if (position.y<0) angle = HALF_PI;
            else angle = -HALF_PI;
          }
          Sprite newSprite = new Sprite(anim, random(2.5, 3.5), position, angle, random(1, 2));
          sprites.add(newSprite);
        }
      }
    }
    if (random(frameRate)<0.5) {
      for (Sprite s : sprites) {
        if (!s.isLeaving) {
          s.moveAngle = floor(random(4))*HALF_PI;
        }
      }
    }
    if (singleStar!=null) if (random(frameRate)<0.7) singleStar.moveAngle = floor(random(4))*HALF_PI;
  }
  if (sceneMode==3) {// esther williams
    angleBias += 0.01;
    concentricLength += 1.0;
    for (int i=0; i<handledSprites.size(); i++) {
      if (!handledSprites.get(i).isLeaving) handledSprites.get(i).target = new PVector(width/2+cos((float)i*TWO_PI/handledSprites.size()+angleBias)*concentricLength, height/2+sin((float)i*TWO_PI/handledSprites.size()+angleBias)*concentricLength);
    }
    if (singleStar!=null) if (!singleStar.isLeaving) singleStar.target=new PVector(width/2, height/2);
  }
  if (sceneMode==4) {// single
    if (singleStar!=null) {
      PVector target = PVector.add(singleStar.pos, singleStar.dir);
      singleStar.moveAngle = atan2(target.y-singleStar.pos.y, target.x-singleStar.pos.x);
      singleStar.moveSpeed = PVector.sub(target, singleStar.pos).mag();
      if (!singleStar.isArriving) {
        if ((singleStar.pos.y + (float)singleStar.anim.height/2 > height && singleStar.dir.y>0) || (singleStar.pos.y - (float)singleStar.anim.height/2 < 0 && singleStar.dir.y<0)) {
          singleStar.moveAngle = 0-singleStar.moveAngle;
          if (singleStar.isVisible()) if (useSound) triggerNote(singleStar);
        } else if ((singleStar.pos.x + (float)singleStar.anim.width/2 > width && singleStar.dir.x>0) || (singleStar.pos.x - (float)singleStar.anim.width/2 < 0 && singleStar.dir.x<0)) {
          singleStar.moveAngle = PI-singleStar.moveAngle;
          if (singleStar.isVisible()) if (useSound) triggerNote(singleStar);
        }
      }
    }
  }
  if (sceneMode==5) {// shivering
  }
  if (sceneMode==6) {// grid
    int numberInPlace = 0;
    if (grid==null) sceneInit();
    if (grid!=null) {
      for (int x=0; x<grid.length; x++) {
        for (int y=0; y<grid[x].length; y++) {
          if (grid[x][y].target==null) numberInPlace++;
        }
      }
    }
    if (numberInPlace>1 && sprites.size()>6) {
      sceneInit();
    }
    if (random(frameRate)<0.03) sceneInit();
    if (grid!=null) {
      for (int x=0; x<grid.length; x++) {
        for (int y=0; y<grid[x].length; y++) {
          if (grid[x][y]!=null) {
            PVector target = new PVector((float)(x+1)*width/(grid.length+1), (float)(y+1)*height/(grid[x].length+1));
            if (!grid[x][y].isLeaving) grid[x][y].target=target;
          }
        }
      }
    }
  }
  if (sceneMode==7) {// bounce
    for (Sprite s : sprites) {
      if (s.target==null) {
        PVector target = PVector.add(s.pos, s.dir);
        target.add(gravity);
        s.moveAngle = atan2(target.y-s.pos.y, target.x-s.pos.x);
        s.moveSpeed = PVector.sub(target, s.pos).mag();
        if (!s.isArriving) {
          if ((s.pos.y + (float)s.anim.height/2 > height && s.dir.y>0) || (s.pos.y - (float)s.anim.height/2 < 0 && s.dir.y<0)) {
            s.moveAngle = 0-s.moveAngle;
            if (s.isVisible() && !s.isArriving) if (useSound) triggerNote(s);
          } else if ((s.pos.x + (float)s.anim.width/2 > width && s.dir.x>0) || (s.pos.x - (float)s.anim.width/2 < 0 && s.dir.x<0)) {
            s.moveAngle = PI-s.moveAngle;
            if (s.isVisible() && !s.isArriving) if (useSound) triggerNote(s);
          }
        } else {
          s.leave();
        }
      }
    }
    if (gravity.mag()<1) gravity.add(gravityIncrement);
  }
  if (sceneMode==8) {// symmetry
  }
  if (sceneMode==9) {// snake
    for (int i=0; i<sprites.size()-1; i++) {
      if (!sprites.get(i).isLeaving) sprites.get(i).target = sprites.get(i+1).pos;
    }
  }
  if (sceneMode==10) {// merging
  }
  if (sceneMode==11) {// lava lamp
    for (int i=0; i<sprites.size(); i++) {
      sprites.get(i).moveAngle += sin(((float)frameCount*2/max(0.0001, frameRate*(i+1))))/10.0;
      sprites.get(i).moveAngle = lerp(sprites.get(i).moveAngle, HALF_PI*3, 0.1f);
    }
  }
  if (sceneMode==12) {// wind
    for (int i=0; i<sprites.size(); i++) {
      sprites.get(i).moveAngle += sin(((float)frameCount*2/max(0.0001, frameRate*(i+1))))/50.0;
      sprites.get(i).moveSpeed *= 1.01f;
    }
  }
  if (sceneMode==13) {// sur les bords
    for (Sprite s : sprites) {
      if (!s.isLeaving) {
        if (s.pos.x < 50) s.moveAngle = HALF_PI*3;
        if (s.pos.y < 50) s.moveAngle = HALF_PI*0;
        if (s.pos.x > width-51) s.moveAngle = HALF_PI*1;
        if (s.pos.y > height-51 && s.pos.x>50) s.moveAngle = HALF_PI*2;
      }
    }
  }
  if (sceneMode==14) {// curves
    for (Sprite s : sprites) {
      s.moveAngle+=random(-0.3, 0.3);
    }
  }
  if (sceneMode==15) {// speed scale
    for (Sprite s : sprites) {
      if (!s.isLeaving) s.moveSpeed*=speedScale;
    }
  }
  if (sceneMode==16) {// shift direction
  }
  if (sceneMode==17) {// merge to several points
    for (Sprite s : sprites) {
      if (s.target==null) s.moveSpeed *= 0.9;
    }
  }
  if (sceneMode==18) {// regulatePopulation
    if (sprites.size()>targetPop) {
      sprites.get(0).leave();
    }
    if (sprites.size()<targetPop) {
      if (deltaTime-(1000.0/targetFrameRate)<frameMsMargin) {// if it's not lagging
        if (sprites.size()<maxNumSprites || maxNumSprites==-1) {
          Anim anim = pickWeightedRandomAnim();
          PVector position = new PVector(random(-width, width*2), random(-height, height*2));
          float angle = atan2((float)height/2-position.y, (float)width/2-position.x)+random(-0.5, 0.5);
          float speed = random(1, 10);
          float animSpeed = random(1, 8);
          Sprite s1 = new Sprite(anim, animSpeed, position, angle, speed);
          if (random(1)<0.5) s1.flipHorizontal = true;
          if (random(1)<0.5) s1.flipVertical = true;
          sprites.add(s1);
          if (useSound) triggerNote(s1);
        }
      }
    }
  }
  if (sceneMode==19) {// gravitation
    for (Sprite body : sprites) {
      for (Sprite otherBody : sprites) {
        if (body != otherBody) {
          float angleTowardsOther = atan2(otherBody.pos.y - body.pos.y, otherBody.pos.x - body.pos.x);
          float normalizedBodyAngle = (body.moveAngle + TWO_PI) % TWO_PI;
          float normalizedOtherAngle = (angleTowardsOther + TWO_PI) % TWO_PI;
          float angleDifference = normalizedOtherAngle - normalizedBodyAngle;
          if (angleDifference < -PI) angleDifference += TWO_PI;
          if (angleDifference > PI) angleDifference -= TWO_PI;
          body.moveAngle += angleDifference * attractionStrength;
          body.moveSpeed = lerp(body.moveSpeed, otherBody.moveSpeed, constrain(PVector.dist(body.pos, otherBody.pos)/5000, 0, 0.01));
        }
      }
    }
  }
  if (sceneMode==20) {// pluie
    if (random(frameRate)<rainForce) {
      if (deltaTime-(1000.0/targetFrameRate)<frameMsMargin) {// if it's not lagging
        if (sprites.size()<maxNumSprites || maxNumSprites==-1) {
          Anim anim = pickWeightedRandomAnim();
          if (chosenAnim!=null) anim = chosenAnim;
          PVector position = new PVector(random(width), -anim.height);
          Sprite newSprite = new Sprite(anim, random(1, 5)*(round(random(1))*2-1), position, HALF_PI + ((random(1.0)<0.5)?0.5:-0.5), 10);
          newSprite.flipHorizontal = random(1)<0.5;
          newSprite.flipVertical = random(1)<0.5;
          sprites.add(newSprite);
        }
      }
    }
  }
  if (sceneMode==21) {// spiral
    if (random(frameRate)<7) {
      if (deltaTime-(1000.0/targetFrameRate)<frameMsMargin) {// if it's not lagging
        if (sprites.size()<maxNumSprites || maxNumSprites==-1) {
          Anim anim = pickWeightedRandomAnim();
          if (chosenAnim!=null) anim = chosenAnim;
          PVector position = new PVector(width/2, height/2);
          Sprite newSprite = new Sprite(anim, chosenAnimRate, position, spiralPhase, 10);
          newSprite.flipHorizontal = random(1)<0.5;
          newSprite.flipVertical = random(1)<0.5;
          sprites.add(newSprite);
          if (useSound) triggerNote(newSprite);
          spiralPhase = (spiralPhase+spiralSpeed+TWO_PI)%TWO_PI;
        }
      }
    }
  }
  if (sceneMode==22) {// dance spawn
  }
  if (sceneMode==23) {// repulse
    for (Sprite body : sprites) {
      for (Sprite otherBody : sprites) {
        if (body != otherBody) {
          float averageDim = (body.anim.width+body.anim.height+otherBody.anim.width+otherBody.anim.height)/4.0;
          if (PVector.dist(body.pos, otherBody.pos)<averageDim/2.0) {
            float angle = atan2(body.pos.y-otherBody.pos.y, body.pos.x-otherBody.pos.x);
            otherBody.moveAngle = angle+PI;
            body.moveAngle = angle;
          }
        }
      }
    }
  }
  if (sceneMode == 24) { // teleportation
    if (sprites.size()<3) {
      Anim anim = pickWeightedRandomAnim();
      PVector position = new PVector(random(-width, width*2), random(-height, height*2));
      Sprite newSprite = new Sprite(anim, chosenAnimRate, position, random(TWO_PI), 10);
      newSprite.flipHorizontal = random(1)<0.5;
      newSprite.flipVertical = random(1)<0.5;
      sprites.add(newSprite);
      if (useSound) triggerNote(newSprite);
    }
  }
  if (sceneMode==25) {// path
    if (mergingPoints.size()==0) sceneInit();
    for (Sprite s : sprites) {
      int targetClose = -1;
      for (int i=0; i<mergingPoints.size(); i++) {
        if (PVector.dist(mergingPoints.get(i), s.pos)<100) targetClose = i;
      }
      if (targetClose!=-1) {
        if (!s.isLeaving) {
          if (mergingPoints.size()>0) s.target = mergingPoints.get((targetClose+1)%mergingPoints.size());
        }
      }
    }
  }
  if (sceneMode==26) {// stroke
    if (sprites.size()<70) {
      if (frameCount%2==0) {
        if (deltaTime-(1000.0/targetFrameRate)<frameMsMargin) {// if it's not lagging
          Anim anim = pickWeightedRandomAnim();
          strokePos.add(new PVector(cos(strokeAngle)*anim.width*2/5, sin(strokeAngle)*anim.height*2/5));
          strokePos.x = (strokePos.x+width)%width;
          strokePos.y = (strokePos.y+height)%height;
          strokeAngle += random(-0.5, 0.5);
          Sprite newSprite = new Sprite(anim, chosenAnimRate, strokePos.copy(), strokeAngle+PI, 0);
          newSprite.flipHorizontal = random(1)<0.5;
          newSprite.flipVertical = random(1)<0.5;
          sprites.add(newSprite);
          if (useSound) triggerNote(newSprite);
        }
      }
    }
  }
  if (sceneMode==27) {// cells
    for (Sprite body : sprites) {
      for (Sprite otherBody : sprites) {
        if (body != otherBody) {
          float distance = PVector.dist(body.pos, otherBody.pos);
          if (distance<500) {
            float angle = atan2(body.pos.y-otherBody.pos.y, body.pos.x-otherBody.pos.x);
            otherBody.moveAngle = angle+PI;
            body.moveAngle = angle;
            otherBody.moveSpeed += 1.0/(max(10, distance-10));
            body.moveSpeed += 1.0/(max(10, distance-10));
          }
        }
      }
    }
    for (Sprite s : sprites) {
      if (!s.isLeaving) s.moveSpeed*=0.9;
    }
  }
  if (sceneMode==28) {// rotate
    for (Sprite s : sprites) {
      s.moveAngle = atan2(height/2-s.pos.y, width/2-s.pos.x)+HALF_PI*rotDirection;
    }
  }
  if (sceneMode==29) {// stairs
  }
  if (sceneMode==30) {// backforth
    for (Sprite s : sprites) {
      s.moveSpeed = s.moveSpeed*0.999;
    }
  }
}

float avgDanceMovePerSecond = 2.0;
float sceneChangeProba = 0;//Float.MAX_VALUE;
void danceMove() {
  if (random(avgDanceMovePerSecond)<sceneChangeProba) nextMode();
  sceneChangeProba = map(sin((float)frameCount/3000), -1, 1, 0.01, 0.17);
  if (millis()-lastModeSwitch > 1000*2*60) nextMode();

  int tempSceneMode = sceneMode;
  if (random(100)<modeEventScramblePercent) tempSceneMode = floor(random(nbSceneModes));

  if (tempSceneMode==0) {// rien
  }
  if (tempSceneMode==1) {// vagues de beaucoup
  }
  if (tempSceneMode==2) {// orthogonal
  }
  if (tempSceneMode==3) {// esther williams
    if (random(avgDanceMovePerSecond)<0.03) sceneInit();
  }
  if (tempSceneMode==4) {// single
  }
  if (tempSceneMode==5) {// shivering
    if (random(avgDanceMovePerSecond)<(float)sprites.size()*5.0f && sprites.size()>0) sprites.get(floor(random(sprites.size()))).moveAngle = random(TWO_PI);
    if (random(avgDanceMovePerSecond)<0.1) nextMode();
  }
  if (tempSceneMode==6) {// grid
  }
  if (tempSceneMode==7) {// bounce
  }
  if (tempSceneMode==8) {// symmetry
    if (random(avgDanceMovePerSecond)<0.1) sceneInit();
  }
  if (tempSceneMode==9) {// snake
  }
  if (tempSceneMode==10) {// merging
    if (random(avgDanceMovePerSecond)<sprites.size() && sprites.size()>0) {
      Sprite randomSprite = sprites.get(floor(random(sprites.size())));
      if (!randomSprite.isLeaving) randomSprite.target = new PVector((float)width/2, (float)height/2);
    }
  }
  if (tempSceneMode==11) {// lava lamp
  }
  if (tempSceneMode==12) {// wind
  }
  if (tempSceneMode==13) {// sur les bords
  }
  if (tempSceneMode==14) {// curves
  }
  if (tempSceneMode==15) {// speed scale
  }
  if (tempSceneMode==16) {// shift direction
    if (random(avgDanceMovePerSecond)<1.0) sceneInit();
    for (Sprite s : sprites) {
      if (!s.isLeaving) if (random(avgDanceMovePerSecond)<1.0/sprites.size()) s.moveAngle+=PI;
    }
  }
  if (tempSceneMode==17) {// merge to several points
    if (random(avgDanceMovePerSecond)<0.3) sceneInit();
    if (mergingPoints==null) sceneInit();
    for (Sprite s : sprites) {
      if (random(avgDanceMovePerSecond)<0.5) {
        if (!s.isLeaving) {
          if (mergingPoints!=null && mergingPoints.size()>0) {
            s.target = mergingPoints.get(floor(random(mergingPoints.size())));
            s.moveSpeed = random(2, 70);
            if (useSound) triggerNote(s);
          }
        }
      }
    }
  }
  if (tempSceneMode==18) {// regulatePopulation
  }
  if (tempSceneMode==19) {// gravitation
    if (random(avgDanceMovePerSecond)<0.3) sceneInit();
  }
  if (tempSceneMode==20) {// pluie
  }
  if (tempSceneMode==21) {// spiral
    if (random(avgDanceMovePerSecond)<0.2) {
      chosenAnim = pickWeightedRandomAnim();
      chosenAnimRate = random(2, 10)*(round(random(1))*2-1);
    }
  }
  if (tempSceneMode==22) {// dance spawn
    if (random(avgDanceMovePerSecond)<danceSpawnDensity) {
      if (deltaTime-(1000.0/targetFrameRate)<frameMsMargin) {// if it's not lagging
        if (sprites.size()<maxNumSprites || maxNumSprites==-1) {
          Anim anim = pickWeightedRandomAnim();
          if (chosenAnim!=null) anim = chosenAnim;
          PVector position = new PVector(random(width), random(height));
          Sprite newSprite = new Sprite(anim, random(1, 10), position, random(TWO_PI), random(20));
          newSprite.flipHorizontal = random(1)<0.5;
          newSprite.flipVertical = random(1)<0.5;
          sprites.add(newSprite);
          if (useSound) triggerNote(newSprite);
        }
      }
    }
  }
  if (tempSceneMode==23) {// repulse
    if (random(avgDanceMovePerSecond)<10.0/(sprites.size()+1)) {
      if (deltaTime-(1000.0/targetFrameRate)<frameMsMargin) {// if it's not lagging
        if (sprites.size()<maxNumSprites || maxNumSprites==-1) {
          Anim anim = pickWeightedRandomAnim();
          if (chosenAnim!=null) anim = chosenAnim;
          PVector position = new PVector(width/2+random(-500, 500), height/2+random(-500, 500));
          Sprite newSprite = new Sprite(anim, chosenAnimRate, position, random(TWO_PI), 10);
          newSprite.flipHorizontal = random(1)<0.5;
          newSprite.flipVertical = random(1)<0.5;
          sprites.add(newSprite);
          if (useSound) triggerNote(newSprite);
        }
      }
    }
    if (sprites.size()>0) {
      Sprite body = sprites.get(floor(random(sprites.size())));
      Sprite otherBody = sprites.get(floor(random(sprites.size())));
      if (body != otherBody) {
        float angle = atan2(body.pos.y-otherBody.pos.y, body.pos.x-otherBody.pos.x);
        otherBody.moveAngle = angle;
        body.moveAngle = angle+PI;
      }
    }
  }
  if (tempSceneMode == 24) { // teleportation
    PVector target = new PVector(random(width), random(height));
    for (Sprite sprite : sprites) {
      if (random(avgDanceMovePerSecond) < 7.0 / (sprites.size() + 1)) {
        sprite.pos.set(target);
        sprite.moveSpeed=0;
        sprite.animFrameRate=random(1, 7)*(round(random(1))*2-1);
        if (random(1)<0.5) sprite.moveSpeed=random(5);
        if (useSound) triggerNote(sprite);
      }
    }
  }
  if (tempSceneMode==25) {// path
  }
  if (tempSceneMode==26) {// stroke
    for (int i=0; i<max(0, sprites.size()-20); i++) {
      sprites.get(i).moveSpeed = 30;
      sprites.get(i).leave();
    }
  }
  if (tempSceneMode==27) {// cells
    if (sprites.size()>0) {
      Sprite sprite = sprites.get(floor(random(sprites.size())));
      if (useSound) triggerNote(sprite);
      float angle = random(TWO_PI);
      Sprite newSprite = new Sprite(sprite.anim, sprite.animFrameRate, sprite.pos.copy(), angle, 15);
      newSprite.flipHorizontal = sprite.flipHorizontal;
      newSprite.flipVertical = sprite.flipVertical;
      sprites.add(newSprite);
      sprite.moveAngle = angle+PI;
      sprite.moveSpeed = 15;
    }
  }
  if (tempSceneMode==28) {// rotate
    if (random(avgDanceMovePerSecond)<0.05) {
      rotDirection = random(1)<0.5?1:-1;
    }
  }
  if (tempSceneMode==29) {// stairs
    stairShift=(stairShift+1)%stairShiftLimit;
    for (int i=0; i<sprites.size(); i++) {
      sprites.get(i).moveAngle = (((float)i+stairShift)%4)*HALF_PI;
    }
  }
  if (tempSceneMode==30) {// backforth
    if (sprites.size()>0) {
      Sprite s = sprites.get(floor(random(sprites.size())));
      s.animFrameRate = -s.animFrameRate;
      s.currentFrame = floor(s.currentFrame) + (1-(s.currentFrame%1));
    }
  }
}
