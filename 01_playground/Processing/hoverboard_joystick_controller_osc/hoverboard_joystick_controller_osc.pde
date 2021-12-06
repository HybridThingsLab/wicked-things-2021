// libraries
import org.gamecontrolplus.gui.*; // searchin library manager for "game control plus" and install
import org.gamecontrolplus.*;
import net.java.games.input.*;
import oscP5.*; // http://www.sojamo.de/oscP5
import netP5.*;

// osc
OscP5 oscP5;
NetAddress remoteLocation;
OscMessage message;

// joystick
ControlIO control;
ControlDevice stick;
float px, py;


public void setup() {

  // canvas
  size(800, 800);

  // init osc
  // listen to incoming messages (not needed yet)
  oscP5 = new OscP5(this, 8888);
  // send messages
  remoteLocation = new NetAddress("192.168.1.202", 9999); // change IP HERE


  // Initialise the ControlIO
  control = ControlIO.getInstance(this);
  // Find a device that matches the configuration file
  stick = control.getMatchedDevice("joystick");
  if (stick == null) {
    println("No suitable device configured");
    System.exit(-1); // End the program NOW!
  }
  // Setup a function to trap events for this button
  stick.getButton("SHADOW").plug(this, "dropShadow", ControlIO.ON_RELEASE);


  delay(1000); // bugfix if serial not detected
}

// Poll for user input called from the draw() method.
public void getUserInput() {
  px = map(stick.getSlider("rx").getValue(), -1, 1, 0, width);
  py = map(stick.getSlider("ry").getValue(), -1, 1, 0, height);

  int steer = int(map(px, 0, width, -300, 300));
  int speed = int(map(py, 0, height, 300, -300));

  message = new OscMessage("/control");
  message.add(steer); // direction
  message.add(speed); // speed (0-1023)
  oscP5.send(message, remoteLocation);
}

// Event handler for the SHADOW button
public void dropShadow() {
  // Make sure we have the latest position
  getUserInput();
}

public void draw() {
  getUserInput(); // Polling
  background(0);
  // Show position
  noStroke();
  fill(255);
  rectMode(CENTER);
  rect(px, py, 20, 20);
}
