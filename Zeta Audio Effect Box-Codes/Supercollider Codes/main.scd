(

s.options.memSize = 65536;
s.options.numOutputBusChannels = 2;
s.reboot;

s.waitForBoot {
    ~inputBus = Bus.audio(s, 2);
    ~fxBus = Bus.audio(s, 2);

    ~revIn = 0.0;
    ~delIn = 0.0;
    ~pitIn = 0.0;
	~noiseIn = 0.0;


    ~normalizeMixes = {
		var sum = ~revIn + ~delIn + ~pitIn + ~noiseIn;
		var norm = if(sum > 1.0, { 1 / sum }, { 1.0 });

		var rev = ~revIn * norm;
		var del = ~delIn * norm;
		var pit = ~pitIn * norm;
		var noise = ~noiseIn * norm;
		var dry = 1.0 - (rev + del + pit + noise);

		~reverb.set(\mix, rev);
		~delay.set(\mix, del);
		~pitchshifter.set(\mix, pit);
		~dry.set(\dryLevel, dry);
		~noise.set(\amp, noise);
	};

    ~amen = Buffer.read(s, "/Users/emrezeytinoglu/Zeta Audio Effect Box/thand.mp3");

    SynthDef(\player, {
		arg out=0, rate=1.0, gain=0.5;
		var sig = PlayBuf.ar(2, ~amen.bufnum, BufRateScale.kr(~amen.bufnum) * rate, loop: 1);
		sig = sig * gain;
		Out.ar(out, sig);
	}).add;

    SynthDef(\dryOut, {
        arg inBus=0, out=0, dryLevel=1.0;
        var input = In.ar(inBus, 2);
        Out.ar(out, input * dryLevel);
    }).add;


    SynthDef(\masterLimiter, {
        arg inBus=0, out=0;
        var sig = In.ar(inBus, 2);
        sig = Limiter.ar(sig, 0.90);
        Out.ar(out, sig);
    }).add;

    "/Users/emrezeytinoglu/Zeta Audio Effect Box/JPVERB with presets.scd".standardizePath.load;
    "/Users/emrezeytinoglu/Zeta Audio Effect Box/delay.scd".standardizePath.load;
    "/Users/emrezeytinoglu/Zeta Audio Effect Box/freqshifter.scd".standardizePath.load;
	"/Users/emrezeytinoglu/Zeta Audio Effect Box/whitenoise.scd".standardizePath.load;

    s.sync;

    ~src = Synth(\player, [\out, ~inputBus, \gain, 0.2]);

    ~dry = Synth(\dryOut, [\inBus, ~inputBus, \out, ~fxBus.index], addAction: \addToTail);
    ~reverb = Synth(\jpverbReverb, [\inBus, ~inputBus, \out, ~fxBus.index], addAction: \addToTail);
    ~delay = Synth(\gridDelayFX, [\inBus, ~inputBus, \out, ~fxBus.index], addAction: \addToTail);
    ~pitchshifter = Synth(\pitchShiftFX, [\inBus, ~inputBus, \out, ~fxBus.index], addAction: \addToTail);
	~noise = Synth(\whiteNoiseFX, [\inBus, ~inputBus, \out, ~fxBus.index], addAction: \addToTail);

    ~limiter = Synth(\masterLimiter, [\inBus, ~fxBus.index, \out, 0], addAction: \addToTail);

    "[FX Sistemi Başlatıldı]".postln;
};
)

s.meter;