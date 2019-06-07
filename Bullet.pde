class Bullet extends GameObject {

  boolean isGood;
  float damage;

  Bullet(PVector position, PVector direction, float speed, boolean isGood, float damage) {
    this.position = position;
    this.direction = direction;
    this.velocity = direction.mult(speed);
    this.isGood = isGood;
    this.damage = damage;

    size = mapScl/5;

    hp = 1;
  }

  void display() {
    noStroke();
    fill(255, 0, 0);
    ellipse(position.x, position.y, size, size);
  }

  void update() {
    checkCollisions(position.copy().add(velocity.copy()));
    //checkCollisions(position.copy());
    position.add(velocity.copy());
  }


  void checkCollisions(PVector position) {
    if (dist(position.x, position.y, hero.position.x, hero.position.y) > width/2 + 300)
      gameObjects.remove(this);


    // Walls
    for (int i = gameObjects.size()-1; i>=0; i--) {
      GameObject w = gameObjects.get(i);
      if (w instanceof Wall && ((Wall) w).state == ((Wall) w).WALL) {
        if (circleRect(position, size, w.position, w.size, w.size)) {
          gameObjects.remove(this);
        }
      }
    }

    if (isGood) {
      for (GameObject o : gameObjects) {
        if (o instanceof Enemy) {
          if (dist(o.position.x, o.position.y, position.x, position.y) <= (o.size /2) + (size /2)) {
            o.hp -= damage;
            hp = 0;
          }
        }
      }
    } else {
    }
  }
}
