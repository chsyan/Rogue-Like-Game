abstract class GameObject {

  PVector position, direction, velocity;
  int hp, size;

  GameObject() {
  }

  void display() {
  }

  void update() {
  }

  boolean isDead() {
    return hp <= 0;
  }
}
