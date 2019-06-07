class Camera {
  PVector position, target;
  float camSmoothing;
  float roll;

  Camera(PVector position) {
    this.position = new PVector(-position.x + width/2, -position.y + height/2);
    target = position.copy();
    camSmoothing = 0.05;
  }

  void update() {
    target = new PVector(-hero.position.x + width/2, -hero.position.y + height/2);
    position.lerp(target, camSmoothing);
    if (roll > 0) {
      roll -= 0.1;
    } else {
      roll += 0.1;
    }


    PVector shakeAmount = new PVector(noise(camOff), noise(1+camOff)).mult(random(-1, 1));
    roll = radians(1) * sMag * noise(camOff) * random(-1, 1) * 0.08;
    shakeAmount.mult(sMag);
    position.add(shakeAmount);
    camOff += 0.5;
  }
}
