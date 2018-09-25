import processing.serial.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.*;



Capture video;
OpenCV opencv;
Serial port; 


void setup() 
{
  size(640, 480);
  video = new Capture(this, 640/2, 480/2);
  opencv = new OpenCV(this, 640/2, 480/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);

  video.start();
  
  //select Arduino com-port
  port = new Serial(this, "COM5", 115200);   //Baud rate is set to 57600 to match the Arduino baud rate.

}

void draw() 
{
  scale(2);
  opencv.loadImage(video);

  image(video, 0, 0 );

  noFill();
  stroke(0, 255, 0);
  strokeWeight(3);
  Rectangle[] faces = opencv.detect();
  //println(faces.length);


  for (int i = 0; i < faces.length; i++) 
  {
    port.write( (faces[i].x+faces[i].width/2) + "," + (faces[i].y+faces[i].height/2) + "\n");
    println((faces[i].x+faces[i].width/2) + "," + (faces[i].y+faces[i].height/2));
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }
}



void captureEvent(Capture c) 
{
  c.read();
}