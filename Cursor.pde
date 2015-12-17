import java.util.*;

class Cursor {
  
  // constants
  final Model model;
  
  // variables
  int x = 0;
  int drawingX = 0;  // to make sure background and foreground are in lock-step
  boolean hidden = false;
    
  float fillLevel = 0;  // 0 to 1
  float fillToLevel = 0;  // 0 to 1
  int blinkInterval = 100;  // in milliseconds
  private int _prevMillis;
  private boolean _blink;
  
  Cursor(Model model) {
    this.model = model;
    update(0);
  }  
  
  void update(int x) {
    this.x = clampToRanges(x, model.rangesForUncoveredSections);
  }
  
  void drawBackground() {
    drawingX = x;
    if (hidden) return;
    noStroke();
    fill(CURSOR_BACKGROUND_COLOR);
    rect(drawingX-(CURSOR_WIDTH/2), CANVAS_TOP, CURSOR_WIDTH, CANVAS_BOTTOM-CANVAS_TOP, 
         (CURSOR_WIDTH/2), (CURSOR_WIDTH/2), (CURSOR_WIDTH/2), (CURSOR_WIDTH/2));    
  }
  
  void drawForeground() {
    if (hidden) return;
    int x = drawingX-(CURSOR_WIDTH/2);
    
    color c = gradient(drawingX, 0, SCREEN_WIDTH, RAINBOW_COLORS);
    if (fillLevel > 0) {
      float y = map(fillLevel, 0, 1, CANVAS_BOTTOM-3, CANVAS_TOP+3);
      noStroke();
      fill(c);
      rect(x, y, CURSOR_WIDTH, CANVAS_BOTTOM-3-y);
    }
    if (fillToLevel - fillLevel > 0) {
      int currentMillis = millis();
      if (currentMillis - _prevMillis >= blinkInterval) {
        _prevMillis = currentMillis;
        _blink = !_blink;
      }
      if (!_blink) {
        float y = map(fillToLevel, 0, 1, CANVAS_BOTTOM-3, CANVAS_TOP+3);
        noStroke();
        fill(c);
        rect(x, y, CURSOR_WIDTH, CANVAS_BOTTOM-3-y);
      }
    }

    noFill();
    strokeWeight(10);
    stroke(CURSOR_FOREGROUND_COLOR);
    rect(x, CANVAS_TOP, CURSOR_WIDTH, CANVAS_BOTTOM-CANVAS_TOP, 
         (CURSOR_WIDTH/2), (CURSOR_WIDTH/2), (CURSOR_WIDTH/2), (CURSOR_WIDTH/2));
  }
  
  void clipArea() {
    clip(drawingX-(CURSOR_WIDTH/2), CANVAS_TOP, CURSOR_WIDTH, CANVAS_BOTTOM-CANVAS_TOP);
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