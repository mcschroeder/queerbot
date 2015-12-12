import processing.serial.*;

final boolean DEBUG_SHOW_FPS = true;
final boolean DEBUG_SHOW_INFO_FOR_COVERED_SECTIONS = true;
final boolean DEBUG_BEGIN_WITH_ALL_SECTIONS_UNCOVERED = true;
final boolean DEBUG_SIMULATE_HARDWARE = true;

// constants
// TODO: replace by builtin width/height variable
final int SCREEN_WIDTH = 720;
final int SCREEN_HEIGHT = 576;

final int CANVAS_LEFT = 100;
final int CANVAS_RIGHT = SCREEN_WIDTH-100;
final int CANVAS_TOP = 50;
final int CANVAS_BOTTOM = SCREEN_HEIGHT-200;
final int CANVAS_WIDTH = CANVAS_RIGHT - CANVAS_LEFT;
final int CANVAS_HEIGHT = CANVAS_BOTTOM - CANVAS_TOP;
final color[] INGREDIENT_COLORS = {
    color(255,0,0),
    color(0,255,0),
    color(0,0,255),
    color(127,127,0),
    color(0,127,127),
    color(127,0,127)
};

enum QueerbotState {
  SELECTING,
  MIXING,
  //WAITING_FOR_REFILL,
  //ERROR
}

// variables
QueerbotState state;
Model model;
Cursor cursor1;
Cursor cursor2;
Cursor activeCursor;
Selection activeDrink;
Serial port;

void settings() {
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
}

void setup() {
  model = new Model("ingredients.csv", "input.rules", "cover.rules");
  cursor1 = new Cursor(model);
  cursor2 = new Cursor(model);
  cursor2.hidden = true;
  activeCursor = cursor1;
  
  if (!DEBUG_SIMULATE_HARDWARE) {
    port = new Serial(this, "/dev/ttyUSB0", 9600);
    port.bufferUntil(10);
  }
  
  state = QueerbotState.SELECTING;    
  ellipseMode(CENTER);
  noLoop();  
}

void draw() {
  switch (state) {
    case SELECTING: drawSelectingInterface(); break;
    case MIXING: drawMixingInterface(); break;
    //case WAITING_FOR_REFILL: drawRefillInterface(); break;
    //case ERROR: drawErrorInterface(); break;
  }
    
  if (DEBUG_SHOW_FPS) {
    drawFramerate();
  }
  
}

void drawFramerate() {
  fill(255);
  textSize(12);
  textAlign(LEFT,TOP);
  String fps = (int)frameRate+"";
  text(fps, SCREEN_WIDTH-textWidth(fps)-10, 5);  
}

///////////////////////////////////////////////////////////////////////////////

float analogValue;

void analogValueChanged(float x) {
  assert x >= 0 && x <= 1;
  analogValue = x;
  switch (state) {
    case SELECTING: moveCursor(x); break;
    default: break;
  }
}

void selectButtonPressed() {
  switch (state) {
    case SELECTING: select(); break;
    default: break;
  }
}

void confirmButtonPressed() {
  switch (state) {
    case SELECTING: confirm(); break;
    default: break;
  }
}

///////////////////////////////////////////////////////////////////////////////

void serialEvent(Serial port) {
  String line = port.readString();
  if (line == null) return;
  line = trim(line);
  if (line.isEmpty()) return;
  switch (line.charAt(0)) {    
    case 'A':
      if (line.length() < 3) return;
      int value = int(line.substring(2));
      float x = clamp(norm(value, 0, 1024), 0, 1);
      analogValueChanged(x);
      break;
    case 'B':
      if (line.length() < 3) return;
      int buttonID = int(line.substring(2));
      if (buttonID == 0) selectButtonPressed();
      else if (buttonID == 1) confirmButtonPressed();
      break;
    case '#':
      print(line);
      break;
  }
}

///////////////////////////////////////////////////////////////////////////////

void mouseMoved() {
  if (mouseX < CANVAS_LEFT || mouseX > CANVAS_RIGHT) return;
  float x = map(mouseX, CANVAS_LEFT, CANVAS_RIGHT, 0, 1);
  analogValueChanged(x);
}

void keyPressed() {
  switch (key) {
    case 's': selectButtonPressed(); break;
    case 'c': confirmButtonPressed(); break;
    case 'm': if (DEBUG_SIMULATE_HARDWARE) { endMixing(); break; }
  }
}

///////////////////////////////////////////////////////////////////////////////

// TODO: user builtin constrain() function

int clamp(int n, int min, int max) {
  return n < min ? min : n > max ? max : n;
}

float clamp(float n, float min, float max) {
  return n < min ? min : n > max ? max : n;
}