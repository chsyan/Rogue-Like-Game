void play() {

  updateCamera();
  //pushMatrix();
  //translate(-camPos.x, -camPos.y);
  drawMap();

  //popMatrix();

  hero.update();
}

void initMap() {
  for (int i = 0; i < currentMap.length; i++)
    for (int j = 0; j < currentMap[0].length; j++)
      walls.add(new Wall(new PVector(i*gridScl, j*gridScl), gridScl, currentMap[i][j]));
}

void drawMap() {
  for (Wall w : walls) {
    w.display();
  }
}

void updateCamera() {
  camPos = new PVector(hero.position.x * gridScl, hero.position.y);
  //camPos.lerp(new PVector(hero.position.x, hero.position.y), camSmoothing);
}
