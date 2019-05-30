void initMap() {
  map = new Map();
  currentMap = map.generateMap(width/gridScl, height/gridScl);

  boolean foundHero = false;
  for (int i = 0; i < currentMap.length; i++) {
    for (int j = 0; j < currentMap[0].length; j++)
      if (i == map.start.x && j == map.start.y) {
        hero = new Hero(new PVector(i*mapScl, j*mapScl));
        gameObjects.add(hero);
        currentMap[i][j] = 0;
        foundHero = true;
        break;
      }
    if (foundHero) break;
  }


  for (int i = 0; i < currentMap.length; i++)
    for (int j = 0; j < currentMap[0].length; j++)
      gameObjects.add(new Wall(i, j, new PVector(i*mapScl, j*mapScl), mapScl, currentMap[i][j]));
}

void play() {
  background(0);

  camera.update();

  pushMatrix();
  translate(camera.position.x, camera.position.y);


  displayMap();

  popMatrix();
}


void displayMap() {
  for (GameObject o : gameObjects)
    if (o instanceof Wall) {
      o.update();
      o.display();
    }


  for (int i = gameObjects.size()-1; i >= 0; i--) {
    GameObject obj = gameObjects.get(i);
    if (!(obj instanceof Wall)) {
      if (obj.isDead()) {
        gameObjects.remove(i);
      } else {
        obj.update();
        obj.display();
      }
    }
  }
}
