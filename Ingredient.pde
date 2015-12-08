class Ingredient {
  
  // constants  
  final int index;
  final String name;  
    
  // variables
  final PVector[] significantPoints;  // one point per section
  color strokeColor;
  int strokeWeight = 3;
  boolean displayOnRightSide = false;
  float fillLevel = 0;  // 0-1
  
  Ingredient(int index, String name, int numSections) {
    this.index = index;
    this.name = name;    
    this.significantPoints = new PVector[numSections];
    for (int i = 0; i < significantPoints.length; i++) {
      significantPoints[i] = new PVector();
    }
    this.strokeColor = INGREDIENT_COLORS[this.index];
  }
  
  void updateSignificantPoints(Section section) {
    PVector p = significantPoints[section.index];
    float amount = section.significantAmounts[this.index];
    p.y = map(amount, 1, 0, CANVAS_TOP, CANVAS_BOTTOM);
    if (section.index == 0) {
      p.x = section.leftX;
    } else if (section.index == significantPoints.length-1) {
      p.x = section.rightX;
    } else {
      p.x = section.centerX;
    }
  }
  
  void drawCurve() {
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