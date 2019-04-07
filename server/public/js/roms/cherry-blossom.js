var cherry_cap_delta = 3000;
var cherry_animation_interval = 50;

rom_list.push({
    name: "cherry",
    onclick: "initcherry()"
});

var cherry_rom_functions = [

    {
        name: 'clear all',
        id: 'cherry_clear',
        function: 'cherryClear()',
        toggle: false,
    },
    {
        name: 'cherry cycle',
        id: 'cherry_cycle',
        function: 'cherryCycle()',
        toggle: false
	}
];

function initcherry() {

    clearRomButtons();
    initLayerColor();

    for (i in cherry_rom_functions) {
        createRomFunctionButton(cherry_rom_functions[i]);
    }

    for (var i = 0; i < LO_config.rows; i++) {
        cherry_s_counter.push([]);
        for (var j = 0; j < LO_config.cols; j++) {
            cherry_s_counter[i].push(0);
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
    animation = setInterval(cherryAnimation, cherry_animation_interval);
}

var cherry_v_incr = 0.05;
var cherry_h_incr = 0.01;
var cherry_s_incr = 0.05;
var cherry_h_counter = 0;
var cherry_s_counter = [];
var cherry_run = true;
var cherry_mode = "cherry_cycle";

function cherryAnimation() {
    var d = new Date();
    var time = d.getTime();

    if (cherry_run == true) {
        for (var i = 0; i < LO_config.rows; i++) {
            for (var j = 0; j < LO_config.cols; j++) {

                var top_touch_val = 0.5;
                var top_touch_bool = false;
                if (station_triggers[i][j]["top"].getTrigger("click", time, cherry_cap_delta)) {
                    top_touch_val = 0.0;
                    top_touch_bool = true;
                }

                if (station_triggers[i][j]["top"].getTrigger("click", time, cherry_animation_interval)) {
                    cherry_s_counter[i][j] = 0;
                }

                if (cherry_mode == "cherry_cycle") {

                    for (var k = 0; k < LO_config.layers; k++) {
                        //var h = (cherry_h_counter + 1 - 0.2 * i - 0.04 * j) % 1;
                        var h = 260;
                        var s = 0;
                        if (top_touch_bool) {
                            s = top_touch_val + 0.5 - (cherry_s_counter[i][j] + 0.1 * k) % 0.5;
                        } else {
                            //s = top_touch_val + 0.5 - (0.1 * k) % 0.5;
                            s = top_touch_val + (0.1 * k) % 0.5;
                        }


                        setLayerColorHSV(i, j, k, h, s, undefined);
                    }

                }

                if (cherry_mode == "cherry_confetti") {

                    for (var k = 0; k < LO_config.layers; k++) {
                        var h = getRndDecimal(0, 100);
                        var s = 0;
                        if (top_touch_bool) {
                            s = top_touch_val + 0.5 - (cherry_s_counter[i][j] + 0.1 * k) % 0.5;
                        } else {
                            s = top_touch_val + 0.5 - (0.1 * k) % 0.5;
                        }


                        setLayerColorHSV(i, j, k, h, s, undefined);
                    }

                }

                if (cherry_mode == "cherry_confetti_grey") {

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

                cherry_s_counter[i][j] = cherry_s_counter[i][j] + cherry_s_incr;
            }
        }
        cherry_h_counter = cherry_h_counter + cherry_h_incr;
        updateAllStationsFlag();
    }
    updateAllStationsColor();

}

function getRndDecimal(min, max) {
    return (Math.floor(Math.random() * (max - min + 1)) + min) / 100;
}

function cherryClear() {
    cherry_run = false;
    for (var i = 0; i < LO_config.rows; i++) {
        for (var j = 0; j < LO_config.cols; j++) {
            for (var k = 0; k < LO_config.layers; k++) {
                setLayerColorHSV(i, j, k, 0.5, 1.0, 0.0);
            }
        }
    }
    updateAllStationsFlag();
    //console.log(cherry_run);
}

function cherryCycle() {
    cherry_run = true;
    cherry_mode = "cherry_cycle";
    for (var i = 0; i < LO_config.rows; i++) {
        for (var j = 0; j < LO_config.cols; j++) {
            for (var k = 0; k < LO_config.layers; k++) {
                setLayerColorHSV(i, j, k, undefined, undefined, 1.0);
            }
        }
    }
    updateAllStationsFlag();
    //console.log(cherry_run);
}

function cherryConfetti() {
    cherry_run = true;
    cherry_mode = "cherry_confetti";
    for (var i = 0; i < LO_config.rows; i++) {
        for (var j = 0; j < LO_config.cols; j++) {
            for (var k = 0; k < LO_config.layers; k++) {
                setLayerColorHSV(i, j, k, undefined, undefined, 1.0);
            }
        }
    }
    updateAllStationsFlag();
    //console.log(cherry_run);
}

function cherryConfettiGrey() {
    cherry_run = true;
    cherry_mode = "cherry_confetti_grey";
    for (var i = 0; i < LO_config.rows; i++) {
        for (var j = 0; j < LO_config.cols; j++) {
            for (var k = 0; k < LO_config.layers; k++) {
                setLayerColorHSV(i, j, k, 0, 0, undefined);
            }
        }
    }
    updateAllStationsFlag();
    //console.log(cherry_run);
}
