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
    new Thread(ts).start();
  }


}


//---------------------------

class ThreadedOscSend extends Thread {

  OscMessage noteOnMsg;
  OscMessage noteOffMsg;
  NetAddress remoteoscServer;
  OscP5 oscP5;

  int note;
  int track;
  int instr;
  int duration;


  // See if these server things are not available as global stuff thanks to the main sketch
  public ThreadedOscSend(OscP5 oscP5, NetAddress remoteoscServer ){
    this.oscP5 = oscP5;
    this.remoteoscServer = remoteoscServer;
  }


  public void  setMessageData(int note, int track, int instr, int duration) {
    this.note = note;
    this.track = track;
    this.instr = instr;
    this.duration = duration;
  }

  public void makeMessages() {

    noteOnMsg = new OscMessage("/renoise/trigger/note_on" );
    noteOnMsg.add(instr); 
    noteOnMsg.add(track);
    noteOnMsg.add(note);
    noteOnMsg.add(125);

    noteOffMsg = new OscMessage("/renoise/trigger/note_off" );
    noteOffMsg.add(instr); 
    noteOffMsg.add(track);
    noteOffMsg.add(note);

  }


  public void run(){
    makeMessages();
    oscP5.send(noteOnMsg, remoteoscServer); 
    try {
      Thread.sleep(this.duration);
    } catch(InterruptedException ie) {
    }
    oscP5.send(noteOffMsg, remoteoscServer); 
  }
}

