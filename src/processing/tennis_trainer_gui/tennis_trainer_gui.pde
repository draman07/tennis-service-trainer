import controlP5.*;
import netP5.*;
import oscP5.*;
import processing.serial.*;


// life feed ascii char
int LF = 10;


// position vars
PVector center;


// control vars
int BUTTON_WIDTH = 128;
int BUTTON_HEIGHT = 32;
String START_WEKI_LABEL = "Start Wekinator";
String STOP_WEKI_LABEL = "Stop Wekinator";

ControlP5 ctrl;
Button startWekiButton;
Button stopWekiButton;

Boolean isRecording = false;


// wifi vars

// TODO: change connection type if has wifi
boolean HAS_WIFI = false;


// port vars
int PORT_INDEX = 0; // TODO: set to appropriate value
int BAUD_RATE = 9600;
int GYRO_DATA_LENGTH = 6;

Serial port;


// osc vars
String WEKINATOR_ADDRESS = "127.0.0.1";
String WEKINATOR_MESSAGE = "/wek/gyro";
int LISTENING_PORT = 32000;
int BROADCASTING_PORT = 48000;
OscP5 osc;
NetAddress wekinator;


// processing setup
void setup() {
  size(640, 360);
  center = new PVector(width * 0.5, height * 0.5);
  
  // init according to protocol used
  if (HAS_WIFI) {
    initWiFi();
  } else {
    initSerialPort();
  }
  
  initOSC();
  initGUI();
}

void draw() {
  background(20);
  
  if (isRecording) {
    pullDataFromPort();
  }
}


// methods definitions
void initGUI() {
  int margin = 16;
  int buttonX = margin;
  int buttonY = 0;
  ctrl = new ControlP5(this);
  
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

void initOSC() {
  osc = new OscP5(this, LISTENING_PORT);
  wekinator = new NetAddress(WEKINATOR_ADDRESS, BROADCASTING_PORT);
}

void initSerialPort() {
  // see https://www.processing.org/reference/libraries/serial/Serial_read_.html
  
  // list all available serial ports
  printArray(Serial.list());

  // open port
  String portName = Serial.list()[PORT_INDEX];
  println("proto port name: " + portName);
  port = new Serial(
    this,
    portName,
    BAUD_RATE
  );
}

void initWiFi() {
  // TODO
}

GyroData parsePortData(String raw) {
  // data structure: GyroX, GyroY, GyroZ, AccelX, AccelY, AccelZ
  String temp[] = raw.split(",");
  GyroData g = new GyroData();
  if (temp.length == GYRO_DATA_LENGTH) {
    g.gyroX = float(temp[0]);
    g.gyroY = float(temp[1]);
    g.gyroZ = float(temp[2]);
    g.accelX = float(temp[3]);
    g.accelY = float(temp[4]);
    g.accelZ = float(temp[5]);
    g.init();
  }
  return g;
}

void pullDataFromPort() {
  while (port.available() > 0) {
    String incoming = port.readStringUntil(LF);
    
    GyroData g = new GyroData();
    if (incoming != null) {
      g = parsePortData(incoming);
    }
    
    if (g.isInit) {
      sendToWekinator(g);
    }
  }
}

void sendToWekinator(GyroData g) {
  // create message
  OscMessage message = new OscMessage(WEKINATOR_MESSAGE);
  message.add(g.gyroX);
  message.add(g.gyroY);
  message.add(g.gyroZ);
  message.add(g.accelX);
  message.add(g.accelY);
  message.add(g.accelZ);
  
  osc.send(message, wekinator);
}