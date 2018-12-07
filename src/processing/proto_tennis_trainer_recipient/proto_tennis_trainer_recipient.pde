import netP5.*;
import oscP5.*;


// constants
int BAR_WIDTH = 80;


// osc vars
String OSC_ADDRESS = "/tennis";
int LISTENING_PORT = 9600;
OscP5 osc;

// values
float g1ErrorSum = MAX_FLOAT;
float g1LowestErrorsSum = MAX_FLOAT;
float g2ErrorSum = MAX_FLOAT;
float g2LowestErrorsSum = MAX_FLOAT;
float g3ErrorSum = MAX_FLOAT;
float g3LowestErrorsSum = MAX_FLOAT;

float matchThreshold = MAX_FLOAT;


// PROCESSING METHODS
void setup() {
  size(240, 320);
  background(20);

  osc = new OscP5(this, LISTENING_PORT);
}

void draw() {
  background(20);
  
  // visualize data
  drawBar(0, g1ErrorSum, g1LowestErrorsSum);
  drawBar(BAR_WIDTH, g2ErrorSum, g2LowestErrorsSum);
  drawBar(BAR_WIDTH * 2, g3ErrorSum, g3LowestErrorsSum);
}


// METHODS DEFINITIONS
void drawBar(int _x, float sum, float lowest) {
  float scale = 50.;
  float lineY = 0;
  
  // errors sum
  stroke(255);
  lineY = height - (sum * scale);
  line(
    _x, lineY,
    _x + BAR_WIDTH, lineY
  );
  
  // lowest
  stroke(0, 200, 200);
  lineY = height - (lowest * scale);
  line(
    _x, lineY,
    _x + BAR_WIDTH, lineY
  );
  
  // threshold
  stroke(0, 200, 0);
  lineY = height - (matchThreshold * scale);
  line(
    _x, lineY,
    _x + BAR_WIDTH, lineY
  );
}


// EVENT HANDLERS
void oscEvent(OscMessage message) {
  if (message.checkAddrPattern(OSC_ADDRESS) == true) {
    // gesture 1
    g1ErrorSum = message.get(0).floatValue();
    g1LowestErrorsSum = message.get(1).floatValue();
    
    // gesture 2
    g2ErrorSum = message.get(2).floatValue();
    g2LowestErrorsSum = message.get(3).floatValue();
    
    // gesture 3
    g3ErrorSum = message.get(4).floatValue();
    g3LowestErrorsSum = message.get(5).floatValue();

    matchThreshold = message.get(6).floatValue();
  }
}