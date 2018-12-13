import netP5.*;
import oscP5.*;


// constants
int MARGIN = 40;


// images
PImage bg;

// threshold icon
PImage targetIcon1;
PVector t1Vector;
PImage targetIcon2;
PVector t2Vector;

// cursors
PImage cursor1;
PImage cursor2;
PImage cursor3;
PVector c1Vector;
PVector c2Vector;
PVector c3Vector;
int CURSOR_MIN_Y = 97;
int CURSOR_MAX_Y = 577;


// match vars
int MATCH_COOLDOWN = 1000;
int MATCH_DISPLAY_DURATION = 500;

PImage match1Image;
PImage match2Image;
PImage match3Image;
PVector m1Vector;
PVector m2Vector;
PVector m3Vector;
int match1TimeEnd = -1;
int match2TimeEnd = -1;
int match3TimeEnd = -1;
int m1VisibleEnd = -1;
int m2VisibleEnd = -1;
int m3VisibleEnd = -1;


// fullscreen buttons
int BUTTON_WIDTH = 72;
int BUTTON_HEIGHT = 48;
boolean isFullScreen = false;
PImage enterFullScreenButton;
PImage exitFullScreenButton;


// osc vars
String OSC_ADDRESS = "/tennis";
int LISTENING_PORT = 9600;
OscP5 osc;


// osc values
float g1ErrorSum = 0;
float g1LowestErrorsSum = 0;
float g2ErrorSum = 0;
float g2LowestErrorsSum = 0;
float g3ErrorSum = 0;
float g3LowestErrorsSum = 0;

float matchThreshold = 0;


// processing methods
void setup() {
  size(1280, 720, P2D);
  frameRate(60);
  bg = loadImage("bg.png");

  initTarget();
  initCursors();
  //initFullScreenButtons();
  initMatchImages();

  // init osc
  osc = new OscP5(this, LISTENING_PORT);
}

void draw() {
  image(bg, 0, 0);
  
  updateTarget();
  drawTarget();
  drawCursors();
  //drawFullScreenButtons();
  
  detectMatch1();
  detectMatch2();
  detectMatch3();

  drawMatchImages();
}


// method definitions
void initTarget() {
  targetIcon1 = loadImage("star.png");
  t1Vector = new PVector(628, 0);
  
  targetIcon2 = loadImage("star.png");
  t2Vector = new PVector(1220, 0);
}

void initCursors() {
  cursor1 = loadImage("cursor.png");
  c1Vector = new PVector(648, CURSOR_MAX_Y);

  cursor2 = loadImage("cursor.png");
  c2Vector = new PVector(872, CURSOR_MAX_Y);
  
  cursor3 = loadImage("cursor.png");
  c3Vector = new PVector(1096, CURSOR_MAX_Y);
}

void initFullScreenButtons() {
  enterFullScreenButton = loadImage("btn-enter-fs.png");
  exitFullScreenButton = loadImage("btn-exit-fs.png");
}

void detectMatch1() {
  if (c1Vector.y <= t1Vector.y && millis() > match1TimeEnd) {
    match1TimeEnd = millis() + MATCH_COOLDOWN;
    m1VisibleEnd = millis() + MATCH_DISPLAY_DURATION;
  }
}

void detectMatch2() {
  if (c2Vector.y <= t1Vector.y && millis() > match2TimeEnd) {
    match2TimeEnd = millis() + MATCH_COOLDOWN;
    m2VisibleEnd = millis() + MATCH_DISPLAY_DURATION;
  }
}

void detectMatch3() {
  if (c3Vector.y <= t1Vector.y && millis() > match3TimeEnd) {
    match3TimeEnd = millis() + MATCH_COOLDOWN;
    m3VisibleEnd = millis() + MATCH_DISPLAY_DURATION;
  }
}

void initMatchImages() {
  float imageY = height * 0.4;
  
  match1Image = loadImage("match-good.png");
  m1Vector = new PVector(628, imageY);
  
  match2Image = loadImage("match-good.png");
  m2Vector = new PVector(860, imageY);
  
  match3Image = loadImage("match-good.png");
  m3Vector = new PVector(1080, imageY);
}

void drawTarget() {
  image(targetIcon1, t1Vector.x, t1Vector.y);
  image(targetIcon2, t2Vector.x, t2Vector.y);
}

void drawCursors() {
  image(cursor1, c1Vector.x, c1Vector.y);
  image(cursor2, c2Vector.x, c2Vector.y);
  image(cursor3, c3Vector.x, c3Vector.y);
}

void drawFullScreenButtons() {
  if (isFullScreen) {
    image(exitFullScreenButton, MARGIN, height - MARGIN - BUTTON_HEIGHT);
  } else {
    image(enterFullScreenButton, MARGIN, height - MARGIN - BUTTON_HEIGHT);
  }
}

void drawMatchImages() {
  if (m1VisibleEnd > millis()) {
   image(match1Image, m1Vector.x, m1Vector.y); 
  }
  if (m2VisibleEnd > millis()) {
   image(match2Image, m2Vector.x, m2Vector.y); 
  }
  if (m3VisibleEnd > millis()) {
   image(match3Image, m3Vector.x, m3Vector.y); 
  }
}

void updateCursor(PVector v, float sum) {
  v.y = map(
    sum,
    0., 4.,
    CURSOR_MAX_Y, CURSOR_MIN_Y
  );
}

void updateTarget() {
  float lineY = map(
    matchThreshold,
    0., 4.,
    CURSOR_MIN_Y + 22, CURSOR_MAX_Y
  );

  stroke(255, 221, 0);
  strokeWeight(2);
  line(
    648, lineY,
    1240, lineY
  );

  t1Vector.y = lineY - 20;
  t2Vector.y = t1Vector.y;
}


// event handlers
void mousePressed() {
  // FIXME: unable to toggle full screen
  if (
    mouseX >= MARGIN
    && mouseX <= MARGIN + BUTTON_WIDTH
    && mouseY >= height - MARGIN - BUTTON_HEIGHT
    && mouseY < height - MARGIN
  ) {
    if (!isFullScreen) {
      isFullScreen = true;
      fullScreen();
    } else {
      isFullScreen = false;
    }
  }
}

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
    
    updateCursor(c1Vector, g1ErrorSum);
    updateCursor(c2Vector, g2ErrorSum);
    updateCursor(c3Vector, g3ErrorSum);
  }
}