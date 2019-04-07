var water_cap_delta = 40;
var water_animation_interval = 100;

rom_list.push(
	{
		name : "water",
		onclick : "initWater()"
	}
);

var water_rom_functions = [
	{
		name : 'clear all',
		id : 'water_clear_all',
		function : 'waterClearAll()',
		toggle : false
	},
];

var water_location = [];
var water_distribution = [];
var water_speed = 0.25;
var water_speed_blocked = 0.01;
var water_spawn_threshold = 0.2;
var water_start_val = 2.5;

function initWater() {

	clearRomButtons();
	initLayerColor();

	for (i in water_rom_functions) {
		createRomFunctionButton(water_rom_functions[i]);
	}

	for (var i=0; i<LO_config.cols; i++) {
        water_location.push([]);
        water_distribution.push([]);
		for (var j=0; j<LO_config.rows; j++) {
            water_location[i].push(0);
            water_distribution[i].push([]);
			for (var k=0; k<LO_config.layers; k++) {
                water_distribution[i][j].push(0);
				setLayerColorHSV(j, i, k, 0.5, 0.5, 0.1);
			}
		}
	}

	clearInterval(animation);
	animation = setInterval(waterAnimation, water_animation_interval);
}


var blue_min = 0.1;

function waterAnimation() {
    var d = new Date();
    var time = d.getTime();
    
    if (Math.random() < water_spawn_threshold) {
        var random_col = parseInt(Math.random()*LO_config.cols);
        water_location[random_col][0] = water_location[random_col][0] + water_start_val;
    }
    for (var i=0; i<LO_config.cols; i++) {
		for (var j=0; j<LO_config.rows; j++) {
            if ((mouseInLayer.col == i && mouseInLayer.row == j && mouseInLayer.side === 'top') || station_triggers[j][i]['top'].getTrigger("click", time, water_cap_delta)) {
                var water_movement = water_location[i][j] * water_speed_blocked;
                water_location[i][j] = water_location[i][j] - water_movement;
                water_location[i][j] = water_location[i][j] < 0 ? 0 : water_location[i][j];
                if (j < LO_config.rows-1) {
                    water_location[i][j+1] = water_location[i][j+1] + water_movement/3;
                }
                if (i == 0) {
                    water_location[i+1][j] = water_location[i+1][j] + water_movement/3*2;
                } else if (i == LO_config.cols-1) {
                    water_location[i-1][j] = water_location[i-1][j] + water_movement/3*2;
                } else {
                    water_location[i+1][j] = water_location[i+1][j] + water_movement/3;
                    water_location[i-1][j] = water_location[i-1][j] + water_movement/3;
                }
            } else {
                var water_movement = water_location[i][j] * water_speed;
                water_location[i][j] = water_location[i][j] - water_movement;
                water_location[i][j] = water_location[i][j] < 0 ? 0 : water_location[i][j];
                if (j < LO_config.rows-1) {
                    water_location[i][j+1] = water_location[i][j+1] + water_movement;
                }
            }
            var distribution_counter = 0;
            for (var k=0; k<LO_config.layers; k++) {
                water_distribution[i][j][k] = 0.75 + Math.random();
                distribution_counter = distribution_counter + water_distribution[i][j][k];
            }

            for (var k=0; k<LO_config.layers; k++) {
                water_distribution[i][j][k] = water_distribution[i][j][k] / distribution_counter;
                var val = blue_min + water_distribution[i][j][k]*water_location[i][j];
                val = val > 1.0 ? 1.0 : val;
                setLayerColorHSV(j, i, k, 0.6, 0.9, val);
            }
		}
    }

    // for (var i=0; i<LO_config.cols; i++) {
	// 	for (var j=0; j<LO_config.rows; j++) {
    //         station_update[i][j] = true;
    //     }
    // }
	updateAllStationsColor();
}