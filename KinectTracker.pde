import SimpleOpenNI.*;

int offset;
int pixel;
int rawDepth;
PImage depthImg;

class KinectTracker {

  PImage flip = new PImage(kinectFrameW, kinectFrameH);

  // int threshold = ;
  int detectionZoneSize = 785; // The area beyond the threshold for detection.

  // Raw location
  PVector loc;

  // Interpolated location

  // Depth data
  int[] depth;

  SimpleOpenNI  kinect;

  PImage display;

  /*********************************************************************************************
   *
   **********************************************************************************************/
  KinectTracker(PApplet owner) {
    kinect = new SimpleOpenNI(owner);
    // kinect.enableScene();
    kinect.enableDepth();
    kinect.setMirror(true);
    //kinect.enableIR();
    display = createImage(kinectFrameW, kinectFrameH, PConstants.RGB);
  }


  /*********************************************************************************************
   *
   **********************************************************************************************/
  PVector getPos() {
    return loc;
  }

  /*********************************************************************************************
   *
   **********************************************************************************************/
  PImage display() {
    PImage newImage = createImage(kinectFrameW, kinectFrameH, RGB);
    // Get the raw depth as array of integers
    depth = kinect.depthMap();

    depthImg = kinect.depthImage();

    if (depth == null ) return(depthImg);

    int pix = 0;
    for (int x = 0; x < kinectFrameW; x++) {
      for (int y = 0; y < kinectFrameH; y++) {
        pixel = x+y*display.width;

        pix = x+y*kinectFrameW;
        rawDepth = depth[pix];
        if ( (rawDepth < depthThreshold) && (rawDepth > depthThreshold - detectionZoneSize ) ) {
          display.pixels[pix] = color(0, 255, 0);
        }
        else {
          display.pixels[pix] = color(0); 
        }
        flip.pixels[pix] = depthImg.pixels[y*kinectFrameW+x];
      }
    }

    display.updatePixels();
    flip.updatePixels();
    image(display, 0, 0);

    return display;
  }


  /*********************************************************************************************
   *
   **********************************************************************************************/
  PImage getDepthImage(){
    return kinect.depthImage();
  }


  /*********************************************************************************************
   *
   **********************************************************************************************/
  void quit() {
    // kinect.quit();
  }

  /*********************************************************************************************
   *
   **********************************************************************************************/
  int getThreshold() {
    return depthThreshold;
  }

  /*********************************************************************************************
   *
   **********************************************************************************************/
  void setThreshold(int t) {
    depthThreshold =  t;
  }

  /*********************************************************************************************
   *
   **********************************************************************************************/
  int getZone() {
    return detectionZoneSize;
  }

  /*********************************************************************************************
   *
   **********************************************************************************************/
  void setZone(int z) {
    detectionZoneSize = z;
  }


  /*********************************************************************************************
   *
   **********************************************************************************************/
  void checkRequireConditions(){

    if(kinect.enableDepth() == false){
      println("Can't open the depthMap, maybe the camera is not connected!"); 
      exit();
      return;
    }

    if(kinect.enableRGB() == false) {
      println("Can't open the rgbMap, maybe the camera is not connected or there is no rgbSensor!"); 
      exit();
      return;
    }

  }


  /*********************************************************************************************
   *
   **********************************************************************************************/
  void update(){
    kinect.update();
  }

}

