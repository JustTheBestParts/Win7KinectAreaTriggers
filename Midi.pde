
// http://creativecomputing.cc/p5libs/promidi/
//
import promidi.*;

MidiIO midiIO;
MidiOut midiOut;

MidiOut controllerMidiOut;
Note note;


class MidiManager {


  ThreadedMidiSend tms;


  MidiManager(PApplet owner, Configgy config) {

    setUpMidiOut(owner); 
    tms = new ThreadedMidiSend(midiOut);

  }


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
  void sendMidiNote(int note) {
    tms.setMessageData("N," + note + ",127,5000");
    thread("executeMidiSend"); 
  }


  /***************************************************************/
  void executeMidiSend() {
    tms.run(); 
  }


  void clear() {
    midiOut = null;

  }
}
