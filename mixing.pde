final Queue<PVector> ingredientsToMix = new LinkedList<PVector>();
boolean mixingInProgress = false;
PImage _blurredBackground = null;

void drawMixingInterface() {
  assert state == QueerbotState.MIXING;
  assert activeDrink != null;
  
  if (_blurredBackground == null) {    
    background(BACKGROUND_COLOR);
    drawCurves();
    model.history.drawMarks();
    for (Section section : model.sections) {
      section.drawForeground();
      section.drawLabel();
    }  
    filter(BLUR,6);  
    _blurredBackground = get();
  }
  image(_blurredBackground, 0, 0);
  
  drawLegend(getSelection(activeDrink.x, model));
  model.history.drawMark(activeDrink.mark);
  activeDrink.section.drawLabel();
  cursor1.drawBackground();
  cursor1.clipArea();
  for (Ingredient ingredient : model.ingredients) {
    ingredient.drawCurve();
  }
  noClip();
  cursor1.drawForeground();
}

///////////////////////////////////////////////////////////////////////////////

void gotoMixing(Selection drink) {
  assert state == QueerbotState.SELECTING;
  assert drink != null;
  activeDrink = drink;
  state = QueerbotState.MIXING;
  cursor1.update(drink.x);
  cursor1.fillLevel = 0;
  cursor1.fillToLevel = 0;
  for (Section section : model.sections) {
    section.selected = false;
    section.highlighted = false;
  }
  activeDrink.section.selected = true;
  loop();
  
  ingredientsToMix.clear();
  int[] absoluteAmounts = round(map(activeDrink.amounts, CUP_SIZE));
  for (int i = 0; i < absoluteAmounts.length; i++) {
    int amount = absoluteAmounts[i];
    if (amount > 0) {
      ingredientsToMix.add(new PVector(i, amount));
    }
  }
  mixNextIngredient();
}

void mixNextIngredient() {
  assert state == QueerbotState.MIXING;
  cursor1.fillLevel = cursor1.fillToLevel;
  if (ingredientsToMix.isEmpty()) {
    finishMixing();
  } else {
    PVector p = ingredientsToMix.poll();
    int index = (int)p.x;
    int amount = (int)p.y;    
    cursor1.fillToLevel = cursor1.fillLevel + norm(amount, 0, CUP_SIZE);    
    if (DEBUG_SIMULATE_MIXING) {
      mixingInProgress = true;
    } else {
      // TODO
    }
  }
}

void finishMixing() {
  noLoop();
  activeDrink = null;
  _blurredBackground = null;
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