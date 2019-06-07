abstract class GameObject {

  PVector position, direction, velocity;
  float hp, size, speed;

  GameObject() {
  }

  GameObject(PVector position) {
    this.position = position;
    position.add(new PVector(mapScl/2, mapScl/2));
  }

  void display() {
  }

  void update() {
  }

  boolean isDead() {
    return hp <= 0;
  }
}
