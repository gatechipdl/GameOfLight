'use strict';

const BASE_VERSION = 4002;

const express = require('express');
const app = express();
const server = require('http').createServer(app);
const io = require('socket.io')(server);
const color = require("rgb");
const base64js = require('base64-js');
const path = require('path');
const fs = require('fs');
const md5 = require('md5-file');
const dgram = require('dgram');
const udpSocket = dgram.createSocket('udp4');

var _webserverPort = 80;
var _udpPortSend = 30000; //all stations listen to UDP on port 30000
//var udpMulticastIP = '230.185.192.109'; //not being used
//var udpPortRecv = 60001; //not being used
//var udpDestIP = '192.168.1.199'; //not being used

const MAX_STATION_COUNT = 36;
const LED_CLUSTER_COUNT = 45; // actual LED count is 45*3 = 135
//the locally stored color array for each station
var _colors = new Array(MAX_STATION_COUNT).fill(new Array(LED_CLUSTER_COUNT).fill(new CRGB(0, 0, 0)));





// host everything in the public folder
app.use(express.static(__dirname + '/public'));

//check github.com/esp8266/Arduino/issues/2228 for example
app.get('/update/base', function (req, res) {
    //check version somehow

    console.log('a device is requesting an update');
    //console.dir(req.headers);
    if (parseInt(req.headers['x-esp8266-version']) != BASE_VERSION) { //could be <
        var full_path = path.join(__dirname, '/bin/base' + BASE_VERSION + '.bin');
        fs.readFile(full_path, "binary", function (err, file) {
            if (err) {
                console.log('error uploading new firmware');
                res.writeHeader(500, {
                    "Content-Type": "text/plain"
                });
                res.write(err + "\n");
                res.end();
            } else {
                console.log('uploading new firmware');
                res.writeHeader(200, {
                    "Content-Type": "application/octect-stream",
                    "Content-Disposition": "attachment;filename=" + path.basename(full_path),
                    "Content-Length": "" + fs.statSync(full_path)["size"],
                    "x-MD5": md5.sync(full_path)
                });
                res.write(file, "binary");
                res.end();
            }
        });
    } else {
        console.log('not uploading new firmware');
        res.writeHeader(304, {
            "Content-Type": "text/plain"
        });
        res.write("304 Not Modified\n");
        res.end();
    }

});



//spin up the webserver
server.listen(_webserverPort);








///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   Station Management
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////



//uses json object instead of an array in order to use the mac address as the key for faster lookup
//potential improvements - switch to an array, but build a lookup table with key value pairs for the array index
var _stationData = {
    "60-01-94-10-89-E1": {
        "online": false,
        "id": 2000,
        "mode": 4,
        "mac": "60-01-94-10-89-E1",
        "ip": "192.168.0.99",
        "name": "ESP_1089E1",
        "socket": "sdfghj",
        "firmware": "3005"
    }
};



//copied from the station firmware for reference
//var operationModes = {
//    0:'SlaveListen',
//    1:'StrandTest1',
//    2:'StrandTest2',
//    3:'StrandTest3'
//    4:'CapSenseTest',
//    5:'CapSenseControl',
//    6:'CapSenseControlTop'
//}



function loadStationData() {
    try {
        var dataFile = fs.readFileSync('./data/stations.json');
        _stationData = JSON.parse(dataFile);
    } catch (err) {
        console.log('stations.json file did not exist');
    }

}


loadStationData(); //get _stationData on server start
resetStationData();



function saveStationData() {
    console.log("saving station data");
    var dataJSON = JSON.stringify(_stationData);
    fs.writeFileSync('./data/stations.json', dataJSON);
}



// removes all data entries
function clearStationData() {
    Object.keys(_stationData).forEach(function (key) {
        delete _stationData[key];
    });
}



// sets all data entries' online to false
// run at start
function resetStationData() {
    Object.keys(_stationData).forEach(function (key) {
        _stationData[key]['online'] = false;
    });
}



function updateStationData(data) {
    Object.keys(data).forEach(function (key) {
        if (_stationData.hasOwnProperty(key)) {
            Object.assign(_stationData[key], data[key]); //merge data
        } else {
            _stationData[key] = data[key]; //add data
        }

    });
    io.sockets.emit('syncStationData', _stationData);
}



//helper function to convert a 32-bit int into a string IP address - Big Endian or Little Endian, not sure which
function int2ip(ipInt) {
    return ((ipInt >>> 24) + '.' + (ipInt >> 16 & 255) + '.' + (ipInt >> 8 & 255) + '.' + (ipInt & 255));
}



//helper function to convert a 32-bit int into a string IP address - Little Endian or Big Endian, not sure which
function int2ipReverse(ipInt) {
    return ((ipInt & 255) + '.' + (ipInt >> 8 & 255) + '.' + (ipInt >> 16 & 255) + '.' + (ipInt >>> 24));
}



function stationDataListener(socket) {
    socket.on('idhostnameipmac', function (data) {
        //parse the pieces and keep in a managed list
        console.log('idhostnameipmac');
        console.log(data);
        //parse and add to managed list
        var aData = data.split(",");
        //                  ("\"" + stationId_str + ","
        //                  + String(WiFi.hostname()) + ","
        //                  + String(WiFi.localIP()) + ","
        //                  + String(mac[0], HEX) + ","
        //                  + String(mac[1], HEX) + ","
        //                  + String(mac[2], HEX) + ","
        //                  + String(mac[3], HEX) + ","
        //                  + String(mac[4], HEX) + ","
        //                  + String(mac[5], HEX) + ","
        //                  + String(baseVersion)
        //                  + "\"").c_str()
        //                );
        var mData = aData[3] + "-" + aData[4] + "-" + aData[5] + "-" + aData[6] + "-" + aData[7] + "-" + aData[8];
        var sData = {
            [mData]: {
                'online': true,
                'id': aData[0],
                'mode': 0,
                'mac': mData,
                'ip': aData[2],
                'name': aData[1],
                'socket': socket['id'],
                'firmware': aData[9]
            }
        }
        console.log("sData");
        console.log(sData);
        updateStationData(sData)
    });
}



function getIPAddressFromStationID(stationId) {
    var ip = 0;
    Object.keys(_stationData).forEach(function (key) {
        if (_stationData[key]['id'] == stationId) {
            ip = _stationData[key]['ip'];
        }
    });
    //return int2ipReverse(ip);
    return ip;
}



//changes the id value of a number
function setstationIdListener(socket) {
    socket.on('setStationId', function (data) {
        if (!isNaN(data['stationId'])) {
            if (Number.parseInt(data['stationId'])) {
                console.log('setting mac ' + data['mac'] + ' to station ' + data['stationId'] + " through socket: " + [_stationData[data['mac']]['socket']]);
                var dataBuff16 = new Uint16Array([data['stationId']]);
                console.log('dataBuff16 ', dataBuff16);
                var dataBuff8 = new Uint8Array(dataBuff16.buffer);
                console.log('dataBuff8 ', dataBuff8);
                socket.broadcast.to([_stationData[data['mac']]['socket']]).emit('setStationId', base64js.fromByteArray(dataBuff8));
                //update station data

                updateStationData({
                    [data['mac']]: {
                        'id': data['stationId']
                    }
                });
            } else {
                console.log('stationId not an integer: ' + data);
            }
        } else {
            console.log('data issue: ' + data);
            console.dir(data);
        }
    })
}



function setStationModeListener(socket) {
    socket.on('setStationMode', function (data) {
        console.log('setting mac ' + data['mac'] + ' to mode ' + data['modeId']);
        var data64 = base64js.fromByteArray(new Uint8Array([data['modeId']]));
        socket.broadcast.to([_stationData[data['mac']]['socket']]).emit('setMode', data64);
        updateStationData({
            [data['mac']]: {
                'mode': data['modeId']
            }
        });
    });
}



function pingStationListener(socket) {
    socket.on('pingStation', function (data) {
        console.log('pinging mac ' + data['mac'] + ' at station number ' + _stationData[data['mac']]['id']);
        //var dataBuffer = new Uint8Array([startIndex,numToFill,ledColor.r,ledColor.g,ledColor.b]);
        var dataBuffer = new Uint8Array([0, 45, 0, 255, 0]); //all green
        socket.broadcast.to([_stationData[data['mac']]['socket']]).emit('fillSolid', base64js.fromByteArray(dataBuffer));
    });
}



function messageListener(socket) {
    socket.on('message', function (data) {
        console.log('message: ' + data);
    });
}



function checkForUpdateListener(socket) {
    socket.on('checkForUpdate', function (data) {
        console.log('trigging check for firmware update on mac ' + data['mac'] + ' at station number ' + _stationData[data['mac']]['id']);
        socket.broadcast.to([_stationData[data['mac']]['socket']]).emit('checkForUpdate', "");
    });
}



function saveStationDataListener(socket) {
    socket.on('saveStationData', function (data) {
        console.log('saving station data to file on server');
        saveStationData();
    });
}



function recoverStationDataListener(socket) {
    socket.on('recoverStationData', function (data) {
        console.log('trying to recover Station Ids');
        let stationDataBackup = _stationData;

        loadStationData(); //no callback
        //assume this happened instantly - bad assumption
        console.log('trying to loading current socket data');
        Object.keys(_stationData).forEach(function (key) {
            _stationData[key]['socket'] = stationDataBackup[key]['socket'];
        });

        io.sockets.emit('syncStationData', _stationData);
        console.log('setting station Ids from recovered data file');
        Object.keys(_stationData).forEach(function (key) {
            _stationData[key]['online'] = false;

            if (!isNaN(_stationData[key]['id'])) {
                if (Number.parseInt(_stationData[key]['id'])) {
                    console.log('setting mac ' + _stationData[key]['mac'] + ' to station ' + _stationData[key]['id'] + " through socket: " + _stationData[key]['socket']);
                    var dataBuff16 = new Uint16Array([_stationData[key]['id']]);
                    console.log('dataBuff16 ', dataBuff16);
                    var dataBuff8 = new Uint8Array(dataBuff16.buffer);
                    console.log('dataBuff8 ', dataBuff8);
                    socket.broadcast.to([_stationData[key]['socket']]).emit('setStationId', base64js.fromByteArray(dataBuff8));
                    //update station data
                } else {
                    console.log('id not an integer: ' + data);
                }
            } else {
                console.log('data issue: ' + data);
                console.dir(data);
            }
        });
    });
}



//stations = [
//    ESP_1089E5	60-01-94-10-89-E5	192.168.0.102	01:09:16
//3	ESP_0FF841	60-01-94-0F-F8-41	192.168.0.103	01:09:18
//4	ESP_108363	60-01-94-10-83-63	192.168.0.104	01:09:16
//5	ESP_108507	60-01-94-10-85-07	192.168.0.105	01:40:14
//6	ESP_0FF49E	60-01-94-0F-F4-9E	192.168.0.106	01:09:16
//7	ESP_108BE2	60-01-94-10-8B-E2	192.168.0.107	01:09:16
//8	ESP_0FF846	60-01-94-0F-F8-46	192.168.0.108	01:09:16
//9	ESP_0E7780	60-01-94-0E-77-80	192.168.0.109	01:09:15
//10	ESP_1083B1	60-01-94-10-83-B1	192.168.0.110	01:09:15
//11	ESP_108B42	60-01-94-10-8B-42	192.168.0.111	01:09:16
//12	ESP_0E7772	60-01-94-0E-77-72	192.168.0.112	01:09:20
//13	ESP_108446	60-01-94-10-84-46	192.168.0.113	01:40:16
//14	ESP_107D19	60-01-94-10-7D-19	192.168.0.114	01:09:16
//15	ESP_0E75FE	60-01-94-0E-75-FE	192.168.0.115	01:09:16
//16	ESP_0E777D	60-01-94-0E-77-7D	192.168.0.116	01:09:16
//17	ESP_10835B	60-01-94-10-83-5B	192.168.0.117	01:09:16
//18	ESP_0FF684	60-01-94-0F-F6-84	192.168.0.118	01:09:16
//19	ESP_1080FB	60-01-94-10-80-FB	192.168.0.119	01:09:16
//20	ESP_0FF4BB	60-01-94-0F-F4-BB	192.168.0.120	01:09:16
//21	ESP_0E7545	60-01-94-0E-75-45	192.168.0.121	01:40:14
//22	ESP_1083C7	60-01-94-10-83-C7	192.168.0.122	01:09:16
//23	ESP_107EC9	60-01-94-10-7E-C9	192.168.0.123	01:09:16
//24	ESP_0FF398	60-01-94-0F-F3-98	192.168.0.124	00:38:29
//25	ESP_108A60	60-01-94-10-8A-60	192.168.0.125	01:38:09
//26	ESP_0FF878	60-01-94-0F-F8-78	192.168.0.126	01:09:16
//27	ESP_0FF634	60-01-94-0F-F6-34	192.168.0.127	01:09:16
//28	ESP_108C51	60-01-94-10-8C-51	192.168.0.128	01:09:16
//29	ESP_0E7620	60-01-94-0E-76-20	192.168.0.129	01:40:29
//30	ESP_107CA2	60-01-94-10-7C-A2	192.168.0.130	01:09:16
//31	ESP_108167	60-01-94-10-81-67	192.168.0.131	01:09:16
//32	ESP_10818B	60-01-94-10-81-8B	192.168.0.132	01:09:16
//33	ESP_0E7563	60-01-94-0E-75-63	192.168.0.133	01:40:14
//34	ESP_107FB3	60-01-94-10-7F-B3




///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   CapSense
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
function capSenseListener(socket) {
    socket.on('capSense', function (data) { //TODO: modify firmware to emit use 'CapSenseEvent'
        console.log('capsense: ' + data);
        var cData = data.split(","); //station, cap, state
        var nData = {
            'stationId': cData[0],
            'sensorId': cData[1],
            'value': cData[2]
        }
        io.sockets.to('browsers').emit('CapSenseEvent', nData);


        var t_entry;
        capsenseData.forEach(function (entry) {
            if (entry.stationId == nData.stationId) {
                t_entry = entry;
            }
        });

        if (!t_entry) {
            var newEntry = {
                'stationId': nData.stationId,
                'values': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
            };
            newEntry.values[nData.sensorId] = nData.value;
            capsenseData.push(newEntry);
        } else {
            var bData = {
                'stationId': t_entry.stationId, //1-25
                'sensorId': nData.sensorId //0-4: One side, 5-9: One side, 11: Top
            };
            if (nData.value > t_entry.values[nData.sensorId]) {
                io.sockets.to('browsers').emit('CapSenseTouch', bData);
            } else {
                io.sockets.to('browsers').emit('CapSenseUnTouch', bData);
            }
            t_entry.values[nData.sensorId] = nData.value;
        }
    });
}

var capsenseData = [];


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   test.html Socket Methods
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


function setModeRawListener(socket) {
    socket.on('setModeRaw', function (dataRaw) {
        console.log(dataRaw);
        var data64 = base64js.fromByteArray(new Uint8Array([dataRaw]));
        console.log(data64);
        //socket.broadcast.to('stations').emit('setMode',data64);  - these didn't work
        //io.sockets.to('stations').emit('setMode',data64); - these didn't work
        io.sockets.emit('setMode', data64);
    });
}

function checkForUpdatesListener(socket) {
    socket.on('checkForUpdates', function () {
        io.sockets.emit('checkForUpdate', "");
    });
}

function setFiveHueColorsListener(socket) {
    socket.on('setFiveHueColors', function () {
        fiveColors = new Array(5).fill(new CRGB(0, 0, 0));
        hue = (hue + 10) % hueBase;
        console.log(hue);
        var t_hue = hue;
        t_hue = (hue + 10) % hueBase;
        fiveColors[0] = HSVtoRGB(t_hue / (hueBase), 1.0, 1.0);
        t_hue = (hue + 20) % hueBase;
        fiveColors[1] = HSVtoRGB(t_hue / (hueBase), 1.0, 1.0);
        t_hue = (hue + 30) % hueBase;
        fiveColors[2] = HSVtoRGB(t_hue / (hueBase), 1.0, 1.0);
        t_hue = (hue + 40) % hueBase;
        fiveColors[3] = HSVtoRGB(t_hue / (hueBase), 1.0, 1.0);
        t_hue = (hue + 50) % hueBase;
        fiveColors[4] = HSVtoRGB(t_hue / (hueBase), 1.0, 1.0);

        //        var dataBuffer = new Uint8Array([
        //            fiveColors[0].r, fiveColors[0].g, fiveColors[0].b,
        //            fiveColors[1].r, fiveColors[1].g, fiveColors[1].b,
        //            fiveColors[2].r, fiveColors[2].g, fiveColors[2].b,
        //            fiveColors[3].r, fiveColors[3].g, fiveColors[3].b,
        //            fiveColors[4].r, fiveColors[4].g, fiveColors[4].b
        //        ]);
        //        var data64 = base64js.fromByteArray(dataBuffer);
        //        //io.sockets.emit('setFives', data64);


        let colors = [
            [fiveColors[0].r, fiveColors[0].g, fiveColors[0].b],
            [fiveColors[1].r, fiveColors[1].g, fiveColors[1].b],
            [fiveColors[2].r, fiveColors[2].g, fiveColors[2].b],
            [fiveColors[3].r, fiveColors[3].g, fiveColors[3].b],
            [fiveColors[4].r, fiveColors[4].g, fiveColors[4].b]
                ];

        for (let i = 1; i < 26; i++) {
            setFivesUDP({
                'stationId': i,
                'colors': colors
            });
        }

    });
}

/*
should include tree id and 1 color
*/
function setTreeColorListener(socket) {
    socket.on('setTreeColor', function (data) {
        console.dir(data);
        /*
        {
        stationId:'asdf',
        color:[255,255,255]
        }
        */
        var theColor = data['color'];

        var dataBuffer = new Uint8Array([
            theColor[0], theColor[1], theColor[2],
            theColor[0], theColor[1], theColor[2],
            theColor[0], theColor[1], theColor[2],
            theColor[0], theColor[1], theColor[2],
            theColor[0], theColor[1], theColor[2]
        ]);

        var data64 = base64js.fromByteArray(dataBuffer);
        socket.broadcast.to(data['stationId']).emit('setFives', data64);
    });
}


function setFiveColorsListener(socket) {
    socket.on('SetFiveColors', function (data) {
        if (data['log']) {
            console.dir(data);
        }
        //socket.broadcast.emit('SetFiveColors', data); //for logging purposes
        /*
        {
        stationId:'asdf',
        colors:[
        [255,255,255],
        [255,255,255],
        [255,255,255],
        [255,255,255],
        [255,255,255]
        ]
        }
        */
        //        fiveColors = data['colors'];
        //
        //        var dataBuffer = new Uint8Array([
        //            fiveColors[0][0],fiveColors[0][1],fiveColors[0][2],
        //            fiveColors[1][0],fiveColors[1][1],fiveColors[1][2],
        //            fiveColors[2][0],fiveColors[2][1],fiveColors[2][2],
        //            fiveColors[3][0],fiveColors[3][1],fiveColors[3][2],
        //            fiveColors[4][0],fiveColors[4][1],fiveColors[4][2]
        //        ]);
        //
        //        var data64 = base64js.fromByteArray(dataBuffer);
        //        socket.broadcast.to(data['stationId']).emit('setFives',data64);

        setFivesUDP(data); //route through to UDP
    });
}



function setMultipleFiveColorsListener(socket) {
    socket.on('setMultipleFiveColors', function (data) {
        if (data['log']) {
            console.dir(data);
        }
        /*
        {'stations':[
            {stationId:'asdf',
            colors:[
            [255,255,255],
            [255,255,255],
            [255,255,255],
            [255,255,255],
            [255,255,255]
            ]},
            {},
            {}...
        ]}
        */
        if(data.hasOwnProperty('stations')){
            if(Array.isArray((data['stations']))){
                (data['stations']).forEach(function(stationColorSet){
                    setFivesUDP(stationColorSet); //route through to UDP
                })
            }
        }
    });
}



//sets one station's colors to the same color
function setColumnarColorsListener(socket) {
    socket.on('setColumnarColors', function (data) {
        //console.dir(data);
        /*
        {
        stationId:'asdf',
        color:[
        [255,255,255]
        }
        */
        var theColor = data['color'];
        fillSolid(data['stationId'], 0, 45, new CRGB(theColor[0], theColor[1], theColor[2]));
    });
}


function clearColorsListener(socket) {
    socket.on('clearColors', function () {
        {
            console.log('clear colors');
            io.sockets.emit('clear', "");
        }
    });
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   SYNC Data
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////



//var uiSettings = {
//    'lastElementChanged':'test',
//    'elements':{
//        'test':'value'
//    }
//};
//
//function syncUISettings(socket){
//    socket.on('syncUISettings',function(data){
//        uiSettings['elements'][Object.keys(data)[0]] = data[Object.keys(data)[0]];;// = merge.recursive(true,data,uiSettings['elements']);
//
//        console.log(Object.keys(data)[0]);
//        uiSettings['lastElementChanged'] = Object.keys(data)[0]; //assumes only one pair
//        //console.log(uiSettings['lastElementChanged']);
//
//        //broadcast the updates and change for other clients to process
//        socket.broadcast.emit('syncUISettings',data);
//    });
//}

//var modelData = {
//    //'0':[0,0,0,4,0,0,127]
//    //'1':[x,y,z,s,r,g,b]
//};
//
//function syncModelData(socket){
//    socket.on('syncModelData',function(data){
//        Object.keys(data).forEach(function(key) {
//            modelData[key] = data[key];
//        });
//        //broadcast the updates and change for other clients to process
//        socket.broadcast.emit('syncModelData',data);
//    });
//}
//
//var systemVariables = {
//    'availableId':0
//};
//
//function syncSystemVariables(socket){
//    socket.on('syncSystemVariables',function(data){
//        Object.keys(data).forEach(function(key) {
//            systemVariables[key] = data[key];
//        });
//        //broadcast the updates and change for other clients to process
//        socket.broadcast.emit('syncSystemVariables',data);
//    });
//}






///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   UDP
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////



//udpSocket.on('error', (err) => {
//    console.log('udp socket error:\n${err.stack}');
//    console.log('closing the udp socket');
//    udpServer.close();
//    //TODO add function to restart the udp socket
//});
//
//udpSocket.on('message', (msg, rinfo) => {
//    console.log('udp socket got: ', msg, ' from ', rinfo.address, ':', rinfo.port);
//    parseData(msg);
//});
//
//udpSocket.on('listening', () => {
//    const address = udpSocket.address();
//    console.log('udp socket listening ', address.address, ':', address.port);
//});
//
//udpSocket.bind(udpPortRecv, () => {});
////udpSocket.bind(udpPortSend, function(){
////    udpSocket.setBroadcast(true);
////    udpSocket.setMulticastTTL(128);
////    udpSocket.addMembership(udpMulticastIP);
////});



function sendUDPSocket(msg, stationId) {
    //console.log('sending UDP Socket');
    let ip = getIPAddressFromStationID(stationId);
    // console.log(stationId+":"+ip);
    if (isNaN(ip)) {
        udpSocket.send(msg, 0, msg.length, _udpPortSend, ip);
        //console.log([stationId, ip, udpPortSend, msg.length])
    }
}

const UDP_COMMAND_SETFIVES = 5;

function setFivesUDP(data) {
    //{'stationId":<#>, 'colors':[ [255(R),255(G),255(B)](bottom),[0,0,0],[0,0,0],[0,0,0],[0,0,0] ]}
    let msg = new Buffer.from([
        UDP_COMMAND_SETFIVES, //COMMAND byte
        data['colors'][0][0],
        data['colors'][0][1],
        data['colors'][0][2],
        data['colors'][1][0],
        data['colors'][1][1],
        data['colors'][1][2],
        data['colors'][2][0],
        data['colors'][2][1],
        data['colors'][2][2],
        data['colors'][3][0],
        data['colors'][3][1],
        data['colors'][3][2],
        data['colors'][4][0],
        data['colors'][4][1],
        data['colors'][4][2]
        ]);
    sendUDPSocket(msg, data['stationId']);
}









///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   Socket.IO
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////



var clientSockets = {};
//node id
//socket io id
//ip address
//udp send port: 60000


io.on('connection', function (socket) {
    console.log("client " + socket['id'] + " connected");
    //clearAll();

    stationDataListener(socket);
    messageListener(socket);

    socket.on('subscribeStation', function (roomName) {
        socket.join(roomName);
        socket.join('stations');

        var tAddress = socket.handshake.address;
        var idx = tAddress.replace(/^.*:/, ''); //chop down ipv6 to ipv4
        console.log("station client " + socket['id'] + " joined room " + roomName + " at ip: " + idx);

        checkForUpdate(roomName);
        capSenseListener(socket);

        socket.on('disconnect', function () {
            Object.keys(_stationData).forEach(function (key) {
                if (_stationData[key]['socketId'] === socket['id']) {
                    updateStationData({
                        [key]: {
                            "online": false
                        }
                    });
                }
            });
        });
    });

    socket.on('subscribe', function (roomName) {
        socket.join(roomName);

        var tAddress = socket.handshake.address;
        var idx = tAddress.replace(/^.*:/, ''); //chop down ipv6 to ipv4
        console.log("client " + socket['id'] + " joined room " + roomName + " at ip: " + idx);

        clientSockets[socket['id']] = {
            'iosocket': socket['id'],
            'ipaddress': idx
        }

        socket.on('disconnect', function () {
            for (var key in clientSockets) {
                if (clientSockets[key]['iosocket'] == socket['id']) {
                    delete clientSockets[key];
                }
            }
        });

        if (roomName == 'browsers') {
            socket.emit('syncStationData', _stationData);

            //for manager.html
            setstationIdListener(socket);
            setStationModeListener(socket);
            pingStationListener(socket);
            checkForUpdateListener(socket);
            saveStationDataListener(socket);
            recoverStationDataListener(socket);
            requestStationInfoListener(socket);

            //for test.html
            setModeRawListener(socket);
            checkForUpdatesListener(socket);
            setFiveHueColorsListener(socket);
            setTreeColorListener(socket);
            setFiveColorsListener(socket);
            setMultipleFiveColorsListener(socket);
            setColumnarColorsListener(socket);
            clearColorsListener(socket);
        }
    });
});




/*
 * prototype function for CRGB data to mimic the FastLED library
 */
function CRGB(red, green, blue) {
    this.r = red;
    this.g = green;
    this.b = blue;
    this.int = function () {
        return r >> 16 + g >> 8 + b >> 0;
    }
    this.setRGB = function (red, green, blue) {
        this.r = red;
        this.g = green;
        this.b = blue;
    }
    this.setHSV = function (hue, sat, val) {
        var temp = HSVtoRGB(hue, sat, val);
        this.r = temp.r;
        this.g = temp.g;
        this.b = temp.b;
    }
}



/*
 * Turn off LEDs on a specific station
 */
function clear(stationId) {
    io.sockets.to(stationId).emit('clear', '');
}



/*
 * Turn off LEDs on all stations
 */
function clearAll() {
    io.sockets.to('stations').emit('clear', '');
}



/*
 * mimics FastLED FillSolid method
 */
function fillSolid(stationId, startIndex, numToFill, ledColor) {
    if (!isNaN(stationId)) {
        //update server's copy of the LED cluster state
        for (var i = startIndex; i < startIndex + numToFill; i++) {
            _colors[stationId][i].r = ledColor.r;
            _colors[stationId][i].g = ledColor.g;
            _colors[stationId][i].b = ledColor.b;
        }
    }
    let dataBuffer = new Uint8Array([startIndex, numToFill, ledColor.r, ledColor.g, ledColor.b]);
    io.sockets.to(stationId).emit('fillSolid', base64js.fromByteArray(dataBuffer));
}



/*
 * Set a single LED color on a specific station
 */
function setOneColor(stationId, startIndex, ledColor) {
    if (!isNaN(stationId)) {
        //update server's copy of the LED custer state
        _colors[stationId][startIndex].r = ledColor.r;
        _colors[stationId][startIndex].g = ledColor.g;
        _colors[stationId][startIndex].b = ledColor.b;
    }
    let dataBuffer = new Uint8Array([startIndex, ledColor.r, ledColor.g, ledColor.b]);
    io.sockets.to(stationId).emit('setColor', dataBuffer);
}



/*
 * Send a set of different colors to a subset of a specific station
 * Could be the whole station
 * the number of leds is computed by the lenth of the colorArray
 * colorArray is an array of CRGB
 */
function setMultipleColors(stationId, startIndex, colorArray) {
    //update server's copy of the LED custer state
    _colors[stationId][ledIndex].r = ledColor.r;
    _colors[stationId][ledIndex].g = ledColor.g;
    _colors[stationId][ledIndex].b = ledColor.b;

    var dataBuffer = new Uint8Array([ledIndex, numToFill, ledColor.r, ledColor.g, ledColor.b]);
    io.sockets.to(stationId).emit('setColors', dataBuffer);
}



/*
 * GOL Station 5 segment code
 */
function setFiveColors(stationId, fiveColorArray) {
    if (!isNaN(stationId)) {
        //update server's copy of the LED custer state
        if (stationId < MAX_STATION_COUNT) {
            for (var i = 0; i < 5; i++) {
                for (var j = 0; j < LED_CLUSTER_COUNT / 5; j++) {
                    _colors[stationId][i * 9 + j].r = fiveColorArray[i].r;
                    _colors[stationId][i * 9 + j].g = fiveColorArray[i].g;
                    _colors[stationId][i * 9 + j].b = fiveColorArray[i].b;
                }
            }
        }
    }


    //    var dataArrayBuffer = new ArrayBuffer(15);
    //    var dataBuffer = new Uint8Array(dataArrayBuffer);
    //    dataArrayBuffer[0]=fiveColorArray[0].r;
    //    dataArrayBuffer[1]=fiveColorArray[0].g;
    //    dataArrayBuffer[2]=fiveColorArray[0].b;
    //    
    //    dataArrayBuffer[3]=fiveColorArray[1].r;
    //    dataArrayBuffer[4]=fiveColorArray[1].g;
    //    dataArrayBuffer[5]=fiveColorArray[1].b;
    //    
    //    dataArrayBuffer[6]=fiveColorArray[2].r;
    //    dataArrayBuffer[7]=fiveColorArray[2].g;
    //    dataArrayBuffer[8]=fiveColorArray[2].b;
    //    
    //    dataArrayBuffer[9]=fiveColorArray[3].r;
    //    dataArrayBuffer[10]=fiveColorArray[3].g;
    //    dataArrayBuffer[11]=fiveColorArray[3].b;
    //    
    //    dataArrayBuffer[12]=fiveColorArray[4].r;
    //    dataArrayBuffer[13]=fiveColorArray[4].g;
    //    dataArrayBuffer[14]=fiveColorArray[4].b;

    var dataBuffer2 = new Uint8Array([
        fiveColorArray[0].r, fiveColorArray[0].g, fiveColorArray[0].b,
        fiveColorArray[1].r, fiveColorArray[1].g, fiveColorArray[1].b,
        fiveColorArray[2].r, fiveColorArray[2].g, fiveColorArray[2].b,
        fiveColorArray[3].r, fiveColorArray[3].g, fiveColorArray[3].b,
        fiveColorArray[4].r, fiveColorArray[4].g, fiveColorArray[4].b
    ]);

    io.sockets.to(stationId).emit('setFives', base64js.fromByteArray(dataBuffer2));
    //console.log(base64js.fromByteArray(dataBuffer2));
}



/*
 * Set the colors on the stations to the _colors stored on the server
 * typially used on startup to retrieve the last stored state of the system
 */
function syncColorsFromServer() {
    for (var i = 0; i < MAX_STATION_COUNT; i++) {
        setMultipleColors(i, 0, _colors[i]);
    }
}



/*
 * sets entire strip colors at once
 * typically used for loading last saved state
 * or used for more efficient devliery of complete color changes
 */
function setStrip(stationId, colorArray) {

}



/*
 * Force clients to check for firmware updates
 */
function checkForUpdate(stationId) {
    io.sockets.to(stationId).emit('checkForUpdate', "");
}
setInterval(checkForUpdate, 600000);



/*
 *
 */
function requestStationInfo(socketId) {
    io.sockets.to(socketId).emit('getInfo', "");
}



function requestStationInfoListener(socket) {
    socket.on('requestStationInfo', function () {
        console.log('requesting info from all stations');
        io.sockets.emit('getInfo', "");
    });
}



/*
 * Helper method for HSV color model
 */
function HSVtoRGB(h, s, v) {
    var r, g, b, i, f, p, q, t;
    if (arguments.length === 1) {
        s = h.s, v = h.v, h = h.h;
    }
    i = Math.floor(h * 6);
    f = h * 6 - i;
    p = v * (1 - s);
    q = v * (1 - f * s);
    t = v * (1 - (1 - f) * s);
    switch (i % 6) {
        case 0:
            r = v, g = t, b = p;
            break;
        case 1:
            r = q, g = v, b = p;
            break;
        case 2:
            r = p, g = v, b = t;
            break;
        case 3:
            r = p, g = q, b = v;
            break;
        case 4:
            r = t, g = p, b = v;
            break;
        case 5:
            r = v, g = p, b = q;
            break;
    }
    return {
        r: Math.round(r * 255),
        g: Math.round(g * 255),
        b: Math.round(b * 255)
    };
}





///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/*
   Test Area
*/
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////


/*
 * Rainbow test code below here
 */

var hue = 120;
var hueBase = 360;
var colorString = '';

var fiveColors = new Array(5).fill(new CRGB(0, 0, 0));

var doStuff1 = function () {
    hue = (hue + 6) % hueBase;
    var t_hue = hue;
    for (var i = 0; i < MAX_STATION_COUNT; i++) {
        t_hue = (hue + 1) % hueBase;
        fiveColors[0] = HSVtoRGB(t_hue / (hueBase), 1.0, 1.0);
        t_hue = (hue + 2) % hueBase;
        fiveColors[1] = HSVtoRGB(t_hue / (hueBase), 1.0, 1.0);
        t_hue = (hue + 3) % hueBase;
        fiveColors[2] = HSVtoRGB(t_hue / (hueBase), 1.0, 1.0);
        t_hue = (hue + 4) % hueBase;
        fiveColors[3] = HSVtoRGB(t_hue / (hueBase), 1.0, 1.0);
        t_hue = (hue + 5) % hueBase;
        fiveColors[4] = HSVtoRGB(t_hue / (hueBase), 1.0, 1.0);

        setFiveColors(i, fiveColors);
    }

    fiveColors[0] = HSVtoRGB(0.0, 1.0, 1.0);
    fiveColors[1] = HSVtoRGB(0.0, 1.0, 1.0);
    fiveColors[2] = HSVtoRGB(0.0, 1.0, 1.0);
    fiveColors[3] = HSVtoRGB(0.0, 1.0, 1.0);
    fiveColors[4] = HSVtoRGB(0.0, 1.0, 1.0);
    setFiveColors(24932, fiveColors);

    console.log(fiveColors[0]);



};
//setInterval(doStuff1,5000);

var doStuff2 = function () {
    hue = (hue + 1) % hueBase;
    var hue2 = (Math.floor(hue / 6) * 6) % hueBase;
    fiveColors[0] = HSVtoRGB(hue2 / (hueBase), 1.0, 1.0);
    fiveColors[1] = HSVtoRGB(hue2 / (hueBase), 1.0, 1.0);
    fiveColors[2] = HSVtoRGB(hue2 / (hueBase), 1.0, 1.0);
    fiveColors[3] = HSVtoRGB(hue2 / (hueBase), 1.0, 1.0);
    fiveColors[4] = HSVtoRGB(hue2 / (hueBase), 1.0, 1.0);
    setFiveColors('allStations', fiveColors);
    console.log(fiveColors[0]); //fillSolid('allStations',0,LED_CLUSTER_COUNT,HSVtoRGB(hue/(hueBase),1.0,1.0));
}
//setInterval(doStuff2,10000/60);




var doStuff3 = function () {
    hue = (hue + 1) % hueBase;
    var hue2 = (Math.floor(hue / 6) * 6) % hueBase;
    fiveColors[0] = HSVtoRGB(hue2 / (hueBase), 1.0, 1.0);
    fiveColors[1] = HSVtoRGB(hue2 / (hueBase), 1.0, 1.0);
    fiveColors[2] = HSVtoRGB(hue2 / (hueBase), 1.0, 1.0);
    fiveColors[3] = HSVtoRGB(hue2 / (hueBase), 1.0, 1.0);
    fiveColors[4] = HSVtoRGB(hue2 / (hueBase), 1.0, 1.0);
    setFiveColors('stations', fiveColors);

    console.log(fiveColors[0]); //fillSolid('allStations',0,LED_CLUSTER_COUNT,HSVtoRGB(hue/(hueBase),1.0,1.0));
    udpSendColors();
}


var doStuff4 = function () {
    fiveColors = new Array(5).fill(new CRGB(0, 0, 0));
    hue = (hue + 10) % hueBase;
    console.log(hue);
    var t_hue = hue;
    t_hue = (hue + 1) % hueBase;
    fiveColors[0] = HSVtoRGB(t_hue / (hueBase), 1.0, 1.0);
    t_hue = (hue + 20) % hueBase;
    fiveColors[1] = HSVtoRGB(t_hue / (hueBase), 1.0, 1.0);
    t_hue = (hue + 30) % hueBase;
    fiveColors[2] = HSVtoRGB(t_hue / (hueBase), 1.0, 1.0);
    t_hue = (hue + 40) % hueBase;
    fiveColors[3] = HSVtoRGB(t_hue / (hueBase), 1.0, 1.0);
    t_hue = (hue + 50) % hueBase;
    fiveColors[4] = HSVtoRGB(t_hue / (hueBase), 1.0, 1.0);

    var dataBuffer = new Uint8Array([
        fiveColors[0].r, fiveColors[0].g, fiveColors[0].b,
        fiveColors[1].r, fiveColors[1].g, fiveColors[1].b,
        fiveColors[2].r, fiveColors[2].g, fiveColors[2].b,
        fiveColors[3].r, fiveColors[3].g, fiveColors[3].b,
        fiveColors[4].r, fiveColors[4].g, fiveColors[4].b
    ]);
    var data64 = base64js.fromByteArray(dataBuffer);
    io.sockets.emit('setFives', data64);
}
//setInterval(doStuff2,100000/60);
//setInterval(doStuff4,1000/30);