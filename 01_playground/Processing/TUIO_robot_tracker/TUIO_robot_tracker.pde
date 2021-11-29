// libraries
import oscP5.*; // http://www.sojamo.de/oscP5
import netP5.*;

OscP5 oscP5;
NetAddress remoteLocation;
OscMessage message;


// import the TUIO library
import TUIO.*;
// declare a TuioProcessing client
TuioProcessing tuioClient;

// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;

boolean verbose = false; // print console debug messages
boolean callback = true; // updates only after callbacks

// tracking
float robot_x = 0.0;
float robot_y = 0.0;
float robot_rotation = 0.0;

PVector robot_loc = new PVector(robot_x, robot_y);
PVector mouse_loc = new PVector();
PVector robot_dir = new PVector();
PVector mouse_dir = new PVector();
float angle;

// motor
int generalSpeed = 80;

void setup()
{
  // GUI setup
  size(1080, 720);
  noStroke();
  fill(0);

  // periodic updates
  if (!callback) {
    frameRate(60);
    loop();
  } else noLoop(); // or callback updates

  font = createFont("Arial", 18);
  scale_factor = height/table_size;

  // an implementation of the TUIO callback methods in this class (see below)
  tuioClient  = new TuioProcessing(this);

  // init osc
  // listen to incoming messages (not needed yet)
  oscP5 = new OscP5(this, 8888);
  // send messages
  remoteLocation = new NetAddress("192.168.1.200", 9999); // change IP HERE
}

// within the draw method we retrieve an ArrayList of type <TuioObject>, <TuioCursor> or <TuioBlob>
// from the TuioProcessing client and then loops over all lists to draw the graphical feedback.
void draw()
{
  background(255);
  textFont(font, 18*scale_factor);
  float obj_size = object_size*scale_factor;

  ArrayList<TuioObject> tuioObjectList = tuioClient.getTuioObjectList();



  for (int i=0; i<tuioObjectList.size(); i++) {
    TuioObject tobj = tuioObjectList.get(i);
    stroke(0);
    fill(0, 0, 0);
    pushMatrix();
    translate(tobj.getScreenX(width), tobj.getScreenY(height));
    rotate(tobj.getAngle());
    rect(-obj_size/2, -obj_size/2, obj_size, obj_size);
    popMatrix();
    fill(255, 0, 0);

    // quick and dirty
    robot_x =  tobj.getScreenX(width);
    robot_y = tobj.getScreenY(height);
    robot_rotation = degrees(tobj.getAngle());


    text(""+tobj.getSymbolID()+" "+ robot_rotation, tobj.getScreenX(width), tobj.getScreenY(height));
  }

  // TEST //

  // update rotation
  robot_rotation = robot_rotation * PI/180;

  //set location vectors for object and mouse
  robot_loc.x = robot_x;
  robot_loc.y = robot_y;
  mouse_loc = new PVector(mouseX, mouseY);

  //set direction vectors for object and from object to mouse
  robot_dir.x = cos(robot_rotation);
  robot_dir.y = sin(robot_rotation);
  mouse_dir = mouse_loc.sub(robot_loc);

  //get the angle with positive and negative angles
  float angle_bitte = atan2(robot_dir.x * mouse_dir.y - robot_dir.y * mouse_dir.x, mouse_dir.x + robot_dir.y * mouse_dir.y);
  if (angle_bitte < 0) {
    angle = PVector.angleBetween(robot_dir, mouse_dir) * -1;
  } else if (angle_bitte >= 0) {
    angle = PVector.angleBetween(robot_dir, mouse_dir);
  }

  angle = degrees(angle);

  // viz
  rectMode(CENTER);
  noStroke();
  fill(255, 0, 0);
  rect(mouseX, mouseY, 20, 20);
  fill(0);
  text(angle, mouseX+10, mouseY);


  // control robot

  // rotate to target

  if (abs(angle) >= 20) {

    if (angle > 0) {
      // right
      controlMotor(0, 1, generalSpeed);
      controlMotor(1, 1, generalSpeed);
    }
    if (angle< 0) {
      // left
      controlMotor(0, 0, generalSpeed);
      controlMotor(1, 0, generalSpeed);
    }
  } else {

    // drive to target
    controlMotor(0, 1, generalSpeed);
    controlMotor(1, 0, generalSpeed);
  }
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

// --------------------------------------------------------------
// these callback methods are called whenever a TUIO event occurs
// there are three callbacks for add/set/del events for each object/cursor/blob type
// the final refresh callback marks the end of each TUIO frame


// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  if (verbose) println("add obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle());
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  if (verbose) println("set obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+") "+tobj.getX()+" "+tobj.getY()+" "+tobj.getAngle()
    +" "+tobj.getMotionSpeed()+" "+tobj.getRotationSpeed()+" "+tobj.getMotionAccel()+" "+tobj.getRotationAccel());
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  if (verbose) println("del obj "+tobj.getSymbolID()+" ("+tobj.getSessionID()+")");
}

// --------------------------------------------------------------
// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) {
  if (verbose) println("add cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
  //redraw();
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) {
  if (verbose) println("set cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
    +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
  //redraw();
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  if (verbose) println("del cur "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
  //redraw()
}

// --------------------------------------------------------------
// called when a blob is added to the scene
void addTuioBlob(TuioBlob tblb) {
  if (verbose) println("add blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea());
  //redraw();
}

// called when a blob is moved
void updateTuioBlob (TuioBlob tblb) {
  if (verbose) println("set blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+") "+tblb.getX()+" "+tblb.getY()+" "+tblb.getAngle()+" "+tblb.getWidth()+" "+tblb.getHeight()+" "+tblb.getArea()
    +" "+tblb.getMotionSpeed()+" "+tblb.getRotationSpeed()+" "+tblb.getMotionAccel()+" "+tblb.getRotationAccel());
  //redraw()
}

// called when a blob is removed from the scene
void removeTuioBlob(TuioBlob tblb) {
  if (verbose) println("del blb "+tblb.getBlobID()+" ("+tblb.getSessionID()+")");
  //redraw()
}

// --------------------------------------------------------------
// called at the end of each TUIO frame
void refresh(TuioTime frameTime) {
  if (verbose) println("frame #"+frameTime.getFrameID()+" ("+frameTime.getTotalMilliseconds()+")");
  if (callback) redraw();
}
