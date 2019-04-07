var audioviz_cap_delta = 3000;
var audioviz_animation_interval = 50;

rom_list.push({
    name: "audio viz",
    onclick: "initAudioViz()"
});

var audioviz_rom_functions = [

    {
        name: 'audio viz start',
        id: 'audioviz_start',
        function: 'audiovizStart()',
        toggle: false
    },
    {
        name: 'audio viz stop',
        id: 'audioviz_stop',
        function: 'audiovizStop()',
        toggle: false
    }
];


function MicrophoneSample(){
    this.audioCtx = new (window.AudioContext || window.webkitAudioContext)();
    this.getMicrophoneInput();
}

MicrophoneSample.prototype.getMicrophoneInput = function(){
    navigator.getUserMedia({audio:true},
        this.onStream.bind(this),
        this.onStreamError.bind(this));
};

MicrophoneSample.prototype.onStream = function(stream){
    var input = this.audioCtx.createMediaStreamSource(stream);
    var filter = this.audioCtx.createBiquadFilter();//depricated?
    filter.frequency.value = 60.0;
    filter.type = filter.NOTCH;
    filter.Q = 10.0;

    var analyser = this.audioCtx.createAnalyser();

    //filter graph
    input.connect(filter);
    filter.connect(analyser);

    this.analyser = analyser; //1024 bins
    this.analyser.fftSize = 256;
    requestAnimationFrame(this.visualize.bind(this));
}

MicrophoneSample.prototype.onStreamError = function(e){
    console.error('Error getting microphone', e);
};

var buckets = [0,0,0,0,0,0];

MicrophoneSample.prototype.visualize = function(){
    var times = new Uint8Array(this.analyser.frequencyBinCount); //1024 bins
    //this.analyser.getByteTimeDomainData(times);
    this.analyser.getByteFrequencyData(times);
    buckets = [0,0,0,0,0,0];
    //for(let i=0;i<times.length;i++){
    //    buckets[Math.floor(i/(times.length/6))]+=times[i]/256;
    //}
    for(let i=0;i<6;i++){
        // buckets[i]/=(times.length/6);
        buckets[i]=times[i]/256;
    }
    // console.log(times);
    // console.log(buckets[0].toFixed(3)
    // +','+buckets[1].toFixed(3)
    // +','+buckets[2].toFixed(3)
    // +','+buckets[3].toFixed(3)
    // +','+buckets[4].toFixed(3)
    // +','+buckets[5].toFixed(3));
    requestAnimationFrame(this.visualize.bind(this));


}




function initAudioViz() {

    clearRomButtons();
    initLayerColor();

    navigator.getUserMedia = (navigator.getUserMedia ||
                            navigator.webkitGetUserMedia ||
                            navigator.mozGetUserMedia ||
                            navigator.msGetUserMedia);
    
    

    //var audioCtx = new (window.AudioContext || window.webkitAudioContext)();
    var sample = new MicrophoneSample();
    // var analyser = audioCtx.createAnalyser();
    // var source = audioCtx.createMeiaStreamSource(stream);
    // source.connect(analyser);
    // analyser.connect(distortion);
    // distortion.connect(audioCtx.destination);


    for (i in audioviz_rom_functions) {
        createRomFunctionButton(audioviz_rom_functions[i]);
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
    animation = setInterval(audiovizAnimation, audioviz_animation_interval);
}

function audiovizAnimation() {
    var d = new Date();
    var time = d.getTime();

    
    for (var i = 0; i < LO_config.rows; i++) {
        //for (var j = 0; j < LO_config.cols; j++) {
        for (var j = 0; j < 1; j++) {
            for (var k = 0; k < LO_config.layers; k++) {
                setLayerColorHSV(i, j, k, i/6.0, 1.0, (buckets[i]*5>k));
            }
        }
    }
    updateAllStationsFlag();
    updateAllStationsColor();

}