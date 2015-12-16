void drawSelectingInterface() {  
  assert (state == QueerbotState.SELECTING);  
  background(BACKGROUND_COLOR);
  drawLegend();
  for (Section section : model.sections) {
    section.drawBackground();
  }
  cursor1.drawBackground();
  cursor2.drawBackground();
  imageMode(CORNER);
  clip(0, CANVAS_TOP, SCREEN_WIDTH, CANVAS_HEIGHT);
  for (Ingredient ingredient : model.ingredients) {
    ingredient.drawCurve();
  }
  noClip();
  for (Section section : model.sections) {
    section.drawForeground();
    section.drawLabel();
  }
  cursor1.drawForeground();
  cursor2.drawForeground();
  model.history.drawMarks();
}

void drawLegend() {
  Selection activeSelection = activeCursor != null ? getSelection(activeCursor.x, model) : null;  
  int margin = getIngredientTextMargin();
  textAlign(LEFT,TOP);
  textSize(INGREDIENT_TEXT_SIZE);
  float h = textAscent()+textDescent()+5;
  int x = margin;
  int y = margin;
  for (int i = 0; i < model.ingredients.length; i++) {
    Ingredient ingredient = model.ingredients[i];    
    float w = textWidth(ingredient.name) + INGREDIENT_TEXT_PADDING;    
    float alpha = 255 * (activeSelection != null ? activeSelection.amounts[i] : 0);        
    noStroke();
    fill(ingredient.strokeColor, alpha);
    rect(x, y, w, h, 5, 5, 5, 5);    
    noStroke();
    fill(INGREDIENT_TEXT_COLOR);
    text(ingredient.name, x + INGREDIENT_TEXT_PADDING/2, y + 2);
    x += w + margin;
  }  
}

Integer _ingredientTextMargin = null;
int getIngredientTextMargin() {
  if (_ingredientTextMargin == null) {
    int total = 0;  
    textSize(INGREDIENT_TEXT_SIZE);  
    for (Ingredient ingredient : model.ingredients) {
      total += textWidth(ingredient.name) + INGREDIENT_TEXT_PADDING;
    }  
    _ingredientTextMargin = (SCREEN_WIDTH-total)/(model.ingredients.length+1);
  }
  return _ingredientTextMargin;
}

///////////////////////////////////////////////////////////////////////////////

void gotoSelecting() {
  state = QueerbotState.SELECTING;
  cursor1.hidden = false;
  cursor2.hidden = true;
  activeCursor = cursor1;
  updateSelectedSections();
  analogValueChanged(analogValue);  
}

void moveCursor(float pos) {
  assert state == QueerbotState.SELECTING;
  if (activeCursor == null) return;
  int x = (int)map(pos, 0, 1, 0, SCREEN_WIDTH);
  activeCursor.update(x);
  updateHighlightedSections();
  redraw();
}

void select() {
  assert state == QueerbotState.SELECTING;
  if (cursor1 == activeCursor) {
    activeCursor = cursor2;
    cursor2.x = cursor1.x;
    cursor2.hidden = false;    
  } else if (cursor2 == activeCursor) {
    activeCursor = null;
  } else if (activeCursor == null) {
    activeCursor = cursor1;
    cursor1.x = cursor2.x;
    cursor2.hidden = true;
  }
  updateHighlightedSections();
  updateSelectedSections();
  redraw();
}

void confirm() {
  assert state == QueerbotState.SELECTING;
  activeCursor = null;
  Selection selection1 = getSelection(cursor1.x, model);
  Selection selection2 = cursor2.hidden ? null : getSelection(cursor2.x, model);  
  Selection result = model.update(selection1, selection2);
  for (Section section : model.sections) {
    section.selected = false;
    section.highlighted = false;
  }
  result.section.highlighted = true;
  result.section.selected = true;
  gotoSelecting();
  //gotoMixing(result);
}

void updateSelectedSections() {
  for (Section section : model.sections) {
    section.selected = false;
  }
  if (cursor1 != activeCursor && !cursor1.hidden) {
    getSelection(cursor1.x, model).section.selected = true;
  }
  if (cursor2 != activeCursor && !cursor2.hidden) {
    getSelection(cursor2.x, model).section.selected = true;
  }
}

void updateHighlightedSections() {
  for (Section section : model.sections) {
    section.highlighted = false;
  }
  if (activeCursor != null) {
    getSelection(activeCursor.x, model).section.highlighted = true;
  }
}