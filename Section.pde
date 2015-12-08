class Section {
  
  // constants
  final int index;  
  final String name;    
  final int width;
  final int leftX;
  final int centerX;
  final int rightX;

  // variables
  final float[] significantAmounts;  // one amount per ingredient
  int count = 0;  // how often was this section selected
  boolean covered = true;
  boolean selected = false;
  boolean highlighted = false;

  Section(int index, String name, int numSections, int numIngredients) {
    this.index = index;
    this.name = name;
    this.significantAmounts = new float[numIngredients];
    this.width = CANVAS_WIDTH/numSections;
    this.leftX = (int)map(index, 0, numSections-1, CANVAS_LEFT, CANVAS_RIGHT-width);
    this.centerX = leftX + width/2;
    this.rightX = leftX + width;    
  }
      
  void drawBackground() {
    if (highlighted) {
      noStroke();
      fill(100,100,200,127);
      rect(leftX, CANVAS_TOP, width, CANVAS_HEIGHT);      
    }
  }
  
  void drawForeground() {
    if (covered) {
      noStroke();
      fill(0);
      rect(leftX, CANVAS_TOP, width, CANVAS_HEIGHT);      
    }
  }
  
  void drawLabel() {
    if (covered) {
      return;
    }
    fill(255);
    textSize(24);
    textAlign(LEFT,BASELINE);
    text(name, centerX, CANVAS_BOTTOM + 33);    
  }

}