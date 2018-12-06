class SignalRecorder {

  // CONSTANTS
  color X_COLOR = color(204, 255, 0);
  color Y_COLOR = color(255, 204, 0);
  color Z_COLOR = color(204, 0, 255);
  int MARGIN_BOTTOM = 144;


  // VARS
  SignalPlotter[] recorders;
  SignalPlotter[] comparators;

  int x = 0;
  int y = 0;
  int monitorWidth = 0;
  int monitorHeight = 0;
  int monHistLength = 100;

  Boolean isInit = false;

  // signal difference variables
  float errorsSum = MIN_FLOAT;
  float lowestErrorsSum = MAX_FLOAT;
  float matchThreshold = 1.75;

  Boolean hasRecording = false;


  // CONSCTRUCTOR
  SignalRecorder(
    int _x, int _y,
    int _monitorWidth, int _monitorHeight,
    int _monHistLength
  ) {

    // assign params
    x = _x;
    y = _y;
    monitorWidth = _monitorWidth;
    monitorHeight = _monitorHeight;
    monHistLength = _monHistLength;
  }


  // METHODS DEFINITIONS
  void init() {
    recorders = initMonitors(recorders, x, y);
    comparators = initMonitors(comparators, x, y + MARGIN_BOTTOM);

    isInit = true;
  }

  Boolean areSignalsMatching() {
    Boolean isMatch = false;

    if (errorsSum <= lowestErrorsSum * matchThreshold) {
      isMatch = true;
    }

    return isMatch;
  }

  void compareToRecording(float[] _xValues, float[] _yValues, float[] _zValues) {
    comparators[0].setValues(recorders[0].getComparedValues(_xValues));
    comparators[1].setValues(recorders[1].getComparedValues(_yValues));
    comparators[2].setValues(recorders[2].getComparedValues(_zValues));

    setErrorsSum();
  }

  void draw() {
    if (!isInit) {
      return;
    }

    if (recorders != null) {
      recorders[0].draw();
      recorders[1].draw();
      recorders[2].draw();
    }

    if (comparators != null) {
      comparators[0].draw();
      comparators[1].draw();
      comparators[2].draw();
    }
  }

  void record(float _x, float _y, float _z) {
    recorders[0].update(_x);
    recorders[1].update(_y);
    recorders[2].update(_z);
    hasRecording = true;
  }


  // PRIVATE METHODS DEFINITIONS
  SignalPlotter[] initMonitors(SignalPlotter[] _monitors, int _x, int _y) {
    _monitors = new SignalPlotter[3]; // x, y, z
    _monitors[0] = new SignalPlotter(
      _x, _y,
      monitorWidth, monitorHeight,
      monHistLength,
      X_COLOR
    );
    _monitors[1] = new SignalPlotter(
      _x, _y,
      monitorWidth, monitorHeight,
      monHistLength,
      Y_COLOR
    );
    _monitors[2] = new SignalPlotter(
      _x, _y,
      monitorWidth, monitorHeight,
      monHistLength,
      Z_COLOR
    );

    return _monitors;
  }

  float getErrorSum(float[] a) {
    float sum = 0;
    for (int i = 0; i < a.length; i++) {
      sum += abs(a[i]);
    };
    return sum / a.length;
  }

  void setErrorsSum() {
    float gxError = getErrorSum(comparators[0].values);
    float gyError = getErrorSum(comparators[1].values);
    float gzError = getErrorSum(comparators[2].values);
    errorsSum = gxError + gyError + gzError;

    // perfect match is impossible,
    // wait for a sum to be more than 0 before setting anything
    if (errorsSum > 0.) {
      lowestErrorsSum = min(lowestErrorsSum, errorsSum);
      // TODO: refresh value at every so often
    }
  }
}
