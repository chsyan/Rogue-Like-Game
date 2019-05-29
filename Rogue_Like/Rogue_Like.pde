// Map
int[][] currentMap;
Map map;
int gridScl = 10;
int mapScl = 25;
ArrayList<GameObject> gameObjects = new ArrayList<GameObject>();

// Hero
Hero hero;

// Camera
Camera camera;

// Input
boolean[] pressed = new boolean[256];
char upKey, leftKey, downKey, rightKey, shootKey;


void setup() {
  size(1000, 800);

  // Input key values
  upKey = 'w';
  leftKey = 'a';
  downKey = 's';
  rightKey = 'd';
  shootKey = ' ';

  // Init map & hero
  initMap();

  // Init camera
  camera = new Camera(hero.position.copy());
}

void draw() {
  play();
}
