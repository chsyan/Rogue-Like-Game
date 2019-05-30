class Bullet extends GameObject {

  boolean isGood;

  Bullet(PVector position, PVector direction, float speed, boolean isGood) {
    this.position = position;
    this.direction = direction;
    this.velocity = direction.mult(speed);
    this.isGood = isGood;
    println("Bullet made");

    size = 5;

    hp = 1;
  }

  void display() {
    fill(255, 0, 0);
    ellipse(position.x, position.y, size, size);
  }

  void update() {
    position.add(velocity.copy());
    checkCollisions();
  }


  void checkCollisions() {
    for (GameObject w : gameObjects) {
      if (w instanceof Wall && ((Wall) w).state == ((Wall) w).WALL) {
        if (circleRect(position, size, w.position, w.size, w.size)) {
          hp = 0;
        }
      }
    }
  }
}
