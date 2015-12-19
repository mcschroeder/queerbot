final Queue<PVector> ingredientsToMix = new LinkedList<PVector>();
int totalMixAmount, currentMixAmount, currentMixIndex;
boolean mixingInProgress = false;
Cursor mixingCursor = null;
Selection mixingDrink = null;

///////////////////////////////////////////////////////////////////////////////

void gotoMixing(Selection drink) {
  assert state == QueerbotState.SELECTING;
  assert drink != null;
  mixingDrink = drink;
  state = QueerbotState.MIXING;
  mixingCursor = new Cursor(model);
  mixingCursor.update(drink.x, false);
  mixingCursor.fillLevel = 0;
  mixingCursor.fillToLevel = 0;
  for (Section section : model.sections) {
    section.selected = false;
    section.highlighted = false;
  }
  mixingDrink.section.selected = true;
  loop();
  
  ingredientsToMix.clear();
  totalMixAmount = 0;
  for (int i = 0; i < mixingDrink.amounts.length; i++) {
    float amount = mixingDrink.amounts[i];
    if (amount > 0) {
      ingredientsToMix.add(new PVector(i, amount));
      totalMixAmount += amount;
    }
  }
  /*
  int[] absoluteAmounts = round(map(mixingDrink.amounts, CUP_SIZE));
  for (int i = 0; i < absoluteAmounts.length; i++) {
    int amount = absoluteAmounts[i];
    if (amount > 0) {
      ingredientsToMix.add(new PVector(i, amount));
    }
  }*/
  mixNextIngredient();
}

void drawMixingInterface() {
  assert state == QueerbotState.MIXING;
  assert mixingDrink != null;
  assert mixingCursor != null;
  
  background(0);
  rainbowBackground();
  
  //drawLegend(getSelection(mixingDrink.x, model));
  model.history.drawMark(mixingDrink.mark);
  mixingDrink.section.drawLabel();
  mixingCursor.drawBackground();
  mixingCursor.clipArea();
  for (Ingredient ingredient : model.ingredients) {
    ingredient.drawCurve();
  }
  noClip();
  mixingCursor.drawForeground();

  Ingredient ingredient = model.ingredients[currentMixIndex];

  textAlign(LEFT,TOP);
  textSize(INGREDIENT_TEXT_SIZE);
  float h = textAscent()+textDescent()+5;
  float w = textWidth(ingredient.name) + INGREDIENT_TEXT_PADDING;

  float x = mixingCursor.drawingX+(CURSOR_WIDTH/2)+20;
  if (x+w >= SCREEN_WIDTH-20) {
    x = mixingCursor.drawingX-(CURSOR_WIDTH/2)-w-20;
  }
  float y = map(mixingCursor.fillToLevel, 0, 1, CANVAS_BOTTOM-3, CANVAS_TOP+3);
  if (y+h >= CANVAS_BOTTOM-3) {
    y = CANVAS_BOTTOM-3-h;
  }

  noStroke();
  fill(0);
  rect(x, y, w, h, 5, 5, 5, 5);  
  noStroke();
  fill(255);
  text(ingredient.name, x + INGREDIENT_TEXT_PADDING/2, y + 2);
}

void mixNextIngredient() {
  assert state == QueerbotState.MIXING;
  mixingCursor.fillLevel = mixingCursor.fillToLevel;
  if (ingredientsToMix.isEmpty()) {
    finishMixing();
  } else {
    PVector p = ingredientsToMix.poll();
    currentMixIndex = (int)p.x;
    currentMixAmount = (int)p.y;
    mixingCursor.fillToLevel = mixingCursor.fillLevel + norm(currentMixAmount, 0, totalMixAmount); 
    if (DEBUG_SIMULATE_MIXING) {
      mixingInProgress = true;
    } else {
      openValve(currentMixIndex, currentMixAmount);
    }
  }
}

void finishMixing() {
  noLoop();
  mixingDrink = null;
  mixingCursor = null;
  mixingInProgress = false;
  gotoSelecting();
}

///////////////////////////////////////////////////////////////////////////////

// map amounts from 0-1 to amounts relative to a given maximum
float[] map(float[] amounts, int max) {
  float total = 0;
  for (float amount : amounts) {
    total += amount;
  }
  float[] norms = new float[amounts.length];
  for (int i = 0; i < amounts.length; i++) {
    norms[i] = map(amounts[i], 0, total, 0, max);
  }
  return norms;
}

// largest remainer method for rounding values 
// while ensuring they still add up to the same sum
int[] round(float[] values) {
  int rounded[] = new int[values.length];
  int rounded_total = 0;
  float total = 0;
  PVector decimals[] = new PVector[values.length];
  for (int i = 0; i < values.length; i++) {
    rounded[i] = floor(values[i]);
    rounded_total += rounded[i];
    total += values[i];
    decimals[i] = new PVector(values[i] - rounded[i], i);
  }
  Arrays.sort(decimals, new Comparator<PVector>() {
    public int compare( PVector lhs, PVector rhs) {
      return lhs.x < rhs.x ? 1 : 0;
    }
  });
  int diff = floor(total) - rounded_total;
  int i = 0;
  while (diff > 0) {
    int index = (int)decimals[i].y;
    if (decimals[i].x > 0) {
      rounded[index] += 1;
      diff--;
    }    
    i = (i + 1) % rounded.length;    
  }
  return rounded;
}