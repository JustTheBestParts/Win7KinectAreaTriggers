class ThreadedRenoiseNote extends Thread {
  OscManager om;

  int track;
  int instrument;
  int duration;
  int velocity;
  int note;



  ThreadedRenoiseNote( OscManager _om) {
    om = _om;
  }



  public void setNoteData(int instr, int track, int note, int velocity, int duration ) {

  this.track = track;
  this.instrument = instr;
  this.duration = duration;
  this.velocity = velocity;
  this.note = note;

  }

  public void run() {
    // What does this do? How does it know?
    // When would you want to send a sequence of Renoise OSC messages
    // with a delay between , an dnot want to block on that sequence?
    // Note_on note_off is one.  Maybe the only one.
    // Maybe the class should exist only to send note on/off with a delay?
  
  
    String args[] = {"" + this.instrument, 
                   "" + this.track,  
                   "" + this.note, 
                   "" + this.velocity };

   osc.sendMessage("/renoise/trigger/note_on", "iiii", args);

   println("Sent note " + this.note + " ..");

   try {
    Thread.sleep(this.duration);
   } catch( InterruptedException ie) { }

 String args2[] = {"" + instrument, 
            "" + track,  
            "" + note };
  osc.sendMessage("/renoise/trigger/note_on", "iii", args2);

  }


}
