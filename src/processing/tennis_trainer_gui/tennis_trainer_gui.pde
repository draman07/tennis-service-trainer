import controlP5.*;
import netP5.*;
import oscP5.*;
import processing.serial.*;


// port vars
int PORT_INDEX = 3; // TODO: set to appropriate value
int BAUD_RATE = 9600;
int GYRO_DATA_LENGTH = 6;

Serial port;


// osc vars
String OSC_ADDRESS = "/tennis";
String RECIPIENT_IP = "127.0.0.1";
int RECIPIENT_PORT = 9600;
int LISTENING_PORT = 12800;
OscP5 osc;
NetAddress recipient;


// control vars
ControlP5 ctrl;

int BUTTON_WIDTH = 128;
int BUTTON_HEIGHT = 32;

String START_REC_LABEL = "Start Recording";
String STOP_REC_LABEL = "Stop Recording";
Slider matchThresholdSlider;

String SLIDER_LABEL = "Match Threshold";
Button startRecButton;
Button stopRecButton;

String START_SIM_LABEL = "Start Simulation";
String STOP_SIM_LABEL = "Stop Simulation";
String RESET_SIM_LABEL = "Reset Simulation";
Button startSimButton;
Button stopSimButton;
Button resetSimButton;
Boolean isSimulatingSignal = false;
float sineStep = 0;
float sineValue = 0;

Boolean isRecording = false;
Boolean hasRecording = false;


// signal monitors
int HISTORY_LENGTH = 160;
float GYRO_SCALE = 1000.;

SignalPlotter[] gyroMonitors;
int[] MONITOR_X_POSITIONS = {20, 440, 860};

SignalRecorder gesture1Recorder;
SignalRecorder gesture2Recorder;
SignalRecorder gesture3Recorder;
SignalRecorder[] recorders = new SignalRecorder[3];

int targetRecorderIndex = 0;


// match variables
float matchThreshold = 1.75;


// PROCESSING METHODS
void setup() {
  size(1280, 640, P2D);
  frameRate(60);

  initSerialPort();
  initOSC();

  initGUI();

  // monitors
  int margin = 20;
  int monitorWidth = 400;
  int monitorHeight = 100;
  int monitorX = 0;
  int monitorY = 0;

  // gyro monitor
  monitorX = MONITOR_X_POSITIONS[0];
  monitorY = 96;
  initGyroMonitors(
    monitorX, monitorY,
    monitorWidth, monitorHeight
  );

  // rec 1 monitor
  monitorX = MONITOR_X_POSITIONS[0];
  monitorY = 240;
  gesture1Recorder = new SignalRecorder(
    monitorX, monitorY,
    monitorWidth, monitorHeight,
    HISTORY_LENGTH
  );

  // rec 2 monitor
  monitorX = MONITOR_X_POSITIONS[1];
  monitorY = 240;
  gesture2Recorder = new SignalRecorder(
    monitorX, monitorY,
    monitorWidth, monitorHeight,
    HISTORY_LENGTH
  );

  // rec 3 monitor
  monitorX = MONITOR_X_POSITIONS[2];
  monitorY = 240;
  gesture3Recorder = new SignalRecorder(
    monitorX, monitorY,
    monitorWidth, monitorHeight,
    HISTORY_LENGTH
  );

  gesture1Recorder.init();
  gesture2Recorder.init();
  gesture3Recorder.init();

  recorders[0] = gesture1Recorder;
  recorders[1] = gesture2Recorder;
  recorders[2] = gesture3Recorder;
}

void draw() {
  // draw bg
  background(20);

  GyroData g = new GyroData();

  // simulate signal
  if (isSimulatingSignal) {
    sineStep += 0.1;
    sineValue = sin(sineStep);

    g.gyroX = sineValue;
    g.gyroY = sineValue;
    g.gyroZ = sineValue;
    g.init();

  } else {
    // pull data from port
    // only if not during simulation
    if (port != null) {
      while (port.available() > 0) {
        g = pullDataFromPort();
        if (g != null && g.isInit) {
          g.gyroX /= GYRO_SCALE;
          g.gyroY /= GYRO_SCALE;
          g.gyroZ /= GYRO_SCALE;
        }
      }
    }
  }

  // assign gyro values to monitors
  if (g.gyroX != 0. && g.gyroY != 0. && g.gyroZ != 0.) {
    // set values
    gyroMonitors[0].update(g.gyroX);
    gyroMonitors[1].update(g.gyroY);
    gyroMonitors[2].update(g.gyroZ);

    if (isRecording) {
      recorders[targetRecorderIndex].record(
        g.gyroX,
        g.gyroY,
        g.gyroZ
      );
    }
  }

  if (gesture1Recorder.hasRecording) {
    gesture1Recorder.compareToRecording(
      gyroMonitors[0].values,
      gyroMonitors[1].values,
      gyroMonitors[2].values
    );
  }
  if (gesture2Recorder.hasRecording) {
    gesture2Recorder.compareToRecording(
      gyroMonitors[0].values,
      gyroMonitors[1].values,
      gyroMonitors[2].values
    );
  }
  if (gesture3Recorder.hasRecording) {
    gesture3Recorder.compareToRecording(
      gyroMonitors[0].values,
      gyroMonitors[1].values,
      gyroMonitors[2].values
    );
  }

  // draw monitors
  gyroMonitors[0].draw();
  gyroMonitors[1].draw();
  gyroMonitors[2].draw();

  // draw recorders
  gesture1Recorder.draw();
  gesture2Recorder.draw();
  gesture3Recorder.draw();

  sendOSC();
}


// METHODS DEFINITIONS
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
  
  // start recording button
  buttonX = margin;
  buttonY = height - 2 * (BUTTON_HEIGHT + margin);
  startRecButton = ctrl.addButton(START_REC_LABEL)
    .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
    .setPosition(buttonX, buttonY);
  
  // stop recording button
  buttonX += BUTTON_WIDTH + margin;
  stopRecButton = ctrl.addButton(STOP_REC_LABEL)
    .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
    .setPosition(buttonX, buttonY);

  // match threshold slider
  buttonX += BUTTON_WIDTH + margin;
  matchThresholdSlider = ctrl.addSlider(SLIDER_LABEL)
    .setPosition(buttonX, buttonY)
    .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
    .setRange(0.00, 2.50)
    .setValue(matchThreshold)
    .setSliderMode(Slider.FLEXIBLE);
  matchThresholdSlider.getValueLabel()
    .align(ControlP5.RIGHT, ControlP5.TOP_OUTSIDE)
    .setPaddingX(0);
  matchThresholdSlider.getCaptionLabel()
    .align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE)
    .setPaddingX(0);

  // simulate signal buttons
  buttonX = margin;
  buttonY = buttonY + BUTTON_HEIGHT + margin;
  startSimButton = ctrl.addButton(START_SIM_LABEL)
    .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
    .setPosition(buttonX, buttonY);

  buttonX += BUTTON_WIDTH + margin;
  stopSimButton = ctrl.addButton(STOP_SIM_LABEL)
    .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
    .setPosition(buttonX, buttonY);

  buttonX += BUTTON_WIDTH + margin;
  resetSimButton = ctrl.addButton(RESET_SIM_LABEL)
    .setSize(BUTTON_WIDTH, BUTTON_HEIGHT)
    .setPosition(buttonX, buttonY);
}

void initGyroMonitors(int x, int y, int w, int h) {
  gyroMonitors = new SignalPlotter[3]; // x, y, z
  gyroMonitors[0] = new SignalPlotter(
    x, y,
    w, h,
    HISTORY_LENGTH,
    color(204, 255, 0)
  );
  gyroMonitors[1] = new SignalPlotter(
    x, y,
    w, h,
    HISTORY_LENGTH,
    color(255, 204, 0)
  );
  gyroMonitors[2] = new SignalPlotter(
    x, y,
    w, h,
    HISTORY_LENGTH,
    color(204, 0, 255)
  );
}

void initOSC() {
  osc = new OscP5(this, LISTENING_PORT);
  recipient = new NetAddress(RECIPIENT_IP, RECIPIENT_PORT);
}

void initSerialPort() {
  // see https://www.processing.org/reference/libraries/serial/Serial_read_.html
  
  // list all available serial ports
  printArray(Serial.list());

  // error checking
  if (PORT_INDEX > Serial.list().length) {
    return;
  }

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

void resetSimulation() {
  sineStep = 0;
  sineValue = 0;
}

void sendOSC() {
  OscMessage message = new OscMessage(OSC_ADDRESS);

  message.add(gesture1Recorder.errorsSum);
  message.add(gesture1Recorder.lowestErrorsSum);

  message.add(gesture2Recorder.errorsSum);
  message.add(gesture2Recorder.lowestErrorsSum);

  message.add(gesture3Recorder.errorsSum);
  message.add(gesture3Recorder.lowestErrorsSum);

  message.add(matchThreshold);

  osc.send(message, recipient);
}

void setGyroMonitorsX(int _x) {
  gyroMonitors[0].x = _x;
  gyroMonitors[1].x = _x;
  gyroMonitors[2].x = _x;
}

void setMatchThreshold() {
  if (matchThresholdSlider != null) {
    matchThreshold = matchThresholdSlider.getValue();
  }
}

void startRecording() {
  if (isRecording) {
    return;
  }

  println("start recording");

  // set flag
  isRecording = true;
}

void startSimulation() {
  isSimulatingSignal = true;
  resetSimulation();
}

void stopRecording() {
  println("stop recording");
  isRecording = false;
}

void stopSimulation() {
  isSimulatingSignal = false;
}


// EVENT HANDLERS
void controlEvent(ControlEvent event) {
  String controlName = event.getController().getName();

  if (controlName == START_REC_LABEL) {
    startRecording();
  }
  if (controlName == STOP_REC_LABEL) {
    stopRecording();
  }
  if (controlName == SLIDER_LABEL) {
    setMatchThreshold();
  }
  if (controlName == START_SIM_LABEL) {
    startSimulation();
  }
  if (controlName == STOP_SIM_LABEL) {
    stopSimulation();
  }
  if (controlName == RESET_SIM_LABEL) {
    resetSimulation();
  }
}

void keyPressed(KeyEvent event) {
  switch (keyCode) {
    // 1
    case 49:
      targetRecorderIndex = 0;
      break;

    // 2
    case 50:
      targetRecorderIndex = 1;
      break;

    // 3
    case 51:
      targetRecorderIndex = 2;
      break;

    // spacebar
    case 32:
      if (!isRecording) {
        startRecording();
      } else {
        stopRecording();
      }
      break;	
  }
  setGyroMonitorsX(MONITOR_X_POSITIONS[targetRecorderIndex]);
}
