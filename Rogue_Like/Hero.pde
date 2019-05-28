class Hero {

  PVector position, direction, velocity;
  float speed;
  int size;

  Hero(PVector start) {
    position = start;
    speed = 5;
    size = 50;
  }


  void update() {
    move();
    display();
  }

  void display() {
    fill(0, 255, 0);
    ellipse(position.x, position.y, size, size);
  }

  void move() {
    velocity = new PVector();
    if (pressed[leftKey])
      velocity.add(-speed, 0);
    if (pressed[rightKey])
      velocity.add(speed, 0);
    if (pressed[upKey])
      velocity.add(0, -speed);
    if (pressed[downKey])
      velocity.add(0, speed);
    position.add(velocity);
  }
}
