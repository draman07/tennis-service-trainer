import controlP5.*;
import netP5.*;
import oscP5.*;


// position vars
PVector center;

// control vars
ControlP5 ctrl;
int BUTTON_WIDTH = 128;
int BUTTON_HEIGHT = 32;
String BUTTON_LABEL = "Send OSC Test Message";
String START_BUTTON_LABEL = "Start Recording";
String STOP_BUTTON_LABEL = "Stop Recording";
String START_WEKI_LABEL = "Start Wekinator";
String STOP_WEKI_LABEL = "Stop Wekinator";


Button testButton;
Button startRecordingbutton;
Button stopRecordingButton;
Button startWekiButton;
Button stopWekiButton;

Boolean isRecordingMouse = false;
Boolean isWeki = false;


// osc vars
String SERVER_ADDRESS = "127.0.0.1";
int LISTENING_PORT = 32000;
int BROADCASTING_PORT = 48000;
OscP5 osc;
NetAddress nodeServer;
NetAddress wekinator;


// processing setup
void setup() {
  size(640, 360);
  center = new PVector(width * 0.5, height * 0.5);
  
  // osc
  osc = new OscP5(this, LISTENING_PORT);
  nodeServer = new NetAddress(SERVER_ADDRESS, BROADCASTING_PORT);
  wekinator = new NetAddress(SERVER_ADDRESS, BROADCASTING_PORT);
  
  // gui
  int margin = 16;
  int buttonX = margin;
  int buttonY = 0;
  ctrl = new ControlP5(this);

  // test btn
  buttonX = margin;
  buttonY = height - (BUTTON_HEIGHT + margin) * 3;
  testButton = ctrl.addButton(BUTTON_LABEL)
    .setSize(BUTTON_WIDTH,BUTTON_HEIGHT)
    .setPosition(buttonX, buttonY);
  

  // start recording button
  buttonX = margin;
  buttonY = height - (BUTTON_HEIGHT + margin) * 2;
  startRecordingbutton = ctrl.addButton(START_BUTTON_LABEL)
    .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
    .setPosition(buttonX, buttonY);
  
  // stop recording button
  buttonX += BUTTON_WIDTH + margin;
  stopRecordingButton = ctrl.addButton(STOP_BUTTON_LABEL)
    .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
    .setPosition(buttonX, buttonY);


  // start weki button
  buttonX = margin;
  buttonY = height - (BUTTON_HEIGHT + margin);
  startWekiButton = ctrl.addButton(START_WEKI_LABEL)
    .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
    .setPosition(buttonX, buttonY);
  
  // stop weki button
  buttonX += BUTTON_WIDTH + margin;
  stopWekiButton = ctrl.addButton(STOP_WEKI_LABEL)
    .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
    .setPosition(buttonX, buttonY);
}

void draw() {
  background(20);
}


// test methods
void sendTestMessage() {
  // create message
  OscMessage message = new OscMessage("/test");
  message.add(123);

  osc.send(message, nodeServer);
}


// mouse methods
void sendMousePosition() {
  // create message
  OscMessage message = new OscMessage("/mouse-position");
  message.add(mouseX);
  message.add(mouseY);

  osc.send(message, nodeServer);
}

void sendStopRecording() {
  OscMessage message = new OscMessage("/stop-recording-mouse-position");
  osc.send(message, nodeServer);
}

void startRecordingMouse() {
  isRecordingMouse = true;
}

void stopRecordingMouse() {
  isRecordingMouse = false;
  sendStopRecording();
}


// weki methods
void sendToWekinator() {
  // create message
  OscMessage message = new OscMessage("/wek/inputs");
  message.add(mouseX);
  message.add(mouseY);

  osc.send(message, wekinator);
}

void startSendingToWeki() {
  isWeki = true;
}

void stopSendingToWeki() {
  isWeki = false;
}


// event handlers
void mouseMoved() {
  if (isRecordingMouse) {
    sendMousePosition();
  }
  if (isWeki) {
    sendToWekinator();
  }
}


void controlEvent(ControlEvent event) {
  String controlName = event.getController().getName();
  
  // test
  if (controlName == BUTTON_LABEL) {
    sendTestMessage();
  }
  
  // mouse
  if (controlName == START_BUTTON_LABEL) {
    startRecordingMouse();
  }
  if (controlName == STOP_BUTTON_LABEL) {
    stopRecordingMouse();
  }
  
  // weki
  if (controlName == START_WEKI_LABEL) {
    startSendingToWeki();
  }
  if (controlName == STOP_WEKI_LABEL) {
    stopSendingToWeki();
  }
}