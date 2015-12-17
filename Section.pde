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
  
  void drawForeground() {
    if (covered) {
      noStroke();
      fill(BACKGROUND_COLOR);
      rect(leftX, CANVAS_TOP, sectionWidth, SCREEN_HEIGHT-CANVAS_TOP);
    }
  }
    
  void drawLabel() {       
    if (covered) {
      return;
    }
    
    if (selected || highlighted) {
      noStroke();
      fill(255);
      rectMode(CORNER);
      float w = textWidth(name)+20;
      float h = textAscent()+textDescent()+5;
      rect(centerX-w/2, SECTION_LABELS_TOP-2, w, h, 5,5,5,5);
      fill(0);
    } else {
      fill(255);
    }
    //fill(255, dimmed ? 100 : 255);
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