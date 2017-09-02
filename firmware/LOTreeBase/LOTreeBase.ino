///////////////////////////////////////////////////////////////////////////////////////////////////
//use Flash size 4MB (1M SPIFFS)
///////////////////////////////////////////////////////////////////////////////////////////////////
//Flash real id:   001640EF
///////////////////////////////////////////////////////////////////////////////////////////////////
//Flash real size: 4194304
///////////////////////////////////////////////////////////////////////////////////////////////////


const char* baseVersion = "1009";

#include <EEPROM.h>

#include <Arduino.h>

#include <MPR121.h>
#include <Wire.h>

#include <ESP8266WiFi.h>
#include <ESP8266WiFiMulti.h>

#include <ESP8266HTTPClient.h>
#include <ESP8266httpUpdate.h>

#include <WiFiUDP.h>
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

#define PIN_SDA 14
#define PIN_SCL 5


CRGB stationColors[STATION_SEGMENT_COUNT];
int stationId = 0; //need to pull from EEPROM asap

const char* wifi_ssid     = "Orchard";
const char* wifi_pass = "";
const char* server_ip = "192.168.0.100";

//IPAddress udpMulticastServerIp(230, 185, 192, 109);
//uint16_t udpMulticastServerPort = 60000;
//uint16_t udpPort = 60000;


boolean doRedraw = true;
boolean doPrepareStationSegmentColors = false;
uint8_t stationLedColorIndex[STATION_LED_COUNT];
uint8_t currentLedIndex = 0;
boolean doShowStrip = false;

uint8_t gHue = 0; // rotating "base color" used by many of the patterns
CRGB rgbval(50, 0, 250);


ESP8266WiFiMulti WiFiMulti;
SocketIoClient webSocket;

// UDP variables
unsigned int udpPort = 60000;
byte packetBytesBuffer[STATION_BYTE_COUNT];
int packetBytesIndex = 0;
int packetLength = 0;
byte packetBytes[STATION_BYTE_COUNT];
bool packetComplete = false;
WiFiUDP udpSocket;

// cap sense variables
int const STATION_SEGMENTS = 5;
int LED_COUNT = 45;
int SEGMENT_LED_COUNT = 9;
float STATION_HUE[STATION_SEGMENTS];
float STATION_SAT[STATION_SEGMENTS];
float HUE_STEP = 0.002;
float SAT_STEP_MAG = 0.003;
float SAT_STEP[STATION_SEGMENTS];
float BRI_STEP = 0.03;
float BRI_STEP2 = 0.007;
float STATION_BRI[STATION_SEGMENTS];
// this is the touch threshold - setting it low makes it more like a proximity trigger
// default value is 40 for touch
const int touchThreshold = 40;
// this is the release threshold - must ALWAYS be smaller than the touch threshold
// default value is 20 for touch
const int releaseThreshold = 20;
int cap_dev[12];
int cap_threshold = 2;
int cap_sum = 0;







///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   Poor Man's Base64
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

const char map64[64] = {
  'A', //  0
  'B', //  1
  'C', //  2
  'D', //  3
  'E', //  4
  'F', //  5
  'G', //  6
  'H', //  7
  'I', //  8
  'J', //  9
  'K', // 10
  'L', // 11
  'M', // 12
  'N', // 13
  'O', // 14
  'P', // 15
  'Q', // 16
  'R', // 17
  'S', // 18
  'T', // 19
  'U', // 20
  'V', // 21
  'W', // 22
  'X', // 23
  'Y', // 24
  'Z', // 25
  'a', // 26
  'b', // 27
  'c', // 28
  'd', // 29
  'e', // 30
  'f', // 31
  'g', // 32
  'h', // 33
  'i', // 34
  'j', // 35
  'k', // 36
  'l', // 37
  'm', // 38
  'n', // 39
  'o', // 40
  'p', // 41
  'q', // 42
  'r', // 43
  's', // 44
  't', // 45
  'u', // 46
  'v', // 47
  'w', // 48
  'x', // 49
  'y', // 50
  'z', // 51
  '0', // 52
  '1', // 53
  '2', // 54
  '3', // 55
  '4', // 56
  '5', // 57
  '6', // 58
  '7', // 59
  '8', // 60
  '9', // 61
  '+', // 62
  '/'  // 63
};

const uint8_t demap64[128] = {
  0, //  0
  0, //  1
  0, //  2
  0, //  3
  0, //  4
  0, //  5
  0, //  6
  0, //  7
  0, //  8
  0, //  9
  0, // 10
  0, // 11
  0, // 12
  0, // 13
  0, // 14
  0, // 15
  0, // 16
  0, // 17
  0, // 18
  0, // 19
  0, // 20
  0, // 21
  0, // 22
  0, // 23
  0, // 24
  0, // 25
  0, // 26
  0, // 27
  0, // 28
  0, // 29
  0, // 30
  0, // 31
  0, // 32
  0, // 33
  0, // 34
  0, // 35
  0, // 36
  0, // 37
  0, // 38
  0, // 39
  0, // 40
  0, // 41
  0, // 42
  63, // 43 '+'
  0, // 44
  0, // 45
  0, // 46
  62, // 47 '/'
  52, // 48 '0'
  53, // 49 '1'
  54, // 50 '2'
  55, // 51 '3'
  56, // 52 '4'
  57, // 53 '5'
  58, // 54 '6'
  59, // 55 '7'
  60, // 56 '8'
  61, // 57 '9'
  0, // 58
  0, // 59
  0, // 60
  0, // 61
  0, // 62
  0, // 63
  0, // 64
  0, // 65 'A'
  1, // 66 'B'
  2, // 67 'C'
  3, // 68 'D'
  4, // 69 'E'
  5, // 70 'F'
  6, // 71 'G'
  7, // 72 'H'
  8, // 73 'I'
  9, // 74 'J'
  10, // 75 'K'
  11, // 76 'L'
  12, // 77 'M'
  13, // 78 'N'
  14, // 79 'O'
  15, // 80 'P'
  16, // 81 'Q'
  17, // 82 'R'
  18, // 83 'S'
  19, // 84 'T'
  20, // 85 'U'
  21, // 86 'V'
  22, // 87 'W'
  23, // 88 'X'
  24, // 89 'Y'
  25, // 90 'Z'
  0, // 91
  0, // 92
  0, // 93
  0, // 94
  0, // 95
  0, // 96
  26, // 97 'a'
  27, // 98 'b'
  28, // 99 'c'
  29, //100 'd'
  30, //101 'e'
  31, //102 'f'
  32, //103 'g'
  33, //104 'h'
  34, //105 'i'
  35, //106 'j'
  36, //107 'k'
  37, //108 'l'
  38, //109 'm'
  39, //110 'n'
  40, //111 'o'
  41, //112 'p'
  42, //113 'q'
  43, //114 'r'
  44, //115 's'
  45, //116 't'
  46, //117 'u'
  47, //118 'v'
  48, //119 'w'
  49, //120 'x'
  50, //121 'y'
  51, //122 'z'
  0, //123
  0, //124
  0, //125
  0, //126
  0  //127
};



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   LEDs
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

void redraw() {
  FastLED.show();
  doRedraw = false;
}





///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   OTA Updates
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

void checkForUpdate() {
  //t_httpUpdate_return ret = ESPhttpUpdate.update("http://192.168.0.100",80,"/update/base","1000");
  t_httpUpdate_return ret = ESPhttpUpdate.update("http://192.168.0.100:80/update/base", baseVersion);

  switch (ret) {
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





///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   EEPROM
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

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


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   UDP Events
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

//TODO: parse incoming UDP packets
void udpEvent() {
  int packetSize = udpSocket.parsePacket();
  if (packetSize) {
    USE_SERIAL.printf("received packet of size %d", packetSize);
    int len = udpSocket.read(packetBytes, STATION_BYTE_COUNT);
    packetComplete = true;
    memcpy(packetBytes, packetBytesBuffer, packetSize); //copy into buffer
  }
}








///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   Cap Sense
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

// Operation Variables
uint8_t operationMode = 0;
typedef void (*OperationFunction) ();
OperationFunction operations[5] = {
  StrandTest,              // 0 - rainbow
  SlaveListen,             // 1 - listening
  CapSenseControl,         // 2 - cap sense controller
  StrandTest2,              // 3 - another strandtest
  StrandTest3              // 4 - another strandtest
};
OperationFunction Operate = operations[0]; //StrandTest is default startup operation mode

void readCapSenseInputs() {
  int i;

  if (MPR121.touchStatusChanged()) MPR121.updateTouchData();
  MPR121.updateBaselineData();
  MPR121.updateFilteredData();
  cap_sum = 0;
  for (i = 0; i < 12; i++) {    // 13 value pairs
    cap_dev[i] = MPR121.getBaselineData(i) - MPR121.getFilteredData(i);
    Serial.print(cap_dev[i]);
    Serial.print(" ");
    if (cap_dev[i] > cap_threshold) {
      cap_sum++;
    }
  }
  Serial.println();
}

void capSenseLEDUpdate() {
  for (int i = 0; i < STATION_SEGMENTS; i++) {
    CRGB STATION_COLOR = CHSV(uint8_t(STATION_HUE[i]*255), uint8_t(STATION_SAT[i]*255), uint8_t(STATION_BRI[i]*255));
    for (int j = 0; j < SEGMENT_LED_COUNT; j++) {
      leds[i * SEGMENT_LED_COUNT + j] = STATION_COLOR;
    }
  }
  doRedraw = true;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   Setup
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

void setup() {

  delay(100); // small delay for recovery

  USE_SERIAL.begin(115200);
  Serial.setDebugOutput(true);
  USE_SERIAL.println("Booting up");

  WiFi.mode(WIFI_OFF);
  WiFi.disconnect(); //in version 2.3.0 of ESP8266 library, can't WiFi.begin if already connected or more than 1 second of delay
  delay(100);
  WiFi.mode(WIFI_STA);
  WiFi.setAutoConnect(true);
  WiFi.setAutoReconnect(true);
  WiFi.begin(wifi_ssid, wifi_pass);

  // tell FastLED about the LED strip configuration
  FastLED.addLeds<LED_TYPE, DATA_PIN, COLOR_ORDER>(leds, NUM_LEDS).setCorrection(TypicalLEDStrip);

  // set master brightness control
  FastLED.setBrightness(max_brightness);

  //turn all LEDs off immediately
  fill_solid(leds, STATION_LED_COUNT, CRGB(0, 0, 0));
  redraw();

  EEPROM.begin(512);
  stationId = EEPROMReadInt(0);
  EEPROM.end();

  USE_SERIAL.println();
  USE_SERIAL.println();
  USE_SERIAL.println();

  for (uint8_t t = 4; t > 0; t--) {
    USE_SERIAL.printf("[SETUP] BOOT WAIT %d...\n", t);
    USE_SERIAL.flush();
    delay(1000);
  }

  USE_SERIAL.printf("station id is %d\n", stationId);
  USE_SERIAL.printf("firmware version is %s\n", baseVersion);



  webSocket.on("connect", connectSocketEventHandler);
  webSocket.on("clear", clearSocketEventHandler);
  webSocket.on("fillSolid", fillSolidSocketEventHandler);
  webSocket.on("setColor", setColorSocketEventHandler);
  webSocket.on("setColors", setColorsSocketEventHandler);
  webSocket.on("setFives", setFivesSocketEventHandler);
  webSocket.on("checkForUpdate", checkForUpdateSocketEventHandler);
  webSocket.on("setMode", setModeSocketEventHandler);
  webSocket.on("setStationId", setStationIdSocketEventHandler);
  webSocket.begin(server_ip);

  udpSocket.begin(udpPort);


  //setup I2C
  pinMode(PIN_SDA, OUTPUT);
  pinMode(PIN_SCL, OUTPUT);
  Wire.begin(PIN_SDA, PIN_SCL); //SDA SCL
  Wire.setClockStretchLimit(1500); //https://github.com/esp8266/Arduino/issues/2607
  // 0x5C is the MPR121 I2C address on the Bare Touch Board
  byte mpr121try = 0;
  while (!MPR121.begin(0x5A) || mpr121try<20) {
    Serial.println("error setting up MPR121");
    switch (MPR121.getError()) {
      case NO_ERROR:
        Serial.println("no error");
        break;
      case ADDRESS_UNKNOWN:
        Serial.println("incorrect address");
        break;
      case READBACK_FAIL:
        Serial.println("readback failure");
        break;
      case OVERCURRENT_FLAG:
        Serial.println("overcurrent on REXT pin");
        break;
      case OUT_OF_RANGE:
        Serial.println("electrode out of range");
        break;
      case NOT_INITED:
        Serial.println("not initialised");
        break;
      default:
        Serial.println("unknown error");
        break;
    }
    delay(100);
    mpr121try++;
  }

  MPR121.setTouchThreshold(touchThreshold);
  MPR121.setReleaseThreshold(releaseThreshold);

  for (uint8_t i = 0; i < 12; i++) {
    cap_dev[i] = 0;
  }
}



///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   Operation Functions
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

void StrandTest() {
  // 0 - rainbow
  fill_rainbow(leds, STATION_LED_COUNT, gHue, 7);
  FastLED.show();
  FastLED.delay(1000 / 120);
  EVERY_N_MILLISECONDS(20) {
    gHue++;
  }
}

void SlaveListen() {
  // 1 - listening
}

void CapSenseControl() {
  // 2 - cap sense controller
  readCapSenseInputs();

  if (cap_dev[11] < cap_threshold) {
    for (int j = 0; j < STATION_SEGMENTS; j++) {
      if (STATION_BRI[j] < 1.0) {
        STATION_BRI[j] = STATION_BRI[j] + BRI_STEP2;
        STATION_BRI[j] = STATION_BRI[j] >= 1.0 ? 1.0 : STATION_BRI[j];
        break;
      }
    }
    capSenseLEDUpdate();
  }
  for (uint8_t i = 0; i < 12; i++) {
    if (cap_dev[i] > cap_threshold) {
      int bri_or_sat = i / 5;
      int s = i - 5;
      switch (bri_or_sat) {
        case 0:
          STATION_HUE[i] = (STATION_HUE[i] + HUE_STEP);
          STATION_HUE[i] = STATION_HUE[i] > 1.0 ? STATION_HUE[i] - 1.0 : STATION_HUE[i];
          break;
        case 1:
          STATION_SAT[s] = (STATION_SAT[s] + SAT_STEP[s]);
          SAT_STEP[s] = STATION_SAT[s] >= 1.0 ? SAT_STEP[s] * -1 : STATION_SAT[s] <= 0.0 ? SAT_STEP[s] * -1 : SAT_STEP[s];
          STATION_SAT[s] = STATION_SAT[s] >= 1.0 ? 1.0 : STATION_SAT[s] <= 0.0 ? 0.0 : STATION_SAT[s];
          break;
        default: //case 2
          for (int j = STATION_SEGMENTS - 1; j >= 0; j--) {
            if (STATION_BRI[j] > 0.0) {
              STATION_BRI[j] = STATION_BRI[j] - BRI_STEP;
              STATION_BRI[j] = STATION_BRI[j] <= 0.0 ? 0.0 : STATION_BRI[j];
              break;
            } else {
              if (j == 0) {
                for (int k = 0; k < STATION_SEGMENTS; k++) {
                  STATION_SAT[k] = 1.0;
                }
              }
            }
          }
          break;
      }
    }
  }
  capSenseLEDUpdate();
}

void StrandTest2() {
  // 3 - sinelon
  // a colored dot sweeping back and forth, with fading trails
  fadeToBlackBy( leds, NUM_LEDS, 20);
  int pos = beatsin16(13, 0, NUM_LEDS);
  leds[pos] += CHSV( gHue, 255, 192);
  FastLED.show();
  FastLED.delay(1000 / 120);
  EVERY_N_MILLISECONDS(20) {
    gHue++;
  }
}

void StrandTest3() {
  // 4 - juggle
  // eight colored dots, weaving in and out of sync with each other
  fadeToBlackBy( leds, NUM_LEDS, 20);
  byte dothue = 0;
  for ( int i = 0; i < 8; i++) {
    leds[beatsin16(i + 7, 0, NUM_LEDS)] |= CHSV(dothue, 200, 255);
    dothue += 32;
  }
  FastLED.show();
  FastLED.delay(1000 / 120);
  EVERY_N_MILLISECONDS(20) {
    gHue++;
  }
}








///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   Socket.IO Methods
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

void connectSocketEventHandler(const char * payload, size_t payloadLength) {
  USE_SERIAL.printf("connected to server\n");
  String stationId_str = String(stationId, DEC);
  const char* stationId_char = stationId_str.c_str();
  webSocket.emit("subscribe", stationId_char);
  webSocket.emit("subscribe", "stations");
  byte mac[6];
  WiFi.macAddress(mac);
  webSocket.emit("idhostnameipmac",
                 (stationId_str + ","
                  + String(WiFi.hostname()) + ","
                  + String(WiFi.localIP()) + ","
                  + String(mac[5], HEX) + ","
                  + String(mac[4], HEX) + ","
                  + String(mac[3], HEX) + ","
                  + String(mac[2], HEX) + ","
                  + String(mac[1], HEX) + ","
                  + String(mac[0], HEX)).c_str()
                );
}

void clearSocketEventHandler(const char * payload, size_t payloadLength) {
  USE_SERIAL.printf("got clear message\n");
  fill_solid(leds, STATION_LED_COUNT, CRGB(0, 0, 0));
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
  fill_solid(leds + (uint8_t)binPayload[0], (uint8_t)binPayload[1], CRGB((uint8_t)binPayload[2], (uint8_t)binPayload[3], (uint8_t)binPayload[4]));

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
  int last = first + (output_length - 1) / 3;
  for (int i = first; i < last; i++) {
    leds[i].r = (uint8_t)binPayload[i * COLOR_BYTE_COUNT + 0];
    leds[i].g = (uint8_t)binPayload[i * COLOR_BYTE_COUNT + 2];
    leds[i].b = (uint8_t)binPayload[i * COLOR_BYTE_COUNT + 1];
  }

  doRedraw = true;
}

void setFivesSocketEventHandler(const char * payload, size_t payloadLength) {
  USE_SERIAL.printf("got setFives message: %s\n", payload);

  unsigned int output_length = decode_base64_length((unsigned char*)payload);

  unsigned char binPayload[output_length];
  decode_base64((unsigned char*)payload, binPayload);

  for (int i = 0; i < STATION_LED_COUNT; i++) {
    leds[i].r = (uint8_t)binPayload[(i / STATION_LED_SEGMENT_COUNT) * COLOR_BYTE_COUNT + 0];
    leds[i].g = (uint8_t)binPayload[(i / STATION_LED_SEGMENT_COUNT) * COLOR_BYTE_COUNT + 2];
    leds[i].b = (uint8_t)binPayload[(i / STATION_LED_SEGMENT_COUNT) * COLOR_BYTE_COUNT + 1];
  }

  doRedraw = true;
}

void checkForUpdateSocketEventHandler(const char * payload, size_t payloadLength) {
  USE_SERIAL.printf("got checkForUpdate message: %s\n", payload);
  checkForUpdate();
}

void setModeSocketEventHandler(const char * payload, size_t payloadLength) {
  USE_SERIAL.printf("got setMode: %s\n", payload);

  unsigned int output_length = decode_base64_length((unsigned char*)payload);

  unsigned char binPayload[output_length];
  decode_base64((unsigned char*)payload, binPayload);

  operationMode = (uint8_t)binPayload[0];
  Operate = operations[operationMode];
}

void setStationIdSocketEventHandler(const char * payload, size_t payloadLength) {
  USE_SERIAL.printf("got setStationId: %s\n", payload);

  unsigned int output_length = decode_base64_length((unsigned char*)payload);

  unsigned char binPayload[output_length];
  decode_base64((unsigned char*)payload, binPayload);

  stationId = binPayload[0] + binPayload[1] << 8;
  EEPROM.begin(512);
  EEPROMWriteInt(0, stationId);
  EEPROM.commit();
  EEPROM.end(); //also commits in addition to release from RAM copy
}










///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   Loop
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

void loop() {
  webSocket.loop();
  udpEvent();
  if (doRedraw) {
    redraw();
  }

  if (packetComplete) {

    for (int i = 0; i < STATION_LED_COUNT; i++) {
//      leds[i].r = (uint8_t)packetBytesBuffer[(i / STATION_LED_SEGMENT_COUNT) * COLOR_BYTE_COUNT + 0];
//      leds[i].g = (uint8_t)packetBytesBuffer[(i / STATION_LED_SEGMENT_COUNT) * COLOR_BYTE_COUNT + 2];
//      leds[i].b = (uint8_t)packetBytesBuffer[(i / STATION_LED_SEGMENT_COUNT) * COLOR_BYTE_COUNT + 1];
    }
    //    if((int)packetBytesBuffer[0]==stationId){
    //      //startIndex
    //      //numToFill,
    //      //ledColor (r,g,b)
    //      fill_solid(leds + demap64[packetBytesBuffer[1]],
    //      demap64[packetBytesBuffer[2]],
    //      CRGB(
    //        demap64[packetBytesBuffer[3]],
    //        demap64[packetBytesBuffer[4]],
    //        demap64[packetBytesBuffer[5]]
    //        )
    //      );
    //doRedraw = (bool)demap64[packetBytesBuffer[6]];
    //    }
    doRedraw = true;
    packetComplete = false;
  }
  //USE_SERIAL.printf("time:%u\n",millis());

  Operate();

  //check for firmware updates once every two minutes
  EVERY_N_SECONDS(120) {
    if (WiFi.status() == WL_CONNECTED) {
      checkForUpdate();
    }
  }
}










