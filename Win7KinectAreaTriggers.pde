import java.awt.*;

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

int[] t1= { 0,    0,        defaultTargetW, defaultTargetH};
int[] t2 = {0,    hd*4,     defaultTargetW, defaultTargetH};
int[] t3 = {wd*4, 0,        defaultTargetW, defaultTargetH};
int[] t4 = {wd*4, hd*4,     defaultTargetW, defaultTargetH};


/***********************************************************/
void setup() {
  size(kinectFrameW*2,kinectFrameH);
  tracker = new KinectTracker(this);
  config = new Configgy("config.jsi");

  sendMIDI = config.getBoolean("sendMIDI");
  sendOSC = config.getBoolean("sendOSC");
 
  if (sendOSC) {
    osc = new OscManager(config);
  }

  trackerZoneSizeDelta = config.getInt("trackerZoneSizeDelta");
  trackerThreshholdDelta = config.getInt("trackerThreshholdDelta");
  
  if (sendMIDI) {
     midi = new MidiManager(config);
  }
}


/***************************************************************/
// The values passed in are the same as used to draw the target rectangles
// These are the pper-right corner then the width and height, so
// we need to calc the proper range for x and y
int getRectColorSum( int x1, int y1, int tW, int tH, int shiftColorInt) {
  int sum = 0;

  for(int x = x1;  x < (x1+tW); x++){
    for(int y = y1; y < (y1+tH); y++) {
      sum += (pixels[y*width+x] >> shiftColorInt)  & 0xFF;
    }
  }
  return sum;
}

/***************************************************************/
int getRectColorSum2( int[] coords, int shiftColorInt ) {
  return getRectColorSum( coords[0], coords[1], coords[2], coords[3], shiftColorInt);
}

/***************************************************************/
void drawTarget(int x1, int y1, int x2, int y2, color c) {
  noFill();
  rect(x1, y1, x2, y2);
}

/***************************************************************/
void drawTarget2(int[] coords, color c) {  
  drawTarget(coords[0],coords[1], coords[2], coords[3], c);
}

/***************************************************************/
void drawTargets(){

  // Top left 
  drawTarget2(t1, col);

  // Bottom left
  drawTarget2(t2, col);

  // Top right 
  drawTarget2( t3, col);

  // Bottom right is   
  drawTarget2( t4, col);
}






/***************************************************************/
void draw() {
  background(0);
  tracker.update();
  tracker.display();

  drawTargets();
  checkTargets();
  // TODO: REALLY hacky.  Need to find out why doing this before checking targets
  // triggers things even though the targets appear empty.

  image(tracker.flip, kinectFrameW+1, 0);
  drawGrid();
  println("Zone: " + tracker.getZone() + "; " ); 
  frame.setTitle(" " + int(frameRate ) + " ");
}



/***************************************************************/
void zoneAlert(int zoneNumber, int zoneValue){
  if (sendOSC) {
    osc.sendRenoiseNote(zoneValue%40+45);
  }

  if (sendMIDI) {
    midi.sendMidiNote(zoneValue%40+(zoneNumber+1)*5);
  }

  println("*************************************************************************");
  println("******                           ZONE "+zoneNumber+", value  "+zoneValue+"                      ******");
  println("*************************************************************************");
}

/***************************************************************/
void checkTargets(){
  loadPixels();
  int z1 = getRectColorSum2(t1, shiftColorGreen);
  int z2 = getRectColorSum2(t2, shiftColorGreen);
  int z3 = getRectColorSum2( t3, shiftColorGreen);
  int z4 = getRectColorSum2( t4, shiftColorGreen);

  if (z1 > targetThreshold){ zoneAlert(1, z1); }
  if (z2 > targetThreshold){ zoneAlert(2, z2); }
  if (z3 > targetThreshold){ zoneAlert(3, z3); }
  if (z4 > targetThreshold){ zoneAlert(4, z4); }

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



