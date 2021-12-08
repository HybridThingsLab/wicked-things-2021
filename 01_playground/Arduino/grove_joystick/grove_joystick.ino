/*
  Thumb Joystick demo v1.0
  by:https://www.seeedstudio.com
  connect the module to A0&A1 for using;
*/

// serial output
unsigned long lastSent = 0;
int updateSerial = 10; // interval to send value via serial port

void setup()
{
  Serial.begin(57600);
}

void loop()
{

  // read joystick
  int sensorValue1 = analogRead(A0);
  int sensorValue2 = analogRead(A1);

  // Do not try to send Serial stuff too often, be prevent this by checking when we sent the last time
  if ((millis() - lastSent) > updateSerial) {
    // send values to serial port
    Serial.print(sensorValue2);
    Serial.print(" ");
    Serial.println(sensorValue1);
    // update timestamp last sent
    lastSent = millis();
  }

}
