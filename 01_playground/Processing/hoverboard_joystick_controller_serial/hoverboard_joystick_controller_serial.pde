// libraries
import org.gamecontrolplus.gui.*; // searchin library manager for "game control plus" and install
import org.gamecontrolplus.*;
import net.java.games.input.*;
import processing.serial.*;

// joystick
ControlIO control;
ControlDevice stick;
float px, py;

// serial
Serial port;  // The serial port

public void setup() {
  size(800, 800);
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

  // serial
  // List all the available serial ports
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  port = new Serial(this, Serial.list()[3], 115200);
  port.clear();

  delay(1000); // bugfix if serial not detected
}

// Poll for user input called from the draw() method.
public void getUserInput() {
  px = map(stick.getSlider("rx").getValue(), -1, 1, 0, width);
  py = map(stick.getSlider("ry").getValue(), -1, 1, 0, height);

  int steer = int(map(px, 0, width,  -300, 300));
  int speed = int(map(py, 0, height, 300, -300));

  // send message to serial port
  port.write("CONTROL");
  port.write(" ");
  port.write(str(steer)); // send integer as string
  port.write(" ");
  port.write(str(speed)); // send integer as string
  port.write("\r\n"); // line feed
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
