'use strict';

const express = require('express');
const app = express();
const server = require('http').createServer(app);
const io = require('socket.io')(server);

app.use(express.static(__dirname + '/public')); 

server.listen(80);

io.on('connection',function(socket){
    console.log("client "+socket+" connected");
    socket.on('subscribe',function(roomName){
        socket.join(roomName);
        console.log("client "+socket+" joined room "+roomName);
    });
});

var colors = {
    'r':0,
    'g':0,
    'b':0
};
var hue = 120;
var colorString = '';

var doStuff = function(){
    hue = (hue+1)%360;
    colors = HSVtoRGB(hue,100,100);
    console.log(colors);
    colorString = '';
    colorString+=colors.r+',';
    colorString+=colors.g+',';
    colorString+=colors.b+',';
    colorString+=colors.r+',';
    colorString+=colors.g+',';
    colorString+=colors.b+',';
    colorString+=colors.r+',';
    colorString+=colors.g+',';
    colorString+=colors.b+',';
    colorString+=colors.r+',';
    colorString+=colors.g+',';
    colorString+=colors.b+',';
    colorString+=colors.r+',';
    colorString+=colors.g+',';
    colorString+=colors.b+',';
    
    
    io.sockets.emit('colors',colorString);
    
};

setInterval(doStuff,50);

function HSVtoRGB(h, s, v) {
    var r, g, b, i, f, p, q, t;
    h = h/360;
    s = s/100;
    v = v/100;
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