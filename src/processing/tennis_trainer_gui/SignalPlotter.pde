class SignalPlotter {

  // constants
  color MONITOR_FRAME = color(130, 27, 0, 100);

  // positions variables
  int x;
  int y;
  int w;
  int h;
  float stepSize;

  // values variables
  float[] values;
  int historyLength;
  int index;

  color signalColor;


  // constructor
  SignalPlotter(int _x, int _y, int _w, int _h, int _hl, color _c) {
    // assign params
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    historyLength = _hl;
    signalColor = _c;
    
    // init
    values = new float[historyLength];
    index = 0;
    stepSize = w / (float)historyLength;
  }


  // methods definitions
  float[] addAtEnd(float[] array, float value) {
    float[] updatedArray = new float[array.length];
  
    int lastIndex = array.length - 1;
    int shiftedIndex = -1;
  
    // shift existing content
    for (int i = lastIndex; i > 0; i--) {
      shiftedIndex = i - 1;
      updatedArray[shiftedIndex] = array[i];
    }
    
    // add new value at end of index
    updatedArray[lastIndex] = value;
    
    return updatedArray;
  }

  void draw() {
    if (values.length == 0) {
      return;
    }
    
    // draw monitor bottom frame
    stroke(MONITOR_FRAME);
    line(
      x, y,
      x + w,
      y
    );

    // draw signal
    stroke(signalColor);
    for(int i = 1; i < historyLength; i++) {
      int prevIndex = i - 1;
      line(
        x + stepSize * i,
        y - values[prevIndex] * h,
        x + stepSize * (i + 1),
        y - values[i] * h
      );
    }
  }

  float[] getComparedValues(float[] otherValues) {
    // error checking
    if (otherValues.length != historyLength) {
      println(
        "Error at SignalPlotter#getComparedValues: "
        + "The array of values must be of the same length as historyLength"
      );
      return null;
    }

    // create return values
    float[] comparedValues = new float[historyLength];
    
    // loop through values
    for(int i = 0; i < historyLength; i++) {
      comparedValues[i] = otherValues[i] - values[i];
    }
    
    return comparedValues;
  }

  float getMean() {
    float sum = 0;
    for (int i = 0; i < historyLength; i++) {
      sum += values[i];
    }
    return sum / historyLength;
  }

  float[] getRange() {
    float[] r = new float[2];
    r[0] = min(values);
    r[1] = max(values);
    return r;
  }

  float getRangeSize() {
    float[] r = getRange();
    return abs(r[1] - r[0]);
  }

  void setValues(float[] newValues) {
    if (newValues.length != historyLength) {
      println(
        "Error at SignalPlotter#update: "
        + "The array of values must be of the same length as historyLength"
      );
      return;
    }
    
    values = newValues;
  }

  void update(float newValue) {
    values = addAtEnd(values, newValue);
  }
}
