var paint_cap_delta = 1000;
var paint_animation_interval = 250;

var paint_rom_functions = [
	{
		name : 'clear all',
		id : 'paint_clear_all',
		function : 'paintClearAll()',
		toggle : false
	},
	{
		name : 'rainbow',
		id : 'paint_rainbow',
		function : 'paintRainbow()',
		toggle : false
	}
];

function initRainbow() {

	clearRomButtons();
	initLayerColor();

	for (i in paint_rom_functions) {
		createRomFunctionButton(paint_rom_functions[i]);
	}

	for (var i=0; i<LO_config.rows; i++) {
		for (var j=0; j<LO_config.cols; j++) {
			for (var k=0; k<LO_config.layers; k++) {
				setLayerColorHSV(i, j, k, 0.5, 1.0, 1.0); //starts off completely dark with full saturation at about the hue blue
			}
		}
	}

	clearInterval(animation);
	animation = setInterval(paintAnimation, paint_animation_interval);
}

var v_incr = 0.05;
var h_incr = 0.01;
var s_incr = 0.05;
function paintAnimation() {
	var d = new Date();
	var time = d.getTime();
	for (var i=0; i<LO_config.rows; i++) {
		for (var j=0; j<LO_config.cols; j++) {
			var change_v = false;
			if (station_triggers[i][j]['top'].getTrigger("click", time, paint_cap_delta)) {
				change_v = true;
				station_update[i][j] = true;
			}
			for (var k=0; k<LO_config.layers; k++) {
				if (change_v) {
					var v = (layer_color[i][j][k].v + v_incr)%1;
					setLayerColorHSV(i, j, k, undefined, undefined, v);
				}
				if (station_triggers[i][j]['L'+k].getTrigger("click", time, paint_cap_delta)) {
					var h = (layer_color[i][j][k].h + h_incr)%1;
					setLayerColorHSV(i, j, k, h, undefined, undefined);
					station_update[i][j] = true;
				}
				if (station_triggers[i][j]['R'+k].getTrigger("click", time, paint_cap_delta)) {
					var s = (layer_color[i][j][k].s + s_incr)%1;
					setLayerColorHSV(i, j, k, undefined, s, undefined);
					station_update[i][j] = true;
				}
			}
		}
	}
	updateAllStationsColor();
}

function paintClearAll() {
	for (var i=0; i<LO_config.rows; i++) {
		for (var j=0; j<LO_config.cols; j++) {
			for (var k=0; k<LO_config.layers; k++) {
				setLayerColorHSV(i, j, k, 0.5, 1.0, 0.0); //starts off completely dark with full saturation at about the hue blue
			}
		}
	}
	updateAllStationsFlag();
}

function paintRainbow() {
	for (var i=0; i<LO_config.rows; i++) {
		for (var j=0; j<LO_config.cols; j++) {
			for (var k=0; k<LO_config.layers; k++) {
				setLayerColorHSV(i, j, k, 1-0.2*i-0.04*j, 1-0.1*k, 1.0); //starts off completely dark with full saturation at about the hue blue
			}
		}
	}
	updateAllStationsFlag();
}

