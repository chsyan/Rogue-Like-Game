class Camera {
  PVector position, target;
  float camSmoothing;

  Camera(PVector position) {
    this.position = new PVector(-position.x + width/2, -position.y + height/2);
    target = position.copy();
    camSmoothing = 0.05;
  }

  void update() {
    target = new PVector(-hero.position.x + width/2, -hero.position.y + height/2);
    position.lerp(target, camSmoothing);
  }
}
