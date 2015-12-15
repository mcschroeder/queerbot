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

  Section(int index, String name, int numSections, int numIngredients) {
    this.index = index;
    this.name = name;
    this.significantAmounts = new float[numIngredients];
    this.width = CANVAS_WIDTH/numSections;
    this.leftX = (int)map(index, 0, numSections-1, CANVAS_LEFT, CANVAS_RIGHT-width);
    this.centerX = leftX + width/2;
    this.rightX = leftX + width;    
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
    
    int x = centerX;    
    int y = HISTORY_TOP+(height-HISTORY_TOP)/2;    

    int radius = min(MAX_BUBBLE_RADIUS, MIN_BUBBLE_RADIUS + count);

    noStroke();
    if (highlighted || selected) {
      fill(100,100,200);
    } else {
      fill(255);
    }
    ellipseMode(RADIUS);
    ellipse(x, y, radius, radius);
    
    fill(0);
    textSize(radius/2);
    textAlign(CENTER,CENTER);
    text(name, x, y-2);
  }
  
}