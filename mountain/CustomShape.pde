
class CustomShape {

  Body body;

  ArrayList<CustomShape> parent;

  PImage im;
  PVector imgAnchor;
  float scale;
  int shapeType;
  // 0 = circle
  // 1 = polygon

  float life = 0;

  // for a circle
  CustomShape(float x, float y, ArrayList<CustomShape> parent, float a, BodyType type, float radius, PImage im, PVector imgAnchor, float scale) {

    setParameters(x, y, parent, a, type, im, imgAnchor, scale);

    shapeType = 0;

    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(radius*scale);

    body.createFixture(cs, 1.0);
  }

  // for a polygon
  CustomShape(float x, float y, ArrayList<CustomShape> parent, float a, BodyType type, ArrayList<PVector> vertices, PImage im, PVector imgAnchor, float scale) {

    setParameters(x, y, parent, a, type, im, imgAnchor, scale);

    shapeType = 1;

    // convert PVector array to PolygonShape
    Vec2[] vertices2 = new Vec2[vertices.size()];
    for (int i=0; i<vertices.size(); i++) vertices2[i] = box2d.vectorPixelsToWorld(new Vec2(vertices.get(i).y*scale, -vertices.get(i).x*scale));
    PolygonShape sd = new PolygonShape();
    sd.set(vertices2, vertices2.length);

    body.createFixture(sd, 1.0);
  }

  void setParameters(float x, float y, ArrayList<CustomShape> parent, float a, BodyType type, PImage im, PVector imgAnchor, float scale) {

    this.parent=parent;
    this.scale=scale;

    this.im = im;
    this.imgAnchor = imgAnchor;

    // set the body
    BodyDef bd = new BodyDef();
    bd.type = type;
    bd.position.set(box2d.coordPixelsToWorld(x, y));
    bd.angle = a-HALF_PI;
    body = box2d.createBody(bd);
  }

  void update() {
    if (!shapeIsVisible()) {// check if it's outside the screen
      box2d.destroyBody(body);// remove the body
      if (parent!=null) parent.remove(this);// then remove it from the list
    }
    if (dist(0,0,body.getLinearVelocity().x,body.getLinearVelocity().y) < 0.01) body.setType(BodyType.STATIC);
    life+=1;
  }

  boolean shapeIsVisible() {
    Vec2 pos = box2d.getBodyPixelCoord(body);
    if (shapeType==0) {
      CircleShape cs = (CircleShape) body.getFixtureList().getShape();
      float radius = box2d.scalarWorldToPixels(cs.m_radius);
      return !(pos.y-radius*scale >= height || pos.y+radius*scale < 0 || pos.x-radius*scale >= width || pos.x+radius*scale < 0);
    }
    if (shapeType==1) {
      PolygonShape ps = (PolygonShape) body.getFixtureList().getShape();
      for (int i = 0; i < ps.getVertexCount(); i++) {
        Vec2 v = box2d.vectorWorldToPixels(ps.getVertex(i));
        if (!(pos.y+v.y >= height || pos.y+v.y < 0 || pos.x+v.x >= width || pos.x+v.x < 0)) return true;
      }
      return false;
    }
    return false;
  }

  void display() {

    // retrieve values
    Vec2 pos = box2d.getBodyPixelCoord(body);
    float a = body.getAngle();
    Fixture f = body.getFixtureList();

    // draw
    rectMode(CENTER);
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(-a);
    fill(175);
    // stroke(0);
    noStroke();
    if (im==null) {
      if (shapeType == 0) {
        CircleShape cs = (CircleShape) f.getShape();
        float radius = box2d.scalarWorldToPixels(cs.getRadius());
        ellipse(0, 0, radius*2, radius*2);
      }
      if (shapeType == 1) {
        beginShape();
        strokeWeight(1);
        PolygonShape ps = (PolygonShape) f.getShape();
        for (int i = 0; i < ps.getVertexCount(); i++) {
          Vec2 v = box2d.vectorWorldToPixels(ps.getVertex(i));
          vertex(v.x, v.y);
        }
        endShape(CLOSE);
      }
    }
    if (im!=null) {
      rotate(-HALF_PI);
      scale(scale);
      translate(-imgAnchor.x, -imgAnchor.y);
      image(im, 0, 0);
    }
    popMatrix();
  }

  void jump() {
    body.applyLinearImpulse(new Vec2(0, -20), box2d.getBodyPixelCoord(body), true);
  }
}