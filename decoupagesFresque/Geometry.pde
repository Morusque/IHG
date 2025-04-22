
// intersection between a circle and a segment closest to lineStart, null if no intersection
PVector closestIntersection(PVector circle, float radius, PVector lineStart, PVector lineEnd) {
  PVector closestPoint = getClosestPointOnSegment(lineStart, lineEnd, circle);
  if (closestPoint==null) return null;
  else if (PVector.dist(closestPoint, circle)>radius) return null;
  ArrayList<PVector> intersections = findLineCircleIntersections(circle, radius, lineStart, lineEnd);
  if (intersections.size() == 1) return intersections.get(0);
  if (intersections.size() == 2) return (PVector.dist(intersections.get(0), lineStart) < PVector.dist(intersections.get(1), lineStart)?intersections.get(0):intersections.get(1));
  return null;
}

// all intersections between a line (infinitely long) and a circle
ArrayList<PVector> findLineCircleIntersections(PVector circle, float radius, PVector point1, PVector point2) {
  float dx, dy, A, B, C, det, t;
  dx = point2.x - point1.x;
  dy = point2.y - point1.y;
  A = sq(dx) + sq(dy);
  B = 2 * (dx * (point1.x - circle.x) + dy * (point1.y - circle.y));
  C = sq(point1.x - circle.x) + sq(point1.y - circle.y) - sq(radius);
  det = B * B - 4 * A * C;
  ArrayList<PVector> intersections = new ArrayList<PVector>();
  if ((A <= 0.0000001f) || (det < 0)) {// No real solutions.
  } else if (det == 0) {// One solution.
    t = -B / (2 * A);
    intersections.add(new PVector(point1.x + t * dx, point1.y + t * dy));
  } else {// Two solutions.
    t = (float)((-B + sqrt(det)) / (2 * A));
    intersections.add(new PVector(point1.x + t * dx, point1.y + t * dy));
    t = (float)((-B - sqrt(det)) / (2 * A));
    intersections.add(new PVector(point1.x + t * dx, point1.y + t * dy));
  }
  return intersections;
}

// intersection bewteen two segments (null if no intersection)
PVector lineSegmentIntersection (PVector p1A, PVector p1B, PVector p2A, PVector p2B) {
  PVector s1 = new PVector(p1B.x - p1A.x, p1B.y - p1A.y); 
  PVector s2 = new PVector(p2B.x - p2A.x, p2B.y - p2A.y); 
  float s = (-s1.y * (p1A.x - p2A.x) + s1.x * (p1A.y - p2A.y)) / (-s2.x * s1.y + s1.x * s2.y);
  float t = ( s2.x * (p1A.y - p2A.y) - s2.y * (p1A.x - p2A.x)) / (-s2.x * s1.y + s1.x * s2.y);
  if (s >= 0 && s <= 1 && t >= 0 && t <= 1) return new PVector (p1A.x + (t * s1.x), p1A.y + (t * s1.y));
  return null;
}

// point on the segment (s1, s2) closest to p
PVector getClosestPointOnSegment(PVector s1, PVector s2, PVector p) {
  double xDelta = s2.x - s1.x;
  double yDelta = s2.y - s1.y;
  if ((xDelta == 0) && (yDelta == 0)) return s1; // Segment start equals segment end
  double u = ((p.x - s1.x) * xDelta + (p.y - s1.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta);
  if (u < 0) return new PVector(s1.x, s1.y);
  else if (u > 1) return new PVector(s2.x, s2.y);
  return new PVector((float)(s1.x + u * xDelta), (float)(s1.y + u * yDelta));
}

// squared distance
float sqDist(PVector p1, PVector p2) {
  return sq(p1.x-p2.x)+sq(p1.y-p2.y);
}

// smallest point to ligne distance
float getSmallestDistanceToLine(PVector p, PVector a, PVector b) {
  PVector pa = PVector.sub(p,a);
  PVector ba = PVector.sub(b,a);
  float h = constrain(PVector.dot(pa,ba) / PVector.dot(ba,ba), 0., 1.);  
  return PVector.sub(pa,PVector.mult(ba,h)).mag();
}
