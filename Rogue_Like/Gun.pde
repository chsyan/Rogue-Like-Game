class Gun {
  int cd;
  int threshold;

  Gun(int threshold) {
    this.threshold = threshold;
    cd = 0;
  }

  void update() {
    cd++;
  }

  void shoot(PVector position, PVector direction, float speed, boolean isGood) {
    if (cd >= threshold) {
      gameObjects.add(new Bullet(position.copy(), direction.copy(), speed, isGood));
      cd = 0;
    }
  }
}
