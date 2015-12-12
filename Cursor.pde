import java.util.*;

class Cursor {
  
  // constants
  final PImage hand;
  final Model model;
  
  // variables
  int x = 0;
  boolean hidden = false;
    
  Cursor(Model model) {
    this.hand = loadImage("hand.jpg");
    this.model = model;
    update(0);
  }  
  
  void update(int x) {
    x = clamp(x, CANVAS_LEFT, CANVAS_RIGHT);
    this.x = clampToRanges(x, model.rangesForUncoveredSections);
  }
  
  void draw() {
    if (hidden) return;
    strokeWeight(1);
    stroke(255,0,0);
    line(x, CANVAS_TOP, x, CANVAS_BOTTOM);  
    imageMode(CENTER);
    image(hand, x, CANVAS_BOTTOM + (hand.height/2) + 50);    
  }
  
  Selection getSelection() {
    for (Section section : model.sections) {
      if (x >= section.leftX && x <= section.rightX) {
        float[] amounts = section.getAmounts(x);
        return new Selection(section, amounts);
      }
    }
    return null;
  }  
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