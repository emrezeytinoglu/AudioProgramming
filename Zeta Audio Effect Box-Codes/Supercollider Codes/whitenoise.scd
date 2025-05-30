(
SynthDef(\whiteNoiseFX, {
	arg out=0, amp=0.0;
	var sig;

	sig = WhiteNoise.ar;
	sig = BPF.ar(sig, 1200, 1);
	sig = LPF.ar(sig, 9000);
	sig = sig * amp;
	Out.ar(out, sig.dup);
}).add;


EZSlider(w, Rect(20, 240, 300, 20), "White Noise", ControlSpec(0, 1, \lin, 0.01), {
	|v| ~noiseIn = v.value; ~normalizeMixes.();
}, ~noiseIn);


OSCdef(\noiseAmp, { |msg|
    var val = msg[1].asFloat;
    ~noiseIn = val.clip(0, 1);
    ~normalizeMixes.();
}, '/noise/amp');
)
