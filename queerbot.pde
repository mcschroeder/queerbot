import processing.serial.*;

final boolean DEBUG_LOG_RULES = true;
final boolean DEBUG_SHOW_FPS = false;
final boolean DEBUG_SHOW_INFO_FOR_COVERED_SECTIONS = false;
final boolean DEBUG_BEGIN_WITH_ALL_SECTIONS_UNCOVERED = true;
final boolean DEBUG_SIMULATE_HARDWARE = true;

int SCREEN_WIDTH, SCREEN_HEIGHT;

int LEGEND_HEIGHT, LEGEND_TOP, LEGEND_BOTTOM;
int CANVAS_LEFT, CANVAS_RIGHT, CANVAS_TOP, CANVAS_BOTTOM, CANVAS_WIDTH, CANVAS_HEIGHT;
int HISTORY_HEIGHT, HISTORY_TOP;
int RAINBOW_TOP, RAINBOW_BOTTOM;


final color[] INGREDIENT_COLORS = {
    color(6,174,213),
    color(8,103,136),
    color(240,200,8),
    color(255,241,208),
    color(221,28,26),
    color(146,94,45)
};

color[] RAINBOW_COLORS = {
  color(255,0,0),
  color(255,127,0),
  color(255,255,0),
  color(0,255,0),
  color(0,0,255),
  color(75,0,130),
  color(139,0,255)
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
  loadConfig("config.txt");
  
  size(800,600);
  noCursor();
  //fullScreen();
  noLoop();
  
  SCREEN_WIDTH = width;
  SCREEN_HEIGHT = height;
  
  LEGEND_HEIGHT = 80;  
  HISTORY_HEIGHT = SCREEN_HEIGHT/4;
  CANVAS_HEIGHT = SCREEN_HEIGHT-LEGEND_HEIGHT-HISTORY_HEIGHT;
  
  LEGEND_TOP = 0;
  LEGEND_BOTTOM = LEGEND_TOP+LEGEND_HEIGHT;
  
  
  CANVAS_LEFT = 0;
  CANVAS_RIGHT = SCREEN_WIDTH;
  CANVAS_TOP = LEGEND_BOTTOM;
  CANVAS_BOTTOM = CANVAS_TOP+CANVAS_HEIGHT;
  CANVAS_WIDTH = CANVAS_RIGHT - CANVAS_LEFT;
  
  HISTORY_TOP = CANVAS_BOTTOM;
  RAINBOW_TOP = HISTORY_TOP + 50;
  RAINBOW_BOTTOM = height - 20;
    
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