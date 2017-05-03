//this script is used to list the serial ports
//usage:
//>   node listports.js

var serialport = require('serialport');
var SerialPort = serialport.SerialPort;
var parsers = serialport.parsers;

//code to list available serial ports by name
// all the code here below is inside serialport.list
function ListSerialPorts(){   
    serialport.list(function (err, ports) {
        console.log("\n");
        console.log("+++++++++++ port info +++++++++++\n");
        console.log("\n");
        ports.forEach(function(port) {
            console.log("   "+port.comName+"   ,   "+port.pnpId+"   ,   "+port.manufacturer+"\n");
            console.log("\n");
        });
        console.log("+++++++++++ port done +++++++++++\n");
        console.log("\n");
   });
};
ListSerialPorts();