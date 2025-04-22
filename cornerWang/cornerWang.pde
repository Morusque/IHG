
int tileSize = 64;
Tile[] tiles = new Tile[16];
boolean[][] terrains = new boolean[20][20];
int[][] alts = new int[20][20];
int[][] tilesId = new int[20][20];
int nbAlts = 1;

boolean useMouse = false;
boolean atLeastOneTerrain = false;
int nbSaved = 0;

void setup() {
  size(900, 700);
  for (int x=0; x<terrains.length; x++) {
    for (int y=0; y<terrains[x].length; y++) {
      terrains[x][y] = false;
      alts[x][y] = 0;
    }
  }
  PGraphics emptyTile = createGraphics(tileSize, tileSize, JAVA2D);
  emptyTile.beginDraw();
  emptyTile.background(0xFF);
  emptyTile.endDraw();
  for (int i=0; i<tiles.length; i++) tiles[i] = new Tile();
  tiles[0].addTile(emptyTile.get());
  tiles[0].setConfig ("0000");
}

void draw() {
  background(0x50);
  modifyTerrains();
  if (atLeastOneTerrain) {
    for (int x=0; x<terrains.length-1; x++) {
      for (int y=0; y<terrains[x].length-1; y++) {
        image(tiles[tilesId[x][y]].pics.get(alts[x][y]), x*tileSize, y*tileSize);
      }
    }
  }
  if (useMouse) {
    int tX = floor((float)(mouseX+(float)tileSize/2)/tileSize);
    int tY = floor((float)(mouseY+(float)tileSize/2)/tileSize);
    noFill();
    stroke(0, 0xA0, 0);
    rect((tX-0.5f)*tileSize, (tY-0.5f)*tileSize, tileSize, tileSize);
  }
}

class Tile {
  ArrayList<PImage> pics = new ArrayList<PImage>();
  // boolean[] config = new boolean[4];
  String config;
  Tile () {
  }
  void addTile (PImage pic) {
    this.pics.add(pic);
  }
  void setConfig(String configS) {
    // for (int i=0; i<4; i++) config[i] = (configS.charAt(i)=='1');
    config = configS;
  }
  void addTileConfig (PImage pic, String configS) {
    this.pics.add(pic);
    config = configS;
  }
}

boolean mouseRight = false;
boolean mouseLeft = false;
void mousePressed() {
  if (mouseButton==RIGHT) mouseRight=true;
  if (mouseButton==LEFT) mouseLeft=true;
}

void mouseReleased() {
  if (mouseButton==RIGHT) mouseRight=false;
  if (mouseButton==LEFT) mouseLeft=false;
}

void keyPressed() {
  if (keyCode==CONTROL) {
    String[] files = getAllFilesFrom(dataPath("input"));
    for (String f : files) {
      PImage tileset = loadImage(f);
      tileset = tileset.get(41, 45, 320, 192);
      tiles[1].addTileConfig(tileset.get(tileSize*0, tileSize*0, tileSize, tileSize), "0001");
      tiles[2].addTileConfig(tileset.get(tileSize*1, tileSize*0, tileSize, tileSize), "0011");
      tiles[3].addTileConfig(tileset.get(tileSize*2, tileSize*0, tileSize, tileSize), "0010");
      tiles[4].addTileConfig(tileset.get(tileSize*3, tileSize*0, tileSize, tileSize), "0111");
      tiles[5].addTileConfig(tileset.get(tileSize*4, tileSize*0, tileSize, tileSize), "1011");
      tiles[6].addTileConfig(tileset.get(tileSize*0, tileSize*1, tileSize, tileSize), "0101");
      tiles[7].addTileConfig(tileset.get(tileSize*1, tileSize*1, tileSize, tileSize), "1111");
      tiles[8].addTileConfig(tileset.get(tileSize*2, tileSize*1, tileSize, tileSize), "1010");
      tiles[9].addTileConfig(tileset.get(tileSize*3, tileSize*1, tileSize, tileSize), "1101");
      tiles[10].addTileConfig(tileset.get(tileSize*4, tileSize*1, tileSize, tileSize), "1110");
      tiles[11].addTileConfig(tileset.get(tileSize*0, tileSize*2, tileSize, tileSize), "0100");
      tiles[12].addTileConfig(tileset.get(tileSize*1, tileSize*2, tileSize, tileSize), "1100");
      tiles[13].addTileConfig(tileset.get(tileSize*2, tileSize*2, tileSize, tileSize), "1000");
      tiles[14].addTileConfig(tileset.get(tileSize*3, tileSize*2, tileSize, tileSize), "0110");
      tiles[15].addTileConfig(tileset.get(tileSize*4, tileSize*2, tileSize, tileSize), "1001");
      atLeastOneTerrain = true;
    }
  }
  if (keyCode==TAB) {
    saveFrame(dataPath("results/"+nf(nbSaved++, 4)+".png"));
  }
}

void modifyTerrains() {
  if (useMouse) {
    if (mouseX>=0&&mouseX<width&&mouseY>=0&&mouseY<height) {
      int tX = floor((float)(mouseX+(float)tileSize/2)/tileSize);
      int tY = floor((float)(mouseY+(float)tileSize/2)/tileSize);
      if (mouseLeft) terrains[tX][tY] = true;
      if (mouseRight) terrains[tX][tY] = false;
    }
  }
  if (atLeastOneTerrain) {
    if (frameCount%100==1) {
      for (int x=0; x<terrains.length; x++) {
        for (int y=0; y<terrains[x].length; y++) {
          terrains[x][y] = (dist(x, y, terrains.length/3, terrains[x].length/3)<random(2, 5));
        }
      }
      for (int x=0; x<terrains.length-1; x++) {
        for (int y=0; y<terrains[x].length-1; y++) {
          String config = "";
          config += terrains[x][y]?"1":"0";
          config += terrains[x+1][y]?"1":"0";
          config += terrains[x][y+1]?"1":"0";
          config += terrains[x+1][y+1]?"1":"0";
          for (int i=0; i<tiles.length; i++) if (tiles[i].config.equals(config)) tilesId[x][y] = i;
        }
      }
      chooseAlts();
    }
  }
}

void chooseAlts() {
  /*
  int nbFilled = 0;
   for (int x=0; x<terrains.length; x++) {
   for (int y=0; y<terrains[x].length; y++) {
   if (terrains[x][y]) nbFilled++;
   }
   }
   */
  int offset = 0;//floor((float)nbFilled/10);
  int[] nbTTFound = new int[16];
  for (int x=0; x<terrains.length; x++) {
    for (int y=0; y<terrains[x].length; y++) {      
      alts[x][y] = offset;
      alts[x][y] += nbTTFound[tilesId[x][y]];
      nbTTFound[tilesId[x][y]]++;
      alts[x][y] = floor(random(100000));// < total random mode
      alts[x][y] = alts[x][y]%tiles[tilesId[x][y]].pics.size();
      ;
    }
  }
}