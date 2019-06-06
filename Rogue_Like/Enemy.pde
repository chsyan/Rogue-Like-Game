class Enemy extends GameObject {
  Enemy(PVector position) {
    super(position);
    size = mapScl * 0.8;
    hp = 1;
  }

  void display() {
    stroke(0, 0, 255);
    fill(0, 0, 255);
    ellipse(position.x, position.y, size, size);
  }

  void update() {
  }
}

class Chaser extends Enemy {
  Chaser(PVector position) {
    super (position); 

    speed = 2;
  }

  void update() {
  }
}
