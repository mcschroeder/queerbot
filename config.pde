final boolean OUT_OF_ORDER = false;

final boolean DEBUG_SHOW_FPS = false;
final boolean DEBUG_LOG_RULES = false;
boolean DEBUG_BEGIN_WITH_ALL_SECTIONS_UNCOVERED = true;
boolean DEBUG_SIMULATE_HARDWARE = true;
boolean DEBUG_SIMULATE_MIXING = true;
final boolean DEBUG_LOG_HARDWARE = true;

boolean VIRGIN_MODE = false;

final int MIN_FILL_LEVEL = 100;  // ml
final int MAX_FILL_LEVEL = 1400;  // ml

final int MIN_AMOUNT = 10;  // ml
final int CUP_SIZE = 150;  // ml

final int LEVER_MIN = 434;
final int LEVER_MAX = 774;
final int SELECT_BUTTON_ID = 4;
final int CONFIRM_BUTTON_ID = 5;
final int MAINTENANCE_BUTTON_ID = 3;

final int SELECTION_HISTORY_SIZE = 10;
final boolean TRAIT_UPDATES_ENABLED = true;
final float PLASTICITY_FACTOR = 0.15;
final float SUB_PLASTICITY_FACTOR = 0.05;

final boolean LIGHTS_ENABLED = false;
final int NUM_LIGHTS = 100;

final color BACKGROUND_COLOR = color(0);
final color INGREDIENT_TEXT_COLOR = color(0);
final color CURSOR_BACKGROUND_COLOR = color(255);
final color CURSOR_FOREGROUND_COLOR = 255; //color(127);
final color[] RAINBOW_COLORS = {  
  color(255,0,0),
  color(255,127,0),
  color(255,255,0),
  color(0,255,0),
  color(0,0,255),
  color(75,0,130), 
  color(139,0,255)
};

final int SCREEN_WIDTH = 800;
final int SCREEN_HEIGHT = 600;
final int LEGEND_HEIGHT = 80;
final int HISTORY_HEIGHT = 150;
final int SECTION_LABELS_TOP_MARGIN = 20;
final int RAINBOW_TOP_MARGIN = 60;
final int RAINBOW_BOTTOM_MARGIN = 0;

final int CURSOR_WIDTH = 40;

final int CANVAS_HEIGHT = SCREEN_HEIGHT-LEGEND_HEIGHT-HISTORY_HEIGHT;
final int LEGEND_TOP = 0;
final int LEGEND_BOTTOM = LEGEND_TOP+LEGEND_HEIGHT;
final int CANVAS_TOP = LEGEND_BOTTOM;
final int CANVAS_BOTTOM = CANVAS_TOP+CANVAS_HEIGHT;
final int HISTORY_TOP = CANVAS_BOTTOM;
final int HISTORY_BOTTOM = HISTORY_TOP+HISTORY_HEIGHT;
final int SECTION_LABELS_TOP = HISTORY_TOP+SECTION_LABELS_TOP_MARGIN;
final int RAINBOW_TOP = HISTORY_TOP+RAINBOW_TOP_MARGIN;
final int RAINBOW_BOTTOM = HISTORY_BOTTOM-RAINBOW_BOTTOM_MARGIN;

final int INGREDIENT_TEXT_SIZE = 24;
final int INGREDIENT_TEXT_PADDING = 20;