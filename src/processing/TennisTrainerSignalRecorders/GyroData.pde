class GyroData {
  float gyroX = 0;
  float gyroY = 0;
  float gyroZ = 0;
  
  float accelX = 0;
  float accelY = 0;
  float accelZ = 0;
  
  boolean isInit = false;


  // constructor
  GyroData() {}
  
  void init() {
    this.isInit = true;
  }
  
  String toString() {
    return "[GyroData "
      + "gyroX: " + this.gyroX + ", "
      + "gyroY: " + this.gyroY + ", "
      + "gyroZ: " + this.gyroZ + ", "
      + "accelX: " + this.accelX + ", "
      + "accelY: " + this.accelY + ", "
      + "accelZ: " + this.accelZ
      + "]";
  }
}