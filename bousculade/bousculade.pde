
// scans publics : carrés en haut
// scans publics : H en bas

import java.util.Collections;

ArrayList<String> doneUrls = new ArrayList<String>();
ArrayList<Anim> anims = new ArrayList<Anim>();
ArrayList<Sprite> sprites = new ArrayList<Sprite>();

PImage[] borderA = new PImage[6];
PImage[] borderB = new PImage[6];

float lastMillis=0;
float deltaTime=0;

boolean useSound = true;

float targetFrameRate = 20;
float frameMsMargin = 10;

boolean refreshBackground = true;
int refreshDuration=0;

Sprite boule;

ArrayList<Float> moveLog = new ArrayList<Float>();

int nbGifsExported = 0;

boolean mergeShapes = true;

PApplet theApplet;

int targetMode = 7;

boolean publicMode = true;

boolean autoNextSwitch = true;

int currentBackgroundIndex = 0;

void setup() {
  loadBoule();
  loadImages();
  Collections.shuffle(anims);
  // size(1920, 1080);
  // size(300, 300);
  // fullScreen(P2D, 2);
  fullScreen(P2D, 2);
  frameRate(targetFrameRate);
  noCursor();
  for (int i=0; i<borderA.length; i++) borderA[i]=loadImage(dataPath("files/border/A_"+nf(i, 2)+".png"));
  for (int i=0; i<borderB.length; i++) borderB[i]=loadImage(dataPath("files/border/B_"+nf(i, 2)+".png"));
  if (useSound) setupSound();
  System.gc();
  // for (int i=0; i<quantity.length; i++) quantity[i]=0;
  theApplet = this;
}

void draw() {
  /*
  quantity[sprites.size()]+=1;
   String[] out = new String[200];
   for (int i=0; i<quantity.length; i++) out[i] = str(quantity[i]);
   saveStrings("trackQuantity.txt", out);
   */
  /*
  println("sprites : "+sprites.size());
   for (Sprite s : sprites) {// < tracking NaNs, remove it for presentation
   println(s.pos);
   if (Float.isNaN(s.pos.x)||Float.isNaN(s.pos.y)) {
   exit();
   }
   }
   */

  deltaTime = millis()-lastMillis;
  lastMillis = millis();

  if (useSound) soundUpdate();

  if (refreshBackground) if (random(1)<0.0) {// intentionally unlikely to happen
    refreshBackground = false;
    refreshDuration = ceil(frameRate*20);
  }
  if (!refreshBackground) {
    refreshDuration--;
    if (refreshDuration*2<0x100) {
      noStroke();
      fill(0xFF, constrain(0x100-refreshDuration*2, 0, 0xFF));
      rect(0, 0, width, height);
    }
    if (refreshDuration<=0) refreshBackground=true;
  }
  
  if ((frameCount%4)==0) {
    currentBackgroundIndex = floor(currentBackgroundIndex+random(1,2.3))%6;
  }

  sceneUpdate();
  updateBoule();

  for (Sprite s : sprites) s.update();
  sprites.removeIf(Sprite::pendingKill);

  float thisMoveLog = 0;
  for (Sprite s : sprites) thisMoveLog += s.dir.mag();
  moveLog.add(thisMoveLog);
  while (moveLog.size()>100) moveLog.remove(0);

  if (refreshBackground) background(0xFF, 0xFF, 0xFF);
  noTint();
  boule.drawLayer(0);
  boule.drawLayer(1);
  if (mergeShapes) tint(0, 255);
  else noTint();
  for (Sprite s : sprites) s.drawLayer(0);
  noTint();
  imageMode(CENTER);
  image(borderA[currentBackgroundIndex], width/2, height/2);
  if (mergeShapes) tint(0xFF, 0xFF, 0xFF, 0xFF);
  else noTint();
  for (Sprite s : sprites) s.drawLayer(1);
  noTint();
  imageMode(CENTER);
  image(borderB[currentBackgroundIndex], width/2, height/2);
  /*
  int[] notes = notesForTime(millis()-bgmStartTime, allowedNoteEvents);
   for (int n : notes) {
   noStroke();
   fill(0xFF, 0, 0);
   rect(0, height-n*10, 50, -10);
   }
   */
}

void keyPressed() {
  if (keyCode==CONTROL) thread("loadImages");
  if (keyCode==ENTER) {
    Anim anim = pickWeightedRandomAnim();
    PVector position = new PVector(random(width), random(height));
    float animFR = preferredAFR*pow(2, random(5))*(round(random(1))*2-1);
    Sprite newSprite = new Sprite(anim, animFR, position, random(TWO_PI), random(1, 10));
    newSprite.flipHorizontal = random(1)<0.5;
    newSprite.flipVertical = random(1)<0.5;
    sprites.add(newSprite);
    if (useSound) triggerNote(newSprite);
  }
  if (keyCode==RIGHT) nextMode();
  if (keyCode==UP) {
    targetMode=(targetMode+1)%31;
  }
  if (keyCode==LEFT) {// TEST
    sceneMode=targetMode;
    println("switch to scene mode : "+nf(sceneMode, 2)+" : "+sceneName(sceneMode));
    sceneInit();
  }
  if (keyCode==TAB) {
    save(sketchPath(year()+" "+nf(month(), 2)+" "+nf(day(), 2)+" "+nf(hour(), 2)+"h"+nf(minute(), 2)+" "+frameCount+".png"));
  }
  if (key=='m') {
    triggerBgm();
  }
  if (key=='r') {
    musicMode = 0;
    randomizeTracks();
  }
  if (key=='a') {
    currentAppearSfxIndex=-1;
  }
  if (key=='g') {
    for (Anim a : anims) {
      a.exportFrames();
    }
  }
  if (key=='c') {
    sprites.clear();
  }
  if (key=='p') {
    invertPanner ^= true;
    println("invertPanner : "+invertPanner);
  }
  if (key=='s') {
    autoNextSwitch ^= true;
    println("autoNextSwitch : "+autoNextSwitch);
  }
  if (key=='l') {
    for (Sprite s : sprites) s.leave();
  }
}

void loadBoule() {
  println("loading boule");
  Anim bouleAnim = new Anim();
  int nbX = 4;
  int nbY = 3;
  bouleAnim.layerA = new PImage[nbX*nbY];
  bouleAnim.layerB = new PImage[nbX*nbY];
  float maxWidth = 0;
  float maxHeight = 0;
  for (int j=0; j < nbX*nbY; j++) {
    bouleAnim.layerA[j] = loadImage(dataPath("files/boule/p_a_boule01_"+nf(j, 2)+".png"));
    bouleAnim.layerB[j] = loadImage(dataPath("files/boule/p_b_boule01_"+nf(j, 2)+".png"));
    maxWidth  =  max(maxWidth, bouleAnim.layerA[j].width, bouleAnim.layerB[j].width);
    maxHeight = max(maxHeight, bouleAnim.layerA[j].height, bouleAnim.layerB[j].height);
  }
  bouleAnim.width=maxWidth;
  bouleAnim.height=maxHeight;
  bouleAnim.generateFlipped();
  PVector position = new PVector(random(width), random(height));
  if (random(1)<0.5f) position.x = ((random(1)<0.5f) ? -5000  : 5000);
  else position.y = ((random(1)<0.5f) ? -5000 : 5000);
  float angle = atan2(position.y-height/2, position.x-width/2);
  boule = new Sprite(bouleAnim, 5, position, angle, 5);
}

void updateBoule() {
  if (boule.target==null) {
    if (boule.isVisible()) {
      PVector position = new PVector(random(width), random(height));
      if (random(1)<0.5f) position.x = ((random(1)<0.5f) ? -boule.anim.width  : width+boule.anim.width);
      else position.y = ((random(1)<0.5f) ? -boule.anim.height : height+boule.anim.height); 
      boule.target = position;
    } else {
      if (random(frameRate)<0.003) boule.target = new PVector(width/2+random(random(-1000, 1000)), height/2+random(random(-1000, 1000)));
    }
  }
  boule.update();
}

void loadImages() {
  println("loading...");
  String[] inputUrl = getAllFilesFrom(dataPath("input"));
  int maxFiles = Integer.MAX_VALUE;
  int nbX = 4;
  int nbY = 3;
  for (int i=0; i<inputUrl.length; i++) {
    try {
      if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
        println("file : "+inputUrl[i]);
        String fileName = inputUrl[i].substring(dataPath("input").length()+1, inputUrl[i].length()-4);
        if (new File(dataPath("processed/"+"p_a_"+fileName+"_01"+".png")).exists()) {
          Anim anim = new Anim();
          anim.layerA = new PImage[nbX*nbY];
          anim.layerB = new PImage[nbX*nbY];
          float maxWidth = 0;
          float maxHeight = 0;
          for (int j=0; j < nbX*nbY; j++) {
            anim.layerA[j] = loadImage(dataPath("processed/"+"p_a_"+fileName+"_"+nf(j, 2)+".png"));
            anim.layerB[j] = loadImage(dataPath("processed/"+"p_b_"+fileName+"_"+nf(j, 2)+".png"));
            maxWidth  =  max(maxWidth, anim.layerA[j].width, anim.layerB[j].width);
            maxHeight = max(maxHeight, anim.layerA[j].height, anim.layerB[j].height);
          }
          anim.width=maxWidth;
          anim.height=maxHeight;
          anim.generateFlipped();
          if (!publicMode) if (mergeShapes) anim.convertToAlpha();
          anims.add(anim);
        } else {
          PImage im = loadImage(inputUrl[i]);
          Anim anim = new Anim();
          anim.layerA = new PImage[nbX*nbY];
          anim.layerB = new PImage[nbX*nbY];
          int startX = 220;
          int startY = 70;
          int sizeX = 1560;
          int sizeY = 1560;
          int spaceX = 1576;
          int spaceY = 1576;
          if (publicMode) {
            startX = 87;
            startY = 43;
            sizeX = 492;
            sizeY = 492;
            spaceX = 569;
            spaceY = 537;
          }
          int frameNb = 0;
          for (int y=0; y<nbY; y++) {
            for (int x=0; x<nbX; x++) {
              PImage cutted = cutShape(im.get(startX+spaceX*x, startY+spaceY*y, sizeX, sizeY));
              if (!publicMode) {
                anim.layerA[frameNb] = keepOnlyColor(cutted, color(0), 200);
                anim.layerB[frameNb] = keepEverythingBut(cutted, color(0), 200);
              } else {
                anim.layerA[frameNb] = cutted.get();
                anim.layerB[frameNb] = cutted.get();
              }
              anim.layerA[frameNb].resize(400, 400);
              anim.layerB[frameNb].resize(400, 400);
              frameNb++;
            }
          }
          anim.cropAnims();
          frameNb = 0;
          for (int y=0; y<nbY; y++) {
            for (int x=0; x<nbX; x++) {
              anim.layerA[frameNb].save(dataPath("processed/"+"p_a_"+fileName+"_"+nf(frameNb, 2)+".png"));
              anim.layerB[frameNb].save(dataPath("processed/"+"p_b_"+fileName+"_"+nf(frameNb, 2)+".png"));
              frameNb++;
            }
          }
          anim.generateFlipped();
          if (!publicMode) if (mergeShapes) anim.convertToAlpha();
          anims.add(anim);
        }
      }
      doneUrls.add(inputUrl[i]);
    }
    catch(Exception e) {
      println(e);
    }
    if (anims.size()>=maxFiles) break;
  }
  println("...done");
}

class Sprite {
  Anim anim;
  float animFrameRate;
  float currentFrame;
  PVector pos;
  PVector dir = new PVector(0, 0);
  boolean isLeaving = false;
  boolean isArriving = true;
  PVector target;
  boolean pendingKill=false;
  int layer =0;
  float moveAngle;
  float moveSpeed;
  boolean[] displayLayer;
  boolean flipHorizontal = false;
  boolean flipVertical = false;
  Sprite(Anim anim, float animFrameRate, PVector pos, float moveAngle, float moveSpeed) {
    this.anim=anim;
    this.animFrameRate=animFrameRate;
    this.pos=pos;
    this.moveAngle=moveAngle;
    this.moveSpeed=moveSpeed;
    this.currentFrame=0;
    displayLayer = new boolean[]{true, true};
  }
  void update() {
    float adjustedMoveSpeed = moveSpeed;
    adjustedMoveSpeed = min(adjustedMoveSpeed, 80);
    if (target!=null) {
      moveAngle = atan2(target.y-pos.y, target.x-pos.x);
      if (PVector.dist(pos, target)<=moveSpeed) {
        adjustedMoveSpeed = PVector.dist(pos, target);
        target=null;
      }
    }

    dir = new PVector(cos(moveAngle)*adjustedMoveSpeed, sin(moveAngle)*adjustedMoveSpeed);

    pos.add(dir);
    currentFrame = currentFrame+deltaTime*animFrameRate/1000.0;
    while (currentFrame<0 || currentFrame>=anim.layerA.length) currentFrame = (currentFrame+anim.layerA.length)%anim.layerA.length;

    if (pos.x<-anim.width/2 || pos.y<-anim.height/2 || pos.x>=width+anim.width/2 || pos.y>=height+anim.height/2) {
      if (!isArriving) pendingKill=true;
      if (isLeaving) pendingKill=true;
    } else {
      isArriving = false;
    }
  }
  void leave() {
    isLeaving = true;
    if (moveAngle==0) moveAngle = floor(random(4))*HALF_PI;
    moveSpeed = max(moveSpeed, 2);
  }
  void drawLayer(int layerIndex) {
    imageMode(CENTER);
    PImage imageToDisplay = null;
    if (!flipHorizontal && !flipVertical) {
      if (layerIndex==0) if (displayLayer[0]) imageToDisplay = anim.layerA[floor(currentFrame)];
      if (layerIndex==1) if (displayLayer[1]) imageToDisplay = anim.layerB[floor(currentFrame)];
    }
    if (flipHorizontal && !flipVertical) {
      if (layerIndex==0) if (displayLayer[0]) imageToDisplay = anim.layerAFH[floor(currentFrame)];
      if (layerIndex==1) if (displayLayer[1]) imageToDisplay = anim.layerBFH[floor(currentFrame)];
    }
    if (!flipHorizontal && flipVertical) {
      if (layerIndex==0) if (displayLayer[0]) imageToDisplay = anim.layerAFV[floor(currentFrame)];
      if (layerIndex==1) if (displayLayer[1]) imageToDisplay = anim.layerBFV[floor(currentFrame)];
    }
    if (flipHorizontal && flipVertical) {
      if (layerIndex==0) if (displayLayer[0]) imageToDisplay = anim.layerAFVH[floor(currentFrame)];
      if (layerIndex==1) if (displayLayer[1]) imageToDisplay = anim.layerBFVH[floor(currentFrame)];
    }
    image(imageToDisplay, pos.x, pos.y);
    // rectMode(CENTER);
    // noFill();
    // stroke(0);
    // rect(pos.x, pos.y, anim.width, anim.height);
  }
  boolean pendingKill() {
    return pendingKill;
  }
  boolean isVisible() {
    if (pos.x < -(float)anim.width/2) return false;
    if (pos.y < -(float)anim.height/2) return false;
    if (pos.x > width+(float)anim.width/2) return false;
    if (pos.y > height+(float)anim.height/2) return false;
    return true;
  }
}

float benchmark;
void benchmark() {
  println(millis()-benchmark);
  benchmark=millis();
}

class Anim {
  PImage[] layerA;
  PImage[] layerB;
  PImage[] layerAFH;
  PImage[] layerBFH;
  PImage[] layerAFV;
  PImage[] layerBFV;
  PImage[] layerAFVH;
  PImage[] layerBFVH;
  float width;
  float height;
  void generateFlipped() {
    layerAFH = flipHorizontal(layerA);
    layerBFH = flipHorizontal(layerB);
    layerAFV = flipVertical(layerA);
    layerBFV = flipVertical(layerB);
    layerAFVH = flipVertical(layerAFH);
    layerBFVH = flipVertical(layerBFH);
  }

  PImage[] flipHorizontal(PImage[] original) {
    PImage[] flipped = new PImage[original.length];
    for (int i = 0; i < original.length; i++) {
      flipped[i] = new PImage((int)width, (int)height, ARGB);
      original[i].loadPixels();
      flipped[i].loadPixels();
      for (int y = 0; y < original[i].height; y++) {
        for (int x = 0; x < original[i].width; x++) {
          flipped[i].pixels[y * original[i].width + x] = original[i].pixels[y * original[i].width + (original[i].width - 1 - x)];
        }
      }
      flipped[i].updatePixels();
    }
    return flipped;
  }

  PImage[] flipVertical(PImage[] original) {
    PImage[] flipped = new PImage[original.length];
    for (int i = 0; i < original.length; i++) {
      flipped[i] = new PImage((int)width, (int)height, ARGB);
      original[i].loadPixels();
      flipped[i].loadPixels();
      for (int y = 0; y < original[i].height; y++) {
        for (int x = 0; x < original[i].width; x++) {
          flipped[i].pixels[x + (original[i].height - 1 - y) * original[i].width] = original[i].pixels[x + y * original[i].width];
        }
      }
      flipped[i].updatePixels();
    }
    return flipped;
  }

  void cropAnims() {
    int startX = Integer.MAX_VALUE;
    int startY = Integer.MAX_VALUE;
    int endX = 0;
    int endY = 0;
    for (int i = 0; i < layerA.length; i++) {
      PImage im = layerA[i];
      im.loadPixels();
      for (int x = 0; x < im.width; x++) {
        for (int y = 0; y < im.height; y++) {
          if (alpha(im.pixels[x + y * im.width]) > 0) {
            startX = min(startX, x);
            startY = min(startY, y);
            endX = max(endX, x);
            endY = max(endY, y);
          }
        }
      }
    }

    // Adjusting bounds to include a 1-pixel margin, ensuring they're within the image dimensions
    startX = max(startX - 1, 0);
    startY = max(startY - 1, 0);
    endX = min(endX + 1, layerA[0].width - 1);
    endY = min(endY + 1, layerA[0].height - 1);

    for (int i = 0; i < layerA.length; i++) {
      layerA[i] = layerA[i].get(startX, startY, endX - startX + 1, endY - startY + 1);
      layerB[i] = layerB[i].get(startX, startY, endX - startX + 1, endY - startY + 1);
    }

    width = endX - startX + 1;
    height = endY - startY + 1;
  }

  void convertToAlpha() {
    for (int i=0; i<layerA.length; i++) layerA[i] = toAlphaMode(layerA[i]);
    for (int i=0; i<layerB.length; i++) layerB[i] = toAlphaMode(layerB[i]);
    for (int i=0; i<layerAFH.length; i++) layerAFH[i] = toAlphaMode(layerAFH[i]);
    for (int i=0; i<layerBFH.length; i++) layerBFH[i] = toAlphaMode(layerBFH[i]);
    for (int i=0; i<layerAFV.length; i++) layerAFV[i] = toAlphaMode(layerAFV[i]);
    for (int i=0; i<layerBFV.length; i++) layerBFV[i] = toAlphaMode(layerBFV[i]);
    for (int i=0; i<layerAFVH.length; i++) layerAFVH[i] = toAlphaMode(layerAFVH[i]);
    for (int i=0; i<layerBFVH.length; i++) layerBFVH[i] = toAlphaMode(layerBFVH[i]);
  }
  void exportFrames() {
    for (int i=0; i<layerA.length; i++) {
      PGraphics g = createGraphics(floor(this.width), floor(this.height), JAVA2D);
      g.beginDraw();
      if (mergeShapes) g.tint(0, 255);
      else g.noTint();
      g.image(layerA[i], 0, 0);
      g.image(layerB[i], 0, 0);
      g.endDraw();
      g.save(dataPath("exports/"+nf(nbGifsExported, 3)+"_"+nf(i, 1)+".png"));
    }
    nbGifsExported++;
  }
}

PImage keepOnlyColor(PImage in, color c, float threshold) {
  in.loadPixels();
  PImage out = createImage(in.width, in.height, ARGB);
  for (int x=0; x<out.width; x++) {
    for (int y=0; y<out.height; y++) {
      out.pixels[x+y*out.width] = color(0, 0);
      if (colorProximity(in.pixels[x+y*out.width], c)>threshold) out.pixels[x+y*out.width] = in.pixels[x+y*out.width];
    }
  }
  out.updatePixels();
  return out;
}

PImage keepEverythingBut(PImage in, color c, float threshold) {
  in.loadPixels();
  PImage out = createImage(in.width, in.height, ARGB);
  for (int x=0; x<out.width; x++) {
    for (int y=0; y<out.height; y++) {
      out.pixels[x+y*out.width] = in.pixels[x+y*out.width];
      if (colorProximity(in.pixels[x+y*out.width], c)>threshold) out.pixels[x+y*out.width] = color(0, 0);
    }
  }
  out.updatePixels();
  return out;
}

PImage convertColor(PImage in, color cFrom, color cTo, float threshold) {
  in.loadPixels();
  PImage out = createImage(in.width, in.height, ARGB);
  for (int x=0; x<out.width; x++) {
    for (int y=0; y<out.height; y++) {
      out.pixels[x+y*out.width] = in.pixels[x+y*in.width];
      if (alpha(in.pixels[x+y*out.width])>0) if (colorProximity(in.pixels[x+y*out.width], cFrom)>threshold) out.pixels[x+y*out.width] = cTo;
    }
  }
  out.updatePixels();
  return out;
}

float colorProximity(color a, color b) {
  // Extract the RGB components of each color
  float r1 = red(a);
  float g1 = green(a);
  float b1 = blue(a);

  float r2 = red(b);
  float g2 = green(b);
  float b2 = blue(b);

  // Calculate the Euclidean distance between the two colors in RGB space
  float distance = sqrt(sq(r2 - r1) + sq(g2 - g1) + sq(b2 - b1));

  // Invert the distance to get a proximity measure. You could adjust the scale factor (e.g., 255) to suit your needs.
  // This is a simple inversion where larger distances give lower scores, and vice versa.
  // Adjust the scale (255 in this case) as needed depending on your application's requirements.
  float proximity = 255 - distance;

  // Ensure the result is within a sensible range, especially if you adjust the scaling.
  proximity = max(0, min(proximity, 255));

  return proximity;
}

PImage cutShape(PImage oIm) {
  PImage im = oIm.get();
  // crop borders
  int margin = min(min(0, floor((float)im.width/2)), floor((float)im.height/2));
  if (publicMode) margin = min(min(3, floor((float)im.width/2)), floor((float)im.height/2));
  im = im.get(margin, margin, im.width-margin*2, im.height-margin*2);
  // add white margin
  PImage largerIm = createImage(im.width+2, im.height+2, RGB);
  largerIm.loadPixels();
  for (int i = 0; i < largerIm.pixels.length; i++) largerIm.pixels[i] = color(0xFF);
  largerIm.updatePixels();
  largerIm.copy(im, 0, 0, im.width, im.height, 1, 1, im.width, im.height);
  im = largerIm;
  // expand cutted zone
  float emptyThreshold = 35;
  if (publicMode) emptyThreshold = 15;
  boolean[] empty = new boolean[im.width*im.height];
  im.loadPixels();
  for (int x = 0; x<im.width; x++) {
    for (int y = 0; y<im.height; y++) {
      color c = im.pixels[x+y*im.width];
      if (0xFF*3-(red(c)+green(c)+blue(c))>emptyThreshold) empty[x+y*im.width] = false;
      else empty[x+y*im.width] = true;
    }
  }
  boolean[] done = new boolean[im.pixels.length];
  boolean[] toErase = new boolean[im.pixels.length];
  for (int i=0; i<im.pixels.length; i++) {
    done[i] = false;
    toErase[i] = false;
  }
  ArrayList<Integer> toCheck = new ArrayList<Integer>();
  toCheck.add(0);
  done[0] = true;
  while (toCheck.size()>0) {
    // println((float)toCheck.size()/done.length);
    /*
    if (toCheck.size()<50) {
     for (int i : toCheck) print(i+",");
     println("-");
     }
     */
    int thisIndex = toCheck.remove(0);
    if (empty[thisIndex]) {
      toErase[thisIndex] = true;
      if (!done[(thisIndex-1+done.length)%done.length]) {
        toCheck.add((thisIndex-1+done.length)%done.length);
        done[(thisIndex-1+done.length)%done.length] = true;
      }
      if (!done[(thisIndex+1+done.length)%done.length]) {
        toCheck.add((thisIndex+1+done.length)%done.length);
        done[(thisIndex+1+done.length)%done.length] = true;
      }
      if (!done[(thisIndex-im.width+done.length)%done.length]) {
        toCheck.add((thisIndex-im.width+done.length)%done.length);
        done[(thisIndex-im.width+done.length)%done.length] = true;
      }
      if (!done[(thisIndex+im.width+done.length)%done.length]) {
        toCheck.add((thisIndex+im.width+done.length)%done.length);
        done[(thisIndex+im.width+done.length)%done.length] = true;
      }
    }
  }
  PGraphics mask = createGraphics(im.width, im.height, JAVA2D);
  mask.beginDraw();
  for (int x=0; x<im.width; x++) {
    for (int y=0; y<im.height; y++) {
      mask.stroke(0xFF);
      if (toErase[x+y*im.width]) mask.stroke(0);
      for (int x2=-1; x2<2; x2++) {
        for (int y2=-1; y2<2; y2++) {
          if (toErase[((x+x2)+(y+y2)*im.width+toErase.length)%toErase.length]) mask.stroke(0);
        }
      }
      mask.point(x, y);
    }
  }
  mask.endDraw();
  im.mask(mask);
  // TODO trace polygon
  return im;
}

PImage mergePics(PImage a, PImage b) {
  PGraphics m = createGraphics(max(a.width, b.width), max(a.height, b.height));
  m.beginDraw();
  m.image(a, 0, 0);
  m.image(b, 0, 0);
  m.endDraw();
  return m.get();
}

boolean spritesOverlap(Sprite spriteA, Sprite spriteB, float tolerance) {
  float halfWidthA = spriteA.anim.width / tolerance;
  float halfHeightA = spriteA.anim.height / tolerance;
  float halfWidthB = spriteB.anim.width / tolerance;
  float halfHeightB = spriteB.anim.height / tolerance;
  if (abs(spriteA.pos.x - spriteB.pos.x) > (halfWidthA + halfWidthB)) return false;
  if (abs(spriteA.pos.y - spriteB.pos.y) > (halfHeightA + halfHeightB)) return false;
  return true;
}

PImage toAlphaMode(PImage im) {
  PImage alphaImage = createImage(im.width, im.height, ALPHA);
  im.loadPixels();
  alphaImage.loadPixels();
  for (int i = 0; i < im.pixels.length; i++) {
    int alphaValue = (im.pixels[i] >> 24) & 0xFF;
    alphaImage.pixels[i] = alphaValue;
  }
  alphaImage.updatePixels();
  return alphaImage;
}
