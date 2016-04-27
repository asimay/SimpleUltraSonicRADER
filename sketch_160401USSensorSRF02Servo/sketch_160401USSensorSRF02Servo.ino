/*
  Ultrasonic sensor x Servo motor

  Command for reference:http://robot-electronics.co.uk/htm/srf02techI2C.htm
  Connection:
  SRF02       Arduino
  5v Vcc    -> 5V
  SDA       -> A4
  SCL       -> A5
  Mode      -> no connection
  0v Ground -> GND

*/

#include <Wire.h>
#include <Servo.h>

Servo servo;
int angle = 90;
int angleStep = 3;

unsigned long pastMillis = millis();

void setup()
{
  Wire.begin();                // join i2c bus (address optional for master)

  Serial.begin(9600);          // start serial communication at 9600bps

  servo.attach(3);
  servo.write(angle);
  delay(1000);
}

int reading = 0;

void loop()
{
  //  if (millis() - pastMillis > 100) {
  //    pastMillis = millis();
  //    angle += angleStep;
  //    if (angle > 150 || angle < 30) angleStep *= -1;
  //    servo.write(angle);
  //    delay(100);
  //  }

  pastMillis = millis();
  angle += angleStep;
  if (angle > 150 || angle < 30) {
    angleStep++;
    angleStep *= -1;
  }
  servo.write(angle);

  Serial.print(getDistanceFromUSSensor());
  Serial.print(",");
  Serial.print(angle);
  Serial.print("\n");
}

int getDistanceFromUSSensor() {
  // step 1: instruct sensor to read echoes
  Wire.beginTransmission(112); // transmit to device #112 (0x70)
  // the address specified in the datasheet is 224 (0xE0)
  // but i2c adressing uses the high 7 bits so it's 112
  Wire.write(byte(0x00));      // sets register pointer to the command register (0x00)
  Wire.write(byte(0x51));      // command sensor to measure in "centimeters" (0x51)
  // use 0x51 for centimeters
  // use 0x52 for ping microseconds
  Wire.endTransmission();      // stop transmitting

  // step 2: wait for readings to happen
  delay(70);                   // datasheet suggests at least 65 milliseconds

  // step 3: instruct sensor to return a particular echo reading
  Wire.beginTransmission(112); // transmit to device #112
  Wire.write(byte(0x02));      // sets register pointer to echo #1 register (0x02)
  Wire.endTransmission();      // stop transmitting

  // step 4: request reading from sensor
  Wire.requestFrom(112, 2);    // request 2 bytes from slave device #112

  // step 5: receive reading from sensor
  if (2 <= Wire.available())   // if two bytes were received
  {
    reading = Wire.read();  // receive high byte (overwrites previous reading)
    reading = reading << 8;    // shift high byte to be high 8 bits
    reading |= Wire.read(); // receive low byte as lower 8 bits
    return reading;
  } else {
    return 0;
  }
}
