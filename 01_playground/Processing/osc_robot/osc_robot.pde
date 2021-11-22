// libraries
import oscP5.*; // http://www.sojamo.de/oscP5
import netP5.*;

OscP5 oscP5;
NetAddress remoteLocation;
OscMessage message;


// motor
int generalSpeed = 1023;

void setup() {
  // size canvas
  size(1000, 700);
  frameRate(60);
  // init osc
  // listen to incoming messages (not needed yet)
  oscP5 = new OscP5(this, 8888);
  // send messages
  remoteLocation = new NetAddress("192.168.1.201", 9999); // change IP HERE
}


void draw() {
  // background
  background(0);
}

// custom function motor
void controlMotor(int ID, int dir, int speed) {
  if (ID==0) {
    message = new OscMessage("/motor1");
    message.add(dir); // direction
    message.add(speed); // speed (0-1023)
    oscP5.send(message, remoteLocation);
  } else {
    message = new OscMessage("/motor2");
    message.add(dir); // direction
    message.add(speed); // speed (0-1023)
    oscP5.send(message, remoteLocation);
  }
}

// key interaction
void keyPressed() {
  switch(keyCode) {
  case 38:
    // forward
    // motor 1 + 2
    controlMotor(0, 1, generalSpeed);
    controlMotor(1, 0, generalSpeed);
    break;
  case 40:
    // backward 
    // motor 1 + 2
    controlMotor(0, 0, generalSpeed);
    controlMotor(1, 1, generalSpeed);
    break;
  case 37: 
    // left
    // motor 1 + 2
    controlMotor(0, 0, generalSpeed);
    controlMotor(1, 0, generalSpeed);
    break;
  case 39: 
    // right
    // motor 1 + 2
    controlMotor(0, 1, generalSpeed);
    controlMotor(1, 1, generalSpeed);
    break;
  case 32: 
    // space / rotate
    // motor 1 + 2
    controlMotor(0, 0, generalSpeed);
    controlMotor(1, 0, generalSpeed);
    break;
  }
}

void keyReleased() {
  // stop
  // motor 1 + 2
  controlMotor(0, 0, 0);
  controlMotor(1, 0, 0);
}


/* incoming osc message are forwarded to the oscEvent method. */
/*void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/send")==true) {
    receivedData = theOscMessage.get(0).intValue();
  }
}*/
