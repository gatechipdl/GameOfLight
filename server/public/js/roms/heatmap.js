var heatmap_cap_delta = 3000;
var heatmap_animation_interval = 100;

rom_list.push({
    name: "heatmap",
    onclick: "initheatmap()"
});

var heatmap_rom_functions = [

    {
        name: 'clear all',
        id: 'heatmap_clear',
        function: 'heatmapClear()',
        toggle: false,
    },
    {
        name: 'heatmap cycle',
        id: 'heatmap_cycle',
        function: 'heatmapCycle()',
        toggle: false
	}
];

function initheatmap() {

    clearRomButtons();
    initLayerColor();

    for (i in heatmap_rom_functions) {
        createRomFunctionButton(heatmap_rom_functions[i]);
    }

    for (var i = 0; i < LO_config.rows; i++) {
        heatmap_s_counter.push([]);
        for (var j = 0; j < LO_config.cols; j++) {
            heatmap_s_counter[i].push(0);
        }
    }

    for (var i = 0; i < LO_config.rows; i++) {
        for (var j = 0; j < LO_config.cols; j++) {
            for (var k = 0; k < LO_config.layers; k++) {
                var h = getRndDecimal(0, 33);
                var s = 1;
                var v = 1;

                setLayerColorHSV(i, j, k, h, s, v);
            }
        }
    }

    clearInterval(animation);
    animation = setInterval(heatmapAnimation, heatmap_animation_interval);
}

var heatmap_v_incr = 0.05;
var heatmap_h_incr = 0.01;
var heatmap_s_incr = 0.05;
var heatmap_h_counter = 0;
var heatmap_s_counter = [];
var heatmap_run = true;
var heatmap_mode = "heatmap";

function heatmapAnimation() {
    var d = new Date();
    var time = d.getTime();

    if (heatmap_run == true) {
        for (var i = 0; i < LO_config.rows; i++) {
            for (var j = 0; j < LO_config.cols; j++) {

                var top_touch_val = 0.5;
                var top_touch_bool = false;
                if (station_triggers[i][j]["top"].getTrigger("click", time, heatmap_cap_delta)) {
                    top_touch_val = 0.0;
                    top_touch_bool = true;
                }

                if (station_triggers[i][j]["top"].getTrigger("click", time, heatmap_animation_interval)) {
                    heatmap_s_counter[i][j] = 0;
                }


                if (heatmap_mode == "heatmap_nope") {

                    for (var k = 0; k < LO_config.layers; k++) {
                        var h = getRndDecimal(0, 35);
                        var s = 1;
                        var v = 1;

                        setLayerColorHSV(i, j, k, h, s, v);
                    }

                }

                heatmap_s_counter[i][j] = heatmap_s_counter[i][j] + heatmap_s_incr;
            }
        }
        heatmap_h_counter = heatmap_h_counter + heatmap_h_incr;
        updateAllStationsFlag();
    }
    updateAllStationsColor();

}

function getRndDecimal(min, max) {
    return (Math.floor(Math.random() * (max - min + 1)) + min) / 100;
}

function heatmapClear() {
    heatmap_run = false;
    for (var i = 0; i < LO_config.rows; i++) {
        for (var j = 0; j < LO_config.cols; j++) {
            for (var k = 0; k < LO_config.layers; k++) {
                setLayerColorHSV(i, j, k, 0.5, 1.0, 0.0);
            }
        }
    }
    updateAllStationsFlag();
    //console.log(heatmap_run);
}

function heatmapCycle() {
    heatmap_run = true;
    //heatmap_mode = "heatmap_cycle";
    for (var i = 0; i < LO_config.rows; i++) {
        for (var j = 0; j < LO_config.cols; j++) {
            for (var k = 0; k < LO_config.layers; k++) {
                var h = getRndDecimal(0, 33);
                var s = 1;
                var v = 1;

                setLayerColorHSV(i, j, k, h, s, v);
            }
        }
    }
    updateAllStationsFlag();
    //console.log(heatmap_run);
}
