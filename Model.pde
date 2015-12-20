import java.util.*;

class Model {
  
  // constants  
  final Section[] sections;
  final Map<String,Section> sectionsByName;
  final Ingredient[] ingredients;
  final List<InputRule> inputRules;
  final List<CoverRule> coverRules;
  final History history;
  
  // variables
  Set<Range> rangesForUncoveredSections;
    
  public Model(String ingredientsFile, String inputRulesFile, String coverRulesFile) {    
    Table table = loadTable(ingredientsFile, "header");
    table.trim();
            
    sections = new Section[table.getColumnCount()-3];
    sectionsByName = new HashMap();
    ingredients = new Ingredient[table.getRowCount()];    
    for (int i = 0; i < sections.length; i++) {
      sections[i] = new Section(i, table.getColumnTitle(i), sections.length, ingredients.length);
      sectionsByName.put(sections[i].name, sections[i]);
      for (int j = 0; j < ingredients.length; j++) {
        TableRow row = table.getRow(j);
        sections[i].significantAmounts[j] = row.getFloat(i);
        if (sections[i].getCount() == 0) {
          sections[i].historicalAverage[j] = sections[i].significantAmounts[j];
        }
        if (ingredients[j] == null) { 
          ingredients[j] = new Ingredient(j, row.getString("name"), sections.length);
          ingredients[j].strokeColor = color(unhex(row.getString("color")) | 0xFF000000);
          ingredients[j].scaleFactor = row.getFloat("scale");
        }
      }
    }
    for (Ingredient ingredient : ingredients) {
      ingredient.setSignificantPoints(sections);
    }
    
    this.history = new History(ingredients);
    
    this.inputRules = loadInputRules(inputRulesFile, sectionsByName);
    this.coverRules = loadCoverRules(coverRulesFile, sectionsByName);
    
    updateRangesForUncoveredSections(CURSOR_WIDTH/2);    
  }

  Selection update(Selection selection1, Selection selection2) {
    if (DEBUG_LOG_RULES) {
      println("\nUPDATING MODEL WITH SELECTION: " + selection1 + "," + selection2);
    }
    assert (selection1 != null);
    Selection result;
    if (selection2 == null) {
      selection1.section.incrementCount();
      result = selection1;
    } else {
      Section[] selectedSections = {selection1.section, selection2.section};
      InputRule inputRule = firstMatchingInputRule(selectedSections, inputRules);      
      if (inputRule == null) {
        if (DEBUG_LOG_RULES) {
          println("NO INPUT RULE FOUND. TALLYING EACH AND RETURNING HYBRID.");
        }
        selection1.section.incrementCount();
        selection2.section.incrementCount();
        result = hybridSelection(selection1, selection2, this);
      } else {
        if (DEBUG_LOG_RULES) {
          println("USING INPUT RULE: " + inputRule);
        }
        if (inputRule.tally1 != null) inputRule.tally1.incrementCount();
        if (inputRule.tally2 != null) inputRule.tally2.incrementCount();
        if (inputRule.out == null) {
          result = hybridSelection(selection1, selection2, this);
        } else {
          if (inputRule.in1 == inputRule.in2 && inputRule.out == inputRule.in1) {
            result = hybridSelection(selection1, selection2, this);
          } else {
            result = new Selection(inputRule.out, inputRule.out.significantAmounts, inputRule.out.centerX);
          }
        }
      }
    }

    history.add(result);
    result.section.updateHistoricalAverage(result.amounts);
    
    CoverRule coverRule = firstMatchingCoverRule(history.sectionsForSelections(), coverRules);
    if (coverRule != null) {
      if (DEBUG_LOG_RULES) {
        println("FOUND MATCHING COVER RULE: " + coverRule);
      }
      coverRule.conclusion.setCovered(!coverRule.uncover);
    }    
    
    updateRangesForUncoveredSections(CURSOR_WIDTH/2);
    
    // TODO
    // updateTraits();
    
    return result;
  }

  int t = 0;
  float p = 0.1;
  void updateTraits() {
    t = t + 1;
    // if (t % 60 != 0) return;
    for (Section dom : model.sections) {
      for (int i = 0; i < dom.significantAmounts.length; i++) {
        float sigAmount = dom.significantAmounts[i];
        float histAvg = dom.historicalAverage[i];
        float sigAmount_next = sigAmount + (histAvg-sigAmount)*p;
        println("a="+sigAmount+" h="+histAvg+" a'="+sigAmount_next);
        dom.significantAmounts[i] = sigAmount_next;
      }
      /*
      for (Section sub :  model.sections) {
        if (dom == sub) continue;
        float r = random(-1,1);
        for (int i = 0; i < sub.significantAmounts.length; i++) {
          float subSigAmount = sub.significantAmounts[i];
          float domSigAmount = dom.significantAmounts[i];
          float subSigAmount_next = subSigAmount + (domSigAmount-subSigAmount)*p*r;
          sub.significantAmounts[i] = subSigAmount_next;
          println("sub_a="+subSigAmount+" dom_a="+domSigAmount+" sub_a'="+subSigAmount_next);
        }
      }
      */
    }
    for (Ingredient ingredient : model.ingredients) {
      ingredient.setSignificantPoints(model.sections);
    }
  }
  
  void updateRangesForUncoveredSections(int padding) {
    Set<Range> ranges = new HashSet();
    Range currentRange = null;
    for (Section section : sections) {
      if (section.isCovered()) {
        if (currentRange != null) {
          currentRange.end -= padding;
          ranges.add(currentRange);
          currentRange = null;
        }
      } else {
        if (currentRange == null) {
          currentRange = new Range();
          currentRange.begin = section.leftX + padding;
          currentRange.end = section.rightX;
        } else {
          //assert (currentRange.end == section.leftX);
          currentRange.end = section.rightX;
        }
      }
    }
    if (currentRange != null) {
      currentRange.end -= padding;
      ranges.add(currentRange);
    }
    this.rangesForUncoveredSections = ranges;
  }
}

///////////////////////////////////////////////////////////////////////////////

class Selection {
  final Section section;
  final float[] amounts;  // one ml amount per ingredient
  
  // to move the cursor to the right location:
  final int x;  // absolute pixel scale, indexed from 0=CANVAS_LEFT to CANVAS_WIDTH-1
  
  PVector mark;  // mark on the rainbow of history
  
  public Selection(Section section, float[] amounts, int x) {
    this.section = section;
    this.amounts = amounts;
    this.x = x;
  }
    
  String toString() {
    return section.name;
  }
}

Selection hybridSelection(Selection selection1, Selection selection2, Model model) {
  int resultX;
  if (selection1.x > selection2.x) {
    resultX = selection2.x + (selection1.x - selection2.x)/2;
  } else {
    resultX = selection1.x + (selection2.x - selection1.x)/2;
  }
  return getSelection(resultX, model);
}