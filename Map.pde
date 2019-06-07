class Map {
  int[][] map;
  double percentGoal;
  double walkIterations;
  double weightedTowardCenter, weightedTowardPreviousDirection;
  double filled, filledGoal;
  int x, y; // Coords
  double north, south, east, west; // Directions
  String previousDirection;

  PVector start, end;

  int temp;

  Map() {
  }

  int[][] generateMap(int mapWidth, int mapHeight) {
    temp = 0;

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
    start = new PVector(sx, sy);
    map[sx][sy] = 0;

    filledGoal = mapWidth * mapHeight * percentGoal;

    // Replace wall tiles with floor tiles
    for (int i = 0; i < walkIterations; i++) {
      walk(mapWidth, mapHeight);
      if (filled >= filledGoal) {
       
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

    end = new PVector(ex, ey);

    cleanUp(mapWidth, mapHeight);

    markBoundary(mapWidth, mapHeight);






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

  void cleanUp(int mapWidth, int mapHeight) {
    for (int x = 1; x < mapWidth-1; x++)
      for (int y = 1; y < mapHeight-1; y++)
        if (getAdjacentWallsSimple(x, y) <= 0)
          if (map[x][y] == 1)
            map[x][y] = 0;
  }

  void  markBoundary(int mapWidth, int mapHeight) {
    for (int x = 1; x < mapWidth-1; x++)
      for (int y = 1; y < mapHeight-1; y++)
        if (getAdjacentWalls(x, y) >= 8)
          if (map[x][y] != 0)
            map[x][y] = 10;

    //set the outer ring as 'boundaries'
    for (int x = 0; x < map.length; x++) {
      map[x][0] = 10;
      map[x][map[0].length-1] = 10;
    }

    for (int y = 0; y < map[0].length; y++) {
      map[0][y] = 10;
      map[map.length-1][y] = 10;
    }
  }



  int getAdjacentWallsSimple(int x, int y) {
    int count = 0;
    if (map[x][y-1]!=0)
      count++;
    if (map[x][y+1]!=0)
      count++;
    if (map[x+1][y]!=0)
      count++;
    if (map[x-1][y]!=0)
      count++;
    return count;
  }


  int getAdjacentWalls(int tx, int ty) {
    int count = 0;
    for (int x = tx-1; x <= tx+1; x++)
      for (int y = ty-1; y <= ty+1; y++)
        if (map[x][y] != 0)
          if (x != tx || y != ty)
            count++;
    if (count>temp) {
      temp = count;
    }
    return count;
  }

  PVector getStart() { 
    return start;
  }
  PVector getEnd() { 
    return end;
  }
}
