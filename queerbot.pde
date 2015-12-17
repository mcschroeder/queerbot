import processing.serial.*;

enum QueerbotState {
  SELECTING,
  MIXING,
  MAINTENANCE,
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
PrintWriter hwLogWriter;

void settings() {
  boolean fullscreen = false;
  try {
    fullscreen = (null != System.getenv("QUEERBOT_REVISION"));
  } catch (Exception e) {}
  if (fullscreen) {
    fullScreen();
  } else {
    size(SCREEN_WIDTH, SCREEN_HEIGHT);
  }
}

void setup() {
  noCursor();
  noLoop();
    
  model = new Model("ingredients.csv", "input.rules", "cover.rules");
  cursor1 = new Cursor(model);
  cursor2 = new Cursor(model);
  cursor2.hidden = true;
  activeCursor = cursor1;
  
  if (DEBUG_LOG_HARDWARE) {
    hwLogWriter = createWriter("log/serial.log");
  }
  
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

void stop() {
  hwLogWriter.flush();
  hwLogWriter.close();
  model.history.logWriter.flush();
  model.history.logWriter.close();
}

void draw() {
  switch (state) {
    case SELECTING: drawSelectingInterface(); break;
    case MIXING: drawMixingInterface(); break;
    case MAINTENANCE: drawMaintenanceInterface(); break;
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
  text(_errorMsg, SCREEN_WIDTH/2, SCREEN_HEIGHT/2);  
}

///////////////////////////////////////////////////////////////////////////////

float analogValue;

void analogValueChanged(float x) {
  assert x >= 0 && x <= 1;
  analogValue = x;
  switch (state) {
    case SELECTING: moveCursor(x); break;
    case MAINTENANCE: _maint_moveCursor(x); break;
    default: break;
  }
}

void selectButtonPressed() {
  switch (state) {
    case SELECTING: select(); break;
    case MAINTENANCE: _maint_select(); break;
    default: break;
  }
}

void confirmButtonPressed() {
  switch (state) {
    case SELECTING: confirm(); break;
    case MAINTENANCE: _maint_confirm(); break;
    default: break;
  }
}

void maintenanceButtonPressed() {
  switch (state) {
    case SELECTING: gotoMaintenanceMode(); break;
    case MAINTENANCE: gotoSelecting(); break;
    default: break;
  }
}

void didReceiveFillLevel(int index, int amount) {
  if (index >= model.ingredients.length) return;
  model.ingredients[index].fillLevel = amount;
  switch (state) {
    case MIXING: mixNextIngredient(); break;
    case MAINTENANCE: redraw();
    default: break;
  }
}

void openValve(int index, int amount) {
  sendCommand("V " + index + " " + amount + "\n");
}

void setFillLevel(int index, int amount) {
  sendCommand("F " + index + " " + amount + "\n");
}

void sendCommand(String cmd) {
  if (DEBUG_LOG_HARDWARE && hwLogWriter != null) {
    hwLogWriter.println(cmd);
    hwLogWriter.flush();
  }
  port.write(cmd);
}

///////////////////////////////////////////////////////////////////////////////

void serialEvent(Serial port) {
  String line = port.readString();
  if (DEBUG_LOG_HARDWARE && hwLogWriter != null) {
    hwLogWriter.print(">");
    hwLogWriter.println(line);
    hwLogWriter.flush();
  }
  if (line == null) return;
  line = trim(line);
  if (line.isEmpty()) return;
  switch (line.charAt(0)) {    
    case 'A':
      if (line.length() < 3) return;
      int value = int(line.substring(2));
      float x = constrain(norm(value, LEVER_MIN, LEVER_MAX), 0, 1);
      analogValueChanged(x);
      break;
    case 'B':
      if (line.length() < 2) return;
      int buttonID = int(line.substring(1));
      if (buttonID == SELECT_BUTTON_ID) selectButtonPressed();
      else if (buttonID == CONFIRM_BUTTON_ID) confirmButtonPressed();
      else if (buttonID == MAINTENANCE_BUTTON_ID) maintenanceButtonPressed();
      break;
    case 'F':
      if (line.length() < 3) return;
      String[] tokens = splitTokens(line.substring(2), " ");
      if (tokens.length < 2) return;
      int ingredientID = int(tokens[0]);
      int amount = int(tokens[1]);
      didReceiveFillLevel(ingredientID, amount);
      break;
    case 'E':
      // TODO
      // E1=falscher index  
      // E2=zu hoher amount 
      // E3=über max fill level auffüllen
    case '#':
      println(line);
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
    case 'c':
      if (DEBUG_SIMULATE_MIXING && 
          state == QueerbotState.MIXING && mixingInProgress) {
        mixNextIngredient();
      } else {
        confirmButtonPressed();
      }
      break;
    case 'm': maintenanceButtonPressed(); break;
  }
}