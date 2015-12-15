void drawSelectingInterface() {  
  assert (state == QueerbotState.SELECTING);
  
  background(BACKGROUND_COLOR);  
  drawLegend();
  cursor1.drawBackground();
  cursor2.drawBackground();
  drawCurves();
  cursor1.drawForeground();
  cursor2.drawForeground();
  for (Section section : model.sections) {
    section.drawForeground();
    section.drawLabel();
  }
}

void drawLegend() {
  //noStroke();
  //fill(BACKGROUND_COLOR);
  //rect(0,0,width,LEGEND_BOTTOM);
  
  int totalLabelWidth = 0;
  
  textSize(24);  
  for (Ingredient ingredient : model.ingredients) {
    totalLabelWidth += textWidth(ingredient.name);
    totalLabelWidth += 20;  // rect
  }
  
  int leftover = width-totalLabelWidth;
  int margin = leftover/(model.ingredients.length+1);
  
  textAlign(LEFT,TOP);
  
  Selection activeSelection = getSelection(activeCursor.x, model);
  
  int x = margin;
  int i = 0;
  for (Ingredient ingredient : model.ingredients) {
    float tWidth = textWidth(ingredient.name);
    float tHeight = textAscent()+textDescent();
        
    
    float amount = activeSelection.amounts[i++];
        
    noStroke();
    //stroke(ingredient.strokeColor);
    //strokeWeight(2);
    fill(ingredient.strokeColor, amount * 255);
    rect(x, 10, tWidth + 20, tHeight + 5, 5, 5, 5, 5);
    
    noStroke();
    fill(0);
    text(ingredient.name, x+10, 10+2);
    x += textWidth(ingredient.name) + 20 + margin;
  }
  
}

void drawCurves() {
  imageMode(CORNER);
  clip(CANVAS_LEFT, CANVAS_TOP+1, CANVAS_WIDTH, CANVAS_HEIGHT-1);
  for (Ingredient ingredient : model.ingredients) {
    ingredient.drawCurve();
  }
  noClip();
}
/*
void drawHistory() {
  Section[] historySections = new Section[model.drinkHistory.size()];
  int i = 0;
  for (Selection selection : model.drinkHistory) {
    historySections[i++] = selection.section;
  }
  
  String history = "";
  for (Section section : historySections) {
    history += section.name + " ";
  }
  fill(0);
  textSize(12);
  textAlign(LEFT,BASELINE);
  text(history, 0, height-(textAscent()+textDescent()));
    
  for (Section section : model.sections) {
    if (section.covered && !DEBUG_SHOW_INFO_FOR_COVERED_SECTIONS) {
      continue;
    }
    float count = 0;
    for (Section hs : historySections) {
      if (hs == section) count++; 
    }
    float percentage = historySections.length > 0 ? count/historySections.length : 0;
    fill(255,0,255);
    textSize(20);
    textAlign(CENTER,BASELINE);
    text(percentage, section.centerX, CANVAS_BOTTOM + 100);
  }  
}
*/

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
  int x = (int)map(pos, 0, 1, CANVAS_LEFT, CANVAS_RIGHT);
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
  gotoMixing(result);
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