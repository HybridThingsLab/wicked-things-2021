// libraries
import processing.serial.*;
import oscP5.*; // http://www.sojamo.de/oscP5
import netP5.*;

// osc
OscP5 oscP5;

// serial
Serial port;  // The serial port
int lf = 10;    // Linefeed in ASCII
String stringReceived = "";
String[] values_string = {"", "", "", ""};

Hoverboard h1 = new Hoverboard();
Hoverboard h2 = new Hoverboard();


public void setup() {

  // canvas
  size(800, 800);
  frameRate(60);


  // init osc
  // listen to incoming messages (not needed yet)
  oscP5 = new OscP5(this, 8888);

  // send messages
  h1.remoteLocation = new NetAddress("192.168.1.202", 9999); // change IP HERE
  h2.remoteLocation = new NetAddress("192.168.1.203", 9999); // change IP HERE


  // serial
  // List all the available serial ports
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  port = new Serial(this, Serial.list()[3], 57600);
  port.clear();

  // start value px, py, TODO check (fixed)
  //joystick1
  h1.px = (h1.joystick_max_x - h1.joystick_min_x)/2;
  h1.py = (h1.joystick_max_y - h1.joystick_min_y)/2;
  //joystick2
  h2.px = (h1.joystick_max_x - h1.joystick_min_x)/2;
  h2.py = (h1.joystick_max_y - h1.joystick_min_y)/2;



  // serial
  delay(1000); // bugfix if serial not detected
}


public void draw() {

  // clear background
  background(0);

  // quick and dirty bugfix
  h1.steer = 0;
  h1.speed = 0;
  h2.steer = 0;
  h2.speed = 0;

  // get values from joystick via serial port
  // check if message received
  while (port.available() > 0) {
    stringReceived = port.readStringUntil(lf);
    try {
      if (stringReceived != null) {
        stringReceived = trim(stringReceived); // remove line feed
        //println(stringReceived);
        // split string
        values_string = stringReceived.split(" ");
        // quick bugfix, ToDo CHECK again!
        //println(values_string.length);
        if (values_string.length>3) {
          h1.px = int(values_string[0]);
          h1.py = int(values_string[1]);
          h2.px = int(values_string[2]);
          h2.py = int(values_string[3]);

          // re-map values joystick1
          h1.mapped_px = int(map(h1.px, h1.joystick_min_x, h1.joystick_max_x, 0, width/2));
          h1.mapped_py = int(map(h1.py, h1.joystick_min_y, h1.joystick_max_y, 0, height));

          //easing (value, min, max)
          h1.mapped_px = ease(h1.mapped_px, 0, width/2);
          h1.mapped_py = ease(h1.mapped_py, 0, height);

          h1.steer = int(map(h1.mapped_px, 0, width/2, h1.max_steering * -1, h1.max_steering));
          h1.speed = int(map(h1.mapped_py, 0, height, h1.max_speed * -1, h1.max_speed));  // *-1 vertauscht
          h1.steer = constrain(h1.steer, h1.max_steering * -1, h1.max_steering);
          h1.steer = constrain(h1.steer, h1.max_speed * -1, h1.max_speed);


          // re-map values joystick2
          h2.mapped_px = int(map(h2.px, h2.joystick_min_x, h2.joystick_max_x, width/2, width));
          h2.mapped_py = int(map(h2.py, h2.joystick_min_y, h2.joystick_max_y, 0, height));

          h2.steer = int(map(h2.mapped_px, width/2, width, h2.max_steering * -1, h2.max_steering));
          h2.speed = int(map(h2.mapped_py, 0, height, h2.max_speed, h2.max_speed * -1));
          h2.steer = constrain(h2.steer, h2.max_steering * -1, h2.max_steering);
          h2.steer = constrain(h2.steer, h2.max_speed * -1, h2.max_speed);
        }
      }
    }
    catch (NullPointerException e) {
    }
  }


  // show values on screen joystick1
  fill(255, 0, 0);
  text("px: "+h1.px, 32, 32);
  text("py: "+h1.py, 32, 48);
  text("steer: "+h1.steer, 32, 64);
  text("speed: "+h1.speed, 32, 80);

  // show values on screen joystick2
  fill(255);
  text("px: "+h2.px, width/2 + 10, 32);
  text("py: "+h2.py, width/2 + 10, 48);
  text("steer: "+h2.steer, width/2 + 10, 64);
  text("speed: "+h2.speed, width/2 + 10, 80);


  // show cross center screen   joystick1
  noFill();
  stroke(0, 255, 0);
  line(width/2, 0, width/2, height);
  stroke(255, 0, 0);
  line(0, height/2, width/2, height/2);
  line(width/4, 0, width/4, height);

  // show cross center screen   joystick2
  stroke(255);
  line(width/2, height/2, width, height/2);
  line(width/4*3, 0, width/4*3, height);

  // Show position joystick1
  noStroke();
  fill(255, 0, 0);
  rectMode(CENTER);
  rect(h1.mapped_px, h1.mapped_py, 20, 20);

  // Show position joystick2
  noStroke();
  fill(255);
  rectMode(CENTER);
  rect(h2.mapped_px, h2.mapped_py, 20, 20);


  h1.message = new OscMessage("/control");
  h1.message.add(h1.steer); // direction
  h1.message.add(h1.speed); // speed (0-1023)
  oscP5.send(h1.message, h1.remoteLocation);

  h2.message = new OscMessage("/control");
  h2.message.add(h2.steer); // direction
  h2.message.add(h2.speed); // speed (0-1023)
  oscP5.send(h2.message, h2.remoteLocation);

  // heart beat (emergency stop)
  if (frameCount%10 == 0) {
    h1.message = new OscMessage("/heartbeat");
    oscP5.send(h1.message, h1.remoteLocation);

    h2.message = new OscMessage("/heartbeat");
    oscP5.send(h2.message, h2.remoteLocation);
  }
}

int ease(int v, int min, int max) {
  float value = float(v);
  value = map(value, min, max, 0, 1);

  // easing HERE
  // see different functions here https://easings.net/de

  // value = value < 0.5 ? 16 * value * value * value * value * value : 1 - pow(-2 * value + 2, 5) / 2; // easeInOutQuint
  value =  value < 0.5 ? 2 * value * value : 1 - pow(-2 * value + 2, 2) / 2; // easeInOutQuad;

  return int(map(value, 0, 1, min, max));
}
