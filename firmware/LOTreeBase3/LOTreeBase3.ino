///////////////////////////////////////////////////////////////////////////////////////////////////
//use Flash size 4MB (1M SPIFFS)
///////////////////////////////////////////////////////////////////////////////////////////////////
//Flash real id:   001640EF
///////////////////////////////////////////////////////////////////////////////////////////////////
//Flash real size: 4194304
///////////////////////////////////////////////////////////////////////////////////////////////////

const char* baseVersion = "3014";

#include <EEPROM.h>
#include <ESP8266WiFi.h>
#include <FastLED.h>
#include <MPR121.h>
#include <Wire.h>
#include <ESP8266HTTPClient.h>
#include <ESP8266httpUpdate.h>
#include <SocketIoClient.h>
#include "base64.h"

#define LED_DATA_PIN 4
#define BAUDRATE 115200
#define LED_TYPE    WS2811
#define LED_COLOR_ORDER GRB
#define LED_COUNT    45
#define LED_SEGMENT_COUNT 5
#define LED_PER_SEGMENT_COUNT 9
#define COLOR_BYTE_COUNT      3

#define PIN_SDA 14
#define PIN_SCL 5

int stationId = 0; //need to pull from EEPROM asap

CRGB leds[LED_COUNT];
float segmentHues[LED_SEGMENT_COUNT];
float segmentSats[LED_SEGMENT_COUNT];
float hueStep = 0.002;
float satStepMag = 0.003;
float satSteps[LED_SEGMENT_COUNT];
float briStep1 = 0.03;
float briStep2 = 0.007;
float segmentBris[LED_SEGMENT_COUNT];

uint8_t gHue = 0; // rotating "base color" used by many of the patterns

// this is the touch threshold - setting it low makes it more like a proximity trigger
// default value is 40 for touch
const int touchThreshold = 40;
// this is the release threshold - must ALWAYS be smaller than the touch threshold
// default value is 20 for touch
const int releaseThreshold = 20;
int cap_dev[12];
int cap_threshold = 2;
int cap_sum = 0;
bool cap_last[12]; //last state
bool cap_curr[12]; //curr state

const char* wifi_ssid     = "Orchard";
const char* wifi_pass = "";
const char* server_ip = "192.168.0.100";
SocketIoClient webSocket;

void chunkedDelay(int ms, int chunkSize);
//void redraw();
void checkForUpdate();
void EEPROMWriteInt(int p_address, int p_value);
unsigned int EEPROMReadInt(int p_address);
//void udpEvent();
void readCapSenseInputs();
void capSenseLEDUpdate();
void PostSetupInitialization();
void SlaveListen();
void StrandTest1();
void StrandTest2();
void StrandTest3();
void CapSenseTest();
void CapSenseControl();
void connectSocketEventHandler(const char * payload, size_t payloadLength);
void clearSocketEventHandler(const char * payload, size_t payloadLength);
void fillSolidSocketEventHandler(const char * payload, size_t payloadLength);
void setColorSocketEventHandler(const char * payload, size_t payloadLength);
void setColorsSocketEventHandler(const char * payload, size_t payloadLength);
void setFivesSocketEventHandler(const char * payload, size_t payloadLength);
void checkForUpdateSocketEventHandler(const char * payload, size_t payloadLength);
void setModeSocketEventHandler(const char * payload, size_t payloadLength);
void setStationIdSocketEventHandler(const char * payload, size_t payloadLength);


// Operation Variables
uint8_t operationMode = 4;
typedef void (*OperationFunction) ();
OperationFunction operations[6] = {
  SlaveListen,            // 0 - listening
  StrandTest1,            // 1 - rainbow
  StrandTest2,            // 2 - another strandtest
  StrandTest3,            // 3 - another strandtest
  CapSenseTest,           // 4 - cap sense test
  CapSenseControl         // 5 - cap sense controller
};
OperationFunction Operate = operations[operationMode]; //default startup operation mode

void capSenseLEDUpdate() {
  for (int i = 0; i < LED_SEGMENT_COUNT; i++) {
    //uint32_t STATION_COLOR = HSV_to_RGB(i);
    for (int j = 0; j < LED_PER_SEGMENT_COUNT; j++) {
      leds[i*LED_PER_SEGMENT_COUNT+j].setHSV(int(segmentHues[i]*255), int(segmentSats[i]*255), int(segmentBris[i]*255));
    }
  }
  FastLED.show();
}

void PostSetupInitialization(){};

void SlaveListen() {
  // 0 - listening
}

void StrandTest1() {
  // 1 - rainbow
  fill_rainbow(leds, LED_COUNT, gHue, 7);
  FastLED.show();
  FastLED.delay(1000 / 120);
  EVERY_N_MILLISECONDS(20) {
    gHue++;
  }
}

void StrandTest2() {
  // 2 - sinelon
  // a colored dot sweeping back and forth, with fading trails
  fadeToBlackBy( leds, LED_COUNT, 20);
  int pos = beatsin16(13, 0, LED_COUNT);
  leds[pos] += CHSV( gHue, 255, 192);
  FastLED.show();
  FastLED.delay(1000 / 120);
  EVERY_N_MILLISECONDS(20) {
    gHue++;
  }
}

void StrandTest3() {
  // 3 - juggle
  // eight colored dots, weaving in and out of sync with each other
  fadeToBlackBy( leds, LED_COUNT, 20);
  byte dothue = 0;
  for ( int i = 0; i < 8; i++) {
    leds[beatsin16(i + 7, 0, LED_COUNT)] |= CHSV(dothue, 200, 255);
    dothue += 32;
  }
  FastLED.show();
  FastLED.delay(1000 / 120);
  EVERY_N_MILLISECONDS(20) {
    gHue++;
  }
}


void CapSenseTest() {
  
  readCapSenseInputs();
  
  if (cap_dev[11] < cap_threshold) {
    for (int j = 0; j < LED_SEGMENT_COUNT; j++) {
      if (segmentBris[j] < 1.0) {
        segmentBris[j] = segmentBris[j] + briStep2;
        segmentBris[j] = segmentBris[j] >= 1.0 ? 1.0 : segmentBris[j];
        break;
      }
    }
    capSenseLEDUpdate();
  }
  for (uint8_t i = 0; i < 12; i++) {
    cap_curr[i] = cap_dev[i] > cap_threshold; //greater is true is 1 is "pressed"
    if (cap_curr[i]) {
      int bri_or_sat = i / 5;
      int s = i - 5;
      switch (bri_or_sat) {
        case 0:
          segmentHues[i] = (segmentHues[i] + hueStep);
          segmentHues[i] = segmentHues[i] > 1.0 ? segmentHues[i] - 1.0 : segmentHues[i];
          break;
        case 1:
          segmentSats[s] = (segmentSats[s] + satSteps[s]);
          satSteps[s] = segmentSats[s] >= 1.0 ? satSteps[s] * -1 : segmentSats[s] <= 0.0 ? satSteps[s] * -1 : satSteps[s];
          segmentSats[s] = segmentSats[s] >= 1.0 ? 1.0 : segmentSats[s] <= 0.0 ? 0.0 : segmentSats[s];
          break;
        default: //case 2
          for (int j = LED_SEGMENT_COUNT - 1; j >= 0; j--) {
            if (segmentBris[j] > 0.0) {
              segmentBris[j] = segmentBris[j] - briStep1;
              segmentBris[j] = segmentBris[j] <= 0.0 ? 0.0 : segmentBris[j];
              break;
            } else {
              if (j == 0) {
                for (int k = 0; k < LED_SEGMENT_COUNT; k++) {
                  segmentSats[k] = 1.0;
                }
              }
            }
          }
          break;
      }
    }
    
    cap_last[i] = cap_curr[i]; //reset cap_last
  }

  capSenseLEDUpdate();
}


void CapSenseControl() {
  
  readCapSenseInputs();
  
  if (cap_dev[11] < cap_threshold) {
    for (int j = 0; j < LED_SEGMENT_COUNT; j++) {
      if (segmentBris[j] < 1.0) {
        segmentBris[j] = segmentBris[j] + briStep2;
        segmentBris[j] = segmentBris[j] >= 1.0 ? 1.0 : segmentBris[j];
        break;
      }
    }
    capSenseLEDUpdate();
  }
  for (uint8_t i = 0; i < 12; i++) {
    cap_curr[i] = cap_dev[i] > cap_threshold; //greater is true is 1 is "pressed"
    if (cap_curr[i]) {
      int bri_or_sat = i / 5;
      int s = i - 5;
      switch (bri_or_sat) {
        case 0:
          segmentHues[i] = (segmentHues[i] + hueStep);
          segmentHues[i] = segmentHues[i] > 1.0 ? segmentHues[i] - 1.0 : segmentHues[i];
          break;
        case 1:
          segmentSats[s] = (segmentSats[s] + satSteps[s]);
          satSteps[s] = segmentSats[s] >= 1.0 ? satSteps[s] * -1 : segmentSats[s] <= 0.0 ? satSteps[s] * -1 : satSteps[s];
          segmentSats[s] = segmentSats[s] >= 1.0 ? 1.0 : segmentSats[s] <= 0.0 ? 0.0 : segmentSats[s];
          break;
        default: //case 2
          for (int j = LED_SEGMENT_COUNT - 1; j >= 0; j--) {
            if (segmentBris[j] > 0.0) {
              segmentBris[j] = segmentBris[j] - briStep1;
              segmentBris[j] = segmentBris[j] <= 0.0 ? 0.0 : segmentBris[j];
              break;
            } else {
              if (j == 0) {
                for (int k = 0; k < LED_SEGMENT_COUNT; k++) {
                  segmentSats[k] = 1.0;
                }
              }
            }
          }
          break;
      }
    }

    //if there was a state change
    if(cap_curr[i]!=cap_last[i]){
      //send the stationId, the id of the cap sensor, and the current state to which it changed
      webSocket.emit("capSense",("\""+String(stationId, DEC)+","+String(i,DEC)+","+String(cap_curr[i],DEC)+"\"").c_str());
      if(cap_curr[i]>cap_last[i]){
        //change was from touched to released
      }else
      {
        //change was from released to touched
        
      }
    }
    
    cap_last[i] = cap_curr[i]; //reset cap_last
  }

  capSenseLEDUpdate();
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
  Serial.printf("checking for firmware update\n");
  t_httpUpdate_return ret = ESPhttpUpdate.update("http://192.168.0.100:80/update/base", baseVersion);

  switch (ret) {
    case HTTP_UPDATE_FAILED:
      Serial.printf("HTTP_UPDATE_FAILD Error (%d): %s", ESPhttpUpdate.getLastError(), ESPhttpUpdate.getLastErrorString().c_str());
      break;

    case HTTP_UPDATE_NO_UPDATES:
      Serial.println("HTTP_UPDATE_NO_UPDATES");
      break;

    case HTTP_UPDATE_OK:
      Serial.println("HTTP_UPDATE_OK");
      break;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   Helper Functions
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

void chunkedDelay(int ms = 1000, int chunkSize = 10) {
  ////https://github.com/esp8266/Arduino/issues/34
  int chunks = ms / chunkSize;
  for (int i = 0; i < chunks; i++) {
    delay(chunkSize);
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
  Serial.printf("connected to server\n");
  String stationId_str = String(stationId, DEC);
  const char* stationId_char = stationId_str.c_str();
  webSocket.emit("subscribeStation", stationId_char);
}

void getInfoSocketEventHandler(const char * payload, size_t payloadLength) {
  Serial.printf("got getInfo message\n");
  String stationId_str = String(stationId, DEC);
  byte mac[6];
  WiFi.macAddress(mac);
  webSocket.emit("idhostnameipmac",
                 ("\"" + stationId_str + ","
                  + String(WiFi.hostname()) + ","
                  + String(WiFi.localIP()) + ","
                  + String(mac[0], HEX) + ","
                  + String(mac[1], HEX) + ","
                  + String(mac[2], HEX) + ","
                  + String(mac[3], HEX) + ","
                  + String(mac[4], HEX) + ","
                  + String(mac[5], HEX) + ","
                  + String(baseVersion)
                  + "\"").c_str()
                );
}

void clearSocketEventHandler(const char * payload, size_t payloadLength) {
  Serial.printf("got clear message\n");
  fill_solid(leds, LED_COUNT, CRGB(0, 0, 0));
  FastLED.show();//doRedraw = true;
}

void fillSolidSocketEventHandler(const char * payload, size_t payloadLength) {
  //Serial.printf("got fillSolid message: %s\n", payload);

  unsigned int output_length = decode_base64_length((unsigned char*)payload);
  unsigned char binPayload[output_length];
  decode_base64((unsigned char*)payload, binPayload);

  //startIndex
  //numToFill,
  //ledColor (r,g,b)
  fill_solid(leds + (uint8_t)binPayload[0], (uint8_t)binPayload[1], CRGB((uint8_t)binPayload[2], (uint8_t)binPayload[3], (uint8_t)binPayload[4]));

  FastLED.show();//doRedraw = true;
}

void setColorSocketEventHandler(const char * payload, size_t payloadLength) {
  //Serial.printf("got setColor message: %s\n", payload);

  unsigned int output_length = decode_base64_length((unsigned char*)payload);
  unsigned char binPayload[output_length];
  decode_base64((unsigned char*)payload, binPayload);

  //startIndex
  //ledColor (r,g,b)

  int first = (uint8_t)binPayload[0];
  leds[first].r = (uint8_t)binPayload[1];
  leds[first].g = (uint8_t)binPayload[2];
  leds[first].b = (uint8_t)binPayload[3];

  FastLED.show();//doRedraw = true;
}

void setColorsSocketEventHandler(const char * payload, size_t payloadLength) {
  //Serial.printf("got setColors message: %s\n", payload);

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

  FastLED.show();//doRedraw = true;
}

void setFivesSocketEventHandler(const char * payload, size_t payloadLength) {
  Serial.printf("got setFives message: %s\n", payload);

  unsigned int output_length = decode_base64_length((unsigned char*)payload);

  unsigned char binPayload[output_length];
  decode_base64((unsigned char*)payload, binPayload);

  for (int i = 0; i < LED_COUNT; i++) {
    leds[i].r = (uint8_t)binPayload[(i / LED_PER_SEGMENT_COUNT) * COLOR_BYTE_COUNT + 0];
    leds[i].g = (uint8_t)binPayload[(i / LED_PER_SEGMENT_COUNT) * COLOR_BYTE_COUNT + 2];
    leds[i].b = (uint8_t)binPayload[(i / LED_PER_SEGMENT_COUNT) * COLOR_BYTE_COUNT + 1];
  }

  FastLED.show();//doRedraw = true;
}

void checkForUpdateSocketEventHandler(const char * payload, size_t payloadLength) {
  Serial.printf("got checkForUpdate message: %s\n", payload);
  checkForUpdate();
}

void setModeSocketEventHandler(const char * payload, size_t payloadLength) {
  Serial.printf("got setMode: %s\n", payload);

  unsigned int output_length = decode_base64_length((unsigned char*)payload);

  unsigned char binPayload[output_length];
  decode_base64((unsigned char*)payload, binPayload);

  operationMode = (uint8_t)binPayload[0];
  Operate = operations[operationMode];
}

void setStationIdSocketEventHandler(const char * payload, size_t payloadLength) {
  Serial.printf("got setStationId: %s\n", payload);

  unsigned int output_length = decode_base64_length((unsigned char*)payload);

  unsigned char binPayload[output_length];
  decode_base64((unsigned char*)payload, binPayload);

  stationId = ((binPayload[0]<<0) & 0xFF) + ((binPayload[1]<<8) & 0xFF00);
  EEPROM.begin(512);
  EEPROMWriteInt(0, stationId);
  
  EEPROM.commit();
  EEPROM.end(); //also commits in addition to release from RAM copy
}


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

  chunkedDelay(100);
  EEPROM.write(p_address, lowByte);
  chunkedDelay(100);
  EEPROM.write(p_address + 1, highByte);
  chunkedDelay(100);
}

//This function will read a 2 byte integer from the eeprom at the specified address and address + 1
unsigned int EEPROMReadInt(int p_address)
{
  chunkedDelay(100);
  byte lowByte = EEPROM.read(p_address);
  chunkedDelay(100);
  byte highByte = EEPROM.read(p_address + 1);
  chunkedDelay(100);

  return ((lowByte << 0) & 0xFF) + ((highByte << 8) & 0xFF00);
}














void setup() {
  Serial.begin(BAUDRATE);
  Serial.setDebugOutput(true);
  Serial.println("Booting up");

  WiFi.mode(WIFI_OFF);
  WiFi.disconnect(); //in version 2.3.0 of ESP8266 library, can't WiFi.begin if already connected or more than 1 second of delay
  delay(100);
  WiFi.mode(WIFI_STA);
  WiFi.setAutoConnect(true);
  WiFi.setAutoReconnect(true);
  WiFi.begin(wifi_ssid, wifi_pass);
  
  webSocket.on("connect", connectSocketEventHandler);
  webSocket.on("getInfo", getInfoSocketEventHandler);
  webSocket.on("clear", clearSocketEventHandler);
  webSocket.on("fillSolid", fillSolidSocketEventHandler);
  webSocket.on("setColor", setColorSocketEventHandler);
  webSocket.on("setColors", setColorsSocketEventHandler);
  webSocket.on("setFives", setFivesSocketEventHandler);
  webSocket.on("checkForUpdate", checkForUpdateSocketEventHandler);
  webSocket.on("setMode", setModeSocketEventHandler);
  webSocket.on("setStationId", setStationIdSocketEventHandler);
  webSocket.begin(server_ip);
  
  pinMode(PIN_SDA, OUTPUT);
  pinMode(PIN_SCL, OUTPUT);
  Wire.begin(PIN_SDA, PIN_SCL); //SDA SCL
  Wire.setClockStretchLimit(1500); //https://github.com/esp8266/Arduino/issues/2607
  //Wire.setClock(100000L);
  delay(100);

  // 0x5C is the MPR121 I2C address on the Bare Touch Board
  while (!MPR121.begin(0x5A)) {
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
    delay(1000);
  }

  MPR121.setTouchThreshold(touchThreshold);
  MPR121.setReleaseThreshold(releaseThreshold);

  for (uint8_t i = 0; i < 12; i++) {
    cap_dev[i] = 0;
    cap_last[i] = 0; //released
    cap_curr[i] = 0; //released
  }

  FastLED.addLeds<LED_TYPE, LED_DATA_PIN, LED_COLOR_ORDER>(leds, LED_COUNT).setCorrection( TypicalLEDStrip );
  checkForUpdate();

  for (int i = 0; i < LED_SEGMENT_COUNT; i++) {
    segmentHues[i] = 0.5;
    segmentSats[i] = 1.0;
    segmentBris[i] = 1.0;
    satSteps[i] = satStepMag;
  }
  capSenseLEDUpdate();

  EEPROM.begin(512);
  stationId = EEPROMReadInt(0);
  Serial.print("stationId is: ");
  Serial.println(stationId);
  EEPROM.end();
}

void loop() {
  webSocket.loop();
  Operate();  
  
  //check for firmware updates once every ten minutes
  EVERY_N_SECONDS(600) {
    if (WiFi.status() == WL_CONNECTED) {
      checkForUpdate();
    }
  }
}





