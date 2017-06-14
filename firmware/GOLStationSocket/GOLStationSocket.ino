#include <Arduino.h>

#include <ESP8266WiFi.h>
#include <ESP8266WiFiMulti.h>

#include <SocketIoClient.h>

#define USE_SERIAL Serial
#define STATION_ID 12

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
uint8_t stationId = STATION_ID;
#define WIFI_SSID "imagine"
#define WIFI_PASS ""
#define SERVER_IP "192.168.0.100"

boolean doRedraw = true;
boolean doPrepareStationSegmentColors = false;
uint8_t stationLedColorIndex[STATION_LED_COUNT];
uint8_t currentLedIndex = 0;
boolean doShowStrip = false;

uint8_t gHue = 0; // rotating "base color" used by many of the patterns
CRGB rgbval(50, 0, 250);


ESP8266WiFiMulti WiFiMulti;
SocketIoClient webSocket;

void colorEventHandler(const char * payload, size_t payloadLength) {
  USE_SERIAL.printf("got message: %s\n", payload);

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

  //  for (int num = 0; num < payloadLength; num++) {
  //    dataString.concat(payload[num]);
  //  }
  //  String[] readings = dataString.split(dataString,',');
  //  for(int i=0;i<readings.length()||i>STATION_BYTE_COUNT;i++){
  //    packetBytesSerialBuffer[i] = (byte)(readings[i].toInt());
  //  }
  doRedraw = true;
}



void setup() {

  delay(2000); // 2 second delay for recovery

  // tell FastLED about the LED strip configuration
  FastLED.addLeds<LED_TYPE, DATA_PIN, COLOR_ORDER>(leds, NUM_LEDS).setCorrection(TypicalLEDStrip);
  //FastLED.addLeds<LED_TYPE,DATA_PIN,CLK_PIN,COLOR_ORDER>(leds, NUM_LEDS).setCorrection(TypicalLEDStrip);

  // set master brightness control
  FastLED.setBrightness(max_brightness);

  USE_SERIAL.begin(115200);

  USE_SERIAL.setDebugOutput(true);

  USE_SERIAL.println();
  USE_SERIAL.println();
  USE_SERIAL.println();

  for (uint8_t t = 4; t > 0; t--) {
    USE_SERIAL.printf("[SETUP] BOOT WAIT %d...\n", t);
    USE_SERIAL.flush();
    delay(1000);
  }

  //WiFiMulti.addAP(WIFI_SSID, WIFI_PASS);
  WiFiMulti.addAP("imagine");

  while (WiFiMulti.run() != WL_CONNECTED) {
    delay(100);
  }
  webSocket.emit("subscribe", "14");//number2char(stationId));
  webSocket.emit("subscribe", "stations");
  webSocket.on("colors", colorEventHandler);
  //webSocket.begin(SERVER_IP);
  webSocket.begin("192.168.0.100", 80);
  USE_SERIAL.printf("got to the bottom here\n");
}

char* number2char(uint8_t num) {
  return string2char(String(num, DEC));
}

//https://coderwall.com/p/zfmwsg/arduino-string-to-ch
char* string2char(String command) {
  if (command.length() != 0) {
    char *p = const_cast<char*>(command.c_str());
    return p;
  }
}

void loop() {
  webSocket.loop();
  if (doRedraw) {
    redraw();
  }
}

void redraw() {
  memcpy(packetBytes, packetBytesSerialBuffer, STATION_BYTE_COUNT);
  for (uint8_t i = 0; i < STATION_SEGMENT_COUNT; i++) {
    stationColors[i] = CRGB(
       (uint8_t)packetBytes[((COLOR_BYTE_COUNT * i) + 0)], //RED
       (uint8_t)packetBytes[((COLOR_BYTE_COUNT * i) + 2)], //GREEN
       (uint8_t)packetBytes[((COLOR_BYTE_COUNT * i) + 1)] //BLUE
     );
  }

  fill_solid(leds + 0, 10, stationColors[0]);
  fill_solid(leds + 10, 9, stationColors[1]);
  fill_solid(leds + 19, 9, stationColors[2]);
  fill_solid(leds + 28, 9, stationColors[3]);
  fill_solid(leds + 37, 8, stationColors[4]);
  FastLED.show();

  doRedraw = false;
}

