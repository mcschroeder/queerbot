enum MaintenanceState {
  SELECTING_BOTTLE,
  SELECTING_ACTION
}

MaintenanceState _maint_state;
int _maint_selectedBottle;
int _maint_selectedAction;

void drawMaintenanceInterface() {
  assert state == QueerbotState.MAINTENANCE;  
  background(0);
    
  String rev = null;
  try {
    rev = System.getenv("QUEERBOT_REVISION");
  } catch (Exception e) {}
  rev = "23343ffg";
  if (rev != null) {
    textSize(12);
    textAlign(LEFT,BOTTOM);
    fill(42);
    text(rev, 10, SCREEN_HEIGHT-10);
  }
  
  int margin = getIngredientTextMargin();
  textAlign(LEFT,TOP);
  textSize(INGREDIENT_TEXT_SIZE);
  float h = textAscent()+textDescent()+5;
  int x = margin;
  int y = margin;
  for (int i = 0; i < model.ingredients.length; i++) {
    Ingredient ingredient = model.ingredients[i];
    textSize(INGREDIENT_TEXT_SIZE);
    float w = textWidth(ingredient.name) + INGREDIENT_TEXT_PADDING;        
        
    noStroke();    
    fill(ingredient.strokeColor);
    rect(x, y, w, h, 5, 5, 0, 0);    
        
    noStroke();
    fill(0);
    textAlign(LEFT, TOP);
    text(ingredient.name, x + INGREDIENT_TEXT_PADDING/2, y + 2);

    noStroke();
    fill(ingredient.strokeColor);
    rect(x, y+h+3, w, 200, 0, 0, 5, 5);
    float fillH = map(ingredient.fillLevel, 0, MAX_FILL_LEVEL, 200-6, 0);
    noStroke();
    fill(0);
    rect(x+3, y+h+6, w-6, fillH, 0, 0, 3, 3);
        
    noStroke();
    textSize(18);
    fill(255);
    textAlign(CENTER, TOP);
    text(ingredient.fillLevel + "ml", x + w/2, y+h+3+200+5);
    
    if (i == _maint_selectedBottle) {
      stroke(0);
      strokeWeight(2);
      fill(255);
      ellipseMode(CENTER);
      ellipse(x + w/2, y+h+100, 30, 30);
    }
    
    x += w + margin;
  }  
  
  if (_maint_state == MaintenanceState.SELECTING_ACTION) {
    String[] items = {"Mark Refilled", "Gimme Some!"}; 
    drawMenu(items, _maint_selectedAction, 400);
  }  
  
  noLoop();
}

void drawMenu(String[] items, int selectedIndex, int y) {
  int MENU_PADDING = 60;
  textSize(24);
  float menuWidth = 0;
  for (String item : items) {
    menuWidth += textWidth(item) + MENU_PADDING;
  }
  menuWidth -= MENU_PADDING;
  
  textAlign(LEFT, TOP);
  float x = SCREEN_WIDTH/2 - menuWidth/2;
  for (int i = 0; i < items.length; i++) {
    String item = items[i];
    
    if (i == selectedIndex) {
      noStroke();
      fill(255);
      rect(x-6, y - 3, textWidth(item)+12, textAscent()+textDescent()+6, 5, 5, 5, 5);
      fill(0);
    } else {
      fill(255);
    }    
    text(item, x, y);
    x += textWidth(item) + MENU_PADDING;    
  }
}

void _maint_moveCursor(float x) {
  switch (_maint_state) {
    case SELECTING_BOTTLE:
      _maint_selectedBottle = (int)map(x, 0, 1, 0, model.ingredients.length);
      break;
    case SELECTING_ACTION:
      _maint_selectedAction = (int)map(x, 0, 1, 0, 2);
  }  
  redraw();
}

void _maint_select() {
  switch (_maint_state) {
    case SELECTING_BOTTLE:
      _maint_state = MaintenanceState.SELECTING_ACTION;
      break;
    case SELECTING_ACTION:
      _maint_state = MaintenanceState.SELECTING_BOTTLE;
      break;
    default:
      break;
  }
  redraw();
}

void _maint_confirm() {
  switch (_maint_state) {
    case SELECTING_ACTION:
      switch (_maint_selectedAction) {
        case 0: 
          setFillLevel(_maint_selectedBottle, MAX_FILL_LEVEL);
          if (DEBUG_SIMULATE_MIXING) {
            didReceiveFillLevel(_maint_selectedBottle, MAX_FILL_LEVEL);
          }
          break;
        case 1: 
          openValve(_maint_selectedBottle, CUP_SIZE);
          if (DEBUG_SIMULATE_MIXING) {
            int level = model.ingredients[_maint_selectedBottle].fillLevel - CUP_SIZE;
            didReceiveFillLevel(_maint_selectedBottle, level);
          }
          break;
        default: break;
      }
      _maint_state = MaintenanceState.SELECTING_BOTTLE;
      break;
    default:
      break;
  }
  redraw();
}

void gotoMaintenanceMode() {
  state = QueerbotState.MAINTENANCE;
  _maint_state = MaintenanceState.SELECTING_BOTTLE;
  redraw();
}