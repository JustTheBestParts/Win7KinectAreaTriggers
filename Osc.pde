import oscP5.*;
import netP5.*;

class OscManager {

  OscP5 oscP5;

  NetAddress oscServer;

  OscMessage msgOn;
  OscMessage msgOff;

  int onOffDelay = 500;

  ThreadedOscSend ts;

  int renoiseInstr = 0;
  int renoiseTrack = 1;

   OscManager(Configgy config ) {
     println("Creating an OscManager!");
    oscP5 = new OscP5(this, config.getInt("oscListeningPort"));
    oscServer = new NetAddress(config.getString("oscServerIP"), config.getInt("oscServerPort"));
    onOffDelay = config.getInt("onOffDelay");
  }

  public void sendRenoiseNote(int note){
    ts = new ThreadedOscSend(oscP5, oscServer);
    ts.setMessageData(note, renoiseTrack, renoiseInstr, onOffDelay);
    // Problem: Seems P5 `thread` only accepts methods that are deinfed in the
    // main class (perhaps because it is doing some invokeMethod thing or whatever.
    
    thread("executeOscSend");
  }

  void executeOscSend() {
    ts.run();
  }

}
