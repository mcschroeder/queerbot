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
            
    sections = new Section[table.getColumnCount()-2];
    sectionsByName = new HashMap();
    ingredients = new Ingredient[table.getRowCount()];    
    for (int i = 0; i < sections.length; i++) {
      sections[i] = new Section(i, table.getColumnTitle(i), sections.length, ingredients.length);
      sectionsByName.put(sections[i].name, sections[i]);
      for (int j = 0; j < ingredients.length; j++) {
        TableRow row = table.getRow(j);
        sections[i].significantAmounts[j] = row.getFloat(i);
        if (ingredients[j] == null) { 
          ingredients[j] = new Ingredient(j, row.getString("name"), sections.length);
          ingredients[j].strokeColor = color(unhex(row.getString("color")) | 0xFF000000);
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
      selection1.section.count += 1;
      result = selection1;
    } else {
      Section[] selectedSections = {selection1.section, selection2.section};
      InputRule inputRule = firstMatchingInputRule(selectedSections, inputRules);      
      if (inputRule == null) {
        if (DEBUG_LOG_RULES) {
          println("NO INPUT RULE FOUND. TALLYING EACH AND RETURNING HYBRID.");
        }
        selection1.section.count += 1;
        selection2.section.count += 1;
        result = hybridSelection(selection1, selection2, this);
      } else {
        if (DEBUG_LOG_RULES) {
          println("USING INPUT RULE: " + inputRule);
        }
        if (inputRule.tally1 != null) inputRule.tally1.count++;
        if (inputRule.tally2 != null) inputRule.tally2.count++;
        if (inputRule.out == null) {
          result = hybridSelection(selection1, selection2, this);
        } else {
          result = new Selection(inputRule.out, inputRule.out.significantAmounts, inputRule.out.centerX);
        }
      }
    }

    history.add(result);
    
    CoverRule coverRule = firstMatchingCoverRule(history.sectionsForSelections(), coverRules);
    if (coverRule != null) {
      if (DEBUG_LOG_RULES) {
        println("FOUND MATCHING COVER RULE: " + coverRule);
      }
      coverRule.conclusion.setCovered(!coverRule.uncover);
    }    
    
    updateRangesForUncoveredSections(CURSOR_WIDTH/2);
    
    // TODO: update the traits based on ???
    
    return result;
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
  final float[] amounts;  // one amount per ingredient
  
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
  println("s1="+selection1.x+" s2="+selection2.x+" r="+resultX);
  return getSelection(resultX, model);
}