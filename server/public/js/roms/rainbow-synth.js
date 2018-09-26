var rainbowSynth_cap_delta = 1000;
var rainbowSynth_animation_interval = 100;

Synth instanceof AudioSynth; // true

var testInstance = new AudioSynth;
testInstance instanceof AudioSynth; // true

testInstance === Synth; // true
var piano = Synth.createInstrument('piano');

rom_list.push({
    name: "rainbowSynth",
    onclick: "initrainbowSynth()"
});

var rainbowSynth_rom_functions = [

    {
        name: 'clear all',
        id: 'rainbowSynth_clear',
        function: 'rainbowSynthClear()',
        toggle: false,
    },
    {
        name: 'rainbowSynth cycle',
        id: 'rainbowSynth_cycle',
        function: 'rainbowSynthCycle()',
        toggle: false
	},
    {
        name: 'rainbowSynth confetti',
        id: 'rainbowSynth_confetti',
        function: 'rainbowSynthConfetti()',
        toggle: false
	},
    {
        name: 'greyscale confetti',
        id: 'rainbowSynth_confetti_grey',
        function: 'rainbowSynthConfettiGrey()',
        toggle: false
	}
];

function initrainbowSynth() {

    clearRomButtons();
    initLayerColor();

    for (i in rainbowSynth_rom_functions) {
        createRomFunctionButton(rainbowSynth_rom_functions[i]);
    }

    for (var i = 0; i < LO_config.rows; i++) {
        rainbowSynth_s_counter.push([]);
        for (var j = 0; j < LO_config.cols; j++) {
            rainbowSynth_s_counter[i].push(0);
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
    animation = setInterval(rainbowSynthAnimation, rainbowSynth_animation_interval);
}

var rainbowSynth_v_incr = 0.05;
var rainbowSynth_h_incr = 0.01;
var rainbowSynth_s_incr = 0.05;
var rainbowSynth_h_counter = 0;
var rainbowSynth_s_counter = [];
var rainbowSynth_run = true;
var rainbowSynth_mode = "rainbowSynth_cycle";

function rainbowSynthAnimation() {
    var d = new Date();
    var time = d.getTime();

    if (rainbowSynth_run == true) {
        for (var i = 0; i < LO_config.rows; i++) {
            for (var j = 0; j < LO_config.cols; j++) {

                var top_touch_val = 0.5;
                var top_touch_bool = false;
                if (station_triggers[i][j]["top"].getTrigger("click", time, rainbowSynth_cap_delta)) {
                    top_touch_val = 0.0;
                    top_touch_bool = true;

                }

                if (station_triggers[i][j]["top"].getTrigger("click", time, rainbowSynth_animation_interval)) {
                    rainbowSynth_s_counter[i][j] = 0;
                    var note = String.fromCharCode(67 + j);
                    Synth.play(1, note, i+2, 3); 
                }

                if (rainbowSynth_mode == "rainbowSynth_cycle") {

                    for (var k = 0; k < LO_config.layers; k++) {
                        var h = (rainbowSynth_h_counter + 1 - 0.2 * i - 0.04 * j) % 1;
                        var s = 0;
                        if (top_touch_bool) {
                            s = top_touch_val + 0.5 - (rainbowSynth_s_counter[i][j] + 0.1 * k) % 0.5;
                        } else {
                            s = top_touch_val + 0.5 - (0.1 * k) % 0.5;
                        }


                        setLayerColorHSV(i, j, k, h, s, undefined);
                    }

                }

                if (rainbowSynth_mode == "rainbowSynth_confetti") {

                    for (var k = 0; k < LO_config.layers; k++) {
                        var h = getRndDecimal(0, 100);
                        var s = 0;
                        if (top_touch_bool) {
                            s = top_touch_val + 0.5 - (rainbowSynth_s_counter[i][j] + 0.1 * k) % 0.5;
                        } else {
                            s = top_touch_val + 0.5 - (0.1 * k) % 0.5;
                        }


                        setLayerColorHSV(i, j, k, h, s, undefined);
                    }

                }

                if (rainbowSynth_mode == "rainbowSynth_confetti_grey") {

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

                rainbowSynth_s_counter[i][j] = rainbowSynth_s_counter[i][j] + rainbowSynth_s_incr;
            }
        }
        rainbowSynth_h_counter = rainbowSynth_h_counter + rainbowSynth_h_incr;
        updateAllStationsFlag();
    }
    updateAllStationsColor();

}

function getRndDecimal(min, max) {
    return (Math.floor(Math.random() * (max - min + 1)) + min) / 100;
}

function rainbowSynthClear() {
    rainbowSynth_run = false;
    for (var i = 0; i < LO_config.rows; i++) {
        for (var j = 0; j < LO_config.cols; j++) {
            for (var k = 0; k < LO_config.layers; k++) {
                setLayerColorHSV(i, j, k, 0.5, 1.0, 0.0);
            }
        }
    }
    updateAllStationsFlag();
    //console.log(rainbowSynth_run);
}

function rainbowSynthCycle() {
    rainbowSynth_run = true;
    rainbowSynth_mode = "rainbowSynth_cycle";
    for (var i = 0; i < LO_config.rows; i++) {
        for (var j = 0; j < LO_config.cols; j++) {
            for (var k = 0; k < LO_config.layers; k++) {
                setLayerColorHSV(i, j, k, undefined, undefined, 1.0);
            }
        }
    }
    updateAllStationsFlag();
    //console.log(rainbowSynth_run);
}

function rainbowSynthConfetti() {
    rainbowSynth_run = true;
    rainbowSynth_mode = "rainbowSynth_confetti";
    for (var i = 0; i < LO_config.rows; i++) {
        for (var j = 0; j < LO_config.cols; j++) {
            for (var k = 0; k < LO_config.layers; k++) {
                setLayerColorHSV(i, j, k, undefined, undefined, 1.0);
            }
        }
    }
    updateAllStationsFlag();
    //console.log(rainbowSynth_run);
}

function rainbowSynthConfettiGrey() {
    rainbowSynth_run = true;
    rainbowSynth_mode = "rainbowSynth_confetti_grey";
    for (var i = 0; i < LO_config.rows; i++) {
        for (var j = 0; j < LO_config.cols; j++) {
            for (var k = 0; k < LO_config.layers; k++) {
                setLayerColorHSV(i, j, k, 0, 0, undefined);
            }
        }
    }
    updateAllStationsFlag();
    //console.log(rainbowSynth_run);
}
