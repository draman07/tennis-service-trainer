#include "SparkFunLSM6DS3.h"
#include "Wire.h"


LSM6DS3 myIMU( I2C_MODE, 0x6A );  //I2C device address 0x6A


void setup() {
  // init serial
  Serial.begin(9600);  

  myIMU.begin();
}

void loop() {
  // gyro values
  Serial.print(myIMU.readFloatGyroX(), 1);
  Serial.print(",");
  Serial.print(myIMU.readFloatGyroY(), 1);
  Serial.print(",");
  Serial.print(myIMU.readFloatGyroZ(), 1);

/*
  // accelerometer values
  Serial.print(",");

  Serial.print(myIMU.readFloatAccelX(), 2);
  Serial.print("\t");
  Serial.print(myIMU.readFloatAccelY(), 2);
  Serial.print("\t");
  Serial.print(myIMU.readFloatAccelZ(), 2);
  */

  Serial.println();
  delay(25);
}
