color BACKGROUND_COLOR = color(0);

void loadConfig(String configFile) {
  String[] lines = loadStrings(configFile);
  for (String line : lines) {
    String[] tokens = line.split("=");
    if (tokens.length != 2) {
      println("error parsing " + configFile + ":\n\t" + line);
      continue;
    }
    String var = tokens[0].trim().toUpperCase();
    String valStr = tokens[1].trim();
    if (var.equals("BACKGROUND_COLOR")) {
      BACKGROUND_COLOR = parseColor(valStr);
    }
  }
}

color parseColor(String valStr) {
  if (valStr.startsWith("#")) {
    return unhex(valStr.substring(1));
  } else {
    // TODO: split rgb tuple or parse direct color value
    return 0;
  }
}