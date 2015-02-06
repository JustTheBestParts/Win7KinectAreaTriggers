# Win7 Kinect Area Triggers

A Processing sketch to demonstrate using Xbox Kinect depth data to send MIDI and OSC.

There are different versions of the Microsoft Kinect hardware.  The very first one released was for the Xbox 360.  It was almost immediately reverse-engineered and code made available so that it could be used without needing an Xbox 360.

Since it could be added to an existing Xbox 360 the device was sold separately, typically for about US $100 new (if you caught a sale).

Microsoft later released a [Kinect for Windows](http://www.microsoft.com/en-us/kinectforwindows/).  This cost more than than the Xbox version.  It was specifically designed to be used without an Xbox 360, but with a machine running Windows.  It offered better technical specs than the Xbox 360 Kinect.

Later came Kinect for Xbox One.  If you search around a used one might  be available for about US $120.00. New ones seem to be more around US $150.00.

This code is for the very first Kinect, the one for the Xbox 360.   

Microsoft was discontinued making them, but they can still be found.

The project is has so for only been developed and tested on Windows 7, hence the name.  It probably works on on operating systems as well; that will be verified in the future.


## What it does

The sketch grabs depth data from the Kinect.  It looks for objects that fall within in a pre-determined distance from the sensor.  For example, it might be set to look for things that are 2 feet to 4 feet away.  This creates a sort of virtual box or zone into which you, standing a bit further away, can reach or step in to and out of.  Think of it as passing your hand through an invisible wall.

The sketch window shows two images.  On the right is the raw Kinect depth data, rendered in gray scale. 

On the left is shown, in green, anything that has been detected withing this bounding zone.   The image on the right allows you to see where you are in relation to the Kinect.

The image on the left also has some grid lines.  The sketch defines four target zones, one in each corner of the left-side image.

If an object is detected within the bounding zone, and it also passes through one of the grid zones, it triggers some code to do whatever it is you think would be interesting.  

There is code in place to send MIDI and OSC.

## Code structure

You need to know at least _something_ about Processing to fiddle with the sketch.  However, some effort has been made to arrange the code so that people can play around without having to know too many of the ins and outs of Processing.

If you are just starting out then the main code to look at is in `Core.pde`.  It has a single method, `handleEvents`.

Helper methods have been defined to encapsulate assorted behavior and conditions.  For example, `haveTriggeredZone1` will return true or false depending on whether something has been detected within the Kinect boundary range and passed into the grid that defines zone 1 (the upper left corner).

There are classes in place providing methods to send OSC and MIDI.  

A lot of this is still in progress.  The goal is have very simple methods for sending data using OSC and MIDI without having to know too much of the underlying details.

## Configuration

There is a file, `config.jsi`, that holds sketch configuration data.  It uses a format that is basically JSON.  (See [this write-up about Configgy](http://jamesbritt.com/posts/getting-configgy-with-processing.html).)

You use this to define settings for sending OSC and connecting to a MIDI device.  It also holds settings for the Kinect bounding range.








Copyright (c) James Britt / Neurogami

james@neurogami.com


## License


MIT License

See LICENSE.txt

