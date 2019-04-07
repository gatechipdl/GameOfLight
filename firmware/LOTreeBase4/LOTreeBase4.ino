///////////////////////////////////////////////////////////////////////////////////////////////////
//***use Flash size 4MB (1M SPIFFS)
///////////////////////////////////////////////////////////////////////////////////////////////////
//Flash real id:   001640EF
///////////////////////////////////////////////////////////////////////////////////////////////////
//Flash real size: 4194304
///////////////////////////////////////////////////////////////////////////////////////////////////
//Using Arduino ESP8266 Library version 2.5
///////////////////////////////////////////////////////////////////////////////////////////////////

const char* baseVersion = "4026";

#include <EEPROM.h>
#include <ESP8266WiFi.h>
#include <WiFiUdp.h>

#define FASTLED_ALLOW_INTERRUPTS 0
#include <FastLED.h>
//https://github.com/BareConductive/mpr121/blob/public/MPR121/MPR121.h
#include <MPR121.h>
#include <Wire.h>
#include <ESP8266HTTPClient.h>
#include <ESP8266httpUpdate.h>
#include <SocketIoClient.h>
#include "base64.h"
#include <ArtnetWifi.h>
extern "C" {
  #include "user_interface.h"
}


FASTLED_USING_NAMESPACE

#define LED_DATA_PIN 4
#define BAUD_RATE 115200
#define LED_TYPE    WS2811
#define LED_COLOR_ORDER GRB
//#define LED_OFFSET 1
#define LED_COUNT    45
#define LED_SEGMENT_COUNT 5
#define LED_PER_SEGMENT_COUNT 9
#define COLOR_BYTE_COUNT      3

#define PIN_SDA 14
#define PIN_SCL 5

uint16_t stationId = 0; //need to pull from EEPROM asap

CRGB leds[LED_COUNT];
float segmentHues[LED_SEGMENT_COUNT];
float segmentSats[LED_SEGMENT_COUNT];
float hueStep = 0.002;
float satStepMag = 0.008;//0.003;
float satSteps[LED_SEGMENT_COUNT];
float briStep1 = 0.03;//brightness off off speed
float briStep2 = 0.007;//recovery
float segmentBris[LED_SEGMENT_COUNT];

uint8_t gHue = 0; // rotating "base color" used by many of the patterns

#define CAPSENSE_COUNT 12
#define CAPSENSE_TOP 11

// this is the touch threshold - setting it low makes it more like a proximity trigger
// default value is 40 for touch
const int touchThreshold = 40;
// this is the release threshold - must ALWAYS be smaller than the touch threshold
// default value is 20 for touch
const int releaseThreshold = 20;
int cap_dev[CAPSENSE_COUNT];
int cap_threshold = 2;
int cap_sum = 0;
bool cap_last[CAPSENSE_COUNT]; //last state
bool cap_curr[CAPSENSE_COUNT]; //curr state

const char* wifi_ssid     = "Orchard";
const char* wifi_pass = "";
const char* server_ip = "192.168.1.100"; //make sure to change this in the checkUpdate() method too
SocketIoClient webSocket;


WiFiUDP _udp;
boolean _udpIsRunning=false;
unsigned int _localUdpPort = 30000; //+stationId?
#define UDP_MAX_INPUT_BYTE_COUNT  32
char _udpIncomingPacket[UDP_MAX_INPUT_BYTE_COUNT];
#define UDP_COMMAND_SETFIVES  5


// Art-Net settings
ArtnetWifi artnet;
int startUniverse = 0; // CHANGE FOR YOUR SETUP most software this is 1, some software send out artnet first universe as 0.

// Check if we got all universes
const int numberOfChannels = LED_COUNT * 3; // Total number of channels you want to receive (1 led = 3 channels)
const int maxUniverses = numberOfChannels / 512 + ((numberOfChannels % 512) ? 1 : 0);
bool universesReceived[maxUniverses];
bool sendFrame = 1;
int previousDataLength = 0;

void initWiFi();
void startWiFi();

void initWebSocket();
void startWebSocket();

void initUDP();
void startUDP();
//void flushUDP();
void stopUDP();

void initArtNet();
void startArtNet();
//void flushArtNet();
void stopArtNet();

void chunkedDelay(int ms, int chunkSize);
//void redraw();
void checkForUpdate();
void EEPROMWriteInt(int p_address, int p_value);
uint16_t EEPROMReadInt(int p_address);
void udpEvent();
void readCapSenseInputs();
void capSenseLEDUpdate();
void PostSetupInitialization();
void SlaveListenUDP();
void StrandTest1();
void StrandTest2();
void StrandTest3();
void CapSenseStandAlone();
void CapSenseControl();
void CapSenseControlTop();
void ArtNetControlled();
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
#define OPERATION_COUNT 8
OperationFunction operations[OPERATION_COUNT] = {
  SlaveListenUDP,            // 0 - listening
  StrandTest1,            // 1 - rainbow
  StrandTest2,            // 2 - another strandtest
  StrandTest3,            // 3 - another strandtest
  CapSenseStandAlone,           // 4 - cap sense test
  CapSenseControl,         // 5 - cap sense controller
  CapSenseControlTop,      // 6 - cap sense controller top
  ArtNetControlled      // 7 - artnet control reading
};
OperationFunction Operate = operations[operationMode]; //default startup operation mode

void capSenseLEDUpdate() {
  for (int i = 0; i < LED_SEGMENT_COUNT; i++) {
    //uint32_t STATION_COLOR = HSV_to_RGB(i);
    uint8_t h = (uint8_t)(segmentHues[i]*255);
    float sat = segmentSats[i];
    sat = 2.0*(sat-0.5); //shift from 0.0:1.0 to -1.0:+1.0
    sat = sin(sat*PI/2);//take sin
    bool wasNeg = sat<0;
    sat = (-1*wasNeg)*sqrt(abs(sat));//take square root to make it even flatter
    sat = (sat/2.0)+0.5; //shift back to 0.0:1.0
    
    uint8_t s = (uint8_t)(sat*255);
    uint8_t v = (uint8_t)(segmentBris[i]*255);
    fill_solid(leds + i*LED_PER_SEGMENT_COUNT, LED_PER_SEGMENT_COUNT, CHSV(h,s,v) );
//    for (int j = 0; j < LED_PER_SEGMENT_COUNT; j++) {
//      leds[i*LED_PER_SEGMENT_COUNT+j].setHSV(int(segmentHues[i]*255), int(segmentSats[i]*255), int(segmentBris[i]*255));
//    }
  }
  FastLED.show();
}

void PostSetupInitialization(){};

void SlaveListenUDP() {
  // 0 - listening
  udpEvent(); //check for udp events
}

void StrandTest1() {
  // 1 - rainbow
  fill_rainbow(leds, LED_COUNT, gHue, 7);
  FastLED.show();
  FastLED.delay(1000 / 120);
  EVERY_N_MILLISECONDS(30) {
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
  EVERY_N_MILLISECONDS(30) {
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
  EVERY_N_MILLISECONDS(30) {
    gHue++;
  }
}


void CapSenseStandAlone() {
  
  readCapSenseInputs();
  
  if (cap_dev[CAPSENSE_TOP] < cap_threshold) {
    for (int j = 0; j < LED_SEGMENT_COUNT; j++) {
      if (segmentBris[j] < 1.0) {
        segmentBris[j] = segmentBris[j] + briStep2;
        segmentBris[j] = segmentBris[j] >= 1.0 ? 1.0 : segmentBris[j];
        break;
      }
    }
    capSenseLEDUpdate();
  }
  for (uint8_t i = 0; i < CAPSENSE_COUNT; i++) {
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


/*
 * with UDP led controls
 * with Socket.Io CapSense controls
 */
void CapSenseControl() {
  udpEvent(); //check for udp events
  EVERY_N_MILLISECONDS(50) {
    readCapSenseInputs();

    for (uint8_t i = 0; i < CAPSENSE_COUNT; i++) {
      cap_curr[i] = cap_dev[i] > cap_threshold; //greater is true if 1 is "pressed"
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
  }
}

/*
 * with UDP led controls
 * with Socket.Io CapSense controls
 */
void CapSenseControlTop() {
  udpEvent(); //check for udp events
  EVERY_N_MILLISECONDS(50) {
    readCapSenseInputs();
    
    cap_curr[CAPSENSE_TOP] = cap_dev[CAPSENSE_TOP] > cap_threshold; //greater is true if 1 is "pressed"
    //if there was a state change
    if(cap_curr[CAPSENSE_TOP]!=cap_last[CAPSENSE_TOP]){
      //send the stationId, the id of the cap sensor, and the current state to which it changed
      webSocket.emit("capSense",("\""+String(stationId, DEC)+","+String(CAPSENSE_TOP,DEC)+","+String(cap_curr[CAPSENSE_TOP],DEC)+"\"").c_str());
      if(cap_curr[CAPSENSE_TOP]>cap_last[CAPSENSE_TOP]){
        //change was from touched to released
      }else
      {
        //change was from released to touched
    }
    cap_last[CAPSENSE_TOP] = cap_curr[CAPSENSE_TOP]; //reset cap_last
  }

//  EVERY_N_MILLISECONDS(1000) {
//    webSocket.emit("message",("\""+String(stationId, DEC)+","+String(cap_last[CAPSENSE_TOP],DEC)+","+String(cap_curr[CAPSENSE_TOP],DEC)+"\"").c_str());
//      }
  }
}

/*
 * with led control through ArtNet (UDP specific port)
 * with no CapSense controls yet
 */
void ArtNetControlled(){
  // we call the read function inside the loop
  artnet.read();
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
  t_httpUpdate_return ret = ESPhttpUpdate.update("http://192.168.1.100:80/update/base", baseVersion);

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

void initWebSocket(){
  webSocket.on("connect", connectSocketEventHandler);
  webSocket.on("getInfo", getInfoSocketEventHandler);
//  webSocket.on("clear", clearSocketEventHandler); //remove to reduce socket.io load
//  webSocket.on("fillSolid", fillSolidSocketEventHandler); //remove to reduce socket.io load
//  webSocket.on("setColor", setColorSocketEventHandler); //remove to reduce socket.io load
//  webSocket.on("setColors", setColorsSocketEventHandler); //remove to reduce socket.io load
  webSocket.on("setFives", setFivesSocketEventHandler);
  webSocket.on("checkForUpdate", checkForUpdateSocketEventHandler);
  webSocket.on("setMode", setModeSocketEventHandler);
  webSocket.on("setStationId", setStationIdSocketEventHandler);
}

void startWebSocket(){
  webSocket.begin(server_ip);
}
  
void subscribeStation(){
  String stationId_str = String(stationId, DEC);
  const char* stationId_char = stationId_str.c_str();
  webSocket.emit("subscribeStation", stationId_char);
}

void connectSocketEventHandler(const char * payload, size_t payloadLength) {
  Serial.printf("connected to server\n");
  subscribeStation();
}

void getInfoSocketEventHandler(const char * payload, size_t payloadLength) {
  Serial.printf("got getInfo message\n");
  String stationId_str = String(stationId, DEC);
  byte mac[6];
  WiFi.macAddress(mac);
  webSocket.emit("idhostnameipmac",
                 ("\"" + stationId_str + ","
                  + String(WiFi.hostname()) + ","
                  + String(WiFi.localIP().toString()) + ","
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

//  webSocket.emit("message",("\""+String(stationId, DEC)+": ["+
//  String(binPayload[0],DEC)+","+
//  String(binPayload[1],DEC)+","+
//  String(binPayload[2],DEC)+","+
//  String(binPayload[3],DEC)+","+
//  String(binPayload[4],DEC)+"]"+
//  "\"").c_str());

  //startIndex
  //numToFill,
  //ledColor (r,g,b)
  fill_solid(leds + (uint8_t)binPayload[0], (uint8_t)binPayload[1], CRGB((uint8_t)binPayload[2], (uint8_t)binPayload[4], (uint8_t)binPayload[3]));
  //fill_solid(leds+0,45,CRGB(0,0,255));
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
  leds[first].g = (uint8_t)binPayload[3];
  leds[first].b = (uint8_t)binPayload[2];

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


OperationFunction operations[OPERATION_COUNT] = {
  SlaveListenUDP,            // 0 - listening
  StrandTest1,            // 1 - rainbow
  StrandTest2,            // 2 - another strandtest
  StrandTest3,            // 3 - another strandtest
  CapSenseStandAlone,           // 4 - cap sense test
  CapSenseControl,         // 5 - cap sense controller
  CapSenseControlTop,      // 6 - cap sense controller top
  ArtNetControlled      // 7 - artnet control reading
};

  uint8_t newOperationMode = (uint8_t)binPayload[0];
  if(operationMode==0 || operationMode==5 || operationMode==6){
    stopUDP();
  }
  if(operationMode==7){
    stopArtNet();
  }

  operationMode = newOperationMode;
  if(operationMode==0 || operationMode==5 || operationMode==6){
    startUDP();
  }
  if(operationMode==7){
    startArtNet();
  }
  
  Operate = operations[operationMode];
}

void setStationIdSocketEventHandler(const char * payload, size_t payloadLength) {
  Serial.printf("got setStationId: %s\n", payload);

  unsigned int output_length = decode_base64_length((unsigned char*)payload);

  unsigned char binPayload[output_length];
  decode_base64((unsigned char*)payload, binPayload);

  stationId = binPayload[0] + binPayload[1]*256;
  EEPROM.begin(512);
  EEPROMWriteInt(0, stationId);
  
  EEPROM.commit();
  EEPROM.end(); //also commits in addition to release from RAM copy
}





///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   WiFi Methods
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

void initWiFi(){
  WiFi.mode(WIFI_OFF);
  WiFi.disconnect(); //in version 2.3.0 of ESP8266 library, can't WiFi.begin if already connected or more than 1 second of delay
  delay(100);
  WiFi.mode(WIFI_STA);
  wifi_set_sleep_type(NONE_SLEEP_T); //70mA power; without this should be 18mA average as it wakes up every <100ms to check for data
  WiFi.setAutoConnect(true);
  WiFi.setAutoReconnect(true);  
}

void startWiFi(){
 WiFi.begin(wifi_ssid, wifi_pass);
}
  
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   UDP Methods
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

void initUDP(){} //does nothing

void startUDP(){
  _udp.begin(_localUdpPort); //begin listening to UDP port for incoming data
  _udpIsRunning = true;
}

void stopUDP(){
  _udp.stop();
  _udpIsRunning = false;
}

void udpEvent(){
  int packetSize = _udp.parsePacket();
  //packet should be:
  //2 bytes source port
  //2 byte destination port
  //2 byte length of whole packet including data payload and header (includes checksum)
  //2 byte checksum
  //the data payload bytes
  
  if (packetSize)
  {
    // receive incoming UDP packets
    //Serial.printf("Received %d bytes from %s, port %d\n", packetSize, _udp.remoteIP().toString().c_str(), _udp.remotePort());
    int len = _udp.read(_udpIncomingPacket, UDP_MAX_INPUT_BYTE_COUNT);
    if (len > 0)
    {
      //first byte is the command byte
      switch(_udpIncomingPacket[0]){
        case UDP_COMMAND_SETFIVES:
          for (int i = 0; i < LED_COUNT; i++) {
            leds[i].r = (uint8_t)_udpIncomingPacket[(i / LED_PER_SEGMENT_COUNT) * COLOR_BYTE_COUNT + 0 + 1];
            leds[i].g = (uint8_t)_udpIncomingPacket[(i / LED_PER_SEGMENT_COUNT) * COLOR_BYTE_COUNT + 2 + 1];
            leds[i].b = (uint8_t)_udpIncomingPacket[(i / LED_PER_SEGMENT_COUNT) * COLOR_BYTE_COUNT + 1 + 1];
          }
          FastLED.show();
        break;
      }
    }
    //Serial.printf("UDP packet contents: %s\n", incomingPacket);
  }
}

















///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   CapSense
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////



void readCapSenseInputs() {
  int i;

  if (MPR121.touchStatusChanged()) MPR121.updateTouchData();
  MPR121.updateBaselineData();
  MPR121.updateFilteredData();
  cap_sum = 0;
  for (i = 0; i < CAPSENSE_COUNT; i++) {    // 12 value pairs
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
  uint8_t lowByte = ((p_value >> 0) & 0xFF);
  uint8_t highByte = ((p_value >> 8) & 0xFF);

  chunkedDelay(100);
  EEPROM.write(p_address, lowByte);
  chunkedDelay(100);
  EEPROM.write(p_address + 1, highByte);
  chunkedDelay(100);
}

//This function will read a 2 byte integer from the eeprom at the specified address and address + 1
uint16_t EEPROMReadInt(int p_address)
{
  chunkedDelay(100);
  uint8_t lowByte = EEPROM.read(p_address);
  chunkedDelay(100);
  uint8_t highByte = EEPROM.read(p_address + 1);
  chunkedDelay(100);

  //return ((lowByte << 0) & 0xFF) + ((highByte << 8) & 0xFF00);
  return uint16_t(lowByte) + uint16_t(highByte)*256;
}










///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   ArtNet Methods
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

void initArtNet(){
  artnet.setArtDmxCallback(onDmxFrame);
}

void startArtNet(){
  startUniverse = 0;
  artnet.begin(); //udp on port 0x1936 (6454 decimal)
}
void stopArtNet(){
  artnet.stop();
}

void onDmxFrameFlush(uint16_t universe, uint16_t length, uint8_t sequence, uint8_t* data){}

void onDmxFrame(uint16_t universe, uint16_t length, uint8_t sequence, uint8_t* data)
{ 
  sendFrame = 1;
  // set brightness of the whole strip
  if (universe == 15)
  {
    FastLED.setBrightness(data[0]);
    FastLED.show();
  }

  // Store which universe has got in
  if ((universe - startUniverse) < maxUniverses) {
    universesReceived[universe - startUniverse] = 1;
  }

  for (int i = 0 ; i < maxUniverses ; i++)
  {
    if (universesReceived[i] == 0)
    {
      //Serial.println("Broke");
      sendFrame = 0;
      break;
    }
  }
  

//  // read universe and put into the right part of the display buffer
//  for (int i = 0; i < length / 3; i++)
//  {
//    int led = i + (universe - startUniverse) * (previousDataLength / 3);
//    if (led < LED_COUNT)
//      leds[led] = CRGB(data[i * 3], data[i * 3 + 1], data[i * 3 + 2]);
//  }

  if(stationId<35){
    for (int i = 0; i < LED_SEGMENT_COUNT; i++) {
      //0,2,1
      uint8_t r = data[(stationId-1)*15+i*3+0];
      uint8_t g = data[(stationId-1)*15+i*3+2];
      uint8_t b = data[(stationId-1)*15+i*3+1];
      fill_solid(leds + i*LED_PER_SEGMENT_COUNT, LED_PER_SEGMENT_COUNT, CRGB(r,g,b) );
    }
    //FastLED.show();  
  } 

  
  previousDataLength = length;

  if (sendFrame)
  {
    FastLED.show();
    // Reset universeReceived to 0
    memset(universesReceived, 0, maxUniverses);
  }
}

void onDmxFrameFives(uint16_t universe, uint16_t length, uint8_t sequence, uint8_t* data)
{
  if(stationId<35){
    for (int i = 0; i < LED_SEGMENT_COUNT; i++) {
      //0,2,1
      uint8_t r = data[(stationId-1)*15+i*3+0];
      uint8_t g = data[(stationId-1)*15+i*3+2];
      uint8_t b = data[(stationId-1)*15+i*3+1];
      fill_solid(leds + i*LED_PER_SEGMENT_COUNT, LED_PER_SEGMENT_COUNT, CRGB(r,g,b) );
    }
    FastLED.show();  
  }  
}












///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   Initial Setup
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

void setup() {
  Serial.begin(BAUD_RATE);
  Serial.setDebugOutput(true);
  Serial.println("Booting up");

  //read the station ID asap
  EEPROM.begin(512);
  stationId = EEPROMReadInt(0);
  Serial.print("stationId is: ");
  Serial.println(stationId);
  EEPROM.end();

  initWiFi();
  startWiFi();
  
  initWebSocket();
  startWebSocket();
  initUDP();
  initArtNet();

  
  pinMode(PIN_SDA, OUTPUT);
  pinMode(PIN_SCL, OUTPUT);
  Wire.begin(PIN_SDA, PIN_SCL); //SDA SCL
  Wire.setClockStretchLimit(1500); //https://github.com/esp8266/Arduino/issues/2607
  //Wire.setClock(100000L);
  delay(100);

  byte capTry = 3;
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
    capTry--;
    if(capTry<=0){
      break;
    }
    delay(100);
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
    segmentHues[i] = 0.55;// blue
    segmentSats[i] = 1.0;
    segmentBris[i] = 1.0;
    satSteps[i] = satStepMag;
  }
  capSenseLEDUpdate();

  
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

  EVERY_N_SECONDS(280) {
    subscribeStation(); //subscribeStation periodically to make sure we can address them in socket.io by station name
  }
}
