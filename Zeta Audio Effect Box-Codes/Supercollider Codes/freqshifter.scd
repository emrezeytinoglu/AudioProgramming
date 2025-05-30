(
var w, waveMenu;

SynthDef(\pitchShiftFX, {
    arg inBus=0, out=0, lfoRate=0.2, lfoAmount=0.0, lfoType=0, mix=0.5, detune=0.01, fftSize=1024;
    var input, lfo, ratio, shifted, final, isBypassed, mixCurve, chainL, chainR, fftBufL, fftBufR;

    input = In.ar(inBus, 2);
    lfo = Select.kr(lfoType, [
        SinOsc.kr(lfoRate),
        LFTri.kr(lfoRate),
        LFPulse.kr(lfoRate)
    ]);

    ratio = lfo * lfoAmount + 1.0;
    isBypassed = lfoAmount <= 0.0001;


    fftBufL = LocalBuf(fftSize);
    fftBufR = LocalBuf(fftSize);


    chainL = FFT(fftBufL, input[0]);
    chainR = FFT(fftBufR, input[1]);
    shifted = [
        IFFT(PV_PitchShift(chainL, ratio * (1 + detune))),
        IFFT(PV_PitchShift(chainR, ratio * (1 - detune)))
    ];


    mixCurve = (1 - cos(mix * pi)) * 0.5;
    final = SelectX.ar(isBypassed, [XFade2.ar(input, shifted, (mixCurve * 2) - 1), input]);
    Out.ar(out, final);
}).add;


w = Window("Pitch Shifter FX", Rect(100, 100, 350, 190)).front;

EZSlider(w, Rect(20, 20, 300, 20), "Dry/Wet", ControlSpec(0, 1, \lin, 0.01), {
    |v| ~pitIn = v.value; ~normalizeMixes.();
}, ~pitIn);

EZSlider(w, Rect(20, 60, 300, 20), "LFO Rate (Hz)", ControlSpec(0.01, 10, \exp, 0.01), {
    |v| ~pitchshifter.set(\lfoRate, v.value);
}, 0.2);

EZSlider(w, Rect(20, 100, 300, 20), "LFO Amount (semitones)", ControlSpec(0, 24, \lin, 0.1), {
    |v| var ratio = 2.pow(v.value / 12); ~pitchshifter.set(\lfoAmount, ratio - 1);
}, 0.0);

StaticText(w, Rect(20, 140, 100, 20)).string = "LFO Waveform:";
waveMenu = PopUpMenu(w, Rect(130, 140, 120, 20));
waveMenu.items = ["sine", "triangle", "square"];
waveMenu.action = { var sel = waveMenu.value; ~pitchshifter.set(\lfoType, sel); };
waveMenu.value = 0;


OSCdef(\pitchShiftRate, { |msg|
    ~pitchshifter.set(\lfoRate, msg[1].asFloat);
}, "/pitchshift/rate");

OSCdef(\pitchShiftAmt, { |msg|
    var semitone = msg[1].asFloat.linlin(0, 1, 0, 24);
    var ratio = 2.pow(semitone / 12);
    ~pitchshifter.set(\lfoAmount, ratio - 1);
}, "/pitchshift/amount");

OSCdef(\pitchShiftMix, { |msg|
    ~pitIn = msg[1].asFloat;
    ~normalizeMixes.();
}, "/pitchshift/mix");

OSCdef(\pitchShiftWave, { |msg|
    var wave = msg[1].asSymbol;
    var typeIndex = [\sine, \triangle, \square].indexOf(wave);
    if (typeIndex.notNil) {
        ~pitchshifter.set(\lfoType, typeIndex);
    }
}, "/pitchshift/lfo");
)
