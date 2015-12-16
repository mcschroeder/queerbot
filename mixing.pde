void drawMixingInterface() {
  assert state == QueerbotState.MIXING;
  assert activeDrink != null;

  background(BACKGROUND_COLOR);
  drawLegend(getSelection(activeDrink.x, model));
  for (Section section : model.sections) {
    section.drawBackground();
  }
  drawCurves();
  model.history.drawMarks();
  for (Section section : model.sections) {
    section.drawForeground();
    section.drawLabel();
  }
  cursor1.drawBackground();  
  cursor1.clipArea();
  for (Ingredient ingredient : model.ingredients) {
    ingredient.drawCurve();
  }
  noClip();
  cursor1.drawForeground();
  

  /*
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
  text(msg, width/2, height/2);
  
  */
}

///////////////////////////////////////////////////////////////////////////////

void gotoMixing(Selection drink) {
  assert state == QueerbotState.SELECTING;
  assert drink != null;
  activeDrink = drink;
  state = QueerbotState.MIXING;
  cursor1.update(drink.x);
  for (Section section : model.sections) {
    section.selected = false;
    section.highlighted = false;
    section.dimmed = true;
  }
  activeDrink.section.dimmed = false;
  activeDrink.section.selected = true;
  loop();
  //redraw();
  
  if (DEBUG_SIMULATE_HARDWARE) return;
  
  // TODO: mixing
  // TODO: timeout if no response from controller?
  
  activeDrink = null;
  gotoSelecting();
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