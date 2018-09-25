#include <Servo.h>

typedef struct coordinates
{
  int x;
  int y;
}Coordinate;

typedef struct Limits
{
  int Max;
  int Min;
}Limit;


Servo tiltServo;  // create servo object to control a servo
Servo panServo;
Coordinate faceCenter = {640/4, 480/4};
Coordinate actualFace;
Limit panServoLim = {180,0};
Limit tiltServoLim = {175,80};

int pos = 180;             // variable to store the servo position
int midScreenWindow = 20;  // This is the acceptable 'error' for the center of the screen. 
int stepSize = 1;
int panServoPos = 90;
int tiltServoPos = 130;


void setup() 
{
  Serial.begin(115200);
  tiltServo.attach(6);  // attaches the servo on pin 9 to the servo object
  tiltServo.write(tiltServoPos);
  panServo.attach(5);  // attaches the servo on pin 9 to the servo object
  panServo.write(panServoPos);
}

void loop() 
{
  if (Serial.available() > 0) 
  {
    // look for the next valid integer in the incoming serial stream
    actualFace.x = Serial.parseInt();
    actualFace.y = Serial.parseInt();
    if (Serial.read() == '\n') 
    {
        //Find out if the Y component of the face is below the middle of the screen.
        if(actualFace.y < (faceCenter.y - midScreenWindow))
        {
            //If it is below the middle of the screen, update the tilt position variable to lower the tilt servo.
            if(tiltServoPos >= tiltServoLim.Min)
            {
              tiltServoPos -= stepSize; 
            }
        }
        //Find out if the Y component of the face is above the middle of the screen.
        else if(actualFace.y > (faceCenter.y + midScreenWindow))
        {
            //Update the tilt position variable to raise the tilt servo.
            if(tiltServoPos <= tiltServoLim.Max)
            {
              tiltServoPos +=stepSize; 
            }
        }
        //Find out if the X component of the face is to the left of the middle of the screen.
        if(actualFace.x < (faceCenter.x - midScreenWindow))
        {
            //Update the pan position variable to move the servo to the left.
            if(panServoPos >= panServoLim.Min)
            {
              panServoPos -= stepSize; 
            }
        }
        //Find out if the X component of the face is to the right of the middle of the screen.
        else if(actualFace.x > (faceCenter.x + midScreenWindow))
        {
            //Update the pan position variable to move the servo to the right.
            if(panServoPos <= panServoLim.Max)
            {
              panServoPos +=stepSize; 
            }
        }
  
        tiltServo.write(tiltServoPos);
        panServo.write(panServoPos);
    }
  }
}

