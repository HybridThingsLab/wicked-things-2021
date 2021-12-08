// libraries
import processing.serial.*;
import oscP5.*; // http://www.sojamo.de/oscP5
import netP5.*;

// osc
OscP5 oscP5;
NetAddress remoteLocation;
OscMessage message;

// joystick
int px, py;
int joystick_min_x = 250;
int joystick_max_x = 770;
int joystick_min_y = 250;
int joystick_max_y = 770;

// max steering and speed hoverboard
int max_steering = 300;
int max_speed = 300;
int steer;
int speed;
int mapped_px;
int mapped_py;

// serial
Serial port;  // The serial port
int lf = 10;    // Linefeed in ASCII
String stringReceived = "";
String[] values_string = {"", ""};


public void setup() {

  // canvas
  size(800, 800);
  frameRate(60);

  // init osc
  // listen to incoming messages (not needed yet)
  oscP5 = new OscP5(this, 8888);
  // send messages
  remoteLocation = new NetAddress("192.168.1.202", 9999); // change IP HERE

  // serial
  // List all the available serial ports
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  port = new Serial(this, Serial.list()[3], 57600);
  port.clear();

  // start value px, py
  px = joystick_min_x - joystick_max_x;
  py = joystick_min_y - joystick_max_y;

  // serial
  delay(1000); // bugfix if serial not detected
}


public void draw() {

  // clear background
  background(0);
  
  // quick and dirty bugfix
  steer = 0;
  speed = 0;

  // get values from joystick via serial port
  // check if message received
  while (port.available() > 0) {
    stringReceived = port.readStringUntil(lf);
    try {
      if (stringReceived != null) {
        stringReceived = trim(stringReceived); // remove line feed
        // println(stringReceived);
        // split string
        values_string = stringReceived.split(" ");
        // quick bugfix
        if (values_string.length>1) {
          px = int(values_string[0]);
          py = int(values_string[1]);
          // re-map values
          mapped_px = int(map(px, joystick_min_x, joystick_max_x, 0, width));
          mapped_py = int(map(py, joystick_min_y, joystick_max_y, 0, height));

          steer = int(map(mapped_px, 0, width, -max_steering, max_steering));
          speed = int(map(mapped_py, 0, height, max_speed, -max_speed));
        }
      }
    }
    catch (NullPointerException e) {
    }
  }


  // show values on screen
  fill(255);
  text("px: "+px, 32, 32);
  text("py: "+py, 32, 48);
  text("steer: "+steer, 32, 64);
  text("speed: "+speed, 32, 80);

  // show cross center screen
  noFill();
  stroke(255);
  line(0, height/2, width, height/2);
  line(width/2, 0, width/2, height);

  // Show position
  noStroke();
  fill(255);
  rectMode(CENTER);
  rect(mapped_px, mapped_py, 20, 20);

  message = new OscMessage("/control");
  message.add(steer); // direction
  message.add(speed); // speed (0-1023)
  oscP5.send(message, remoteLocation);

  // heart beat (emergency stop)
  if (frameCount%10 == 0) {
    message = new OscMessage("/heartbeat");
    oscP5.send(message, remoteLocation);
  }
}
