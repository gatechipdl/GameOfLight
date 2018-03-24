var paint_cap_delta = 500;
var paint_animation_interval = 50;

var paint_rom_functions = [
	{
		name : 'clear all',
		function : 'paintClearAll()'
	},
	{
		name : 'random all',
		function : 'paintRandomAll()'
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

function paintAnimation() {
	var d = new Date();
	var time = d.getTime();
	var timeCheck = time;
	for (var i=0; i<LO_config.rows; i++) {
		for (var j=0; j<LO_config.cols; j++) {
			var change_v = false;
			if (station_triggers[i][j]['top'].getTrigger(time, paint_cap_delta)) {
				change_v = true;
			}
			for (var k=0; k<LO_config.layers; k++) {
				if (change_v) {
					var v = (layer_color[i][j][k].v + 0.015)%1;
					setLayerColorHSV(i, j, k, undefined, undefined, v);
				}
				if (station_triggers[i][j]['L'+k].getTrigger(time, paint_cap_delta)) {
					var h = (layer_color[i][j][k].h + 0.005)%1;
					setLayerColorHSV(i, j, k, h, undefined, undefined);
				}
				if (station_triggers[i][j]['R'+k].getTrigger(time, paint_cap_delta)) {
					var s = (layer_color[i][j][k].s + 0.01)%1;
					setLayerColorHSV(i, j, k, undefined, s, undefined);
				}
			}
		}
	}
}

function paintClearAll() {
	for (var i=0; i<LO_config.rows; i++) {
		for (var j=0; j<LO_config.cols; j++) {
			for (var k=0; k<LO_config.layers; k++) {
				setLayerColorHSV(i, j, k, 0.0, 1.0, 0.0); //starts off completely dark with full saturation at about the hue blue
			}
		}
	}
}

function paintRandomAll() {
	for (var i=0; i<LO_config.rows; i++) {
		for (var j=0; j<LO_config.cols; j++) {
			for (var k=0; k<LO_config.layers; k++) {
				setLayerColorHSV(i, j, k, Math.random(), 0.4+0.6*Math.random(), 1.0); //starts off completely dark with full saturation at about the hue blue
			}
		}
	}
}