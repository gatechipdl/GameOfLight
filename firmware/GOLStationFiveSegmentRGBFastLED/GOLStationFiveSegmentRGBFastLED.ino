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

#include <ESP8266WiFi.h>

#define STATION_ID 24
//possible to go up to 250000 with ~20ms refresh rate
#define SERIAL_BAUD 115200

#include "FastLED.h"

FASTLED_USING_NAMESPACE

#if defined(FASTLED_VERSION) && (FASTLED_VERSION < 3001000)
#warning "Requires FastLED 3.1 or later; check github for latest code."
#endif

#define DATA_PIN    4
//#define CLK_PIN   4
#define LED_TYPE    WS2811
#define COLOR_ORDER GRB
#define NUM_LEDS   45
CRGB leds[NUM_LEDS];
uint8_t max_brightness = 255; 

#define PIN_RS485_RECEIVE 13

#define STATION_LED_COUNT 45
#define STATION_SEGMENT_COUNT 5
#define STATION_LED_SEGMENT_COUNT 9

//3 bytes of color, 5 segments, 36 stations = 540
#define COLOR_BYTE_COUNT 3
#define STATION_BYTE_COUNT 540
#define MAX_MILLIS_TO_WAIT_FOR_PACKET 30

uint32_t lastSerialEventMillis;
boolean packetComplete = false;  // whether the packet is complete
byte packetBytesSerialBuffer[STATION_BYTE_COUNT];
byte packetBytes[STATION_BYTE_COUNT];
uint16_t packetBytesReceivedCount = 0;

CRGB stationColors[STATION_SEGMENT_COUNT];
uint8_t stationId = STATION_ID;

boolean doPrepareStationSegmentColors = false;
uint8_t stationLedColorIndex[STATION_LED_COUNT];
uint8_t currentLedIndex = 0;
boolean doShowStrip = false;
 
uint8_t gHue = 0; // rotating "base color" used by many of the patterns
CRGB rgbval(50,0,250);

void setup() {
  delay(2000); // 2 second delay for recovery
  
  // tell FastLED about the LED strip configuration
  FastLED.addLeds<LED_TYPE,DATA_PIN,COLOR_ORDER>(leds, NUM_LEDS).setCorrection(TypicalLEDStrip);
  //FastLED.addLeds<LED_TYPE,DATA_PIN,CLK_PIN,COLOR_ORDER>(leds, NUM_LEDS).setCorrection(TypicalLEDStrip);

  // set master brightness control
  FastLED.setBrightness(max_brightness);
  
  pinMode(PIN_RS485_RECEIVE,OUTPUT);
  digitalWrite(PIN_RS485_RECEIVE,LOW); //listen mode
  
  lastSerialEventMillis = millis();
  
//  //index once
//  stationLedColorIndex[0]=0; //TODO integrate black pixel as first pixel
//  for(uint8_t i=0;i<STATION_SEGMENT_COUNT;i++){
//    for(uint8_t j=0;j<STATION_LED_SEGMENT_COUNT;j++){
//      stationLedColorIndex[i*STATION_LED_SEGMENT_COUNT+j+1]=i;
//    }
//  }
  
  // initialize serial:
  Serial.begin(SERIAL_BAUD);

  // turn off wifi
  WiFi.mode(WIFI_OFF);
}

void loop() {
  checkSerialEvent(); //check the serial event buffer
  
  if (packetComplete) {
    packetBytesReceivedCount = 0; //reset the packet bytes received count
    //lastSerialEventMillis = millis(); //reset timer
    memcpy(packetBytes, packetBytesSerialBuffer, STATION_BYTE_COUNT);
    
    //rgb1,rgb2,rgb3,rgb4,rgb5
    for(uint8_t i=0; i<STATION_SEGMENT_COUNT;i++){
      stationColors[i] = CRGB(
        (uint8_t)packetBytes[((stationId*STATION_SEGMENT_COUNT+i)*COLOR_BYTE_COUNT+2)], //BLUE
        (uint8_t)packetBytes[((stationId*STATION_SEGMENT_COUNT+i)*COLOR_BYTE_COUNT+1)], //GREEN
        (uint8_t)packetBytes[((stationId*STATION_SEGMENT_COUNT+i)*COLOR_BYTE_COUNT+0)]  //RED
      );
    }
    
    fill_solid(leds+0,10,stationColors[0]);
    fill_solid(leds+10,9,stationColors[1]);
    fill_solid(leds+19,9,stationColors[2]);
    fill_solid(leds+28,9,stationColors[3]);
    fill_solid(leds+37,8,stationColors[4]);
    FastLED.show();
    
    packetComplete = false;
  }
}

/*
  SerialEvent occurs whenever a new data comes in the
 hardware serial RX.  This routine is run between each
 time loop() runs, so using delay inside loop can delay
 response.  Multiple bytes of data may be available.
 */
void checkSerialEvent() {
  //bool hadData = false;
  while (Serial.available()) {
    
    // get the next new byte:
    packetBytesSerialBuffer[packetBytesReceivedCount] = Serial.read();
    packetBytesReceivedCount++;
    if (packetBytesReceivedCount == STATION_BYTE_COUNT) {
      packetComplete = true; //flag the packet to be processed
      Serial.flush();
    }
    //hadData = true;
  }
//  if(hadData){
//    lastSerialEventMillis = millis();
//  }
//
//  //reset the packetBytes count if there hasn't been bytes in over 1 second
//  if( millis() - lastSerialEventMillis > MAX_MILLIS_TO_WAIT_FOR_PACKET){
//    packetBytesReceivedCount = 0; //reset the packet byte count
//    Serial.flush(); //clear out anything that might be in the serial buffer
//    lastSerialEventMillis = millis(); //reset timer
//  }
}
