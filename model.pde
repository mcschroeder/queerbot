import java.util.Map;
import java.util.Set;

class Model {  
  final Section[] sections;
  final Ingredient[] ingredients;
    
  public Model(String file) {    
    Table table = loadTable(file, "header");
    table.trim();
    
    int numSections = table.getColumnCount()-2;
    int numIngredients = table.getRowCount();    
    sections = new Section[numSections];
    ingredients = new Ingredient[numIngredients];
    for (int i = 0; i < numSections; i++) {
      String sectionName = table.getColumnTitle(i);
      Section section = new Section(this, i, sectionName);
      for (int j = 0; j < numIngredients; j++) {
        TableRow row = table.getRow(j);
        Ingredient ingredient = ingredients[j];
        if (ingredient == null) {
          String ingredientName = row.getString("name");
          ingredient = new Ingredient(j, ingredientName);
          ingredient.displayOnRightSide = row.getString("side").equals("R");
        }
        ingredients[j] = ingredient;
        float amount = row.getFloat(section.name);
        section.significantAmounts.put(ingredient, amount);
      }
      sections[i] = section;
    }
    
    sections[1].covered = false;
    sections[3].covered = false;
    sections[4].covered = false;
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
  final Model model;
  final int index;  
  final String name;
  
  final int width;
  final int leftX;
  final int centerX;
  final int rightX;
  
  final Map<Ingredient,Float> significantAmounts = new HashMap();  
  int count = 0;  // how often was this section selected
  boolean covered = true;
    
  Section(Model model, int index, String name) {
    this.model = model;
    this.index = index;
    this.name = name;
    this.width = CANVAS_WIDTH/model.sections.length;
    this.leftX = (int)map(index, 0, model.sections.length-1, CANVAS_LEFT, CANVAS_RIGHT-width);
    this.centerX = leftX + width/2;
    this.rightX = leftX + width;
  }
}

class Ingredient {
  final int index;
  final String name;
  
  boolean displayOnRightSide = false;
  float level = 0;  // 0-1
  
  Ingredient(int index, String name) {
    this.index = index;
    this.name = name;
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