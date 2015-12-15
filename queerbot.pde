import processing.serial.*;

final boolean DEBUG_SHOW_FPS = false;
final boolean DEBUG_SHOW_INFO_FOR_COVERED_SECTIONS = false;
final boolean DEBUG_BEGIN_WITH_ALL_SECTIONS_UNCOVERED = true;
final boolean DEBUG_SIMULATE_HARDWARE = true;

int LEGEND_BOTTOM;
int CANVAS_LEFT, CANVAS_RIGHT, CANVAS_TOP, CANVAS_BOTTOM, CANVAS_WIDTH, CANVAS_HEIGHT;
int HISTORY_TOP;
int MIN_BUBBLE_RADIUS;
color BACKGROUND_COLOR = color(0);

final color[] INGREDIENT_COLORS = {
    color(6,174,213),
    color(8,103,136),
    color(240,200,8),
    color(255,241,208),
    color(221,28,26),
    color(146,94,45)
};

enum QueerbotState {
  SELECTING,
  MIXING,
  //WAITING_FOR_REFILL,
  ERROR
}

// variables
QueerbotState state;
Model model;
Cursor cursor1;
Cursor cursor2;
Cursor activeCursor;
Selection activeDrink;
Serial port;
String errorMsg;

void setup() {
  //size(800,600);
  noCursor();
  fullScreen();
  noLoop();
  
  LEGEND_BOTTOM = 200;
  CANVAS_LEFT = 0;
  CANVAS_RIGHT = width;
  CANVAS_TOP = LEGEND_BOTTOM;
  CANVAS_BOTTOM = height-200;
  CANVAS_WIDTH = CANVAS_RIGHT - CANVAS_LEFT;
  CANVAS_HEIGHT = CANVAS_BOTTOM - CANVAS_TOP;
  HISTORY_TOP = height-150;
  MIN_BUBBLE_RADIUS = 100;
  
  model = new Model("ingredients.csv", "input.rules", "cover.rules");
  cursor1 = new Cursor(model);
  cursor2 = new Cursor(model);
  cursor2.hidden = true;
  activeCursor = cursor1;
  
  if (!DEBUG_SIMULATE_HARDWARE) {
    try {
      port = new Serial(this, "/dev/ttyUSB0", 9600);
      port.bufferUntil(10);
    } catch (Exception e) {
      gotoError(e.getLocalizedMessage());      
      return;
    }
  }
  
  state = QueerbotState.SELECTING;    
}

void draw() {
  switch (state) {
    case SELECTING: drawSelectingInterface(); break;
    case MIXING: drawMixingInterface(); break;
    //case WAITING_FOR_REFILL: drawRefillInterface(); break;
    case ERROR: drawErrorInterface(); break;
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
  text(fps, width-textWidth(fps)-10, 5);  
}

///////////////////////////////////////////////////////////////////////////////

void gotoError(String msg) {
  state = QueerbotState.ERROR;
  errorMsg = msg;
  redraw();
}

void drawErrorInterface() {
  background(0,0,255);
  textAlign(CENTER, BOTTOM);
  int size = 50;
  textSize(size);
  while (textWidth(errorMsg) > width-50) {
    textSize(size--);
  }
  text(errorMsg, width/2, height/2);  
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
      float x = constrain(norm(value, 0, 1024), 0, 1);
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
    case 'm': if (DEBUG_SIMULATE_HARDWARE) { gotoSelecting(); break; }
  }
}
