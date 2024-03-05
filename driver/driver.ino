#include <ArduinoBLE.h>
#include <Arduino_BMI270_BMM150.h>
#include <MadgwickAHRS.h>

// BLE service name
BLEService EulerAngles("180C");

// BLE characteristics
BLEFloatCharacteristic ble_roll("2A56", BLERead | BLENotify);
BLEFloatCharacteristic ble_pitch("2A57", BLERead | BLENotify);
BLEFloatCharacteristic ble_yaw("2A58", BLERead | BLENotify);

// Madgwick AHRS filter
Madgwick filter;
const float sensorRate = 100.0; // Hz

void setup() {
  // Start serial transmission
  Serial.begin(9600);

  // Stop if unable to access IMU
  if (!IMU.begin()) {
    Serial.println("Failed to initialise IMU");
    while(true);
  }

  // Stop if unable to use BLE
  if (!BLE.begin()) {
    Serial.println("BLE failed to initialise");
    while(true);
  }

  // Set BLE Name
  BLE.setLocalName("Arduino AHRS");
    
  // Set BLE Service Advertisment
  BLE.setAdvertisedService(EulerAngles);
    
  // Add characteristics to BLE Service Advertisment
  EulerAngles.addCharacteristic(ble_roll);
  EulerAngles.addCharacteristic(ble_pitch);
  EulerAngles.addCharacteristic(ble_yaw);

  // Add service to the BLE stack
  BLE.addService(EulerAngles);

  // Start advertising
  BLE.advertise();
  Serial.println("Bluetooth device now active, waiting for connections...");

  // Start the sensor filter
  filter.begin(sensorRate);
  Serial.println("Attitude and heading reference system ready");
}

void loop() {
  float ax, ay, az;       // Acceleration 
  float gx, gy, gz;       // Angular velocity
  float mx, my, mz;       // Magnetometer
  float roll, pitch, yaw; // Orientation

  // Read IMU data
  if (IMU.accelerationAvailable() && IMU.gyroscopeAvailable() && IMU.magneticFieldAvailable()) {
    IMU.readAcceleration(ax, ay, az);  // g
    IMU.readGyroscope(gx, gy, gz);     // dps
    IMU.readMagneticField(mx, my, mz); // uT
  }

  // Update filter
  filter.update(gx, gy, gz, ax, ay, az, mx, my, mz);

  // Check if central device is connected
  BLEDevice central = BLE.central();
  if (central) {
    Serial.print("Connected to central: ");
    Serial.println(central.address());
    while (central.connected()) {

      // Read IMU data
      if (IMU.accelerationAvailable() && IMU.gyroscopeAvailable() && IMU.magneticFieldAvailable()) {
        IMU.readAcceleration(ax, ay, az);  // g
        IMU.readGyroscope(gx, gy, gz);     // dps
        IMU.readMagneticField(mx, my, mz); // uT
      }

      // Compute Euler angles in degrees
      filter.update(gx, gy, gz, ax, ay, az, mx, my, mz);
      roll  = filter.getRoll();
      pitch = filter.getPitch();
      yaw   = filter.getYaw();

      // Write Euler angles to the characteristics
      ble_roll.writeValue(roll);
      ble_pitch.writeValue(pitch);
      ble_yaw.writeValue(yaw);

      // Display attitude in Serial Monitor
      Serial.println("Roll: " + String(roll) + " Pitch: " + String(pitch) + " Yaw: " + String(yaw));
    }
    Serial.print("Disconnected from central: ");
    Serial.println(central.address());
  }
}
