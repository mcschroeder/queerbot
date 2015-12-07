import java.util.*;

final int SCREEN_WIDTH = 720;
final int SCREEN_HEIGHT = 576;

final int CANVAS_LEFT = 100;
final int CANVAS_RIGHT = SCREEN_WIDTH-100;
final int CANVAS_TOP = 50;
final int CANVAS_BOTTOM = SCREEN_HEIGHT-200;
final int CANVAS_WIDTH = CANVAS_RIGHT - CANVAS_LEFT;
final int CANVAS_HEIGHT = CANVAS_BOTTOM - CANVAS_TOP;

final int INGREDIENT_STROKE_WEIGHT = 3;
final color[] INGREDIENT_COLORS = {
    color(255,0,0),
    color(0,255,0),
    color(0,0,255),
    color(127,127,0),
    color(0,127,127),
    color(127,0,127)
};

PImage HAND_IMAGE;

///////////////////////////////////////////////////////////////////////////////

class View {
  private IngredientCurve[] curves;
  private SectionRect[] sectionRects;
  
  View() {
    HAND_IMAGE = loadImage("hand.jpg");
  }
  
  void update(Model model) {
    sectionRects = new SectionRect[model.sections.length];
    for (int i = 0; i < model.sections.length; i++) {
      sectionRects[i] = new SectionRect(model.sections[i]);
    }
    curves = new IngredientCurve[model.ingredients.length];
    for (int i = 0; i < model.ingredients.length; i++) {
      curves[i] = new IngredientCurve(model.ingredients[i], sectionRects);
    }
    
  }
  
  void draw() {
    background(0);
    for (SectionRect sectionRect : sectionRects) {
      sectionRect.drawBackground();
    }
    for (IngredientCurve curve : curves) {
      curve.draw();
    }
    clipCanvas();
    for (IngredientCurve curve : curves) {
      curve.drawLabel();
    }
    for (SectionRect sectionRect : sectionRects) {
      sectionRect.drawOverlay();
    }
    drawCanvas();
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
  
  void updateCursor(float pos) {
    
  }
  
   
}

///////////////////////////////////////////////////////////////////////////////

class IngredientCurve {
  final String name;
  final color strokeColor;
  final int strokeWeight;
  final PVector[] significantPoints;
  final boolean displayOnRightSide;
  
  IngredientCurve(Ingredient ingredient, SectionRect[] sectionRects) {
    this.name = ingredient.name;
    this.strokeColor = INGREDIENT_COLORS[ingredient.index];
    this.strokeWeight = 3;
    this.significantPoints = new PVector[ingredient.model.sections.length];
    for (int i = 0; i < ingredient.model.sections.length; i++) {
      Section section = ingredient.model.sections[i];
      PVector p = new PVector();
      float amount = section.significantAmounts.get(ingredient);
      p.y = map(amount, 1, 0, CANVAS_TOP, CANVAS_BOTTOM);
      if (section.index == 0) {
        p.x = sectionRects[i].leftX;
      } else if (section.index == model.sections.length-1) {
        p.x = sectionRects[i].rightX;
      } else {
        p.x = sectionRects[i].centerX;
      }
      significantPoints[i] = p;
    }
    this.displayOnRightSide = ingredient.displayOnRightSide;
  }
  
  void draw() {
    noFill();
    strokeWeight(this.strokeWeight);
    stroke(this.strokeColor);
    beginShape();
    for (int i = 0; i < significantPoints.length; i++) {
      PVector p = significantPoints[i];
      curveVertex(p.x, p.y);
      if (i == 0 || i == significantPoints.length-1) {
        curveVertex(p.x, p.y);
      }
    }
    endShape();
  }
  
  void drawLabel() {
    fill(this.strokeColor);
    textAlign(LEFT,BASELINE);
    float x,y;
    if (displayOnRightSide) {
      x = CANVAS_RIGHT + 10;
      y = significantPoints[significantPoints.length-1].y;
    } else {
      x = CANVAS_LEFT - textWidth(name) - 10;
      y = significantPoints[0].y;
    }
    text(name, x, y);
  }
}

///////////////////////////////////////////////////////////////////////////////

enum SectionRectState {
  COVERED,
  UNCOVERED,
  HIGHLIGHTED  
}

class SectionRect {
  final String name;
  final int width;
  final int leftX;
  final int centerX;
  final int rightX;  
  
  SectionRectState state = SectionRectState.COVERED;
  
  SectionRect(Section section) {
    this.name = section.name;
    this.width = CANVAS_WIDTH/section.model.sections.length;
    this.leftX = (int)map(section.index, 0, section.model.sections.length-1, CANVAS_LEFT, CANVAS_RIGHT-width);
    this.centerX = leftX + width/2;
    this.rightX = leftX + width;
    this.state = section.covered ? SectionRectState.COVERED : SectionRectState.UNCOVERED;
  }
  
  void drawBackground() {
    if (this.state == SectionRectState.HIGHLIGHTED) {
        noStroke();
        fill(100,100,200,127);
        rect(leftX, CANVAS_TOP, width, CANVAS_HEIGHT);
    }
  }
  
  void drawOverlay() {
    if (this.state == SectionRectState.COVERED) {
        noStroke();
        fill(0);
        rect(leftX, CANVAS_TOP, width, CANVAS_HEIGHT);
    } else {
        fill(255);
        textSize(24);
        textAlign(LEFT,BASELINE);
        text(name, centerX, CANVAS_BOTTOM + 33);
    }
  }  
}

///////////////////////////////////////////////////////////////////////////////

class Cursor {
  boolean ghost = false;
  
  
}

///////////////////////////////////////////////////////////////////////////////
/*

Section getSectionAt(int x, Model model) {
  for (Section section : model.sections) {
    if (section.leftX <= x && section.rightX >= x) {
      return section;
    }
  }
  return null;
}
*/

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
  image(HAND_IMAGE,x,CANVAS_BOTTOM+(HAND_IMAGE.height/2)+50);
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