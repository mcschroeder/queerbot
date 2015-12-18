class CoverRule {
  final Predicate[] premises;
  final Section conclusion;
  final boolean uncover;
  
  CoverRule(Predicate[] premises, Section conclusion, boolean uncover) {
    this.premises = premises;
    this.conclusion = conclusion;
    this.uncover = uncover;
  }

  CoverRule(String line, Map<String,Section> sectionsByName) {
    String[] premiseStrs = line.substring(0, line.indexOf("->")).trim().split(",");
    line = line.substring(line.indexOf("->")+2).trim();
    this.uncover = line.startsWith("-") == false;
    String conclusionName = line.substring(1);
    this.premises = new Predicate[premiseStrs.length];
    for (int i = 0; i < premiseStrs.length; i++) {
      this.premises[i] = new Predicate(premiseStrs[i], sectionsByName);
    }
    this.conclusion = sectionsByName.get(conclusionName);    
  }
  
  boolean matches(Section sections[]) {
    for (Predicate premise : premises) {
      if (premise.test(sections) == false) return false;
    }
    return true;
  }
  
  String toString() {
    String s = "";
    for (int i = 0; i < premises.length; i++) {
      s += premises[i] + (i == premises.length-1 ? " " : ", ");
    }
    s += "-> " + (uncover ? "+":"-") + conclusion.name;
    return s;
  }
}

private List<CoverRule> loadCoverRules(String file, Map<String,Section> sectionsByName) {
  List<CoverRule> rules = new ArrayList();
  String[] lines = loadStrings(file);
  for (String line : lines) {
    if (line.startsWith("#") || line.trim().isEmpty()) { continue; }
    CoverRule rule = new CoverRule(line, sectionsByName);
    rules.add(rule);
  }
  return rules;
}

CoverRule firstMatchingCoverRule(Section[] sections, List<CoverRule> rules) {
  for (CoverRule rule : rules) {
    if (rule.matches(sections)) {
      if ((rule.uncover && rule.conclusion.covered) ||
          (!rule.uncover && !rule.conclusion.covered)) {
        return rule;
      }
    }
  }
  return null;
}

///////////////////////////////////////////////////////////////////////////////

class Predicate {
  final Section section;
  final Operator operator;
  final float value;
  
  Predicate(Section section, Operator operator, float value) {
    this.section = section;
    this.operator = operator;
    this.value = value;
  }
  
  Predicate(String str, Map<String,Section> sectionsByName) {
    int opIndex = str.indexOf("<");
    if (opIndex > -1) {
      this.operator = Operator.LESS_THAN;
    } else {
      opIndex = str.indexOf(">");
      if (opIndex > -1) {
        this.operator = Operator.GREATER_THAN;
      } else {
        opIndex = str.indexOf("=");
        assert (opIndex > -1);
        this.operator = Operator.EQUALS;
      }
    }
    String secName = str.substring(0, opIndex).trim();
    String valueStr = str.substring(opIndex+1).trim();
    this.section = sectionsByName.get(secName);
    this.value = Float.parseFloat(valueStr);
  }
  
  boolean test(Section[] sections) {
    float count = 0;
    for (Section s : sections) {
      if (s == this.section) count++; 
    }
    float percentage = sections.length > 0 ? count/sections.length : 0;
    switch (operator) {
      case LESS_THAN: return percentage < value;
      case GREATER_THAN: return percentage > value;
      case EQUALS: return percentage == value;
      default: return false;
    }
  }
  
  String toString() {
    String s = section.name;
    switch (operator) {
      case LESS_THAN: s += " < "; break;
      case GREATER_THAN: s += " > "; break;
      case EQUALS: s += " = "; break;
    }
    s += value;
    return s;
  }
}

///////////////////////////////////////////////////////////////////////////////

enum Operator {
  LESS_THAN,
  GREATER_THAN,
  EQUALS
}