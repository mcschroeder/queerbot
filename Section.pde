import java.util.concurrent.*;

class Section {
  
  // constants
  final int index;  
  final String name;    
  final int sectionWidth;
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
    this.sectionWidth = SCREEN_WIDTH/numSections;
    this.leftX = (int)map(index, 0, numSections-1, 0, SCREEN_WIDTH-sectionWidth);
    this.centerX = leftX + sectionWidth/2;
    this.rightX = leftX + sectionWidth;
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
      rect(leftX, CANVAS_TOP, sectionWidth, CANVAS_HEIGHT);
    }
  }
    
  void drawLabel() {       
    if (covered && !DEBUG_SHOW_INFO_FOR_COVERED_SECTIONS) {
      return;
    }        
    fill(255);
    textSize(24);
    textAlign(CENTER,TOP);
    text(name, centerX, SECTION_LABELS_TOP);    
  }
}

color gradient(float x, float minX, float maxX, color[] colors) {
  float size = maxX - minX;
  float bucketSize = size/(colors.length-1);
  int i = (int)(x/bucketSize);
  color c1 = colors[i];
  color c2 = colors[min(i+1, colors.length-1)];
  float amt = (float) (x % bucketSize) / bucketSize;
  return lerpColor(c1, c2, amt);
}