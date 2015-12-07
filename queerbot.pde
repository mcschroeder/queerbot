import java.util.Map;

int SCREEN_WIDTH = 720;
int SCREEN_HEIGHT = 576;

int CANVAS_LEFT = 100;
int CANVAS_RIGHT = SCREEN_WIDTH-100;
int CANVAS_TOP = 50;
int CANVAS_BOTTOM = SCREEN_HEIGHT-200;
int CANVAS_WIDTH = CANVAS_RIGHT - CANVAS_LEFT;
int CANVAS_HEIGHT = CANVAS_BOTTOM - CANVAS_TOP;

color[] traitColors = {
    color(255,0,0),
    color(0,255,0),
    color(0,0,255),
    color(127,127,0),
    color(0,127,127),
    color(127,0,127)
};

PImage hand; 

Model model;

void settings() {
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
}

void setup() {
  ellipseMode(CENTER);
  
  model = new Model("ingredients.csv");
  
  //table = loadTable("ingredients.csv", "header");
  //table.trim();
  hand = loadImage("hand.jpg");
}

void draw() {
  background(color(0));

  drawCurves(model);
  drawCanvas();
  drawSectionLabels(model);
  drawDrinkLabels(model);
  
  drawCursor(mouseX);
  drawAlertIfNeeded();
}

void drawCurves(Model model) {
  noFill();
  strokeWeight(3);
  int colorCounter = 0;
  for (Ingredient ingredient : model.ingredients) {
    stroke(traitColors[colorCounter++]);
    beginShape();
    int sectionIndex = 0;
    for (Section section : model.sections) {
      float x = map(sectionIndex++, 0, model.sections.length-1, CANVAS_LEFT, CANVAS_RIGHT);
      float y = map(section.percentages.get(ingredient), 1, 0, CANVAS_TOP, CANVAS_BOTTOM);
      curveVertex(x,y);
      if (sectionIndex == 1 || sectionIndex == model.sections.length) {
        curveVertex(x,y);
      }
    }
    endShape();
  }
}

void drawCanvas() {
  noStroke();
  fill(color(0));
  rect(0,CANVAS_BOTTOM,SCREEN_WIDTH,SCREEN_HEIGHT-CANVAS_BOTTOM-CANVAS_TOP);
  noFill();
  stroke(color(255));
  rect(CANVAS_LEFT, CANVAS_TOP, CANVAS_RIGHT-CANVAS_LEFT, CANVAS_BOTTOM-CANVAS_TOP);  
}

void drawSectionLabels(Model model) {
  fill(color(255));
  textSize(24);
  textAlign(LEFT,BASELINE);
  int sectionIndex = 0;
  for (Section section : model.sections) {
    float x = map(sectionIndex++, 0, model.sections.length-1, CANVAS_LEFT, CANVAS_RIGHT) - textWidth(section.name)/2;
    float y = CANVAS_BOTTOM + 33;
    text(section.name, x, y);
  }
}

void drawDrinkLabels(Model model) {
  fill(color(255));
  textAlign(LEFT,BASELINE);
  for (Ingredient ingredient : model.ingredients) {
    int sectionIndex; 
    float x;    
    if (ingredient.displayOnRightSide) {
      sectionIndex = model.sections.length - 1;
      x = CANVAS_RIGHT + 10;
    } else {
      sectionIndex = 0;
      x = CANVAS_LEFT - textWidth(ingredient.name)-10;
    }
    float y = map(model.sections[sectionIndex].percentages.get(ingredient), 1, 0, CANVAS_TOP, CANVAS_BOTTOM);
    text(ingredient.name, x, y);
  }
}



void drawCursor(int x) {
  x = clamp(x, CANVAS_LEFT, CANVAS_RIGHT);
  strokeWeight(1);
  stroke(color(255,0,0));
  line(x,CANVAS_TOP,x,CANVAS_BOTTOM);
  
  imageMode(CENTER);
  image(hand,x,CANVAS_BOTTOM+hand.width+10);
}



void highlightSection(int x) {
  float sectionWidth = CANVAS_WIDTH / (model.sections.length);
  int section = x % (int)sectionWidth;
  System.out.println(section);
}

void keyPressed() {
  if (key == 's') {
    select();
  } else if (key == 'c') {
    confirm();
  } else if (key == 'd') {
    dismissAlert();
  }
}


void select() {
  alert("selected");
}

void confirm() {
  alert("confirmed");
}




// Alert message

void alert(String message) {
  _message = message;
  _alerting = true;
}

void dismissAlert() {
  _alerting = false;
}

String _message = null;
boolean _alerting = false;

void drawAlertIfNeeded() {
  if (!_alerting || _message == null) {
    return;
  }
  
  fill(color(255,255,255,220));
  rect(CANVAS_LEFT, CANVAS_TOP, CANVAS_RIGHT-CANVAS_LEFT, CANVAS_BOTTOM-CANVAS_TOP);
  
  int x = CANVAS_LEFT+(CANVAS_WIDTH/2);
  int y = CANVAS_TOP+(CANVAS_HEIGHT/2);  

  textSize(32);
  textAlign(CENTER,CENTER);  
  fill(color(0,0,0));
  text(_message, x, y);  
}

int clamp(int n, int min, int max) {
  return n < min ? min : n > max ? max : n;
}