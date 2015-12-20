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
  final float[] significantAmounts;  // one ml amount per ingredient
  boolean sigAmsReloaded = false;
  final float[] historicalAverage;  
  private int _count = 0;  // how often was this section selected
  private boolean _covered = true;
  boolean selected = false;
  boolean highlighted = false;  
  
  Section(int index, String name, int numSections, int numIngredients) {
    this.index = index;
    this.name = name;
    this.significantAmounts = new float[numIngredients];
    this.historicalAverage = new float[numIngredients];
    this.sectionWidth = SCREEN_WIDTH/numSections;
    this.leftX = (int)map(index, 0, numSections-1, 0, SCREEN_WIDTH-sectionWidth);
    this.centerX = leftX + sectionWidth/2;
    this.rightX = leftX + sectionWidth;
    
    this.sectionStateFile = SECTION_STATE_FILE_PREFIX+index;
    String[] sectionState = loadStrings(sectionStateFile);
    if (sectionState == null) {
      if (DEBUG_BEGIN_WITH_ALL_SECTIONS_UNCOVERED) {
        _covered = false;
      } else {
        _covered = !(index == 0 || index == numSections-1);
      }
    } else {
      if (DEBUG_BEGIN_WITH_ALL_SECTIONS_UNCOVERED) {
        _covered = false;
      } else {
        if (sectionState.length >= 1) {
          _covered = boolean(sectionState[0]);
        }
      }
      if (sectionState.length >= 2) {
        _count = int(sectionState[1]);
      }
      if (sectionState.length >= 3) {
        String[] sigAms = sectionState[2].split(",");
        if (sigAms.length == significantAmounts.length) { 
          for (int i = 0; i < sigAms.length; i++) {
            significantAmounts[i] = float(sigAms[i]);
          }
          sigAmsReloaded = true;
        }          
      }
      if (sectionState.length >= 4 && sigAmsReloaded) {
        String[] histAvgs = sectionState[3].split(",");
        if (histAvgs.length == historicalAverage.length) { 
          for (int i = 0; i < histAvgs.length; i++) {
            historicalAverage[i] = float(histAvgs[i]);
          }
        }
      }
    }
  }

  void saveState() {
    String sigAms = str(significantAmounts[0]);
    for (int i = 1; i < significantAmounts.length; i++) {
      sigAms += ","+str(significantAmounts[i]);
    }    
    String histAvgs = str(historicalAverage[0]);
    for (int i = 1; i < historicalAverage.length; i++) {
      histAvgs += ","+str(historicalAverage[i]);
    }
    String[] state = {str(_covered), str(_count), sigAms, histAvgs};
    saveStrings(sectionStateFile, state);
  }
  
  void setCovered(boolean covered) {
    _covered = covered;
    saveState();
  }
  
  boolean isCovered() {
    return _covered;
  }

  void incrementCount() {
    _count = _count + 1;
    saveState();
  }

  int getCount() {
    return _count;
  }

  void setSignificantAmounts(float[] amounts) {
    for (int i = 0; i < significantAmounts.length; i++) {
      significantAmounts[i] = amounts[i];
    }
    saveState();
  }

  void updateHistoricalAverage(float[] selectedAmounts) {
    for (int i = 0; i < historicalAverage.length; i++) {
      // print("hist="+historicalAverage[i]);
      historicalAverage[i] = (selectedAmounts[i] + _count * historicalAverage[i])/(_count + 1);
      // println(" a="+selectedAmounts[i]+" hist'="+historicalAverage[i]);
    }
    saveState();
  }
  
  void drawForeground() {
    if (_covered) {
      noStroke();
      fill(BACKGROUND_COLOR);
      rect(leftX, CANVAS_TOP, sectionWidth, CANVAS_HEIGHT);
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
