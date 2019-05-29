class Hero extends GameObject {

  PVector position, direction, velocity, targetVelocity;
  float speed;
  float size;
  float smoothing;
  float viewRadius;

  float ix;
  float iy;
  boolean firstInt;

  PVector camOff;

  Hero(PVector start) {
    position = start.copy();
    position.add(new PVector(mapScl/2, mapScl/2));

    velocity = new PVector();
    direction = new PVector();
    targetVelocity = new PVector();
    camOff = new PVector();

    speed = 4;
    size = mapScl * 0.5;
    smoothing = 0.3;
    hp = 100;

    viewRadius = 5 * mapScl;
  }

  void display() {
    pushMatrix();
    translate(position.x, position.y);
    // Sights
    stroke(0, 255, 0);
    line(0, 0, ix - position.x, iy - position.y);

    stroke(255, 0, 0);
    line(0, 0, direction.x - width/2, direction.y - height/2);

    // Player
    stroke(0);
    fill(0, 255, 0);
    ellipse(0, 0, size, size);
    popMatrix();
  }

  void update() {
    receiveInput();
    move();
    updateSights();
  }

  void updateSights() {
    camOff = camera.target.copy().sub(camera.position.copy());
    direction.x = mouseX + camOff.x;
    direction.y = mouseY + camOff.y;

    float x1 = direction.x -width/2 + position.x;
    float y1 = direction.y -height/2 + position.y;


    firstInt = true;
    for (GameObject o : gameObjects) 
      if (o instanceof Wall &&((Wall) o).state != 0 && dist(position.x, position.y, o.position.x, o.position.y) <= viewRadius)
        if (lineRect(x1, y1, position.x, position.y, o.position.x + camOff.x, o.position.y + camOff.y, o.size, o.size)) {
        }
  }

  void receiveInput() {
    targetVelocity = new PVector();
    if (pressed[leftKey])
      targetVelocity.add(-speed, 0);
    if (pressed[rightKey])
      targetVelocity.add(speed, 0);
    if (pressed[upKey])
      targetVelocity.add(0, -speed);
    if (pressed[downKey])
      targetVelocity.add(0, speed);
  }

  void move() {
    velocity.lerp(targetVelocity, smoothing);
    if (!checkWallCollision(new PVector(velocity.x, 0))) 
      position.x += velocity.x;
    else velocity.x = 0;
    if (!checkWallCollision(new PVector(0, velocity.y))) 
      position.y += velocity.y;
    else velocity.y = 0;
  }

  boolean checkWallCollision(PVector v) {
    for (GameObject o : gameObjects) 
      if (o instanceof Wall &&((Wall) o).state == 1)
        if (circleRect(position.copy().add(v), size * 0.5, o.position.copy(), o.size, o.size)) 
          return true;
    return false;
  }

  // LINE/RECTANGLE
  boolean lineRect(float x1, float y1, float x2, float y2, float rx, float ry, float rw, float rh) {

    // check if the line has hit any of the rectangle's sides
    // uses the Line/Line function below
    boolean left =   lineLine(x1, y1, x2, y2, rx, ry, rx, ry+rh);
    if (left) return true;
    boolean right =  lineLine(x1, y1, x2, y2, rx+rw, ry, rx+rw, ry+rh);
    if (right) return true;
    boolean top =    lineLine(x1, y1, x2, y2, rx, ry, rx+rw, ry);
    if (top) return true;
    boolean bottom = lineLine(x1, y1, x2, y2, rx, ry+rh, rx+rw, ry+rh);
    if (bottom) return true;

    // if ANY of the above are true, the line
    // has hit the rectangle
    if (left || right || top || bottom) {
      // println("hi");
      return true;
    }
    return false;
  }


  // LINE/LINE
  boolean lineLine(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
    // calculate the direction of the lines
    float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
    float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

    // if uA and uB are between 0-1, lines are colliding
    if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {

      // optionally, draw a circle where the lines meet
      float intersectionX = x1 + (uA * (x2-x1));
      float intersectionY = y1 + (uA * (y2-y1));
      println(intersectionX + ", " + intersectionY);
      
      fill(255, 0, 0);
      noStroke();
      ellipse(intersectionX + camOff.x, intersectionY + camOff.y, 10, 10);
      
      if (firstInt) {
        fill(255, 0, 0);
        noStroke();
        ellipse(intersectionX + camOff.x, intersectionY + camOff.y, 10, 10);
        ix = intersectionX + camOff.x;
        iy = intersectionY + camOff.y;
        firstInt = false;
      }

      return true;
    }
    return false;
  }
}
