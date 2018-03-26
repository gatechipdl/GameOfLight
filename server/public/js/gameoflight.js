var gol_cap_delta = 250;
var gol_animation_interval = 250;
var gol_generation_interval = 2000;
var generation_time = 0;

var gol_rom_functions = [
	{
        name : 'random',
        id : 'gol_random',
        function : 'golRandom()',
        toggle : false,
        disable : ['gol_run']
    },
    {
        name : 'clear all',
        id : 'gol_clear',
        function : 'golClear()',
        toggle : false,
        disable : ['gol_run'],
        color : "#FF0000"
    },
    {
        name : 'reset',
        id : 'gol_reset',
        function : 'golReset()',
        toggle : false,
        disable : ['gol_run']
    },
    {
        name : 'edit',
        id : 'gol_edit',
        function : 'golEdit()',
        toggle : true,
        disable : ['gol_run']
    },
    {
        name : 'run',
        id : 'gol_run',
        function : 'golRun()',
        toggle : true,
        disable : ['gol_edit'],
        color : "#00FF00"
    },
    {
        name : 'increase generation interval',
        id : 'gol_increase_interval',
        function : 'golIncreaseInterval()',
        toggle : false
    },
    {
        name : 'decrease generation interval',
        id : 'gol_increase_interval',
        function : 'golDecreaseInterval()',
        toggle : false
    }
];

var game_state = [];
var curr_game_state = [];
var next_game_state = [];
var runGame = false;
var editGame = false;
var live_domain = [4, 8];

function initGOL() {
	clearRomButtons();
	initLayerColor();

	for (i in gol_rom_functions) {
		createRomFunctionButton(gol_rom_functions[i]);
    }
    
    for (var i=0; i<LO_config.rows; i++) {
        game_state.push([]);
		for (var j=0; j<LO_config.cols; j++) {
            game_state[i].push([]);
			for (var k=0; k<LO_config.layers; k++) {
                game_state[i][j].push(0);
            }
        }
    }
    curr_game_state = $.extend(true, {}, game_state);
    next_game_state = $.extend(true, {}, game_state);

	clearInterval(animation);
	animation = setInterval(golAnimation, gol_animation_interval);
}


function golAnimation() {
    var d = new Date();
	var time = d.getTime();
    if (runGame) {
        if (time - generation_time > gol_generation_interval) {
            updateGame();
            generation_time = time;
        }
        var time_ratio = (time-generation_time)/gol_generation_interval;
        time_ratio = time_ratio >= 1.0 ? 1.0 : time_ratio;
        for (var i=0; i<LO_config.rows; i++) {
            for (var j=0; j<LO_config.cols; j++) {
                for (var k=0; k<LO_config.layers; k++) { 
                    var rgb = renderLayer(i, j, k, curr_game_state[i][j][k], next_game_state[i][j][k], time_ratio);
                    setLayerColorRGB(i, j, k, rgb.r, rgb.g, rgb.b);
                }
            }
        }
        station_update = $.extend(true, {}, comparing_station_states);
    } else if (editGame) {
        for (var i=0; i<LO_config.rows; i++) {
            for (var j=0; j<LO_config.cols; j++) {
                for (var k=0; k<LO_config.layers; k++) {
                    if (station_triggers[i][j]['L'+k].getTrigger("click", time, gol_cap_delta)) {
                        game_state[i][j][k] = (game_state[i][j][k]+1)%4;
                        setGameLayerColor(i, j, k, game_state[i][j][k]);
                        station_update[i][j] = true;
                    }
                    if (station_triggers[i][j]['R'+k].getTrigger("click", time, gol_cap_delta)) {
                        game_state[i][j][k] = (4+game_state[i][j][k]-1)%4;
                        setGameLayerColor(i, j, k, game_state[i][j][k]);
                        station_update[i][j] = true;
                    }
                }
            }
        }
        curr_game_state = $.extend(true, {}, game_state);
        next_game_state = $.extend(true, {}, game_state);
    } else {

    }
    updateAllStationsColor();
}

function setGameLayerColor(row, col, layer, state) {
    switch(state) {
        case 1:
            setLayerColorRGB(row, col, layer, 255, 0, 0);
            break;
        case 2:
            setLayerColorRGB(row, col, layer, 0, 255, 0);
            break;
        case 3:
            setLayerColorRGB(row, col, layer, 0, 0, 255);
            break;
        default:
            setLayerColorRGB(row, col, layer, 0, 0, 0);
            break;
    }
}

function golRandom() {
    runGame = false;
    for (var i=0; i<LO_config.rows; i++) {
        for (var j=0; j<LO_config.cols; j++) {
            for (var k=0; k<LO_config.layers; k++) {
                var random_state = Math.floor(Math.random()*4.999999);
                game_state[i][j][k] = random_state;
                setGameLayerColor(i, j, k, random_state);
            }
        }
    }
    curr_game_state = $.extend(true, {}, game_state);
    next_game_state = $.extend(true, {}, game_state);
    updateAllStationsFlag();
}

function golClear() {
    runGame = false;
    for (var i=0; i<LO_config.rows; i++) {
        for (var j=0; j<LO_config.cols; j++) {
            for (var k=0; k<LO_config.layers; k++) {
                game_state[i][j][k] = 0;
                setGameLayerColor(i, j, k, 0);
            }
        }
    }
    curr_game_state = $.extend(true, {}, game_state);
    next_game_state = $.extend(true, {}, game_state);
    updateAllStationsFlag();
}

function golReset() {
    runGame = false;
    for (var i=0; i<LO_config.rows; i++) {
        for (var j=0; j<LO_config.cols; j++) {
            for (var k=0; k<LO_config.layers; k++) {
                setGameLayerColor(i, j, k, game_state[i][j][k]);
            }
        }
    }
    curr_game_state = $.extend(true, {}, game_state);
    next_game_state = $.extend(true, {}, game_state);
    updateAllStationsFlag();
}

function golEdit() {
    editGame = !editGame;
    runGame = false;
    if (editGame) {
        game_state = $.extend(true, {}, curr_game_state);
        next_game_state = $.extend(true, {}, curr_game_state);
    }
}

function golRun() {
    runGame = !runGame;
    editGame = false;
    if (!runGame) {
        generation_counter = 0;
        for (var i=0; i<LO_config.rows; i++) {
            for (var j=0; j<LO_config.cols; j++) {
                for (var k=0; k<LO_config.layers; k++) { 
                    var rgb = renderLayer(i, j, k, curr_game_state[i][j][k], next_game_state[i][j][k], 0);
                    setLayerColorRGB(i, j, k, rgb.r, rgb.g, rgb.b);
                }
            }
        }
    }
    updateAllStationsFlag();
}

function golIncreaseInterval() {
    gol_generation_interval = gol_generation_interval + 100;
    console.log("gol_generation_interval "+gol_generation_interval);
}

function golDecreaseInterval() {
    gol_generation_interval = gol_generation_interval - 100;
    gol_generation_interval = gol_generation_interval <= 0 ? 0 : gol_generation_interval;
    console.log("gol_generation_interval "+gol_generation_interval);
}


var comparing_station_states = [];
function updateGame() {

    curr_game_state = $.extend(true, {}, next_game_state);

    for (var i=0; i<LO_config.rows; i++) {
        for (var j=0; j<LO_config.cols; j++) {
            for (var k=0; k<LO_config.layers; k++) {

                var neighbor = [0, 0, 0, 0];

                for (var x=-1.0; x<=1.0; x++) {
                    for (var y=-1.0; y<=1.0; y++) {
                        for (var z=-1.0; z<=1.0; z++) {
                            var x1 = (parseInt(LO_config.rows)+parseInt(i)+parseInt(x))%parseInt(LO_config.rows);
                            var y1 = (parseInt(LO_config.cols)+parseInt(j)+parseInt(y))%parseInt(LO_config.cols);
                            var z1 = (parseInt(LO_config.layers)+parseInt(k)+parseInt(z))%parseInt(LO_config.layers);
                            neighbor[curr_game_state[x1][y1][z1]]++;
                        }
                    }   
                }

                for (var m=0; m<neighbor.length; m++) {
                    if (neighbor[m] <= live_domain[0] || neighbor[m] >= live_domain[1]) {
                        neighbor[m] = 0;
                    }
                }

                var index_max = 0;
                var max_count = 0;

                for (var m=0; m<neighbor.length; m++) {
                    if (neighbor[m] > max_count) {
                        max_count = neighbor[m];
                        index_max = parseInt(m); 
                    }
                }

                next_game_state[i][j][k] = index_max;
            }
        }
    }

    comparing_station_states = [];
    var counter = 0;
    for (i in curr_game_state) {
        comparing_station_states.push([]);
        for (j in curr_game_state[i]) {
            comparing_station_states[i].push(false);
            var update_station_bool = false;
            for (k in curr_game_state[i][j]) {
                if (curr_game_state[i][j][k] != next_game_state[i][j][k]) {
                    update_station_bool = true;
                    break;
                }
            }
            if (update_station_bool) {
                comparing_station_states[i][j] = true;
                counter++;
            }
        }
    }
    console.log('updating', counter, 'stations');
}

function renderLayer(row, col, layer, curr, next, time_ratio) {
    var rgb1 = {r:0, g:0, b:0};
    var rgb2 = {r:0, g:0, b:0};
    switch(curr) {
        case 1:
            rgb1.r = 255;
            break;
        case 2:
            rgb1.g = 255;
            break;
        case 3:
            rgb1.b = 255;
            break;
    }
    switch(next) {
        case 1:
            rgb2.r = 255;
            break;
        case 2:
            rgb2.g = 255;
            break;
        case 3:
            rgb2.b = 255;
            break;
    }
    var rgb = {
        r : Math.floor((1-time_ratio)*rgb1.r + time_ratio*rgb2.r),
        g : Math.floor((1-time_ratio)*rgb1.g + time_ratio*rgb2.g),
        b : Math.floor((1-time_ratio)*rgb1.b + time_ratio*rgb2.b)
    };
    return rgb;
}