import java.util.concurrent.*;

class Section {
  
  // constants
  final int index;  
  final String name;    
  final int width;
  final int leftX;
  final int centerX;
  final int rightX;

  // variables
  final float[] significantAmounts;  // one percentage amount per ingredient
  int count = 0;  // how often was this section selected
  boolean covered = true;
  boolean selected = false;
  boolean highlighted = false;
  
  final ConcurrentLinkedQueue<PVector> history;  // absolute pixels

  Section(int index, String name, int numSections, int numIngredients) {
    this.index = index;
    this.name = name;
    this.significantAmounts = new float[numIngredients];
    this.width = CANVAS_WIDTH/numSections;
    this.leftX = (int)map(index, 0, numSections-1, CANVAS_LEFT, CANVAS_RIGHT-width);
    this.centerX = leftX + width/2;
    this.rightX = leftX + width;   
    this.history = new ConcurrentLinkedQueue<PVector>();
  }
  
  void drawBackground() {
    if (!covered) {
      if (this.index > 0) {
        noFill();
        stroke(255, 60);
        strokeWeight(1);        
        line(this.leftX, CANVAS_TOP, this.leftX, height); 
      }
    }
  }
      
  void drawForeground() {
    if (covered) {
      noStroke();
      fill(BACKGROUND_COLOR);
      rect(leftX, CANVAS_TOP, width, CANVAS_HEIGHT);      
    }
  }
    
  void drawLabel() {       
    if (covered && !DEBUG_SHOW_INFO_FOR_COVERED_SECTIONS) {
      return;
    }        
    fill(255);
    textSize(24);
    textAlign(CENTER,TOP);
    text(name, centerX, HISTORY_TOP+10);
    
    for (PVector p : history) {
      noFill();
      color c = rainbowColor(p.x);
      stroke(c);
      strokeWeight(8);
      //strokeWeight(1);
      //line(p.x, p.y, p.x, p.y);
      point(p.x, p.y);
    }    
  }
  
  void addToHistory(int x) {
    assert x >= this.leftX && x <= this.rightX;
    float y = random(RAINBOW_TOP, RAINBOW_BOTTOM);
    history.add(new PVector(x, y));
  }
  
}

color[] rainbow = {
  color(255,0,0),
  color(255,119,0),
  color(255,221,0),
  color(0,255,0),
  color(0,0,255),
  color(138,43,226),
  color(199,125,243)
};

color rainbowColor(float x) {
  // TODO
  return rainbow[0];
}