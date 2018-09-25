/**********************************************************************************************
* Pan/Tilt Face Tracking Sketch
* Written by Ryan Owens for SparkFun Electronics
* Uses the OpenCV real-time computer vision  framework from Intel
* Based on the OpenCV Processing Examples from ubaa.net
* This example is released under the Beerware License.
* (Use the code however you'd like, but mention us and by me a beer if we ever meet!)
*
* The Pan/Tilt Face Tracking Sketch interfaces with an Arduino Main board to control
* two servos, pan and tilt, which are connected to a webcam. The OpenCV library
* looks for a face in the image from the webcam. If a face is detected the sketch
* uses the coordinates of the face to manipulate the pan and tilt servos to move the webcam
* in order to keep the face in the center of the frame.
*
* Setup-
* A webcam must be connected to the computer.
* An Arduino must be connected to the computer. Note the port which the Arduino is connected on.
* The Arduino must be loaded with the SerialServoControl Sketch.
* Two servos mounted on a pan/tilt backet must be connected to the Arduino pins 2 and 3.
* The Arduino must be powered by a 9V external power supply.
* 
* Read this tutorial for more information:
**********************************************************************************************/
import hypermedia.video.*;  //Include the video library to capture images from the webcam
import java.awt.Rectangle;  //A rectangle class which keeps track of the face coordinates.
import processing.serial.*; //The serial library is needed to communicate with the Arduino.

OpenCV opencv;  //Create an instance of the OpenCV library.

//Screen Size Parameters
int width = 320;
int height = 240;

// contrast/brightness values
int contrast_value    = 0;
int brightness_value  = 0;

Serial port; // The serial port

//Variables for keeping track of the current servo positions.
char servoTiltPosition = 90;
char servoPanPosition = 90;
//The pan/tilt servo ids for the Arduino serial command interface.
char tiltChannel = 0;
char panChannel = 1;

//These variables hold the x and y location for the middle of the detected face.
int midFaceY=0;
int midFaceX=0;

//The variables correspond to the middle of the screen, and will be compared to the midFace values
int midScreenY = (height/2);
int midScreenX = (width/2);
int midScreenWindow = 10;  //This is the acceptable 'error' for the center of the screen. 

//The degree of change that will be applied to the servo each time we update the position.
int stepSize=1;

void setup() {
  //Create a window for the sketch.
  size( width, height );

  opencv = new OpenCV( this );
  opencv.capture( width, height );                   // open video stream
  opencv.cascade( OpenCV.CASCADE_FRONTALFACE_ALT );  // load detection description, here-> front face detection : "haarcascade_frontalface_alt.xml"

  println(Serial.list()); // List COM-ports (Use this to figure out which port the Arduino is connected to)

  //select first com-port from the list (change the number in the [] if your sketch fails to connect to the Arduino)
  port = new Serial(this, Serial.list()[0], 57600);   //Baud rate is set to 57600 to match the Arduino baud rate.

  // print usage
  println( "Drag mouse on X-axis inside this sketch window to change contrast" );
  println( "Drag mouse on Y-axis inside this sketch window to change brightness" );
  
  //Send the initial pan/tilt angles to the Arduino to set the device up to look straight forward.
  port.write(tiltChannel);    //Send the Tilt Servo ID
  port.write(servoTiltPosition);  //Send the Tilt Position (currently 90 degrees)
  port.write(panChannel);         //Send the Pan Servo ID
  port.write(servoPanPosition);   //Send the Pan Position (currently 90 degrees)
}


public void stop() {
  opencv.stop();
  super.stop();
}



void draw() {
  // grab a new frame
  // and convert to gray
  opencv.read();
  opencv.convert( GRAY );
  opencv.contrast( contrast_value );
  opencv.brightness( brightness_value );

  // proceed detection
  Rectangle[] faces = opencv.detect( 1.2, 2, OpenCV.HAAR_DO_CANNY_PRUNING, 40, 40 );

  // display the image
  image( opencv.image(), 0, 0 );

  // draw face area(s)
  noFill();
  stroke(255,0,0);
  for( int i=0; i<faces.length; i++ ) {
    rect( faces[i].x, faces[i].y, faces[i].width, faces[i].height );
  }
  
  //Find out if any faces were detected.
  if(faces.length > 0){
    //If a face was found, find the midpoint of the first face in the frame.
    //NOTE: The .x and .y of the face rectangle corresponds to the upper left corner of the rectangle,
    //      so we manipulate these values to find the midpoint of the rectangle.
    midFaceY = faces[0].y + (faces[0].height/2);
    midFaceX = faces[0].x + (faces[0].width/2);
    
    //Find out if the Y component of the face is below the middle of the screen.
    if(midFaceY < (midScreenY - midScreenWindow)){
      if(servoTiltPosition >= 5)servoTiltPosition -= stepSize; //If it is below the middle of the screen, update the tilt position variable to lower the tilt servo.
    }
    //Find out if the Y component of the face is above the middle of the screen.
    else if(midFaceY > (midScreenY + midScreenWindow)){
      if(servoTiltPosition <= 175)servoTiltPosition +=stepSize; //Update the tilt position variable to raise the tilt servo.
    }
    //Find out if the X component of the face is to the left of the middle of the screen.
    if(midFaceX < (midScreenX - midScreenWindow)){
      if(servoPanPosition >= 5)servoPanPosition -= stepSize; //Update the pan position variable to move the servo to the left.
    }
    //Find out if the X component of the face is to the right of the middle of the screen.
    else if(midFaceX > (midScreenX + midScreenWindow)){
      if(servoPanPosition <= 175)servoPanPosition +=stepSize; //Update the pan position variable to move the servo to the right.
    }
    
  }
  //Update the servo positions by sending the serial command to the Arduino.
  port.write(tiltChannel);      //Send the tilt servo ID
  port.write(servoTiltPosition); //Send the updated tilt position.
  port.write(panChannel);        //Send the Pan servo ID
  port.write(servoPanPosition);  //Send the updated pan position.
  delay(1);
}



/**
 * Changes contrast/brigthness values
 */
void mouseDragged() {
  contrast_value   = (int) map( mouseX, 0, width, -128, 128 );
  brightness_value = (int) map( mouseY, 0, width, -128, 128 );
}

