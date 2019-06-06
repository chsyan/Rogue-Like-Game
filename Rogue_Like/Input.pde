void mouseReleased() {
}

void mousePressed() {
}


// Input
void keyPressed() {
  if (key==CODED) {
    pressed[keyCode] = true;
  } else pressed[key] = true;

  if (key == '1')
    scl -= 0.1;
  if (key == '2')
    scl += 0.1;
}

void keyReleased() {
  if (key==CODED) {
    pressed[keyCode] = false;
  } else pressed[key] = false;
} 
