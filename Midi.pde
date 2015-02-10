
// http://creativecomputing.cc/p5libs/promidi/

import promidi.*;

class MidiManager {
  MidiIO midiIO;
  MidiOut midiOut;

  MidiOut controllerMidiOut;
  Note note;

  boolean sendMIDI = true;

  /***************************************************************/
  MidiManager(PApplet owner, Configgy config) {
    setUpMidiOut(owner);
    sendMIDI = config.getBoolean("sendMIDI"); 
  }

  /***************************************************************/
  void setUpMidiOut(PApplet owner) {
    midiIO = MidiIO.getInstance(owner); 

    String[] deviceNames = config.getStrings("devices");

    for(int i = 0; i < midiIO.numberOfOutputDevices();i++){
      for(int x=0; x < deviceNames.length; x++) {
        println("Check for device " + deviceNames[x] + " against " + midiIO.getOutputDeviceName(i) );
        if (midiIO.getOutputDeviceName(i).indexOf(deviceNames[x]) > -1 ) {
          println("\tWE HAVE A MATCH ON " + deviceNames[x] );
          midiOut = midiIO.getMidiOut(1, i);
          return;      
        }
      }
    }
  }

  /***************************************************************/
  void sendMidiNote(int note, int velocity, int duration) {
    if (sendMIDI ) {
      ThreadedMidiSend _tms = new ThreadedMidiSend(midiOut);
      _tms.setMessageData("N," + note + "," + velocity + "," + duration);
      try {
        new Thread( _tms ).start();
      } catch ( java.util.ConcurrentModificationException eee) {
        println("Threaded MIDI had a  java.util.ConcurrentModificationException ");
      }
    }
  }

  /***************************************************************/
  void sendMidiCC(int controller, int value ) {
    if (sendMIDI ) {
      ThreadedMidiSend _tms = new ThreadedMidiSend(midiOut);
      _tms.setMessageData("C," + controller + "," + controller + "," + value);
      try {
        new Thread( _tms ).start();
        // Need to watch how this effects memory usage.
        // _tms should be destroyed when it all falls out of scope. 
      } catch ( java.util.ConcurrentModificationException eee) {
        println("Threaded MIDI had a  java.util.ConcurrentModificationException ");

      }
    }
  }


  /***************************************************************/
  void clear() {
    midiOut = null;
  }
}


/*

   Something to note:  First there was ThreadedSend.java (which was then renamed to
   ThreadedOscSend.java.  It is a Java class.

   It was copied and modified to make ThreadedMidiSend.pde.

   Basically the same sort of thing, but it has a pde extension.

   Still, all works. Why?

   Coincidence.

   Changing the extension to java breaks the code because it is using `split(s,s)`

   This is a P5 thing, not available in Java.

   Does it matter? Do we get a proper threaded class either way?


 */

import promidi.*;

class ThreadedMidiSend extends Thread {

  int duration = 500;
  String command;
  String[] messageParts;
  MidiOut midiOut;

  /***************************************************************/
  // See if these server things are not available as global stuff thanks to the main sketch
  public ThreadedMidiSend(MidiOut midiOut){
    this.midiOut = midiOut;
  }

  /***************************************************************/
  public void setMessageData(String midiString) {
    messageParts = split(midiString, ",");
    command = trim(messageParts[0]);
  }

  // Would it make more sense to have seperate threaded classes
  // for each of the kinds of MIDI messages?
  // Probably.  The "Use a string to encode different things"
  // is cleverish but maybe not the best idea.
  /***************************************************************/
  public synchronized void run() {
    /*
http://creativecomputing.cc/p5libs/promidi/index.htm    
There are a lot of changes in the new proMIDI version so you have a new plug method, where you can directly 
plug method that handle the incoming midi data. You no longer need to take care for sending note offs, 
instead you create notes with a length, the notes are buffered and proMIDI automatically send the note off. 
     */
    if (command.equals("N") ) {
      // println("\nPlay note " + messageParts[1] ); // DEBUG
      try {
        midiOut.sendNote(new Note( int(trim(messageParts[1])), int(trim(messageParts[2])), int(trim(messageParts[3])) ));
      } catch ( java.util.ConcurrentModificationException eee) {
        println("Caught java.util.ConcurrentModificationException sending note.");
      } 
      return;
    }

    if (command.equals("PC") ) {
      midiOut.sendProgramChange( new ProgramChange( int(trim(messageParts[1])) ) );
      return;
    }

    if (command.equals("CC") ) {
      // Note that if you send 1 for the channel value that renoise treats it like channel 2.
      midiOut.sendController( new Controller( int(trim(messageParts[1])), int(trim(messageParts[2])) ) );
      return;
    }

  }
}

// Some helper methods so that people who just messing about in Core can more easily send MIDI stuff
/***************************************************************/
void sendMidiNote(int note, int velocity, int duration ) {
  midi.sendMidiNote(note, velocity, duration); 
}

/***************************************************************/
void sendMidiNote(int note) {
  midi.sendMidiNote(note, 127, 2000);
}

/***************************************************************/
void sendMidiCC(int controller, int value) {
  midi.sendMidiCC(controller, value);
}

// void sendMidiSysex(String sysexText ) {
// midi.sendMidiSysex(sysexText)
// }
