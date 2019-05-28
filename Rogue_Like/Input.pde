void mouseReleased() {
  // currentMap = map.generateMap(width/mapScl, height/mapScl);
}


// Input
void keyPressed() {
  if (key==CODED)
    pressed[keyCode] = true;
  else pressed[key] = true;
}

void keyReleased() {
  if (key==CODED)
    pressed[keyCode] = false;
  else pressed[key] = false;
} 
