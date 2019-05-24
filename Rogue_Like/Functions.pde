void displayMap() {
  for (int i = 0; i < currentMap.length; i++)
    for (int j = 0; j < currentMap[0].length; j++) {
      noStroke();
      int s = currentMap[i][j];
      if (s == 0) fill(255);
      else if (s == 1) fill(0);
      else if (s == 2) fill(0, 0, 255);
      else if (s == 3) fill(255, 0, 0);
      rect(i*gridScl, j*gridScl, gridScl, gridScl);
    }
}
