// create an empty modbus client 
var ModbusRTU = require("modbus-serial");
var client = new ModbusRTU();
 
// open connection to a serial port 
client.connectRTU("COM49", { baudrate: 9600 }, write);
 
function write(data) {
    client.setID(24);
 
    // write the values 0, 0xffff to registers starting at address 5 
    // on device number 1. 
    client.writeRegisters(100, data)
        .then(read);
}
 
function read() {
    // read the 2 registers starting at address 5 
    // on device number 1. 
    client.readHoldingRegisters(100, 1)
        .then(console.log);
}

var hue = 0;
setInterval(function() {
    console.log('hue: '+hue);
    hue = (hue+10)%256;
    write(hue);
    //client.writeRegisters(100, hue);
}, 1000);