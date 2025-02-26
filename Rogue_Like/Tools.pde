boolean circleRect(PVector c, float radius, PVector r, float rw, float rh) {

  // temporary variables to set edges for testing
  float testX = c.x;
  float testY = c.y;

  // which edge is closest?
  if (c.x < r.x)         testX = r.x;      // test left edge
  else if (c.x > r.x+rw) testX = r.x+rw;   // right edge
  if (c.y < r.y)         testY = r.y;      // top edge
  else if (c.y > r.y+rh) testY = r.y+rh;   // bottom edge

  // get distance from closest edges
  float distX = c.x-testX;
  float distY = c.y-testY;
  float distance = sqrt( (distX*distX) + (distY*distY) );

  // if the distance is less than the radius, collision!
  return distance <= radius;
}

boolean rectRect(float r1x, float r1y, float r1w, float r1h, float r2x, float r2y, float r2w, float r2h) {

  // are the sides of one rectangle touching the other?

  if (r1x + r1w >= r2x &&    // r1 right edge past r2 left
    r1x <= r2x + r2w &&    // r1 left edge past r2 right
    r1y + r1h >= r2y &&    // r1 top edge past r2 bottom
    r1y <= r2y + r2h) {    // r1 bottom edge past r2 top
    return true;
  }
  return false;
}

PVector toAbsoluteCoords(PVector v) {
  v.sub(camera.position.copy());
  return v;
}

PVector toRelativeCoords(PVector v) {
  v.add(camera.position.copy());
  return v;
}
