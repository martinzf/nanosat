#include <ArduinoBLE.h>
#include <Arduino_BMI270_BMM150.h>

// BLE services
BLEService IMU9DOF("180C");
BLEService RWHEELS("181C");

// BLE IMU characteristic (1D array of floats, for accel (g) + gyro (dps) + mag data (uT))
BLECharacteristic ble_imu("2A56", BLERead | BLENotify, sizeof(float) * 9);

// BLE Wheels characteristic (1D array of unsigned chars for 4 wheels)
BLECharacteristic ble_whl("2A65", BLEWrite | BLENotify, 4);

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
  BLE.setLocalName("Arduino Nanosat");
    
  // Set BLE Service Advertisments
  BLE.setAdvertisedService(IMU9DOF);
  BLE.setAdvertisedService(RWHEELS);
    
  // Add characteristics to IMU BLE Service 
  IMU9DOF.addCharacteristic(ble_imu);

  // Add characteristics to wheels BLE Service
  RWHEELS.addCharacteristic(ble_whl);

  // Add services to the BLE stack
  BLE.addService(IMU9DOF);
  BLE.addService(RWHEELS);

  // Start advertising
  BLE.advertise();
  Serial.println("Bluetooth peripheral active, awaiting connections...");
}

void loop() {
  float a[3];         // Acceleration 
  float g[3];         // Angular velocity
  float m[3];         // Magnetometer
  unsigned char w[4]; // Wheel PWM commands

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

      // Write IMU data to characteristics
      ble_imu.writeValue(a, sizeof(a) + sizeof(g) + sizeof(m));

      // Read, execute and print wheel PWM commands
      ble_whl.readValue(w, sizeof(w));
      analogWrite(A0, w[0]);
      analogWrite(A1, w[1]);
      analogWrite(A2, w[2]);
      analogWrite(A3, w[3]);
      Serial.println("w1: " + String(w[0]) + " w2: " + String(w[1]) + " w3: " + String(w[2]) + " w4: " + String(w[3]));
    }
    Serial.print("Disconnected from central: ");
    Serial.println(central.address());
  }
}