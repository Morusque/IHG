
ArrayList<Part> parts = new ArrayList<Part>();

void setup() {
  size(900, 900);
  reload();
  background(0xFF);
  generate();
}

void draw() {
  if (frameCount%100==0) generate();
}

class Part {
  int[] edgeType = new int[4];
  // up, right, down, left
  // 0 = dead end
  // 1 = large
  // 2 = two
  PImage im;
  Part(PImage im, int[] edgeType) {
    this.im=im;
    this.edgeType=edgeType;
  }
  boolean fitsWith(Request request, int rotation) {
    for (int i=0; i<4; i++) if (request.type[(i+rotation)%4]!=-1) if (request.type[(i+rotation)%4]!=edgeType[i]) return false; 
    return true;
  }
}

ArrayList<Part> partsFrom(PImage im) {
  ArrayList<Part> theseParts = new ArrayList<Part>();
  theseParts.add(new Part(im.get(123, 109, 628, 628), new int[]{1, 0, 1, 1}));
  theseParts.add(new Part(im.get(123, 897, 628, 628), new int[]{0, 1, 0, 1}));
  theseParts.add(new Part(im.get(877, 109, 628, 628), new int[]{1, 0, 0, 0}));
  theseParts.add(new Part(im.get(877, 897, 628, 628), new int[]{2, 0, 1, 0}));
  theseParts.add(new Part(im.get(1633, 109, 628, 628), new int[]{0, 0, 2, 0}));
  theseParts.add(new Part(im.get(1633, 897, 628, 628), new int[]{0, 1, 1, 0}));
  /*
  theseParts.add(new Part(im.get(123, 129, 628, 628), new int[]{1, 0, 1, 0}));
   theseParts.add(new Part(im.get(123, 917, 628, 628), new int[]{0, 1, 0, 1}));
   theseParts.add(new Part(im.get(877, 129, 628, 628), new int[]{1, 0, 0, 0}));
   theseParts.add(new Part(im.get(877, 917, 628, 628), new int[]{2, 0, 1, 0}));
   theseParts.add(new Part(im.get(1633, 129, 628, 628), new int[]{0, 0, 2, 0}));
   theseParts.add(new Part(im.get(1633, 917, 628, 628), new int[]{0, 1, 1, 0}));
   */
  return theseParts;
}

void generate() {
  background(0xFF);
  Body body = new Body(); 
  body.requests.add(new Request(2, 2, new int[]{-1, -1, -1, -1}));
  body.fulfilRequests();
  body.draw();
}

class Body {
  int tSize = 5;
  Part[][] bodyParts = new Part[tSize][tSize];
  ArrayList<Request> requests = new ArrayList<Request>();
  int[][] rotations = new int[tSize][tSize];
  int[][] partNb = new int[tSize][tSize];
  int currentPartNb=0;
  Body() {
  }
  void fulfilRequests() {
    while (requests.size()>0) processRequest(requests.remove(0));
  }
  void processRequest (Request request) {
    int partOffset = floor(random(parts.size()));
    int rotationOffset = floor(random(4));
    for (int i=0; i<parts.size(); i++) {
      Part thisPart = parts.get((partOffset+i)%parts.size());
      for (int rotation=0; rotation<4; rotation++) {
        int thisRotation = (rotation+rotationOffset)%4;
        if (thisPart.fitsWith(request, thisRotation)) {
          addPart(thisPart, request.x, request.y, thisRotation);
          return;
        }
      }
    }
  }
  void addPart(Part part, int xS, int yS, int rotation) {
    bodyParts[xS][yS] = part;
    rotations[xS][yS] = rotation;
    partNb[xS][yS] = currentPartNb++;
    for (int r=0; r<4; r++) {
      if (part.edgeType[(r-rotation+4)%4]>0) {
        int newX = xS;
        int newY = yS;
        if (r==0) newY-=1;
        if (r==1) newX+=1;
        if (r==2) newY+=1;
        if (r==3) newX-=1;
        if (bodyParts[newX][newY]==null && newX>=0 && newY>=0 && newX<tSize && newY<tSize) {
          Request thisRequest = new Request(newX, newY, new int[]{-1, -1, -1, -1});
          boolean requestFound = false;
          for (int i=0; i<requests.size(); i++) {
            if (requests.get(i).x==newX && requests.get(i).y==newY) {
              thisRequest = requests.get(i); 
              requestFound=true;
            }
          }
          if (newY-1>=0) if (bodyParts[newX][newY-1]!=null) thisRequest.type[0] = bodyParts[newX][newY-1].edgeType[(2-rotations[xS][yS]+4)%4];
          if (newX+1<tSize) if (bodyParts[newX+1][newY]!=null) thisRequest.type[1] = bodyParts[newX+1][newY].edgeType[(3-rotations[xS][yS]+4)%4];
          if (newY+1<tSize) if (bodyParts[newX][newY+1]!=null) thisRequest.type[2] = bodyParts[newX][newY+1].edgeType[(0-rotations[xS][yS]+4)%4];
          if (newX-1>=0) if (bodyParts[newX-1][newY]!=null) thisRequest.type[3] = bodyParts[newX-1][newY].edgeType[(1-rotations[xS][yS]+4)%4];
          if (newX==0) thisRequest.type[3] = 0;
          if (newX==tSize-1) thisRequest.type[1] = 0;
          if (newY==0) thisRequest.type[0] = 0;
          if (newY==tSize-1) thisRequest.type[2] = 0;
          if (!requestFound) requests.add(thisRequest);
        }
      }
    }
  }
  void draw() {
    float size = 150;
    for (int x=0; x<bodyParts.length; x++) {
      for (int y=0; y<bodyParts[x].length; y++) {
        if (bodyParts[x][y]!=null) {
          imageMode(CENTER);
          pushMatrix();
          translate(100+x*size, 100+y*size);
          rotate(HALF_PI*rotations[x][y]);
          image(bodyParts[x][y].im, 0, 0, size, size);
          fill(0);
          // text(partNb[x][y], 0, -10);
          // text(rotations[x][y], 0, 10);
          popMatrix();
        } else {
          rectMode(CENTER);
          pushMatrix();
          translate(100+x*size, 100+y*size);
          noFill();
          stroke(0xE0);
          rect(0, 0, size, size);
          popMatrix();
        }
      }
    }
  }
}

class Request {
  int x;
  int y;
  int[] type = new int[4];
  Request(int x, int y, int[] type) {
    this.x=x;
    this.y=y;
    this.type=type;
  }
}

int nbSavedPics = 0;

int nbExported = 0;
void keyPressed() {
  if (keyCode==CONTROL) reload();
  if (keyCode==TAB) save(dataPath("result/"+nf(nbSavedPics++, 4)+".png"));
  generate();
  // save(dataPath("result/"+nf(nbExported++, 4)+".png"));
}

void reload() {
  parts.clear();
  String[] files = getAllFilesFrom(dataPath("input"));
  for (String f : files) parts.addAll(partsFrom(loadImage(f)));
}