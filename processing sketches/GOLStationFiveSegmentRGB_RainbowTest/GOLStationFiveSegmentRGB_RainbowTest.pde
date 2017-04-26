/**
 * Simple Write. 
 * 
 * Check if the mouse is over a rectangle and writes the status to the serial port. 
 * This example works with the Wiring / Arduino program that follows below.
 */

import processing.serial.*;

Serial sPort;  // Create object from Serial class

//3 bytes of color, 5 segments, 36 stations = 540
private static final int STATION_COUNT = 36;
private static final int STATION_LED_COUNT = 45;
private static final int STATION_SEGMENT_COUNT = 5;
private static final int STATION_LED_SEGMENT_COUNT = 9;
private static final int COLOR_BYTE_COUNT = 3;
private static final int STATION_COLOR_COUNT = 180;
private static final int STATION_BYTE_COUNT = 540;
private static final int BASE_CYCLE_MILLIS = 5000;

int canvasWidth = 600;
int canvasHeight = 600;

byte[] packetBytes = new byte[STATION_BYTE_COUNT];
color[] colors = new color[STATION_COLOR_COUNT];
float[] hueIndices = new float[STATION_SEGMENT_COUNT];

void setup() 
{
  size(600, 600);
  canvasWidth = width;
  canvasHeight = height;
  
  // List all the available serial ports:
  printArray(Serial.list());
  
  String portName = Serial.list()[0];
  //sPort = new Serial(this, portName, 57600);
  
  colorMode(HSB,1f);
  updateHuesAndBytes();
}

void draw() {
  delay(150);
  background(255);
  updateHuesAndBytes();
  
  for(int i=0;i<6;i++){
    for(int j=0;j<6;j++){
      for(int k=0;k<5;k++){
        int colorIndex = (i*6+j)*5+k;
        fill(colors[colorIndex]);
        rect(canvasWidth/6*i,canvasHeight/6*j+canvasHeight/30*k,canvasWidth/6*(i+1),canvasHeight/6*j+canvasHeight/30*(k+1));
      }
    }
  }
  
  sPort.write(packetBytes);
}

void updateHuesAndBytes(){
  int m = millis();
  for(int i=0;i<STATION_SEGMENT_COUNT;i++){
    hueIndices[i] = 1f*(m%(BASE_CYCLE_MILLIS*(i+1)))/float(BASE_CYCLE_MILLIS*(i+1));
  }
  
  //AAAAAAAARRRRRRRRGGGGGGGGBBBBBBBB
  for(int s=0;s<STATION_COUNT;s++){
    for(int i=0;i<STATION_SEGMENT_COUNT;i++){
      float hueIndex = (hueIndices[i] + s/float(STATION_COUNT));
      color c = color( hueIndex-floor(hueIndex),1f,1f);
      int colorIndex = s*STATION_SEGMENT_COUNT+i;
      colors[colorIndex] = c;
      packetBytes[colorIndex*COLOR_BYTE_COUNT+0] = byte((c >> 16) & 0xFF); //RED
      packetBytes[colorIndex*COLOR_BYTE_COUNT+1] = byte((c >>  8) & 0xFF); //GREEN
      packetBytes[colorIndex*COLOR_BYTE_COUNT+2] = byte((c >>  0) & 0xFF); //BLUE
    }
  }
}