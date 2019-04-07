var paintSynth_cap_delta = 1000;
var paintSynth_animation_interval = 250;

rom_list.push(
	{
		name : "paintSynth",
		onclick : "initpaintSynth()"
	}
);

var paintSynth_rom_functions = [
	{
		name : 'clear all',
		id : 'paintSynth_clear_all',
		function : 'paintSynthClearAll()',
		toggle : false
	},
	{
		name : 'random all',
		id : 'paintSynth_random_all',
		function : 'paintSynthRandomAll()',
		toggle : false
	},
	{
		name : 'increase brightness all',
		id : 'paintSynth_increase_all',
		function : 'paintSynthIncreaseValueAll()',
		toggle : false
	},
	{
		name : 'decrease brightness all',
		id : 'paintSynth_decrease_all',
		function : 'paintSynthDecreaseValueAll()',
		toggle : false
	}
];

function initpaintSynth() {

	clearRomButtons();
	initLayerColor();

	for (i in paintSynth_rom_functions) {
		createRomFunctionButton(paintSynth_rom_functions[i]);
	}

	for (var i=0; i<LO_config.rows; i++) {
		for (var j=0; j<LO_config.cols; j++) {
			for (var k=0; k<LO_config.layers; k++) {
				setLayerColorHSV(i, j, k, 0.5, 1.0, 0.0); //starts off completely dark with full saturation at about the hue blue
			}
		}
	}

	clearInterval(animation);
	animation = setInterval(paintSynthAnimation, paintSynth_animation_interval);
}

var v_incr = 0.05;
var h_incr = 0.01;
var s_incr = 0.05;
function paintSynthAnimation() {
	var d = new Date();
	var time = d.getTime();
	for (var i=0; i<LO_config.rows; i++) {
		for (var j=0; j<LO_config.cols; j++) {
			var change_v = false;
			if (station_triggers[i][j]['top'].getTrigger("click", time, paintSynth_cap_delta)) {
				change_v = true;
				station_update[i][j] = true;

			}
            if (station_triggers[i][j]['top'].getTrigger("click", time, paintSynth_animation_interval)) {
                Synth.play(i % 4, 'C', j+2, 3);
                Synth.play(i % 4, 'E', j+2, 3);
				Synth.play(i % 4, 'G', j+2, 3);
                //Synth.play(1, 'C', j+2, 3);
                //Synth.play(1, 'E', j+2, 3);
                //Synth.play(1, 'G', j+2, 3);
                }
			for (var k=0; k<LO_config.layers; k++) {
				if (change_v) {
					var v = (layer_color[i][j][k].v + v_incr)%1;
					setLayerColorHSV(i, j, k, undefined, undefined, v);
				}
				if (station_triggers[i][j]['L'+k].getTrigger("click", time, paintSynth_cap_delta)) {
					var h = (layer_color[i][j][k].h + h_incr)%1;
					setLayerColorHSV(i, j, k, h, undefined, undefined);
					station_update[i][j] = true;
				}
				if (station_triggers[i][j]['R'+k].getTrigger("click", time, paintSynth_cap_delta)) {
					var s = (layer_color[i][j][k].s + s_incr)%1;
					setLayerColorHSV(i, j, k, undefined, s, undefined);
					station_update[i][j] = true;
				}
				if (station_triggers[i][j]['L'+k].getTrigger("click", time, paintSynth_animation_interval)) {
                    var note = String.fromCharCode(65 + k);
					Synth.play(i % 4, note, j+2, 3);
                    //Synth.play(1, note, j+2, 3);
				}
				if (station_triggers[i][j]['R'+k].getTrigger("click", time, paintSynth_animation_interval)) {
                    var note = String.fromCharCode(67 + k);
					Synth.play(i % 4, note, j+2, 3);
					//Synth.play(1, note, j+2, 3);
				}                

			}
		}
	}
	updateAllStationsColor();
}

function paintSynthClearAll() {
	for (var i=0; i<LO_config.rows; i++) {
		for (var j=0; j<LO_config.cols; j++) {
			for (var k=0; k<LO_config.layers; k++) {
				setLayerColorHSV(i, j, k, 0.5, 1.0, 0.0); //starts off completely dark with full saturation at about the hue blue
			}
		}
	}
	updateAllStationsFlag();
}

function paintSynthRandomAll() {
	for (var i=0; i<LO_config.rows; i++) {
		for (var j=0; j<LO_config.cols; j++) {
			for (var k=0; k<LO_config.layers; k++) {
				setLayerColorHSV(i, j, k, Math.random(), 0.4+0.6*Math.random(), undefined); //starts off completely dark with full saturation at about the hue blue
			}
		}
	}
	updateAllStationsFlag();
}

function paintSynthIncreaseValueAll() {
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

function paintSynthDecreaseValueAll() {
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