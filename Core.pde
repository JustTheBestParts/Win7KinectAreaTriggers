
public void handleEvents() {
  if (haveTriggeredZone1()){ 
    osc.sendRenoiseNote(zoneSum1%40 + 45); 
    midi.sendMidiNote(zoneSum1%40 + 5); 
  }

  if (zoneSum2 > targetThreshold){ 
    osc.sendRenoiseNote(zoneSum2%40 + 45); 
    midi.sendMidiNote(zoneSum2%40 + 10 ); 
  }

  if (zoneSum3 > targetThreshold){ 
    osc.sendRenoiseNote(zoneSum3%40 + 45); 
    midi.sendMidiNote(zoneSum3%40 + 15 );
  }

  if (zoneSum4 > targetThreshold){ 
    osc.sendRenoiseNote(zoneSum4%40 + 45);
    midi.sendMidiNote(zoneSum4%40 + 20 ); 
  }
}







