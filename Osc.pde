import oscP5.*;
import netP5.*;

class OscManager {

  OscP5 oscP5;

  NetAddress oscServer;

  OscMessage msgOn;
  OscMessage msgOff;
  OscMessage msg;


  int onOffDelay = 500;

  int renoiseInstr = 0;
  int renoiseTrack = 1;


  /*
     This code needs to drop the Renoise hard-coded stuff and allow for easier 
     sending of whatever OSC.

     The probelm is that OSC messages come in all shpaes and sizes.

     An ideal solution would allow something like:

     sendOSC( "/my/cool/address/pattern", 0.3, "Some string", 5);

     This would require a Java/Processing method that accepted near-arbitrary arguments.

     That might not be a possible thing.

     The next option might be to pass all that stuff as a single argument, a list thing.


     A third thing might be to use a single carefully-crafted string:

     sendOSC( "/my/cool/address/pattern  0.3 'Some string' 5");

     or something.

     Then some other code would need to figure out what that meant.

     Option 2 is possible: http://stackoverflow.com/questions/16363547/how-to-declare-an-array-of-different-data-types

     but it has a problem in common with option 3: How does the code know the types of OSC arguments?


     There is Ruby code that does some regexy stuff to sort out what something is.

     It feels fragile to try to port it to Java.

     Some othre ideas:

     Require the use to define their OSC calls in some special file.  

     Then call those with runtime values.

Or: Require OSC commands to look like this:

[  "/my/cool/address/pattern", "fsi",  "0.3",  "Some string", "5" ]

An array of strings that use the first 2 items for the address pattern and tag types.


Is there some way to cache any of the evaluation?  Store what we know about an OSC message pattern?

There's still parsing, but splitting the tag type into chars seems easier tha guessing data types.


This approach works, though there is some latency.

What if there were also some arg-specific methods? for example:
* oscInt1(addressPattern,  n1)
* oscInt2(addressPattern,  n1, n2)

Many OSC servers do work with a fairly smallish range of argument options. 

So provide semi-generic "args of these kinds" methods to avoid doing type parsing.



   */
  /***************************************************************/
  OscManager(Configgy config ) {
    println("Creating an OscManager!");
    oscP5 = new OscP5(this, config.getInt("oscListeningPort"));
    oscServer = new NetAddress(config.getString("oscServerIP"), config.getInt("oscServerPort"));
    onOffDelay = config.getInt("onOffDelay");
    sendOSC = config.getBoolean("sendOSC");
  }

  /***************************************************************/
  public void sendMessage(String addrPattern, String tagtypes, String[] args ) {
    println("* send OSC message to " + addrPattern );
    ThreadedOscSend _ts = new ThreadedOscSend(oscP5, oscServer);
    _ts.setMsgData(addrPattern, tagtypes, args);
    new Thread(_ts).start();
  }




    /***************************************************************/
    // The idea is have some tagtype-specific methods, which should
    // be faster since there is no string parsing/converting
/*  public void sendMessageI(String addrPattern, int arg) {
    println("send OSC message to " + addrPattern );
    ThreadedOscSend _ts = new ThreadedOscSend(oscP5, oscServer);
    _ts.setMsgData(addrPattern, arg);
    new Thread(_ts).start();
  }
*/
}

/*
 
The problem: The initial plan was to pass in data then the the threaded thing do the 
message-building off in a thread (i.e. run).

Run calls makeMessage, which assumes the it has to parse a tagtype thing, cast args.

This allows for near-arbitrary OSC messages, but it might be slow.

To speed up certain kinds of OSC messages we want to add methods for building messages
where we already now the arg count and types.

makeMessage needs to be smarter. Or, run needs to know to call a different
method to set of the OscMessage instance.

*/
/***************************************************************/
class ThreadedOscSend extends Thread {

  OscMessage msg;
  String tagtypes;
  String[] args;
  String addressPattern;

  NetAddress remoteOscServer;
  OscP5 oscP5;
  boolean sendOSC = true;
  boolean haveArgs = false;


  /***************************************************************/
  // See if these server things are not available as global stuff thanks to the main sketch
  public ThreadedOscSend(OscP5 oscP5, NetAddress remoteOscServer ){
    this.oscP5 = oscP5;
    this.remoteOscServer = remoteOscServer;
  }

  /***************************************************************/
  public void setMsgData(String addrPattern, String tagtypes, String[] args) {
    addressPattern = addrPattern;
    this.tagtypes = tagtypes;
    this.args = args;
    this.haveArgs  = false;
  }


    /***************************************************************/
  public void setMsgData(String addrPattern, int i) {
    addressPattern = addrPattern;
    this.tagtypes = tagtypes;
    this.args = args;
    this.haveArgs  = false;
  }

  public void makeMessage() {
    String[] types = tagtypes.split("(?!^)");
    int argIdx = 0;

    msg = new OscMessage(addressPattern);

    for( String t : types) {

      switch (t.charAt(0) ) {
        case 'i':
          msg.add( parseInt(args[argIdx++] ));
          break;
        case 'f':
          msg.add( parseFloat(args[argIdx++] ));
          break;
        case 's':
          msg.add( args[argIdx++] );
          break;
      }

    }

  }


  /***************************************************************/
  public void run(){
    makeMessage();
    println("Sending " + msg + " to " + remoteOscServer);
    oscP5.send(msg, remoteOscServer); 
    //    try {
    //    Thread.sleep(this.duration);
    //} catch(InterruptedException ie) {
    //}

    //    oscP5.send(noteOffMsg, remoteOscServer); 
  }
}

/***************************************************************/
/*                  Helper methods                             */


public void sendOSCMessage(String addrPattern, String tagtypes, String[] args ) {
  osc.sendMessage(addrPattern, tagtypes, args);
}

// This one is clearly tool-specific; too bad if you're not using Renoise :)
// However, it should demonstrate how to create a helper method that encapsulates
// multiple OSC messages.
//
// However, this is going to block unless it gets wrapped in  a thread somehow.
// If you have the option to send MIDI notes it might be better to not use OSC for notes.
// OTOH, the Renoise OSC lets you pick the intrument.
//

public void sendRenoiseNote(int instr, int track, int note, int velocity, int duration ) {
   ThreadedRenoiseNote _trn = new ThreadedRenoiseNote(osc);
   _trn.setNoteData(instr, track, note, velocity, duration );

         try {

        new Thread( _trn).start();
        // Need to watch how this effects memory usage.
        // _tms should be destroyed when it all falls out of scope. 
      } catch ( java.util.ConcurrentModificationException eee) {
        println("Threaded Renoise OSC  had a  java.util.ConcurrentModificationException ");

      }
   
}



