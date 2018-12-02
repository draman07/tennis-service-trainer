import java.util.Date;

import controlP5.*;
import processing.serial.*;


// position vars
PVector center;


// control vars
int BUTTON_WIDTH = 128;
int BUTTON_HEIGHT = 32;

ControlP5 ctrl;

// wekinator control vars
String START_REC_LABEL = "Start Recording";
String STOP_REC_LABEL = "Stop Recording";
Button startRecButton;
Button stopRecButton;
Boolean isRecording = false;


// port vars
int PORT_INDEX = 3; // TODO: set to appropriate value
int BAUD_RATE = 9600;
int GYRO_DATA_LENGTH = 6;

Serial port;


// output json
String jsonString;
JSONObject json;


// signal monitors
SignalPlotter[] gyroMonitors;
SignalPlotter[] accelMonitors;
float gyroScale = 1000.;


// PROCESSING SETUP
void setup() {
  size(640, 360);
  center = new PVector(width * 0.5, height * 0.5);
  
  initSerialPort();
  initGUI();
  initGyroMonitors();
}

void draw() {
  // draw bg
  background(20);
  
  if (isRecording) {
    // pull from port
    while (port.available() > 0) {
      GyroData g = pullDataFromPort();
      
      if (g != null && g.isInit) {
        //addToJSON(g);
        
        gyroMonitors[0].update(g.gyroX / gyroScale);
        gyroMonitors[1].update(g.gyroY / gyroScale);
        gyroMonitors[2].update(g.gyroZ / gyroScale);
      }
    }
  }
  
  gyroMonitors[0].draw();
  gyroMonitors[1].draw();
  gyroMonitors[2].draw();
}


// METHODS DEFINITIONS
void addToJSON(GyroData g) {
  // create date for timestamp
  Date now = new Date();
  
  // add to string
  jsonString += "{"
    + "gx:" + g.gyroX
    + "gy:" + g.gyroY
    + "gz:" + g.gyroZ
    + "ax:" + g.accelX
    + "ay:" + g.accelY
    + "az:" + g.accelZ
    + "'timestamp':" + now.getTime()
  + "},";
}

void initGUI() {
  int margin = 16;
  int buttonX = margin;
  int buttonY = 0;
  ctrl = new ControlP5(this);
  
  // start weki button
  buttonX = margin;
  buttonY = height - (BUTTON_HEIGHT + margin);
  startRecButton = ctrl.addButton(START_REC_LABEL)
    .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
    .setPosition(buttonX, buttonY);
  
  // stop weki button
  buttonX += BUTTON_WIDTH + margin;
  stopRecButton = ctrl.addButton(STOP_REC_LABEL)
    .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
    .setPosition(buttonX, buttonY);
}

void initGyroMonitors() {
  int monitorX = 16;
  int monitorY = 160;
  int monitorW = width - 32;
  int monitorH = 100;
  int histLen = 100;
  
  gyroMonitors = new SignalPlotter[3]; // x, y, z
  gyroMonitors[0] = new SignalPlotter(
    monitorX, monitorY,
    monitorW, monitorH,
    histLen,
    color(204, 255, 0)
  );
  gyroMonitors[1] = new SignalPlotter(
    monitorX, monitorY,
    monitorW, monitorH,
    histLen,
    color(255, 204, 0)
  );
  gyroMonitors[2] = new SignalPlotter(
    monitorX, monitorY,
    monitorW, monitorH,
    histLen,
    color(204, 0, 255)
  );
}

void initSerialPort() {
  // see https://www.processing.org/reference/libraries/serial/Serial_read_.html
  
  // list all available serial ports
  printArray(Serial.list());

  // open port
  String portName = Serial.list()[PORT_INDEX];
  println("Connecting to port name: " + portName);
  port = new Serial(
    this,
    portName,
    BAUD_RATE
  );
  port.bufferUntil('\n');
}

void initWiFi() {
  // TODO
}

GyroData parsePortData(String raw) {
  // data structure: GyroX, GyroY, GyroZ, AccelX, AccelY, AccelZ
  String temp[] = raw.split(",");
  
  GyroData g = new GyroData();

  if (temp.length == GYRO_DATA_LENGTH) {
    g.accelX = float(temp[3]);
    g.accelY = float(temp[4]);
    g.accelZ = float(temp[5]);

  } else if (temp.length == 3) {
    g.gyroX = float(temp[0]);
    g.gyroY = float(temp[1]);
    g.gyroZ = float(temp[2]);
  }

  g.init();
  println(g.toString());

  return g;
}

GyroData pullDataFromPort() {
  String incoming = port.readStringUntil('\n');
  GyroData g = null;
  if (incoming != null) {
    g = parsePortData(incoming);
  }
  return g;
}

void startRecording() {
  if (isRecording) {
    return;
  }
  
  println("start recording");

  // set flag
  isRecording = true;
  
  // start json string
  jsonString = "{'data':[";
}

void stopRecording() {
  println("stop recording");
  
  // set flag
  isRecording = false;
  
  // save json to file
  // TODO
  jsonString += "]}";
  //println(jsonString);
}


// EVENT HANDLERS
void controlEvent(ControlEvent event) {
  String controlName = event.getController().getName();
  
  // weki
  if (controlName == START_REC_LABEL) {
    startRecording();
  }
  if (controlName == STOP_REC_LABEL) {
    stopRecording();
  }
}