var address_map = [
    ['1', '2', '3', '4', '5'],
    ['6', '7', '8', '9', '10'],
    ['11', '12', '13', '14', '15'],
    ['16', '17', '18', '19', '20'],
    ['21', '22', '23', '24', '25']
];

var socket = io.connect('/');

socket.on('connect', function() {
    socket.emit('subscribe', 'browsers'); //to receive CapSenseEvent, CapSenseTouch, CapSenseUnTouch
});

function setStationColor(row, col) {
    if (LO_config.layers == 5) {
        var tData = {};
        var station_id = address_map[row][col];
        //tData['log'] = true;
        tData['station_id'] = station_id;
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

function CapSenseTouchListener(socket){
    socket.on('CapSenseTouch', function(data) {
        var row = -1, col = -1;
        for (i in address_map) {
            for (j in address_map[i]) {
                if (parseInt(data['station_id']) == parseInt(address_map[i][j])) {
                    row = parseInt(i);
                    col = parseInt(j);
                    break;
                }
            }
        }
        if (row != -1 && col != -1) {
            var div_id = 'stationui_'+row+'-'+col;
            var cap = parseInt(data['sensor_id']);
            console.log('cap event', row, col, cap);
            if (cap >= 0 && cap <= 4) {
                var layer_id = 'L'+cap;
                station_triggers[row][col][layer_id].logState('click');
            } else if (cap >= 5 && cap <= 9) {
                var layer_id = 'R'+(cap-5);
                station_triggers[row][col][layer_id].logState('click');
            } else if (cap == 11) {
                station_triggers[row][col]['top'].logState('click');
            }
        }
    });
}
CapSenseTouchListener(socket);
