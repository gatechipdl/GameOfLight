//use Flash size 4MB (1M SPIFFS)
//Flash real id:   001640EF
//Flash real size: 4194304

#include <EEPROM.h>

#include <Arduino.h>

#include <ESP8266WiFi.h>
#include <ESP8266WiFiMulti.h>

#include <ESP8266HTTPClient.h>
#include <ESP8266httpUpdate.h>

#include <SocketIoClient.h>
#include "base64.hpp"

#define USE_SERIAL Serial

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

#define STATION_LED_COUNT 45
#define STATION_SEGMENT_COUNT 5
#define STATION_LED_SEGMENT_COUNT 9

//3 bytes of color, 5 segments, 36 stations = 540
#define COLOR_BYTE_COUNT 3
#define STATION_BYTE_COUNT 15

byte packetBytesSerialBuffer[STATION_BYTE_COUNT];
byte packetBytes[STATION_BYTE_COUNT];

CRGB stationColors[STATION_SEGMENT_COUNT];
int stationId = 0; //need to pull from EEPROM asap

const char* wifi_ssid     = "Orchard";
const char* wifi_pass = "";
const char* server_ip = "192.168.0.100";
const char* baseVersion = "1000";

boolean doRedraw = true;
boolean doPrepareStationSegmentColors = false;
uint8_t stationLedColorIndex[STATION_LED_COUNT];
uint8_t currentLedIndex = 0;
boolean doShowStrip = false;

uint8_t gHue = 0; // rotating "base color" used by many of the patterns
CRGB rgbval(50, 0, 250);


ESP8266WiFiMulti WiFiMulti;
SocketIoClient webSocket;


void connectSocketEventHandler(const char * payload, size_t payloadLength) {
  USE_SERIAL.printf("connected to server\n");
  //const char* temp = number2char(stationId);
  //*temp++ = '\0';
  //temp[temp.length] = '\0';
  String stationId_str = String(stationId,DEC);
  const char* stationId_char = stationId_str.c_str();
  //itoa(stationId,stationId_char,10);
  webSocket.emit("subscribe", stationId_char);
  webSocket.emit("subscribe", "stations");
}

void clearSocketEventHandler(const char * payload, size_t payloadLength) {
  USE_SERIAL.printf("got clear message\n");

  fill_solid(leds,STATION_LED_COUNT, CRGB(0,0,0));
  
  doRedraw = true;
}

void fillSolidSocketEventHandler(const char * payload, size_t payloadLength) {
  //USE_SERIAL.printf("got fillSolid message: %s\n", payload);
  
  unsigned int output_length = decode_base64_length((unsigned char*)payload);
  unsigned char binPayload[output_length];
  decode_base64((unsigned char*)payload, binPayload);

  //startIndex
  //numToFill,
  //ledColor (r,g,b)
  fill_solid(leds + (uint8_t)binPayload[0], (uint8_t)binPayload[1], CRGB((uint8_t)binPayload[2],(uint8_t)binPayload[3],(uint8_t)binPayload[4]));
  
  doRedraw = true;
}

void setColorSocketEventHandler(const char * payload, size_t payloadLength) {
  //USE_SERIAL.printf("got setColor message: %s\n", payload);
  
  unsigned int output_length = decode_base64_length((unsigned char*)payload);
  unsigned char binPayload[output_length];
  decode_base64((unsigned char*)payload, binPayload);

  //startIndex
  //ledColor (r,g,b)

  int first = (uint8_t)binPayload[0];
  leds[first].r = (uint8_t)binPayload[1];
  leds[first].g = (uint8_t)binPayload[2];
  leds[first].b = (uint8_t)binPayload[3];
  
  doRedraw = true;
}

void setColorsSocketEventHandler(const char * payload, size_t payloadLength) {
  //USE_SERIAL.printf("got setColors message: %s\n", payload);
  
  unsigned int output_length = decode_base64_length((unsigned char*)payload);
  unsigned char binPayload[output_length];
  decode_base64((unsigned char*)payload, binPayload);

  //startIndex
  //colorArray[] (r,g,b)
  int first = (uint8_t)binPayload[0];
  int last = first+(output_length-1)/3;
  for (int i = first; i < last; i++) {
    leds[i].r = (uint8_t)binPayload[i*COLOR_BYTE_COUNT+0];
    leds[i].g = (uint8_t)binPayload[i*COLOR_BYTE_COUNT+2];
    leds[i].b = (uint8_t)binPayload[i*COLOR_BYTE_COUNT+1];
  }
  
  doRedraw = true;
}

void setFivesSocketEventHandler(const char * payload, size_t payloadLength) {
  //USE_SERIAL.printf("got setFives message: %s\n", payload);

  unsigned int output_length = decode_base64_length((unsigned char*)payload);
  
  unsigned char binPayload[output_length];
  decode_base64((unsigned char*)payload, binPayload);
  
  for (int i = 0; i < STATION_LED_COUNT; i++) {
    leds[i].r = (uint8_t)binPayload[(i/STATION_LED_SEGMENT_COUNT)*COLOR_BYTE_COUNT+0];
    leds[i].g = (uint8_t)binPayload[(i/STATION_LED_SEGMENT_COUNT)*COLOR_BYTE_COUNT+2];
    leds[i].b = (uint8_t)binPayload[(i/STATION_LED_SEGMENT_COUNT)*COLOR_BYTE_COUNT+1];
  }
  
  doRedraw = true;
}

void setFivesOldSocketEventHandler(const char * payload, size_t payloadLength) {
  USE_SERIAL.printf("got setFivesOld message: %s\n", payload);

  String dataString = "";
  int loc = 0; //keep track of color byte number

  for (int num = 0; num < payloadLength; num++) {
    if (payload[num] == ',' || payload[num] == '\n' || payload[num] == '\r') { //delimiter(s)
      //save byte
      packetBytesSerialBuffer[loc] = (byte)(dataString.toInt());
      char stuff[10];
      dataString.toCharArray(stuff, dataString.length() + 1);
      USE_SERIAL.printf("got string: %s\n", stuff);
      dataString = ""; //reset dataString
      loc++;
      if (loc >= STATION_BYTE_COUNT) {
        break; //only read and store up to 15 values
      }
    }
    else {
      dataString.concat(payload[num]);
    }
  }
  
  doRedraw = true;
}

void checkForUpdateSocketEventHandler(const char * payload, size_t payloadLength) {
  USE_SERIAL.printf("got checkForUpdate message: %s\n", payload);
  checkForUpdate();
}

void checkForUpdate(){
  //t_httpUpdate_return ret = ESPhttpUpdate.update("http://192.168.0.100",80,"/update/base","1000");
  t_httpUpdate_return ret = ESPhttpUpdate.update("http://192.168.0.100:80/update/base",baseVersion);
   
  switch(ret) {
    case HTTP_UPDATE_FAILED:
      USE_SERIAL.printf("HTTP_UPDATE_FAILD Error (%d): %s", ESPhttpUpdate.getLastError(), ESPhttpUpdate.getLastErrorString().c_str());
        break;
        
    case HTTP_UPDATE_NO_UPDATES:
      USE_SERIAL.println("HTTP_UPDATE_NO_UPDATES");
        break;
    
    case HTTP_UPDATE_OK:
      USE_SERIAL.println("HTTP_UPDATE_OK");
        break;
    }
}

//http://forum.arduino.cc/index.php?topic=37470.0
//This function will write a 2 byte integer to the eeprom at the specified address and address + 1
void EEPROMWriteInt(int p_address, int p_value)
 {
  byte lowByte = ((p_value >> 0) & 0xFF);
  byte highByte = ((p_value >> 8) & 0xFF);
  
  EEPROM.write(p_address, lowByte);
  EEPROM.write(p_address + 1, highByte);
 }

//This function will read a 2 byte integer from the eeprom at the specified address and address + 1
unsigned int EEPROMReadInt(int p_address)
{
  byte lowByte = EEPROM.read(p_address);
  byte highByte = EEPROM.read(p_address + 1);
  
  return ((lowByte << 0) & 0xFF) + ((highByte << 8) & 0xFF00);
}

void setup() {

  delay(2000); // 2 second delay for recovery
  
  // tell FastLED about the LED strip configuration
  FastLED.addLeds<LED_TYPE, DATA_PIN, COLOR_ORDER>(leds, NUM_LEDS).setCorrection(TypicalLEDStrip);
  //FastLED.addLeds<LED_TYPE,DATA_PIN,CLK_PIN,COLOR_ORDER>(leds, NUM_LEDS).setCorrection(TypicalLEDStrip);

  // set master brightness control
  FastLED.setBrightness(max_brightness);

  //turn all LEDs off immediately
  fill_solid(leds,STATION_LED_COUNT, CRGB(0,0,0));
  redraw();

  EEPROM.begin(512);
  stationId = EEPROMReadInt(0);
  EEPROM.commit();
  
  USE_SERIAL.begin(115200);

  USE_SERIAL.setDebugOutput(true);

  USE_SERIAL.println();
  USE_SERIAL.println();
  USE_SERIAL.println();

  for (uint8_t t = 11; t > 0; t--) {
    USE_SERIAL.printf("[SETUP] BOOT WAIT %d...\n", t);
    USE_SERIAL.flush();
    delay(1000);
  }

  USE_SERIAL.printf("station id is %d\n", stationId);
  
  WiFiMulti.addAP(wifi_ssid,wifi_pass);

  while (WiFiMulti.run() != WL_CONNECTED) {
    USE_SERIAL.printf(".");
    delay(100);
  }

  if (WiFiMulti.run() == WL_CONNECTED) {
    checkForUpdate();
  }
  
  webSocket.on("connect", connectSocketEventHandler);
  webSocket.on("clear", clearSocketEventHandler);
  webSocket.on("fillSolid", fillSolidSocketEventHandler);
  webSocket.on("setColor", setColorSocketEventHandler);
  webSocket.on("setColors", setColorsSocketEventHandler);
  webSocket.on("setFives", setFivesSocketEventHandler);
  webSocket.on("setFivesOld", setFivesOldSocketEventHandler);
  webSocket.on("checkForUpdate", checkForUpdateSocketEventHandler);
  
  webSocket.begin(server_ip);
  USE_SERIAL.printf("got to the bottom here\n");
}

char* number2char(int num) {
  char buf[7];
  buf[0] = 0;
  buf[1] = 0;
  buf[2] = 0;
  buf[3] = 0;
  buf[4] = 0;
  buf[5] = 0;
  buf[6] = 0;
  itoa(num,buf,10);
  buf[6] = 0;
  //Serial.println(buf);
  return buf;
  //String t = ""+String(num,DEC)+"";
  //Serial.println(t);
  Serial.println(buf);
  //return string2char(buf);
  
  //return const_cast<char*>(t.c_str());
}

//https://coderwall.com/p/zfmwsg/arduino-string-to-ch
char* string2char(String str) {
  char* buf;//[str.length()+2];
  //Serial.println(str);
  //Serial.println(str.length());
  //str.toCharArray(buf,str.length());
  Serial.println(buf);
  //*buf++ = '\0';
  *buf++ = 0;
  return buf;
//  if (str.length() != 0) {
//    char* p = const_cast<char*>(str.c_str());
//    return p;
//  }
}

void loop() {
  webSocket.loop();
  if (doRedraw) {
    redraw();
  }
}

void redraw() {

  FastLED.show();

  doRedraw = false;
}

