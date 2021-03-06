class Ingredient {
  
  // constants  
  final int index;
  final String name;
  final boolean alcoholic;

  // variables
  final PVector[] controlPoints;  // spline control points, absolute pixel scale
  final float[] yValues;  // absolute pixel scale, indexed from 0=CANVAS_LEFT to CANVAS_WIDTH-1
  float scaleFactor = 1;

  // absolute ml amounts, indexed from 0=CANVAS_LEFT to CANVAS_WIDTH-1
  final PVector[] amountControlPoints;
  final float[] interpolatedAmounts;

  color strokeColor = 255;
  int strokeWeight = 5;

  private int _fillLevel;  // in milliliters
  final String INGREDIENT_FILL_STATE_FILE_PREFIX = "state/fill";
  final String fillStateFile;
  
  Ingredient(int index, String name, int numSections, boolean alcoholic) {
    this.index = index;
    this.name = name;
    this.alcoholic = alcoholic;
    this.controlPoints = new PVector[numSections+2];
    this.amountControlPoints = new PVector[numSections+2];
    for (int i = 0; i < controlPoints.length; i++) {
      controlPoints[i] = new PVector();
      amountControlPoints[i] = new PVector();
    }
    this.yValues = new float[SCREEN_WIDTH];
    this.interpolatedAmounts = new float[SCREEN_WIDTH];
    _fillLevel = DEBUG_SIMULATE_MIXING ? MAX_FILL_LEVEL : 0;
    this.fillStateFile = INGREDIENT_FILL_STATE_FILE_PREFIX+index;
    String[] fillState = loadStrings(fillStateFile);
    if (fillState == null) {
      _fillLevel = 0;
    } else {
      if (fillState.length >= 1) {
        _fillLevel = int(fillState[0]);
        sendFillLevel(index, _fillLevel);        
      }
    }
  }
  
  void setSignificantPoints(Section[] sections) {
    interpolatePixels(sections);
    interpolateAmounts(sections);
  }

  void interpolatePixels(Section[] sections) {
    for (Section section : sections) {
      PVector p = controlPoints[section.index+1];
      float amount = section.significantAmounts[this.index];      
      p.y = map(amount*scaleFactor, CUP_SIZE, 0, CANVAS_TOP, CANVAS_BOTTOM);
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

    // interpolate amounts
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

  void interpolateAmounts(Section[] sections) {
    for (Section section : sections) {
      PVector p = amountControlPoints[section.index+1];
      float amount = section.significantAmounts[this.index];      
      p.y = amount;
      if (section.index == 0) {
        p.x = section.leftX;
      } else if (section.index == sections.length-1) {
        p.x = section.rightX;
      } else {
        p.x = section.centerX;
      }
    }
    amountControlPoints[0] = amountControlPoints[1];
    amountControlPoints[amountControlPoints.length-1] = amountControlPoints[amountControlPoints.length-2];    

    PVector[] points = spline(amountControlPoints, SCREEN_WIDTH/sections.length);
    HashMap<Integer,Float> pointMap = new HashMap();
    for (PVector point : points) {
      pointMap.put(new Integer((int)point.x), new Float(point.y));
    }
    for (int i = 0; i < SCREEN_WIDTH; i++) {
      Float y = pointMap.get(new Integer(i));
      if (y == null) {
        this.interpolatedAmounts[i] = i == 0 ? 0 : this.interpolatedAmounts[i-1];
      } else {
        this.interpolatedAmounts[i] = y.floatValue();
      }
    }
  }

  // x = absolute pixel scale
  // return = ml amount
  float getAmount(int x) {
    x = (int)map(x, 0, SCREEN_WIDTH, 0, interpolatedAmounts.length);
    x = constrain(x, 0, interpolatedAmounts.length-1);
    float a = this.interpolatedAmounts[x];
    if (a < MIN_AMOUNT) a = 0;
    if (a > CUP_SIZE) a = CUP_SIZE;
    return a;
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

  int getFillLevel() {
    return _fillLevel;
  }

  void setFillLevel(int level) {
    _fillLevel = level;
    saveStrings(fillStateFile, new String[]{str(_fillLevel)});
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