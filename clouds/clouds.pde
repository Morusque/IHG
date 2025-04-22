
ArrayList<String> doneUrls = new ArrayList<String>();
ArrayList<PImage> images = new ArrayList<PImage>();

int nbX = 4;
int nbY = 3;
float motifMaxSize = 340;

int currentIndex = 0;

boolean seeAnimatedMotif = false;

void setup() {
  size(1485, 1050);
  frameRate(5);
  //generate(null);
}

void draw() {
  if (seeAnimatedMotif) {
    background(0xFF);
    stroke(0);
    pushMatrix();
    translate(width/2, height/2);
    rectMode(CENTER);
    noFill();
    stroke(0xF0);
    rect(0, 0, motifMaxSize, motifMaxSize);
    stroke(0xB0);
    for (Shape s : shapes) s.draw((float)frameCount/((float)nbX*nbY)*TWO_PI);
    popMatrix();
  }
  if (images.size()>0) {
    background(0xFF);
    imageMode(CENTER);
    int indexX = (frameCount%4);
    int indexY = floor(((float)(frameCount%12)/4));
    image(images.get((currentIndex+images.size())%images.size()).get(98+indexX*852, 23+indexY*807, 800, 800), width/2, height/2);
  }
}

int nbExported = 0;

ArrayList<Shape> shapes = new ArrayList<Shape>();
void generate(int[] types) {
  shapes.clear();
  background(0xFF);
  // PVector motifSize = new PVector((float)width/nbX, (float)height/nbY);
  PVector motifSize = new PVector(motifMaxSize+3, motifMaxSize+3);
  int nbShapes;
  if (types == null) {
    nbShapes = floor(random(2, 6));
    for (int i=0; i<nbShapes; i++) shapes.add(new Shape(-1));
  } else {
    nbShapes = types.length;
    for (int i=0; i<nbShapes; i++) shapes.add(new Shape(types[i]));
  }
  for (int y=0; y<nbY; y++) {
    for (int x=0; x<nbX; x++) {
      PVector center = new PVector(15+motifSize.x*(x+0.5), 5+motifSize.y*(y+0.5));
      pushMatrix();
      translate(center.x, center.y);
      rectMode(CENTER);
      noFill();
      stroke(0xF0);
      rect(0, 0, motifMaxSize, motifMaxSize);
      stroke(0xB0);
      float phase = ((float)x+(float)y*(float)nbX)/((float)nbX*(float)nbY)*TWO_PI;
      for (int i=0; i<nbShapes; i++) shapes.get(i).draw(phase);
      popMatrix();
    }
  }
  fill(0);
  text("H", 2, 10);
  int[] shapesPerType = new int[5];
  for (int i=0; i<shapesPerType.length; i++) shapesPerType[i] = 0;
  for (int i=0; i<nbShapes; i++) shapesPerType[shapes.get(i).type]++;
  for (int i=0; i<shapesPerType.length; i++) {
    for (int j=0; j<shapesPerType[i]; j++) {
      rect(1410+j*20, 100+i*150, 15, 15);
    }
  }
}

class Shape {
  int type;// 0=ellipse, 1=rectangle, 2 = triangle, 3 = amibe, 4 = éclaté
  PVector size;
  PVector offset;
  int nbOsc;
  float[] oscFr;
  float[] oscAm;
  float[] oscPh;
  int moveMode;// 0 = both, 1 = horizontal, 2 = vertical
  float nbRot;
  Oscillator[] oscs;
  Oscillator[] oscsB;
  int nbPoints = 100;
  float amibeMaxNonNormSize=0;
  float eclateInternalSizeMin = 0.5;
  float eclateInternalSizeMax = 0.5;
  float eclateRotAmpInt = 0;
  float eclateRotAmpExt = 0;
  PVector rectShrink = new PVector(1, 1);
  float rectShrinkPhaseX = 0;
  float rectShrinkPhaseY = 0;
  Shape(int typeIn) {
    this.type = typeIn;
    if (typeIn == -1) this.type = floor(random(5));
    if (this.type==4 && random(1)<1.0) this.type = floor(random(4));
    offset = new PVector(random(-motifMaxSize/5, motifMaxSize/5), random(-motifMaxSize/5, motifMaxSize/5));
    nbOsc = floor(random(0, 4));
    oscFr = new float[nbOsc];
    oscAm = new float[nbOsc];
    oscPh = new float[nbOsc];
    nbRot = 0;
    if (type==1) {
      rectShrink = new PVector(random(0.5, 1), random(0.5, 1));
      rectShrinkPhaseX = random(TWO_PI);
      rectShrinkPhaseY = random(TWO_PI);
    }
    if (type==2) nbRot = round(random(-1, 1))/3.0;
    for (int i=0; i<nbOsc; i++) {
      oscFr[i] = round(random(-2, 2));
      oscAm[i] = random(-50, 50);
      oscPh[i] = random(TWO_PI);
    }
    moveMode = floor(random(3));
    PVector maxValues = new PVector(0, 0);
    for (int i=0; i<nbX*nbY; i++) {
      float phase = (float)i/((float)nbX*nbY)*TWO_PI;
      PVector position = getPositionFor(phase);
      maxValues.x = max(maxValues.x, abs(position.x));
      maxValues.y = max(maxValues.y, abs(position.y));
    }
    if (type==2 && nbRot!=0) {
      maxValues.x = maxValues.y = max(maxValues.x, maxValues.y);
    }
    if (type==3) {
      maxValues.x = maxValues.y = max(maxValues.x, maxValues.y);
      oscs = new Oscillator[20];
      for (int i=0; i<oscs.length; i++) {
        oscs[i] = new Oscillator();
      }
      for (int f=0; f<nbX*nbY; f++) {
        for (int i=0; i<nbPoints; i++) {
          float shapePhase = (float)i/(float)nbPoints;
          float shapeLength = 10;
          for (int j=0; j<oscs.length; j++) shapeLength += oscs[j].value(shapePhase, f/(nbX*nbY));
          amibeMaxNonNormSize = max(amibeMaxNonNormSize, abs(cos(shapePhase*TWO_PI)*shapeLength*10));
          amibeMaxNonNormSize = max(amibeMaxNonNormSize, abs(sin(shapePhase*TWO_PI)*shapeLength*10));
        }
      }
    }
    if (type==4) {
      nbPoints = floor(random(5, 10))*2;
      eclateInternalSizeMin = random(0.2, 0.9);
      eclateInternalSizeMax = random(0.4, 1.3);
      eclateRotAmpInt = random(-HALF_PI/nbPoints, HALF_PI/nbPoints);
      eclateRotAmpExt = random(-HALF_PI/nbPoints, HALF_PI/nbPoints);
      maxValues.x = maxValues.y = max(maxValues.x, maxValues.y);
      oscs = new Oscillator[20];
      oscsB = new Oscillator[5];
      for (int i=0; i<oscs.length; i++) oscs[i] = new Oscillator();
      for (int i=0; i<oscsB.length; i++) oscsB[i] = new Oscillator();
      for (int f=0; f<nbX*nbY; f++) {
        for (int i=0; i<nbPoints; i++) {
          float phase = f/(nbX*nbY)*TWO_PI;
          float shapePhase = (float)i/(float)nbPoints;
          float shapeLength = 5;
          if (i%2==0) for (int j=0; j<oscs.length; j++) shapeLength += oscs[j].value(shapePhase, phase/TWO_PI);
          else for (int j=0; j<oscsB.length; j++) shapeLength += oscsB[j].value(shapePhase, phase/TWO_PI);
          if (i%2==0) shapeLength*=map(sin(phase), -1, 1, eclateInternalSizeMin, eclateInternalSizeMax);
          float phaseShift = phase*eclateRotAmpExt;
          if (i%2==0) phaseShift = phase*eclateRotAmpInt;
          amibeMaxNonNormSize = max(amibeMaxNonNormSize, abs(phaseShift+cos(shapePhase*TWO_PI)*shapeLength*10));
          amibeMaxNonNormSize = max(amibeMaxNonNormSize, abs(phaseShift+sin(shapePhase*TWO_PI)*shapeLength*10));
        }
      }
    }
    size = new PVector(random((motifMaxSize/2-maxValues.x)/5, motifMaxSize/2-maxValues.x), random((motifMaxSize/2-maxValues.y)/5, motifMaxSize/2-maxValues.y));
    if (type==2||type==3||type==4) {
      size.x=min(size.x, size.y);
      size.y=min(size.x, size.y);
    }
    if (random(10)<5) {
      size.x=min(size.x, size.y);
      size.y=min(size.x, size.y);
    }
  }
  void draw(float phase) {
    PVector position = getPositionFor(phase);
    pushMatrix();
    translate(position.x, position.y);
    rotate(phase*nbRot);
    if (type==0) ellipse(0, 0, size.x*2, size.y*2);
    if (type==1) {
      scale(map(sin(rectShrinkPhaseX+phase), -1, 1, rectShrink.x, 1), map(sin(rectShrinkPhaseY+phase), -1, 1, rectShrink.y, 1));
      rect(0, 0, size.x*2, size.y*2);
    }
    if (type==2) triangle(size.x*cos(HALF_PI+TWO_PI*0/3), size.y*sin(HALF_PI+TWO_PI*0/3),
      size.x*cos(HALF_PI+TWO_PI*1/3), size.y*sin(HALF_PI+TWO_PI*1/3),
      size.x*cos(HALF_PI+TWO_PI*2/3), size.y*sin(HALF_PI+TWO_PI*2/3));
    if (type==3) {
      beginShape();
      for (int i=0; i<nbPoints; i++) {
        float shapePhase = (float)i/(float)nbPoints;
        float shapeLength = 10;
        for (int j=0; j<oscs.length; j++) shapeLength += oscs[j].value(shapePhase, phase/TWO_PI);
        vertex(cos(shapePhase*TWO_PI)*shapeLength*10*size.x/amibeMaxNonNormSize, sin(shapePhase*TWO_PI)*shapeLength*10*size.y/amibeMaxNonNormSize);
      }
      endShape(CLOSE);
    }
    if (type==4) {
      beginShape();
      for (int i=0; i<nbPoints; i++) {
        float shapePhase = (float)i/(float)nbPoints;
        float shapeLength = 5;
        if (i%2==0) for (int j=0; j<oscs.length; j++) shapeLength += oscs[j].value(shapePhase, phase/TWO_PI);
        else for (int j=0; j<oscsB.length; j++) shapeLength += oscsB[j].value(shapePhase, phase/TWO_PI);
        if (i%2==0) shapeLength*=map(sin(phase), -1, 1, eclateInternalSizeMin, eclateInternalSizeMax);
        float phaseShift = phase*eclateRotAmpExt;
        if (i%2==0) phaseShift = phase*eclateRotAmpInt;
        vertex(cos(phaseShift+shapePhase*TWO_PI)*shapeLength*10*size.x/amibeMaxNonNormSize, sin(phaseShift+shapePhase*TWO_PI)*shapeLength*10*size.y/amibeMaxNonNormSize);
      }
      endShape(CLOSE);
    }
    popMatrix();
  }
  PVector getPositionFor(float phase) {
    PVector position = new PVector(offset.x, offset.y);
    for (int i=0; i<nbOsc; i++) {
      if (moveMode!=2) position.x += cos(oscPh[i]+phase*oscFr[i])*oscAm[i];
      if (moveMode!=1) position.y += sin(oscPh[i]+phase*oscFr[i])*oscAm[i];
    }
    return position;
  }
}

void keyPressed() {
  if (keyCode==ENTER) generate(null);
  if (keyCode=='G') {
    ArrayList<int[]> types = generateArrays(3, 2);
    for (int[] t : types) {
      // println(t);
      // println("-");
      generate(t);
      save("combinations/"+nf(nbExported++, 5)+".png");
    }
  }
  if (keyCode==TAB)   save(nf(nbExported++, 5)+".png");
  if (keyCode == CONTROL) {
    println("loading...");
    String[] inputUrl = getAllFilesFrom(dataPath("input"));
    for (int i=0; i<inputUrl.length; i++) {
      try {
        if (!inArray(doneUrls.toArray(new String[doneUrls.size()]), inputUrl[i])) {
          println("file : "+inputUrl[i]);
          PImage im = loadImage(inputUrl[i]);
          images.add(im.get());
          doneUrls.add(inputUrl[i]);
        }
      }
      catch (Exception e) {
        println(e);
      }
    }
    println("...done");
  }
  if (keyCode==RIGHT) {
    currentIndex++;
  }
}

ArrayList<int[]> generateArrays(int n, int s) {
  ArrayList<int[]> result = new ArrayList<int[]>();
  for (int size = 1; size <= n; size++) {
    int[] currentArray = new int[size];
    generateArraysHelper(currentArray, size, 0, 0, s, result);
  }
  return result;
}

void generateArraysHelper(int[] currentArray, int size, int index, int start, int s, ArrayList<int[]> result) {
  if (index == size) {
    result.add(currentArray.clone());
    return;
  }
  for (int i = start; i <= s; i++) {
    currentArray[index] = i;
    generateArraysHelper(currentArray, size, index + 1, i, s, result);
  }
}


class Oscillator {
  float fr;
  float ph;
  float am;
  float bi;
  float sp;
  float mp;
  float ma;
  Oscillator() {
    fr = floor(random(1, random(1, 8)));
    ph = random(TWO_PI);
    am = random(0, 1);
    bi = 0;
    sp = round(random(-1, 1));
    mp = random(TWO_PI);
    ma = random(-1, 1);
  }
  float value(float t, float p) {
    return sin(((t)*TWO_PI+ph)*fr)*(am*map(sin(p*TWO_PI*sp+mp), -1, 1, 1, ma)+bi);
  }
}
