

// Map
int[][] currentMap;
Map map;
int gridScl = 2;

void setup() {

  size(1000, 800);

  /*
   CellularAutomataOne
   CellularAutomataTwo(width/gridScl, height/gridScl)
   DrunkardsWalk
   */
  map = new DrunkardsWalk();

  currentMap = map.generateMap(width/gridScl, height/gridScl);
}

void draw() {
  displayMap();
}

void mouseReleased() {
  currentMap = map.generateMap(width/gridScl, height/gridScl);
}
