
abstract class DisplayMode {
  int frame;

  void enter() {
    frame = 0;
  }

  boolean isDone() {
    return frame>=DISPLAY_MODE_DURATION;
  }

  void forceComplete() {
    frame = DISPLAY_MODE_DURATION;
  }

  abstract void drawFrame();
}

class PassingMode extends DisplayMode {
  int secondaryAnim = 0;
  int secondaryFrame = DISPLAY_MODE_DURATION/2;

  void enter() {
    super.enter();
    secondaryAnim = relatedAnimIndex(1);
    secondaryFrame = DISPLAY_MODE_DURATION/2;
  }

  void drawFrame() {
    if (secondaryFrame>=DISPLAY_MODE_DURATION) {
      secondaryAnim = relatedAnimIndex(1);
      secondaryFrame = 0;
    }
    background(bgColor);
    imageMode(CENTER);
    drawAnimFrame(currentAnim, frame, width/2+(frame-50)*12, height*0.34, (50.0-abs((float)frame-50.0))*1.2/50.0, ((float)frame-50.0)/75, false, false);
    drawAnimFrame(secondaryAnim, secondaryFrame, width/2-(secondaryFrame-50)*12, height*0.66, (50.0-abs((float)secondaryFrame-50.0))*1.2/50.0, ((float)secondaryFrame-50.0)/75, false, false);
    frame++;
    secondaryFrame++;
  }
}

class CircleMode extends DisplayMode {
  int count = 8;
  int frameCountTotal = 0;
  void enter() {
    super.enter();
    count = floor(random(4, 12));
  }
  void drawFrame() {
    background(bgColor);
    imageMode(CENTER);
    float phase = (float)frame/DISPLAY_MODE_DURATION;
    float distanceFromCenter = (240+sin(phase*PI)*100);
    for (int i=0; i<count; i++) {
      drawAnimFrame(relatedAnimIndex(i/4), frame+i, width/2+cos((float)i/count*TWO_PI)*distanceFromCenter, height*1/2+sin((float)i/count*TWO_PI)*distanceFromCenter, (50.0-abs((float)frame-50.0))*0.55/50.0, ((float)frameCountTotal-50.0)/80, false, false);
    }
    frame++;
    frameCountTotal++;
  }
}

class GridMode extends DisplayMode {
  int nbX = 4;
  int nbY = 3;
  int frameCountTotal = 0;
  void enter() {
    super.enter();
    nbX = floor(random(3, 6));
    nbY = floor(random(2, 5));
  }
  void drawFrame() {
    background(bgColor);
    imageMode(CENTER);
    for (int x=0; x<nbX; x++) {
      for (int y=0; y<nbY; y++) {
        drawAnimFrame(relatedAnimIndex((x+y)%2), frame+x+y, (x+1)*width/(nbX+1), (y+1)*height/(nbY+1), max((50.0-abs((float)frame+(x*y)-50.0))*0.38/50.0, 0), ((float)frameCountTotal-50.0)/85, false, false);
      }
    }
    frame++;
    frameCountTotal++;
  }
}

class SpiralMode extends DisplayMode {
  int nbSprites;
  int[] animIndices;
  float[] angleOffsets;
  float[] radiusOffsets;
  float angularSpeed;
  float radialSpeed;

  void enter() {
    super.enter();
    nbSprites = floor(random(8, 14));
    animIndices = new int[nbSprites];
    angleOffsets = new float[nbSprites];
    radiusOffsets = new float[nbSprites];
    angularSpeed = random(-0.06, 0.06);
    radialSpeed = random(3, 7);
    for (int i=0; i<nbSprites; i++) {
      animIndices[i] = relatedAnimIndex(i/5);
      if (random(100)<50) animIndices[i] = anims.size()-floor(random(random(random(anims.size()))))-1;
      angleOffsets[i] = i*TWO_PI/max(1, nbSprites);
      radiusOffsets[i] = i*28;
    }
  }

  void drawFrame() {
    background(bgColor);
    imageMode(CENTER);
    float maxRadius = dist(0, 0, width/2, height/2)+200;
    for (int i=0; i<nbSprites; i++) {
      float radius = (radiusOffsets[i]+frame*radialSpeed)%maxRadius;
      float angle = angleOffsets[i]+frame*angularSpeed+radius*0.015;
      float scaleValue = map(radius, 0, maxRadius, 0.2, 1.0);
      drawAnimFrame(animIndices[i], frame+i*2, width/2+cos(angle)*radius, height/2+sin(angle)*radius, scaleValue, angle+HALF_PI, false, false);
    }
    frame++;
  }
}

class StairsMode extends DisplayMode {
  int nbSteps;
  int[] animIndices;
  float[] scaleValues;
  int stairShiftLimit;
  float[] frameIndices;
  float[] frameRates;

  void enter() {
    super.enter();
    nbSteps = floor(random(5, 9));
    animIndices = new int[nbSteps];
    scaleValues = new float[nbSteps];
    stairShiftLimit = floor(random(2, 4));
    frameIndices = new float[nbSteps];
    frameRates = new float[nbSteps];
    for (int i=0; i<nbSteps; i++) {
      animIndices[i] = relatedAnimIndex(i/3);
      if (random(100)<50) animIndices[i] = anims.size()-floor(random(random(random(anims.size()))))-1;
      scaleValues[i] = random(0.3, 0.8);
      frameIndices[i] = i;
      frameRates[i] = random(0.7, 1.3);
    }
  }

  void drawFrame() {
    background(bgColor);
    imageMode(CENTER);
    int stairShift = (frame/12)%stairShiftLimit;
    for (int i=0; i<nbSteps; i++) {
      float x = map(i, 0, max(1, nbSteps-1), width*0.18, width*0.82);
      float y = map(i, 0, max(1, nbSteps-1), height*0.24, height*0.76);
      float travel = sin((frame+i*5)*0.08)*25;
      int direction = (i+stairShift)%4;
      float offsetX = 0;
      float offsetY = 0;
      if (direction==0) offsetX = travel;
      if (direction==1) offsetY = travel;
      if (direction==2) offsetX = -travel;
      if (direction==3) offsetY = -travel;
      drawAnimFrame(animIndices[i], floor(frameIndices[i]), x+offsetX, y+offsetY, scaleValues[i], direction*HALF_PI, false, false);
      frameIndices[i]+=frameRates[i];
    }
    frame++;
  }
}

class SingleBounceMode extends DisplayMode {
  float posX;
  float posY;
  float dirX;
  float dirY;
  float angle;
  float spin;
  float scaleValue;
  boolean flipHorizontal;
  boolean flipVertical;
  int animIndex;

  void enter() {
    super.enter();
    animIndex = currentAnim;
    if (random(100)<50) animIndex = anims.size()-floor(random(random(random(anims.size()))))-1;
    posX = random(width*0.35, width*0.65);
    posY = random(height*0.35, height*0.65);
    float moveAngle = random(TWO_PI);
    float moveSpeed = random(4, 24);
    dirX = cos(moveAngle)*moveSpeed;
    dirY = sin(moveAngle)*moveSpeed;
    angle = random(TWO_PI);
    spin = random(-0.04, 0.04);
    scaleValue = 1.7-random(random(1.5f));
    flipHorizontal = random(1)<0.5;
    flipVertical = false;
  }

  void drawFrame() {
    background(bgColor);
    imageMode(CENTER);
    PImage im = getAnimFrame(animIndex, frame);
    posX += dirX;
    posY += dirY;
    float halfW = im.width*scaleValue/2;
    float halfH = im.height*scaleValue/2;
    if (posX<halfW || posX>width-halfW) {
      dirX *= -1;
      posX = constrain(posX, halfW, width-halfW);
      flipHorizontal = !flipHorizontal;
    }
    if (posY<halfH || posY>height-halfH) {
      dirY *= -1;
      posY = constrain(posY, halfH, height-halfH);
      flipVertical = !flipVertical;
    }
    angle += spin;
    drawAnimFrame(animIndex, frame, posX, posY, scaleValue, angle, flipHorizontal, flipVertical);
    frame++;
  }
}

class SymmetryMode extends DisplayMode {
  int symmetryType;
  int nbSeeds;
  int[] animIndices;
  float[] phaseOffsets;
  float[] speedValues;
  float[] ampXValues;
  float[] ampYValues;
  float[] scaleValues;
  float[] rotationOffsets;

  void enter() {
    super.enter();
    symmetryType = floor(random(3));
    nbSeeds = 1+(currentAnim%2);
    animIndices = new int[nbSeeds];
    phaseOffsets = new float[nbSeeds];
    speedValues = new float[nbSeeds];
    ampXValues = new float[nbSeeds];
    ampYValues = new float[nbSeeds];
    scaleValues = new float[nbSeeds];
    rotationOffsets = new float[nbSeeds];
    for (int i=0; i<nbSeeds; i++) {
      animIndices[i] = relatedAnimIndex(i);
      phaseOffsets[i] = i*TWO_PI/max(1, nbSeeds);
      speedValues[i] = random(0.015, 0.035)*(random(1)<0.5 ? -1 : 1);
      ampXValues[i] = random(width*0.08, width*0.22);
      ampYValues[i] = random(height*0.08, height*0.2);
      scaleValues[i] = random(0.5, 1.3);
      rotationOffsets[i] = i*TWO_PI/4.0;
    }
  }

  void drawFrame() {
    background(bgColor);
    imageMode(CENTER);
    for (int i=0; i<nbSeeds; i++) {
      float phase = phaseOffsets[i]+frame*speedValues[i];
      float x = width/2+cos(phase)*ampXValues[i];
      float y = height/2+sin(phase*1.4)*ampYValues[i];
      float rotation = phase+rotationOffsets[i];
      drawAnimFrame(animIndices[i], frame+i*2, x, y, scaleValues[i], rotation, false, false);
      if (symmetryType==0 || symmetryType==2) {
        drawAnimFrame(animIndices[i], frame+i*2, width-x, y, scaleValues[i], PI-rotation, true, false);
      }
      if (symmetryType==0 || symmetryType==1) {
        drawAnimFrame(animIndices[i], frame+i*2, x, height-y, scaleValues[i], -rotation, false, true);
      }
      if (symmetryType==0) {
        drawAnimFrame(animIndices[i], frame+i*2, width-x, height-y, scaleValues[i], rotation+PI, true, true);
      }
    }
    frame++;
  }
}

class EdgeTravelMode extends DisplayMode {
  int nbSprites;
  int[] animIndices;
  float[] distanceOffsets;
  float[] speedValues;
  float[] scaleValues;
  float margin;

  void enter() {
    super.enter();
    nbSprites = floor(random(4, 8));
    animIndices = new int[nbSprites];
    distanceOffsets = new float[nbSprites];
    speedValues = new float[nbSprites];
    scaleValues = new float[nbSprites];
    margin = min(random(200, 400), min(width, height)*0.3);
    float loop = perimeterLength(margin);
    for (int i=0; i<nbSprites; i++) {
      animIndices[i] = relatedAnimIndex(i/3);
      if (random(100)<5) animIndices[i] = anims.size()-floor(random(random(random(anims.size()))))-1;
      distanceOffsets[i] = loop*i/max(1, nbSprites);
      speedValues[i] = random(8, 16)*(random(1)<0.2 ? -1 : 1);
      scaleValues[i] = random(0.4, 0.8);
    }
  }

  void drawFrame() {
    background(bgColor);
    imageMode(CENTER);
    for (int i=0; i<nbSprites; i++) {
      float distance = distanceOffsets[i]+frame*speedValues[i];
      PVector position = perimeterPosition(distance, margin);
      float direction = perimeterDirection(distance, margin);
      drawAnimFrame(animIndices[i], frame+i*3, position.x, position.y, scaleValues[i], direction+HALF_PI, false, false);
    }
    frame++;
  }
}

class RainMode extends DisplayMode {
  int nbDrops;
  int[] animIndices;
  float[] frameIndices;
  float[] frameRates;
  float[] startXValues;
  float[] offsetValues;
  float[] speedValues;
  float[] scaleValues;
  float[] driftValues;

  void enter() {
    super.enter();
    nbDrops = floor(random(10, 50));
    animIndices = new int[nbDrops];
    startXValues = new float[nbDrops];
    offsetValues = new float[nbDrops];
    speedValues = new float[nbDrops];
    scaleValues = new float[nbDrops];
    scaleValues = new float[nbDrops];
    driftValues = new float[nbDrops];
    frameIndices = new float[nbDrops];
    frameRates = new float[nbDrops];
    for (int i=0; i<nbDrops; i++) {
      animIndices[i] = relatedAnimIndex(i/4);
      if (random(100)<5) animIndices[i] = anims.size()-floor(random(random(random(anims.size()))))-1;
      startXValues[i] = random((float)width*0.12, (float)width*0.88);
      offsetValues[i] = -i*120;
      speedValues[i] = random(4, 48);
      scaleValues[i] = random(0.4, 0.8);
      driftValues[i] = random(-PI, PI);
      frameIndices[i] = i;
      frameRates[i] = random(0.7, 1.3);
    }
  }

  void drawFrame() {
    background(bgColor);
    imageMode(CENTER);
    for (int i=0; i<nbDrops; i++) {
      float y = offsetValues[i]+frame*speedValues[i];
      float x = startXValues[i];
      drawAnimFrame(animIndices[i], floor(frameIndices[i]), x, y, scaleValues[i], HALF_PI+driftValues[i], false, false);
      frameIndices[i]+=frameRates[i];
    }
    frame++;
  }
}

class RotateMode extends DisplayMode {
  int nbSprites;
  int[] animIndices;
  float[] baseAngles;
  float[] radii;
  float[] scaleValues;
  int direction;
  float angularSpeed;

  void enter() {
    super.enter();
    nbSprites = floor(random(6, 10));
    animIndices = new int[nbSprites];
    baseAngles = new float[nbSprites];
    radii = new float[nbSprites];
    scaleValues = new float[nbSprites];
    direction = random(1)<0.5 ? 1 : -1;
    angularSpeed = random(0.02, 0.05);
    for (int i=0; i<nbSprites; i++) {
      animIndices[i] = relatedAnimIndex(i/4);
      baseAngles[i] = i*TWO_PI/max(1, nbSprites);
      radii[i] = map(i, 0, max(1, nbSprites-1), min(width, height)*0.14, min(width, height)*0.34);
      scaleValues[i] = random(0.2, 0.8);
    }
  }

  void drawFrame() {
    background(bgColor);
    imageMode(CENTER);
    for (int i=0; i<nbSprites; i++) {
      float angle = baseAngles[i]+frame*angularSpeed*direction;
      float radius = radii[i]+sin(frame*0.08+i)*30;
      drawAnimFrame(animIndices[i], frame+i*3, width/2+cos(angle)*radius, height/2+sin(angle)*radius, scaleValues[i], angle+HALF_PI*direction, false, false);
    }
    frame++;
  }
}

class BackForthMode extends DisplayMode {
  int nbSprites;
  int[] animIndices;
  float[] baseXValues;
  float[] baseYValues;
  float[] swingValues;
  float[] scaleValues;

  void enter() {
    super.enter();
    nbSprites = floor(random(4, 8));
    animIndices = new int[nbSprites];
    baseXValues = new float[nbSprites];
    baseYValues = new float[nbSprites];
    swingValues = new float[nbSprites];
    scaleValues = new float[nbSprites];
    for (int i=0; i<nbSprites; i++) {
      animIndices[i] = relatedAnimIndex(i/3);
      if (random(100)<5) animIndices[i] = anims.size()-floor(random(random(random(anims.size()))))-1;
      baseXValues[i] = map(i%2, 0, 1, width*0.34, width*0.66)+(i/2)*18;
      baseYValues[i] = map(i, 0, max(1, nbSprites-1), height*0.24, height*0.76);
      swingValues[i] = random(35, 90);
      scaleValues[i] = random(0.4, 1.0);
    }
    for (int i=0; i<5; i++) {
      int indexA = floor(random(nbSprites));
      int indexB = floor(random(nbSprites));
      float tmpbaseXValue = baseXValues[indexA];
      baseXValues[indexA] = baseXValues[indexB];
      baseXValues[indexB] = tmpbaseXValue;
      float tmpbaseYValue = baseYValues[indexA];
      baseYValues[indexA] = baseYValues[indexB];
      baseYValues[indexB] = tmpbaseYValue;
    }
  }

  void drawFrame() {
    background(bgColor);
    imageMode(CENTER);
    for (int i=0; i<nbSprites; i++) {
      Anim anim = anims.get(wrapIndex(animIndices[i], anims.size()));
      int animFrame = pingPongIndex(frame+i*2, anim.images.length);
      float offset = sin(frame*0.08+i*0.6)*swingValues[i];
      float x = baseXValues[i]+offset;
      float rotation = offset>=0 ? 0 : PI;
      drawAnimFrame(animIndices[i], animFrame, x, baseYValues[i], scaleValues[i], rotation, false, false);
    }
    frame++;
  }
}


class FullMode extends DisplayMode {
  int nbDrops;
  int[] animIndices;
  float[] frameIndices;
  float[] frameRates;
  float[] startXValues;
  float[] startYValues;
  float[] speedValues;
  float[] angleValues;
  float[] scaleValues;
  float[] driftValues;

  void enter() {
    super.enter();
    nbDrops = floor(random(5, 20));
    animIndices = new int[nbDrops];
    startXValues = new float[nbDrops];
    startYValues = new float[nbDrops];
    speedValues = new float[nbDrops];
    angleValues = new float[nbDrops];
    scaleValues = new float[nbDrops];
    driftValues = new float[nbDrops];
    frameIndices = new float[nbDrops];
    frameRates = new float[nbDrops];
    for (int i=0; i<nbDrops; i++) {
      animIndices[i] = floor(random(anims.size()));
      if (random(100)<5) animIndices[i] = anims.size()-floor(random(random(random(anims.size()))))-1;
      startXValues[i] = random((float)width*0.12, (float)width*0.88);
      startYValues[i] = random((float)height*0.12, (float)height*0.88);
      speedValues[i] = random(0, 16);
      angleValues[i] = random(TWO_PI);
      scaleValues[i] = random(0.2, 0.7);
      driftValues[i] = random(-PI, PI);
      frameIndices[i] = i;
      frameRates[i] = random(0.5, 1.5);
    }
  }

  void drawFrame() {
    background(bgColor);
    imageMode(CENTER);
    for (int i=0; i<nbDrops; i++) {
      float y = startYValues[i]+cos(angleValues[i])*speedValues[i]*frame;
      float x = startXValues[i]+sin(angleValues[i])*speedValues[i]*frame;
      drawAnimFrame(animIndices[i], floor(frameIndices[i]), x, y, scaleValues[i], HALF_PI+driftValues[i], false, false);
      frameIndices[i]+=frameRates[i];
    }
    frame++;
  }
}
