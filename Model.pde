import java.util.*;

class Model {
  
  // constants
  final Section[] sections;
  final Ingredient[] ingredients;
  
  // variables
  Set<Range> rangesForUncoveredSections;
    
  public Model(String file) {    
    Table table = loadTable(file, "header");
    table.trim();
    
    sections = new Section[table.getColumnCount()-2];
    ingredients = new Ingredient[table.getRowCount()];    
    for (int i = 0; i < sections.length; i++) {
      sections[i] = new Section(i, table.getColumnTitle(i), sections.length, ingredients.length);
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

    // TODO: remove
    sections[1].covered = false;
    sections[3].covered = false;
    sections[4].covered = false;
    
    updateRangesForUncoveredSections();
  }
    
  Selection update(Selection selection1, Selection selection2) {
    // TODO: calculate result selection based on input selections (MF -> Q etc)
    // TODO: update counts (with cap)
    // TODO: un/cover sections based on counts    
    // TODO: update the traits based on ???
    return null;
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

class Selection {
  final Section section;
  final Map<Ingredient,Float> amounts;
  
  public Selection(Section section, Map<Ingredient,Float> amounts) {
    this.section = section;
    this.amounts = amounts;
  }
}