enum MaintenanceState {
  SELECTING_BOTTLE,
  SELECTING_ACTION
}

MaintenanceState _maint_state;
int _maint_selectedBottle;
int _maint_selectedAction;
String[] _maint_actions = {"Mark Refilled", "Gimme Some!"};

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
    fill(120);
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
    
    float alpha = VIRGIN_MODE && ingredient.alcoholic ? 127 : 255;

    noStroke();    
    fill(ingredient.strokeColor, alpha);
    rect(x, y, w, h, 5, 5, 0, 0);    
        
    noStroke();
    fill(0);
    textAlign(LEFT, TOP);
    text(ingredient.name, x + INGREDIENT_TEXT_PADDING/2, y + 2);

    noStroke();
    fill(ingredient.strokeColor, alpha);
    rect(x, y+h+3, w, 200, 0, 0, 5, 5);
    float fillH = map(ingredient.getFillLevel(), 0, MAX_FILL_LEVEL, 200-6, 0);
    noStroke();
    fill(0);
    rect(x+3, y+h+6, w-6, fillH, 0, 0, 3, 3);
        
    noStroke();
    textSize(18);
    fill(255);
    textAlign(CENTER, TOP);
    text(ingredient.getFillLevel() + "ml", x + w/2, y+h+3+200+5);
    
    if (i == _maint_selectedBottle) {
      stroke(0);
      strokeWeight(2);
      fill(255);
      ellipseMode(CENTER);
      ellipse(x + w/2, y+h+100, 30, 30);

      if (_maint_state == MaintenanceState.SELECTING_ACTION) {
        drawMenu(_maint_actions, _maint_selectedAction, x + w/2, y+h+3+200+20);
      }
    }    
    
    x += w + margin;
  }  

  noLoop();
}

final int _maint_MENU_TOP_MARGIN = 40;
final int _maint_MENU_LEFT_MARGIN = 20;

void drawMenu(String[] items, int selectedIndex, float centerX, float topY) {
  textSize(24);
  float y = topY + _maint_MENU_TOP_MARGIN;
  for (int i = 0; i < items.length; i++) {
    String item = items[i];
    float x = max(_maint_MENU_LEFT_MARGIN, centerX - textWidth(item)/2);
    x = min(x, SCREEN_WIDTH-_maint_MENU_LEFT_MARGIN-textWidth(item));
    if (i == selectedIndex) {
      noStroke();
      fill(255);
      rect(x-6, y - 3, textWidth(item)+12, textAscent()+textDescent()+6, 5, 5, 5, 5);
      fill(0);
    } else {
      fill(255);
    }
    textAlign(LEFT, TOP);
    text(item, x, y);

    y += textAscent()+textDescent()+20;
  }
}

void _maint_moveCursor(float x) {
  switch (_maint_state) {
    case SELECTING_BOTTLE:
      int index = (int)map(x, 0, 1, 0, model.ingredients.length);
      if (index >= model.ingredients.length) {
        index = model.ingredients.length-1;
      }
      _maint_selectedBottle = index;
      break;
    case SELECTING_ACTION: break;
  }
  redraw();
}

void _maint_select() {
  switch (_maint_state) {
    case SELECTING_BOTTLE:
      _maint_selectedAction = 0;
      _maint_state = MaintenanceState.SELECTING_ACTION;
      break;
    case SELECTING_ACTION:    
      _maint_selectedAction = (_maint_selectedAction+1);
      if (_maint_selectedAction == _maint_actions.length) {
        _maint_state = MaintenanceState.SELECTING_BOTTLE;
      }
      break;
  }
  analogValueChanged(analogValue);
  redraw();
}

void _maint_confirm() {
  switch (_maint_state) {
    case SELECTING_BOTTLE:
      VIRGIN_MODE = !VIRGIN_MODE;
      break;
    case SELECTING_ACTION:
      switch (_maint_selectedAction) {
        case 0: 
          sendFillLevel(_maint_selectedBottle, MAX_FILL_LEVEL);
          if (DEBUG_SIMULATE_MIXING) {
            didReceiveFillLevel(_maint_selectedBottle, MAX_FILL_LEVEL);
          }
          _maint_state = MaintenanceState.SELECTING_BOTTLE;
          break;
        case 1: 
          openValve(_maint_selectedBottle, CUP_SIZE);
          if (DEBUG_SIMULATE_MIXING) {
            int level = model.ingredients[_maint_selectedBottle].getFillLevel() - CUP_SIZE;
            didReceiveFillLevel(_maint_selectedBottle, level);
          }
          _maint_state = MaintenanceState.SELECTING_BOTTLE;
          break;
        default: break;
      }
      break;
  }  
  analogValueChanged(analogValue);
  redraw();
}

void gotoMaintenanceMode() {
  state = QueerbotState.MAINTENANCE;
  _maint_state = MaintenanceState.SELECTING_BOTTLE;
  analogValueChanged(analogValue);
  getStatus();
  redraw();
}