import java.util.concurrent.*;

class Section {
  
  // constants
  final int index;  
  final String name;    
  final int sectionWidth;
  final int leftX;
  final int centerX;
  final int rightX;

  final String SECTION_STATE_FILE_PREFIX = "state/section";
  final String sectionStateFile;

  // variables
  final float[] significantAmounts;  // one percentage amount per ingredient
  int count = 0;  // how often was this section selected
  private boolean _covered = true;
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
    
    this.sectionStateFile = SECTION_STATE_FILE_PREFIX+index;
    if (DEBUG_BEGIN_WITH_ALL_SECTIONS_UNCOVERED) {
      _covered = false;
    } else {
      String[] sectionState = loadStrings(sectionStateFile);
      if (sectionState == null) {
         _covered = !(index == 0 || index == numSections-1);
      } else {
        if (sectionState.length >= 1) {
          _covered = boolean(sectionState[0]);
        }
      }
    }
  }
  
  void setCovered(boolean covered) {
    _covered = covered;
    saveStrings(sectionStateFile, new String[] { str(_covered) });
  }
  
  boolean isCovered() {
    return _covered;
  }
  
  void drawForeground() {
    if (_covered) {
      noStroke();
      fill(BACKGROUND_COLOR);
      rect(leftX, CANVAS_TOP, sectionWidth, SCREEN_HEIGHT-CANVAS_TOP);
    }
  }
    
  void drawLabel() {       
    if (_covered) {
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
