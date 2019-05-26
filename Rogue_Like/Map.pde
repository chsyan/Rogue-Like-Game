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
  int sm;

  int[][] map;

  DrunkardsWalk() {
  }

  int[][] generateMap(int mapWidth, int mapHeight) {
    percentGoal = 0.4;
    walkIterations = 62500 * percentGoal; // cut off in case percentGoal is never reached
    weightedTowardCenter = 0.15;
    weightedTowardPreviousDirection = 0.7;
    sm = 2;

    map = new int[mapWidth][mapHeight]; // create an empty (filled with '1') 2D array with the above dimensions
    for (int i =0; i < map.length; i++)
      for (int j =0; j < map[0].length; j++)
        map[i][j] = 1;

    filled = 0;
    previousDirection = "None";


    // generate random starting point and set it as the "spawn"
    x = int(random(mapWidth/sm, (sm-1)*mapWidth/sm));
    y = int(random(mapHeight /sm, (sm-1)*mapHeight/sm));
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

    for (int i = 0; i < 1; i++)
      cleanUp(mapWidth, mapHeight);


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



  int getAdjacentWallsSimple(int x, int y) {
    int count = 0;
    if (map[x][y-1]==1)
      count++;
    if (map[x][y+1]==1)
      count++;
    if (map[x+1][y]==1)
      count++;
    if (map[x-1][y]==1)
      count++;
    return count;
  }
}

// =============================================================================
// __   ___                           __               ___  __             ___          __        ___ 
///  ` |__  |    |    |  | |     /\  |__)     /\  |  |  |  /  \  |\/|  /\   |   /\     /  \ |\ | |__  
//\__, |___ |___ |___ \__/ |___ /~~\ |  \    /~~\ \__/  |  \__/  |  | /~~\  |  /~~\    \__/ | \| |___ 

// =============================================================================               

class CellularAutomataOne extends Map {

  int iterations;
  int neighbors;
  float wallProbability;

  int ROOM_MIN_SIZE;
  int ROOM_MAX_SIZE;

  boolean smoothEdges;
  int smoothing;

  ArrayList<Cave> caves;

  CellularAutomataOne() {
  }

  int[][] generateMap(int mapWidth, int mapHeight) {

    iterations = 30000;
    neighbors = 4;
    wallProbability = 0.5;
    ROOM_MIN_SIZE = 16;
    ROOM_MAX_SIZE = 500;
    smoothEdges = true;
    smoothing = 1;

    caves = new ArrayList<Cave>();

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
    for (int x = 2; x < mapWidth-2; x++)
      for (int y = 2; y < mapHeight-2; y++)
        if (random(1) >= wallProbability)
          map[x][y] = 0;
  }

  void createCaves(int mapWidth, int mapHeight) {
    for (int i = 0; i < iterations; i++) {
      int tileX = int(random(2, mapWidth-3));
      int tileY = int(random(2, mapHeight-3));

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

  void createTunnel(PVector p1, PVector p2, Cave currentCave, int mapWidth, int mapHeight) {
    int drunkardX = int(p2.x);
    int drunkardY = int(p2.y);

    while (!currentCave.getTiles().contains(new PVector(drunkardX, drunkardY))) {
      float north = 1.0;
      float south = 1.0;
      float east = 1.0;
      float west = 1.0;

      int weight = 1;

      if (drunkardX < p1.x)
        east += weight;
      else if (drunkardX > p1.x)
        west += weight;
      if (drunkardY < p1.y)
        south += weight;
      else if (drunkardY > p1.y)
        north += weight;

      float total = north + south + east + west;
      north /= total;
      south /= total;
      east /= total;
      west /= total;

      float choice = random(1);
      int dx = 0, dy = 0;


      if (0 <= choice && choice < north)
        dy = -1;
      else if (choice < north + south)
        dy = 1;
      else if (choice < north + south + east)
        dx = 1;
      else dx = -1;

      if (2 < drunkardX + dx && drunkardX + dx < mapWidth-2 && 2 < drunkardY + dy && drunkardY + dy < mapHeight-2) {
        drunkardX += dx;
        drunkardY += dy;
        if (map[drunkardX][drunkardY] == 1)
          map[drunkardX][drunkardY] = 0;
      }
    }
  }

  boolean notIn(int x, int y, Cave currentCave) {
    for (PVector c : currentCave.getTiles())
      if (int(c.x) == x && int(c.y) == y)
        return false;
    return true;
  }

  boolean notIn(PVector p, Cave currentCave) {
    return notIn(int(p.x), int(p.y), currentCave);
  }

  int getAdjacentWallsSimple(int x, int y) {
    int count = 0;
    if (map[x][y-1]==1)
      count++;
    if (map[x][y+1]==1)
      count++;
    if (map[x+1][y]==1)
      count++;
    if (map[x-1][y]==1)
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

    for (Cave c : caves) 
      for (PVector t : c.getTiles()) {
        map[int(t.x)][int(t.y)] = 0;
      }
  }

  void floodFill(int x, int y) {
    /*
     flood fill the separate regions of the level, discard
     the regions that are smaller than a minimum size, and 
     create a reference for the rest.
     */

    Cave cave = new Cave();


    //flood fill implementation -> add tiles to cave
    PVector tile = new PVector(x, y);

    ArrayList<PVector> toBeFilled = new ArrayList<PVector>();
    toBeFilled.add(tile);

    while (toBeFilled.size()>0) {
      int randIndex = int(random(toBeFilled.size()));
      tile = toBeFilled.get(randIndex);
      toBeFilled.remove(randIndex);

      if (!cave.getTiles().contains(tile)) {
        cave.tiles.add(tile);

        map[int(tile.x)][int(tile.y)] = 1;

        x = int(tile.x);
        y = int(tile.y);
        PVector north = new PVector(x, y-1);
        PVector south = new PVector(x, y+1);
        PVector east = new PVector(x+1, y);
        PVector west = new PVector(x-1, y);
        ArrayList<PVector> directions = new ArrayList<PVector>();
        directions.add(north);
        directions.add(south);
        directions.add(east);
        directions.add(west);

        for (PVector dir : directions) 
          if (map[int(dir.x)][int(dir.y)] == 0)
            if (!toBeFilled.contains(dir) && !cave.getTiles().contains(dir))
              toBeFilled.add(dir);
      }
    }

    if (cave.getTiles().size() >= ROOM_MIN_SIZE)
      caves.add(cave);
  }

  void connectCaves(int mapWidth, int mapHeight) {
    for (Cave currentCave : caves) {

      PVector p1 = new PVector();
      for (PVector tempP1 : currentCave.getTiles()) {
        p1 = tempP1;
        break;
      }
      PVector p2 = new PVector(-100000, -100000); 
      float distance = -100000;

      for (Cave nextCave : caves) {
        if (nextCave != currentCave && !checkConnecivity(currentCave, nextCave)) {

          PVector nextPoint = new PVector();
          for (PVector np : nextCave.getTiles()) {
            nextPoint = np;
            break;
          }

          float newDistance = distanceFormula(p1, nextPoint);
          if (newDistance < distance || distance == -100000) {
            p2 = nextPoint; 
            distance = newDistance;
          }
        }
      }
      if (p2 == new PVector(-100000, -100000))
        createTunnel(p1, p2, currentCave, mapWidth, mapHeight);
    }
  }

  float distanceFormula(PVector p1, PVector p2) {
    return sqrt(pow((p2.x-p1.x), 2) + pow((p2.y-p1.y), 2));
  }

  boolean checkConnecivity(Cave cave1, Cave cave2) {
    ArrayList<PVector> connectedRegion = new ArrayList<PVector>(); 
    PVector start = new PVector();
    for (PVector s : cave1.getTiles()) {
      start = s;
      break;
    }
    ArrayList<PVector> toBeFilled = new ArrayList<PVector>();
    toBeFilled.add(start);
    while (toBeFilled.size()>0) {
      int randIndex = int(random(toBeFilled.size()));
      PVector tile = toBeFilled.get(randIndex);
      toBeFilled.remove(randIndex);

      if (!connectedRegion.contains(tile)) {
        connectedRegion.add(tile);

        int x = int(tile.x);
        int y = int(tile.y);
        PVector north = new PVector(x, y-1);
        PVector south = new PVector(x, y+1);
        PVector east = new PVector(x+1, y);
        PVector west = new PVector(x-1, y);
        ArrayList<PVector> directions = new ArrayList<PVector>();
        directions.add(north);
        directions.add(south);
        directions.add(east);
        directions.add(west);

        for (PVector direction : directions) {
          if (map[int(direction.x)][int(direction.y)] == 0)
            if (!toBeFilled.contains(direction) && !connectedRegion.contains(direction))
              toBeFilled.add(direction);
        }
      }
    }

    PVector end = new PVector();
    for (PVector e : cave2.getTiles()) {
      end = e;
      break;
    }

    return connectedRegion.contains(end);
  }
}



class Cave {
  ArrayList<PVector> tiles; 
  Cave() {
    tiles = new ArrayList<PVector>();
  }

  ArrayList<PVector> getTiles() { 
    return tiles;
  }
}


// ========================================================================================================          
// __   ___                           __               ___  __             ___         ___       __  
///  ` |__  |    |    |  | |     /\  |__)     /\  |  |  |  /  \  |\/|  /\   |   /\      |  |  | /  \ 
//\__, |___ |___ |___ \__/ |___ /~~\ |  \    /~~\ \__/  |  \__/  |  | /~~\  |  /~~\     |  |/\| \__/ 
// ========================================================================================================       


class CellularAutomataTwo extends Map {

  // Caves within the map are stored here
  ArrayList<ArrayList<PVector>> caves;

  // Corridors within the map are stored here
  ArrayList<PVector> corridors;

  // Contains the map
  int[][] map;

  // List of points which contain 4 directions
  ArrayList<PVector> directions;

  // List of points which contain the cardinal directions as well as diaganols
  ArrayList<PVector> directions1;

  float rnd;
  int neighbors;
  int iterations;
  float closeCellProb;
  int lowerLimit, upperLimit;
  int mapWidth, mapHeight;

  int emptyNeighbors;
  int emptyCellNeighbors;

  int corridorSpace;
  int corridorMaxTurns;
  int corridorMin;
  int corridorMax;

  int breakOut;

  CellularAutomataTwo(int mapWidth, int mapHeight) {

    directions = new ArrayList<PVector>();
    directions.add(new PVector(0, -1));
    directions.add(new PVector(0, 1));
    directions.add(new PVector(1, 0));
    directions.add(new PVector(-1, 0));

    directions1 = new ArrayList<PVector>();
    directions1.add(new PVector(0, -1));
    directions1.add(new PVector(0, 1));
    directions1.add(new PVector(1, 0));
    directions1.add(new PVector(-1, 0));
    directions1.add(new PVector(1, -1));
    directions1.add(new PVector(-1, -1));
    directions1.add(new PVector(-1, 1));
    directions1.add(new PVector(1, 1));
    directions1.add(new PVector(0, 0));




    rnd = random(12345);
    neighbors = 4;
    iterations = 50000;
    closeCellProb = 55;

    lowerLimit = 450;
    upperLimit = 1500;

    this.mapWidth = mapWidth;
    this.mapHeight = mapHeight;

    emptyNeighbors = 4;
    emptyCellNeighbors = 3;

    corridorSpace = 5;
    corridorMaxTurns = 10;
    corridorMin = 1;
    corridorMax = 10000;

    breakOut = 100000;
  }

  int[][] generateMap(int mapWidth, int mapHeight) {
    map = new int[mapWidth][mapHeight]; // create an empty 2D array with the above dimensions
    for (int i =0; i < map.length; i++)
      for (int j =0; j < map[0].length; j++)
        map[i][j] = 1;
    buildCaves();
    return map;
  }

  int build() {
    buildCaves();
    GetCaves();
    return caves.size();
  }

  void buildCaves() {
    map = new int[mapWidth][mapHeight];

    for (int x = 3; x < mapWidth-3; x++)
      for (int y = 3; y < mapHeight-3; y++)
        if (random(100) < closeCellProb)
          map[x][y] = 1;
        else map[x][y] = 0;

    PVector cell = new PVector();

    for (int x = 0; x <= iterations; x++) {
      cell = new PVector(int(random(3, mapWidth-3)), int(random(3, mapHeight-3)));

      //if the randomly selected cell has more closed neighbours than the property Neighbours
      //set it closed, else open it
      ArrayList<PVector> temp = Neighbors_Get1(cell.copy());
      int tempSize = 0;
      for (PVector n : temp)
        if (Point_Get(n.copy()) == 1) 
          tempSize++;

      if (tempSize > neighbors)
        Point_Set(cell.copy(), 1);
      else Point_Set(cell.copy(), 0);
    }

    // Smooth off rough cave edges and any single blocks by making several
    // passes on the map and removing any cells with 3 or more empty neighbors;
    for (int ctr = 0; ctr < 5; ctr++) 
      //examine each cell individually
      for (int x = 0; x < mapWidth; x++) 
        for (int y = 0; y < mapHeight; y++) {
          cell = new PVector(x, y);

          if (Point_Get(cell.copy()) > 0) {
            ArrayList<PVector> temp = Neighbors_Get(cell.copy());
            int tempSize = 0;
            for (PVector n : temp)
              if (Point_Get(n.copy()) == 0)
                tempSize++;
            if (tempSize >= emptyNeighbors)
              Point_Set(cell.copy(), 0);
          }
        }


    // Fill in any empty cells that have 4 full neighbors
    // to get rid of any holes
    for (int x = 0; x < mapWidth; x++)
      for (int y = 0; y < mapHeight; y++) {
        cell = new PVector(x, y);
        ArrayList<PVector> temp = Neighbors_Get(cell.copy());
        int tempSize = 0;
        for (PVector n : temp)
          if (Point_Get(n.copy()) == 1)
            tempSize++;
        if (tempSize >= emptyCellNeighbors)
          Point_Set(cell.copy(), 1);
      }
  }

  void Cave_GetEdge(ArrayList<PVector> pCave, PVector pCavePoint, PVector pDirection) {
    do {
      pCavePoint = pCave.get(int(random(pCave.size())));
      pDirection = Direction_Get(pDirection);

      do {
        pCavePoint.add(pDirection);

        if (!Point_Check(pCavePoint))
          break;
        else if (Point_Get(pCavePoint) == 0)
          return;
      } while (true);
    } while (true);
  }

  void GetCaves() { // Locate all the caves within the map and place each one into the generic list caves
    caves = new ArrayList<ArrayList<PVector>>();
    ArrayList<PVector> Cave;
    PVector cell;

    for (int x = 0; x < mapWidth; x++)
      for (int y = 0; y < mapHeight; y++) {
        cell = new PVector(x, y);

        if (Point_Get(cell) > 0) {
          int s = 0;
          for (ArrayList<PVector> t : caves)
            if (t.contains(cell)) s++;
          if (s == 0) {
            Cave = new ArrayList<PVector>();

            //recursive
            LocateCave(cell, Cave);

            // Check that cave falls with the specified property range size...
            if (Cave.size() <= lowerLimit || Cave.size() > upperLimit) {
              for (PVector p : Cave)
                Point_Set(p, 0);
            } else caves.add(Cave);
          }
        }
      }
  }


  // Recusive method to locate the cells comprising a cave,
  // based on flood fill algo
  void LocateCave(PVector pCell, ArrayList<PVector> pCave) {
    ArrayList<PVector> temp = Neighbors_Get(pCell.copy());
    for (int i = temp.size()-1; i>= 0; i--) {
      PVector t = temp.get(i);
      if (Point_Get(t) <= 0)
        temp.remove(i);
    }

    for (PVector p : temp)
      if (!pCave.contains(p.copy())) {
        pCave.add(p.copy());
        LocateCave(p.copy(), pCave);
      }
  }

  // Attempt to connect the caves together
  boolean ConnectCave() {
    if (caves.size() == 0) return false;

    ArrayList<PVector> currentcave;
    ArrayList<ArrayList<PVector>> ConnectedCaves = new ArrayList<ArrayList<PVector>>();
    PVector cor_point = new PVector();
    PVector cor_direction = new PVector();
    ArrayList<PVector> potentialcorridor = new ArrayList<PVector>();
    int breakoutctr = 0;

    corridors = new ArrayList<PVector>(); // corridors built stored here

    // get started by randomly selecting a cave
    currentcave = caves.get(int(random(caves.size())));
    ConnectedCaves.add(currentcave);
    caves.remove(currentcave);

    // starting builder
    do {
      // no corridors are present, sp build off a cave
      if (corridors.size() == 0) {
        currentcave = ConnectedCaves.get(int(random(ConnectedCaves.size())));
        Cave_GetEdge(currentcave, cor_point, cor_direction);
      } else {
        if (int(random(100)) > 50) {
          currentcave = ConnectedCaves.get(int(random(ConnectedCaves.size())));
          Cave_GetEdge(currentcave, cor_point, cor_direction);
        } else {
          currentcave = null;
          Corridor_GetEdge(cor_point, cor_direction);
        }

        // using the point we've determine above attempt to build a corridor off it
        potentialcorridor = Corridor_Attempt(cor_point, cor_direction, true);

        for (int ctr = 0; ctr < caves.size(); ctr++) {
          if (caves.get(ctr).contains(potentialcorridor.get(potentialcorridor.size()-1))) {
            if (currentcave == null || currentcave != caves.get(ctr)) {

              potentialcorridor.remove(potentialcorridor.get(potentialcorridor.size()-1));

              corridors.addAll(potentialcorridor);

              for (PVector p : potentialcorridor)
                Point_Set(p, 1);

              ConnectedCaves.add(caves.get(ctr));
              caves.remove(ctr);
              break;
            }
          }
        }
      }

      // breakout
      if (breakoutctr++ > breakOut)
        return false;
    } while (caves.size() > 0);

    caves.addAll(ConnectedCaves);
    ConnectedCaves.clear();
    return true;
  }

  void Corridor_GetEdge(PVector pLocation, PVector pDirection) {
    ArrayList<PVector> validDirections = new ArrayList<PVector>();

    do {
      pLocation = corridors.get(int(random(1, corridors.size()-1)));

      for (PVector p : directions)
        if (Point_Check(new PVector(pLocation.x + p.x, pLocation.y + p.y)))
          if (Point_Get(new PVector(pLocation.x + p.x, pLocation.y + p.y)) == 0)
            validDirections.add(p);
    } while (validDirections.size() == 0);

    pDirection = validDirections.get(int(random(validDirections.size())));
    pLocation.add(pDirection.copy());
  }


  ArrayList<PVector> Corridor_Attempt(PVector pStart, PVector pDirection, boolean pPreventBackTracking) {

    ArrayList<PVector> lPotentialCorridor = new ArrayList<PVector>();
    lPotentialCorridor.add(pStart);

    int corridorLength;
    PVector startDirection = new PVector(pDirection.x, pDirection.y);

    int pTurns = corridorMaxTurns;
    while (pTurns >= 0) {
      pTurns--;

      corridorLength = int(random(corridorMin, corridorMax));

      while (corridorLength > 0) {
        corridorLength--;

        pStart.add(pDirection);

        if (Point_Check(pStart) && Point_Get(pStart) == 1) {
          lPotentialCorridor.add(pStart);
          return lPotentialCorridor;
        }

        if (!Point_Check(pStart))
          return null;
        else if (!Corridor_PointTest(pStart.copy(), pDirection.copy()))
          return null;
      }

      if (pTurns > 1)
        if (!pPreventBackTracking)
          pDirection = Direction_Get(pDirection.copy());
        else
          pDirection = Direction_Get(pDirection.copy(), startDirection.copy());
    }

    return null;
  }

  boolean Corridor_PointTest(PVector pPoint, PVector pDirection) {
    ArrayList<Integer> enumerableRange = new ArrayList<Integer>();
    for (int i = -corridorSpace; i <= 2 * corridorSpace + 1; i++)
      enumerableRange.add(i);

    for (int r : enumerableRange) {
      if (pDirection.x == 0) {
        if (Point_Check(new PVector(pPoint.x + r, pPoint.y)))
          if (Point_Get(new PVector(pPoint.x + r, pPoint.y)) != 0)
            return false;
      } else if (pDirection.y == 0) {
        if (Point_Check(new PVector(pPoint.x, pPoint.y + r)))
          if (Point_Get(new PVector(pPoint.x, pPoint.y + r)) != 0)
            return false;
      }
    }

    return true;
  }

  // Return a list of valid neighboring cells of the provided point
  // using north, south, east, and west
  ArrayList<PVector> Neighbors_Get(PVector p) {
    ArrayList<PVector> valid = new ArrayList<PVector>();
    for (PVector d : directions) {
      PVector n = p.copy().add(d.copy()); 
      if (Point_Check(n.copy()))
        valid.add(n.copy());
    }
    return valid;
  }

  // Return a list of valid neighboring cells of the provided point
  // using north, south, east, west, ne, nw, se, sw
  ArrayList<PVector> Neighbors_Get1(PVector p) {
    ArrayList<PVector> valid = new ArrayList<PVector>();
    for (PVector d : directions1) {
      PVector n = p.copy().add(d.copy()); 
      if (Point_Check(n.copy()))
        valid.add(n.copy());
    }
    return valid;
  }


  // Get a random direction, provided it isn't equal to the opposite one provided
  PVector Direction_Get(PVector p) {
    PVector newDir = new PVector();
    do {
      newDir = directions.get(int(random(directions.size())));
    } while (newDir.copy().x != -p.copy().x && newDir.y != p.copy().y);
    return newDir;
  }


  // Get a random direction, excluding the provided directions and the opposite of 
  // the provided direction to prevent a corridor going back on itself.

  // The parameter pDirExclude is the first direction chosen for a corridor, and
  // to prevent it from being used will prevent a corridor from going back on 
  // itself

  PVector Direction_Get(PVector pDir, PVector pDirExclude) {
    PVector newDir = new PVector(); 
    do
    {
      newDir = directions.get(int(random(directions.size())));
    } 
    while (Direction_Reverse(newDir.copy()) == pDir.copy() || Direction_Reverse(newDir.copy()) == pDirExclude.copy());
    return newDir;
  }

  PVector Direction_Reverse(PVector pDir) {
    return new PVector(-pDir.copy().x, -pDir.copy().y);
  }

  // Check if the provided point is valid
  boolean Point_Check(PVector p) {
    return p.copy().x >= 0 && p.copy().x < mapWidth & p.copy().y >= 0 && p.copy().y < mapHeight;
  }


  // Set map cell to the specified value
  void Point_Set (PVector p, int val) {
    map[int(p.copy().x)][int(p.copy().y)] = val;
  }

  // Get the value of the provided point
  int Point_Get(PVector p) {
    return  map[int(p.copy().x)][int(p.copy().y)];
  }
}
