// Protocol Byte Sequence:

// Station ID 0:
// 0_R1, 0_G1, 0_B1 LOWER SEGMENT
// 0_R2, 0_G2, 0_B2 LOWER MIDDLE SEGMENT
// 0_R3, 0_G3, 0_B3 MIDDLE SEGMENT
// 0_R4, 0_G4, 0_B4 UPPER MIDDLE SEGMENT
// 0_R5, 0_G5, 0_B5 UPPER SEGMENT

// Station ID 1:
// 1_R1, 1_G1, 1_B1 LOWER SEGMENT
// 1_R2, 1_G2, 1_B2 LOWER MIDDLE SEGMENT
// 1_R3, 1_G3, 1_B3 MIDDLE SEGMENT
// 1_R4, 1_G4, 1_B4 UPPER MIDDLE SEGMENT
// 1_R5, 1_G5, 1_B5 UPPER SEGMENT

// ...
// ...
// ...

// Station ID 35:
// 35_R1, 35_G1, 35_B1 LOWER SEGMENT
// 35_R2, 35_G2, 35_B2 LOWER MIDDLE SEGMENT
// 35_R3, 35_G3, 35_B3 MIDDLE SEGMENT
// 35_R4, 35_G4, 35_B4 UPPER MIDDLE SEGMENT
// 35_R5, 35_G5, 35_B5 UPPER SEGMENT


#define SERIAL_TX_BUFFER_SIZE 1024

#include <ESP8266WiFi.h>

//possible to go up to 250000 with ~20ms refresh rate
#define SERIAL_BAUD 115200

#include "FastLED.h"

FASTLED_USING_NAMESPACE

#if defined(FASTLED_VERSION) && (FASTLED_VERSION < 3001000)
#warning "Requires FastLED 3.1 or later; check github for latest code."
#endif

#define STATION_COUNT 36
#define STATION_SEGMENT_COUNT 5
#define STATION_TOTAL_SEGMENT_COUNT 180

#define PIN_RS485_RECEIVE 13

//3 bytes of color, 5 segments, 36 stations = 540
#define COLOR_BYTE_COUNT 3
#define STATION_BYTE_COUNT 540
#define PACKET_DELAY 250

byte diff64[] = {
  0x65, 0x14, 0xe7, 0xdf, 0x4c, 0xe0, 0x6b, 0xb4,
  0x9f, 0xe4, 0x06, 0x4d, 0x2c, 0x85, 0x32, 0xfe,
  0xc6, 0x38, 0x4f, 0x19, 0xa7, 0x78, 0x29, 0x3f,
  0xf5, 0x5b, 0x6c, 0x03, 0x6a, 0x8b, 0x8b, 0xf0, 
  0x96, 0xa8, 0x3d, 0xad, 0x3b, 0x8f, 0xbc, 0xc0,
  0x58, 0x51, 0xf7, 0x66, 0x26, 0xbb, 0x5a, 0xb5,
  0x16, 0x20, 0x14, 0x10, 0x69, 0x72, 0x75, 0xc3,
  0x31, 0xcc, 0x3b, 0x01, 0xb7, 0x2b, 0xf4, 0x71
};

CRGB stationColors[STATION_TOTAL_SEGMENT_COUNT];
byte packetBytes[STATION_BYTE_COUNT];

#define PACKET_CHUNKS 9
#define PACKET_CHUNK_SIZE 60
byte packetBytesChunky[PACKET_CHUNKS][PACKET_CHUNK_SIZE];

uint8_t gHue = 0; // rotating "base color" used by many of the patterns

void setup() {
  delay(3000); // 2 second delay for recovery
  
  // set master brightness control
  FastLED.setBrightness(255);
  
  pinMode(PIN_RS485_RECEIVE,OUTPUT);
  //digitalWrite(PIN_RS485_RECEIVE,LOW); //receive mode
  digitalWrite(PIN_RS485_RECEIVE,HIGH); //transmit mode
  
  // initialize serial:
  Serial.begin(SERIAL_BAUD);

  // turn off wifi
  WiFi.mode(WIFI_OFF);
}

CRGB c;

void loop() {
  
  for(int i=0;i<STATION_COUNT;i++){
    c = CHSV((gHue+i*5)%256,255,255);
    for(int j=0;j<STATION_SEGMENT_COUNT;j++){
      stationColors[i*STATION_SEGMENT_COUNT+j] = c;
    }
  }
  for(int i=0;i<STATION_TOTAL_SEGMENT_COUNT;i++){
    for(int j=0;j<COLOR_BYTE_COUNT;j++){
      uint16_t byteId = i*COLOR_BYTE_COUNT+j;
      packetBytes[i] = (stationColors[i][j]-0x7F+diff64[byteId%64]);
      uint16_t chunkId = byteId/PACKET_CHUNKS;
      uint16_t subByteId = i-chunkId*PACKET_CHUNKS;
      packetBytesChunky[chunkId][subByteId] = packetBytes[i];
    }
  }

  digitalWrite(PIN_RS485_RECEIVE,HIGH); //transmit mode
  //Serial.write(packetBytes,STATION_BYTE_COUNT);

//  for(int i=0;i<STATION_BYTE_COUNT;i++){
//    
//    Serial.write(packetBytes[i]);
//    delayMicroseconds(5);
//  }
  
  for(int i=0;i<PACKET_CHUNKS;i++){
    Serial.write(packetBytesChunky[i],PACKET_CHUNK_SIZE);
    Serial.flush();
    //delayMicroseconds(1);
  }
  delayMicroseconds(1);
  //Serial.write(packetBytes,STATION_BYTE_COUNT);
  digitalWrite(PIN_RS485_RECEIVE,LOW); //receive mode

  gHue = (gHue+1)%256;
  delay(PACKET_DELAY);
}
