'use strict';

const express = require('express');
const app = express();
const server = require('http').createServer(app);
const io = require('socket.io')(server);
const color = require("rgb");

// host everything in the public folder
app.use(express.static(__dirname + '/public')); 

var port = 80;
server.listen(port);

io.on('connection',function(socket){
    console.log("client "+socket+" connected");
    socket.on('subscribe',function(roomName){
        socket.join(roomName);
        console.log("client "+socket+" joined room "+roomName);
    });
});


const STATION_COUNT = 36;
const LED_CLUSTER_COUNT = 45; // actual LED count is 45*3 = 135


//prototype function for CRGB data to mimic the FastLED library
function CRGB(red, green, blue){
    this.r = red;
    this.g = green;
    this.b = blue;
    this.int = function(){
        return r>>16+g>>8+b>>0;
    }
    this.setRGB = function(red, green, blue){
        this.r = red;
        this.g = green;
        this.b = blue;
    }
    this.setHSV = function(hue, sat, val){
        var temp = HSVtoRGB(hue,sat,val);
        this.r = temp.r;
        this.g = temp.g;
        this.b = temp.b;
    }
}

//mimics FastLED FillSolid method
function FillSolid(stationId,startIndex,numToFill,ledColor){
    //update server's copy of the LED custer state
    for(var i=startIndex;i<startIndex+numToFill;i++){
        colors[stationId][i].r = ledColor.r;
        colors[stationId][i].g = ledColor.g;
        colors[stationId][i].b = ledColor.b;
    }
    var dataBuffer = new Uint8Array([startIndex,numToFill,ledColor.r,ledColor.g,ledColor.b]);
    io.sockets.to(stationId).emit('fillSolid',dataBuffer);
}

//Set a single LED color on a specific station
function SetColor(stationId,startIndex,ledColor){
    //update server's copy of the LED custer state
    colors[stationId][startIndex].r = ledColor.r;
    colors[stationId][startIndex].g = ledColor.g;
    colors[stationId][startIndex].b = ledColor.b;
    
    var dataBuffer = new Uint8Array([startIndex,ledColor.r,ledColor.g,ledColor.b]);
    io.sockets.to(stationId).emit('setColor',dataBuffer);
}

//Send a set of different colors to a subset of a specific station
//Could be the whole station
//the number of leds is computed by the lenth of the colorArray
//colorArray is an array of CRGB
function SetColors(stationId,startIndex,colorArray){
    //update server's copy of the LED custer state
    colors[stationId][ledIndex].r = ledColor.r;
    colors[stationId][ledIndex].g = ledColor.g;
    colors[stationId][ledIndex].b = ledColor.b;
    
    var dataBuffer = new Uint8Array([ledIndex,numToFill,ledColor.r,ledColor.g,ledColor.b]);
    io.sockets.to(stationId).emit('setColors',dataBuffer);
}

//Set the colors on the stations to the colors stored on the server
//typially used on startup to retrieve the last stored state of the system
function SyncColorsFromServer(){
    for(var i=0;i<STATION_COUNT;i++){
        SetColors(i,0,colors[i]);
    }
}

//Turn off LEDs on a specific station
function Clear(stationId){
    io.sockets.to(stationId).emit('clear','');
}

//Turn off LEDs on all stations
function ClearAll(){
    io.sockets.to('stations').emit('clear','');
}

function SetStrip(stationId,colorArray){
    
}


//Helper method for HSV color model
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
        case 0: r = v, g = t, b = p; break;
        case 1: r = q, g = v, b = p; break;
        case 2: r = p, g = v, b = t; break;
        case 3: r = p, g = q, b = v; break;
        case 4: r = t, g = p, b = v; break;
        case 5: r = v, g = p, b = q; break;
    }
    return {
        r: Math.round(r * 255),
        g: Math.round(g * 255),
        b: Math.round(b * 255)
    };
}

//the locally stored color array for each station
var colors = new Array(STATION_COUNT).fill(new Array(LED_CLUSTER_COUNT).fill(new CRGB(0,0,0)));
















var hue = 120;
var colorString = '';

var doStuff = function(){
    hue = (hue+1)%360;
    colors = HSVtoRGB(hue,100,100);
    console.log(colors);
    colorString = '';
    colorString+=colors[0][0].r+',';
    colorString+=colors[0][0].g+',';
    colorString+=colors[0][0].b+',';
    colorString+=colors[0][1].r+',';
    colorString+=colors[0][1].g+',';
    colorString+=colors[0][1].b+',';
    colorString+=colors[0][2].r+',';
    colorString+=colors[0][2].g+',';
    colorString+=colors[0][2].b+',';
    colorString+=colors[0][3].r+',';
    colorString+=colors[0][3].g+',';
    colorString+=colors[0][3].b+',';
    colorString+=colors[0][4].r+',';
    colorString+=colors[0][4].g+',';
    colorString+=colors[0][4].b+',';
    
    
    io.sockets.emit('colors',colorString);
    
};

//setInterval(doStuff,50);