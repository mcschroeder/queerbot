final boolean DEBUG_LOG_RULES = true;
final boolean DEBUG_SHOW_FPS = false;
final boolean DEBUG_SHOW_INFO_FOR_COVERED_SECTIONS = false;
final boolean DEBUG_BEGIN_WITH_ALL_SECTIONS_UNCOVERED = true;
final boolean DEBUG_SIMULATE_MIXING = false;
final boolean DEBUG_SIMULATE_HARDWARE = false;

final int CUP_SIZE = 150;  // milliliters

final int SELECTION_HISTORY_SIZE = 10;

final color BACKGROUND_COLOR = color(0);
final color INGREDIENT_TEXT_COLOR = color(0);
final color[] INGREDIENT_COLORS = {
    color(6,174,213),
    color(8,103,136),
    color(240,200,8),
    color(255,241,208),
    color(221,28,26),
    color(146,94,45)
};
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