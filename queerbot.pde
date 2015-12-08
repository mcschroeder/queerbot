final boolean DEBUG = true;

// constants
final int SCREEN_WIDTH = 720;
final int SCREEN_HEIGHT = 576;
final int CANVAS_LEFT = 100;
final int CANVAS_RIGHT = SCREEN_WIDTH-100;
final int CANVAS_TOP = 50;
final int CANVAS_BOTTOM = SCREEN_HEIGHT-200;
final int CANVAS_WIDTH = CANVAS_RIGHT - CANVAS_LEFT;
final int CANVAS_HEIGHT = CANVAS_BOTTOM - CANVAS_TOP;
final color[] INGREDIENT_COLORS = {
    color(255,0,0),
    color(0,255,0),
    color(0,0,255),
    color(127,127,0),
    color(0,127,127),
    color(127,0,127)
};

// variables
Model model;
Cursor cursor1;
Cursor cursor2;
Cursor activeCursor;
Selection activeDrink = null;
boolean mixing = false;

void settings() {
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
}

void setup() {
  ellipseMode(CENTER);
  model = new Model("ingredients.csv", "input.rules", "cover.rules");
  cursor1 = new Cursor(model);
  cursor2 = new Cursor(model);
  cursor2.hidden = true;
  activeCursor = cursor1;
}

void draw() {  
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
  
  if (mixing == true && activeDrink != null) {
    String msg = "MIXING DRINK " + activeDrink.section.name;
    textSize(26);
    float msgWidth = textWidth(msg);
    float msgHeight = textAscent() + textDescent();
    int padding = 5;    
    fill(255);
    rect(SCREEN_WIDTH/2 - msgWidth/2 - padding, 
         SCREEN_HEIGHT/2 - msgHeight/2 - padding/2, 
         msgWidth + padding*2, msgHeight + padding*2);        
    fill(0);
    textAlign(CENTER, CENTER);
    text(msg, SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
  }
  
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
  text(history, 0, SCREEN_HEIGHT-(textAscent()+textDescent()));
    
  for (Section section : model.sections) {
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

void mouseMoved() {
  if (activeCursor != null) {
    activeCursor.update(mouseX);
    updateHighlightedSections();
  }
}

void keyPressed() {
  if (key == 's') {
    select();
  } else if (key == 'c') {
    confirm();
  }
}

void select() {
  if (mixing) return;
  if (cursor1 == activeCursor) {
    activeCursor = cursor2;
    cursor2.hidden = false;
  } else if (cursor2 == activeCursor) {
    activeCursor = null;
  } else if (activeCursor == null) {
    activeCursor = cursor1;
    cursor2.hidden = true;
  }
  mouseMoved();
  updateSelectedSections();
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

void resetCursors() {
  cursor1.hidden = false;
  cursor2.hidden = true;
  activeCursor = cursor1;  
  mouseMoved();
  updateSelectedSections();
}

void confirm() {
  if (mixing) return;
  activeCursor = null;
  Selection selection1 = cursor1.getSelection();
  Selection selection2 = cursor2.hidden ? null : cursor2.getSelection();  
  activeDrink = model.update(selection1, selection2);
  for (Section section : model.sections) {
    section.selected = false;
    section.highlighted = false;
  }
  activeDrink.section.highlighted = true;
  activeDrink.section.selected = true;
  mixing = true;
  thread("mix");
}

void mix() {
  // TODO
  delay(1000);  
  mixing = false;
  activeDrink = null;
  resetCursors();
}