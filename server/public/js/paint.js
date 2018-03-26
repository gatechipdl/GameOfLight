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
		name : 'random all',
		id : 'paint_random_all',
		function : 'paintRandomAll()',
		toggle : false
	},
	{
		name : 'increase brightness all',
		id : 'paint_increase_all',
		function : 'paintIncreaseValueAll()',
		toggle : false
	},
	{
		name : 'decrease brightness all',
		id : 'paint_decrease_all',
		function : 'paintDecreaseValueAll()',
		toggle : false
	}
];

function initPaint() {

	clearRomButtons();
	initLayerColor();

	for (i in paint_rom_functions) {
		createRomFunctionButton(paint_rom_functions[i]);
	}

	for (var i=0; i<LO_config.rows; i++) {
		for (var j=0; j<LO_config.cols; j++) {
			for (var k=0; k<LO_config.layers; k++) {
				setLayerColorHSV(i, j, k, 0.5, 1.0, 0.0); //starts off completely dark with full saturation at about the hue blue
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

function paintRandomAll() {
	for (var i=0; i<LO_config.rows; i++) {
		for (var j=0; j<LO_config.cols; j++) {
			for (var k=0; k<LO_config.layers; k++) {
				setLayerColorHSV(i, j, k, Math.random(), 0.4+0.6*Math.random(), undefined); //starts off completely dark with full saturation at about the hue blue
			}
		}
	}
	updateAllStationsFlag();
}

function paintIncreaseValueAll() {
	for (var i=0; i<LO_config.rows; i++) {
		for (var j=0; j<LO_config.cols; j++) {
			for (var k=0; k<LO_config.layers; k++) {
				var v = (layer_color[i][j][k].v + 0.1);
				v = v >= 1 ? 1 : v;
				setLayerColorHSV(i, j, k, undefined, undefined, v); //starts off completely dark with full saturation at about the hue blue
			}
		}
	}
	updateAllStationsFlag();
}

function paintDecreaseValueAll() {
	for (var i=0; i<LO_config.rows; i++) {
		for (var j=0; j<LO_config.cols; j++) {
			for (var k=0; k<LO_config.layers; k++) {
				var v = (layer_color[i][j][k].v - 0.1);
				v = v <= 0 ? 0 : v;
				setLayerColorHSV(i, j, k, undefined, undefined, v); //starts off completely dark with full saturation at about the hue blue
			}
		}
	}
	updateAllStationsFlag();
}