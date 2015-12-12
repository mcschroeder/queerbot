

void drawMixingInterface() {
  assert state == QueerbotState.MIXING;
  assert activeDrink != null;

  background(0,200,0);
  
  float total = 0;
  for (float amount : activeDrink.amounts) {
    total += amount;
  }
  float[] norms = new float[activeDrink.amounts.length];
  for (int i = 0; i < activeDrink.amounts.length; i++) {
    norms[i] = map(activeDrink.amounts[i], 0, total, 0, 100);
  }
  int[] percentages = round(norms);  
  String msg = "+++ MIXING " + activeDrink.section.name + " DRINK +++";
  for (int i = 0; i < activeDrink.amounts.length; i++) {
    Ingredient ingredient = model.ingredients[i];
    msg += "\n" + percentages[i] + "% " + ingredient.name;
  }
  textSize(26);
  fill(0);
  textAlign(CENTER, CENTER);
  text(msg, SCREEN_WIDTH/2, SCREEN_HEIGHT/2);  
}

///////////////////////////////////////////////////////////////////////////////

void mix() {
  assert state == QueerbotState.SELECTING;
  state = QueerbotState.MIXING;
  
  
  
  
  redraw();
  
  
  if (DEBUG_SIMULATE_HARDWARE) return;

  // TODO
  
  delay(10000);
  endMixing();
  
}

void endMixing() {
  state = QueerbotState.SELECTING;
  activeDrink = null;
  cursor1.hidden = false;
  cursor2.hidden = true;
  activeCursor = cursor1;
  updateSelectedSections();
  analogValueChanged(analogValue);
}

///////////////////////////////////////////////////////////////////////////////

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
    rounded[index] += 1;
    i = (i + 1) % rounded.length;
    diff--;
  }
  return rounded;
}