#include <Wire.h>
#include "DFRobot_BloodOxygen_S.h"
#include <OneWire.h>
#include <DallasTemperature.h>
#include <ArduinoBLE.h>

// -------------------- MAX30102 --------------------
#define I2C_ADDRESS 0x57
DFRobot_BloodOxygen_S_I2C MAX30102(&Wire, I2C_ADDRESS);

// -------------------- DS18B20 --------------------
#define ONE_WIRE_BUS 3
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

// -------------------- BLE Setup --------------------
BLEService healthService("180D"); // Custom service
BLECharacteristic dataCharacteristic("2A37", BLERead | BLENotify, 64); // Heart Rate Measurement characteristic

void setup() {
  Serial.begin(115200);

  // Start BLE
  if (!BLE.begin()) {
    Serial.println("BLE init failed!");
    while (1);
  }

  BLE.setLocalName("HealthMonitor");
  BLE.setAdvertisedService(healthService);
  healthService.addCharacteristic(dataCharacteristic);
  BLE.addService(healthService);
  dataCharacteristic.writeValue("Waiting for data...");
  BLE.advertise();
  Serial.println("BLE device is now advertising");

  // Initialize MAX30102
  if (!MAX30102.begin()) {
    Serial.println("MAX30102 init failed!");
    while (1);
  }
  Serial.println("MAX30102 init success!");
  MAX30102.sensorStartCollect();

  // Initialize DS18B20
  sensors.begin();
}

void loop() {
  BLEDevice central = BLE.central();

  if (central) {
    Serial.print("Connected to central: ");
    Serial.println(central.address());

    while (central.connected()) {
      // Read from sensors
      MAX30102.getHeartbeatSPO2();
      float spo2 = MAX30102._sHeartbeatSPO2.SPO2;
      float heartRate = MAX30102._sHeartbeatSPO2.Heartbeat;
      float maxTemp = MAX30102.getTemperature_C();

      sensors.requestTemperatures();
      float dsTemp = sensors.getTempCByIndex(0);

      // Format data as a string
      String bleData = "HR:" + String(heartRate, 0) + " bpm | SpO2:" + String(spo2, 0) +
                       " % | T1:" + String(maxTemp, 1) + "C | T2:" + String(dsTemp, 1) + "C";

      // Send via BLE
      dataCharacteristic.writeValue(bleData.c_str());
      Serial.println(bleData);

      delay(1000);
    }

    Serial.println("Disconnected from central");
  }
} 