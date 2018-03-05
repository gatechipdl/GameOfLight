# Light Orchard Server
Light Orchard Server


## Web Client API
### Incoming Socket.IO Events from Web Server
|Message Name|Description|
|---|---|
| | |
### Outgoing Socket.IO Events to Web Server
|Message Name|Description|
|---|---|
| | |

## Web Server API
### Incoming Socket.IO Events from Web Client
|Message Name|Description|
|---|---|
| | |
### Outgoing Socket.IO Events to Web Client
|Message Name|Description|
|---|---|
| | |
### Incoming Socket.IO Events from Stations
|Message Name|Description|
|---|---|
| | |
### Outgoing Socket.IO Events to Stations
|Message Name|Description|
|---|---|
| | |
### Incoming UDP Events from Stations
|Message Name|Description|
|---|---|
| | |
### Outgoing UDP Events to Stations
|Message Name|Description|
|---|---|
| | |

## Firmware Level API
### Incoming Socket.IO Events from Web Server
|Message Name|Description|
|---|---|
|connect|Called on connection to websocket server. Emits "subscribeStation" message with station ID.|
|getInfo|Request to send "idhostnameipmac"|
|clear|Sets all colors to black and does FastLED.show()|
|fillSolid|Sets all 45 leds to same color using FastLED.fill_solid()|
|setColor|Sets one led to one color using leds[index].r,leds[index].g,leds[index].b|
|setColors|Sets a set of leds to colors based on sets of 3 bytes in the payload|
|setFives|Sets groups of 9 leds to one of 5 colors from a 15 byte payload|
|checkForUpdate|Calls ESPhttpUpdate.update() to check for new firmware|
|setMode|Changes the Operate function deleate to a new operationMode index|
|setStationId|Sets the provided 16 bit integer at the new stationId and commits it to EEPROM|
|planned1:getNetworkInfo|request network settings of the station|
|planned1:setUDP|Set UDP port and addresses|
|planned2:setCapMode|Set capsense mode between event based or stream. Default is event based.|
|planned2:setCapFreq|Set capsense emission frequency. Default 10 Hz|
### Outgoing Socket.IO Events to Web Server
|Message Name|Description|
|---|---|
|capSense|Sends current value of a changed capsense along with stationId|
|subscribeStation|Sends request to Subscribe to the stationId channel and the 'station' channel too|
|idhostnameipmac|Message with station Id, hostname, IP address, mac address, and firmware version.|
|planned1:networkInfo|sent network settings|
### Incoming UDP Events from Web Server
|Message Name|Description|
|---|---|
|planned1:setFive|Set all 5 pixels on the station|
|planned2:setOne|Set 1 of 5 pixels on the station|
### Outgoing UDP Events to Web Server
|Message Name|Description|
|---|---|
|planned1:onTouchTrigger|Send capsense id with a value of 255|
|planned1:onUnTouchTrigger|Send capsense id with a value of 0|
|planned2:onCapsense|Stream out all capsense values at specified frequency|