class Hoverboard {
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
  int max_steering = 380;
  int max_speed = 380;
  int steer;
  int speed;
  int mapped_px;
  int mapped_py;
}
