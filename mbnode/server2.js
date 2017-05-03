var SerialPort = require('serialport').SerialPort;
var modbus = require('modbus-rtu');

//create serail port with params. Refer to node-serialport for documentation 
var serialPort = new SerialPort("COM49", {
   baudrate: 9600
});
 
//create ModbusMaster instance and pass the serial port object 
var master = new modbus.Master(serialPort);
 
////Read from slave with address 1 four holding registers starting from 0. 
//master.readHoldingRegisters(1, 0, 4).then(function(data){
//    //promise will be fulfilled with parsed data 
//    console.log(data); //output will be [10, 100, 110, 50] (numbers just for example) 
//}, function(err){
//    //or will be rejected with error 
//})
 
//Write to first slave into second register value 150. 
//slave, register, value 
//master.writeSingleRegister(1, 2, 150).then(success, error);


function write(data){
    master.writeSingleRegister(24, 100, data);
}

var hue = 0;
setInterval(function() {
    console.log('hue: '+hue);
    hue = (hue+10)%256;
    //write(hue);
    master.writeSingleRegister(24, 100, hue);
}, 000);