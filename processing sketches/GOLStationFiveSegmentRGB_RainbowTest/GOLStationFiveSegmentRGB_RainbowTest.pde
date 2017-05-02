/**
 * Simple Write. 
 * 
 * Check if the mouse is over a rectangle and writes the status to the serial port. 
 * This example works with the Wiring / Arduino program that follows below.
 */

import processing.serial.*;

Serial sPort;  // Create object from Serial class

private static final int SERIAL_BAUD = 115200;
//3 bytes of color, 5 segments, 36 stations = 540
private static final int STATION_COUNT = 36;
private static final int STATION_LED_COUNT = 45;
private static final int STATION_SEGMENT_COUNT = 5;
private static final int STATION_LED_SEGMENT_COUNT = 9;
private static final int COLOR_BYTE_COUNT = 3;
private static final int STATION_COLOR_COUNT = 180;
private static final int STATION_BYTE_COUNT = 540;
private static final int BASE_CYCLE_MILLIS = 10000;

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
  sPort = new Serial(this, portName, SERIAL_BAUD);
  
  colorMode(HSB,1f);
  updateHuesAndBytes();
}

void draw() {
  delay(50);
  background(255); //clear the background
  updateHuesAndBytes();
  
  //for(int i=0;i<6;i++){
  //  for(int j=0;j<6;j++){
  //    for(int k=0;k<5;k++){
  //      int colorIndex = (i*6+j)*5+k;
  //      fill(colors[colorIndex]);
        
  //      rect(canvasWidth/6*j,canvasHeight/6*i+canvasHeight/30*(5-k-1),canvasWidth/6,canvasHeight/30);
  //    }
  //  }
  //}
  
  sPort.write(packetBytes);
  //printArray(packetBytes);
  //for(int i=0;i<STATION_BYTE_COUNT/4;i++){
  //  sPort.write(packetBytes[i]);
  //  //delay(1);
  //}
}

void updateHuesAndBytes(){
  int m = millis();
  for(int i=0;i<STATION_SEGMENT_COUNT;i++){
    hueIndices[i] = 1f*(m%(BASE_CYCLE_MILLIS*(i+1)))/float(BASE_CYCLE_MILLIS*(i+1));
  }
  
  //AAAAAAAARRRRRRRRGGGGGGGGBBBBBBBB
  for(int s=0;s<STATION_COUNT;s++){
    for(int i=0;i<STATION_SEGMENT_COUNT;i++){
      float hueIndex = (hueIndices[0] + s/float(STATION_COUNT*5));
      hueIndex -= floor(hueIndex);
      //float hueIndex = (i/float(STATION_SEGMENT_COUNT));
      //float hueIndex = 0.7f;
      color c = color( hueIndex,1f,1f);
      //c = color( 0f,1f,1f); //just a solid color
      //println(hueIndex+":"+int(red(c)*255)+","+int(green(c)*255)+","+int(blue(c)*255));
      int colorIndex = s*STATION_SEGMENT_COUNT+i;
      //c = color( random(0.0,1.0),1f,1f); //random test
      colors[colorIndex] = c;
      packetBytes[colorIndex*COLOR_BYTE_COUNT+0] = (byte)((c >> 16) & 255); //RED
      packetBytes[colorIndex*COLOR_BYTE_COUNT+1] = (byte)((c >>  8) & 255); //GREEN
      packetBytes[colorIndex*COLOR_BYTE_COUNT+2] = (byte)((c >>  0) & 255); //BLUE
      
      
      //packetBytes[colorIndex*COLOR_BYTE_COUNT+0] = byte(red(c)*255);
      //packetBytes[colorIndex*COLOR_BYTE_COUNT+1] = byte(green(c)*255);
      //packetBytes[colorIndex*COLOR_BYTE_COUNT+2] = byte(blue(c)*255);
    }
  }
}