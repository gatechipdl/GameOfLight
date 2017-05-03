#include <Modbus.h>
#include <ModbusSerial.h>
#include <ESP8266WiFi.h>
#include "FastLED.h"

FASTLED_USING_NAMESPACE

#if defined(FASTLED_VERSION) && (FASTLED_VERSION < 3001000)
#warning "Requires FastLED 3.1 or later; check github for latest code."
#endif

#define STATION_ID 24
//possible to go up to 250000 with ~20ms refresh rate
#define SERIAL_BAUD 9600

#define DATA_PIN    4
#define LED_TYPE    WS2811
#define COLOR_ORDER GRB
#define NUM_LEDS   45
CRGB leds[NUM_LEDS];
uint8_t max_brightness = 255; 

#define PIN_RS485_RECEIVE 13

#define STATION_SEGMENT_COUNT 5
#define STATION_LED_SEGMENT_COUNT 9

CRGB stationColors[STATION_SEGMENT_COUNT];
uint8_t stationId = STATION_ID;

uint8_t lastHue = 127;
uint8_t currHue = 127;

// Modbus Registers Offsets (0-9999)
const int DRAW_ISTS = 97;
const int DRAW_COIL = 99;
const int HUE_HREG = 100; 

// ModbusSerial object
ModbusSerial mb;

void setup() {
  delay(2000); // 2 second delay for recovery
  
  // turn off wifi
  WiFi.mode(WIFI_OFF);
  
  // tell FastLED about the LED strip configuration
  FastLED.addLeds<LED_TYPE,DATA_PIN,COLOR_ORDER>(leds, NUM_LEDS).setCorrection(TypicalLEDStrip);
  //FastLED.addLeds<LED_TYPE,DATA_PIN,CLK_PIN,COLOR_ORDER>(leds, NUM_LEDS).setCorrection(TypicalLEDStrip);

  // set master brightness control
  FastLED.setBrightness(max_brightness);
  
  pinMode(PIN_RS485_RECEIVE,OUTPUT);
  digitalWrite(PIN_RS485_RECEIVE,LOW); //listen mode

  
  // Config Modbus Serial (port, speed, byte format, txPin) 
  //#define SERIAL_8N1 0x06
  //mb.config(&Serial, SERIAL_BAUD, 0x06, PIN_RS485_RECEIVE);
  mb.config(&Serial, SERIAL_BAUD, SERIAL_8N1, PIN_RS485_RECEIVE);
  // Set the Slave ID (1-247)
  mb.setSlaveId(STATION_ID);  

  
  // Add DRAW_ISTS register - Use addIsts() for digital inputs 
  mb.addIsts(DRAW_ISTS);
  // Add DRAW_COIL register - Use addCoil() for digital outputs
  mb.addCoil(DRAW_COIL);
  // Add HUE_HREG register - Use addHreg() for analog outpus or to store values in device 
  mb.addHreg(HUE_HREG, 127);
}

void loop() {
  // Call once inside loop() - all magic here
  mb.task();

  currHue = mb.Hreg(HUE_HREG);
  if(lastHue!=currHue){
    currHue = lastHue;
    //use hue to draw
    fill_solid(leds,NUM_LEDS,CHSV(currHue,255,255));
    FastLED.show();
  }
}
