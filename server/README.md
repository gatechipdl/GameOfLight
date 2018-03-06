# Light Orchard Server
Light Orchard Server

## System Architecture
### Components
|Component|Purpose|
|---|---|
|Web Client|Connects to Web Server through Socket.IO and POST|
|Web Server|Routes requests between Web Clients and Stations|
|Station|Displays colors and senses capcitive touch leves|
### Orchard Analogy?
|Analogy|System Component|
|---|---|
|Orchard|System|
|Orchardist|Web Server|
|Tree|Station|
|Branch/Frond/Fruit|Pixel (5/Station)|
|Leaf/Frond/Fruit/Seed/Bud|LED (45/Station)|

## Web Client API
### Helper/Wrapper Methods (actual API)
|Status|Method Name|Description|
|---|---|---|
|planned1|RGB2HSV()|or just use npm color|
|planned1|HSV2RGB()|or just use npm color|
|planned2|orchard-client.setStationColors()||
|planned2|orchard-client.setStationColor()||
|planned2|orchard-client.setPixelColor()||
|planned2|orchard-client.listGroup()||
|planned2|orchard-client.listGroups()||
|planned2|orchard-client.createGroup()||
|planned2|orchard-client.renameGroup()||
|planned2|orchard-client.deleteGroup()||
|planned2|orchard-client.addToGroup()||
|planned2|orchard-client.setGroupColor()||
|planned2|orchard-client.requestDataModel()||
|planned2|orchard-client.setCapMode()||
|planned2|orchard-client.setCapFreq()||
|planned2|orchard-client.onCapSenseTouch(<event handler delegate>)||
|planned2|orchard-client.onCapSenseUnTouch(<event handler delegate>)||
|planned2|orchard-client.onCapSenseHold(<event handler delegate>)||
|planned2|orchard-client.onCapSenseUnHold(<event handler delegate>)||
|planned2|orchard-client.onCapSenseDoubleTap(<event handler delegate>)||
|planned2|orchard-client.onGroupList(<event handler delegate>=)||
|planned2|orchard-client.onDataModel(<event handler delegate>=)||
### Incoming Socket.IO Events from Web Server
see Web Server API - Outgoing Socket.IO Events
### Outgoing Socket.IO Events to Web Server
see Web Server API - Incoming Socket.IO Events

## Web Server API
### Incoming Socket.IO Events from Web Client
|Status|Message Name|Description|
|---|---|---|
|active|'SetFiveColors'|{'station_id":<#>, 'colors':[[255(R),255(G),255(B)](bottom),[0,0,0],[0,0,0],[0,0,0],[0,0,0]]}|
|active|'SetMode'||
|planned1|'setStationColors'|renaming of 'SetFiveColors'|
|planned2|'setStationColor'|just one color|
|planned2|'setPixelColor'|just one pixel on one station|
|planned2|'listGroup'|list members of one group|
|planned2|'listGroups'|list groups|
|planned2|'createGroup'|create group|
|planned2|'renameGroup'|rename group|
|planned2|'deleteGroup'|delete group|
|planned2|'addToGroup'|add stations and/or pixels to a group|
|planned2|'setGroupColor'|change color of pixels in stations in the group|
|planned2|'requestDataModel'|submits request for current data model with pixel colors, groups, states, and capsense values|
|planned2|'setCapMode'|Set capsense mode between event based or stream. Default is event based.|
|planned2|'setCapFreq'|Set capsense emission frequency. Default 10 Hz|
### Outgoing Socket.IO Events to Web Client
|Status|Message Name|Description|
|---|---|---|
|active|'CapSenseTouch'|{'station_id':<#>,'sensor_id':<#>}|
|active|'CapSenseUnTouch'|{'station_id':<#>,'sensor_id':<#>}|
|planned1|'capSenseTouch'|rename from 'CapSenseTouch'|
|planned1|'capSenseUnTouch'|rename from 'CapSenseUnTouch'|
|planned1|'capSenseHold'||
|planned1|'capSenseUnHold'||
|planned1|'capSenseDoubleTap'||
|planned2|'groupList'||
|planned2|'dataModel'|emits current data model with pixel colors, groups, states, and capsense values|
### Incoming Socket.IO Events from Stations
see Firmware Level API - Outgoing Socket.IO Events
### Outgoing Socket.IO Events to Stations
see Firmware Level API - Incoming Socket.IO Events
### Incoming UDP Events from Stations
see Firmware Level API - Outgoing UDP Events
### Outgoing UDP Events to Stations
see Firmware Level API - Incoming UDP Events

## Firmware Level API
### Incoming Socket.IO Events from Web Server
|Status|Message Name|Description|
|---|---|---|
|active|'connect'|Called on connection to websocket server. Emits "subscribeStation" message with station ID.|
|active|'getInfo'|Request to send "idhostnameipmac"|
|active|'clear'|Sets all colors to black and does FastLED.show()|
|active|'fillSolid'|Sets all 45 leds to same color using FastLED.fill_solid()|
|active|'setColor'|Sets one led to one color using leds[index].r,leds[index].g,leds[index].b|
|active|'setColors'|Sets a set of leds to colors based on sets of 3 bytes in the payload|
|active|'setFives'|Sets groups of 9 leds to one of 5 colors from a 15 byte payload|
|active|'checkForUpdate'|Calls ESPhttpUpdate.update() to check for new firmware|
|active|'setMode'|Changes the Operate function deleate to a new operationMode index|
|active|'setStationId'|Sets the provided 16 bit integer at the new stationId and commits it to EEPROM|
|planned1|'getNetworkInfo'|request network settings of the station|
|planned1|'setUDP'|Set UDP port and addresses|
|planned2|'setCapMode'|Set capsense mode between event based or stream. Default is event based.|
|planned2|'setCapFreq'|Set capsense emission frequency. Default 10 Hz|
### Outgoing Socket.IO Events to Web Server
|Status|Message Name|Description|
|---|---|---|
|active|'capSense'|Sends current value of a changed capsense along with stationId|
|active|'subscribeStation'|Sends request to Subscribe to the stationId channel and the 'station' channel too|
|active|'idhostnameipmac'|Message with station Id, hostname, IP address, mac address, and firmware version.|
|planned1|'networkInfo'|sent network settings|
### Incoming UDP Events from Web Server
|Status|Message Name|Description|
|---|---|---|
|planned1|setFive|Set all 5 pixels on the station|
|planned2|setOne|Set 1 of 5 pixels on the station|
### Outgoing UDP Events to Web Server
|Status|Message Name|Description|
|---|---|---|
|planned1|onTouchTrigger|Send capsense id with a value of 255|
|planned1|onUnTouchTrigger|Send capsense id with a value of 0|
|planned2|onCapsense|Stream out all capsense values at specified frequency|