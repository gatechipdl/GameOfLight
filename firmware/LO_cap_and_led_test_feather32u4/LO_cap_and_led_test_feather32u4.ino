#include <Adafruit_NeoPixel.h>

#include <Wire.h>
#include <SPI.h>
#include <Adafruit_CAP1188.h>
#define LED_PIN 6

int const STATION_SEGMENTS = 5;
int LED_COUNT = 45;
int SEGMENT_LED_COUNT = 9;
float STATION_HUE[STATION_SEGMENTS];
float HUE_STEP = 0.002;
float BRI_STEP = 0.03;
float BRI_STEP2 = 0.007;
float STATION_BRIGHTNESS[STATION_SEGMENTS];

Adafruit_CAP1188 cap = Adafruit_CAP1188();
Adafruit_NeoPixel strip = Adafruit_NeoPixel(45, LED_PIN, NEO_GRB + NEO_KHZ400);



void setup() {
  Serial.begin(9600);
  Serial.println("CAP1188 test!");
  // Initialize the sensor, if using i2c you can pass in the i2c address
  // if (!cap.begin(0x28)) {
  if (!cap.begin()) {
    Serial.println("CAP1188 not found");
    while (1);
  }
  Serial.println("CAP1188 found!");
  strip.begin();
  strip.show(); // Initialize all pixels to 'off'
  for (int i = 0; i < STATION_SEGMENTS; i++) {
    STATION_HUE[i] = 0.5;
    STATION_BRIGHTNESS[i] = 1.0;
  }
  updateStation();
}

void loop() {
  uint8_t touched = cap.touched();

  if (touched == 0) {
    for (int j = 0; j < STATION_SEGMENTS; j++) {
      if (STATION_BRIGHTNESS[j] < 1.0) {
        STATION_BRIGHTNESS[j] = STATION_BRIGHTNESS[j] + BRI_STEP2;
        STATION_BRIGHTNESS[j] = STATION_BRIGHTNESS[j] >= 1.0 ? 1.0 : STATION_BRIGHTNESS[j];
        break;
      }
    }
    updateStation();
    return;
  }

  for (uint8_t i = 0; i < 8; i++) {
    if (touched & (1 << i)) {
      Serial.print("C");
      Serial.print(i + 1);
      Serial.print("\t");
      if (i < 5) {
        STATION_HUE[i] = (STATION_HUE[i] + HUE_STEP);
        STATION_HUE[i] = STATION_HUE[i] > 1.0 ? STATION_HUE[i] - 1.0 : STATION_HUE[i];
      }
      if (i == 7) {
        for (int j = STATION_SEGMENTS - 1; j >= 0; j--) {
          if (STATION_BRIGHTNESS[j] > 0.0) {
            STATION_BRIGHTNESS[j] = STATION_BRIGHTNESS[j] - BRI_STEP;
            STATION_BRIGHTNESS[j] = STATION_BRIGHTNESS[j] <= 0.0 ? 0.0 : STATION_BRIGHTNESS[j];
            break;
          }
        }
      }
    }
  }

  Serial.println();
  updateStation();
}

void updateStation() {
  for (int i = 0; i < STATION_SEGMENTS; i++) {
    uint32_t STATION_COLOR = HSV_to_RGB(STATION_HUE[i], STATION_BRIGHTNESS[i]);
    for (int j = 0; j < SEGMENT_LED_COUNT; j++) {
      strip.setPixelColor(i * SEGMENT_LED_COUNT + j, STATION_COLOR);
    }
  }
  strip.show();
}

uint32_t HSV_to_RGB(float hue, float bri) {
  float sat = 1.0;
  hue = hue * 6;
  int i = floor(hue);
  float v = bri;
  float f = hue - i;
  float p = 1 - sat;
  float q = bri * (1 - sat * f);
  float t = bri * (1 - sat * (1 - f));
  byte r, g, b;
  switch (i) {
    case 0:
      r = round(255 * v);
      g = round(255 * t);
      b = round(255 * p);
      break;
    case 1:
      r = round(255 * q);
      g = round(255 * v);
      b = round(255 * p);
      break;
    case 2:
      r = round(255 * p);
      g = round(255 * v);
      b = round(255 * t);
      break;
    case 3:
      r = round(255 * p);
      g = round(255 * q);
      b = round(255 * v);
      break;
    case 4:
      r = round(255 * t);
      g = round(255 * p);
      b = round(255 * v);
      break;
    default: // case 5:
      r = round(255 * v);
      g = round(255 * p);
      b = round(255 * q);
  }
  return strip.Color(r, g, b);
}





