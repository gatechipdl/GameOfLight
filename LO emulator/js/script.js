var animation;

//Object with installation configuration, a.k.a rows, columns and layers
var LO_config = {
	rows : 5,
	cols : 5,
	layers : 5
}

//ROMs
var rom_list = [
	{
		name : "paint",
		onclick : "initPaint()"
	}
];

// cap events coming into the system
var station_triggers = [];
function StationCapInput() {
	var d = new Date();
	this.log = [d.getTime()];
};
StationCapInput.prototype.logState = function() {
	var d = new Date();
	this.log.push(d.getTime());
};
StationCapInput.prototype.getLatest = function() {
	if (this.log.length==0) {
		return undefined;
	}
	return this.log[this.log.length-1];
};
StationCapInput.prototype.getDelta = function() {
	if (this.log.length<2) {
		return undefined;
	}
	var delta = this.log[this.log.length-1] - this.log[this.log.length-2];
	return delta;
};
StationCapInput.prototype.getLength = function() {
	return this.log.length;
};
StationCapInput.prototype.getTrigger = function(curr_time, time_delta) {
	if ((curr_time - this.getLatest()) < time_delta) {
		return true;
	}
	return false;
};

//layer color variable
var layer_color = [];


/////////////////////////////
//                         //
//	EMULATOR UI FUNCTIONS  //
//                         //
/////////////////////////////

//init function when HTML body loads
function init() {
	generateStationTriggers();
	createVisUI();
	initLayerColor();
	loadRoms();
}

function loadRoms() {
	for (i in rom_list) {
		createRomButton(rom_list[i]);
	}
	$('.rom_toggle').on('click', function() {
		$('.rom_toggle.active').toggleClass('active');
		$(this).toggleClass('active');
	});
}

//DOM FUNCTION
//creates DOM objects for LO set up based on LO_config parameters
function createVisUI() {
	for(var i=0; i<LO_config.rows; i++) {
		for(var j=0; j<LO_config.cols; j++) {
			var div_id = 'stationui_'+i+'-'+j;
			$('#vis_ui').append('<div id="'+div_id+'" class="station_ui"><span class="station_name">station '+i+'-'+j+'<span></div>');
			$('#'+div_id).css('width', 100/LO_config.cols+'%');
			$('#'+div_id).append('<div class="top"></div>');
			$('#'+div_id+' .top').on('click', function() {
				var info = $(this).parent().attr('id').split('_');
				var rowcol = info[1].split('-');
				station_triggers[parseInt(rowcol[0])][parseInt(rowcol[1])]['top'].logState();
			});
			for (var k=LO_config.layers-1; k>=0; k--) {
				$('#'+div_id).append('<div class="layer_'+k+' layer"></div>')
				$('#'+div_id+' .layer_'+k).append('<div class="left">L'+k+'</div>');
				$('#'+div_id+' .layer_'+k).append('<div class="right">R'+k+'</div>');
				$('#'+div_id+' .layer_'+k+' .left').on('click', function() {
					var info = $(this).parent().parent().attr('id').split('_');
					var rowcol = info[1].split('-');
					var layer_info = $(this).parent().attr('class');
					var layer_number = layer_info.split(' ')[0].split('_')[1];
					station_triggers[parseInt(rowcol[0])][parseInt(rowcol[1])]['L'+layer_number].logState();
				});
				$('#'+div_id+' .layer_'+k+' .right').on('click', function() {
					var info = $(this).parent().parent().attr('id').split('_');
					var rowcol = info[1].split('-');
					var layer_info = $(this).parent().attr('class');
					var layer_number = layer_info.split(' ')[0].split('_')[1];
					station_triggers[parseInt(rowcol[0])][parseInt(rowcol[1])]['R'+layer_number].logState();
				});
			}
		}
	}
}

//DOM FUNCTION
//creates ROM button
function createRomButton(romobj) {
	var idname = romobj.name+'_rom';
	$('#menu_toggle_rom').append('<div id="'+idname+'" class="rom_toggle button" onclick="'+romobj.onclick+'">'+romobj.name+'</div>');
}

function setLayerColorRGB(row, col, layer, r, g, b) {
	if (r != undefined) { 
		layer_color[row][col][layer].r = r; 
	}
	if (g != undefined) { 
		layer_color[row][col][layer].g = g; 
	}
	if (b != undefined) { 
		layer_color[row][col][layer].b = b; 
	}
	
	var hsv = RGBtoHSV(layer_color[row][col][layer]);
	layer_color[row][col][layer].h = hsv.h;
	layer_color[row][col][layer].s = hsv.s;
	layer_color[row][col][layer].v = hsv.v;

	var div_id = 'stationui_'+row+'-'+col;
	$('#'+div_id+' .layer_'+layer).css('background', 'rgba('+layer_color[row][col][layer].r+','+layer_color[row][col][layer].g+','+layer_color[row][col][layer].b+',1.0)');
}

function setLayerColorHSV(row, col, layer, h, s, v) {
	if (h != undefined) { 
		layer_color[row][col][layer].h = h; 
	}
	if (s != undefined) { 
		layer_color[row][col][layer].s = s; 
	}
	if (v != undefined) { 
		layer_color[row][col][layer].v = v; 
	}
	var rgb = HSVtoRGB(layer_color[row][col][layer]);
	layer_color[row][col][layer].r = rgb.r;
	layer_color[row][col][layer].g = rgb.g;
	layer_color[row][col][layer].b = rgb.b;
	var div_id = 'stationui_'+row+'-'+col;
	$('#'+div_id+' .layer_'+layer).css('background', 'rgba('+layer_color[row][col][layer].r+','+layer_color[row][col][layer].g+','+layer_color[row][col][layer].b+',1.0)');
}

//creates cap event boolean variables
//variable structure is as follows:
// cap_id:
///// "top" --> top cap button
///// "L"+layer_number --> layer left cap button
///// "R"+layer_number --> layer right cap button
// station_triggers[row_number][col_number][cap_id].log --> an array of timestamps in millis when the cap was triggered.
// station_triggers[row_number][col_number][cap_id].logState() --> pushes current time in millis into the log.
// station_triggers[row_number][col_number][cap_id].getLatest() --> get timestamp of latest trigger.
// station_triggers[row_number][col_number][cap_id].getDelta() --> get timestamp of latest trigger minus timestamp of last trigger.
// station_triggers[row_number][col_number][cap_id].getLength() --> get number of triggers since the start.
// station_triggers[row_number][col_number][cap_id].getTrigger(curr_time, time_delta) --> compares latest trigger timestamp with current time against a time interval and checks if it is within the interval. Returns TRUE if inside and FALSE if not.
function generateStationTriggers() {
	for (var i=0; i<LO_config.rows; i++) {
		station_triggers.push([]);
		for (var j=0; j<LO_config.cols; j++) {
			station_triggers[i].push({
				top : new StationCapInput()
			});
			for (var k=0; k<LO_config.layers; k++) {
				station_triggers[i][j]["L"+k] = new StationCapInput();
				station_triggers[i][j]["R"+k] = new StationCapInput();
			}
		}
	}
}

//set all layer colors to black
function initLayerColor() {
	for (var i=0; i<LO_config.rows; i++) {
		layer_color.push([]);
		for (var j=0; j<LO_config.cols; j++) {
			layer_color[i].push([]);
			for (var k=0; k<LO_config.layers; k++) {
				layer_color[i][j].push({r:0, g:0, b:0, h:0, s:0, v:0});
				setLayerColorRGB(i, j, k, 0, 0, 0);
			}
		}
	}
}

function clearRomButtons() {
	$('#menu_rom_options').empty();
}

function createRomFunctionButton(obj) {
	var button_html = '<div class="button" onclick="'+obj.function+'">'+obj.name+'</div>'
	$('#menu_rom_options').append(button_html);
}


// HSV values should be between or equals to 0 and 1
function HSVtoRGB(h, s, v) {
    var r, g, b, i, f, p, q, t;
    if (arguments.length === 1) {
        s = h.s, v = h.v, h = h.h;
    }
    i = Math.floor(h * 6);
    f = h * 6 - i;
    p = v * (1 - s);
    q = v * (1 - f * s);
    t = v * (1 - (1 - f) * s);
    switch (i % 6) {
        case 0: r = v, g = t, b = p; break;
        case 1: r = q, g = v, b = p; break;
        case 2: r = p, g = v, b = t; break;
        case 3: r = p, g = q, b = v; break;
        case 4: r = t, g = p, b = v; break;
        case 5: r = v, g = p, b = q; break;
    }
    return {
        r: Math.round(r * 255),
        g: Math.round(g * 255),
        b: Math.round(b * 255)
    };
}

function RGBtoHSV(r, g, b) {
    if (arguments.length === 1) {
        g = r.g, b = r.b, r = r.r;
    }
    var max = Math.max(r, g, b), min = Math.min(r, g, b),
        d = max - min,
        h,
        s = (max === 0 ? 0 : d / max),
        v = max / 255;

    switch (max) {
        case min: h = 0; break;
        case r: h = (g - b) + d * (g < b ? 6: 0); h /= 6 * d; break;
        case g: h = (b - r) + d * 2; h /= 6 * d; break;
        case b: h = (r - g) + d * 4; h /= 6 * d; break;
    }

    return {
        h: h,
        s: s,
        v: v
    };
}