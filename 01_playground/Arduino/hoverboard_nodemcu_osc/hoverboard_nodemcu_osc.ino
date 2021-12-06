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


// Install with Sketch > Include Library > Add .ZIP Library
#include <Funken.h>
// instantiation of Funken
Funken fnk;

// debug LCD Screen
#include <Wire.h>
#include "rgb_lcd.h" // https://github.com/Seeed-Studio/Grove_LCD_RGB_Backlight/archive/master.zip
// LCD Display
rgb_lcd lcd;

// include ramp library, https://github.com/siteswapjuggler/RAMP
#include <Ramp.h>
// parameters ramp
rampInt steer_motors;
rampInt speed_motors;
int ramp_time = 150; // time interpolation ramp in milliseconds

// software serial
#include <SoftwareSerial.h>
SoftwareSerial HoverSerial(2, 3);       // RX, TX

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

  // software serial
  HoverSerial.begin(HOVER_SERIAL_BAUD);

  // init funken
  fnk.begin(SERIAL_BAUD, 0, 0); // higher baudrate for better performance
  fnk.listenTo("CONTROL", control); // however you want to name your callback

  // LCD screen
  lcd.begin(16, 2);

  //
  delay(1000);


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
  HoverSerial.write((uint8_t *) &Command, sizeof(Command));
}



// ########################## LOOP ##########################

void loop(void) {

  // needed to make FUNKEN work
  fnk.hark();

  // update ramp
  steer_motors.update();
  speed_motors.update();

  // control hoverboard (steering, speed) > -1000 to 1000
  Send(steer_motors.getValue(), speed_motors.getValue());

}

// ########################## END ##########################

void control(char *c) {

  // get first argument
  char *token = fnk.getToken(c); // is needed for library to work properly, but can be ignored

  // steer
  int steer = atoi(fnk.getArgument(c));

  // speed
  int speed = atoi(fnk.getArgument(c));

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(s teer);
  lcd.setCursor(0, 1);
  lcd.print(speed);

  // update ramp
  steer_motors.go(steer, ramp_time);
  speed_motors.go(speed, ramp_time);


}
