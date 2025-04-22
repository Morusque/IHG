
PImage im;

ArrayList<Node> nodes = new ArrayList<Node>();

float brThreshold = 0x80;

void setup() {
  size(500, 500);
  im = loadImage("image.png");
  placeNodes();
}

void draw() {
  image(im, 0, 0, width, height);
  for (Node n : nodes) n.draw();
}

class Node {
  PVector position;
  float radius=1;
  HashMap<Node, Float> distsTo = new HashMap<Node, Float>();
  ArrayList<Node> links = new ArrayList<Node>();
  Node(PVector position) {
    this.position=position;
  }
  void draw() {
    stroke(0xFF, 0, 0);
    noFill();
    // ellipse(position.x*width/im.width, position.y*height/im.height, radius*2*width/im.width, radius*2*height/im.height);
    for (Node n : links) line(position.x*width/im.width, position.y*width/im.width, n.position.x*width/im.width, n.position.y*width/im.width);
    stroke(0, 0x80, 0);
    line(position.x*width/im.width, position.y*width/im.width,position.x*width/im.width, position.y*width/im.width-20);
  }
  void expand() {
    int nbProbes = 10;
    boolean inside = true;
    while (inside) {
      radius++;
      for (int i=0; i<nbProbes; i++) {
        PVector thisProbe = new PVector(position.x+cos((float)i*TWO_PI/nbProbes)*radius, position.y+sin((float)i*TWO_PI/nbProbes)*radius);
        if (thisProbe.x<0||thisProbe.y<0||thisProbe.x>=im.width||thisProbe.y>=im.height) inside = false;
        else {
          if (brightness(im.get(floor(thisProbe.x), floor(thisProbe.y))) > brThreshold) inside = false;
        }
      }
    }
    radius--;
  }
  void computeDists() {
    for (Node n : nodes) {
      if (n!=this) {
        if (!distsTo.containsKey(n)) {
          float dist = PVector.dist(position, n.position);
          distsTo.put(n, dist);
          n.distsTo.put(this, dist);
        }
      }
    }
  }
  void computeLinks() {
    for (Node n : nodes) {
      if (n!=this && !links.contains(n)) {
        boolean accepted = true;
        for (Node n2 : nodes) {
          if (n2!=this && n2!=n) {
            if (distsTo.get(n2)<distsTo.get(n)) {
              PVector center = PVector.lerp(this.position, n.position, 0.5f);
              if (PVector.dist(n2.position, center)<distsTo.get(n2)/2) {
                accepted = false;
                break;
              }
            }
          }
        }
        if (accepted) {
          for (int i=0;i<distsTo.get(n);i++) {
            PVector thisPos = PVector.lerp(position,n.position,(float)i/distsTo.get(n));
            if (brightness(im.get(floor(thisPos.x),floor(thisPos.y)))>brThreshold) {
              accepted = false;
              break;
            }
          }
        }
        if (accepted) {
          links.add(n);
          n.links.add(this);
        }
      }
    }
  }
}

void placeNodes() {
  println("place nodes everywhere dark");
  float stepSize = 2;
  for (int x=0; x<im.width; x+=stepSize) {
    for (int y=0; y<im.height; y+=stepSize) {
      if (brightness(im.get(x, y)) < brThreshold) nodes.add(new Node(new PVector(x, y)));
    }
  }
  println("expand nodes");
  for (Node n : nodes) {
    n.expand();
    n.radius*=3;
  }
  println("clean nodes");
  ArrayList<Node> toClean = new ArrayList<Node>();
  for (Node n : nodes) toClean.add(n);
  nodes.clear();
  while (toClean.size()>0) {
    ArrayList<Node> toRemove = new ArrayList<Node>();
    Node greaterNode = null;
    for (Node n : toClean) {
      if (greaterNode==null) greaterNode = n;
      if (greaterNode.radius<=n.radius) greaterNode = n;
    }
    for (Node n : toClean) {
      if (n!=greaterNode&&greaterNode!=null) {
        if (PVector.dist(n.position, greaterNode.position)<greaterNode.radius) toRemove.add(n);
      }
    }
    for (Node n : toRemove) {
      toClean.remove(n);
    }
    nodes.add(greaterNode);
    toClean.remove(greaterNode);
  }
  println("compute distances");
  for (Node n : nodes) n.computeDists();
  println("compute links");
  for (Node n : nodes) n.computeLinks();
  println("done");
}
