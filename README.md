# Health Monitoring App with Arduino Nano 33 BLE

This project is a health monitoring system that connects Arduino Nano 33 BLE with DS18B20 temperature sensor and MAX30102 heart rate/SpO2 sensor to a Flutter mobile app via Bluetooth LE.

## Hardware Requirements

1. **Arduino Nano 33 BLE**
2. **Sensors:**
   - DS18B20 Temperature Sensor
   - MAX30102 Heart Rate and SpO2 Sensor
3. **Other components:**
   - 4.7kΩ resistor (for DS18B20)
   - Jumper wires
   - Breadboard

## Arduino Wiring

### DS18B20 Temperature Sensor
- VCC → 3.3V
- GND → GND
- DATA → Digital Pin 2
- 4.7kΩ resistor between VCC and DATA

### MAX30102 Heart Rate and SpO2 Sensor
- VIN → 3.3V
- GND → GND
- SCL → SCL (A5 on Nano)
- SDA → SDA (A4 on Nano)
- INT → Digital Pin 3

## Software Setup

### Arduino Setup
1. Install the required libraries via Arduino Library Manager:
   - ArduinoBLE
   - OneWire
   - DallasTemperature
   - DFRobot_MAX30102
   
2. Upload the provided `arduino_code_guide.ino` to your Arduino Nano 33 BLE.

3. Open the Serial Monitor to verify that sensors are detected and BLE services are advertised.


## Bluetooth LE Services and Characteristics

The app and Arduino use standard Bluetooth GATT services and characteristics where possible:

| Service | UUID | Characteristic | UUID | Description |
|---------|------|----------------|------|-------------|
| Heart Rate | 180D | Heart Rate Measurement | 2A37 | Heart rate data |
| Heart Rate | 180D | SpO2 Measurement | 2A38 | Blood oxygen data |
| Environmental Sensing | 181A | Temperature | 2A6E | Temperature data |

## Troubleshooting

1. **No devices found when scanning:**
   - Make sure Bluetooth is enabled on your mobile device
   - Check if the Arduino is powered and running
   - Verify that permissions are granted in the app

2. **Can't connect to Arduino:**
   - Reset the Arduino
   - Restart the scan in the app
   - Check if the Arduino is still advertising (Serial Monitor)

3. **Connected but no data updates:**
   - Verify sensor wiring
   - Check Arduino Serial Monitor for sensor detection
   - Make sure the sensors are working properly

4. **Temperature sensor not reading:**
   - Check the resistor value (should be 4.7kΩ)
   - Verify wiring, especially the DATA pin connection
   - Try changing the pullup resistor configuration in code

5. **MAX30102 not detected:**
   - Verify I2C connections (SDA/SCL)
   - Check power connections (3.3V)
   - Try different I2C address in the code if needed

## Further Development

- Add more sensors like blood pressure monitor
- Implement data logging and history view
- Add alerts for abnormal readings
- Create user profiles for multiple people

## License

This project is licensed under the MIT License - see the LICENSE file for details.
