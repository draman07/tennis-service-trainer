import netP5.*;
import oscP5.*;


// osc vars
String OSC_ADDRESS = "/tennis";
int LISTENING_PORT = 9600;
OscP5 osc;

// values
float errorsSum = MAX_FLOAT;
float lowestErrorsSum = MAX_FLOAT;
float matchThreshold = MAX_FLOAT;


// PROCESSING METHODS
void setup() {
  size(160, 320);
  background(20);

  osc = new OscP5(this, LISTENING_PORT);
}

void draw() {
  background(20);
  visualizeData();
}


// METHODS DEFINITIONS
void visualizeData() {
  float scale = 50.;
  float lineY = 0;
  
  // errors sum
  stroke(255);
  lineY = height - (errorsSum * scale);
  line(
    0, lineY,
    width, lineY
  );
  
  // lowest
  stroke(0, 200, 200);
  lineY = height - (lowestErrorsSum * scale);
  line(
    0, lineY,
    width, lineY
  );
  
  // threshold
  stroke(0, 200, 0);
  lineY = height - (matchThreshold * scale);
  line(
    0, lineY,
    width, lineY
  );
}


// EVENT HANDLERS
void oscEvent(OscMessage message) {
  if (message.checkAddrPattern(OSC_ADDRESS) == true) {
    errorsSum = message.get(0).floatValue();
    lowestErrorsSum = message.get(1).floatValue();
    matchThreshold = message.get(2).floatValue();
  }
}