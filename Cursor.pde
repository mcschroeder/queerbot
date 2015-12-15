import java.util.*;

class Cursor {
  
  // constants
  final Model model;
  
  // variables
  int x = 0;
  int drawingX = 0;  // to make sure background and foreground are in lock-step
  boolean hidden = false;
    
  Cursor(Model model) {
    this.model = model;
    update(0);
  }  
  
  void update(int x) {
    x = constrain(x, CANVAS_LEFT, CANVAS_RIGHT);
    this.x = clampToRanges(x, model.rangesForUncoveredSections);
  }
    
  void drawBackground() {
    drawingX = x;
    if (hidden) return;    
    fill(255);
    rect(drawingX-20, CANVAS_TOP, 40, CANVAS_BOTTOM-CANVAS_TOP);  
  }
  
  void drawForeground() {
    if (hidden) return;
    noFill();
    strokeWeight(10);
    stroke(127);
    rect(drawingX-20, CANVAS_TOP, 40, CANVAS_BOTTOM-CANVAS_TOP);  
  }
}

Selection getSelection(int x, Model model) {
  for (Section section : model.sections) {
    if (x >= section.leftX && x <= section.rightX) {
      float[] amounts = new float[model.ingredients.length];
      for (int i = 0; i < model.ingredients.length; i++) {
        amounts[i] = model.ingredients[i].getAmount(x);
      }
      return new Selection(section, amounts, x);
    }
  }
  return null;
}  

///////////////////////////////////////////////////////////////////////////////

class Range {
  int begin;
  int end;
  
  int distanceTo(int x) {
    if (x < begin) {
      return begin - x;
    } else if (x > end) {
      return x - end;
    } else {
      return 0;
    }
  }
  
  String toString() {
    return "["+begin+","+end+"]";
  }
}

int clampToRanges(int x, Set<Range> ranges) {
  Range forcedRange = null;
  int clampedX = x;
  for (Range range : ranges) {
    if (x < range.begin) {
      if (forcedRange == null || forcedRange.distanceTo(x) > range.distanceTo(x)) {
        forcedRange = range;
        clampedX = range.begin;
      }
    } else if (x > range.end) {
      if (forcedRange == null || forcedRange.distanceTo(x) > range.distanceTo(x)) {
        forcedRange = range;
        clampedX = range.end;
      }
    } else {
      return x;
    }
  }
  return clampedX;
}