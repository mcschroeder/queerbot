
// Alert message

void alert(String message) {
  _message = message;
  _alerting = true;
}

void dismissAlert() {
  _alerting = false;
}

String _message = null;
boolean _alerting = false;

void drawAlertIfNeeded() {
  if (!_alerting || _message == null) {
    return;
  }
  
  fill(color(255,255,255,220));
  rect(CANVAS_LEFT, CANVAS_TOP, CANVAS_RIGHT-CANVAS_LEFT, CANVAS_BOTTOM-CANVAS_TOP);
  
  int x = CANVAS_LEFT+(CANVAS_WIDTH/2);
  int y = CANVAS_TOP+(CANVAS_HEIGHT/2);  

  textSize(32);
  textAlign(CENTER,CENTER);  
  fill(color(0,0,0));
  text(_message, x, y);  
}