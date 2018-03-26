var address_map = [
    ['0', '1', '2', '3', '4'],
    ['5', '6', '7', '8', '9'],
    ['10', '11', '12', '13', '14'],
    ['15', '16', '17', '18', '19'],
    ['20', '21', '22', '23', '24']
];

var socket = io.connect('/');

socket.on('connect', function() {
    socket.emit('subscribe', 'browsers'); //to receive CapSenseEvent, CapSenseTouch, CapSenseUnTouch
});

function setStationColor(row, col) {
    if (LO_config.layers == 5) {
        var tData = {};
        var station_id = address_map[row][col];
        tData['station_id'] = station_id;
        console.log(layer_color[row][col]);
        tData['colors'] = [
            [layer_color[row][col][0].r,layer_color[row][col][0].g,layer_color[row][col][0].b],
            [layer_color[row][col][1].r,layer_color[row][col][1].g,layer_color[row][col][1].b],
            [layer_color[row][col][2].r,layer_color[row][col][2].g,layer_color[row][col][2].b],
            [layer_color[row][col][3].r,layer_color[row][col][3].g,layer_color[row][col][3].b],
            [layer_color[row][col][4].r,layer_color[row][col][4].g,layer_color[row][col][4].b]
            ];
        socket.emit('SetFiveColors', tData);
    }
}
