// Map
int[][] currentMap;
Map map;
int gridScl = 10;
int mapScl = 50;
float scl = 1;
ArrayList<GameObject> gameObjects = new ArrayList<GameObject>();

// Hero
Hero hero;

// Camera
Camera camera;

// Input
boolean[] pressed = new boolean[256];
char upKey, leftKey, downKey, rightKey, shootKey, sprintKey;

// Screen shake
float sMag, camOff = random(10000);
float trauma, screenShake;
final float SMAGT= 10;


void setup() {
  size(1000, 800, FX2D);


  // Input key values
  upKey = 'W';
  leftKey = 'A';
  downKey = 'S';
  rightKey = 'D';
  shootKey = ' ';
  sprintKey = SHIFT;

  // Init map, hero, and enemies
  initMap();

  // Init camera
  camera = new Camera(hero.position.copy());
}

void draw() {
  play();
}
