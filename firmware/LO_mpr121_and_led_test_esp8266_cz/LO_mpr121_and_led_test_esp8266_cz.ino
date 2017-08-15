#include <Adafruit_NeoPixel.h>
#include <MPR121.h>
#include <Wire.h>

#define LED_PIN 4
#define baudRate 57600

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

Adafruit_NeoPixel strip = Adafruit_NeoPixel(45, LED_PIN, NEO_GRB + NEO_KHZ400);

// this is the touch threshold - setting it low makes it more like a proximity trigger
// default value is 40 for touch
const int touchThreshold = 40;
// this is the release threshold - must ALWAYS be smaller than the touch threshold
// default value is 20 for touch
const int releaseThreshold = 20;
int cap_dev[12];
int cap_threshold = 2;
int cap_sum = 0;

#define PIN_SDA 14
#define PIN_SCL 5


void setup() {
  Serial.begin(baudRate);

  pinMode(PIN_SDA, OUTPUT);
  pinMode(PIN_SCL, OUTPUT);
  Wire.begin(PIN_SDA, PIN_SCL); //SDA SCL
  Wire.setClockStretchLimit(1500); //https://github.com/esp8266/Arduino/issues/2607
  //Wire.setClock(100000L);
  delay(100);

  //  // 0x5C is the MPR121 I2C address on the Bare Touch Board
  //  if (!MPR121.begin(0x5A)) {
  //    Serial.println("error setting up MPR121");
  //    switch (MPR121.getError()) {
  //      case NO_ERROR:
  //        Serial.println("no error");
  //        break;
  //      case ADDRESS_UNKNOWN:
  //        Serial.println("incorrect address");
  //        break;
  //      case READBACK_FAIL:
  //        Serial.println("readback failure");
  //        break;
  //      case OVERCURRENT_FLAG:
  //        Serial.println("overcurrent on REXT pin");
  //        break;
  //      case OUT_OF_RANGE:
  //        Serial.println("electrode out of range");
  //        break;
  //      case NOT_INITED:
  //        Serial.println("not initialised");
  //        break;
  //      default:
  //        Serial.println("unknown error");
  //        break;
  //    }
  //    while (1);
  //  }


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
  }

  strip.begin();
  strip.show(); // Initialize all pixels to 'off'
  for (int i = 0; i < STATION_SEGMENTS; i++) {
    STATION_HUE[i] = 0.5;
    STATION_SAT[i] = 1.0;
    STATION_BRI[i] = 1.0;
    SAT_STEP[i] = SAT_STEP_MAG;
  }
  updateStation();
}

void loop() {
  readRawInputs();

  if (cap_dev[11] < cap_threshold) {
    for (int j = 0; j < STATION_SEGMENTS; j++) {
      if (STATION_BRI[j] < 1.0) {
        STATION_BRI[j] = STATION_BRI[j] + BRI_STEP2;
        STATION_BRI[j] = STATION_BRI[j] >= 1.0 ? 1.0 : STATION_BRI[j];
        break;
      }
    }
    updateStation();
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
                  STATION_SAT[k] == 1.0;
                }
              }
            }
          }
          break;
      }
    }
  }
}

updateStation();
}

void updateStation() {
  for (int i = 0; i < STATION_SEGMENTS; i++) {
    uint32_t STATION_COLOR = HSV_to_RGB(i);
    for (int j = 0; j < SEGMENT_LED_COUNT; j++) {
      strip.setPixelColor(i * SEGMENT_LED_COUNT + j, STATION_COLOR);
    }
  }
  strip.show();
}

uint32_t HSV_to_RGB(int index) {
  float hue = STATION_HUE[index];
  float sat = sqrt(STATION_SAT[index]);
  float bri = STATION_BRI[index];
  hue = hue * 6;
  int i = floor(hue);
  float v = bri;
  float f = hue - i;
  float p = bri * (1 - sat);
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

void readRawInputs() {
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





