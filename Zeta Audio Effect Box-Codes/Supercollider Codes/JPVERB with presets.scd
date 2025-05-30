(

var w, presetMenu;


~reverbPresetActive = false;


SynthDef(\jpverbReverb, {
    arg inBus=0, out=0, mix=0.4, decay=3.0, earlyRef=0.3, length=1.0;
    var input, reverbSig, dry, wet, output;

    input = In.ar(inBus, 2);
    reverbSig = JPverb.ar(input, t60: decay, earlyDiff: earlyRef, size: length);
    dry = input * (1 - mix);
    wet = reverbSig * mix;
    output = dry + wet;
    Out.ar(out, output);
}).add;


~jpverbPresets = (
    "Room":      (mix: 0.3, decay: 2.0, length: 0.6, earlyRef: 0.5),
    "Hall":      (mix: 0.6, decay: 4.5, length: 0.9, earlyRef: 0.7),
    "Cathedral": (mix: 0.8, decay: 7.0, length: 1.0, earlyRef: 0.9),
    "Tight":     (mix: 0.2, decay: 1.0, length: 0.4, earlyRef: 0.3)
);


~applyJPVerbPreset = { |presetName|
    var p = ~jpverbPresets[presetName];
    if (p.notNil) {
        ~reverbPresetActive = true;
        "Applying preset: %".format(presetName).postln;
        ~revIn = p[\mix];
        ~reverb.set(\mix, ~revIn);
        ~reverb.set(\decay, p[\decay]);
        ~reverb.set(\length, p[\length]);
        ~reverb.set(\earlyRef, p[\earlyRef]);
        ~normalizeMixes.();
    } {
        "Preset not found: %".format(presetName).warn;
    }
};


w = Window("JPverb Reverb FX", Rect(100, 100, 300, 250)).front;

EZSlider(w, Rect(20, 20, 260, 20), "Dry/Wet", ControlSpec(0, 1, \lin, 0.01), {
    |v|
    if (~reverbPresetActive.not) {
        ~revIn = v.value;
        ~normalizeMixes.();
    };
}, ~revIn);

EZSlider(w, Rect(20, 60, 260, 20), "Decay (air)", ControlSpec(0.1, 10.0, \exp, 0.01), {
    |v| ~reverb.set(\decay, v.value);
}, 3.0);

EZSlider(w, Rect(20, 100, 260, 20), "Early Reflections", ControlSpec(0.0, 1.0, \lin, 0.01), {
    |v| ~reverb.set(\earlyRef, v.value);
}, 0.3);

EZSlider(w, Rect(20, 140, 260, 20), "Length", ControlSpec(0.1, 2.0, \lin, 0.01), {
    |v| ~reverb.set(\length, v.value);
}, 1.0);

StaticText(w, Rect(20, 180, 100, 20)).string = "Presets:";

presetMenu = PopUpMenu(w, Rect(130, 180, 140, 20));
presetMenu.items = ~jpverbPresets.keys.asArray;
presetMenu.action = {
    var selected = presetMenu.items[presetMenu.value];
    ~applyJPVerbPreset.(selected);
};
presetMenu.value = 0;


OSCdef(\presetTrigger, { |msg|
    var preset = msg[1].asString;
    ~applyJPVerbPreset.value(preset);
}, '/jpverb/preset');

OSCdef(\dryWet, { |msg|
    if (~reverbPresetActive.not) {
        ~revIn = msg[1].asFloat;
        ~normalizeMixes.();
    };
}, '/dryWet');

OSCdef(\character, { |msg| ~reverb.set(\earlyRef, msg[1].asFloat); }, '/character');
OSCdef(\length, { |msg| ~reverb.set(\length, msg[1].asFloat); }, '/length');
OSCdef(\air, { |msg| ~reverb.set(\decay, msg[1].asFloat); }, '/air');
)
