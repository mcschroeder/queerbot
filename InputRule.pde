class InputRule {
  final Section in1, in2;
  final Section tally1, tally2;  // null = hybrid
  final Section out;
  
  InputRule(Section in1, Section in2, Section tally1, Section tally2, Section out) {
    this.in1 = in1;
    this.in2 = in2;
    this.tally1 = tally1;
    this.tally2 = tally2;
    this.out = out;
  }
  
  InputRule(String line, Map<String,Section> sectionsByName) {
    String[] buttons = line.substring(0, line.indexOf("->")).trim().split(",");
    line = line.substring(line.indexOf("->")+2);
    String[] tally = line.substring(0, line.indexOf("->")).trim().split(",");
    String drink = line.substring(line.indexOf("->")+2).trim();    
    this.in1 = sectionsByName.get(buttons[0]);
    this.in2 = sectionsByName.get(buttons[1]);
    this.tally1 = tally.length > 0 ? sectionsByName.get(tally[0]) : null;
    this.tally2 = tally.length > 1 ? sectionsByName.get(tally[1]) : null;
    this.out = drink.equals("hybrid") ? null : sectionsByName.get(drink);
  }
  
  // note: order of sections does not matter
  boolean matches(Section[] sections) {
    return (sections.length == 2 && 
           ((sections[0] == in1 && sections[1] == in2) ||
            (sections[1] == in1 && sections[0] == in2)));
  }  
  
  String toString() {
    String s = in1.name+","+in2.name+" -> ";
    if (tally1 != null) s+=tally1.name;
    if (tally2 != null) s+=","+tally2.name;
    s+=" -> ";
    s+=out==null?"hybrid":out.name;
    return s;
  }
}

List<InputRule> loadInputRules(String file, Map<String,Section> sectionsByName) {
  List<InputRule> rules = new ArrayList();
  String[] lines = loadStrings(file);
  for (String line : lines) {
    if (line.startsWith("#") || line.trim().isEmpty()) { continue; }
    InputRule rule = new InputRule(line, sectionsByName);
    rules.add(rule);
  }    
  return rules;
}

InputRule firstMatchingInputRule(Section[] sections, List<InputRule> rules) {
  for (InputRule rule : rules) {
    if (rule.matches(sections)) {
      return rule;
    }
  }
  return null;
}