import java.util.*;

class Cursor {
  
  // constants
  final Model model;
  
  // variables
  int x = 0;
  int drawingX = 0;  // to make sure background and foreground are in lock-step
  boolean hidden = false;
  
  float amountFilled = 0.3;
  float currentlyFilling = 0.2;
    
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
         
    float amountFilledTop = map(amountFilled, 0, 1, 0, CANVAS_HEIGHT-3);
    float currentlyFillingTop = map(amountFilled+currentlyFilling, 0, 1, 0, CANVAS_HEIGHT-3);
    color c = gradient(this.x, 0, SCREEN_WIDTH, RAINBOW_COLORS);
    if (blink) {
      fill(c);
      rect(drawingX-(CURSOR_WIDTH/2), amountFilledTop, CURSOR_WIDTH, CANVAS_BOTTOM-amountFilledTop);
    }    
    if (millis() - lastTime >= 200) {
      lastTime = millis();
      blink = !blink;
    }

    
  }
  
  boolean blink = false;
  int lastTime;
    
  void drawForeground() {
    if (hidden) return;



    noFill();
    strokeWeight(10);
    stroke(CURSOR_FOREGROUND_COLOR);
    rect(drawingX-(CURSOR_WIDTH/2), CANVAS_TOP, CURSOR_WIDTH, CANVAS_BOTTOM-CANVAS_TOP, 
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