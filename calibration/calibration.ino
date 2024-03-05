#include <Arduino_BMI270_BMM150.h>

void setup() {
  Serial.begin(9600);
  if(!IMU.begin()) {
    Serial.println("Failed to initialise IMU");
    // Stop if unable to access IMU
    while(true);
  }
}

void loop() {
  float ax, ay, az; //  Acceleration 
  float gx, gy, gz; // Angular velocity
  float mx, my, mz; // Magnetometer

  // Read IMU data
  if (IMU.accelerationAvailable() && IMU.gyroscopeAvailable() && IMU.magneticFieldAvailable()) {
    IMU.readAcceleration(ax, ay, az);  // g
    IMU.readGyroscope(gx, gy, gz);     // dps
    IMU.readMagneticField(mx, my, mz); // uT
  }

  // Print results
  Serial.print(String(ax) + " " + String(ay) + " " + String(az) + " ");
  Serial.print(String(gx) + " " + String(gy) + " " + String(gz) + " ");
  Serial.println(String(mx) + " " + String(my) + " " + String(mz));
}