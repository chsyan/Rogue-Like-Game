abstract class Map {
  int[][] map;

  Map() {
  }

  int[][] generateMap(int mapWidth, int mapHeight) {
    map = new int[mapWidth][mapHeight]; // create an empty 2D array with the above dimensions
    return map;
  }
}

// =============================================================================
// __   __                       __   __   __                         
//|  \ |__) |  | |\ | |__/  /\  |__) |  \ /__`    |  |  /\  |    |__/ 
//|__/ |  \ \__/ | \| |  \ /~~\ |  \ |__/ .__/    |/\| /~~\ |___ |  \ 
// =============================================================================

class DrunkardsWalk extends Map {

  double percentGoal;
  double walkIterations;
  double weightedTowardCenter, weightedTowardPreviousDirection;
  double filled, filledGoal;
  int x, y; // Coords
  double north, south, east, west; // Directions
  String previousDirection;

  int[][] map;

  DrunkardsWalk() {
  }

  int[][] generateMap(int mapWidth, int mapHeight) {
    percentGoal = 0.4;
    walkIterations = 62500 * percentGoal; // cut off in case percentGoal is never reached
    weightedTowardCenter = 0.15;
    weightedTowardPreviousDirection = 0.7;

    map = new int[mapWidth][mapHeight]; // create an empty (filled with '1') 2D array with the above dimensions
    for (int i =0; i < map.length; i++)
      for (int j =0; j < map[0].length; j++)
        map[i][j] = 1;

    filled = 0;
    previousDirection = "None";


    // generate random starting point and set it as the "spawn"
    x = int(random(3, mapWidth-3));
    y = int(random(3, mapHeight-3));
    int sx = x, sy = y; // starting x, y -> will become useful when generating end point
    map[sx][sy] = 2;

    filledGoal = mapWidth * mapHeight * percentGoal;

    // Replace wall tiles with floor tiles
    for (int i = 0; i < walkIterations; i++) {
      walk(mapWidth, mapHeight);
      if (filled >= filledGoal) {
        println("break" + i);
        break;
      }
    }

    // Find a valid end point tile -> proceed to next level
    int ex, ey; // coords for end point
    double scl = 1;
    int iterations = 0;
    int max_interations = 5000;

    do {
      ex = int(random(3, mapWidth-3));
      ey = int(random(3, mapHeight-3));

      iterations ++;
      if (iterations > max_interations) {
        iterations = 0;
        scl -= 0.1;
      }
    } while (map[ex][ey] != 0 || dist(ex, ey, sx, sy) < scl * (mapWidth + mapHeight) / 2);
    map[ex][ey] = 3;


    return map;
  }

  void walk(int mapWidth, int mapHeight) {

    north= 1;
    south = 1;
    east = 1;
    west = 1;

    // Weigh the random walk against edges
    if (x < mapWidth * 0.25) east += weightedTowardCenter;
    else if (x > mapWidth * 0.75)  west += weightedTowardCenter;
    if (y < mapHeight * 0.25) south += weightedTowardCenter;
    else if (x > mapHeight * 0.75) north += weightedTowardCenter;

    // Weigh the random walk in favor of the previous direction (If it exists)
    if (previousDirection.equals("north")) north += weightedTowardPreviousDirection;
    if (previousDirection.equals("south")) south += weightedTowardPreviousDirection;
    if (previousDirection.equals("east")) east += weightedTowardPreviousDirection;
    if (previousDirection.equals("west")) west += weightedTowardPreviousDirection;

    // Normalize probabilities -> 0, 1
    double total = north + south + east + west;

    north /= total;
    south /= total;
    east /= total;
    west /= total;

    // Choose direction
    double choice = random(1);
    int dx = 0, dy = 0;
    String direction;

    if (0 <= choice && choice < north) {
      dx = 0;
      dy = -1;
      direction = "north";
    } else if (choice < (north + south)) {
      dx = 0;
      dy = 1;
      direction = "south";
    } else if (choice < (north + south + east)) {
      dx = 1;
      dy = 0;
      direction = "east";
    } else {
      dx = -1;
      dy = 0;
      direction = "west";
    }

    // Walk
    if (2 < x + dx && x + dx < mapWidth-2 && 2 < y + dy && y + dy < mapHeight-2) {
      x += dx;
      y += dy;
      if (map[x][y] == 1) {
        map[x][y] = 0;
        filled ++;
      }
      previousDirection = direction;
    }
  }
}

// =============================================================================
// __   ___                           __               ___  __             ___      
///  ` |__  |    |    |  | |     /\  |__)     /\  |  |  |  /  \  |\/|  /\   |   /\  
//\__, |___ |___ |___ \__/ |___ /~~\ |  \    /~~\ \__/  |  \__/  |  | /~~\  |  /~~\ 
// =============================================================================               

/*
https://github.com/AtTheMatinee/dungeon-generation/blob/master/dungeonGenerationAlgorithms.py
 https://github.com/AndyStobirski/RogueLike/blob/master/csCaveGenerator.cs
 
 https://www.gridsagegames.com/blog/2014/06/mapgen-cellular-automata/
 http://www.evilscience.co.uk/a-c-algorithm-to-build-roguelike-cave-systems-part-1/
 */

class CellularAutomata extends Map {

  int iterations = 30000;
  int neighbors;
  int wallProbability;

  int ROOM_MIN_SIZE = 16;
  int ROOM_MAX_SIZE = 500;

  boolean smoothEdges = true;
  int smoothing = 1;

  ArrayList<PVector> caves;

  CellularAutomata() {
  }

  int[][] generateMap(int mapWidth, int mapHeight) {

    caves = new ArrayList<PVector>();

    map = new int[mapWidth][mapHeight];
    for (int i =0; i < map.length; i++)
      for (int j =0; j < map[0].length; j++)
        map[i][j] = 1;

    randomFillMap(mapWidth, mapHeight);

    createCaves(mapWidth, mapHeight);

    getCaves(mapWidth, mapHeight);

    connectCaves(mapWidth, mapHeight);

    cleanUpMap(mapWidth, mapHeight);

    return map;
  }

  void randomFillMap(int mapWidth, int mapHeight) {
    for (int x = 1; x < mapWidth-1; x++)
      for (int y = 1; y < mapHeight-1; y++)
        if (random(1) >= wallProbability)
          map[x][y] = 0;
  }

  void createCaves(int mapWidth, int mapHeight) {
    for (int i = 0; i < iterations; i++) {
      int tileX = int(random(1, mapWidth-2));
      int tileY = int(random(1, mapHeight-2));

      if (getAdjacentWalls(tileX, tileY) > neighbors)
        map[tileX][tileY] = 1;
      else if (getAdjacentWalls(tileX, tileY) < neighbors)
        map[tileX][tileY] = 0;
    }

    cleanUpMap(mapWidth, mapHeight);
  }

  void cleanUpMap(int mapWidth, int mapHeight) {
    if (smoothEdges)
      for (int i = 0; i < 5; i++)
        for (int x = 1; x < mapWidth-1; x++)
          for (int y = 1; y < mapHeight-1; y++)
            if (map[x][y] == 1 && getAdjacentWallsSimple(x, y) <= smoothing)
              map[x][y] = 0;
  }

  void createTunnel(int[] p1, int[] p2, ArrayList<PVector> currentCave, int mapWidth, int mapHeight) {
    int drunkardX = p2[0];
    int drunkardY = p2[1];

    while (notIn(drunkardX, drunkardY, currentCave)) {
      float north = 1.0;
      float south = 1.0;
      float east = 1.0;
      float west = 1.0;

      int weight = 1;

      if (drunkardX < p1[0])
        east += weight;
      else if (drunkardX > p1[0])
        west += weight;
      if (drunkardY < p1[1])
        south += weight;
      else if (drunkardY > p1[1])
        north += weight;

      float total = north + south + east + west;
      north /= total;
      south /= total;
      east /= total;
      west /= total;

      float choice = random(1);
      int dx = 0, dy = 0;


      if (choice < north)
        dy = -1;
      else if (choice < north + south)
        dy = 1;
      else if (choice < north + south + east)
        dx = 1;
      else dx = -1;

      if (0 < drunkardX + dx && drunkardX + dx < mapWidth-1 && 0 < drunkardY + dy && drunkardY + dy < mapHeight-1) {
        drunkardX += dx;
        drunkardY += dy;
        if (map[drunkardX][drunkardY] == 1)
          map[drunkardX][drunkardY] = 0;
      }
    }
  }

  boolean notIn(int x, int y, ArrayList<PVector> currentCave) {
    for (PVector c : currentCave)
      if (c.x == x && c.y == y)
        return false;
    return true;
  }

  int getAdjacentWallsSimple(int x, int y) {
    int count = 0;
    if (map[x][y-1]==1 || map[x][y+1]==1 || map[x+1][y]==1 || map[x-1][y]==1)
      count++;
    return count;
  }

  int getAdjacentWalls(int tx, int ty) {
    int count = 0;
    for (int x = tx-1; x < tx+2; x++)
      for (int y = ty-1; y < ty+2; y++)
        if (map[x][y] == 1)
          if (x != tx || y != ty)
            count++;
    return count;
  }

  void getCaves(int mapWidth, int mapHeight) {
    // locate all the caves within map[][] and store them in List<Cave> caves
    for (int x = 0; x < mapWidth; x++)
      for (int y = 0; y < mapHeight; y++)
        if (map[x][y] == 0)
          floodFill(x, y);

    for (PVector t : caves) 
      map[int(t.x)][int(t.y)] = 0;
  }

  void floodFill(int x, int y) {
    /*
     flood fill the separate regions of the level, discard
     the regions that are smaller than a minimum size, and 
     create a reference for the rest.
     */




    ArrayList<PVector> cave = new ArrayList<PVector>();
    // TODO: flood fill implementation -> add tiles to cave

    if (cave.size() >= ROOM_MIN_SIZE)
      caves.addAll(cave);
  }

  void connectCaves(int mapWidth, int mapHeight) {
  }
}
