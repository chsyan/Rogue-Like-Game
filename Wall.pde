class Wall extends GameObject {

  int state;
  color c;
  int alpha;

  int FLOOR = 0;
  int WALL = 1;
  int END = 3;
  int FLOOR_FOG = 2;
  int WALL_FOG;
  int BOUNDARY = 10;

  int xIndex, yIndex;

  int r, g, b;

  boolean visible;

  Wall(int xIndex, int yIndex, PVector position, int size, int state) {
    this.position = position.copy();
    this.state = state;
    this.size = size;
    hp = 1;

    this.xIndex = xIndex;
    this.yIndex = yIndex;

    if (state == FLOOR)
      r = g = b = 255; 
    else if (state == WALL)
      r = g = b = 140;   
    else if (state == END) {
      r = 255;
      g = 0;
      b = 0;
    } else if (state == BOUNDARY) {
      r = g = b = 0;
    }

    visible = true;
  }

  void display() {

    if (visible)
      alpha = 255;
    else alpha = 0;

    stroke(r, g, b, alpha);
    fill(r, g, b, alpha);
    rect(position.x, position.y, size, size);
  }
}
