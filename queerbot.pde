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

void settings() {
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
}

void setup() {
  ellipseMode(CENTER);
  model = new Model("ingredients.csv");
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
  for (Ingredient ingredient : model.ingredients) {
    ingredient.drawCurve();
  }
  clipCanvas();
  for (Ingredient ingredient : model.ingredients) {
    ingredient.drawLabel();
  }
  for (Section section : model.sections) {
    section.drawForeground();
    section.drawLabel();
  }
  drawCanvas();

  cursor1.draw();
  cursor2.draw();
}

void clipCanvas() {
  noStroke();
  fill(0);
  rect(0, 0, SCREEN_WIDTH, CANVAS_TOP);
  rect(0, CANVAS_BOTTOM, SCREEN_WIDTH, SCREEN_HEIGHT-CANVAS_BOTTOM);
  rect(0, CANVAS_TOP, CANVAS_LEFT, CANVAS_HEIGHT);
  rect(CANVAS_RIGHT, CANVAS_TOP, SCREEN_WIDTH-CANVAS_LEFT, CANVAS_HEIGHT);
}

void drawCanvas() {
  noFill();
  stroke(255);
  strokeWeight(3);
  rect(CANVAS_LEFT, CANVAS_TOP, CANVAS_WIDTH, CANVAS_HEIGHT);  
}

void mouseMoved() {
  if (activeCursor != null) {
    activeCursor.update(mouseX);
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
}

void confirm() {
  activeCursor = null;
  Selection selection1 = cursor1.getSelection();
  Selection selection2 = cursor2.hidden ? null : cursor2.getSelection();  
  model.update(selection1, selection2);
}