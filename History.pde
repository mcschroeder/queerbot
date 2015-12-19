import java.text.*;
import java.io.*;

class History {
  final Deque<Selection> selections;  // size = SELECTION_HISTORY_SIZE
  final ConcurrentLinkedQueue<PVector> marks;  // absolute pixels
  final PrintWriter logWriter;
  
  final String RAINBOW_STATE_FILE = "state/rainbow";
  FileWriter rainbowStateWriter = null;
  
  History(Ingredient[] ingredients) {
    this.selections = new LinkedList();
    this.marks = new ConcurrentLinkedQueue<PVector>();
    
    Format formatter = new SimpleDateFormat("yyyyMMdd'T'HHmmssZ");    
    String logName = formatter.format(new Date()) + ".csv";    
    this.logWriter = createWriter("log/"+logName);
    String headerLine = "time,section";
    for (Ingredient ingredient : ingredients) {
      headerLine += ","+ingredient.name;
    }
    headerLine += ",rainbowX,rainbowY";
    logWriter.println(headerLine);
    logWriter.flush();
    
    String[] rainbowLines = loadStrings(RAINBOW_STATE_FILE);
    if (rainbowLines != null) {
      for (String line : rainbowLines) {
        String[] tokens = line.split(",");
        PVector p = new PVector();
        p.x = float(tokens[0]);
        p.y = float(tokens[1]);
        marks.add(p);
      }
    }
    try {
      this.rainbowStateWriter = new FileWriter(sketchPath(RAINBOW_STATE_FILE), true);
    } catch (IOException e) {
      e.printStackTrace();
    }
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
    
    if (rainbowStateWriter != null) {
      try {
        rainbowStateWriter.write(p.x + "," + p.y + "\n");
        rainbowStateWriter.flush();
      } catch (IOException e) {}
    }
    
    String logLine = millis()+","+selection.section.name;
    for (float amount : selection.amounts) {
      logLine += ","+amount;
    }
    logLine += ","+p.x+","+p.y;
    logWriter.println(logLine);
    logWriter.flush();
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