void drawSelectingInterface() {
  assert (state == QueerbotState.SELECTING);  
  background(0); 
  for (Section section : model.sections) {
    section.drawBackground();
  }
  imageMode(CORNER);
  clip(CANVAS_LEFT, CANVAS_TOP, CANVAS_WIDTH, CANVAS_HEIGHT);
  for (Ingredient ingredient : model.ingredients) {
    ingredient.drawCurve();
  }
  noClip();
  for (Ingredient ingredient : model.ingredients) {
    ingredient.drawLabel();
  }  
  cursor1.draw();
  cursor2.draw();
  for (Section section : model.sections) {
    section.drawForeground();
    section.drawLabel();
  }  
  noFill();
  stroke(255);
  strokeWeight(3);
  rect(CANVAS_LEFT, CANVAS_TOP, CANVAS_WIDTH, CANVAS_HEIGHT);  

  drawHistory();
}

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
  fill(255);
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
  Selection selection1 = cursor1.getSelection();
  Selection selection2 = cursor2.hidden ? null : cursor2.getSelection();  
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
    cursor1.getSelection().section.selected = true;
  }
  if (cursor2 != activeCursor && !cursor2.hidden) {
    cursor2.getSelection().section.selected = true;
  }
}

void updateHighlightedSections() {
  for (Section section : model.sections) {
    section.highlighted = false;
  }
  if (activeCursor != null) {
    activeCursor.getSelection().section.highlighted = true;
  }
}