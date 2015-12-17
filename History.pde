class History {
  final Deque<Selection> selections;  // size = SELECTION_HISTORY_SIZE
  final ConcurrentLinkedQueue<PVector> marks;  // absolute pixels
  
  History() {
    this.selections = new LinkedList();
    this.marks = new ConcurrentLinkedQueue<PVector>();    
  }
  
  void add(Selection selection) {    
    if (selections.size() >= SELECTION_HISTORY_SIZE) {
      selections.removeLast();
    }
    selections.addFirst(selection);
    
    float y = random(RAINBOW_TOP, RAINBOW_BOTTOM);
    PVector p = new PVector(selection.x, y);
    marks.add(p);
    selection.mark = p;
  }
  
  Section[] sectionsForSelections() {
    Section[] sections = new Section[selections.size()];
    int i = 0;
    for (Selection selection : selections) {
      sections[i++] = selection.section;
    }
    return sections;
  }

  void drawMarks() {
    for (PVector p : marks) {
      drawMark(p);
    }        
  }
  
  void drawMark(PVector p) {
    noFill();
    color c = gradient(p.x, 0, SCREEN_WIDTH, RAINBOW_COLORS);
    stroke(c);
    strokeWeight(8);
    point(p.x, p.y);
    //strokeWeight(2);
    //line(p.x, RAINBOW_TOP, p.x, RAINBOW_BOTTOM);    
  }

}