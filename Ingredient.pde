class Ingredient {
  
  // constants  
  final int index;
  final String name;  
    
  // variables
  final PVector[] controlPoints;  // spline control points, absolute pixel scale
  final float[] yValues;  // absolute pixel scale, indexed from 0=CANVAS_LEFT to CANVAS_WIDTH-1
  color strokeColor;
  int strokeWeight = 5;
  boolean displayOnRightSide = false;
  int fillLevel = 0;  // in milliliters
  
  Ingredient(int index, String name, int numSections) {
    this.index = index;
    this.name = name;
    this.controlPoints = new PVector[numSections+2];
    for (int i = 0; i < controlPoints.length; i++) {
      controlPoints[i] = new PVector();
    }
    this.yValues = new float[SCREEN_WIDTH];
    this.strokeColor = INGREDIENT_COLORS[this.index];    
  }
  
  void setSignificantPoints(Section[] sections) {
    for (Section section : sections) {
      PVector p = controlPoints[section.index+1];
      float amount = section.significantAmounts[this.index];
      p.y = map(amount, 1, 0, CANVAS_TOP, CANVAS_BOTTOM);
      if (section.index == 0) {
        p.x = section.leftX;
      } else if (section.index == sections.length-1) {
        p.x = section.rightX;
      } else {
        p.x = section.centerX;
      }
    }
    controlPoints[0] = controlPoints[1];
    controlPoints[controlPoints.length-1] = controlPoints[controlPoints.length-2];    
    
    PVector[] points = spline(controlPoints, SCREEN_WIDTH/sections.length);
    HashMap<Integer,Float> pointMap = new HashMap();
    for (PVector point : points) {
      pointMap.put(new Integer((int)point.x), new Float(point.y));
    }
    for (int i = 0; i < SCREEN_WIDTH; i++) {
      Float y = pointMap.get(new Integer(i));
      if (y == null) {
        this.yValues[i] = i == 0 ? 0 : this.yValues[i-1];
      } else {
        this.yValues[i] = y.floatValue();
      }
    }    
  }
    
  // x = absolute pixel scale
  // return = percentage amount
  float getAmount(int x) {
    x = (int)map(x, 0, SCREEN_WIDTH, 0, yValues.length);    
    x = constrain(x, 0, yValues.length-1);
    float y = this.yValues[x];
    y = map(y, CANVAS_TOP, CANVAS_BOTTOM, 1, 0);
    y = constrain(y, 0, 1);
    return y;
  }
  
  void drawCurve() {
    noFill();
    strokeWeight(this.strokeWeight);
    stroke(this.strokeColor);
    beginShape();
    for (PVector p : controlPoints) {
      curveVertex(p.x, p.y);
    }
    endShape();
    
    /*
    strokeWeight(1);
    stroke(255,0,0);
    for (int i = 0; i < CANVAS_WIDTH; i++) {
      point(CANVAS_LEFT+i, this.yValues[i]);
    }
    */
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