#include <FastLED.h>
#include <MPR121.h>
#include <Wire.h>

#define LED_DATA_PIN 4
#define baudRate 57600
#define LED_TYPE    WS2811
#define LED_COLOR_ORDER GRB
#define LED_COUNT    45
#define LED_SEGMENT_COUNT 5
#define LED_PER_SEGMENT_COUNT 9

#define PIN_SDA 14
#define PIN_SCL 5

CRGB leds[LED_COUNT];
float segmentHues[LED_SEGMENT_COUNT];
float segmentSats[LED_SEGMENT_COUNT];
float hueStep = 0.002;
float satStepMag = 0.003;
float satSteps[LED_SEGMENT_COUNT];
float briStep1 = 0.03;
float briStep2 = 0.007;
float segmentBris[LED_SEGMENT_COUNT];

// this is the touch threshold - setting it low makes it more like a proximity trigger
// default value is 40 for touch
const int touchThreshold = 40;
// this is the release threshold - must ALWAYS be smaller than the touch threshold
// default value is 20 for touch
const int releaseThreshold = 20;
int cap_dev[12];
int cap_threshold = 2;
int cap_sum = 0;



void capSenseLEDUpdate() {
  for (int i = 0; i < LED_SEGMENT_COUNT; i++) {
    //uint32_t STATION_COLOR = HSV_to_RGB(i);
    for (int j = 0; j < LED_PER_SEGMENT_COUNT; j++) {
      leds[i*LED_PER_SEGMENT_COUNT+j].setHSV(int(segmentHues[i]*255), int(segmentSats[i]*255), int(segmentBris[i]*255));
    }
  }
  FastLED.show();
}

//uint32_t HSV_to_RGB(int index) {
//  float hue = segmentHues[index];
//  float sat = sqrt(segmentSats[index]);
//  float bri = segmentBris[index];
//  hue = hue * 6;
//  int i = floor(hue);
//  float v = bri;
//  float f = hue - i;
//  float p = bri * (1 - sat);
//  float q = bri * (1 - sat * f);
//  float t = bri * (1 - sat * (1 - f));
//  byte r, g, b;
//  switch (i) {
//    case 0:
//      r = round(255 * v);
//      g = round(255 * t);
//      b = round(255 * p);
//      break;
//    case 1:
//      r = round(255 * q);
//      g = round(255 * v);
//      b = round(255 * p);
//      break;
//    case 2:
//      r = round(255 * p);
//      g = round(255 * v);
//      b = round(255 * t);
//      break;
//    case 3:
//      r = round(255 * p);
//      g = round(255 * q);
//      b = round(255 * v);
//      break;
//    case 4:
//      r = round(255 * t);
//      g = round(255 * p);
//      b = round(255 * v);
//      break;
//    default: // case 5:
//      r = round(255 * v);
//      g = round(255 * p);
//      b = round(255 * q);
//  }
//  return strip.Color(r, g, b);
//}

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

void setup() {
  Serial.begin(baudRate);

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
  }

  FastLED.addLeds<LED_TYPE, LED_DATA_PIN, LED_COLOR_ORDER>(leds, LED_COUNT).setCorrection( TypicalLEDStrip );

  for (int i = 0; i < LED_SEGMENT_COUNT; i++) {
    segmentHues[i] = 0.5;
    segmentSats[i] = 1.0;
    segmentBris[i] = 1.0;
    satSteps[i] = satStepMag;
  }
  capSenseLEDUpdate();
}

void loop() {
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
    if (cap_dev[i] > cap_threshold) {
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
  }

  capSenseLEDUpdate();
}





