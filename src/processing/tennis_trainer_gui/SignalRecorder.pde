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
}
