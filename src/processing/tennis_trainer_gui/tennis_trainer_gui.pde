import java.util.Date;

import controlP5.*;
import processing.serial.*;


// position vars
PVector center;


// control vars
ControlP5 ctrl;

int BUTTON_WIDTH = 128;
int BUTTON_HEIGHT = 32;

String START_REC_LABEL = "Start Recording";
String STOP_REC_LABEL = "Stop Recording";
Button startRecButton;
Button stopRecButton;

Boolean isRecording = false;
Boolean hasRecording = false;


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
SignalPlotter[] gyroRecorders;
SignalPlotter[] gyroComparators;

// SignalPlotter[] accelMonitors;
int HISTORY_LENGTH = 160;
float GYRO_SCALE = 1000.;

// float meanGX = null;
// float lowestMeanGX = null;


// PROCESSING SETUP
void setup() {
  size(640, 720);
  center = new PVector(width * 0.5, height * 0.5);
  
  initSerialPort();
  initGUI();
  initGyroMonitors();
  initGyroRecorders();
  initGyroComparators();
}

void draw() {
  // draw bg
  background(20);
  
  // pull data from port
  while (port.available() > 0) {
    GyroData g = pullDataFromPort();
    
    if (g != null && g.isInit) {
      //addToJSON(g);
      
      gyroMonitors[0].update(g.gyroX / GYRO_SCALE);
      gyroMonitors[1].update(g.gyroY / GYRO_SCALE);
      gyroMonitors[2].update(g.gyroZ / GYRO_SCALE);
    }
  }

  if (isRecording) {
    gyroRecorders[0].setValues(gyroMonitors[0].values);
    gyroRecorders[1].setValues(gyroMonitors[1].values);
    gyroRecorders[2].setValues(gyroMonitors[2].values);
  }
  
  if (hasRecording) {
    gyroComparators[0].setValues(gyroRecorders[0].getComparedValues(gyroMonitors[0].values));
    gyroComparators[1].setValues(gyroRecorders[1].getComparedValues(gyroMonitors[1].values));
    gyroComparators[2].setValues(gyroRecorders[2].getComparedValues(gyroMonitors[2].values));

    // float oldMean = meanGX;
    // meanGX = getMean(gyroComparators[0].values);
    // lowestMeanGX = min(oldMean, meanGX);
    // println("current: " + meanGX + ", lowest: " + lowestMeanGX);
  }
  
  // draw monitors
  gyroMonitors[0].draw();
  gyroMonitors[1].draw();
  gyroMonitors[2].draw();
  
  // draw recorders
  gyroRecorders[0].draw();
  gyroRecorders[1].draw();
  gyroRecorders[2].draw();
  
  // draw comparators
  gyroComparators[0].draw();
  gyroComparators[1].draw();
  gyroComparators[2].draw();
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

float getMean(float[] array) {
  float sum = 0;
  for (int i = 0; i < array.length; i++) {
    sum += array[i];
  }
  return sum / array.length;
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
  
  gyroMonitors = new SignalPlotter[3]; // x, y, z
  gyroMonitors[0] = new SignalPlotter(
    monitorX, monitorY,
    monitorW, monitorH,
    HISTORY_LENGTH,
    color(204, 255, 0)
  );
  gyroMonitors[1] = new SignalPlotter(
    monitorX, monitorY,
    monitorW, monitorH,
    HISTORY_LENGTH,
    color(255, 204, 0)
  );
  gyroMonitors[2] = new SignalPlotter(
    monitorX, monitorY,
    monitorW, monitorH,
    HISTORY_LENGTH,
    color(204, 0, 255)
  );
}

void initGyroRecorders() {
  int monitorX = 16;
  int monitorY = 320;
  int monitorW = width - 32;
  int monitorH = 100;
  
  gyroRecorders = new SignalPlotter[3]; // x, y, z
  gyroRecorders[0] = new SignalPlotter(
    monitorX, monitorY,
    monitorW, monitorH,
    HISTORY_LENGTH,
    color(204, 255, 0)
  );
  gyroRecorders[1] = new SignalPlotter(
    monitorX, monitorY,
    monitorW, monitorH,
    HISTORY_LENGTH,
    color(255, 204, 0)
  );
  gyroRecorders[2] = new SignalPlotter(
    monitorX, monitorY,
    monitorW, monitorH,
    HISTORY_LENGTH,
    color(204, 0, 255)
  );
}

void initGyroComparators() {
  int monitorX = 16;
  int monitorY = 480;
  int monitorW = width - 32;
  int monitorH = 100;
  
  gyroComparators = new SignalPlotter[3]; // x, y, z
  gyroComparators[0] = new SignalPlotter(
    monitorX, monitorY,
    monitorW, monitorH,
    HISTORY_LENGTH,
    color(204, 255, 0)
  );
  gyroComparators[1] = new SignalPlotter(
    monitorX, monitorY,
    monitorW, monitorH,
    HISTORY_LENGTH,
    color(255, 204, 0)
  );
  gyroComparators[2] = new SignalPlotter(
    monitorX, monitorY,
    monitorW, monitorH,
    HISTORY_LENGTH,
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

  } else if (temp.length == 3) {
    g.gyroX = float(temp[0]);
    g.gyroY = float(temp[1]);
    g.gyroZ = float(temp[2]);
  }

  g.init();

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
  
  // set flags
  isRecording = false;
  hasRecording = true;
  
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