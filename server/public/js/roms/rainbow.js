var rainbow_cap_delta = 3000;
var rainbow_animation_interval = 50;

rom_list.push({
    name: "rainbow",
    onclick: "initRainbow()"
});

var rainbow_rom_functions = [

    {
        name: 'clear all',
        id: 'rainbow_clear',
        function: 'rainbowClear()',
        toggle: false,
    },
    {
        name: 'rainbow cycle',
        id: 'rainbow_cycle',
        function: 'rainbowCycle()',
        toggle: false
	},
    {
        name: 'rainbow confetti',
        id: 'rainbow_confetti',
        function: 'rainbowConfetti()',
        toggle: false
	},
    {
        name: 'greyscale confetti',
        id: 'rainbow_confetti_grey',
        function: 'rainbowConfettiGrey()',
        toggle: false
	}
];

function initRainbow() {

    clearRomButtons();
    initLayerColor();

    for (i in rainbow_rom_functions) {
        createRomFunctionButton(rainbow_rom_functions[i]);
    }

    for (var i = 0; i < LO_config.rows; i++) {
        rainbow_s_counter.push([]);
        for (var j = 0; j < LO_config.cols; j++) {
            rainbow_s_counter[i].push(0);
        }
    }

    for (var i = 0; i < LO_config.rows; i++) {
        for (var j = 0; j < LO_config.cols; j++) {
            for (var k = 0; k < LO_config.layers; k++) {
                setLayerColorHSV(i, j, k, 0.5, 1.0, 1.0); //starts off completely dark with full saturation at about the hue blue
            }
        }
    }

    clearInterval(animation);
    animation = setInterval(rainbowAnimation, rainbow_animation_interval);
}

var rainbow_v_incr = 0.05;
var rainbow_h_incr = 0.01;
var rainbow_s_incr = 0.05;
var rainbow_h_counter = 0;
var rainbow_s_counter = [];
var rainbow_run = true;
var rainbow_mode = "rainbow_cycle";

function rainbowAnimation() {
    var d = new Date();
    var time = d.getTime();

    if (rainbow_run == true) {
        for (var i = 0; i < LO_config.rows; i++) {
            for (var j = 0; j < LO_config.cols; j++) {

                var top_touch_val = 0.5;
                var top_touch_bool = false;
                if (station_triggers[i][j]["top"].getTrigger("click", time, rainbow_cap_delta)) {
                    top_touch_val = 0.0;
                    top_touch_bool = true;
                }

                if (station_triggers[i][j]["top"].getTrigger("click", time, rainbow_animation_interval)) {
                    rainbow_s_counter[i][j] = 0;
                }

                if (rainbow_mode == "rainbow_cycle") {

                    for (var k = 0; k < LO_config.layers; k++) {
                        var h = (rainbow_h_counter + 1 - 0.2 * i - 0.04 * j) % 1;
                        var s = 0;
                        if (top_touch_bool) {
                            s = top_touch_val + 0.5 - (rainbow_s_counter[i][j] + 0.1 * k) % 0.5;
                        } else {
                            s = top_touch_val + 0.5 - (0.1 * k) % 0.5;
                        }


                        setLayerColorHSV(i, j, k, h, s, undefined);
                    }

                }

                if (rainbow_mode == "rainbow_confetti") {

                    for (var k = 0; k < LO_config.layers; k++) {
                        var h = getRndDecimal(0, 100);
                        var s = 0;
                        if (top_touch_bool) {
                            s = top_touch_val + 0.5 - (rainbow_s_counter[i][j] + 0.1 * k) % 0.5;
                        } else {
                            s = top_touch_val + 0.5 - (0.1 * k) % 0.5;
                        }


                        setLayerColorHSV(i, j, k, h, s, undefined);
                    }

                }

                if (rainbow_mode == "rainbow_confetti_grey") {

                    for (var k = 0; k < LO_config.layers; k++) {
                        var h = 0;
                        var s = 0;
                        var v = 0;
                        if (top_touch_bool) {
                            v = getRndDecimal(70, 100);
                        } else {
                            v = getRndDecimal(0, 100);;
                        }


                        setLayerColorHSV(i, j, k, h, s, v);
                    }

                }

                rainbow_s_counter[i][j] = rainbow_s_counter[i][j] + rainbow_s_incr;
            }
        }
        rainbow_h_counter = rainbow_h_counter + rainbow_h_incr;
        updateAllStationsFlag();
    }
    updateAllStationsColor();

}

function getRndDecimal(min, max) {
    return (Math.floor(Math.random() * (max - min + 1)) + min) / 100;
}

function rainbowClear() {
    rainbow_run = false;
    for (var i = 0; i < LO_config.rows; i++) {
        for (var j = 0; j < LO_config.cols; j++) {
            for (var k = 0; k < LO_config.layers; k++) {
                setLayerColorHSV(i, j, k, 0.5, 1.0, 0.0);
            }
        }
    }
    updateAllStationsFlag();
    //console.log(rainbow_run);
}

function rainbowCycle() {
    rainbow_run = true;
    rainbow_mode = "rainbow_cycle";
    for (var i = 0; i < LO_config.rows; i++) {
        for (var j = 0; j < LO_config.cols; j++) {
            for (var k = 0; k < LO_config.layers; k++) {
                setLayerColorHSV(i, j, k, undefined, undefined, 1.0);
            }
        }
    }
    updateAllStationsFlag();
    //console.log(rainbow_run);
}

function rainbowConfetti() {
    rainbow_run = true;
    rainbow_mode = "rainbow_confetti";
    for (var i = 0; i < LO_config.rows; i++) {
        for (var j = 0; j < LO_config.cols; j++) {
            for (var k = 0; k < LO_config.layers; k++) {
                setLayerColorHSV(i, j, k, undefined, undefined, 1.0);
            }
        }
    }
    updateAllStationsFlag();
    //console.log(rainbow_run);
}

function rainbowConfettiGrey() {
    rainbow_run = true;
    rainbow_mode = "rainbow_confetti_grey";
    for (var i = 0; i < LO_config.rows; i++) {
        for (var j = 0; j < LO_config.cols; j++) {
            for (var k = 0; k < LO_config.layers; k++) {
                setLayerColorHSV(i, j, k, 0, 0, undefined);
            }
        }
    }
    updateAllStationsFlag();
    //console.log(rainbow_run);
}
