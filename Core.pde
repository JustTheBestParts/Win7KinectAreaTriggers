
public void handleEvents() {
  if ( haveTriggeredZone1() ){ 
    println("trigger 1");
    osc.sendRenoiseNote(zoneSum1%40 + 45); 
    midi.sendMidiNote(zoneSum1%40 + 5); 
  }

  if ( haveTriggeredZone2() ){ 
    println("trigger 2");
    osc.sendRenoiseNote(zoneSum2%40 + 45); 
    midi.sendMidiNote(zoneSum2%40 + 10 ); 
  }

  if ( haveTriggeredZone3() ){ 
    println("trigger 3");
    osc.sendRenoiseNote(zoneSum3%40 + 45); 
    midi.sendMidiNote(zoneSum3%40 + 15 );
  }

  if ( haveTriggeredZone4() ){ 
    println("trigger 4");
    osc.sendRenoiseNote(zoneSum4%40 + 45);
    midi.sendMidiNote(zoneSum4%40 + 20 ); 
  }
}







