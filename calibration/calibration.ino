#include <ArduinoBLE.h>
#include <Arduino_BMI270_BMM150.h>

// BLE service name
BLEService IMU9DOF("180C");

// BLE characteristics
BLEFloatCharacteristic ble_ax("2A56", BLERead | BLENotify);
BLEFloatCharacteristic ble_ay("2A57", BLERead | BLENotify);
BLEFloatCharacteristic ble_az("2A58", BLERead | BLENotify);
BLEFloatCharacteristic ble_gx("2A59", BLERead | BLENotify);
BLEFloatCharacteristic ble_gy("2A60", BLERead | BLENotify);
BLEFloatCharacteristic ble_gz("2A61", BLERead | BLENotify);
BLEFloatCharacteristic ble_mx("2A62", BLERead | BLENotify);
BLEFloatCharacteristic ble_my("2A63", BLERead | BLENotify);
BLEFloatCharacteristic ble_mz("2A64", BLERead | BLENotify);

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
    Serial.println("Failed to initialise BLE");
    while(true);
  }

  // Set BLE Name
  BLE.setLocalName("Arduino Sensors");
    
  // Set BLE Service Advertisment
  BLE.setAdvertisedService(IMU9DOF);
    
  // Add characteristics to BLE Service 
  IMU9DOF.addCharacteristic(ble_ax);
  IMU9DOF.addCharacteristic(ble_ay);
  IMU9DOF.addCharacteristic(ble_az);
  IMU9DOF.addCharacteristic(ble_gx);
  IMU9DOF.addCharacteristic(ble_gy);
  IMU9DOF.addCharacteristic(ble_gz);
  IMU9DOF.addCharacteristic(ble_mx);
  IMU9DOF.addCharacteristic(ble_my);
  IMU9DOF.addCharacteristic(ble_mz);

  // Add service to the BLE stack
  BLE.addService(IMU9DOF);

  // Start advertising
  BLE.advertise();
  Serial.println("Bluetooth peripheral active, awaiting connections...");
}

void loop() {
  float a[3]; // Acceleration 
  float g[3]; // Angular velocity
  float m[3]; // Magnetometer

  // Check if central device is connected
  BLEDevice central = BLE.central();
  if (central) {
    Serial.print("Connected to central: ");
    Serial.println(central.address());
    while (central.connected()) {

      // Read IMU data
      if (IMU.accelerationAvailable() && IMU.gyroscopeAvailable() && IMU.magneticFieldAvailable()) {
        IMU.readAcceleration(a[0], a[1], a[2]);  // g
        IMU.readGyroscope(g[0], g[1], g[2]);     // dps
        IMU.readMagneticField(m[0], m[1], m[2]); // uT
      }

      // Write IMU data to the characteristics
      ble_ax.writeValue(a[0]);
      ble_ay.writeValue(a[1]);
      ble_az.writeValue(a[2]);
      ble_gx.writeValue(g[0]);
      ble_gy.writeValue(g[1]);
      ble_gz.writeValue(g[2]);
      ble_mx.writeValue(m[0]);
      ble_my.writeValue(m[1]);
      ble_mz.writeValue(m[2]);
    }
    Serial.print("Disconnected from central: ");
    Serial.println(central.address());
  }
}