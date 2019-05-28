

// Map
int[][] currentMap;
Map map;
int mapScl;
int gridScl;

double timer;

// Hero
Hero hero;
PVector startingPos;

// Camera
PVector camPos;
float camSmoothing;

// Input;
boolean[] pressed = new boolean[256];
char upKey, leftKey, downKey, rightKey, shootKey;

// ArrayList of walls
ArrayList<Wall> walls = new ArrayList<Wall>();


void setup() {
  size(1000, 800, FX2D);

  // Map
  mapScl = 10;
  gridScl = 10;
  map = new Map();
  currentMap = map.generateMap(width/mapScl, height/mapScl);

  // Hero
  startingPos = map.start.copy();
  startingPos.mult(gridScl);
  startingPos.sub(width/2, height/2);
  hero = new Hero(startingPos);

  // Input Key Values
  upKey = 'W';
  leftKey = 'A';
  downKey = 'S';
  rightKey = 'D';
  shootKey = ' ';

  camPos = new PVector(hero.position.x, hero.position.y);
  camSmoothing = 0.2;
}

void draw() {
  background(0);
  play();
}
