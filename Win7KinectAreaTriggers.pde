/* *******************************************************************

   Sketch to demonstrate using Kinect data to trigger OSC messages.

   The right side of the window shows the raw B&W Kinect data.

   The left side shows only what has been detected as being withing 
   a specified bounding area.

   The left side has a grid-like overlay defining target areas.

   When an object is within the bounding area, and within one of
   the corner target areas, some sort of action is triggered.

   There are custom classes that use threads to allow creating and
   send OSC and MIDI message without bogging down the main sketch.

   There is a config file that defines settings for the OSC, MIDI, and
   the Kinect boundry region.

   There are crude keyboard commands that allow adjusting the bounding 
   area while the sketch is running.

   The idea for this sketch is that a user would stand some distance
   from the Kinect sensor and thrust an arm or hand towards the Kinect
   and into the bounding area, triggering an OSC message.

   The raw data on the right allows this person to know where they are 
   in relation to the Kinect (to avoid blindly flailing about hoping to
   trigger something)

   Target triggering is done by getting Kinect depth data, filtering for only
   those points that are within the bounding area, then rendering the results.

   The sketch then sums the pixel values within each corner target, basically
   looking to see how far it deviates from pure black.  


   The sketch depends on these Processing libraries:

 * SimpleOpenNI
 * oscP5
 * netP5
 * promidi


 A goal of the sketch is provide a useful example that is not too hard to change.

 There is a class that exists to hold methods meant to respond to changes in data.

 The idea is that a user with minimal coding experience need only add/edit specific
 functions that use predefined values.

 It's less than ideal because the class has other stuff in there.  

 Why not just skip the class and have just the methods?  Why not have just one method?

 Put the one method in a separate file, for just that method. No need for clever method
 finding.

 As it is, the Action methods still need to check for conditions.  The advantage to
 having multiple methods is to break things up.  Is that really any better?





 Copyright James Britt / Neurogami 

 james@neurogami.com

Released under the MIT License


******************************************************************* */


import java.lang.reflect.InvocationTargetException;
import java.io.IOException;
import java.lang.reflect.Method;


int depthThreshold = 790;

Configgy config;

int[] depth;

PImage img;

PFont f = createFont("", 10);

KinectTracker tracker;


MidiManager midi;
OscManager osc;



boolean sendOSC  = true;
boolean sendMIDI = true;

int trackerZoneSizeDelta;
int trackerThreshholdDelta;

int shiftColorGreen = 8;

int targetThreshold = 100000;

color col = color(255, 0, 255);

int kinectFrameW = 640;
int kinectFrameH = 480;

int wd = kinectFrameW/6;
int hd = kinectFrameH/6;
int defaultTargetW = wd*2;
int defaultTargetH = hd*2;

int[] t1 = {0,    0,    defaultTargetW, defaultTargetH};
int[] t2 = {0,    hd*4, defaultTargetW, defaultTargetH};
int[] t3 = {wd*4, 0,    defaultTargetW, defaultTargetH};
int[] t4 = {wd*4, hd*4, defaultTargetW, defaultTargetH};


int zoneSum1; 
int zoneSum2; 
int zoneSum3; 
int zoneSum4;


ArrayList<Method> actionMethods;

/***********************************************************/
void setup() {
  size(kinectFrameW*2,kinectFrameH);
  tracker = new KinectTracker(this);
  config = new Configgy("config.jsi");

  sendMIDI = config.getBoolean("sendMIDI");
  sendOSC  = config.getBoolean("sendOSC");
  
  osc  = new OscManager(config);
  midi = new MidiManager(this, config);

  trackerZoneSizeDelta = config.getInt("trackerZoneSizeDelta");
  trackerThreshholdDelta = config.getInt("trackerThreshholdDelta");

}


/***************************************************************/
void draw() {
  background(0);
  tracker.update();
  tracker.display();

  drawTargets();
  checkTargets();

  handleEvents();

  image(tracker.flip, kinectFrameW+1, 0);
  drawGrid();
  println("Zone: " + tracker.getZone() + "; " ); 
  frame.setTitle(" " + int(frameRate ) + " ");
}



/***************************************************************/
// The values passed in are the same as used to draw the target rectangles
// These are the upper-right corner then the width and height, so
// we need to calc the proper range for x and y
int getRectColorSum( int[] coords, int shiftColorInt ) {

  int sum = 0;
  int x1 = coords[0];
  int y1 = coords[1];
  int tW = coords[2];
  int tH = coords[3]; 
  for(int x = x1;  x < (x1+tW); x++){
    for(int y = y1; y < (y1+tH); y++) {
      sum += (pixels[y*width+x] >> shiftColorInt)  & 0xFF;
    }
  }
  return sum;
}

/***************************************************************/
void drawTarget(int[] coords, color c) {  
  noFill();
  rect(coords[0],coords[1], coords[2], coords[3]);
}

/***************************************************************/
void drawTargets(){

  // Top left 
  drawTarget(t1, col);

  // Bottom left
  drawTarget(t2, col);

  // Top right 
  drawTarget( t3, col);

  // Bottom right is   
  drawTarget( t4, col);
}

/***************************************************************/
void checkTargets(){
  loadPixels();
  zoneSum1 = getRectColorSum(t1, shiftColorGreen);
  zoneSum2 = getRectColorSum(t2, shiftColorGreen);
  zoneSum3 = getRectColorSum( t3, shiftColorGreen);
  zoneSum4 = getRectColorSum( t4, shiftColorGreen);
}

/***************************************************************/
boolean haveTriggeredZone1() {
  return zoneSum4 > depthThreshold;
}

/***************************************************************/
void keyPressed() {

  if (key == 'u') {
    tracker.setThreshold(tracker.getThreshold() + trackerThreshholdDelta );
  } 
  else if (key == 'd') {
    tracker.setThreshold(tracker.getThreshold() - trackerThreshholdDelta );
  }
  else if (key == 'U') {
    tracker.setZone(tracker.getZone() + trackerZoneSizeDelta);
  }
  else if (key == 'D') {
    tracker.setZone(tracker.getZone() - trackerZoneSizeDelta );
  }
  else if (key == 'x') {
    stop();
  }

  println("Threshold =  " + tracker.getThreshold() );
  println("Zone =  " + tracker.getZone() );
}


/***************************************************************/
void drawGrid(){
  stroke(240, 200, 100);
  strokeWeight(1);
  // from middle of y, across
  line(0, kinectFrameH/2, kinectFrameW, kinectFrameH/2);
  // from middle of x, and down
  line( kinectFrameW/2, 0, kinectFrameW/2, kinectFrameH);
} 


/***************************************************************/
void stop() {
  if (sendMIDI) { midi.clear(); }
  super.stop();
  super.exit();
}



