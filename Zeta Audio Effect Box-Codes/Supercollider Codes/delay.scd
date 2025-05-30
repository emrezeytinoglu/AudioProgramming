(

var w;

~delayGrid = [1.0, 0.5, 0.25, 0.125, 0.0625];
~selectedDelayIndex = 2;


SynthDef(\gridDelayFX, {
    arg inBus=0, out=0, delayIndex=2, feedback=0.4, mix=0.4;
    var input, fbIn, delayTime, delayed, wet, dry, output;

    input = In.ar(inBus, 2);
    fbIn = LocalIn.ar(2);

    delayTime = Select.kr(delayIndex, ~delayGrid);
    delayed = DelayC.ar(input + (fbIn * feedback), 1.0, delayTime);

    LocalOut.ar(delayed);

    dry = input * (1 - mix);
    wet = delayed * mix;
    output = dry + wet;

    Out.ar(out, output);
}).add;



w = Window("Grid Delay", Rect(100, 100, 300, 240)).front;

EZSlider(w, Rect(20, 20, 260, 20), "Delay Index (0-4)", ControlSpec(0, 4, \lin, 1), {
    |v|
    ~selectedDelayIndex = v.value.asInteger;
    ~delay.set(\delayIndex, ~selectedDelayIndex);
}, ~selectedDelayIndex);

EZSlider(w, Rect(20, 60, 260, 20), "Feedback", ControlSpec(0.0, 0.9, \lin, 0.01), {
    |v| ~delay.set(\feedback, v.value);
}, 0.4);

EZSlider(w, Rect(20, 100, 260, 20), "Dry/Wet", ControlSpec(0.0, 1.0, \lin, 0.01), {
    |v|
    ~delIn = v.value;
    ~normalizeMixes.();
}, 0.4);


OSCdef(\delayIndex, { |msg|
    var idx = msg[1].asInteger.clip(0, ~delayGrid.size - 1);
    ~selectedDelayIndex = idx;
    ~delay.set(\delayIndex, idx);
}, "/delay/time");

OSCdef(\delayFeedback, { |msg|
    ~delay.set(\feedback, msg[1].asFloat);
}, "/delay/feedback");

OSCdef(\delayMix, { |msg|
    ~delIn = msg[1].asFloat;
    ~normalizeMixes.();
}, "/delay/mix");
)
