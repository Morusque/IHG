
ArrayList<PImage> ballsIm = new ArrayList<PImage>();
ArrayList<Ball> balls = new ArrayList<Ball>();

int interBallTimer = 0;

boolean dark = false;

ArrayList<PImage> spritesIm = new ArrayList<PImage>();
ArrayList<Sprite> sprites = new ArrayList<Sprite>();
float lifeEnd = 3.0;// duration of the sprites in seconds
float fadeTime = 1.0;// duration of the fade in and out in seconds

void setup() {
  fullScreen(P2D);
  frameRate(60);
  thread("loadSprites");
  String[] ballImFiles = getAllFilesFrom(dataPath("balls"));
  for (String f : ballImFiles) {
    PImage im = loadImage(f);
    if (im!=null) ballsIm.add(im);
  }
  restart();
}

void draw() {
  // update
  // move balls
  for (Ball b : balls) {
    b.move();
  }
  // remove balls that were not visible for a long time
  for (int i = balls.size()-1; i >= 0; i--) {
    Ball b = balls.get(i);
    if (b.lifeTime>1000) {
      if (b.position.y-b.radius > height && b.position.y<0) {
        balls.remove(i);
      }
    }
  }
  // remove balls that are way off the top
  for (int i = balls.size()-1; i >= 0; i--) {
    Ball b = balls.get(i);
    if (b.position.y-b.radius < -height) {
      balls.remove(i);
    }
  }
  // if there are less than n balls and enough time have ellapsed, add a new ball
  if (balls.size() < 100 && interBallTimer++ > 20) {
    Ball b = new Ball();
    if (b.valid) {
      balls.add(new Ball());
      interBallTimer=0;
    }
  }
  // update sprites
  for (int i=sprites.size()-1; i>=0; i--) {
    sprites.get(i).update();
  }

  // draw
  // background(255);
  for (Ball b : balls) {
    b.draw();
  }

  // Display sprites
  for (Sprite sprite : sprites) {
    sprite.draw();
  }

  if (dark) background(0);
}

class Ball {
  PVector position;
  PVector velocity;
  float radius;
  PImage im;
  boolean valid = true;
  float mass = 1.0;
  float lifeTime = 0;
  Ball() {
    velocity = new PVector(random(-5, 5), random(1, 20));
    im = ballsIm.get((int)random(ballsIm.size()));
    radius = (im.width+im.height)/4;
    position = new PVector(random(radius*2, width-radius*2), random(-radius*2, -height));
    if (random(1)<0.5) {
      position.y = height-position.y;
      velocity.y *= -1;
    }
    // revise position until it is not overlapping with other balls
    boolean overlapping = true;
    int attempts = 0;
    mass = random(1, 2)*radius/10.0;
    while (overlapping) {
      overlapping = false;
      for (Ball b : balls) {
        if (b != this) {
          float d = dist(position.x, position.y, b.position.x, b.position.y);
          if (d < radius + b.radius) {
            overlapping = true;
            position = new PVector(random(radius*2, width-radius*2), -radius);
            break;
          }
        }
      }
      attempts++;
      if (attempts > 2) {
        valid = false;
        break;
      }
    }
  }

  void move() {
    position.add(velocity);
    // make ball bounce on vertical walls
    if (position.x-radius < 0 || position.x+radius > width) {
      velocity.x *= -1;
    }
    // make ball bounce on other balls
    for (Ball b : balls) {
      if (b != this) {
        float d = dist(position.x, position.y, b.position.x, b.position.y);
        if (d < radius + b.radius) {
          PVector normal = PVector.sub(position, b.position);
          normal.normalize();
          float dot = PVector.dot(velocity, normal);
          PVector newVelocity = PVector.sub(velocity, PVector.mult(normal, 2*dot));
          velocity = newVelocity;
          // revise ball speed depending on colliding ball speed
          velocity.add(b.velocity.x*0.1*(b.mass/mass), b.velocity.y*0.1*(b.mass/mass));
          // revise the other ball speed depending on this ball speed
          b.velocity.add(velocity.x*0.1*(mass/b.mass), velocity.y*0.1*(mass/b.mass));
        }
      }
    }
    // push the ball until it is not overlapping with other balls
    for (Ball b : balls) {
      if (b != this) {
        float d = dist(position.x, position.y, b.position.x, b.position.y);
        if (d < radius + b.radius) {
          PVector normal = PVector.sub(position, b.position);
          normal.normalize();
          position.add(PVector.mult(normal, radius + b.radius - d));
        }
      }
    }
    lifeTime++;
  }

  void draw() {
    imageMode(CENTER);
    image(im, position.x, position.y, radius*2, radius*2);
  }
}

void keyPressed() {
  if (keyCode!=BACKSPACE) {
    if (dark) {
      dark=false;
      restart();
    }
  }
  if (keyCode==BACKSPACE) {
    dark^=true;
    if (!dark) {
      restart();
    }
  }
  if (key=='p') {
    // add a sprite somewhere
    synchronized(spritesIm) {
      sprites.add(new Sprite(spritesIm.get(floor(random(spritesIm.size())))));
    }
  }
  if (key=='+') {
    for (Ball b : balls) {
      b.velocity.mult(1.1);
    }
  }
  if (key=='-') {
    for (Ball b : balls) {
      b.velocity.mult(0.9);
    }
  }
  if (key=='u') {
    for (Ball b : balls) {
      b.radius*=0.9;
    }
  }
  if (key=='i') {
    for (Ball b : balls) {
      b.radius*=1.1;
    }
  }
}

void keyReleased() {
  for (int i=sprites.size()-1; i>=0; i--) {
    sprites.remove(i);
  }
}

void restart() {
  balls.clear();
  for (int i=0; i<100; i++) {
    Ball b = new Ball();
    if (b.valid) {
      balls.add(new Ball());
      interBallTimer=0;
    }
  }
  background(0xFF);
}

void loadSprites() {
  synchronized(spritesIm) {
    String[] spritesImFiles = getAllFilesFrom(dataPath("sprites"));
    for (int i=0; i<spritesImFiles.length; i++) {
      PImage im = loadImage(spritesImFiles[i]);
      if (im!=null) spritesIm.add(im);
    }
  }
}

class Sprite {
  PImage im;
  PVector pos;
  float lifeDuration = 0.0;
  float scale = 0.5;

  Sprite(PImage im) {
    this.im = im;
    // random position (not too close to the borders)
    pos = new PVector(random(300, width-300), random(300, height-300));
  }

  void update() {
    lifeDuration += 1.0/((float)frameRate);
    scale+=0.01;
  }

  void draw() {
    imageMode(CENTER);
    image(im, pos.x, pos.y, im.width*scale, im.height*scale);
  }
}
