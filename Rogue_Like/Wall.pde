class Wall {

  PVector position;
  int size;
  int state;
  color col;

  Wall(PVector position, int size, int state) {
    this.position = position;
    this.size = size;
    this.state = state;

    if (state == 0) col = color(255);
    else if (state == 1) col = color(0);
    else if (state == 2) col = color(0, 0, 255);
    else if (state == 3) col = color(255, 0, 0);
  }

  void display() {
    fill(col);
    rect(position.x, position.y, size, size);
  }

  PVector getPosition() {
    return position;
  }

  int getSize() {
    return size;
  }

  int getState() {
    return state;
  }
}
