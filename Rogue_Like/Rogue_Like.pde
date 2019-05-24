

// Map
int[][] currentMap;
Map map;
int gridScl = 10;

void setup() {

  size(1000, 800);

  map = new CellularAutomata();

  currentMap = map.generateMap(width/gridScl, height/gridScl);
}

void draw() {
  displayMap();
}

void mouseReleased() {
  currentMap = map.generateMap(width/gridScl, height/gridScl);
}
