#include <Adafruit_NeoPixel.h>

#include <Wire.h>
#include <SPI.h>
#include <Adafruit_CAP1188.h>
#define LED_PIN 6

int const STATION_SEGMENTS = 5;
int LED_COUNT = 45;
int SEGMENT_LED_COUNT = 9;
byte STATION_WHEEL_POS[STATION_SEGMENTS];
uint32_t STATION_COLOR[STATION_SEGMENTS];

Adafruit_CAP1188 cap = Adafruit_CAP1188();
Adafruit_NeoPixel strip = Adafruit_NeoPixel(45, LED_PIN, NEO_GRB + NEO_KHZ400);



void setup() {
  Serial.begin(9600);
  Serial.println("CAP1188 test!");
  // Initialize the sensor, if using i2c you can pass in the i2c address
  // if (!cap.begin(0x28)) {
  if (!cap.begin()) {
    Serial.println("CAP1188 not found");
    while(1);
  }
  Serial.println("CAP1188 found!");
  strip.begin();
  strip.show(); // Initialize all pixels to 'off'
  for (int i=0; i<STATION_SEGMENTS; i++) {
    STATION_WHEEL_POS[i] = 200;
    STATION_COLOR[i] = Wheel(STATION_WHEEL_POS[i]);
  }
  updateStation();
}

void loop() {
  uint8_t touched = cap.touched();

  if (touched == 0) {
    // No touch detected
    return;
  }

  for (uint8_t i=0; i<8; i++) {
    if (touched & (1 << i)) {
      Serial.print("C"); 
      Serial.print(i+1); 
      Serial.print("\t");
      if (i < 5) {
        STATION_WHEEL_POS[i] = (STATION_WHEEL_POS[i]+1)%255;
        STATION_COLOR[i] = Wheel(STATION_WHEEL_POS[i]);
        Serial.print(STATION_WHEEL_POS[i]);
        Serial.print(" ");
        Serial.println(STATION_COLOR[i]);
      }
      if (i == 7) {
        for (int j=0; j<STATION_SEGMENTS; j++) {
          STATION_WHEEL_POS[j] = (STATION_WHEEL_POS[j]+random(-2, 2))%255;
          STATION_COLOR[j] = Wheel(STATION_WHEEL_POS[j]);
        }
      }
    }
  }
  Serial.println();
  updateStation();
}

void updateStation() {
  for (int i=0; i<STATION_SEGMENTS; i++) {
    for (int j=0; j<SEGMENT_LED_COUNT; j++) {
      strip.setPixelColor(i*SEGMENT_LED_COUNT+j, STATION_COLOR[i]);
    }
  }
  strip.show();
}

uint32_t Wheel(byte WheelPos) {
  if(WheelPos < 85) {
    return strip.Color(WheelPos * 3, 255 - WheelPos * 3, 0);
  } 
  else if(WheelPos < 170) {
    WheelPos -= 85;
    return strip.Color(255 - WheelPos * 3, 0, WheelPos * 3);
  } 
  else {
    WheelPos -= 170;
    return strip.Color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
}




