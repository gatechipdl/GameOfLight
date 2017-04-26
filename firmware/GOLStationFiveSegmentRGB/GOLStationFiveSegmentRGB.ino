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

#define STATION_ID 0

#include <Adafruit_NeoPixel.h>
#ifdef __AVR__
  #include <avr/power.h>
#endif

#define PIN_LED_DATA 4
#define PIN_RS485_RECEIVE 13
#define STATION_LED_COUNT 45
#define STATION_SEGMENT_COUNT 5
#define STATION_LED_SEGMENT_COUNT (STATION_LED_COUNT/STATION_SEGMENT_COUNT)

//3 bytes of color, 5 segments, 36 stations = 540
#define COLOR_BYTE_COUNT 3
#define STATION_BYTE_COUNT 540
#define STATION_BYTE_COUNT_MINUS_ONE 539
#define MAX_MILLIS_TO_WAIT_FOR_PACKET 1000

// Parameter 1 = number of pixels in strip
// Parameter 2 = Arduino pin number (most are valid)
// Parameter 3 = pixel type flags, add together as needed:
//   NEO_KHZ800  800 KHz bitstream (most NeoPixel products w/WS2812 LEDs)
//   NEO_KHZ400  400 KHz (classic 'v1' (not v2) FLORA pixels, WS2811 drivers)
//   NEO_GRB     Pixels are wired for GRB bitstream (most NeoPixel products)
//   NEO_RGB     Pixels are wired for RGB bitstream (v1 FLORA pixels, not v2)
//   NEO_RGBW    Pixels are wired for RGBW bitstream (NeoPixel RGBW products)
Adafruit_NeoPixel strip = Adafruit_NeoPixel(45, PIN_LED_DATA, NEO_GRB + NEO_KHZ400);

// IMPORTANT: To reduce NeoPixel burnout risk, add 1000 uF capacitor across
// pixel power leads, add 300 - 500 Ohm resistor on first pixel's data input
// and minimize distance between Arduino and first pixel.  Avoid connecting
// on a live circuit...if you must, connect GND first.

uint32_t lastSerialEventMillis;
boolean packetComplete = false;  // whether the packet is complete
volatile uint8_t packetBytes[STATION_BYTE_COUNT];
volatile uint16_t packetBytesReceivedCount = 0;

uint32_t stationColors[STATION_SEGMENT_COUNT];
uint8_t stationId = STATION_ID;

void setup() {
  // This is for Trinket 5V 16MHz, you can remove these three lines if you are not using a Trinket
  #if defined (__AVR_ATtiny85__)
    if (F_CPU == 16000000) clock_prescale_set(clock_div_1);
  #endif
  // End of trinket special code

  strip.begin();
  strip.show(); // Initialize all pixels to 'off'

  pinMode(PIN_RS485_RECEIVE,OUTPUT);
  digitalWrite(PIN_RS485_RECEIVE,LOW); //listen mode

  lastSerialEventMillis = millis();
  
  // initialize serial:
  Serial.begin(57600);
}

void loop() {
  checkSerialEvent();
  
  if (packetComplete) {
    packetBytesReceivedCount = 0; //reset the packet bytes received count
    lastSerialEventMillis = millis(); //reset timer

    //rgb1,rgb2,rgb3,rgb4,rgb5
    for(uint8_t i=0; i<STATION_SEGMENT_COUNT;i++){
      stationColors[i] = 
        ((stationId*STATION_SEGMENT_COUNT+i)*COLOR_BYTE_COUNT+0)<<16 + //RED
        ((stationId*STATION_SEGMENT_COUNT+i)*COLOR_BYTE_COUNT+1)<<8 +  //GREEN
        ((stationId*STATION_SEGMENT_COUNT+i)*COLOR_BYTE_COUNT+2);      //BLUE
    }
    
    setStationSegmentColors();
    packetComplete = false;
  }
}

void setStationSegmentColors(){
  for(uint8_t i=0;i<STATION_SEGMENT_COUNT;i++){
    for(uint8_t j=0;j<STATION_LED_SEGMENT_COUNT;j++){
      strip.setPixelColor(i*STATION_SEGMENT_COUNT+j,stationColors[i]);
    }
  }
  strip.show();
}

/*
  SerialEvent occurs whenever a new data comes in the
 hardware serial RX.  This routine is run between each
 time loop() runs, so using delay inside loop can delay
 response.  Multiple bytes of data may be available.
 */
void checkSerialEvent() {
  while (Serial.available()) {
    
    if(packetBytesReceivedCount == 0){
      lastSerialEventMillis = millis(); //reset timer
    }
    
    // get the new byte:
    packetBytes[packetBytesReceivedCount] = Serial.read();
    packetBytesReceivedCount++;
    if (packetBytesReceivedCount == STATION_BYTE_COUNT_MINUS_ONE) {
      packetComplete = true; //flag the packet to be processed
    }
  }

  //reset the packetBytes count if there hasn't been bytes in over 1 second
  if( millis() - lastSerialEventMillis > MAX_MILLIS_TO_WAIT_FOR_PACKET){
    packetBytesReceivedCount = 0; //reset the packet byte count
    Serial.flush(); //clear out anything that might be in the serial buffer
    lastSerialEventMillis = millis(); //reset timer
  }
}
