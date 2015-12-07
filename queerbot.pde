import java.util.*;

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

color[] sectionColors = {
    color(125,0,0,125),
    color(0,125,0,125),
    color(0,0,125,125),
    color(127,255,0,125),
    color(0,255,127,125),
    color(127,0,255,125)
};


PImage hand; 

Model model;

void settings() {
  size(SCREEN_WIDTH, SCREEN_HEIGHT);
}

void setup() {
  ellipseMode(CENTER);  
  model = new Model("ingredients.csv");
  hand = loadImage("hand.jpg");
}

void draw() {
  background(color(0));

  //drawSections(model);
  drawCurves(model);
  drawSectionCovers(model);
  drawCanvas();
  drawSectionLabels(model);
  drawDrinkLabels(model);
  
  drawCursor(model, mouseX);
  drawAlertIfNeeded();
}


void drawSections(Model model) {  
  for (Section section : model.sections) {
    fill(sectionColors[section.index]);
    rect(section.leftX, CANVAS_TOP, section.width, CANVAS_HEIGHT);
  }  
}

void drawSectionCovers(Model model) {
  noStroke();
  fill(color(0));
  for (Section section : model.sections) {
    if (section.covered) {
      rect(section.leftX, CANVAS_TOP, section.width, CANVAS_HEIGHT);
    }
  }
}

void drawCurves(Model model) {
  noFill();
  strokeWeight(3);
  for (Ingredient ingredient : model.ingredients) {
    stroke(traitColors[ingredient.index]);
    beginShape();
    for (Section section : model.sections) {
      float y = map(section.significantAmounts.get(ingredient), 1, 0, CANVAS_TOP, CANVAS_BOTTOM);
      if (section.index == 0) {
        curveVertex(section.leftX, y);
        curveVertex(section.leftX, y);
      } else if (section.index == model.sections.length-1) {
        curveVertex(section.rightX, y);
        curveVertex(section.rightX, y);
      } else {
        curveVertex(section.centerX, y);
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
  for (Section section : model.sections) {
    text(section.name, section.centerX, CANVAS_BOTTOM + 33);
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
    float y = map(model.sections[sectionIndex].significantAmounts.get(ingredient), 1, 0, CANVAS_TOP, CANVAS_BOTTOM);
    text(ingredient.name, x, y);
  }
}

Section getSectionAt(int x, Model model) {
  for (Section section : model.sections) {
    if (section.leftX <= x && section.rightX >= x) {
      return section;
    }
  }
  return null;
}


int prevCursor = CANVAS_LEFT;

void drawCursor(Model model, int x) {
  Set<Hole> holes = makeHolesFromCoveredSections(model);  // TODO: this should be cached
  
  x = clamp(x, CANVAS_LEFT, CANVAS_RIGHT);
  x = avoidHoles(x, holes);
  if (x < CANVAS_LEFT || x > CANVAS_RIGHT) {
    return;  // everything is covered by holes
  }

  strokeWeight(1);
  stroke(color(255,0,0));
  line(x,CANVAS_TOP,x,CANVAS_BOTTOM);
  
  imageMode(CENTER);
  image(hand,x,CANVAS_BOTTOM+(hand.height/2)+50);
  
  prevCursor = x;  
}

class Hole {
  int begin;
  int end;
  public Hole(int begin, int end) {
    this.begin = begin;
    this.end = end;
  }
}

// note: this assumes the sections are ordered on the x axis and contiguous
Set<Hole> makeHolesFromCoveredSections(Model model) {
  Set<Hole> holes = new HashSet();
  Hole currentHole = null;
  for (Section section : model.sections) {
    if (section.covered) {
      if (currentHole == null) {
        currentHole = new Hole(section.leftX, section.rightX);
      } else {
        assert (currentHole.end == section.leftX);
        currentHole.end = section.rightX;
      }
    } else {
      if (currentHole != null) {
        holes.add(currentHole);
        currentHole = null;
      }
    }
  }
  return holes;
}

int avoidHoles(int x, Set<Hole> holes) {
  for (Hole hole : holes) {
    if (x >= hole.begin && x <= hole.end) {
      if (x < (hole.begin + (hole.end-hole.begin)/2)) {
        return hole.begin-1;
      } else {
        return hole.end+1;
      }
    }
  }
  return x;   
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


int clamp(int n, int min, int max) {
  return n < min ? min : n > max ? max : n;
}