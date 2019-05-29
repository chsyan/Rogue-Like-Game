void initMap() {
  map = new Map();
  currentMap = map.generateMap(width/gridScl, height/gridScl);

  for (int i = 0; i < currentMap.length; i++)
    for (int j = 0; j < currentMap[0].length; j++) {
      if (i == map.start.x && j == map.start.y) {
        hero = new Hero(new PVector(i*mapScl, j*mapScl));
        gameObjects.add(hero);
        currentMap[i][j] = 0;
      }
      gameObjects.add(new Wall(i, j, new PVector(i*mapScl, j*mapScl), mapScl, currentMap[i][j]));
    }
}

void play() {
  //calcFOV();
  camera.update();

  pushMatrix();
  translate(camera.position.x, camera.position.y);
  //translate(-hero.position.x + width/2, -hero.position.y + height/2);
  background(0);
  displayMap();

  popMatrix();
}


void displayMap() {
  for (int i = gameObjects.size()-1; i >= 0; i--) {
    GameObject obj = gameObjects.get(i);
    obj.update();
    obj.display();
  }
  hero.update();
  hero.display();
}


void calcFOV() {
  boolean[][] fovmap = new boolean[currentMap.length][currentMap[0].length];
  for (int x = int(hero.position.x - hero.viewRadius); x < fovmap.length * mapScl; x++) {
    for (int y = int(hero.position.y - hero.viewRadius); y < fovmap[0].length * mapScl; y++) {
      if (dist(hero.position.x, hero.position.y, x, y) <= hero.viewRadius) {
        try {
          if (hasLOS(new PVector(x, y))) {
            fovmap[x][y] = true;
          }
        } 
        catch (Exception e) {
        }
      }
    }
  }

  println("hi");

  for (int x = 0; x < currentMap.length; x++)
    for (int y = 0; x < currentMap[0].length; y++)
      for (GameObject o : gameObjects) {
        if (o instanceof Wall) {
          int xIndex = ((Wall) o).xIndex;
          int yIndex = ((Wall) o).yIndex;
          if (x == xIndex && y == yIndex)
            ((Wall) o).visible = fovmap[x][y];
        }
      }

  for (int x = 0; x < currentMap.length; x++)
    for (int y = 0; x < currentMap[0].length; y++)
      println(fovmap[x][y]);

  println("hi");
}

boolean hasLOS(PVector blockPoint) {
  boolean blocked = true;
  for (float i = 0; i < 1; i += 0.05f)
  {
    PVector yvect = getVector(new PVector(blockPoint.x, blockPoint.y), new PVector(hero.position.x, hero.position.y), i);
    PVector xvect = getVector(new PVector(blockPoint.x, blockPoint.y), new PVector(hero.position.x, hero.position.y), i);
    int y = int(yvect.y);
    int x = int(xvect.x);
    if (currentMap[x][y] == 1)
    {
      blocked = false;
    }
  }

  return blocked;
}


PVector getVector (PVector v1, PVector v2, float t) {
  PVector delta = v1.copy().sub(v2.copy());
  float distance = dist(v1.x, v1.y, v2.x, v2.y);
  if (distance == 0)
    return v1;

  PVector direction = delta.copy().div(distance);
  return v1.add(direction.mult((distance *t)));
}
