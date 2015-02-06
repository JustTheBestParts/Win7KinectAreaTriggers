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

There are several code files, each ideally focused on specific responsibilties.

One file has only one method, the one called in `draw` to decide what to do
on each update of the data.

Some helper methods have been created to reduce the need to write certain code.

For example, `haveTriggeredZone1` handles the comparison of zoneSum1 and the
triggering threshold. 

The upside is you get a weak sort of DSL.  The downside is yoou have a number of one-off
methods that would be better handled with more general ones.

When writing about the code for non-techies it would be worth pointing this out, that
when you are creating your own code it can help to create your own DSL like thing to
encapsulte small bits of logic, then when you compose your final handing code it is 
easier to follow.

Same goes for creating files.  On the one hand, using One Big File means you always know
where to look.  However, looking for everything in a large and growing file can get
tedious. It becomes hard to track things.  

Proper code partitioning is non-trivial, so new coders hould not get to worked up over
getting it Just So.  The real goal is to have working code that does what you expect.

Code naming and organizing is important to the extent it serves those goals.

It is similar to organizing paints or other tools.  Yur goal is the work of art, not
an award for organization and neatness.  But we know that some amount of organization and
neatness helps with the real goal, so we do not want to simply ignore that part.

Same goes for OOP. It's a means to an end.   You want code that works, code you can 
understand, code you can come back to a day or week or month later and still work with.

You want to adopt practices that work well for you. If you are working with others you want
something people can live with.


As you code more you'll learn more about design, organization, etc.  You'll hear stuff
from other people, some good some bad.  Keep an open mind, adapt as needed, but don't blindly
follow what others do.  Code on purpose.





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

int[] t1 = {0,    0,    defaultTargetW, defaultTargetH}; // Upper left 
int[] t2 = {0,    hd*4, defaultTargetW, defaultTargetH}; // Upper right
int[] t3 = {wd*4, 0,    defaultTargetW, defaultTargetH}; // Lower left
int[] t4 = {wd*4, hd*4, defaultTargetW, defaultTargetH}; // Lower right


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

  checkTargets();
  drawTargets();


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
      sum += (pixels[y*width+x] >> shiftColorInt) & 0xFF;
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
  drawTarget(t1, col);
  drawTarget(t2, col);
  drawTarget(t3, col);
  drawTarget(t4, col);
}

/***************************************************************/
void checkTargets(){
  loadPixels();
  zoneSum1 = getRectColorSum(t1, shiftColorGreen);
  zoneSum2 = getRectColorSum(t2, shiftColorGreen);
  zoneSum3 = getRectColorSum(t3, shiftColorGreen);
  zoneSum4 = getRectColorSum(t4, shiftColorGreen);
}


/***************************************************************/
boolean haveTriggeredZone1() { return (zoneSum1 > depthThreshold); }
boolean haveTriggeredZone2() { return (zoneSum2 > depthThreshold); }
boolean haveTriggeredZone3() { return (zoneSum3 > depthThreshold); }
boolean haveTriggeredZone4() { return (zoneSum4 > depthThreshold); }


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



