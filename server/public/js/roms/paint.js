var paint_cap_delta = 1000;
var paint_animation_interval = 50;//originally 250 for old wifi latency

rom_list.push(
	{
		name : "paint",
		onclick : "initPaint()"
	}
);

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

	for (let i=0; i<LO_config.rows; i++) {
		for (let j=0; j<LO_config.cols; j++) {
			for (let k=0; k<LO_config.layers; k++) {
				setLayerColorHSV(i, j, k, 0.5, 1.0, 0.5); //starts off half lit with full saturation at about the hue blue
			}
			station_update[i][j] == true
		}
	}

	clearInterval(animation);
	animation = setInterval(paintAnimation, paint_animation_interval);
}

var v_incr = 0.000001;//top cap value 'speed'?
var h_incr = 0.01;//hue 'speed'
var s_incr = 0.05;//saturation 'speed'
function paintAnimation() {
	let d = new Date();
	let time = d.getTime();
	for (let i=0; i<LO_config.rows; i++) {
		for (let j=0; j<LO_config.cols; j++) {
			let change_v = false;
			if (station_triggers[i][j]['top'].getTrigger("click", time, paint_cap_delta)) {
				change_v = true;
				station_update[i][j] = true;
			}
			if (change_v) { //should occur just once; don't iterate over layer count
				let v = (layer_color[i][j][k].v + v_incr)%1;
				//layer_color[i][j][k].v = v; //handled in setLayerColorHSV()
				setLayerColorHSV(i, j, k, undefined, undefined, v);
			}
			for (let k=0; k<LO_config.layers; k++) {
				if (station_triggers[i][j]['L'+k].getTrigger("click", time, paint_cap_delta)) {
					let h = (layer_color[i][j][k].h + h_incr)%1;
					//layer_color[i][j][k].h = h; //handled in setLayerColorHSV()
					setLayerColorHSV(i, j, k, h, undefined, undefined);
					station_update[i][j] = true;
				}
				if (station_triggers[i][j]['R'+k].getTrigger("click", time, paint_cap_delta)) {
					let s = (layer_color[i][j][k].s + s_incr)%1;
					//layer_color[i][j][k].s = s; //handled in setLayerColorHSV()
					setLayerColorHSV(i, j, k, undefined, s, undefined);
					station_update[i][j] = true;
				}
			}
		}
	}
	updateAllStationsColor();
}

function paintClearAll() {
	for (let i=0; i<LO_config.rows; i++) {
		for (let j=0; j<LO_config.cols; j++) {
			for (let k=0; k<LO_config.layers; k++) {
				setLayerColorHSV(i, j, k, 0.5, 1.0, 0.0); //starts off completely dark with full saturation at about the hue blue
			}
		}
	}
	updateAllStationsFlag();
}

function paintRandomAll() {
	for (let i=0; i<LO_config.rows; i++) {
		for (let j=0; j<LO_config.cols; j++) {
			for (let k=0; k<LO_config.layers; k++) {
				setLayerColorHSV(i, j, k, Math.random(), 0.4+0.6*Math.random(), undefined); //starts off completely dark with full saturation at about the hue blue
			}
		}
	}
	updateAllStationsFlag();
}

function paintIncreaseValueAll() {
	for (let i=0; i<LO_config.rows; i++) {
		for (let j=0; j<LO_config.cols; j++) {
			for (let k=0; k<LO_config.layers; k++) {
				let v = (layer_color[i][j][k].v + 0.1);
				v = v >= 1 ? 1 : v;
				setLayerColorHSV(i, j, k, undefined, undefined, v); //starts off completely dark with full saturation at about the hue blue
			}
		}
	}
	updateAllStationsFlag();
}

function paintDecreaseValueAll() {
	for (let i=0; i<LO_config.rows; i++) {
		for (let j=0; j<LO_config.cols; j++) {
			for (let k=0; k<LO_config.layers; k++) {
				let v = (layer_color[i][j][k].v - 0.1);
				v = v <= 0 ? 0 : v;
				setLayerColorHSV(i, j, k, undefined, undefined, v); //starts off completely dark with full saturation at about the hue blue
			}
		}
	}
	updateAllStationsFlag();
}