
public void handleEvents() {
  if ( haveTriggeredZone1() ){ 
    println("trigger 1");
    // sendMidiNote(zoneSum1%40 + 5); 
  }

  if ( haveTriggeredZone2() ){ 
    println("trigger 2");
    // sendMidiNote(zoneSum2%40 + 10 ); 
  }

  if ( haveTriggeredZone3() ){ 
    println("trigger 3");
    // sendMidiNote(zoneSum3%40 + 15 );

  }

  if ( haveTriggeredZone4() ){ 
    println("trigger 4");
  //  sendMidiNote(zoneSum4%40 + 20 ); 
    String[] args = {"" + ((zoneSum4%40) + 15), "" + millis() };
    sendRenoiseNote(1, 1, zoneSum4%40 + 15, 111,  1000);
  }
}







