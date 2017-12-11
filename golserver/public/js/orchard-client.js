//UMD format can be used both in the browser and in Node.js
//https://www.jvandemo.com/a-10-minute-primer-to-javascript-modules-module-formats-module-loaders-and-module-bundlers/
//https://www.davidbcalhoun.com/2014/what-is-amd-commonjs-and-umd/
(function (root, factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD. Register as an anonymous module.
        define(['orchard'], factory);
    } else if (typeof module !== 'undefined' && typeof exports === 'object') {
        // Node. Does not work with strict CommonJS, but
        // only CommonJS-like environments that support module.exports,
        // like Node.
        module.exports = factory(require('orchard'));
    } else {
        // Browser globals (root is window)
        root.returnExports = factory(root.orchard);
    }
}(this, function (orchard) {
    var _privateMethodA = function () {
        // do something
        console.log("using _privateMethodA");
    };

    var publicMethodA = function () {
        // code
        console.log("using publicMethodA");
        _privateMethodA();
    };

    var publicMethodB = function () {
        // code
        console.log("using publicMethodB");
    };

    var _socket;
    var _hasSocket = false;

    var setSocketIO = function (socket) {
        _socket = socket;
        _hasSocket = true;
    }

    var hasSocket = function () {
        console.log("the orchard library does " + (_hasSocket ? "" : "not") + " have a socket object");
        return _hasSocket;
    }

    //return the publicly accessible stuffs
    return {
        publicMethodA: publicMethodA,
        publicMethodB: publicMethodB,
        setSocketIO: setSocketIO,
        hasSocket: hasSocket
    };
}));
