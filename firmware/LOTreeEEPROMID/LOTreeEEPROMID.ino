/*
 * EEPROM Write
 *
 * Stores values read from analog input 0 into the EEPROM.
 * These values will stay in the EEPROM when the board is
 * turned off and may be retrieved later by another sketch.
 */

#include <EEPROM.h>

#define STATION_ID 18
int stationId = STATION_ID;

// the current address in the EEPROM (i.e. which byte
// we're going to write to next)
int addr = 0;

void setup()
{
  
  delay(2000);
  ESP.wdtDisable(); //stop the software watchdog, but not more than 6 seconds
  delay(1000);
  ESP.wdtEnable(259200000); //3 days
  ESP.wdtFeed();
  
  EEPROM.begin(512);
  for (int i = 0; i < 512; i++){
    EEPROM.write(i, 0);
  }
  EEPROMWriteInt(0, stationId);
  EEPROM.commit();
  EEPROM.end(); //also commits in addition to release from RAM copy
  Serial.begin(115200);
  Serial.print("station id is ");
  Serial.println(stationId);
}

void loop()
{
  
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
