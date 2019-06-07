void initMap() {
  map = new Map();
  currentMap = map.generateMap(width/gridScl, height/gridScl);


  // Spawn Hero
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

  // Spawn Enemies
  for (int i = 0; i < currentMap.length; i++)
    for (int j = 0; j < currentMap[0].length; j++) {
      if (currentMap[i][j] == 0) {
        if (random(100) <= 10) {
          gameObjects.add(new Enemy(new PVector(i*mapScl, j*mapScl)));
        }
      }
    }

  // Spawn Walls
  for (int i = 0; i < currentMap.length; i++)
    for (int j = 0; j < currentMap[0].length; j++) {
      gameObjects.add(new Wall(i, j, new PVector(i*mapScl, j*mapScl), mapScl, currentMap[i][j]));
    }
}



void play() {
  background(0);
  camera.update();

  pushMatrix();
  scale(scl);
  translate(camera.position.x, camera.position.y);
  rotate(camera.roll);


  displayMap();

  displayUI();

  popMatrix();
}


void displayMap() {
  for (GameObject o : gameObjects)
    if (o instanceof Wall && dist(o.position.x, o.position.y, hero.position.x, hero.position.y) < width) {
      o.update();
      o.display();
    }


  for (int i = gameObjects.size()-1; i >= 0; i--) {
    GameObject obj = gameObjects.get(i);
    if (!(obj instanceof Wall)) {
      if (obj.isDead()) {
        gameObjects.remove(i);
        trauma += 0.5;
      } else {
        obj.update();
        obj.display();
      }
    }
  }
}

void displayUI() {
  displayLog();
  displayFPS();
  displayHeroValues();
}

void displayHeroValues() {
  // Shield
  
}


void displayFPS() {
  fill(0, 255, 0);
  text(int(frameRate), 10 - camera.position.x, 25 - camera.position.y);
}

void displayLog() {
  pushMatrix();
  rotate(-camera.roll);

  noStroke();

  // Sprint
  float y = map(hero.sprintMeter, 0, 100, 0, height-250);
  fill(40);
  rect(25 - camera.position.x, 200 - camera.position.y, 25, height-250);
  fill(255, 0, 0);
  rect(25 - camera.position.x, height-50-y - camera.position.y, 25, y);

  if (trauma>0)
    trauma -= 0.03;
  if (pressed['C'])
    trauma += 0.1;
  if (trauma>1) 
    trauma = 1;


  if (pressed['V'])
    hero.takeDamage(6);


  screenShake = trauma * trauma * trauma;
  if (screenShake > 1)
    screenShake = 1;
  sMag = SMAGT * screenShake;
  if (trauma<0) {
    sMag = 0;
    trauma = 0;
  }

  //// Trauma
  //fill(100);
  //rect(75 - camera.position.x, 200 - camera.position.y, 25, height-250);
  //float ry = map(trauma, 0, 1, 0, height-250);
  //fill(#FF5F24);
  //rect(75 - camera.position.x, height-50-ry - camera.position.y, 25, ry);

  //// Screenshake
  //fill(100);
  //rect(125 - camera.position.x, 200 - camera.position.y, 25, height-250);
  //ry = map(screenShake, 0, 1, 0, height-250);
  //fill(#249EFF);
  //rect(125 - camera.position.x, height-50-ry - camera.position.y, 25, ry);
  popMatrix();
}
