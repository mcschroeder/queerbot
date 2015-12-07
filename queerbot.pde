Model model;
View view;

void settings() {
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
}

void setup() {
  ellipseMode(CENTER);
  view = new View();
  model = new Model("ingredients.csv");
  view.update(model);  
}

void draw() {
  float pos = map(mouseX, 0, 1, CANVAS_LEFT, CANVAS_RIGHT);
  view.updateCursor(pos);
  
  view.draw();
  
  
  //drawCursor(model, mouseX);
  
}



void keyPressed() {
  if (key == 's') {
    select();
  } else if (key == 'c') {
    confirm();
  } else if (key == 'd') {
   
  }
}


void select() {
  
}

void confirm() {
  
}


int clamp(int n, int min, int max) {
  return n < min ? min : n > max ? max : n;
}