class MidiManager {


  ThreadedMidiSend tms;


  MidiManager(Configgy config) {

    setUpMidiOut(); 
    tms = new ThreadedMidiSend(midiOut);

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
