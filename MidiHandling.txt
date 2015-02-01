// http://creativecomputing.cc/p5libs/promidi/
//
import promidi.*;

MidiIO midiIO;
MidiOut midiOut;

MidiOut controllerMidiOut;
Note note;

int lastValController1 = 10;
int lastValController2 = 15;

int max1 = 128;
int max2 = 128;

void playNote(int[] values){
  if ( values[0] < 0 ) return;
  // Note(i_pitch, i_velocity, i_length);
  note = new Note( values[0], values[0], values[0] );
  midiOut.sendNote(note);
}


void setUpMidiOut() {
  midiIO = MidiIO.getInstance(this); 

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

void sendMIDI(String midiString ) {

  println("DEBUG: Send the MIDI define in the text field."); // DEBUG

  /*
     The plan is to take a string that encodes some kind of midi message and convert it into the
     correct kind of call.

     We have notes, program changes, and controller messages

     So we split the string on whitespace, and check the first string

     We allow N, PC, and CC



   */

  String[] parts = split(midiString, ",");

  String command = trim(parts[0]);
  println("midiString " + midiString );

  for( String s : parts) {
    print( " " + s );
  }
  if (command.equals("N") ) {
    println("\nPlay note " + parts[1] ); // DEBUG
    midiOut.sendNote(new Note( int(trim(parts[1])), int(trim(parts[2])), int(trim(parts[3])) ));
    return;
  }

  if (command.equals("PC") ) {
    //midiOut.sendProgramChange( new ProgramChange( int(trim(parts[1])), int(trim(parts[2])) ) );
    midiOut.sendProgramChange( new ProgramChange( int(trim(parts[1])) ) );
    return;
  }

  if (command.equals("CC") ) {

    // Note that if you send 1 for the channel value that renoise treats it like channel 2.
    //
    midiOut.sendController( new Controller( int(trim(parts[1])), int(trim(parts[2])) ) );
    return;
  }

}



/* ******************************************



   sendController (Controller controller )
   Use this method to send a control change to the midioutput. 
   You can send control changes to change the sound on midi sound 
   sources for example.


   Controller


   Controller represents a midi controller. It has a number and 
   a value. You can receive Controller values from midi ins and 
   send them to midi outs.


   Controller(i_number, i_value);

   parameters
   i_number
int: number of a controller
i_value
int: value of a controller


Example:

void move(){
xPos += xSpeed;
yPos += ySpeed;
midiOut.sendController( new Controller(0,myNumber,int(xPos/6)+2));
...


sendProgramChange(i_programChange);


parameters
i_programChange
ProgramChange, program change you want to send


ProgramChange(midiChannel, i_number);
ProgramChange represents a midi program change. 
It has a midi port, a midi channel, and a number. 
You can receive program changes from midi inputs and send them 
to midi outputs.

parameters
midiChannel
int: midi channel a program change comes from or is send to
i_number
int: number of the program change


Example:

midiOut.sendProgramChange( new ProgramChange(0,myNumber));


 */
