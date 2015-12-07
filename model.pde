import java.util.Map;
import java.util.Set;

class Model {  
  Section[] sections;
  Ingredient[] ingredients;
    
  public Model(String file) {    
    Table table = loadTable(file, "header");
    table.trim();
    sections = new Section[table.getColumnCount()-2];
    ingredients = new Ingredient[table.getRowCount()];
    for (int c = 0; c < table.getColumnCount()-2; c++) {
      sections[c] = new Section();      
      sections[c].name = table.getColumnTitle(c);
      sections[c].percentages = new HashMap();
      for (int r = 0; r < table.getRowCount(); r++) {
        TableRow row = table.getRow(r); 
        Ingredient ingredient = ingredients[r];
        if (ingredient == null) {
          ingredient = new Ingredient();
          ingredient.name = row.getString("name");
          if (row.getString("side").equals("R")) {
            ingredient.displayOnRightSide = true;
          }
          ingredients[r] = ingredient;                  
        }
        sections[c].percentages.put(ingredient, row.getFloat(sections[c].name));        
      }
    }
  }
  
  Selection update(Set<Selection> selection) {
    // TODO: calculate result selection based on input selections (MF -> Q etc)
    // TODO: update counts (with cap)
    // TODO: un/cover sections based on counts
    
    // TODO: update the traits based on ???
    
    return null;
  }  
}

class Section {
  String name;
  Map<Ingredient,Float> percentages;
  int count = 0;  // how often was this section selected
  boolean covered = true;
}

class Ingredient {
  String name;
  boolean displayOnRightSide = false;
  float level = 0;  // 0-1
}

class Selection {
  Section section;
  Map<Ingredient,Float> percentages;
}