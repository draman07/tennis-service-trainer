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
}