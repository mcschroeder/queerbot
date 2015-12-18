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
  boolean raspberry = false;
  try {
    raspberry = (null != System.getenv("QUEERBOT_REVISION"));
  } catch (Exception e) {}
  if (raspberry) {
    fullScreen();
    DEBUG_SIMULATE_HARDWARE = false;
    DEBUG_SIMULATE_MIXING = false;
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

int _error_animationInterval = 100;  // in milliseconds
private int _error_prevMillis;
private int _error_rainbow_index = 0;

void drawErrorInterface() {
  background(0,0,255);
  
  int currentMillis = millis();
  if (currentMillis - _error_prevMillis >= _error_animationInterval) {
    _error_prevMillis = currentMillis;
    _error_rainbow_index = (_error_rainbow_index + 100);
  }
  
  for (int x = 0; x < SCREEN_HEIGHT; x++) {
    color c = gradient((x+_error_rainbow_index)%SCREEN_HEIGHT, 0, SCREEN_HEIGHT, RAINBOW_COLORS) + _error_rainbow_index;
    stroke(c);
    noFill();
    line(0, x, SCREEN_WIDTH, x);
  }
  
  textAlign(CENTER, CENTER);
  int size = 50;
  textSize(size);
  while (textWidth(_errorMsg) > SCREEN_WIDTH-50) {
    textSize(size--);
  }
    
  noStroke();
  fill(0);
  rectMode(CENTER);
  rect(SCREEN_WIDTH/2, SCREEN_HEIGHT/2, textWidth(_errorMsg)+20, textAscent()+textDescent()+20);
  rectMode(CORNER);
  fill(255);
  text(_errorMsg, SCREEN_WIDTH/2, SCREEN_HEIGHT/2-3);
  
  loop();
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
    case MAINTENANCE: gotoSelecting(); break;
    default: gotoMaintenanceMode(); break;
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
  if (DEBUG_SIMULATE_MIXING) return;
  port.write(cmd);
}

///////////////////////////////////////////////////////////////////////////////

void serialEvent(Serial port) {
  String line = port.readString();
  if (DEBUG_LOG_HARDWARE && hwLogWriter != null) {
    hwLogWriter.print(">");
    hwLogWriter.print(line);
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
      String msg = line; 
      if (line.length() > 1) {
        int code = int(line.substring(1));
        switch (code) {
          case 1: line += "wrong index"; break;
          case 2: line += "amount too high"; break;
          case 3: line += "fill level beyond limit"; break;
          default: break;
        }
      }
      gotoError(msg);
      break;
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
        int level = model.ingredients[currentMixIndex].fillLevel - currentMixAmount; 
        didReceiveFillLevel(currentMixIndex, level);
      } else {
        confirmButtonPressed();
      }
      break;
    case 'm': maintenanceButtonPressed(); break;
    case CODED:
      switch (keyCode) {
        case LEFT: analogValueChanged(constrain(analogValue-.1, 0, 1)); break;
        case RIGHT: analogValueChanged(constrain(analogValue+.1, 0, 1)); break;
        default: break;
      }
    default: break;
  }
}