import java.util.*;

final int SELECTION_HISTORY_SIZE = 10;

class Model {
  
  // constants  
  final Section[] sections;
  final Map<String,Section> sectionsByName;
  final Ingredient[] ingredients;
  final List<InputRule> inputRules;
  final List<CoverRule> coverRules;
  
  // variables
  Set<Range> rangesForUncoveredSections;
  final Deque<Selection> drinkHistory = new LinkedList();
    
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
          ingredients[j].displayOnRightSide = row.getString("side").equals("R");
        }
        ingredients[j].updateSignificantPoints(sections[i]);
      }
    }
    
    this.inputRules = loadInputRules(inputRulesFile, sectionsByName);
    this.coverRules = loadCoverRules(coverRulesFile, sectionsByName);

    sections[0].covered = false;
    sections[sections.length-1].covered = false;
    
    updateRangesForUncoveredSections();
  }

  Selection update(Selection selection1, Selection selection2) {
    println("UPDATING MODEL WITH SELECTION: " + selection1 + "," + selection2);
    assert (selection1 != null);
    Selection result;
    if (selection2 == null) {
      selection1.section.count += 1;
      result = selection1;
    } else {
      Section[] selectedSections = {selection1.section, selection2.section};
      InputRule inputRule = firstMatchingInputRule(selectedSections, inputRules);      
      if (inputRule == null) {
        println("NO INPUT RULE FOUND. TALLYING EACH AND RETURNING HYBRID.");
        selection1.section.count += 1;
        selection2.section.count += 1;
        // TODO: which section to choose for hybrid result?
        result = selection1;  // TODO: hybrid
      } else {
        println("USING INPUT RULE: " + inputRule);
        if (inputRule.tally1 != null) inputRule.tally1.count++;
        if (inputRule.tally2 != null) inputRule.tally2.count++;
        if (inputRule.out == null) {
          // TODO: which section to choose for hybrid result?
          result = selection1;  // TODO: hybrid
        } else {
          result = new Selection(inputRule.out, inputRule.out.significantAmounts);
        }        
      }
    }
    
    rememberDrink(result);
    
    Section[] history = new Section[drinkHistory.size()];
    int i = 0;
    for (Selection selection : drinkHistory) {
      history[i++] = selection.section;
    }
    CoverRule coverRule = firstMatchingCoverRule(history, coverRules);
    if (coverRule != null) {
      println("FOUND MATCHING COVER RULE: " + coverRule);
      coverRule.conclusion.covered = !coverRule.uncover;
    }    
    
    updateRangesForUncoveredSections();
    
    // TODO: update the traits based on ???
    
    return result;
  }
  
  void rememberDrink(Selection drink) {
    if (drinkHistory.size() >= SELECTION_HISTORY_SIZE) {
      drinkHistory.removeLast();
    }
    drinkHistory.addFirst(drink);
  }
  
  void updateRangesForUncoveredSections() {
    Set<Range> ranges = new HashSet();
    Range currentRange = null;
    for (Section section : sections) {
      if (section.covered) {
        if (currentRange != null) {
          ranges.add(currentRange);
          currentRange = null;
        }
      } else {
        if (currentRange == null) {
          currentRange = new Range();
          currentRange.begin = section.leftX;
          currentRange.end = section.rightX;
        } else {
          assert (currentRange.end == section.leftX);
          currentRange.end = section.rightX;
        }
      }
    }
    if (currentRange != null) {
      ranges.add(currentRange);
    }
    this.rangesForUncoveredSections = ranges;
  }
}

///////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////



///////////////////////////////////////////////////////////////////////////////

class Selection {
  final Section section;
  final float[] amounts;  // one amount per ingredient
  
  public Selection(Section section, float[] amounts) {
    this.section = section;
    this.amounts = amounts;
  }
  
  String toString() {
    return section.name;
  }
}