class Ingredient {
  
  // constants  
  final int index;
  final String name;  
    
  // variables
  final PVector[] significantPoints;  // one point per section
  PVector[] points;  // one point per pixel, from CANVAS_LEFT to CANVAS_RIGHT
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
    this.points = new PVector[0];
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
    calculatePoints();    
  }
  
  // TODO: allocate PVectors on construction, modify spline() to update in-place?
  private void calculatePoints() {
    PVector[] controlPoints = new PVector[significantPoints.length+2];
    controlPoints[0] = significantPoints[0];
    for (int i = 1; i < controlPoints.length-1; i++) {
      controlPoints[i] = significantPoints[i-1];
    }
    controlPoints[controlPoints.length-1] = significantPoints[significantPoints.length-1];
    this.points = spline(controlPoints, CANVAS_WIDTH/significantPoints.length);
  }
  
  void drawCurve() {
    noFill();
    strokeWeight(this.strokeWeight);
    stroke(this.strokeColor);
    beginShape();
    for (int i = 0; i < points.length; i++) {
      PVector p = points[i];
      point(p.x, p.y);
    }
    /*
    for (int i = 0; i < significantPoints.length; i++) {
      PVector p = significantPoints[i];
      curveVertex(p.x, p.y);
      if (i == 0 || i == significantPoints.length-1) {
        curveVertex(p.x, p.y);
      }
    }
    */
    endShape();
  }
  
  void drawLabel() {
    fill(this.strokeColor);
    textSize(24);
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

PVector[] spline(PVector[] controlPoints, int resolution) {
  assert controlPoints.length >= 3;
  PVector[] points = new PVector[((controlPoints.length-1) * resolution) + 1];
  float increments = 1.0 / (float)resolution;
  for (int i = 0; i < controlPoints.length-1; i++) {
    PVector p0 = i == 0 ? controlPoints[i] : controlPoints[i-1];
    PVector p1 = controlPoints[i];
    PVector p2 = controlPoints[i+1];
    PVector p3 = i+2 == controlPoints.length ? controlPoints[i+1] : controlPoints[i+2];    
    for (int j = 0; j <= resolution; j++) {
      points[(i*resolution)+j] = catmullrom(p0, p1, p2, p3, j * increments); 
    }    
  }
  return points;
}

PVector catmullrom(PVector p0, PVector p1, PVector p2, PVector p3, float t) {
  return new PVector(catmullrom(p0.x, p1.x, p2.x, p3.x, t),
                     catmullrom(p0.y, p1.y, p2.y, p3.y, t));
}

float catmullrom(float p0, float p1, float p2, float p3, float t) {
  return 0.5f * ((2 * p1) + 
                 (p2 - p0) * t + 
                 (2*p0 - 5*p1 + 4*p2 - p3) * t * t +
                 (3*p1 -p0 - 3 * p2 + p3) * t * t * t);
}