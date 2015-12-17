import processing.serial.*;

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

void settings() {
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
  //fullScreen();
}

void setup() {
  noCursor();
  noLoop();
    
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

String _errorMsg;

void gotoError(String msg) {
  state = QueerbotState.ERROR;
  _errorMsg = msg;
  redraw();
}

void drawErrorInterface() {
  background(0,0,255);
  textAlign(CENTER, BOTTOM);
  int size = 50;
  textSize(size);
  while (textWidth(_errorMsg) > SCREEN_WIDTH-50) {
    textSize(size--);
  }
  text(_errorMsg, SCREEN_WIDTH/2, SCREEN_WIDTH/2);  
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

void didReceiveFillLevel(int index, int amount) {
  if (index >= model.ingredients.length) return;
  model.ingredients[index].fillLevel = amount;
  if (state == QueerbotState.MIXING) {
    mixNextIngredient();
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
    case 'F':
      if (line.length() < 3) return;
      String[] tokens = splitTokens(line.substring(2), " ");
      if (tokens.length < 2) return;
      int ingredientID = int(tokens[0]);
      int amount = int(tokens[1]);
      didReceiveFillLevel(ingredientID, amount);
      break;
    case '#':
      print(line);
      break;
  }
}

///////////////////////////////////////////////////////////////////////////////

void mouseMoved() {
  float x = map(mouseX, 0, SCREEN_WIDTH, 0, 1);
  analogValueChanged(x);
}

void keyPressed() {
  switch (key) {
    case 's': selectButtonPressed(); break;
    case 'c': if (DEBUG_SIMULATE_HARDWARE && state == QueerbotState.MIXING) gotoSelecting(); else confirmButtonPressed(); break;
    //case 'm': gotoMaintenanceMode(); break;
  }
}