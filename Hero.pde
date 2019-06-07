class Hero extends GameObject {

  PVector position, direction, velocity, targetVelocity;
  float smoothing;
  float viewRadius;

  PVector sightInt;

  float ix;
  float iy;

  float SPEED, SPRINT;
  float sprintMeter;
  float SPRINT_METER;
  float sprintTimer;
  float SPRINT_TIMER;
  boolean trySprint;


  PVector camOff;
  float shield;


  Gun gun;

  Hero(PVector start) {
    sightInt = new PVector();

    position = start.copy();
    position.add(new PVector(mapScl/2, mapScl/2));

    velocity = new PVector();
    direction = new PVector();
    targetVelocity = new PVector();
    camOff = new PVector();

    speed = 4;
    SPEED = 4;
    SPRINT = 8;
    SPRINT_METER = 100;
    sprintMeter = SPRINT_METER;
    SPRINT_TIMER = 120;
    sprintTimer = SPRINT_TIMER;

    size = mapScl * 0.4;
    smoothing = 0.3;

    hp = 100;
    shield = 100;

    viewRadius = 5 * mapScl;

    gun = new Gun(20);
  }

  void display() {
    pushMatrix();
    translate(position.x, position.y);

    stroke(0);
    fill(0, 255, 0);
    ellipse(0, 0, size, size);

    popMatrix();
  }

  void update() {
    receiveInput();
    move();
    updateSights();
    gun.update();
  }

  void updateSights() {
    direction.x = mouseX;
    direction.y = mouseY;
    direction = toAbsoluteCoords(direction);
    float x1 = direction.x;
    float y1 = direction.y;

    sightInt = null;
    for (GameObject o : gameObjects) 
      if (o instanceof Wall &&((Wall) o).state != 0 && dist(position.x, position.y, o.position.x, o.position.y) <= viewRadius * 20)
        if (lineRect(position.copy().x, position.copy().y, x1, y1, o.position.x + camOff.x, o.position.y + camOff.y, o.size, o.size)) {
          // do nothing, I'm bad and don't want to remake the intersect functions
        }

    stroke(0, 255, 0);
    if (sightInt != null)
      line(position.x, position.y, sightInt.x, sightInt.y);
    else line (position.x, position.y, direction.x, direction.y);
  }

  void receiveInput() {
    speed = SPEED;
    trySprint = false;
    if (pressed[sprintKey] && sprintMeter > 0) {
      speed = SPRINT;
      trySprint = true;
      sprintTimer = 0;
      sprintMeter--;
    } else if (!pressed[sprintKey]) {
      sprintTimer++;
      if (sprintTimer>=SPRINT_TIMER && sprintMeter < SPRINT_METER)
        sprintMeter++;
    }

    targetVelocity = new PVector();
    if (pressed[leftKey])
      targetVelocity.add(-speed, 0); 
    if (pressed[rightKey])
      targetVelocity.add(speed, 0);
    if (pressed[upKey])
      targetVelocity.add(0, -speed);
    if (pressed[downKey])
      targetVelocity.add(0, speed);
    // if (pressed[shootKey]) {
    if (mousePressed) {
      direction.x = mouseX;
      direction.y = mouseY;
      direction = toAbsoluteCoords(direction);
      direction.sub(position.copy());
      direction.setMag(1);
      gun.shoot(position.copy(), direction.copy(), 20, true, 1);
    }

    if (targetVelocity.equals(new PVector(0, 0)) && trySprint) {
      sprintMeter++;
    }
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

  void takeDamage(float damage) {
    float overflow = shield - damage;
    shield -= damage;
    if (shield < 0) shield = 0;
    if (overflow < 0) hp += overflow;
  }



  // Imported funcs









  // LINE/RECTANGLE
  boolean lineRect(float x1, float y1, float x2, float y2, float rx, float ry, float rw, float rh) {

    // check if the line has hit any of the rectangle's sides
    // uses the Line/Line function below
    boolean left =   lineLine(x1, y1, x2, y2, rx, ry, rx, ry+rh);
    boolean right =  lineLine(x1, y1, x2, y2, rx+rw, ry, rx+rw, ry+rh);
    boolean top =    lineLine(x1, y1, x2, y2, rx, ry, rx+rw, ry);
    boolean bottom = lineLine(x1, y1, x2, y2, rx, ry+rh, rx+rw, ry+rh);

    // if ANY of the above are true, the line
    // has hit the rectangle
    if (left || right || top || bottom) {
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


      PVector intersection = new PVector(intersectionX, intersectionY);

      if (sightInt == null) {
        sightInt = intersection;
      } else {
        if (dist(position.x, position.y, intersection.x, intersection.y) < dist(position.x, position.y, sightInt.x, sightInt.y)) {
          sightInt = intersection.copy();
        }
      }

      return true;
    }
    return false;
  }
}
