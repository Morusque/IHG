
int finalNumberOfPoints = 500;

Shape shapeOrig = new Shape(finalNumberOfPoints);
Shape shapeInterp = new Shape(finalNumberOfPoints);
Shape shapeTarget = new Shape(finalNumberOfPoints);

color insideC = color(0xFF, 0xFF, 0);
color insideCTarget = color(0xFF, 0xFF, 0);

float autoFrequency = 1800;
float lastTriggerMs = 0;

float tweeningPhase = 0;
float tweeningLength = 500;

boolean dark = false;

void setup() {
  // size(1920, 1080);
  fullScreen();
  for (int i=0; i<shapeOrig.nbPointsInShape; i++) {
    shapeOrig.distances[i] = shapeTarget.distances[i]=0;
    shapeOrig.angles[i] = shapeTarget.angles[i]=(float)i*TWO_PI/shapeOrig.nbPointsInShape;
  }
  shapeInterp = shapeOrig.copy();
  generate();
}

void draw() {

  // update
  if (millis()-lastTriggerMs>autoFrequency) {
    generate();
  }
  for (int i=0; i<shapeInterp.nbPointsInShape; i++) {
    shapeInterp.distances[i] = lerp(shapeOrig.distances[i], shapeTarget.distances[i], elasticTween(tweeningPhase));
    shapeInterp.angles[i] = lerpAngle(shapeOrig.angles[i], shapeTarget.angles[i], elasticTween(tweeningPhase));
  }
  insideC = lerpColor(insideC, insideCTarget, 0.2);
  tweeningPhase=(millis()-lastTriggerMs)/tweeningLength;

  // draw
  background(0,0,0xFF);
  fill(insideC);
  stroke(0);
  strokeWeight(5);
  noStroke();
  beginShape();
  for (int i=0; i<shapeInterp.distances.length; i++) vertex(width/2+cos(shapeInterp.angles[i])*shapeInterp.distances[i], height/2+sin(shapeInterp.angles[i])*shapeInterp.distances[i]);
  endShape(CLOSE);
   
   if (dark) background(0);
   
  /*
  stroke(0);
   strokeWeight(2);
   for (int i=0; i<shapeInterp.distances.length; i++) point(width/2+cos(shapeInterp.angles[i])*shapeInterp.distances[i], height/2+sin(shapeInterp.angles[i])*shapeInterp.distances[i]);
   */
}

void generate() {

  lastTriggerMs = millis();
  shapeOrig = shapeInterp.copy();
  tweeningPhase = 0;

  float minHeight = random(100, 300);
  float maxHeight = random(400, 500);
  int minCycles = 1;
  int maxCycles = 20;
  int cycles = int(random(minCycles, maxCycles));
  float power = random(0.5, 2.5);
  int type = floor(random(6));// rect, tri, even, spikes, buildings, boules
  shapeTarget = new Shape(finalNumberOfPoints);
  if (type == 2) shapeTarget = new Shape(floor(random(3, 8)));
  if (type == 3) shapeTarget = new Shape(floor(random(4, 16))*2);
  if (type==0 || type==1 || type==2 || type==3) {
    for (int i = 0; i < shapeTarget.nbPointsInShape; i++) {
      shapeTarget.angles[i] = (float)i*TWO_PI/shapeTarget.distances.length;
      if (type==3) shapeTarget.angles[i] += random(-0.1, 0.1);
      float phase = (float)i / shapeTarget.distances.length * cycles * TWO_PI;
      float baseHeight = minHeight;
      if (type==0) baseHeight = map(rectangularWave(phase), -1, 1, minHeight, maxHeight);
      if (type==1) baseHeight = map(pow(map(triangleWave(phase), -1, 1, 0, 1), power), 0, 1, minHeight, maxHeight);
      if (type==2) shapeTarget.distances[i] = lerp(minHeight, maxHeight, 0.8);
      if (type==3) baseHeight = minHeight + (i%2==0?0:random(maxHeight-minHeight));
      shapeTarget.distances[i] = baseHeight;
    }
  }
  if (type==4) {
    ArrayList<Float> angles = new ArrayList<Float>();
    ArrayList<Float> distances = new ArrayList<Float>();
    angles.add(0.0);
    distances.add((minHeight+maxHeight)/2);
    int lastDirection = 1;
    while (angles.get(angles.size()-1)<TWO_PI) {
      float newDistance = distances.get(distances.size()-1);
      boolean vertical = false;
      if (newDistance<=minHeight && lastDirection==0) {
        newDistance+=random(30, 100);
        vertical = true;
        lastDirection = 1;
      }
      if (newDistance>maxHeight && lastDirection==0) {
        newDistance-=random(30, 100);
        vertical = true;
        lastDirection = -1;
      }
      if (random(1)<0.2 && lastDirection==0) {
        newDistance+=random(30, 100);
        vertical = true;
        lastDirection = 1;
      }
      if (random(1)<0.2 && lastDirection==0) {
        newDistance-=random(30, 100);
        vertical = true;
        lastDirection = -1;
      }
      if (angles.get(angles.size()-1)>TWO_PI-1.0  && lastDirection==0) {
        if ((newDistance-(minHeight+maxHeight)/2)>50) {
          newDistance-=constrain(newDistance-(minHeight+maxHeight)/2, 0, 50);
          vertical = true;
          lastDirection = -1;
        }
        if ((newDistance-(minHeight+maxHeight)/2)<50) {
          newDistance+=constrain(newDistance-(minHeight+maxHeight)/2, 0, 50);
          vertical = true;
          lastDirection = 1;
        }
      }
      distances.add(newDistance);
      if (!vertical) lastDirection = 0;
      if (vertical) angles.add(angles.get(angles.size()-1));
      else angles.add(angles.get(angles.size()-1) + constrain(map(distances.get(distances.size()-1), minHeight, maxHeight, 0.1, 0.05), 0.05, 0.1));
      angles.set(angles.size()-1, constrain(angles.get(angles.size()-1), 0, TWO_PI));
      if (TWO_PI-angles.get(angles.size()-1)<0.05) angles.set(angles.size()-1, TWO_PI);
    }
    shapeTarget = new Shape(angles.size());
    for (int i = 0; i < shapeTarget.nbPointsInShape; i++) {
      shapeTarget.angles[i] = angles.get(i);
      shapeTarget.distances[i] = distances.get(i);
    }
  }
  if (type == 5) {
    int nbBalls = floor(random(1,15));
    PVector[] pos = new PVector[nbBalls];
    float[] radii = new float[nbBalls];
    for (int i = 0; i < nbBalls; i++) {
      pos[i] = new PVector(
        width / 2 + cos(random(TWO_PI)) * random(minHeight, maxHeight),
        height / 2 + sin(random(TWO_PI)) * random(minHeight, maxHeight));
      float distance = dist(pos[i].x, pos[i].y, width / 2, height / 2);
      float screenMargin = min(min(pos[i].x, pos[i].y), min(width-pos[i].x, height-pos[i].y));
      screenMargin /=2;
      radii[i] = min(random(distance - minHeight/2, maxHeight - distance), screenMargin);
    }
    shapeTarget = new Shape(finalNumberOfPoints);
    for (int i = 0; i < shapeTarget.nbPointsInShape; i++) {
      shapeTarget.angles[i] = (float) i * TWO_PI / shapeTarget.distances.length;
      float angle = shapeTarget.angles[i];
      float distance = minHeight;

      // Define the ray direction
      PVector rayDir = new PVector(cos(angle), sin(angle));

      // Check each ball for intersection
      if (type==5) {
        for (int j = 0; j < nbBalls; j++) {
          PVector toBall = PVector.sub(pos[j], new PVector(width / 2, height / 2));
          float projection = toBall.dot(rayDir);

          if (projection > 0) { // Ray pointing towards the ball
            // Compute closest approach
            PVector closestPoint = PVector.add(
              new PVector(width / 2, height / 2),
              PVector.mult(rayDir, projection)
              );
            float distToCenter = PVector.dist(closestPoint, pos[j]);

            if (distToCenter <= radii[j]) {
              // Compute intersection distance
              float offset = sqrt(radii[j] * radii[j] - distToCenter * distToCenter);
              float intersectionDist = projection + offset;

              // Update the distance if this is the farthest intersection
              distance = max(distance, intersectionDist);
            }
          }
        }
      }
      shapeTarget.distances[i] = distance;
    }
  }

  shapeTarget.resample(finalNumberOfPoints);

  insideCTarget = color(map(pow(random(1), 2), 0, 1, 0xFF, 0xA0), map(pow(random(1), 2), 0, 1, 0xFF, 0xA0), map(pow(random(1), 2), 0, 1, 0xA0, 0));
  
}

void keyPressed() {
  generate();
  if (keyCode==BACKSPACE) dark^=true;
}

float triangleWave(float phase) {
  phase = phase % TWO_PI;
  if (phase < PI) return 2 * phase / PI - 1;
  else return 3 - 2 * phase / PI;
}

float rectangularWave(float phase) {
  phase = phase % TWO_PI;
  return (phase < PI) ? 1 : -1;
}

class Shape {
  int nbPointsInShape;
  float[] distances;
  float[] angles;
  Shape(int nbPointsInShape) {
    this.nbPointsInShape = nbPointsInShape;
    distances = new float[nbPointsInShape];
    angles = new float[nbPointsInShape];
  }

  Shape copy() {
    Shape newShape = new Shape(nbPointsInShape);
    newShape.distances = new float[nbPointsInShape];
    newShape.angles = new float[nbPointsInShape];
    for (int i=0; i<nbPointsInShape; i++) {
      newShape.distances[i]=this.distances[i];
      newShape.angles[i]=this.angles[i];
    }
    return newShape;
  }

  void resample(int newNbPointsInShape) {
    ArrayList<PVector> currentPoints = new ArrayList<PVector>();
    float totalLength = 0;

    // Convert current shape to Cartesian coordinates and calculate total length
    for (int i = 0; i < nbPointsInShape; i++) {
      PVector point = new PVector(cos(angles[i]) * distances[i], sin(angles[i]) * distances[i]);
      currentPoints.add(point);
      int nextIndex = (i + 1) % nbPointsInShape;
      PVector nextPoint = new PVector(cos(angles[nextIndex]) * distances[nextIndex], sin(angles[nextIndex]) * distances[nextIndex]);
      totalLength += PVector.dist(point, nextPoint);
    }

    float segmentLength = totalLength / newNbPointsInShape;
    float[] newDistances = new float[newNbPointsInShape];
    float[] newAngles = new float[newNbPointsInShape];

    float currentLength = 0;
    int currentIndex = 0;
    for (int i = 0; i < newNbPointsInShape; i++) {
      float targetLength = i * segmentLength;

      while (currentLength < targetLength && currentIndex < nbPointsInShape) {
        int nextIndex = (currentIndex + 1) % nbPointsInShape;
        currentLength += PVector.dist(currentPoints.get(currentIndex), currentPoints.get(nextIndex));
        currentIndex++;
      }

      int prevIndex = (currentIndex - 1 + nbPointsInShape) % nbPointsInShape;
      PVector prevPoint = currentPoints.get(prevIndex);
      PVector currentPoint = currentPoints.get(currentIndex % nbPointsInShape);

      float t = (targetLength - (currentLength - PVector.dist(prevPoint, currentPoint))) / PVector.dist(prevPoint, currentPoint);
      PVector newPoint = PVector.lerp(prevPoint, currentPoint, t);

      newDistances[i] = newPoint.mag();
      newAngles[i] = atan2(newPoint.y, newPoint.x);
      if (newAngles[i] < 0) newAngles[i] += TWO_PI;
    }

    // Update shape with new points
    nbPointsInShape = newNbPointsInShape;
    distances = newDistances;
    angles = newAngles;
  }

  float findIntersection(float rayAngle) {
    float minDist = Float.MAX_VALUE;
    float intersectionDist = 0;
    boolean found = false;
    for (int i = 0; i < nbPointsInShape; i++) {
      int nextI = (i + 1) % nbPointsInShape;
      PVector p1 = new PVector(cos(angles[i]) * distances[i], sin(angles[i]) * distances[i]);
      PVector p2 = new PVector(cos(angles[nextI]) * distances[nextI], sin(angles[nextI]) * distances[nextI]);
      PVector rayDir = new PVector(cos(rayAngle), sin(rayAngle));
      PVector rayOrigin = new PVector(0, 0);
      PVector intersection = lineIntersection(rayOrigin, rayDir, p1, p2);
      if (intersection != null) {
        found = true;
        float dist = intersection.mag();
        if (dist < minDist) {
          minDist = dist;
          intersectionDist = dist;
        }
      }
    }
    if (!found) return -1;
    return intersectionDist;
  }

  PVector lineIntersection(PVector rayOrigin, PVector rayDir, PVector p1, PVector p2) {
    PVector v1 = PVector.sub(rayOrigin, p1);
    PVector v2 = PVector.sub(p2, p1);
    PVector v3 = new PVector(-rayDir.y, rayDir.x);
    float dot = v2.dot(v3);
    if (abs(dot) < 0.000001) return null;
    float t1 = v2.cross(v1).z / dot;
    float t2 = v1.dot(v3) / dot;
    if (t1 >= 0.0 && (t2 >= 0.0 && t2 <= 1.0)) return PVector.add(rayOrigin, PVector.mult(rayDir, t1));
    return null;
  }
}

public float vrMax(float a, float b, float m) {
  float d1=b-a;
  if (d1>m/2) {
    d1=d1-m;
  }
  if (d1<-m/2) {
    d1=d1+m;
  }
  return d1;
}

float lerpAngle(float start, float end, float amount) {
  float difference = end - start;
  while (difference < -PI) difference += TWO_PI;
  while (difference > PI) difference -= TWO_PI;
  return start + difference * amount;
}

float elasticTween(float t) {
  if (t <= 0) return 0;
  if (t >= 1) return 1;
  float k = 5.0;
  float o = 3.5;
  float m = 1.5;
  float curve = ((t-0.5)*m)*k*pow(1-(abs(0.5-t)*2), o)+t;
  return curve;
}
