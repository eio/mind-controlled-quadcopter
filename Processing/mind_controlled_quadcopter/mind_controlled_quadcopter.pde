/*
///    Arduino Bluetooth EEG as Controller Interface for AR Parrot Quadcopter Drone

///    Adapted from:
///    [ODC] Processing Example - DroneVideo - Tim Wood and Sterling Crispin 2013 - fishuyo@gmail.com || sterlingcrispin@gmail.com || http://fishuyo.com/ || http://www.sterlingcrispin.com
///    Press 'u' to takeoff and land

///    if you've downloaded this code from the ODC github you may be missing the ODC processing libraries, please visit the ODC website to download them
///    http://www.opendronecontrol.org/
*/

import java.awt.image.BufferedImage;
import org.opendronecontrol.platforms.ardrone.ARDrone;
import org.opendronecontrol.spatial.Vec3;
import scala.collection.immutable.List;
import processing.serial.*;

Serial serial;
int packetCount = 0;
String[] incomingValues;
int[] incVals;
PFont myFont = createFont("Free Sans", 10);

ARDrone drone;  // this creates our drone class
BufferedImage bimg;  // a 2D image from JAVA returns current video frame
 
PImage img;
Vec3 gyro; // storing gyroscope data
boolean flying; 
float droneX;
float droneY;
float droneZ;
float droneYaw;

void setup(){
  size(1280,800, OPENGL);
  
  println(Serial.list());
  serial = new Serial(this, Serial.list()[6], 9600); // port # = [#]
  serial.bufferUntil(10);
  incVals = new int[20];    
  
  drone = new ARDrone("192.168.3.1"); // default IP is 192.168.1.1
  drone.connect();
  gyro = new Vec3(0.0,0.0,0.0);
}

void draw(){
  // print all values as 0 unless there is a signal (i.e. unless incVals[0] isn't 200)
  for (int i = 0; i < 11; i++) {
    if (incVals[0] == 200 && i >= 1) {
      background(0);
      incVals[i] = 0;
    }
  }
  
  // print values
  brainText();
       
  if (drone.hasSensors()){
    flying = drone.sensors().get("flying").bool();
  }
        
 // if EEG "attention" value crosses threshold,
 // make the drone take off
 if (incVals[1] > 35) {  
    if (flying==false) {
      drone.takeOff(); 
    } 
  } else {
     drone.land(); 
  }  
 
}

void serialEvent(Serial p) {
  // Split incoming packet on commas
  // See https://github.com/kitschpatrol/Arduino-Brain-Library/blob/master/README for information on the CSV packet format
  incomingValues = split(p.readString(), ',');

  // Verify that the packet looks legit
  if (incomingValues.length > 1) {
    packetCount++;

    // Wait till the *fourth packet or so to start recording to avoid initialization garbage.
    if (packetCount > 4) {
      for (int i = 0; i < incomingValues.length; i++) {
        int newValue = Integer.parseInt(incomingValues[i].trim());
        incVals[i] = newValue;
        
        //print all values
        //println(incVals[i]);
        //print attention value
        println(incVals[1]);

      }
    }
  }
}

void keyPressed() {
  // keep this here for testing
  if (key == 'u') {
    if (flying == false) {
      drone.takeOff(); 
    } else {
     drone.land(); 
    }
  }
}