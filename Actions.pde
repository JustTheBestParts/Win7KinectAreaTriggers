/*

   The idea is to define what happens based on the state of the kinect data, in such
   a way that it is relatively easy to alter.

   The original sketch just checked for areas that were over some target threshold.
   It woud then call a set of predefined method (four in all).

   Is there a way to get a list of methods that meet some naming convention, then iterate over
   that list to invoke each one?  

Basically:

actionMethods = findAllActionMethods(someActionClass);

for m in actionMethods {
invoke(m);
}


Or something.



 */

import java.io.IOException;
import java.lang.reflect.Method;


class KinectActionSet {

  KinectActionSet() {    
    println("I am a Kinect Action Set");
  }

  /***************************************************************/
  void zoneAlert(int zoneNumber, int zoneValue){
    if (sendOSC) {
      osc.sendRenoiseNote(zoneValue%40+45);
    }

    if (sendMIDI) {
      midi.sendMidiNote(zoneValue%40+(zoneNumber+1)*5);
    }

    println("*************************************************************************");
    println("******                           ZONE "+zoneNumber+", value  "+zoneValue+"                      ******");
    println("*************************************************************************");
  }

  /***************************************************************/
  public void actionZone1() {
    println("actionSayHello()");
    if (zoneSum1 > targetThreshold){ zoneAlert(1, zoneSum1); }
  }

  /***************************************************************/
  public void actionZone2() {
    println("actionZone2()");
    if (zoneSum2 > targetThreshold){ zoneAlert(2, zoneSum2); }
  }

  /***************************************************************/
  public void actionZone3() {
    println("actionZone3()");
    if (zoneSum3 > targetThreshold){ zoneAlert(3, zoneSum3); }
  }

  /***************************************************************/
  public void actionZone4() {
    println("actionZone4()");
    if (zoneSum4 > targetThreshold){ zoneAlert(4, zoneSum4); }
  }

  /***************************************************************/
  public  ArrayList<Method> myActionMethods() {
    // http://www.avajava.com/tutorials/lessons/how-do-i-list-the-public-methods-of-a-class.html

    ArrayList<Method> am = new ArrayList<Method>();
    Class tClass = this.getClass();

    Method[] methods = tClass.getMethods();
    for (int i = 0; i < methods.length; i++) {
      if (  match(methods[i].toString(), "action" ) != null ) {
        println("public action method: " + methods[i]);
        am.add(methods[i]);

      }
    }
    return am; 
  }
}







