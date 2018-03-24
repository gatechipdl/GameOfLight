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
byte[] packetBytesDiff = new byte[STATION_BYTE_COUNT];
color[] colors = new color[STATION_COLOR_COUNT];
float[] hueIndices = new float[STATION_SEGMENT_COUNT];

byte[] diff64 = {
(byte)0x65, (byte)0x14, (byte)0xe7, (byte)0xdf, (byte)0x4c, (byte)0xe0, (byte)0x6b, (byte)0xb4,
(byte)0x9f, (byte)0xe4, (byte)0x06, (byte)0x4d, (byte)0x2c, (byte)0x85, (byte)0x32, (byte)0xfe,
(byte)0xc6, (byte)0x38, (byte)0x4f, (byte)0x19, (byte)0xa7, (byte)0x78, (byte)0x29, (byte)0x3f,
(byte)0xf5, (byte)0x5b, (byte)0x6c, (byte)0x03, (byte)0x6a, (byte)0x8b, (byte)0x8b, (byte)0xf0, 
(byte)0x96, (byte)0xa8, (byte)0x3d, (byte)0xad, (byte)0x3b, (byte)0x8f, (byte)0xbc, (byte)0xc0,
(byte)0x58, (byte)0x51, (byte)0xf7, (byte)0x66, (byte)0x26, (byte)0xbb, (byte)0x5a, (byte)0xb5,
(byte)0x16, (byte)0x20, (byte)0x14, (byte)0x10, (byte)0x69, (byte)0x72, (byte)0x75, (byte)0xc3,
(byte)0x31, (byte)0xcc, (byte)0x3b, (byte)0x01, (byte)0xb7, (byte)0x2b, (byte)0xf4, (byte)0x71
};


void setup() 
{
  size(600, 600);
  canvasWidth = width;
  canvasHeight = height;
  
  //byte[] test = {0,0,0,0};
  //println(test);
  //byte[] test2 = new byte[test.length];r
  ////System.arraycopy(test,0,test2,0,test.length);
  //for(int i=0;i<test.length;i++){
  //  test2[i] = (byte)(test[i] + diff64[i%64] + diff64[i%64] + diff64[i%64]);
  //}
  //println(test2);
  
  //byte[] test3 = new byte[test.length];
  //for(int i=0;i<test.length;i++){
  //  test3[i] = (byte)(test2[i] - diff64[i%64] - diff64[i%64] - diff64[i%64]);
  //}
  //println(test3);
  
  
  
  // List all the available serial ports:
  printArray(Serial.list());
  
  String portName = Serial.list()[1];
  sPort = new Serial(this, portName, SERIAL_BAUD);
  
  colorMode(HSB,1f);
  updateHuesAndBytes();
}

void draw() {
  delay(2);
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
  
  // "diff" encode the packetBytes
  for(int i=0;i<STATION_BYTE_COUNT;i++){
    packetBytesDiff[i] = (byte)((byte)packetBytes[i] + (byte)diff64[i%64]);
  }
  sPort.write(packetBytesDiff);
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
      float hueIndex = (hueIndices[0] + s/float(STATION_COUNT));
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
      
      
      packetBytes[colorIndex*COLOR_BYTE_COUNT+0] = byte(red(c)*255);
      packetBytes[colorIndex*COLOR_BYTE_COUNT+1] = byte(green(c)*255);
      packetBytes[colorIndex*COLOR_BYTE_COUNT+2] = byte(blue(c)*255);
      

    }
  }
}