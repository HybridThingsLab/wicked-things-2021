// *******************************************************************
//  based on Arduino Nano 5V example code
//  for   https://github.com/EmanuelFeru/hoverboard-firmware-hack-FOC
//  Copyright (C) 2019-2020 Emanuel FERU <aerdronix@gmail.com>
//
// *******************************************************************

// ########################## DEFINES ##########################
#define HOVER_SERIAL_BAUD   115200      // [-] Baud rate for HoverSerial (used to communicate with the hoverboard)
#define SERIAL_BAUD         115200     // [-] Baud rate for built-in Serial (used for the Serial Monitor)
#define START_FRAME         0xABCD       // [-] Start frme definition for reliable serial communication
#define TIME_SEND           100         // [ms] Sending time interval
#define SPEED_MAX_TEST      300         // [-] Maximum speed for testing
// #define DEBUG_RX                        // [-] Debug received data. Prints all bytes to serial (comment-out to disable)

// intertval control hoverboard
unsigned long lastSent = 0;
int updateSent = 10; // interval to send value via serial port

// osc library
#include <ArduinoOSC.h> // https://github.com/hideakitai/ArduinoOSC

// WiFi stuff
const char* ssid = "maschinenraum";
const char* pwd = "maschinenraum";
const IPAddress ip(192, 168, 1, 202); // set unique IP (last number e.g. 200) for each robot here!!!
const IPAddress gateway(192, 168, 1, 1);
const IPAddress subnet(255, 255, 255, 0);

// for ArduinoOSC
const int recv_port = 9999;
const int send_port = 8888;

// include ramp library, https://github.com/siteswapjuggler/RAMP
#include <Ramp.h>
// parameters ramp
rampInt steer_motors;
rampInt speed_motors;
int ramp_time = 150; // time interpolation ramp in milliseconds

// serial command
typedef struct {
  uint16_t start;
  int16_t  steer;
  int16_t  speed;
  uint16_t checksum;
} SerialCommand;
SerialCommand Command;


// ########################## SETUP ##########################
void setup()
{

  // serial
  Serial.begin(SERIAL_BAUD);


  // WiFi stuff
  WiFi.begin(ssid, pwd);
  WiFi.config(ip, gateway, subnet);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }

  // osc messages
  OscWiFi.subscribe(recv_port, "/control", [](OscMessage & m) {
    control(m);
  });



}

// ########################## SEND ##########################
void Send(int16_t uSteer, int16_t uSpeed)
{
  // Create command
  Command.start    = (uint16_t)START_FRAME;
  Command.steer    = (int16_t)uSteer;
  Command.speed    = (int16_t)uSpeed;
  Command.checksum = (uint16_t)(Command.start ^ Command.steer ^ Command.speed);

  // Write to Serial
  Serial.write((uint8_t *) &Command, sizeof(Command));
}



// ########################## LOOP ##########################

void loop(void) {

  // should be called to parse incoming OSC messages
  OscWiFi.parse();

  // update ramp
  steer_motors.update();
  speed_motors.update();

  // Do not try to send Serial stuff too often, be prevent this by checking when we sent the last time
  if ((millis() - lastSent) > updateSent) {
    // control hoverboard (steering, speed) > -1000 to 1000
    Send(steer_motors.getValue(), speed_motors.getValue());
    // update timestamp last sent
    lastSent = millis();
  }


}

// ########################## END ##########################

void control(OscMessage m) {

  // steer
  int steer = m.arg<int>(0);

  // speed
  int speed = m.arg<int>(1);

  // update ramp
  steer_motors.go(steer, ramp_time);
  speed_motors.go(speed, ramp_time);

}
