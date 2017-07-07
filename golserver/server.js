'use strict';

const express = require('express');
const app = express();
const server = require('http').createServer(app);
const io = require('socket.io')(server);
const color = require("rgb");
const base64js = require('base64-js');
const path = require('path');
const fs = require('fs');
const md5 = require('md5-file');

var baseVersion = 1000;

// host everything in the public folder
app.use(express.static(__dirname + '/public')); 

//check github.com/esp8266/Arduino/issues/2228 for example
app.get('/update/base',function(req,res){
    //check version somehow
    //console.dir(req.headers);
    if(parseInt(req.headers['x-esp8266-version'])<baseVersion){
        var full_path = path.join(__dirname,'/bin/base.bin');
        fs.readFile(full_path,"binary",function(err,file){
            if(err){
                res.writeHeader(500, {"Content-Type": "text/plain"});
                res.write(err + "\n");
                res.end();
            }
            else{
                res.writeHeader(200,
                   {"Content-Type": "application/octect-stream",
                   "Content-Disposition": "attachment;filename="+path.basename(full_path),
                   "Content-Length": ""+fs.statSync(full_path)["size"],
                   "x-MD5": md5.sync(full_path)});
                res.write(file, "binary");
                res.end();
            }
        });
    }
    else{
        res.writeHeader(304, {"Content-Type": "text/plain"});
        res.write("304 Not Modified\n");
        res.end();
    }
    
});


var port = 80;
server.listen(port);

io.on('connection',function(socket){
    console.log("client "+socket['id']+" connected");
    socket.on('subscribe',function(roomName){
        socket.join(roomName);
        console.log("client "+socket['id']+" joined room "+roomName);
        CheckForUpdate(roomName);
    });
});

const STATION_COUNT = 36;
const LED_CLUSTER_COUNT = 45; // actual LED count is 45*3 = 135

//the locally stored color array for each station
var colors = new Array(STATION_COUNT).fill(new Array(LED_CLUSTER_COUNT).fill(new CRGB(0,0,0)));


/*
 * prototype function for CRGB data to mimic the FastLED library
 */
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

/*
 * Turn off LEDs on a specific station
 */
function Clear(stationId){
    io.sockets.to(stationId).emit('clear','');
}

/*
 * Turn off LEDs on all stations
 */
function ClearAll(){
    io.sockets.to('stations').emit('clear','');
}

/*
 * mimics FastLED FillSolid method
 */
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

/*
 * Set a single LED color on a specific station
 */
function SetColor(stationId,startIndex,ledColor){
    //update server's copy of the LED custer state
    colors[stationId][startIndex].r = ledColor.r;
    colors[stationId][startIndex].g = ledColor.g;
    colors[stationId][startIndex].b = ledColor.b;
    
    var dataBuffer = new Uint8Array([startIndex,ledColor.r,ledColor.g,ledColor.b]);
    io.sockets.to(stationId).emit('setColor',dataBuffer);
}

/*
 * Send a set of different colors to a subset of a specific station
 * Could be the whole station
 * the number of leds is computed by the lenth of the colorArray
 * colorArray is an array of CRGB
 */
function SetColors(stationId,startIndex,colorArray){
    //update server's copy of the LED custer state
    colors[stationId][ledIndex].r = ledColor.r;
    colors[stationId][ledIndex].g = ledColor.g;
    colors[stationId][ledIndex].b = ledColor.b;
    
    var dataBuffer = new Uint8Array([ledIndex,numToFill,ledColor.r,ledColor.g,ledColor.b]);
    io.sockets.to(stationId).emit('setColors',dataBuffer);
}

/*
 * GOL Station 5 segment code
 */
function SetFiveColors(stationId,fiveColorArray){
    //update server's copy of the LED custer state
    for(var i=0;i<5;i++){
        for(var j=0;j<LED_CLUSTER_COUNT/5;j++){
            colors[stationId][i*9+j].r = fiveColorArray[i].r;
            colors[stationId][i*9+j].g = fiveColorArray[i].g;
            colors[stationId][i*9+j].b = fiveColorArray[i].b;
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
        fiveColorArray[0].r,fiveColorArray[0].g,fiveColorArray[0].b,
        fiveColorArray[1].r,fiveColorArray[1].g,fiveColorArray[1].b,
        fiveColorArray[2].r,fiveColorArray[2].g,fiveColorArray[2].b,
        fiveColorArray[3].r,fiveColorArray[3].g,fiveColorArray[3].b,
        fiveColorArray[4].r,fiveColorArray[4].g,fiveColorArray[4].b
    ]);
    
    io.sockets.to(stationId).emit('setFives',base64js.fromByteArray(dataBuffer2));
    //console.log(base64js.fromByteArray(dataBuffer2));
}

/*
 * Set the colors on the stations to the colors stored on the server
 * typially used on startup to retrieve the last stored state of the system
 */
function SyncColorsFromServer(){
    for(var i=0;i<STATION_COUNT;i++){
        SetColors(i,0,colors[i]);
    }
}

/*
 * sets entire strip colors at once
 * typically used for loading last saved state
 * or used for more efficient devliery of complete color changes
 */
function SetStrip(stationId,colorArray){
    
}

/*
 * Force clients to check for firmware updates
 */
function CheckForUpdate(stationId){
    io.sockets.to(stationId).emit('checkForUpdate',"");
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









/*
 * Rainbow test code below here
 */

var hue = 120;
var hueBase = 360;
var colorString = '';

var fiveColors = new Array(5).fill(new CRGB(0,0,0));

var doStuff = function(){
    hue = (hue+6)%hueBase;
    var t_hue = hue;
    for(var i=0;i<STATION_COUNT;i++){
        t_hue = (hue+1)%hueBase;
        fiveColors[0] = HSVtoRGB(t_hue/(hueBase),1.0,1.0);
        t_hue = (hue+2)%hueBase;
        fiveColors[1] = HSVtoRGB(t_hue/(hueBase),1.0,1.0);
        t_hue = (hue+3)%hueBase;
        fiveColors[2] = HSVtoRGB(t_hue/(hueBase),1.0,1.0);
        t_hue = (hue+4)%hueBase;
        fiveColors[3] = HSVtoRGB(t_hue/(hueBase),1.0,1.0);
        t_hue = (hue+5)%hueBase;
        fiveColors[4] = HSVtoRGB(t_hue/(hueBase),1.0,1.0);
        
        SetFiveColors(i,fiveColors);
    }
    
    //console.log(fiveColors[0]);
    
    
    
};
//setInterval(doStuff,100);