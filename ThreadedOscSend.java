import oscP5.*;
import netP5.*;


class ThreadedOscSend extends Thread{

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

