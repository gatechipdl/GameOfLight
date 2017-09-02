//use Flash size 4MB (1M SPIFFS)
//Flash real id:   001640EF
//Flash real size: 4194304

//for recovery when incorrect SPIFFS was set in the last binary firmware


//const char* baseVersion = "1000";

#include <ESP8266WiFi.h>

#include <ESP8266HTTPClient.h>
#include <ESP8266httpUpdate.h>

#define USE_SERIAL Serial

unsigned long currMillis = 0;
unsigned long lastMillis = 0;
unsigned long millisDuration = 20000;


void checkForUpdate(){
  t_httpUpdate_return ret = ESPhttpUpdate.update("http://192.168.0.100:80/update/base","1000");
   
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
  WiFi.begin("Orchard", "");
  
  USE_SERIAL.println();
  USE_SERIAL.println();
  USE_SERIAL.println();

  for (uint8_t t = 4; t > 0; t--) {
    USE_SERIAL.printf("[SETUP] BOOT WAIT %d...\n", t);
    USE_SERIAL.flush();
    delay(1000);
  }
  
  USE_SERIAL.printf("firmware version is 1000\n");
}





void loop() {
    //check for firmware updates once every two minutes
    currMillis = millis();
    if(currMillis-lastMillis>millisDuration){
      USE_SERIAL.printf("Attempting to check for updates\n");
      if(WiFi.status()==WL_CONNECTED){
        checkForUpdate();
      }else{
        USE_SERIAL.printf("Not connected to the Orchard WiFi network\n");
      }
      lastMillis = currMillis;
    }
}










