var rainbow2_cap_delta = 3000;
var rainbow2_animation_interval = 20;

rom_list.push(
	{
		name : "rainbow2",
		onclick : "initRainbow2()"
	}
);

var rainbow2_rom_functions = [];

function initRainbow2() {

	clearRomButtons();
	initLayerColor();

	for (i in rainbow_rom_functions) {
		createRomFunctionButton(rainbow_rom_functions[i]);
	}
    
	for (var i=0; i<LO_config.rows; i++) {
        rainbow2_s_counter.push([]);
		for (var j=0; j<LO_config.cols; j++) {
            rainbow2_s_counter[i].push(0);
        }
    }

	for (var i=0; i<LO_config.rows; i++) {
		for (var j=0; j<LO_config.cols; j++) {
			for (var k=0; k<LO_config.layers; k++) {
				setLayerColorHSV(i, j, k, 0.5, 1.0, 1.0);
			}
		}
	}

	clearInterval(animation);
	animation = setInterval(rainbow2Animation, rainbow2_animation_interval);
}


var rainbow2_v_incr = 0.05;
var rainbow2_h_incr = 0.0005;
var rainbow2_s_incr = 0.1;
var rainbow2_h_counter = 0;
var rainbow2_s_counter = [];
var rainbow2_station_counter = 0;

function rainbow2Animation() {
	var d = new Date();
    var time = d.getTime();
    
    var station_count = LO_config.rows * LO_config.cols;
    var i = Math.floor((rainbow2_station_counter % station_count) / LO_config.cols);
    var j = Math.floor((rainbow2_station_counter % station_count) % LO_config.cols);

    
    var top_touch_val = 0.5;
    var top_touch_bool = false;
    if (station_triggers[i][j]["top"].getTrigger("click", time, rainbow2_cap_delta)){
        top_touch_val = 0.0;
        top_touch_bool = true;
    }
    
    if (station_triggers[i][j]["top"].getTrigger("click", time, rainbow2_animation_interval*station_count)){
        rainbow2_s_counter[i][j] = 0;
    }
    

    for (var k=0; k<LO_config.layers; k++) {
        var h = (rainbow2_h_counter+1-0.2*i-0.04*j)%1;
        var s = 0;
            if (top_touch_bool) {
                s = top_touch_val+0.5-(rainbow2_s_counter[i][j]+0.1*k)%0.5;  
            } else {
                s = top_touch_val+0.5-(0.1*k)%0.5; 
            }


        setLayerColorHSV(i, j, k, h, s, undefined); 
    }
        
        
    rainbow2_s_counter[i][j] = rainbow2_s_counter[i][j] + rainbow2_s_incr;
    rainbow2_h_counter = rainbow2_h_counter + rainbow2_h_incr;
    
    station_update[i][j] = true;
    rainbow2_station_counter = rainbow2_station_counter + 1;
    updateAllStationsColor();  
}