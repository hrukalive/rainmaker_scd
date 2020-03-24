/************************************************************************

Intellijel Rainmaker Sim
by hrukalive

************************************************************************/

/************************************************************************
    1. Start the server
************************************************************************/
(
Server.default.options.numWireBufs = 1024;
Server.default.options.memSize = 16384 * 32;
s.boot;
)

/************************************************************************
    2. Define functions and SynthDefs
************************************************************************/
(
// Filter coefficients calculation for FOS and SOS
~lpf_1st_coeff = {
	arg fc, fs;
	var wc, denom, a, b;
	wc = (fc / fs * pi).tan;
	denom = 1 + wc;
	a = wc / denom;
	b = (1 - wc) / denom;
	[a, a, b];
};

~hpf_1st_coeff = {
	arg fc, fs;
	var wc, denom, a, b;
	wc = (fc / fs * pi).tan;
	denom = 1 + wc;
	a = 1 / denom;
	b = (1 - wc) / denom;
	[a, a.neg, b];
};

~lpf_2nd_coeff = {
	arg fc, fs, q;
	var wc, wc2, wcq, denom, a, b1, b2;
	wc = (fc / fs * pi).tan;
	wc2 = wc * wc;
	wcq = wc / q;
	denom = 1 + wcq + wc2;
	a = wc2 / denom;
	b1 = (2 * (1 - wc2)) / denom;
	b2 = (wcq - 1 - wc2) / denom;
	[a, 2 * a, a, b1, b2];
};

~hpf_2nd_coeff = {
	arg fc, fs, q;
	var wc, wc2, wcq, denom, a, b1, b2;
	wc = (fc / fs * pi).tan;
	wc2 = wc * wc;
	wcq = wc / q;
	denom = 1 + wcq + wc2;
	a = 1 / denom;
	b1 = (2 * (1 - wc2)) / denom;
	b2 = (wcq - 1 - wc2) / denom;
	[a, -2 * a, a, b1, b2];
};

~bpf_2nd_coeff = {
	arg fc, fs, q;
	var wc, wc2, wcq, denom, a, b1, b2;
	wc = (fc / fs * pi).tan;
	wc2 = wc * wc;
	wcq = wc / q;
	denom = 1 + wcq + wc2;
	a = wcq / denom;
	b1 = (2 * (1 - wc2)) / denom;
	b2 = (wcq - 1 - wc2) / denom;
	[a, 0, a.neg, b1, b2];
};

SynthDef.new(\rhythmic_delay_section, {
	arg input_bus, output_bus = 0,
	tap_delay_01 = 0.0312, tap_delay_02 = 0.0625, tap_delay_03 = 0.0938, tap_delay_04 = 0.1250,
	tap_delay_05 = 0.1562, tap_delay_06 = 0.1875, tap_delay_07 = 0.2188, tap_delay_08 = 0.2500,
	tap_delay_09 = 0.2812, tap_delay_10 = 0.3125, tap_delay_11 = 0.3438, tap_delay_12 = 0.3750,
	tap_delay_13 = 0.4062, tap_delay_14 = 0.4375, tap_delay_15 = 0.4688, tap_delay_16 = 0.5000,
	tap_gate_01 = 1, tap_gate_02 = 1, tap_gate_03 = 1, tap_gate_04 = 1,
	tap_gate_05 = 1, tap_gate_06 = 1, tap_gate_07 = 1, tap_gate_08 = 1,
	tap_gate_09 = 1, tap_gate_10 = 1, tap_gate_11 = 1, tap_gate_12 = 1,
	tap_gate_13 = 1, tap_gate_14 = 1, tap_gate_15 = 1, tap_gate_16 = 1,
	tap_level_01 = 0, tap_level_02 = 0, tap_level_03 = 0, tap_level_04 = 0,
	tap_level_05 = 0, tap_level_06 = 0, tap_level_07 = 0, tap_level_08 = 0,
	tap_level_09 = 0, tap_level_10 = 0, tap_level_11 = 0, tap_level_12 = 0,
	tap_level_13 = 0, tap_level_14 = 0, tap_level_15 = 0, tap_level_16 = 0,
	tap_pan_01 = 0, tap_pan_02 = 0, tap_pan_03 = 0, tap_pan_04 = 0,
	tap_pan_05 = 0, tap_pan_06 = 0, tap_pan_07 = 0, tap_pan_08 = 0,
	tap_pan_09 = 0, tap_pan_10 = 0, tap_pan_11 = 0, tap_pan_12 = 0,
	tap_pan_13 = 0, tap_pan_14 = 0, tap_pan_15 = 0, tap_pan_16 = 0,
	tap_coeff_a0_01 = 1, tap_coeff_a0_02 = 1, tap_coeff_a0_03 = 1, tap_coeff_a0_04 = 1,
	tap_coeff_a0_05 = 1, tap_coeff_a0_06 = 1, tap_coeff_a0_07 = 1, tap_coeff_a0_08 = 1,
	tap_coeff_a0_09 = 1, tap_coeff_a0_10 = 1, tap_coeff_a0_11 = 1, tap_coeff_a0_12 = 1,
	tap_coeff_a0_13 = 1, tap_coeff_a0_14 = 1, tap_coeff_a0_15 = 1, tap_coeff_a0_16 = 1,
	tap_coeff_a1_01 = -2, tap_coeff_a1_02 = -2, tap_coeff_a1_03 = -2, tap_coeff_a1_04 = -2,
	tap_coeff_a1_05 = -2, tap_coeff_a1_06 = -2, tap_coeff_a1_07 = -2, tap_coeff_a1_08 = -2,
	tap_coeff_a1_09 = -2, tap_coeff_a1_10 = -2, tap_coeff_a1_11 = -2, tap_coeff_a1_12 = -2,
	tap_coeff_a1_13 = -2, tap_coeff_a1_14 = -2, tap_coeff_a1_15 = -2, tap_coeff_a1_16 = -2,
	tap_coeff_a2_01 = 1, tap_coeff_a2_02 = 1, tap_coeff_a2_03 = 1, tap_coeff_a2_04 = 1,
	tap_coeff_a2_05 = 1, tap_coeff_a2_06 = 1, tap_coeff_a2_07 = 1, tap_coeff_a2_08 = 1,
	tap_coeff_a2_09 = 1, tap_coeff_a2_10 = 1, tap_coeff_a2_11 = 1, tap_coeff_a2_12 = 1,
	tap_coeff_a2_13 = 1, tap_coeff_a2_14 = 1, tap_coeff_a2_15 = 1, tap_coeff_a2_16 = 1,
	tap_coeff_b1_01 = 2, tap_coeff_b1_02 = 2, tap_coeff_b1_03 = 2, tap_coeff_b1_04 = 2,
	tap_coeff_b1_05 = 2, tap_coeff_b1_06 = 2, tap_coeff_b1_07 = 2, tap_coeff_b1_08 = 2,
	tap_coeff_b1_09 = 2, tap_coeff_b1_10 = 2, tap_coeff_b1_11 = 2, tap_coeff_b1_12 = 2,
	tap_coeff_b1_13 = 2, tap_coeff_b1_14 = 2, tap_coeff_b1_15 = 2, tap_coeff_b1_16 = 2,
	tap_coeff_b2_01 = -1, tap_coeff_b2_02 = -1, tap_coeff_b2_03 = -1, tap_coeff_b2_04 = -1,
	tap_coeff_b2_05 = -1, tap_coeff_b2_06 = -1, tap_coeff_b2_07 = -1, tap_coeff_b2_08 = -1,
	tap_coeff_b2_09 = -1, tap_coeff_b2_10 = -1, tap_coeff_b2_11 = -1, tap_coeff_b2_12 = -1,
	tap_coeff_b2_13 = -1, tap_coeff_b2_14 = -1, tap_coeff_b2_15 = -1, tap_coeff_b2_16 = -1,
	tap_pitchshift_01 = 0, tap_pitchshift_02 = 0, tap_pitchshift_03 = 0, tap_pitchshift_04 = 0,
	tap_pitchshift_05 = 0, tap_pitchshift_06 = 0, tap_pitchshift_07 = 0, tap_pitchshift_08 = 0,
	tap_pitchshift_09 = 0, tap_pitchshift_10 = 0, tap_pitchshift_11 = 0, tap_pitchshift_12 = 0,
	tap_pitchshift_13 = 0, tap_pitchshift_14 = 0, tap_pitchshift_15 = 0, tap_pitchshift_16 = 0,
	fb_tap_index_l = 7, fb_pitch_shift_l = 0, fb_tap_index_r = 7, fb_pitch_shift_r = 0, fb_pingpong = 0, max_delay_time = 20,
	grain_quantity = 2, grain_winenv = -1, grain_size = 0.1, slip = 0, mod_index = 0, mod_level = 0, mod_rate = 1, tap_rev = 0, t_rev_change = 1,
	global_fb = 0.9, global_pitch_shift = 0, global_coeff_a0 = 1, global_coeff_a1 = -1, global_coeff_b1 = 1, global_mix = 0.5;

	var tap_delays = [tap_delay_01, tap_delay_02, tap_delay_03, tap_delay_04, tap_delay_05, tap_delay_06, tap_delay_07, tap_delay_08, tap_delay_09, tap_delay_10, tap_delay_11, tap_delay_12, tap_delay_13, tap_delay_14, tap_delay_15, tap_delay_16];
	var tap_gate = [tap_gate_01, tap_gate_02, tap_gate_03, tap_gate_04, tap_gate_05, tap_gate_06, tap_gate_07, tap_gate_08, tap_gate_09, tap_gate_10, tap_gate_11, tap_gate_12, tap_gate_13, tap_gate_14, tap_gate_15, tap_gate_16];
	var tap_level = [tap_level_01, tap_level_02, tap_level_03, tap_level_04, tap_level_05, tap_level_06, tap_level_07, tap_level_08, tap_level_09, tap_level_10, tap_level_11, tap_level_12, tap_level_13, tap_level_14, tap_level_15, tap_level_16];
	var tap_pan = [tap_pan_01, tap_pan_02, tap_pan_03, tap_pan_04, tap_pan_05, tap_pan_06, tap_pan_07, tap_pan_08, tap_pan_09, tap_pan_10, tap_pan_11, tap_pan_12, tap_pan_13, tap_pan_14, tap_pan_15, tap_pan_16];
	var tap_coeff = [
		tap_coeff_a0_01, tap_coeff_a1_01, tap_coeff_a2_01, tap_coeff_b1_01, tap_coeff_b2_01,
		tap_coeff_a0_02, tap_coeff_a1_02, tap_coeff_a2_02, tap_coeff_b1_02, tap_coeff_b2_02,
		tap_coeff_a0_03, tap_coeff_a1_03, tap_coeff_a2_03, tap_coeff_b1_03, tap_coeff_b2_03,
		tap_coeff_a0_04, tap_coeff_a1_04, tap_coeff_a2_04, tap_coeff_b1_04, tap_coeff_b2_04,
		tap_coeff_a0_05, tap_coeff_a1_05, tap_coeff_a2_05, tap_coeff_b1_05, tap_coeff_b2_05,
		tap_coeff_a0_06, tap_coeff_a1_06, tap_coeff_a2_06, tap_coeff_b1_06, tap_coeff_b2_06,
		tap_coeff_a0_07, tap_coeff_a1_07, tap_coeff_a2_07, tap_coeff_b1_07, tap_coeff_b2_07,
		tap_coeff_a0_08, tap_coeff_a1_08, tap_coeff_a2_08, tap_coeff_b1_08, tap_coeff_b2_08,
		tap_coeff_a0_09, tap_coeff_a1_09, tap_coeff_a2_09, tap_coeff_b1_09, tap_coeff_b2_09,
		tap_coeff_a0_10, tap_coeff_a1_10, tap_coeff_a2_10, tap_coeff_b1_10, tap_coeff_b2_10,
		tap_coeff_a0_11, tap_coeff_a1_11, tap_coeff_a2_11, tap_coeff_b1_11, tap_coeff_b2_11,
		tap_coeff_a0_12, tap_coeff_a1_12, tap_coeff_a2_12, tap_coeff_b1_12, tap_coeff_b2_12,
		tap_coeff_a0_13, tap_coeff_a1_13, tap_coeff_a2_13, tap_coeff_b1_13, tap_coeff_b2_13,
		tap_coeff_a0_14, tap_coeff_a1_14, tap_coeff_a2_14, tap_coeff_b1_14, tap_coeff_b2_14,
		tap_coeff_a0_15, tap_coeff_a1_15, tap_coeff_a2_15, tap_coeff_b1_15, tap_coeff_b2_15,
		tap_coeff_a0_16, tap_coeff_a1_16, tap_coeff_a2_16, tap_coeff_b1_16, tap_coeff_b2_16];
	var tap_pitchshift = [tap_pitchshift_01, tap_pitchshift_02, tap_pitchshift_03, tap_pitchshift_04, tap_pitchshift_05, tap_pitchshift_06, tap_pitchshift_07, tap_pitchshift_08, tap_pitchshift_09, tap_pitchshift_10, tap_pitchshift_11, tap_pitchshift_12, tap_pitchshift_13, tap_pitchshift_14, tap_pitchshift_15, tap_pitchshift_16];
	var global_coeff = [global_coeff_a0, global_coeff_a1, global_coeff_b1];
	var localbus, localbus_r, input_sig, tap_fb_l, tap_fb_r, tap_out, main_clks, tap_clks, delay_frames, used_buffer_size;
	var record_heads, read_heads, fb_read_heads, fb_read_head_l, fb_read_head_r, local_bufs_l, local_bufs_r, max_buffer_size;
	var mod_sources = [
		SinOsc.ar(mod_rate, mul: mod_level * 0.05),
		VarSaw.ar(mod_rate, mul: mod_level * 0.05),
		LFNoise1.ar(mod_rate, mul: mod_level * 0.05),
	];

    localbus = LocalIn.ar(2);
	input_sig = In.ar(input_bus, 2);

	// Local buffers for delays
	max_buffer_size = (SampleRate.ir * max_delay_time * 4).ceil;
	local_bufs_l = Array.fill(16, {LocalBuf(max_buffer_size, 1).clear});
	local_bufs_r = Array.fill(16, {LocalBuf(max_buffer_size, 1).clear});

	delay_frames = Array.fill(16, {
		arg i;
		(SampleRate.ir * tap_delays[i]).floor;
	});
	used_buffer_size = Array.fill(16, {
		arg i;
		(4 * delay_frames[i]);
	});

	// Main clocks that ramps up
	main_clks = Array.fill(16, {
		arg i;
		Phasor.ar(t_rev_change, 1, 0, used_buffer_size[i]);
	});
	// Sub clocks that ramps up for each delay cycle
	tap_clks = Array.fill(16, {
		arg i;
		Phasor.ar(t_rev_change, (1 - tap_rev) - tap_rev, delay_frames[i].neg * (1 - tap_rev), delay_frames[i].neg * tap_rev);
	});

	// Calculate recording and reading heads
	record_heads = Array.fill(16, {
		arg i;
		(((main_clks[i] / delay_frames[i]).floor + 1) * delay_frames[i]) + tap_clks[i];
	});
	read_heads = Array.fill(16, {
		arg i;
		(main_clks[i] - (delay_frames[i] + (Select.ar(mod_index, mod_sources) * SampleRate.ir).floor).abs).mod(used_buffer_size[i]) / max_buffer_size;
	});
	fb_read_heads = Array.fill(16, {
		arg i;
		(main_clks[i] - ((delay_frames[i] + (Select.ar(mod_index, mod_sources) * SampleRate.ir).floor) * slip).abs).mod(used_buffer_size[i]) / max_buffer_size;
	});

	fb_read_head_l = Select.ar(fb_tap_index_l, fb_read_heads);
	fb_read_head_r = Select.ar(fb_tap_index_r, fb_read_heads);

	// Record into buffer
	(0..15).do({
		arg i;
		BufWr.ar(input_sig[0] + localbus[0], local_bufs_l[i], record_heads[i]);
		BufWr.ar(input_sig[1] + localbus[1], local_bufs_r[i], record_heads[i]);
	});

	// Signals to feedback
	tap_fb_l =
		FOS.ar(
			LeakDC.ar(GrainBuf.ar(
				numChannels: 1,
				trigger: Impulse.kr((grain_quantity * fb_pitch_shift_l.midiratio) / grain_size),
				dur: (grain_size / fb_pitch_shift_l.midiratio),
			    sndbuf: Select.kr(fb_tap_index_l, local_bufs_l),
				rate: fb_pitch_shift_l.midiratio,
				pos: fb_read_head_l,
				interp: 4,
				pan: 0,
				envbufnum: grain_winenv,
				maxGrains: 32)),
			global_coeff[0],
			global_coeff[1],
			global_coeff[2],
			mul: global_fb
		);

	tap_fb_r =
		FOS.ar(
			LeakDC.ar(GrainBuf.ar(
				numChannels: 1,
				trigger: Impulse.kr((grain_quantity * fb_pitch_shift_r.midiratio) / grain_size),
				dur: (grain_size / fb_pitch_shift_r.midiratio),
			    sndbuf: Select.kr(fb_tap_index_r, local_bufs_r),
				rate: fb_pitch_shift_r.midiratio,
				pos: fb_read_head_r,
				interp: 4,
				pan: 0,
				envbufnum: grain_winenv,
			    maxGrains: 32)),
			global_coeff[0],
			global_coeff[1],
			global_coeff[2],
			mul: global_fb
		);

	// All 16 taps delays
	tap_out = Array.fill(16, {
		arg i;
		SOS.ar(
			Balance2.ar(LeakDC.ar(GrainBuf.ar(
					numChannels: 1,
					trigger: Impulse.kr((grain_quantity * (tap_pitchshift[i] + global_pitch_shift).midiratio) / grain_size),
					dur: (grain_size / (tap_pitchshift[i] + global_pitch_shift).midiratio),
				    sndbuf: local_bufs_l[i],
					rate: (tap_pitchshift[i] + global_pitch_shift).midiratio,
					pos: read_heads[i],
					interp: 4,
					pan: 0,
					envbufnum: grain_winenv,
					maxGrains: 32)),
				LeakDC.ar(GrainBuf.ar(
					numChannels: 1,
					trigger: Impulse.kr((grain_quantity * (tap_pitchshift[i] + global_pitch_shift).midiratio) / grain_size),
					dur: (grain_size / (tap_pitchshift[i] + global_pitch_shift).midiratio),
				    sndbuf: local_bufs_r[i],
					rate: (tap_pitchshift[i] + global_pitch_shift).midiratio,
					pos: read_heads[i],
					interp: 4,
					pan: 0,
					envbufnum: grain_winenv,
				maxGrains: 32)), tap_pan[i]),
			tap_coeff[5 * i + 0],
			tap_coeff[5 * i + 1],
			tap_coeff[5 * i + 2],
			tap_coeff[5 * i + 3],
			tap_coeff[5 * i + 4],
			mul: tap_level[i] * tap_gate[i]
		);
	});

	// Feedback to local bus
	LocalOut.ar(Splay.ar([(tap_fb_l * (1 - fb_pingpong)) + (tap_fb_r * fb_pingpong), (tap_fb_l * fb_pingpong) + (tap_fb_r * (1 - fb_pingpong))]));
	Out.ar(output_bus, (input_sig * (1 - global_mix)) + (tap_out.sum * global_mix));
}).add;

SynthDef.new(\rhythmic_comb_filter_section, {
	arg input_bus, output_bus = 0,
	tap_delay_01 = 0.0057, tap_delay_02 = 0.0064, tap_delay_03 = 0.0071, tap_delay_04 = 0.0078, tap_delay_05 = 0.0085, tap_delay_06 = 0.0092, tap_delay_07 = 0.0099, tap_delay_08 = 0.0106,
	tap_delay_09 = 0.0113, tap_delay_10 = 0.0120, tap_delay_11 = 0.0127, tap_delay_12 = 0.0134, tap_delay_13 = 0.0141, tap_delay_14 = 0.0148, tap_delay_15 = 0.0155, tap_delay_16 = 0.0163,
	tap_delay_17 = 0.0170, tap_delay_18 = 0.0177, tap_delay_19 = 0.0184, tap_delay_20 = 0.0191, tap_delay_21 = 0.0198, tap_delay_22 = 0.0205, tap_delay_23 = 0.0212, tap_delay_24 = 0.0219,
	tap_delay_25 = 0.0226, tap_delay_26 = 0.0233, tap_delay_27 = 0.0240, tap_delay_28 = 0.0247, tap_delay_29 = 0.0254, tap_delay_30 = 0.0261, tap_delay_31 = 0.0268, tap_delay_32 = 0.0275,
	tap_delay_33 = 0.0282, tap_delay_34 = 0.0289, tap_delay_35 = 0.0296, tap_delay_36 = 0.0303, tap_delay_37 = 0.0310, tap_delay_38 = 0.0317, tap_delay_39 = 0.0324, tap_delay_40 = 0.0331,
	tap_delay_41 = 0.0338, tap_delay_42 = 0.0345, tap_delay_43 = 0.0352, tap_delay_44 = 0.0359, tap_delay_45 = 0.0366, tap_delay_46 = 0.0373, tap_delay_47 = 0.0380, tap_delay_48 = 0.0387,
	tap_delay_49 = 0.0395, tap_delay_50 = 0.0402, tap_delay_51 = 0.0409, tap_delay_52 = 0.0416, tap_delay_53 = 0.0423, tap_delay_54 = 0.0430, tap_delay_55 = 0.0437, tap_delay_56 = 0.0444,
	tap_delay_57 = 0.0451, tap_delay_58 = 0.0458, tap_delay_59 = 0.0465, tap_delay_60 = 0.0472, tap_delay_61 = 0.0479, tap_delay_62 = 0.0486, tap_delay_63 = 0.0493, tap_delay_64 = 0.0500,
	selection_01 = 1, selection_02 = 1, selection_03 = 1, selection_04 = 1, selection_05 = 1, selection_06 = 1, selection_07 = 1, selection_08 = 1,
	selection_09 = 1, selection_10 = 1, selection_11 = 1, selection_12 = 1, selection_13 = 1, selection_14 = 1, selection_15 = 1, selection_16 = 1,
	selection_17 = 1, selection_18 = 1, selection_19 = 1, selection_20 = 1, selection_21 = 1, selection_22 = 1, selection_23 = 1, selection_24 = 1,
	selection_25 = 1, selection_26 = 1, selection_27 = 1, selection_28 = 1, selection_29 = 1, selection_30 = 1, selection_31 = 1, selection_32 = 1,
	selection_33 = 1, selection_34 = 1, selection_35 = 1, selection_36 = 1, selection_37 = 1, selection_38 = 1, selection_39 = 1, selection_40 = 1,
	selection_41 = 1, selection_42 = 1, selection_43 = 1, selection_44 = 1, selection_45 = 1, selection_46 = 1, selection_47 = 1, selection_48 = 1,
	selection_49 = 1, selection_50 = 1, selection_51 = 1, selection_52 = 1, selection_53 = 1, selection_54 = 1, selection_55 = 1, selection_56 = 1,
	selection_57 = 1, selection_58 = 1, selection_59 = 1, selection_60 = 1, selection_61 = 1, selection_62 = 1, selection_63 = 1, selection_64 = 1,
	slope_01 = 0.0156, slope_02 = 0.0156, slope_03 = 0.0156, slope_04 = 0.0156, slope_05 = 0.0156, slope_06 = 0.0156, slope_07 = 0.0156, slope_08 = 0.0156,
	slope_09 = 0.0156, slope_10 = 0.0156, slope_11 = 0.0156, slope_12 = 0.0156, slope_13 = 0.0156, slope_14 = 0.0156, slope_15 = 0.0156, slope_16 = 0.0156,
	slope_17 = 0.0156, slope_18 = 0.0156, slope_19 = 0.0156, slope_20 = 0.0156, slope_21 = 0.0156, slope_22 = 0.0156, slope_23 = 0.0156, slope_24 = 0.0156,
	slope_25 = 0.0156, slope_26 = 0.0156, slope_27 = 0.0156, slope_28 = 0.0156, slope_29 = 0.0156, slope_30 = 0.0156, slope_31 = 0.0156, slope_32 = 0.0156,
	slope_33 = 0.0156, slope_34 = 0.0156, slope_35 = 0.0156, slope_36 = 0.0156, slope_37 = 0.0156, slope_38 = 0.0156, slope_39 = 0.0156, slope_40 = 0.0156,
	slope_41 = 0.0156, slope_42 = 0.0156, slope_43 = 0.0156, slope_44 = 0.0156, slope_45 = 0.0156, slope_46 = 0.0156, slope_47 = 0.0156, slope_48 = 0.0156,
	slope_49 = 0.0156, slope_50 = 0.0156, slope_51 = 0.0156, slope_52 = 0.0156, slope_53 = 0.0156, slope_54 = 0.0156, slope_55 = 0.0156, slope_56 = 0.0156,
	slope_57 = 0.0156, slope_58 = 0.0156, slope_59 = 0.0156, slope_60 = 0.0156, slope_61 = 0.0156, slope_62 = 0.0156, slope_63 = 0.0156, slope_64 = 0.0156,
	filter_alpha = 1, global_fb = 0.5, mod_index = 0, mod_level = 0, mod_rate = 1, amp = 1;

	var tap_delays = [
		tap_delay_01, tap_delay_02, tap_delay_03, tap_delay_04, tap_delay_05, tap_delay_06, tap_delay_07, tap_delay_08,
		tap_delay_09, tap_delay_10, tap_delay_11, tap_delay_12, tap_delay_13, tap_delay_14, tap_delay_15, tap_delay_16,
		tap_delay_17, tap_delay_18, tap_delay_19, tap_delay_20, tap_delay_21, tap_delay_22, tap_delay_23, tap_delay_24,
		tap_delay_25, tap_delay_26, tap_delay_27, tap_delay_28, tap_delay_29, tap_delay_30, tap_delay_31, tap_delay_32,
		tap_delay_33, tap_delay_34, tap_delay_35, tap_delay_36, tap_delay_37, tap_delay_38, tap_delay_39, tap_delay_40,
		tap_delay_41, tap_delay_42, tap_delay_43, tap_delay_44, tap_delay_45, tap_delay_46, tap_delay_47, tap_delay_48,
		tap_delay_49, tap_delay_50, tap_delay_51, tap_delay_52, tap_delay_53, tap_delay_54, tap_delay_55, tap_delay_56,
		tap_delay_57, tap_delay_58, tap_delay_59, tap_delay_60, tap_delay_61, tap_delay_62, tap_delay_63, tap_delay_64];
	var selections = [
		selection_01, selection_02, selection_03, selection_04, selection_05, selection_06, selection_07, selection_08,
		selection_09, selection_10, selection_11, selection_12, selection_13, selection_14, selection_15, selection_16,
		selection_17, selection_18, selection_19, selection_20, selection_21, selection_22, selection_23, selection_24,
		selection_25, selection_26, selection_27, selection_28, selection_29, selection_30, selection_31, selection_32,
		selection_33, selection_34, selection_35, selection_36, selection_37, selection_38, selection_39, selection_40,
		selection_41, selection_42, selection_43, selection_44, selection_45, selection_46, selection_47, selection_48,
		selection_49, selection_50, selection_51, selection_52, selection_53, selection_54, selection_55, selection_56,
		selection_57, selection_58, selection_59, selection_60, selection_61, selection_62, selection_63, selection_64];
	var slopes = [
		slope_01, slope_02, slope_03, slope_04, slope_05, slope_06, slope_07, slope_08,
		slope_09, slope_10, slope_11, slope_12, slope_13, slope_14, slope_15, slope_16,
		slope_17, slope_18, slope_19, slope_20, slope_21, slope_22, slope_23, slope_24,
		slope_25, slope_26, slope_27, slope_28, slope_29, slope_30, slope_31, slope_32,
		slope_33, slope_34, slope_35, slope_36, slope_37, slope_38, slope_39, slope_40,
		slope_41, slope_42, slope_43, slope_44, slope_45, slope_46, slope_47, slope_48,
		slope_49, slope_50, slope_51, slope_52, slope_53, slope_54, slope_55, slope_56,
		slope_57, slope_58, slope_59, slope_60, slope_61, slope_62, slope_63, slope_64];
	var mod_sources = [
		SinOsc.kr(mod_rate, mul: mod_level * 0.05),
		VarSaw.kr(mod_rate, mul: mod_level * 0.05),
		LFNoise1.kr(mod_rate, mul: mod_level * 0.05),
	];
	var localbus, input_sig, taps;

	localbus = LocalIn.ar(2);
	input_sig = In.ar(input_bus, 2);

	// 64 Taps that has very short delays to create comb filters
	taps = Array.fill(64, {
		arg i;
		LeakDC.ar(DelayC.ar(input_sig + localbus, tap_delays[i] + 0.15, (tap_delays[i] - Select.kr(mod_index, mod_sources) - ControlDur.ir).abs));
	});

	LocalOut.ar((filter_alpha * taps[63] * global_fb) + ((1 - filter_alpha) * localbus));

	Out.ar(output_bus, amp * (input_sig + localbus + (slopes * selections * taps).sum));

}).add;
)

/************************************************************************
    3. Create buses, groups, synths, and initiate GUI
       (not quite readable, scaffold generated by Python)
************************************************************************/
(
~rain_maker_bus = Bus.audio(s, 2);
~rain_maker_tmp_bus = Bus.audio(s, 2);
~rain_maker_out_bus = 0;
~rain_maker_grp = Group.tail;
~rain_maker_delay_synth = Synth(\rhythmic_delay_section, [\input_bus, ~rain_maker_bus, \output_bus, ~rain_maker_out_bus], ~rain_maker_grp);
~rain_maker_comb_synth = Synth(\rhythmic_comb_filter_section, [\input_bus, ~rain_maker_bus, \output_bus, ~rain_maker_tmp_bus], ~rain_maker_grp, \addToTail);

~rain_maker_gui = {
	var label_static_texts = Dictionary.with(*[\d_grid_label->StaticText().align_(\center).string_("Grid"), \d_stack_label->StaticText().align_(\center).string_("Stack"), \d_time_label->StaticText().align_(\center).string_("Time"), \d_time_clk_label->StaticText().align_(\center).string_("Tempo"), \d_div_label->StaticText().align_(\center).string_("Div"), \d_grain_quantity_label->StaticText().align_(\center).string_("GQuantity"), \d_grain_size_label->StaticText().align_(\center).string_("GSize"), \d_global_ps_label->StaticText().align_(\center).string_("Pitch Shift"), \d_feedback_label->StaticText().align_(\center).string_("Feedback"), \d_fb_tone_label->StaticText().align_(\center).string_("FB Tone"), \d_fb_tap_l_label->StaticText().align_(\center).string_("FB Tap L"), \d_fb_tap_r_label->StaticText().align_(\center).string_("FB Tap R"), \d_fb_ps_l_label->StaticText().align_(\center).string_("FB PS L"), \d_fb_ps_r_label->StaticText().align_(\center).string_("FB PS R"), \d_slip_label->StaticText().align_(\center).string_("FB Slip"), \d_groove_label->StaticText().align_(\center).string_("Groove"), \d_gveamt_label->StaticText().align_(\center).string_("GveAmt"), \d_mod_wave_label->StaticText().align_(\center).string_("Mod Wave"), \d_mod_level_label->StaticText().align_(\center).string_("Mod Level"), \d_mod_rate_label->StaticText().align_(\center).string_("Mod Rate"), \c_patt_label->StaticText().align_(\center).string_("Patt"), \c_slope_label->StaticText().align_(\center).string_("Slope"), \c_div_label->StaticText().align_(\center).string_("Div"), \c_feedback_label->StaticText().align_(\center).string_("Feedback"), \c_combsize_label->StaticText().align_(\center).string_("CombSize"), \c_combsize_clk_label->StaticText().align_(\center).string_("Tempo"), \c_mod_wave_label->StaticText().align_(\center).string_("Mod Wave"), \c_mod_level_label->StaticText().align_(\center).string_("Mod Level"), \c_mod_rate_label->StaticText().align_(\center).string_("Mod Rate"), \c_fb_num_label->StaticText().align_(\center).string_("Taps+FB"), \g_routing_label->StaticText().align_(\center).string_("Routing"), \g_mix_label->StaticText().align_(\center).string_("Mix"), \g_tempo_label->StaticText().align_(\center).string_("Tempo"), \d_tap_1_mute_label->StaticText().align_(\center).string_("Mute"), \d_tap_1_pan_label->StaticText().align_(\center).string_("Pan"), \d_tap_1_flttype_label->StaticText().align_(\center).string_("Flt Type"), \d_tap_1_fltcut_label->StaticText().align_(\center).string_("Flt Cut"), \d_tap_1_fltq_label->StaticText().align_(\center).string_("Flt Q"), \d_tap_1_ps_label->StaticText().align_(\center).string_("Pitch Shift"), \d_tap_1_level_label->StaticText().align_(\center).string_("Level"), \c_fb_config_label->StaticText().align_(\center).string_("Feedback Alpha"), \d_pingpong_label->StaticText().align_(\center).string_("Pingpong"), \c_level_label->StaticText().align_(\center).string_("Level"), \d_reverse_label->StaticText().align_(\center).string_("Reverse")]);
	var value_static_texts = Dictionary.with(*[\d_global_ps_static->StaticText().align_(\center), \d_feedback_static->StaticText().align_(\center), \d_fb_tone_static->StaticText().align_(\center), \d_fb_ps_l_static->StaticText().align_(\center), \d_fb_ps_r_static->StaticText().align_(\center), \d_slip_static->StaticText().align_(\center), \d_gveamt_static->StaticText().align_(\center), \d_mod_level_static->StaticText().align_(\center), \c_feedback_static->StaticText().align_(\center), \c_combsize_static->StaticText().align_(\center), \c_mod_level_static->StaticText().align_(\center), \g_mix_static->StaticText().align_(\center), \d_tap_1_pan_static->StaticText().align_(\center), \d_tap_1_fltcut_static->StaticText().align_(\center), \d_tap_1_fltq_static->StaticText().align_(\center), \d_tap_1_ps_static->StaticText().align_(\center), \d_tap_2_pan_static->StaticText().align_(\center), \d_tap_2_fltcut_static->StaticText().align_(\center), \d_tap_2_fltq_static->StaticText().align_(\center), \d_tap_2_ps_static->StaticText().align_(\center), \d_tap_3_pan_static->StaticText().align_(\center), \d_tap_3_fltcut_static->StaticText().align_(\center), \d_tap_3_fltq_static->StaticText().align_(\center), \d_tap_3_ps_static->StaticText().align_(\center), \d_tap_4_pan_static->StaticText().align_(\center), \d_tap_4_fltcut_static->StaticText().align_(\center), \d_tap_4_fltq_static->StaticText().align_(\center), \d_tap_4_ps_static->StaticText().align_(\center), \d_tap_5_pan_static->StaticText().align_(\center), \d_tap_5_fltcut_static->StaticText().align_(\center), \d_tap_5_fltq_static->StaticText().align_(\center), \d_tap_5_ps_static->StaticText().align_(\center), \d_tap_6_pan_static->StaticText().align_(\center), \d_tap_6_fltcut_static->StaticText().align_(\center), \d_tap_6_fltq_static->StaticText().align_(\center), \d_tap_6_ps_static->StaticText().align_(\center), \d_tap_7_pan_static->StaticText().align_(\center), \d_tap_7_fltcut_static->StaticText().align_(\center), \d_tap_7_fltq_static->StaticText().align_(\center), \d_tap_7_ps_static->StaticText().align_(\center), \d_tap_8_pan_static->StaticText().align_(\center), \d_tap_8_fltcut_static->StaticText().align_(\center), \d_tap_8_fltq_static->StaticText().align_(\center), \d_tap_8_ps_static->StaticText().align_(\center), \d_tap_9_pan_static->StaticText().align_(\center), \d_tap_9_fltcut_static->StaticText().align_(\center), \d_tap_9_fltq_static->StaticText().align_(\center), \d_tap_9_ps_static->StaticText().align_(\center), \d_tap_10_pan_static->StaticText().align_(\center), \d_tap_10_fltcut_static->StaticText().align_(\center), \d_tap_10_fltq_static->StaticText().align_(\center), \d_tap_10_ps_static->StaticText().align_(\center), \d_tap_11_pan_static->StaticText().align_(\center), \d_tap_11_fltcut_static->StaticText().align_(\center), \d_tap_11_fltq_static->StaticText().align_(\center), \d_tap_11_ps_static->StaticText().align_(\center), \d_tap_12_pan_static->StaticText().align_(\center), \d_tap_12_fltcut_static->StaticText().align_(\center), \d_tap_12_fltq_static->StaticText().align_(\center), \d_tap_12_ps_static->StaticText().align_(\center), \d_tap_13_pan_static->StaticText().align_(\center), \d_tap_13_fltcut_static->StaticText().align_(\center), \d_tap_13_fltq_static->StaticText().align_(\center), \d_tap_13_ps_static->StaticText().align_(\center), \d_tap_14_pan_static->StaticText().align_(\center), \d_tap_14_fltcut_static->StaticText().align_(\center), \d_tap_14_fltq_static->StaticText().align_(\center), \d_tap_14_ps_static->StaticText().align_(\center), \d_tap_15_pan_static->StaticText().align_(\center), \d_tap_15_fltcut_static->StaticText().align_(\center), \d_tap_15_fltq_static->StaticText().align_(\center), \d_tap_15_ps_static->StaticText().align_(\center), \d_tap_16_pan_static->StaticText().align_(\center), \d_tap_16_fltcut_static->StaticText().align_(\center), \d_tap_16_fltq_static->StaticText().align_(\center), \d_tap_16_ps_static->StaticText().align_(\center), \c_fb_config_static->StaticText().align_(\center), \c_level_static->StaticText().align_(\center)]);
	var widgets = Dictionary.with(*[\d_grid_popupmenu->PopUpMenu(), \d_stack_popupmenu->PopUpMenu(), \d_time_numberbox->NumberBox(), \d_time_clk_checkbox->CheckBox(), \d_div_popupmenu->PopUpMenu(), \d_grain_quantity_popupmenu->PopUpMenu(), \d_grain_size_numberbox->NumberBox(), \d_global_ps_knob->Knob(), \d_feedback_knob->Knob(), \d_fb_tone_knob->Knob(), \d_fb_tap_l_popupmenu->PopUpMenu(), \d_fb_tap_r_popupmenu->PopUpMenu(), \d_fb_ps_l_knob->Knob(), \d_fb_ps_r_knob->Knob(), \d_slip_knob->Knob(), \d_groove_popupmenu->PopUpMenu(), \d_gveamt_knob->Knob(), \d_mod_wave_popupmenu->PopUpMenu(), \d_mod_level_knob->Knob(), \d_mod_rate_numberbox->NumberBox(), \c_patt_popupmenu->PopUpMenu(), \c_slope_popupmenu->PopUpMenu(), \c_div_popupmenu->PopUpMenu(), \c_feedback_knob->Knob(), \c_combsize_knob->Knob(), \c_combsize_clk_checkbox->CheckBox(), \c_mod_wave_popupmenu->PopUpMenu(), \c_mod_level_knob->Knob(), \c_mod_rate_numberbox->NumberBox(), \c_fb_num_numberbox->NumberBox(), \g_routing_popupmenu->PopUpMenu(), \g_mix_knob->Knob(), \g_tempo_numberbox->NumberBox(), \d_tap_1_mute_checkbox->CheckBox(), \d_tap_1_pan_knob->Knob(), \d_tap_1_flttype_popupmenu->PopUpMenu(), \d_tap_1_fltcut_knob->Knob(), \d_tap_1_fltq_knob->Knob(), \d_tap_1_ps_knob->Knob(), \d_tap_1_level_slider->Slider(), \d_tap_2_mute_checkbox->CheckBox(), \d_tap_2_pan_knob->Knob(), \d_tap_2_flttype_popupmenu->PopUpMenu(), \d_tap_2_fltcut_knob->Knob(), \d_tap_2_fltq_knob->Knob(), \d_tap_2_ps_knob->Knob(), \d_tap_2_level_slider->Slider(), \d_tap_3_mute_checkbox->CheckBox(), \d_tap_3_pan_knob->Knob(), \d_tap_3_flttype_popupmenu->PopUpMenu(), \d_tap_3_fltcut_knob->Knob(), \d_tap_3_fltq_knob->Knob(), \d_tap_3_ps_knob->Knob(), \d_tap_3_level_slider->Slider(), \d_tap_4_mute_checkbox->CheckBox(), \d_tap_4_pan_knob->Knob(), \d_tap_4_flttype_popupmenu->PopUpMenu(), \d_tap_4_fltcut_knob->Knob(), \d_tap_4_fltq_knob->Knob(), \d_tap_4_ps_knob->Knob(), \d_tap_4_level_slider->Slider(), \d_tap_5_mute_checkbox->CheckBox(), \d_tap_5_pan_knob->Knob(), \d_tap_5_flttype_popupmenu->PopUpMenu(), \d_tap_5_fltcut_knob->Knob(), \d_tap_5_fltq_knob->Knob(), \d_tap_5_ps_knob->Knob(), \d_tap_5_level_slider->Slider(), \d_tap_6_mute_checkbox->CheckBox(), \d_tap_6_pan_knob->Knob(), \d_tap_6_flttype_popupmenu->PopUpMenu(), \d_tap_6_fltcut_knob->Knob(), \d_tap_6_fltq_knob->Knob(), \d_tap_6_ps_knob->Knob(), \d_tap_6_level_slider->Slider(), \d_tap_7_mute_checkbox->CheckBox(), \d_tap_7_pan_knob->Knob(), \d_tap_7_flttype_popupmenu->PopUpMenu(), \d_tap_7_fltcut_knob->Knob(), \d_tap_7_fltq_knob->Knob(), \d_tap_7_ps_knob->Knob(), \d_tap_7_level_slider->Slider(), \d_tap_8_mute_checkbox->CheckBox(), \d_tap_8_pan_knob->Knob(), \d_tap_8_flttype_popupmenu->PopUpMenu(), \d_tap_8_fltcut_knob->Knob(), \d_tap_8_fltq_knob->Knob(), \d_tap_8_ps_knob->Knob(), \d_tap_8_level_slider->Slider(), \d_tap_9_mute_checkbox->CheckBox(), \d_tap_9_pan_knob->Knob(), \d_tap_9_flttype_popupmenu->PopUpMenu(), \d_tap_9_fltcut_knob->Knob(), \d_tap_9_fltq_knob->Knob(), \d_tap_9_ps_knob->Knob(), \d_tap_9_level_slider->Slider(), \d_tap_10_mute_checkbox->CheckBox(), \d_tap_10_pan_knob->Knob(), \d_tap_10_flttype_popupmenu->PopUpMenu(), \d_tap_10_fltcut_knob->Knob(), \d_tap_10_fltq_knob->Knob(), \d_tap_10_ps_knob->Knob(), \d_tap_10_level_slider->Slider(), \d_tap_11_mute_checkbox->CheckBox(), \d_tap_11_pan_knob->Knob(), \d_tap_11_flttype_popupmenu->PopUpMenu(), \d_tap_11_fltcut_knob->Knob(), \d_tap_11_fltq_knob->Knob(), \d_tap_11_ps_knob->Knob(), \d_tap_11_level_slider->Slider(), \d_tap_12_mute_checkbox->CheckBox(), \d_tap_12_pan_knob->Knob(), \d_tap_12_flttype_popupmenu->PopUpMenu(), \d_tap_12_fltcut_knob->Knob(), \d_tap_12_fltq_knob->Knob(), \d_tap_12_ps_knob->Knob(), \d_tap_12_level_slider->Slider(), \d_tap_13_mute_checkbox->CheckBox(), \d_tap_13_pan_knob->Knob(), \d_tap_13_flttype_popupmenu->PopUpMenu(), \d_tap_13_fltcut_knob->Knob(), \d_tap_13_fltq_knob->Knob(), \d_tap_13_ps_knob->Knob(), \d_tap_13_level_slider->Slider(), \d_tap_14_mute_checkbox->CheckBox(), \d_tap_14_pan_knob->Knob(), \d_tap_14_flttype_popupmenu->PopUpMenu(), \d_tap_14_fltcut_knob->Knob(), \d_tap_14_fltq_knob->Knob(), \d_tap_14_ps_knob->Knob(), \d_tap_14_level_slider->Slider(), \d_tap_15_mute_checkbox->CheckBox(), \d_tap_15_pan_knob->Knob(), \d_tap_15_flttype_popupmenu->PopUpMenu(), \d_tap_15_fltcut_knob->Knob(), \d_tap_15_fltq_knob->Knob(), \d_tap_15_ps_knob->Knob(), \d_tap_15_level_slider->Slider(), \d_tap_16_mute_checkbox->CheckBox(), \d_tap_16_pan_knob->Knob(), \d_tap_16_flttype_popupmenu->PopUpMenu(), \d_tap_16_fltcut_knob->Knob(), \d_tap_16_fltq_knob->Knob(), \d_tap_16_ps_knob->Knob(), \d_tap_16_level_slider->Slider(), \c_fb_config_knob->Knob(), \d_pingpong_checkbox->CheckBox(), \c_level_knob->Knob(), \d_reverse_checkbox->CheckBox()]);
	var control_variables = Dictionary.new;
	var d_control_section = GridLayout();
	var d_tap_section = GridLayout();
	var c_control_section = GridLayout();
	var g_control_section = GridLayout();
	var triangle_window = Buffer.sendCollection(s, Env([0, 1, 0], [0.5, 0.5]).discretize, 1);
	var rect_window = Buffer.sendCollection(s, Env([0, 1, 1, 0], [0.01, 0.98, 0.01]).discretize, 1);

	var win, splitter;
	var groove_patterns = [
		[4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52, 56, 60, 64],
		[5, 8, 13, 16, 21, 24, 29, 32, 37, 40, 45, 48, 53, 56, 61, 64],
		[7, 8, 15, 16, 23, 24, 32, 32, 39, 40, 47, 48, 55, 56, 63, 64],
		[3, 8, 11, 16, 19, 24, 27, 32, 35, 40, 43, 48, 51, 56, 59, 64],
		[5, 8, 12, 16, 21, 24, 28, 32, 37, 40, 44, 48, 53, 56, 60, 64],
		[12, 20, 28, 36, 40, 44, 48, 52, 54, 56, 58, 60, 61, 62, 63, 64],
		[1, 2, 3, 4, 6, 8, 10, 12, 16, 20, 24, 28, 36, 44, 52, 64],
		[5, 11, 13, 16, 21, 27, 29, 32, 37, 43, 45, 48, 53, 59, 61, 64],
		[6, 8, 14, 16, 20, 24, 28, 32, 38, 40, 46, 48, 52, 56, 60, 64],
		[4, 8, 16, 20, 24, 32, 40, 48, 50, 52, 54, 56, 58, 60, 62, 64],
		[7, 10, 13, 16, 19, 26, 29, 32, 39, 42, 45, 48, 51, 58, 61, 64],
		[1, 3, 4, 5, 16, 22, 31, 32, 34, 35, 42, 46, 56, 61, 63, 64],
		[1, 19, 21, 22, 28, 32, 34, 35, 36, 37, 47, 51, 52, 53, 59, 62],
		[3, 8, 9, 23, 29, 30, 31, 34, 35, 50, 51, 52, 55, 56, 58, 64],
		[1, 2, 4, 5, 7, 8, 10, 11, 14, 17, 18, 19, 20, 25, 33, 44],
		[28, 29, 30, 36, 37, 41, 42, 50, 52, 55, 56, 60, 61, 62, 63, 64]
	];
	var comb_tap_patterns = [
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
		[0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1],
		[0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1],
		[0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1],
		[0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1],
		[0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1],
		[0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1],
		[0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1],
		[0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1],
		[0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1],
		[0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1],
		[0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1],
		[0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1],
		[0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1],
		[0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1],
		[0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1],
		[0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1],
		[0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1],
		[0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1],
		[0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1],
		[0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1],
		[0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1],
		[0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1],
		[0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1],
		[0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1],
		[0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
		[0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
		[0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
		[0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
		[0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
		[0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
		[0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
		[0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1],
		[0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1],
		[0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1],
		[0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1],
		[0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1],
		[0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1],
		[0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1],
		[0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1],
		[0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 1],
		[0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1],
		[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1],
		[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1],
		[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1],
		[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1],
		[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1],
		[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1],
		[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1],
		[0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]
	]; // [1, 33, 17, 49, 9, 41, 25, 57, 5, 37, 21, 53, 13, 45, 29, 61, 3, 35, 19, 51, 11, 43, 27, 59, 7, 39, 23, 55, 15, 47, 31, 63, 2, 34, 18, 50, 10, 42, 26, 58, 6, 38, 22, 54, 14, 46, 30, 62, 4, 36, 20, 52, 12, 44, 28, 60, 8, 40, 24, 56, 16, 48, 32]
	var comb_slope_patterns = [
		[0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625, 0.015625],
		[0.0004807692307692308, 0.0009615384615384616, 0.0014423076923076924, 0.0019230769230769232, 0.002403846153846154, 0.0028846153846153848, 0.0033653846153846156, 0.0038461538461538464, 0.004326923076923077, 0.004807692307692308, 0.005288461538461539, 0.0057692307692307696, 0.00625, 0.006730769230769231, 0.007211538461538462, 0.007692307692307693, 0.008173076923076924, 0.008653846153846154, 0.009134615384615385, 0.009615384615384616, 0.010096153846153847, 0.010576923076923078, 0.011057692307692308, 0.011538461538461539, 0.01201923076923077, 0.0125, 0.012980769230769231, 0.013461538461538462, 0.013942307692307693, 0.014423076923076924, 0.014903846153846155, 0.015384615384615385, 0.015865384615384615, 0.016346153846153847, 0.016826923076923076, 0.01730769230769231, 0.017788461538461538, 0.01826923076923077, 0.01875, 0.019230769230769232, 0.01971153846153846, 0.020192307692307693, 0.020673076923076922, 0.021153846153846155, 0.021634615384615384, 0.022115384615384617, 0.022596153846153846, 0.023076923076923078, 0.023557692307692307, 0.02403846153846154, 0.02451923076923077, 0.025, 0.02548076923076923, 0.025961538461538463, 0.026442307692307692, 0.026923076923076925, 0.027403846153846154, 0.027884615384615386, 0.028365384615384615, 0.028846153846153848, 0.029326923076923077, 0.02980769230769231, 0.03028846153846154, 0.03076923076923077],
		[0.03076923076923077, 0.03028846153846154, 0.02980769230769231, 0.029326923076923077, 0.028846153846153848, 0.028365384615384615, 0.027884615384615386, 0.027403846153846154, 0.026923076923076925, 0.026442307692307692, 0.025961538461538463, 0.02548076923076923, 0.025, 0.02451923076923077, 0.02403846153846154, 0.023557692307692307, 0.023076923076923078, 0.022596153846153846, 0.022115384615384617, 0.021634615384615384, 0.021153846153846155, 0.020673076923076922, 0.020192307692307693, 0.01971153846153846, 0.019230769230769232, 0.01875, 0.01826923076923077, 0.017788461538461538, 0.01730769230769231, 0.016826923076923076, 0.016346153846153847, 0.015865384615384615, 0.015384615384615385, 0.014903846153846155, 0.014423076923076924, 0.013942307692307693, 0.013461538461538462, 0.012980769230769231, 0.0125, 0.01201923076923077, 0.011538461538461539, 0.011057692307692308, 0.010576923076923078, 0.010096153846153847, 0.009615384615384616, 0.009134615384615385, 0.008653846153846154, 0.008173076923076924, 0.007692307692307693, 0.007211538461538462, 0.006730769230769231, 0.00625, 0.0057692307692307696, 0.005288461538461539, 0.004807692307692308, 0.004326923076923077, 0.0038461538461538464, 0.0033653846153846156, 0.0028846153846153848, 0.002403846153846154, 0.0019230769230769232, 0.0014423076923076924, 0.0009615384615384616, 0.0004807692307692308],
		[0.000946969696969697, 0.001893939393939394, 0.002840909090909091, 0.003787878787878788, 0.004734848484848485, 0.005681818181818182, 0.006628787878787879, 0.007575757575757576, 0.008522727272727272, 0.00946969696969697, 0.010416666666666666, 0.011363636363636364, 0.01231060606060606, 0.013257575757575758, 0.014204545454545454, 0.015151515151515152, 0.016098484848484848, 0.017045454545454544, 0.017992424242424244, 0.01893939393939394, 0.019886363636363636, 0.020833333333333332, 0.021780303030303032, 0.022727272727272728, 0.023674242424242424, 0.02462121212121212, 0.02556818181818182, 0.026515151515151516, 0.027462121212121212, 0.028409090909090908, 0.029356060606060608, 0.030303030303030304, 0.030303030303030304, 0.029356060606060608, 0.028409090909090908, 0.027462121212121212, 0.026515151515151516, 0.02556818181818182, 0.02462121212121212, 0.023674242424242424, 0.022727272727272728, 0.021780303030303032, 0.020833333333333332, 0.019886363636363636, 0.01893939393939394, 0.017992424242424244, 0.017045454545454544, 0.016098484848484848, 0.015151515151515152, 0.014204545454545454, 0.013257575757575758, 0.01231060606060606, 0.011363636363636364, 0.010416666666666666, 0.00946969696969697, 0.008522727272727272, 0.007575757575757576, 0.006628787878787879, 0.005681818181818182, 0.004734848484848485, 0.003787878787878788, 0.002840909090909091, 0.001893939393939394, 0.000946969696969697]
	];
	var comb_patterns = [
		[0.027879914693498105, 0.04330070541915024, 0.058721496144802335, 0.0741422868704544, 0.08956526494230876, 0.10498605566796089, 0.12040684639361296, 0.13602012358506044, 0.15144310165691474, 0.16686389238256688, 0.182284683108219, 0.19770547383387108, 0.21312845190572544, 0.2285492426313775, 0.24397003335702963, 0.2593908240826817, 0.27481380215453605, 0.2902345928801881, 0.30565538360584027, 0.3210761743314924, 0.3364969650571445, 0.3519199431289988, 0.36734073385465094, 0.38276152458030294, 0.39818231530595505, 0.4136052933778094, 0.4290260841034615, 0.4444468748291136, 0.45986766555476577, 0.47548313009241544, 0.4909039208180675, 0.5063247115437196, 0.5217455022693718, 0.537168480341226, 0.5525892710668782, 0.5680100617925303, 0.5834308525181824, 0.5988538305900367, 0.6142746213156889, 0.6296954120413408, 0.645116202766993, 0.6605391808388474, 0.6759599715644994, 0.6913807622901516, 0.7068015530158036, 0.7222245310876579, 0.7376453218133101, 0.7530661125389622, 0.7684869032646143, 0.7839098813364687, 0.7993306720621207, 0.8149439492535682, 0.8303647399792203, 0.8457877180510747, 0.8612085087767267, 0.8766292995023789, 0.8920500902280308, 0.9074708809536831, 0.9228938590255373, 0.9383146497511896, 0.9537354404768416, 0.9691562312024936, 0.9845792092743479, 1.0],
		[0.027877727347295905, 0.043298518072948, 0.058721496144802335, 0.0741422868704544, 0.08956307759610653, 0.10498605566796089, 0.12040684639361296, 0.13602012358506044, 0.15144310165691474, 0.16686389238256688, 0.182284683108219, 0.19770547383387108, 0.2131262645595232, 0.22854705528517527, 0.24397003335702963, 0.2593908240826817, 0.3904719199431291, 0.39818231530595505, 0.4058927106687812, 0.4136052933778094, 0.42131568874063546, 0.4290260841034615, 0.43673647946628763, 0.4444468748291136, 0.45215727019193963, 0.45986766555476577, 0.46777273472958936, 0.47548313009241544, 0.48319352545524147, 0.4909039208180675, 0.4986143161808936, 0.5063247115437196, 0.5140351069065457, 0.5217455022693718, 0.5294558976321977, 0.537168480341226, 0.5448788757040521, 0.5525892710668782, 0.5602996664297042, 0.5680100617925303, 0.5757204571553562, 0.5834308525181824, 0.5911412478810084, 0.5988516432438344, 0.6065620386066606, 0.6142746213156889, 0.6219850166785148, 0.6296954120413408, 0.7684869032646143, 0.7839076939902664, 0.7993306720621207, 0.8149439492535682, 0.8303647399792203, 0.8457877180510747, 0.8612085087767267, 0.8766292995023789, 0.8920500902280308, 0.9074708809536831, 0.9228938590255373, 0.9383146497511896, 0.9537354404768416, 0.9691562312024936, 0.9845792092743479, 1.0],
		[0.017275660305134787, 0.022096571334828032, 0.026915295018319043, 0.03173401870181002, 0.03655274238530103, 0.041371466068792044, 0.046190189752283055, 0.05100891343577404, 0.055829824465467276, 0.060648548148958294, 0.0654672718324493, 0.07028599551594031, 0.0751069065456335, 0.07992563022912451, 0.08474435391261552, 0.08956307759610653, 0.09823809263411169, 0.10691310767211679, 0.11558812271012195, 0.12426095040192488, 0.1331284519057254, 0.14180346694373056, 0.15047848198173563, 0.1591534970197408, 0.16782632471154374, 0.1765013397495489, 0.18517635478755398, 0.19385136982555914, 0.2025241975173621, 0.21119921255536725, 0.21987422759337233, 0.22854705528517527, 0.2449324656860065, 0.26131787608683765, 0.27770328648766884, 0.29408869688850003, 0.3104741072893313, 0.3268595176901624, 0.34324492809099366, 0.3596303384918248, 0.376015748892656, 0.39239897194728496, 0.40878438234811626, 0.4251697927489474, 0.4415552031497786, 0.4579406135506097, 0.4745185104172363, 0.4909017334718653, 0.5227101219445509, 0.5545163230710342, 0.5863225241975175, 0.6181287253240008, 0.649934926450484, 0.6817433149231695, 0.7135495160496528, 0.7453557171761361, 0.7771619183026194, 0.8091606058948981, 0.8409668070213814, 0.8727730081478646, 0.9045792092743481, 0.9363875977470334, 0.9681937988735169, 1.0],
		[0.013421556296822871, 0.014386175972001966, 0.01534860830097883, 0.016313227976157925, 0.017275660305134787, 0.018240279980313884, 0.019204899655492977, 0.020167331984469843, 0.021131951659648936, 0.022096571334828032, 0.023059003663804895, 0.024023623338983988, 0.024988243014163084, 0.025950675343139946, 0.026915295018319043, 0.027877727347295905, 0.028842347022475002, 0.029806966697654064, 0.03076939902663093, 0.03173401870181002, 0.032698638376989116, 0.03366107070596598, 0.034625690381145074, 0.03559031005632417, 0.03655274238530103, 0.037517362060480126, 0.03847979438945699, 0.039444414064636085, 0.041371466068792044, 0.043298518072948, 0.045227757423306196, 0.047154809427462155, 0.05004648110679717, 0.052938152786132224, 0.055829824465467276, 0.058721496144802335, 0.06257560015311425, 0.0673965111828075, 0.07221523486629844, 0.07896101055394542, 0.08667140591677147, 0.09438398862579978, 0.10016514463826764, 0.10884015967627274, 0.118479794389457, 0.12830972822223438, 0.14180346694373056, 0.15626182534040575, 0.17746595942472798, 0.19867009350905016, 0.22276589927270737, 0.24589708536118557, 0.278667906162848, 0.31143872696451036, 0.3499907037786406, 0.3895094876141522, 0.4473385465084487, 0.5053600918685406, 0.5631913381090392, 0.6219850166785148, 0.7164390003827856, 0.8110876578990541, 0.905543828949527, 1.0],
		[0.043298518072948, 0.0741422868704544, 0.10498605566796089, 0.13602012358506044, 0.16686389238256688, 0.19770547383387108, 0.22854705528517527, 0.2593908240826817, 0.2748116148083338, 0.2902345928801881, 0.30565538360584027, 0.3210761743314924, 0.3364969650571445, 0.3519177557827965, 0.36734073385465094, 0.38276152458030294, 0.3904719199431291, 0.39818231530595505, 0.4058927106687812, 0.4136031060316072, 0.42131568874063546, 0.4290260841034615, 0.43673647946628763, 0.4444468748291136, 0.45215727019193963, 0.45986766555476577, 0.4677705473833872, 0.47548313009241544, 0.48319352545524147, 0.4909017334718653, 0.4986143161808936, 0.5063247115437196, 0.5140351069065457, 0.5217455022693718, 0.5294558976321977, 0.537168480341226, 0.5448788757040521, 0.5525892710668782, 0.5602996664297042, 0.5680100617925303, 0.5757204571553562, 0.5834308525181824, 0.5911412478810084, 0.5988516432438344, 0.6065620386066606, 0.6142724339694865, 0.6219850166785148, 0.6296954120413408, 0.645116202766993, 0.660536993492645, 0.6759599715644994, 0.6913807622901516, 0.7068015530158036, 0.7222223437414558, 0.7376431344671079, 0.7530661125389622, 0.7839076939902664, 0.8149439492535682, 0.8457855307048725, 0.8766292995023789, 0.9074708809536831, 0.9383146497511896, 0.9691562312024936, 1.0],
		[0.044263137748127096, 0.07606933887461036, 0.10787554000109371, 0.1398764149395746, 0.1716826160660579, 0.20348881719254117, 0.23529501831902447, 0.26710121944550774, 0.29890742057199104, 0.3307136216984744, 0.3625198228249577, 0.39432821129764317, 0.4261344124241264, 0.4579406135506097, 0.4899393011428884, 0.5217455022693718, 0.5381309126702029, 0.5545163230710342, 0.5709017334718653, 0.5872871438726965, 0.6036725542735276, 0.6200557773281566, 0.6364411877289878, 0.6528265981298191, 0.6692120085306502, 0.6855974189314814, 0.7019828293323126, 0.7183682397331439, 0.7347514627877728, 0.751136873188604, 0.7675222835894352, 0.7839076939902664, 0.7925827090282715, 0.8012577240662767, 0.8101252255700773, 0.8187980532618802, 0.8274730682998853, 0.8361480833378905, 0.8448230983758956, 0.8534959260676984, 0.8621709411057036, 0.8708459561437087, 0.8795209711817139, 0.8881937988735168, 0.8968688139115218, 0.905543828949527, 0.9142188439875322, 0.9228916716793352, 0.9277125827090282, 0.9325313063925195, 0.9373500300760104, 0.9421687537595014, 0.9469896647891948, 0.9518083884726857, 0.9566271121561766, 0.9614458358396676, 0.9662645595231585, 0.9710854705528519, 0.9759041942363428, 0.9807229179198338, 0.985541641603325, 0.9903603652868159, 0.9951790889703069, 1.0],
		[0.013421556296822871, 0.10787554000109371, 0.2025241975173621, 0.2969803685678351, 0.3914365396183081, 0.45022803084158153, 0.5082517635478756, 0.5660830097883742, 0.6239120686826709, 0.6634286651719802, 0.7019828293323126, 0.7347514627877728, 0.7675222835894352, 0.7906556570241156, 0.8149439492535682, 0.8361480833378905, 0.8534981134139006, 0.8660272324602177, 0.8756646798271998, 0.8853021271941818, 0.8968688139115218, 0.906506261278504, 0.9151812763165091, 0.9238562913545143, 0.9315666867173403, 0.9383146497511896, 0.9440979931098596, 0.9498813364685296, 0.9547000601520207, 0.9585541641603326, 0.9614458358396676, 0.9643375075190026, 0.9672291791983377, 0.9691562312024936, 0.9710854705528519, 0.9730125225570078, 0.9739771422321869, 0.9749395745611636, 0.9759041942363428, 0.9768666265653199, 0.9778312462404988, 0.9787958659156779, 0.9797582982446549, 0.9807229179198338, 0.9816875375950129, 0.9826499699239899, 0.9836145895991688, 0.9845792092743479, 0.985541641603325, 0.9865062612785039, 0.9874708809536831, 0.9884333132826598, 0.989397932957839, 0.9903603652868159, 0.9913249849619948, 0.992289604637174, 0.9932520369661509, 0.9942166566413299, 0.9951790889703069, 0.9961437086454861, 0.997108328320665, 0.998070760649642, 0.9990353803248211, 1.0],
		[0.020167331984469843, 0.027877727347295905, 0.03558812271012194, 0.043298518072948, 0.05100891343577404, 0.0587193087986001, 0.06643189150762839, 0.0741422868704544, 0.08185268223328046, 0.08956307759610653, 0.09727347295893259, 0.10498605566796089, 0.11269645103078689, 0.12040684639361296, 0.12830972822223438, 0.13602012358506044, 0.15144091431071258, 0.16686389238256688, 0.182284683108219, 0.19770547383387108, 0.2131262645595232, 0.22854705528517527, 0.24397003335702963, 0.2593908240826817, 0.2902345928801881, 0.3210761743314924, 0.3519177557827965, 0.38276152458030294, 0.4136031060316072, 0.4444468748291136, 0.47548313009241544, 0.5063247115437196, 0.5371662929950238, 0.5680100617925303, 0.5988516432438344, 0.6296954120413408, 0.660536993492645, 0.6913807622901516, 0.7222223437414558, 0.7530661125389622, 0.7684869032646143, 0.7839076939902664, 0.7993306720621207, 0.8149439492535682, 0.8303647399792203, 0.8457855307048725, 0.8612085087767267, 0.8766292995023789, 0.8843396948652049, 0.8920500902280308, 0.8997604855908569, 0.9074708809536831, 0.9151812763165091, 0.9228916716793352, 0.9306020670421612, 0.9383146497511896, 0.9460250451140155, 0.9537354404768416, 0.9614458358396676, 0.9691562312024936, 0.9768666265653199, 0.9845770219281458, 0.992289604637174, 1.0],
		[0.029804779351451864, 0.04233608574397114, 0.0654672718324493, 0.07606933887461036, 0.09341936895062068, 0.10209219664242361, 0.12233389839776891, 0.1379471755892164, 0.1495138623065566, 0.17071799639087878, 0.18324711543719585, 0.2025241975173621, 0.21601793623885826, 0.23047629463553346, 0.24782413736534153, 0.2536074807240116, 0.27963033849182484, 0.2921616448843441, 0.30469076393066113, 0.3104741072893313, 0.3345699130529885, 0.3538469951331547, 0.3654114945042927, 0.397217695630776, 0.4030010389894461, 0.4155323453819654, 0.42998851643243835, 0.43673647946628763, 0.4579406135506097, 0.4774101820965714, 0.49957674850987044, 0.5072893312188987, 0.5188538305900366, 0.5236725542735278, 0.5583704270793461, 0.5680100617925303, 0.5795745611636682, 0.5988516432438344, 0.6133100016405096, 0.6268037403620059, 0.6412599114124788, 0.6624640454968012, 0.6721036802099853, 0.6990911576529777, 0.7068015530158036, 0.7193306720621208, 0.7434264778257779, 0.761738940230765, 0.7675222835894352, 0.7858347459944224, 0.8012577240662767, 0.8187980532618802, 0.8284376879750643, 0.8477147700552305, 0.8621709411057036, 0.8698813364685296, 0.8930147099032101, 0.908435500628862, 0.9200021873462022, 0.9412063214305246, 0.9681937988735169, 0.9730125225570078, 0.9826499699239899, 1.0],
		[0.03366107070596598, 0.04233608574397114, 0.055829824465467276, 0.08667140591677147, 0.09149012960026248, 0.10787554000109371, 0.11944222671843387, 0.13120139990156943, 0.15047848198173563, 0.17264504839503475, 0.17939301142888395, 0.20348881719254117, 0.2140908842347023, 0.22854705528517527, 0.2545721003991907, 0.2603532564116586, 0.3895073002679499, 0.4010739869852901, 0.40878438234811626, 0.41649477771094223, 0.42035106906545633, 0.4290260841034615, 0.4405905834745995, 0.44540930715809046, 0.45215727019193963, 0.46179471755892165, 0.46584349537923114, 0.47933723410072737, 0.4841559577842183, 0.49379340515120035, 0.49572264450155856, 0.5034330398643846, 0.5255996062776837, 0.5284912779570187, 0.5304205173073769, 0.5352392409908678, 0.542949636353694, 0.5545163230710342, 0.5612620987586812, 0.5670454421173511, 0.5795767485098705, 0.5834308525181824, 0.5921058675561875, 0.5940329195603434, 0.6094537102859956, 0.6104183299611746, 0.6296954120413408, 0.6335495160496528, 0.7684869032646143, 0.7858369333406245, 0.806268934215563, 0.8120522775742332, 0.8265106359709085, 0.8467501503800515, 0.8689189041395528, 0.8795209711817139, 0.8910854705528517, 0.906506261278504, 0.9257833433586702, 0.9440979931098596, 0.9547000601520207, 0.9653021271941817, 0.9826499699239899, 1.0],
		[0.021131951659648936, 0.023059003663804895, 0.025950675343139946, 0.03655274238530103, 0.03847979438945699, 0.04233608574397114, 0.048117241756439014, 0.05100891343577404, 0.05679225679444414, 0.0645026521572702, 0.06835894351178436, 0.07125061519111942, 0.07606933887461036, 0.08377973423743643, 0.08667140591677147, 0.08860064526712966, 0.10112976431344674, 0.10787554000109371, 0.1175151747142779, 0.12541805654289934, 0.12927216055121124, 0.14083884726855145, 0.14854924263137753, 0.16204298135287362, 0.17264504839503475, 0.17746595942472798, 0.18421173511237496, 0.1909596981462241, 0.20445343686772027, 0.20830754087603218, 0.22083665992234927, 0.23722207032318043, 0.24589708536118557, 0.26228249576201673, 0.27963033849182484, 0.2892699732050091, 0.3124011592934872, 0.3268595176901624, 0.35480942746213157, 0.36444906217531586, 0.37697818122163296, 0.3933635916224641, 0.4193864493902773, 0.4270968447531033, 0.43962815114562265, 0.46083009788374263, 0.46584349537923114, 0.4899393011428884, 0.5227101219445509, 0.5689746814677094, 0.5901788155520316, 0.6162016733198448, 0.6653557171761362, 0.6817411275769674, 0.7125848963744738, 0.7395701864712638, 0.7781243506315962, 0.8091606058948981, 0.8371127030130695, 0.8737376278230439, 0.9122896046371741, 0.9373500300760104, 0.9653021271941817, 1.0],
		[0.013421556296822871, 0.01378028107398698, 0.014383988625799735, 0.014873954175097058, 0.01534860830097883, 0.015748892655985135, 0.016311040629955694, 0.01675069721660196, 0.017275660305134787, 0.017498769617761253, 0.018240279980313884, 0.01859244271887133, 0.019202712309290746, 0.019642368895937016, 0.019904850440203414, 0.020167331984469843, 0.020561054300869484, 0.021131951659648936, 0.021435992781757528, 0.021873462022201567, 0.022310931262645602, 0.023059003663804895, 0.02340460436375568, 0.024023623338983988, 0.02449827746486576, 0.024986055667960853, 0.02542571225460709, 0.025810685186197842, 0.026915295018319043, 0.027877727347295905, 0.03366107070596598, 0.034625690381145074, 0.04040684639361295, 0.044263137748127096, 0.047154809427462155, 0.05004648110679717, 0.055829824465467276, 0.06257560015311425, 0.06739432383660526, 0.0741422868704544, 0.08667140591677147, 0.09341936895062068, 0.10016514463826764, 0.11944222671843387, 0.12040684639361296, 0.13120139990156943, 0.1379471755892164, 0.15433258599004757, 0.18324711543719585, 0.19963252583802701, 0.2256553836058402, 0.24878875704052064, 0.27288456280417783, 0.3133657789686663, 0.37601356154645377, 0.3933635916224641, 0.44637392683326965, 0.5072871438726965, 0.5901788155520316, 0.6229474490074917, 0.7077661726909827, 0.815906381582545, 0.9228916716793352, 1.0],
		[0.044263137748127096, 0.0654672718324493, 0.10787554000109371, 0.1331284519057254, 0.1697533767156997, 0.20445124952151802, 0.22951167496035435, 0.2593908240826817, 0.2709575108000219, 0.28252201017115985, 0.3124011592934872, 0.3336052933778095, 0.35770109914146664, 0.36637611417947175, 0.37890523322578884, 0.3933635916224641, 0.4068573303439602, 0.40878438234811626, 0.41456772570678624, 0.4193864493902773, 0.42998851643243835, 0.4415552031497786, 0.44540930715809046, 0.4511926505167606, 0.46179471755892165, 0.47258927106687815, 0.47644556242139235, 0.4870476294635534, 0.4889746814677094, 0.5053600918685406, 0.5082517635478756, 0.5159621589107016, 0.5198184502652158, 0.5265642259528628, 0.5381309126702029, 0.546805927708208, 0.55644337507519, 0.5583704270793461, 0.5689724941215072, 0.5795767485098705, 0.5815038005140264, 0.5940329195603434, 0.5978892109148576, 0.6094537102859956, 0.6162016733198448, 0.6229474490074917, 0.6354765680538088, 0.635478755400011, 0.644151583091814, 0.6586099414884892, 0.6721036802099853, 0.6942724339694866, 0.7125848963744738, 0.7193306720621208, 0.738607754142287, 0.751136873188604, 0.7858347459944224, 0.8255460162957292, 0.8438584787007164, 0.8737376278230439, 0.9045792092743481, 0.9479520971181714, 0.9691562312024936, 1.0],
		[0.045227757423306196, 0.07896101055394542, 0.10594848799693775, 0.1369825559140373, 0.17264504839503475, 0.20445124952151802, 0.24782413736534153, 0.2632449280909936, 0.2921616448843441, 0.3316782413736534, 0.35962815114562263, 0.397217695630776, 0.42998851643243835, 0.46083009788374263, 0.4909017334718653, 0.5149975392355226, 0.5390933449991797, 0.5545163230710342, 0.5737934051512004, 0.5901766282058294, 0.6123453819653306, 0.6210203970033358, 0.6287307923661618, 0.654753650133975, 0.6701744408596271, 0.6865598512604583, 0.7039098813364686, 0.7212577240662766, 0.7318597911084378, 0.7569202165472741, 0.7723410072729262, 0.7858347459944224, 0.7945097610324275, 0.8033750751900258, 0.809158418548696, 0.815906381582545, 0.8265084486247061, 0.8390397550172255, 0.8477125827090284, 0.8583146497511894, 0.8640979931098595, 0.8718083884726856, 0.8795187838355116, 0.8843396948652049, 0.894941761907366, 0.9113249849619949, 0.9151812763165091, 0.92, 0.9238562913545143, 0.9325291190463171, 0.9402417017553455, 0.9431333734346805, 0.9450604254388364, 0.9546978728058185, 0.9556624924809974, 0.9604812161644884, 0.9633728878438235, 0.9739749548859847, 0.9759020068901406, 0.9836145895991688, 0.9845770219281458, 0.9884333132826598, 0.9932520369661509, 1.0],
		[0.017275660305134787, 0.10787554000109371, 0.20445124952151802, 0.29023240553398594, 0.3895073002679499, 0.4627593372341008, 0.5053600918685406, 0.5689724941215072, 0.6229474490074917, 0.6653557171761362, 0.6981265379777984, 0.7366785147919288, 0.7694493355935912, 0.7945097610324275, 0.815906381582545, 0.8294001203040412, 0.8602438891015476, 0.8747000601520207, 0.8910854705528517, 0.8959041942363429, 0.91421665664133, 0.9228916716793352, 0.9277103953628261, 0.9392770820801664, 0.9460228577678134, 0.9498791491223274, 0.9614458358396676, 0.9652999398479796, 0.9691562312024936, 0.9710832832066497, 0.9739749548859847, 0.9746814677093019, 0.9759020068901406, 0.9770875485317441, 0.97774375239241, 0.97883742549352, 0.9797582982446549, 0.9816853502488108, 0.9821184447968503, 0.9865040739323018, 0.986943730518948, 0.9874686936074809, 0.9884333132826598, 0.9893957456116368, 0.9903603652868159, 0.9911040629955706, 0.9913249849619948, 0.991524033466397, 0.9922874172909718, 0.9928364411877291, 0.9933395308142398, 0.9942166566413299, 0.9948050527697271, 0.9951790889703069, 0.9956799912506153, 0.9961437086454861, 0.9966686717340189, 0.997108328320665, 0.998070760649642, 0.9985235413135015, 0.9990353803248211, 0.9993984797943896, 0.9997790780335758, 1.0],
		[0.023059003663804895, 0.03076939902663093, 0.044263137748127096, 0.046190189752283055, 0.05293596543993, 0.05486520479028818, 0.0654672718324493, 0.07221304752009627, 0.08667140591677147, 0.09341718160441845, 0.1011275769672445, 0.10787554000109371, 0.1107672116804287, 0.12426095040192488, 0.12927216055121124, 0.13409088423470225, 0.14758462295619842, 0.17071799639087878, 0.18324711543719585, 0.19674085415869197, 0.2256553836058402, 0.22951167496035435, 0.24782413736534153, 0.25746158473232356, 0.28444906217531585, 0.3239656586646252, 0.35480942746213157, 0.37890523322578884, 0.41456772570678624, 0.44251763547875544, 0.47548094274621316, 0.5072871438726965, 0.5448766883578499, 0.5689724941215072, 0.5969245912396786, 0.6431869634166348, 0.659572373817466, 0.6942702466232844, 0.7106556570241156, 0.751136873188604, 0.7646327992563025, 0.7964390003827857, 0.7974036200579647, 0.8149439492535682, 0.8371127030130695, 0.8428960463717395, 0.8641001804560619, 0.8679542844643737, 0.8814480231858698, 0.8910854705528517, 0.908435500628862, 0.9113271723081972, 0.9122917919833763, 0.9267479630338493, 0.9334959260676984, 0.9421709411057035, 0.9469896647891948, 0.9585563515065347, 0.9653021271941817, 0.9681937988735169, 0.9787958659156779, 0.9845792092743479, 0.9951790889703069, 1.0]
	];
	widgets[\d_grid_popupmenu].items_(["1", "2", "3", "4", "6", "8", "12", "16"]).action_({
		arg v;
		widgets[\d_time_clk_checkbox].valueAction_(widgets[\d_time_clk_checkbox].value);
	});
	widgets[\d_stack_popupmenu].items_(["1", "2", "4"]).action_({
		arg v;
		widgets[\d_groove_popupmenu].valueAction_(widgets[\d_groove_popupmenu].value);
	});
	widgets[\d_time_numberbox].clipLo_(1).clipHi_(20000).decimals_(2).action_({
		arg v;
		widgets[\d_stack_popupmenu].valueAction_(widgets[\d_stack_popupmenu].value);
	});
	widgets[\d_pingpong_checkbox].action_({
		arg v;
		~rain_maker_delay_synth.set(\fb_pingpong, v.value.asInteger);
	});
	widgets[\d_reverse_checkbox].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_rev, v.value.asInteger);
		~rain_maker_delay_synth.set(\t_rev_change, 1);
	});
	widgets[\d_time_clk_checkbox].action_({
		arg v;
		var multiplier;
		widgets[\d_time_numberbox].enabled_(v.value.not);
		multiplier = switch (widgets[\d_div_popupmenu].value,
			0, {1},
			1, {2},
			2, {3},
			3, {4},
			4, {6},
			5, {8},
			6, {12},
			7, {16},
			8, {24},
			9, {32},
			10, {48},
			11, {64},
			12, {96},
			13, {128},
			14, {192},
			15, {256},
		);
		if (v.value, {
			widgets[\d_time_numberbox].valueAction_((60000 / (widgets[\g_tempo_numberbox].value * multiplier)) / widgets[\d_grid_popupmenu].item.asInteger)
		}, {});
	});
	widgets[\d_div_popupmenu].items_(["/1", "/2", "/3", "/4", "/6", "/8", "/12", "/16", "/24", "/32", "/48", "/64", "/96", "/128", "/192", "/256"]).action_({
		arg v;
		widgets[\d_time_clk_checkbox].valueAction_(widgets[\d_time_clk_checkbox].value);
	});
	widgets[\d_grain_quantity_popupmenu].items_(["1", "2", "4", "1 no env", "2 hanning"]).action_({
		arg v;
		~rain_maker_delay_synth.set(\grain_quantity, switch (v.value, 0, {1}, 1, {2}, 2, {4}, 3, {1}, 4, {2}));
		~rain_maker_delay_synth.set(\grain_winenv, switch (v.value, 0, {triangle_window}, 1, {triangle_window}, 2, {triangle_window}, 3, {rect_window}, 4, {-1}));
	});
	widgets[\d_grain_size_numberbox].clipLo_(5).clipHi_(671).decimals_(0).action_({
		arg v;
		~rain_maker_delay_synth.set(\grain_size, v.value / 1000);
	});
	widgets[\d_global_ps_knob].mode_(\vert).keystep_(0.032258065).step_(0.032258065).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_global_ps_static].string_((v.value * 31 + -16).round(1).asInteger.asString);
		~rain_maker_delay_synth.set(\global_pitch_shift, (v.value * 31 + -16).round(1));
	});
	widgets[\d_feedback_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_feedback_static].string_((v.value * 1 + 0).round(0.01).asString);
		~rain_maker_delay_synth.set(\global_fb, v.value);
	});
	widgets[\d_fb_tone_knob].mode_(\vert).action_({
		arg v;
		var tmp_coeff;
		value_static_texts[\d_fb_tone_static].string_((v.value * 2 + -1).round(0.01).asString);
		if ((v.value * 2 - 1) < 0, {
			tmp_coeff = ~lpf_1st_coeff.value((v.value * 2 - 1).linexp(-1, 0, 20, 20000), s.sampleRate);
			~rain_maker_delay_synth.set(\global_coeff_a0, tmp_coeff[0]);
			~rain_maker_delay_synth.set(\global_coeff_a1, tmp_coeff[1]);
			~rain_maker_delay_synth.set(\global_coeff_b1, tmp_coeff[2]);
		}, {
			tmp_coeff = ~hpf_1st_coeff.value((v.value * 2 - 1).linexp(0, 1, 20, 20000), s.sampleRate);
			~rain_maker_delay_synth.set(\global_coeff_a0, tmp_coeff[0]);
			~rain_maker_delay_synth.set(\global_coeff_a1, tmp_coeff[1]);
			~rain_maker_delay_synth.set(\global_coeff_b1, tmp_coeff[2]);
		});
	});
	widgets[\d_fb_tap_l_popupmenu].items_(["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16"]).action_({
		arg v;
		~rain_maker_delay_synth.set(\fb_tap_index_l, v.value);
	});
	widgets[\d_fb_tap_r_popupmenu].items_(["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16"]).action_({
		arg v;
		~rain_maker_delay_synth.set(\fb_tap_index_r, v.value);
	});
	widgets[\d_fb_ps_l_knob].mode_(\vert).keystep_(0.032258065).step_(0.032258065).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_fb_ps_l_static].string_((v.value * 31 + -16).round(1).asInteger.asString);
		~rain_maker_delay_synth.set(\fb_pitch_shift_l, (v.value * 31 + -16).round(1).asInteger);
	});
	widgets[\d_fb_ps_r_knob].mode_(\vert).keystep_(0.032258065).step_(0.032258065).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_fb_ps_r_static].string_((v.value * 31 + -16).round(1).asInteger.asString);
		~rain_maker_delay_synth.set(\fb_pitch_shift_r, (v.value * 31 + -16).round(1).asInteger);
	});
	widgets[\d_slip_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_slip_static].string_(v.value.linlin(0, 1, 0.5, 1.5).round(0.1).asString);
		~rain_maker_delay_synth.set(\slip, v.value.linlin(0, 1, 0.5, 1.5));
	});
	widgets[\d_groove_popupmenu].items_(["Straight", "Swing", "Hard Swing", "Reverse Swing", "Alternate Swing", "Accelerando", "Ritardando", "Waltz Time", "Half Swing", "Roller Coaster", "Quintuple Time", "Uniform Random 1", "Uniform Random 2", "Uniform Random 3", "Early Reflection", "Late Reflection"]).action_({
		arg v;
		widgets[\d_gveamt_knob].valueAction_(widgets[\d_gveamt_knob].value);
	});
	widgets[\d_gveamt_knob].mode_(\vert).action_({
		arg v;
		var t1, t2, mix;
		value_static_texts[\d_gveamt_static].string_((v.value.round(0.01) * 100).asInteger.asString ++ "%");
		t1 = (widgets[\d_time_numberbox].value / 1000) * (groove_patterns[0] / 64);
		t2 = (widgets[\d_time_numberbox].value / 1000) * (groove_patterns[widgets[\d_groove_popupmenu].value] / 64);
		mix = (t2 * v.value) + (t1 * (1 - v.value));
		switch (widgets[\d_stack_popupmenu].value,
			0, {
				~rain_maker_delay_synth.set(\tap_delay_01, mix[0]);
				~rain_maker_delay_synth.set(\tap_delay_02, mix[1]);
				~rain_maker_delay_synth.set(\tap_delay_03, mix[2]);
				~rain_maker_delay_synth.set(\tap_delay_04, mix[3]);
				~rain_maker_delay_synth.set(\tap_delay_05, mix[4]);
				~rain_maker_delay_synth.set(\tap_delay_06, mix[5]);
				~rain_maker_delay_synth.set(\tap_delay_07, mix[6]);
				~rain_maker_delay_synth.set(\tap_delay_08, mix[7]);
				~rain_maker_delay_synth.set(\tap_delay_09, mix[8]);
				~rain_maker_delay_synth.set(\tap_delay_10, mix[9]);
				~rain_maker_delay_synth.set(\tap_delay_11, mix[10]);
				~rain_maker_delay_synth.set(\tap_delay_12, mix[11]);
				~rain_maker_delay_synth.set(\tap_delay_13, mix[12]);
				~rain_maker_delay_synth.set(\tap_delay_14, mix[13]);
				~rain_maker_delay_synth.set(\tap_delay_15, mix[14]);
				~rain_maker_delay_synth.set(\tap_delay_16, mix[15]);
			},
			1, {
				~rain_maker_delay_synth.set(\tap_delay_01, mix[1]);
				~rain_maker_delay_synth.set(\tap_delay_02, mix[1]);
				~rain_maker_delay_synth.set(\tap_delay_03, mix[3]);
				~rain_maker_delay_synth.set(\tap_delay_04, mix[3]);
				~rain_maker_delay_synth.set(\tap_delay_05, mix[5]);
				~rain_maker_delay_synth.set(\tap_delay_06, mix[5]);
				~rain_maker_delay_synth.set(\tap_delay_07, mix[7]);
				~rain_maker_delay_synth.set(\tap_delay_08, mix[7]);
				~rain_maker_delay_synth.set(\tap_delay_09, mix[9]);
				~rain_maker_delay_synth.set(\tap_delay_10, mix[9]);
				~rain_maker_delay_synth.set(\tap_delay_11, mix[11]);
				~rain_maker_delay_synth.set(\tap_delay_12, mix[11]);
				~rain_maker_delay_synth.set(\tap_delay_13, mix[13]);
				~rain_maker_delay_synth.set(\tap_delay_14, mix[13]);
				~rain_maker_delay_synth.set(\tap_delay_15, mix[15]);
				~rain_maker_delay_synth.set(\tap_delay_16, mix[15]);
			},
			2, {
				~rain_maker_delay_synth.set(\tap_delay_01, mix[3]);
				~rain_maker_delay_synth.set(\tap_delay_02, mix[3]);
				~rain_maker_delay_synth.set(\tap_delay_03, mix[3]);
				~rain_maker_delay_synth.set(\tap_delay_04, mix[3]);
				~rain_maker_delay_synth.set(\tap_delay_05, mix[7]);
				~rain_maker_delay_synth.set(\tap_delay_06, mix[7]);
				~rain_maker_delay_synth.set(\tap_delay_07, mix[7]);
				~rain_maker_delay_synth.set(\tap_delay_08, mix[7]);
				~rain_maker_delay_synth.set(\tap_delay_09, mix[11]);
				~rain_maker_delay_synth.set(\tap_delay_10, mix[11]);
				~rain_maker_delay_synth.set(\tap_delay_11, mix[11]);
				~rain_maker_delay_synth.set(\tap_delay_12, mix[11]);
				~rain_maker_delay_synth.set(\tap_delay_13, mix[15]);
				~rain_maker_delay_synth.set(\tap_delay_14, mix[15]);
				~rain_maker_delay_synth.set(\tap_delay_15, mix[15]);
				~rain_maker_delay_synth.set(\tap_delay_16, mix[15]);
			}
		);
		~rain_maker_delay_synth.set(\t_rev_change, 1);
	});
	widgets[\d_mod_wave_popupmenu].items_(["Sinusoid", "Triangle", "Random"]).action_({
		arg v;
		~rain_maker_delay_synth.set(\mod_index, v.value);
	});
	widgets[\d_mod_level_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_mod_level_static].string_((v.value * 50 + 0).round(0.01).asString ++ " ms");
		~rain_maker_delay_synth.set(\mod_level, v.value);
	});
	widgets[\d_mod_rate_numberbox].clipLo_(0.1).clipHi_(20).decimals_(1).action_({
		arg v;
		~rain_maker_delay_synth.set(\mod_rate, v.value);
	});
	widgets[\c_level_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\c_level_static].string_(v.value.round(0.01).asString);
		~rain_maker_comb_synth.set(\amp, v.value);
	});
	widgets[\c_patt_popupmenu].items_(["Uniform", "Flat Middle", "Early Comb", "Fibonacci", "Flat Comb", "Late Comb", "Rev. Fibonacci", "Ess Comb", "Rand Uniform", "Rand Middle", "Rand Early", "Rand Fibonacci", "Rand Flat", "Rand Late", "Rand Rev. Fib.", "Rand Ess"]).action_({
		arg v;
		widgets[\c_combsize_clk_checkbox].valueAction_(widgets[\c_combsize_clk_checkbox].value);
	});
	widgets[\c_fb_config_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\c_fb_config_static].string_(v.value.round(0.01).asString);
		~rain_maker_comb_synth.set(\filter_alpha, v.value);
	});
	widgets[\c_slope_popupmenu].items_(["Flat", "Rising", "Falling", "Rise/Fall"]).action_({
		arg v;
		~rain_maker_comb_synth.set(\slope_01, comb_slope_patterns[v.value][0]);
		~rain_maker_comb_synth.set(\slope_02, comb_slope_patterns[v.value][1]);
		~rain_maker_comb_synth.set(\slope_03, comb_slope_patterns[v.value][2]);
		~rain_maker_comb_synth.set(\slope_04, comb_slope_patterns[v.value][3]);
		~rain_maker_comb_synth.set(\slope_05, comb_slope_patterns[v.value][4]);
		~rain_maker_comb_synth.set(\slope_06, comb_slope_patterns[v.value][5]);
		~rain_maker_comb_synth.set(\slope_07, comb_slope_patterns[v.value][6]);
		~rain_maker_comb_synth.set(\slope_08, comb_slope_patterns[v.value][7]);
		~rain_maker_comb_synth.set(\slope_09, comb_slope_patterns[v.value][8]);
		~rain_maker_comb_synth.set(\slope_10, comb_slope_patterns[v.value][9]);
		~rain_maker_comb_synth.set(\slope_11, comb_slope_patterns[v.value][10]);
		~rain_maker_comb_synth.set(\slope_12, comb_slope_patterns[v.value][11]);
		~rain_maker_comb_synth.set(\slope_13, comb_slope_patterns[v.value][12]);
		~rain_maker_comb_synth.set(\slope_14, comb_slope_patterns[v.value][13]);
		~rain_maker_comb_synth.set(\slope_15, comb_slope_patterns[v.value][14]);
		~rain_maker_comb_synth.set(\slope_16, comb_slope_patterns[v.value][15]);
		~rain_maker_comb_synth.set(\slope_17, comb_slope_patterns[v.value][16]);
		~rain_maker_comb_synth.set(\slope_18, comb_slope_patterns[v.value][17]);
		~rain_maker_comb_synth.set(\slope_19, comb_slope_patterns[v.value][18]);
		~rain_maker_comb_synth.set(\slope_20, comb_slope_patterns[v.value][19]);
		~rain_maker_comb_synth.set(\slope_21, comb_slope_patterns[v.value][20]);
		~rain_maker_comb_synth.set(\slope_22, comb_slope_patterns[v.value][21]);
		~rain_maker_comb_synth.set(\slope_23, comb_slope_patterns[v.value][22]);
		~rain_maker_comb_synth.set(\slope_24, comb_slope_patterns[v.value][23]);
		~rain_maker_comb_synth.set(\slope_25, comb_slope_patterns[v.value][24]);
		~rain_maker_comb_synth.set(\slope_26, comb_slope_patterns[v.value][25]);
		~rain_maker_comb_synth.set(\slope_27, comb_slope_patterns[v.value][26]);
		~rain_maker_comb_synth.set(\slope_28, comb_slope_patterns[v.value][27]);
		~rain_maker_comb_synth.set(\slope_29, comb_slope_patterns[v.value][28]);
		~rain_maker_comb_synth.set(\slope_30, comb_slope_patterns[v.value][29]);
		~rain_maker_comb_synth.set(\slope_31, comb_slope_patterns[v.value][30]);
		~rain_maker_comb_synth.set(\slope_32, comb_slope_patterns[v.value][31]);
		~rain_maker_comb_synth.set(\slope_33, comb_slope_patterns[v.value][32]);
		~rain_maker_comb_synth.set(\slope_34, comb_slope_patterns[v.value][33]);
		~rain_maker_comb_synth.set(\slope_35, comb_slope_patterns[v.value][34]);
		~rain_maker_comb_synth.set(\slope_36, comb_slope_patterns[v.value][35]);
		~rain_maker_comb_synth.set(\slope_37, comb_slope_patterns[v.value][36]);
		~rain_maker_comb_synth.set(\slope_38, comb_slope_patterns[v.value][37]);
		~rain_maker_comb_synth.set(\slope_39, comb_slope_patterns[v.value][38]);
		~rain_maker_comb_synth.set(\slope_40, comb_slope_patterns[v.value][39]);
		~rain_maker_comb_synth.set(\slope_41, comb_slope_patterns[v.value][40]);
		~rain_maker_comb_synth.set(\slope_42, comb_slope_patterns[v.value][41]);
		~rain_maker_comb_synth.set(\slope_43, comb_slope_patterns[v.value][42]);
		~rain_maker_comb_synth.set(\slope_44, comb_slope_patterns[v.value][43]);
		~rain_maker_comb_synth.set(\slope_45, comb_slope_patterns[v.value][44]);
		~rain_maker_comb_synth.set(\slope_46, comb_slope_patterns[v.value][45]);
		~rain_maker_comb_synth.set(\slope_47, comb_slope_patterns[v.value][46]);
		~rain_maker_comb_synth.set(\slope_48, comb_slope_patterns[v.value][47]);
		~rain_maker_comb_synth.set(\slope_49, comb_slope_patterns[v.value][48]);
		~rain_maker_comb_synth.set(\slope_50, comb_slope_patterns[v.value][49]);
		~rain_maker_comb_synth.set(\slope_51, comb_slope_patterns[v.value][50]);
		~rain_maker_comb_synth.set(\slope_52, comb_slope_patterns[v.value][51]);
		~rain_maker_comb_synth.set(\slope_53, comb_slope_patterns[v.value][52]);
		~rain_maker_comb_synth.set(\slope_54, comb_slope_patterns[v.value][53]);
		~rain_maker_comb_synth.set(\slope_55, comb_slope_patterns[v.value][54]);
		~rain_maker_comb_synth.set(\slope_56, comb_slope_patterns[v.value][55]);
		~rain_maker_comb_synth.set(\slope_57, comb_slope_patterns[v.value][56]);
		~rain_maker_comb_synth.set(\slope_58, comb_slope_patterns[v.value][57]);
		~rain_maker_comb_synth.set(\slope_59, comb_slope_patterns[v.value][58]);
		~rain_maker_comb_synth.set(\slope_60, comb_slope_patterns[v.value][59]);
		~rain_maker_comb_synth.set(\slope_61, comb_slope_patterns[v.value][60]);
		~rain_maker_comb_synth.set(\slope_62, comb_slope_patterns[v.value][61]);
		~rain_maker_comb_synth.set(\slope_63, comb_slope_patterns[v.value][62]);
		~rain_maker_comb_synth.set(\slope_64, comb_slope_patterns[v.value][63]);
	});
	widgets[\c_div_popupmenu].items_(["/1", "/2", "/3", "/4", "/6", "/8", "/12", "/16", "/24", "/32", "/48", "/64", "/96", "/128", "/192", "/256"]).action_({
		arg v;
		widgets[\c_combsize_clk_checkbox].valueAction_(widgets[\c_combsize_clk_checkbox].value);
	});
	widgets[\c_feedback_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\c_feedback_static].string_((v.value * 1 + 0).round(0.01).asString);
		~rain_maker_comb_synth.set(\global_fb, v.value);
	});
	widgets[\c_combsize_knob].mode_(\vert).keystep_(0.002020202).step_(0.002020202).alt_scale_(1.0).action_({
		arg v;
		var delay_time;
		value_static_texts[\c_combsize_static].string_(v.value.linexp(0, 1, 1, 500).round(0.01).asString ++ " ms");
		if (widgets[\c_combsize_clk_checkbox].value.not, {
			delay_time = v.value.linexp(0, 1, 1, 500) / 1000 * comb_patterns[widgets[\c_patt_popupmenu].value];
			~rain_maker_comb_synth.set(\tap_delay_01, delay_time[0]);
			~rain_maker_comb_synth.set(\tap_delay_02, delay_time[1]);
			~rain_maker_comb_synth.set(\tap_delay_03, delay_time[2]);
			~rain_maker_comb_synth.set(\tap_delay_04, delay_time[3]);
			~rain_maker_comb_synth.set(\tap_delay_05, delay_time[4]);
			~rain_maker_comb_synth.set(\tap_delay_06, delay_time[5]);
			~rain_maker_comb_synth.set(\tap_delay_07, delay_time[6]);
			~rain_maker_comb_synth.set(\tap_delay_08, delay_time[7]);
			~rain_maker_comb_synth.set(\tap_delay_09, delay_time[8]);
			~rain_maker_comb_synth.set(\tap_delay_10, delay_time[9]);
			~rain_maker_comb_synth.set(\tap_delay_11, delay_time[10]);
			~rain_maker_comb_synth.set(\tap_delay_12, delay_time[11]);
			~rain_maker_comb_synth.set(\tap_delay_13, delay_time[12]);
			~rain_maker_comb_synth.set(\tap_delay_14, delay_time[13]);
			~rain_maker_comb_synth.set(\tap_delay_15, delay_time[14]);
			~rain_maker_comb_synth.set(\tap_delay_16, delay_time[15]);
			~rain_maker_comb_synth.set(\tap_delay_17, delay_time[16]);
			~rain_maker_comb_synth.set(\tap_delay_18, delay_time[17]);
			~rain_maker_comb_synth.set(\tap_delay_19, delay_time[18]);
			~rain_maker_comb_synth.set(\tap_delay_20, delay_time[19]);
			~rain_maker_comb_synth.set(\tap_delay_21, delay_time[20]);
			~rain_maker_comb_synth.set(\tap_delay_22, delay_time[21]);
			~rain_maker_comb_synth.set(\tap_delay_23, delay_time[22]);
			~rain_maker_comb_synth.set(\tap_delay_24, delay_time[23]);
			~rain_maker_comb_synth.set(\tap_delay_25, delay_time[24]);
			~rain_maker_comb_synth.set(\tap_delay_26, delay_time[25]);
			~rain_maker_comb_synth.set(\tap_delay_27, delay_time[26]);
			~rain_maker_comb_synth.set(\tap_delay_28, delay_time[27]);
			~rain_maker_comb_synth.set(\tap_delay_29, delay_time[28]);
			~rain_maker_comb_synth.set(\tap_delay_30, delay_time[29]);
			~rain_maker_comb_synth.set(\tap_delay_31, delay_time[30]);
			~rain_maker_comb_synth.set(\tap_delay_32, delay_time[31]);
			~rain_maker_comb_synth.set(\tap_delay_33, delay_time[32]);
			~rain_maker_comb_synth.set(\tap_delay_34, delay_time[33]);
			~rain_maker_comb_synth.set(\tap_delay_35, delay_time[34]);
			~rain_maker_comb_synth.set(\tap_delay_36, delay_time[35]);
			~rain_maker_comb_synth.set(\tap_delay_37, delay_time[36]);
			~rain_maker_comb_synth.set(\tap_delay_38, delay_time[37]);
			~rain_maker_comb_synth.set(\tap_delay_39, delay_time[38]);
			~rain_maker_comb_synth.set(\tap_delay_40, delay_time[39]);
			~rain_maker_comb_synth.set(\tap_delay_41, delay_time[40]);
			~rain_maker_comb_synth.set(\tap_delay_42, delay_time[41]);
			~rain_maker_comb_synth.set(\tap_delay_43, delay_time[42]);
			~rain_maker_comb_synth.set(\tap_delay_44, delay_time[43]);
			~rain_maker_comb_synth.set(\tap_delay_45, delay_time[44]);
			~rain_maker_comb_synth.set(\tap_delay_46, delay_time[45]);
			~rain_maker_comb_synth.set(\tap_delay_47, delay_time[46]);
			~rain_maker_comb_synth.set(\tap_delay_48, delay_time[47]);
			~rain_maker_comb_synth.set(\tap_delay_49, delay_time[48]);
			~rain_maker_comb_synth.set(\tap_delay_50, delay_time[49]);
			~rain_maker_comb_synth.set(\tap_delay_51, delay_time[50]);
			~rain_maker_comb_synth.set(\tap_delay_52, delay_time[51]);
			~rain_maker_comb_synth.set(\tap_delay_53, delay_time[52]);
			~rain_maker_comb_synth.set(\tap_delay_54, delay_time[53]);
			~rain_maker_comb_synth.set(\tap_delay_55, delay_time[54]);
			~rain_maker_comb_synth.set(\tap_delay_56, delay_time[55]);
			~rain_maker_comb_synth.set(\tap_delay_57, delay_time[56]);
			~rain_maker_comb_synth.set(\tap_delay_58, delay_time[57]);
			~rain_maker_comb_synth.set(\tap_delay_59, delay_time[58]);
			~rain_maker_comb_synth.set(\tap_delay_60, delay_time[59]);
			~rain_maker_comb_synth.set(\tap_delay_61, delay_time[60]);
			~rain_maker_comb_synth.set(\tap_delay_62, delay_time[61]);
			~rain_maker_comb_synth.set(\tap_delay_63, delay_time[62]);
			~rain_maker_comb_synth.set(\tap_delay_64, delay_time[63]);
		}, {});
	});
	widgets[\c_combsize_clk_checkbox].action_({
		arg v;
		var multiplier, delay_time;
		widgets[\c_combsize_knob].enabled_(v.value.not);
		multiplier = switch (widgets[\c_div_popupmenu].value,
			0, {1},
			1, {2},
			2, {3},
			3, {4},
			4, {6},
			5, {8},
			6, {12},
			7, {16},
			8, {24},
			9, {32},
			10, {48},
			11, {64},
			12, {96},
			13, {128},
			14, {192},
			15, {256},
		);
		if (v.value, {
			delay_time = (60 / (widgets[\g_tempo_numberbox].value * multiplier)) * comb_patterns[widgets[\c_patt_popupmenu].value];
			value_static_texts[\c_combsize_static].string_((delay_time[63] * 1000).round(0.01).asString ++ " ms");
			~rain_maker_comb_synth.set(\tap_delay_01, delay_time[0]);
			~rain_maker_comb_synth.set(\tap_delay_02, delay_time[1]);
			~rain_maker_comb_synth.set(\tap_delay_03, delay_time[2]);
			~rain_maker_comb_synth.set(\tap_delay_04, delay_time[3]);
			~rain_maker_comb_synth.set(\tap_delay_05, delay_time[4]);
			~rain_maker_comb_synth.set(\tap_delay_06, delay_time[5]);
			~rain_maker_comb_synth.set(\tap_delay_07, delay_time[6]);
			~rain_maker_comb_synth.set(\tap_delay_08, delay_time[7]);
			~rain_maker_comb_synth.set(\tap_delay_09, delay_time[8]);
			~rain_maker_comb_synth.set(\tap_delay_10, delay_time[9]);
			~rain_maker_comb_synth.set(\tap_delay_11, delay_time[10]);
			~rain_maker_comb_synth.set(\tap_delay_12, delay_time[11]);
			~rain_maker_comb_synth.set(\tap_delay_13, delay_time[12]);
			~rain_maker_comb_synth.set(\tap_delay_14, delay_time[13]);
			~rain_maker_comb_synth.set(\tap_delay_15, delay_time[14]);
			~rain_maker_comb_synth.set(\tap_delay_16, delay_time[15]);
			~rain_maker_comb_synth.set(\tap_delay_17, delay_time[16]);
			~rain_maker_comb_synth.set(\tap_delay_18, delay_time[17]);
			~rain_maker_comb_synth.set(\tap_delay_19, delay_time[18]);
			~rain_maker_comb_synth.set(\tap_delay_20, delay_time[19]);
			~rain_maker_comb_synth.set(\tap_delay_21, delay_time[20]);
			~rain_maker_comb_synth.set(\tap_delay_22, delay_time[21]);
			~rain_maker_comb_synth.set(\tap_delay_23, delay_time[22]);
			~rain_maker_comb_synth.set(\tap_delay_24, delay_time[23]);
			~rain_maker_comb_synth.set(\tap_delay_25, delay_time[24]);
			~rain_maker_comb_synth.set(\tap_delay_26, delay_time[25]);
			~rain_maker_comb_synth.set(\tap_delay_27, delay_time[26]);
			~rain_maker_comb_synth.set(\tap_delay_28, delay_time[27]);
			~rain_maker_comb_synth.set(\tap_delay_29, delay_time[28]);
			~rain_maker_comb_synth.set(\tap_delay_30, delay_time[29]);
			~rain_maker_comb_synth.set(\tap_delay_31, delay_time[30]);
			~rain_maker_comb_synth.set(\tap_delay_32, delay_time[31]);
			~rain_maker_comb_synth.set(\tap_delay_33, delay_time[32]);
			~rain_maker_comb_synth.set(\tap_delay_34, delay_time[33]);
			~rain_maker_comb_synth.set(\tap_delay_35, delay_time[34]);
			~rain_maker_comb_synth.set(\tap_delay_36, delay_time[35]);
			~rain_maker_comb_synth.set(\tap_delay_37, delay_time[36]);
			~rain_maker_comb_synth.set(\tap_delay_38, delay_time[37]);
			~rain_maker_comb_synth.set(\tap_delay_39, delay_time[38]);
			~rain_maker_comb_synth.set(\tap_delay_40, delay_time[39]);
			~rain_maker_comb_synth.set(\tap_delay_41, delay_time[40]);
			~rain_maker_comb_synth.set(\tap_delay_42, delay_time[41]);
			~rain_maker_comb_synth.set(\tap_delay_43, delay_time[42]);
			~rain_maker_comb_synth.set(\tap_delay_44, delay_time[43]);
			~rain_maker_comb_synth.set(\tap_delay_45, delay_time[44]);
			~rain_maker_comb_synth.set(\tap_delay_46, delay_time[45]);
			~rain_maker_comb_synth.set(\tap_delay_47, delay_time[46]);
			~rain_maker_comb_synth.set(\tap_delay_48, delay_time[47]);
			~rain_maker_comb_synth.set(\tap_delay_49, delay_time[48]);
			~rain_maker_comb_synth.set(\tap_delay_50, delay_time[49]);
			~rain_maker_comb_synth.set(\tap_delay_51, delay_time[50]);
			~rain_maker_comb_synth.set(\tap_delay_52, delay_time[51]);
			~rain_maker_comb_synth.set(\tap_delay_53, delay_time[52]);
			~rain_maker_comb_synth.set(\tap_delay_54, delay_time[53]);
			~rain_maker_comb_synth.set(\tap_delay_55, delay_time[54]);
			~rain_maker_comb_synth.set(\tap_delay_56, delay_time[55]);
			~rain_maker_comb_synth.set(\tap_delay_57, delay_time[56]);
			~rain_maker_comb_synth.set(\tap_delay_58, delay_time[57]);
			~rain_maker_comb_synth.set(\tap_delay_59, delay_time[58]);
			~rain_maker_comb_synth.set(\tap_delay_60, delay_time[59]);
			~rain_maker_comb_synth.set(\tap_delay_61, delay_time[60]);
			~rain_maker_comb_synth.set(\tap_delay_62, delay_time[61]);
			~rain_maker_comb_synth.set(\tap_delay_63, delay_time[62]);
			~rain_maker_comb_synth.set(\tap_delay_64, delay_time[63]);
		}, {
			widgets[\c_combsize_knob].valueAction_(widgets[\c_combsize_knob].value);
		});
	});
	widgets[\c_mod_wave_popupmenu].items_(["Sinusoid", "Triangle", "Random"]).action_({
		arg v;
		~rain_maker_comb_synth.set(\mod_index, v.value);
	});
	widgets[\c_mod_level_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\c_mod_level_static].string_((v.value * 15 + 0).round(0.01).asString ++ " ms");
		~rain_maker_comb_synth.set(\mod_level, v.value);
	});
	widgets[\c_mod_rate_numberbox].clipLo_(0.1).clipHi_(20).decimals_(1).action_({
		arg v;
		~rain_maker_comb_synth.set(\mod_rate, v.value);
	});
	widgets[\c_fb_num_numberbox].clipLo_(1).clipHi_(64).decimals_(0).action_({
		arg v;
		~rain_maker_comb_synth.set(\selection_01, comb_tap_patterns[64 - v.value][0]);
		~rain_maker_comb_synth.set(\selection_02, comb_tap_patterns[64 - v.value][1]);
		~rain_maker_comb_synth.set(\selection_03, comb_tap_patterns[64 - v.value][2]);
		~rain_maker_comb_synth.set(\selection_04, comb_tap_patterns[64 - v.value][3]);
		~rain_maker_comb_synth.set(\selection_05, comb_tap_patterns[64 - v.value][4]);
		~rain_maker_comb_synth.set(\selection_06, comb_tap_patterns[64 - v.value][5]);
		~rain_maker_comb_synth.set(\selection_07, comb_tap_patterns[64 - v.value][6]);
		~rain_maker_comb_synth.set(\selection_08, comb_tap_patterns[64 - v.value][7]);
		~rain_maker_comb_synth.set(\selection_09, comb_tap_patterns[64 - v.value][8]);
		~rain_maker_comb_synth.set(\selection_10, comb_tap_patterns[64 - v.value][9]);
		~rain_maker_comb_synth.set(\selection_11, comb_tap_patterns[64 - v.value][10]);
		~rain_maker_comb_synth.set(\selection_12, comb_tap_patterns[64 - v.value][11]);
		~rain_maker_comb_synth.set(\selection_13, comb_tap_patterns[64 - v.value][12]);
		~rain_maker_comb_synth.set(\selection_14, comb_tap_patterns[64 - v.value][13]);
		~rain_maker_comb_synth.set(\selection_15, comb_tap_patterns[64 - v.value][14]);
		~rain_maker_comb_synth.set(\selection_16, comb_tap_patterns[64 - v.value][15]);
		~rain_maker_comb_synth.set(\selection_17, comb_tap_patterns[64 - v.value][16]);
		~rain_maker_comb_synth.set(\selection_18, comb_tap_patterns[64 - v.value][17]);
		~rain_maker_comb_synth.set(\selection_19, comb_tap_patterns[64 - v.value][18]);
		~rain_maker_comb_synth.set(\selection_20, comb_tap_patterns[64 - v.value][19]);
		~rain_maker_comb_synth.set(\selection_21, comb_tap_patterns[64 - v.value][20]);
		~rain_maker_comb_synth.set(\selection_22, comb_tap_patterns[64 - v.value][21]);
		~rain_maker_comb_synth.set(\selection_23, comb_tap_patterns[64 - v.value][22]);
		~rain_maker_comb_synth.set(\selection_24, comb_tap_patterns[64 - v.value][23]);
		~rain_maker_comb_synth.set(\selection_25, comb_tap_patterns[64 - v.value][24]);
		~rain_maker_comb_synth.set(\selection_26, comb_tap_patterns[64 - v.value][25]);
		~rain_maker_comb_synth.set(\selection_27, comb_tap_patterns[64 - v.value][26]);
		~rain_maker_comb_synth.set(\selection_28, comb_tap_patterns[64 - v.value][27]);
		~rain_maker_comb_synth.set(\selection_29, comb_tap_patterns[64 - v.value][28]);
		~rain_maker_comb_synth.set(\selection_30, comb_tap_patterns[64 - v.value][29]);
		~rain_maker_comb_synth.set(\selection_31, comb_tap_patterns[64 - v.value][30]);
		~rain_maker_comb_synth.set(\selection_32, comb_tap_patterns[64 - v.value][31]);
		~rain_maker_comb_synth.set(\selection_33, comb_tap_patterns[64 - v.value][32]);
		~rain_maker_comb_synth.set(\selection_34, comb_tap_patterns[64 - v.value][33]);
		~rain_maker_comb_synth.set(\selection_35, comb_tap_patterns[64 - v.value][34]);
		~rain_maker_comb_synth.set(\selection_36, comb_tap_patterns[64 - v.value][35]);
		~rain_maker_comb_synth.set(\selection_37, comb_tap_patterns[64 - v.value][36]);
		~rain_maker_comb_synth.set(\selection_38, comb_tap_patterns[64 - v.value][37]);
		~rain_maker_comb_synth.set(\selection_39, comb_tap_patterns[64 - v.value][38]);
		~rain_maker_comb_synth.set(\selection_40, comb_tap_patterns[64 - v.value][39]);
		~rain_maker_comb_synth.set(\selection_41, comb_tap_patterns[64 - v.value][40]);
		~rain_maker_comb_synth.set(\selection_42, comb_tap_patterns[64 - v.value][41]);
		~rain_maker_comb_synth.set(\selection_43, comb_tap_patterns[64 - v.value][42]);
		~rain_maker_comb_synth.set(\selection_44, comb_tap_patterns[64 - v.value][43]);
		~rain_maker_comb_synth.set(\selection_45, comb_tap_patterns[64 - v.value][44]);
		~rain_maker_comb_synth.set(\selection_46, comb_tap_patterns[64 - v.value][45]);
		~rain_maker_comb_synth.set(\selection_47, comb_tap_patterns[64 - v.value][46]);
		~rain_maker_comb_synth.set(\selection_48, comb_tap_patterns[64 - v.value][47]);
		~rain_maker_comb_synth.set(\selection_49, comb_tap_patterns[64 - v.value][48]);
		~rain_maker_comb_synth.set(\selection_50, comb_tap_patterns[64 - v.value][49]);
		~rain_maker_comb_synth.set(\selection_51, comb_tap_patterns[64 - v.value][50]);
		~rain_maker_comb_synth.set(\selection_52, comb_tap_patterns[64 - v.value][51]);
		~rain_maker_comb_synth.set(\selection_53, comb_tap_patterns[64 - v.value][52]);
		~rain_maker_comb_synth.set(\selection_54, comb_tap_patterns[64 - v.value][53]);
		~rain_maker_comb_synth.set(\selection_55, comb_tap_patterns[64 - v.value][54]);
		~rain_maker_comb_synth.set(\selection_56, comb_tap_patterns[64 - v.value][55]);
		~rain_maker_comb_synth.set(\selection_57, comb_tap_patterns[64 - v.value][56]);
		~rain_maker_comb_synth.set(\selection_58, comb_tap_patterns[64 - v.value][57]);
		~rain_maker_comb_synth.set(\selection_59, comb_tap_patterns[64 - v.value][58]);
		~rain_maker_comb_synth.set(\selection_60, comb_tap_patterns[64 - v.value][59]);
		~rain_maker_comb_synth.set(\selection_61, comb_tap_patterns[64 - v.value][60]);
		~rain_maker_comb_synth.set(\selection_62, comb_tap_patterns[64 - v.value][61]);
		~rain_maker_comb_synth.set(\selection_63, comb_tap_patterns[64 - v.value][62]);
		~rain_maker_comb_synth.set(\selection_64, comb_tap_patterns[64 - v.value][63]);
	});
	widgets[\g_routing_popupmenu].items_(["Delay", "Comb", "Delay -> Comb", "Delay | Comb"]).action_({
		arg v;
		switch (v.value,
			0, {
				~rain_maker_delay_synth.set(\input_bus, ~rain_maker_bus);
				~rain_maker_delay_synth.set(\output_bus, ~rain_maker_out_bus);
				~rain_maker_comb_synth.set(\input_bus, ~rain_maker_bus);
				~rain_maker_comb_synth.set(\output_bus, ~rain_maker_tmp_bus);
			},
			1, {
				~rain_maker_delay_synth.set(\input_bus, ~rain_maker_bus);
				~rain_maker_delay_synth.set(\output_bus, ~rain_maker_tmp_bus);
				~rain_maker_comb_synth.set(\input_bus, ~rain_maker_bus);
				~rain_maker_comb_synth.set(\output_bus, ~rain_maker_out_bus);
			},
			2, {
				~rain_maker_delay_synth.set(\input_bus, ~rain_maker_bus);
				~rain_maker_delay_synth.set(\output_bus, ~rain_maker_tmp_bus);
				~rain_maker_comb_synth.set(\input_bus, ~rain_maker_tmp_bus);
				~rain_maker_comb_synth.set(\output_bus, ~rain_maker_out_bus);
			},
			3, {
				~rain_maker_delay_synth.set(\input_bus, ~rain_maker_bus);
				~rain_maker_delay_synth.set(\output_bus, ~rain_maker_out_bus);
				~rain_maker_comb_synth.set(\input_bus, ~rain_maker_bus);
				~rain_maker_comb_synth.set(\output_bus, ~rain_maker_out_bus);
			},
		);
	});
	widgets[\g_mix_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\g_mix_static].string_(((v.value * 1 + 0).round(0.01) * 100).asInteger.asString ++ "%");
		~rain_maker_delay_synth.set(\global_mix, v.value);
	});
	widgets[\g_tempo_numberbox].clipLo_(5).clipHi_(999).decimals_(0).action_({
		arg v;
		widgets[\d_time_clk_checkbox].valueAction_(widgets[\d_time_clk_checkbox].value);
		widgets[\c_combsize_clk_checkbox].valueAction_(widgets[\c_combsize_clk_checkbox].value);
	});
	widgets[\d_tap_1_mute_checkbox].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_gate_01, v.value.not.asInteger);
	});
	widgets[\d_tap_1_pan_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_1_pan_static].string_((v.value * 2 + -1).round(0.01).asString);
		~rain_maker_delay_synth.set(\tap_pan_01, (v.value * 2 + -1));
	});
	widgets[\d_tap_1_flttype_popupmenu].items_(["LP", "HP", "BP"]).action_({
		arg v;
		var coeff_value;
		coeff_value = switch (v.value,
			0, {~lpf_2nd_coeff.value((widgets[\d_tap_1_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_1_fltq_knob].value))))},
			1, {~hpf_2nd_coeff.value((widgets[\d_tap_1_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_1_fltq_knob].value))))},
			2, {~bpf_2nd_coeff.value((widgets[\d_tap_1_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_1_fltq_knob].value))))}
		);
		~rain_maker_delay_synth.set(\tap_coeff_a0_01, coeff_value[0]);
		~rain_maker_delay_synth.set(\tap_coeff_a1_01, coeff_value[1]);
		~rain_maker_delay_synth.set(\tap_coeff_a2_01, coeff_value[2]);
		~rain_maker_delay_synth.set(\tap_coeff_b1_01, coeff_value[3]);
		~rain_maker_delay_synth.set(\tap_coeff_b2_01, coeff_value[4]);
	});
	widgets[\d_tap_1_fltcut_knob].mode_(\vert).keystep_(0.000050050).step_(0.000050050).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_1_fltcut_static].string_(v.value.linexp(0, 1, 20, 20000).round(1).asInteger.asString ++ " Hz");
		widgets[\d_tap_1_flttype_popupmenu].valueAction_(widgets[\d_tap_1_flttype_popupmenu].value);
	});
	widgets[\d_tap_1_fltq_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_1_fltq_static].string_((0.1 * (10 ** (2 * v.value))).round(0.1).asString);
		widgets[\d_tap_1_flttype_popupmenu].valueAction_(widgets[\d_tap_1_flttype_popupmenu].value);
	});
	widgets[\d_tap_1_ps_knob].mode_(\vert).keystep_(0.032258065).step_(0.032258065).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_1_ps_static].string_((v.value * 31 + -16).round(1).asInteger.asString);
		~rain_maker_delay_synth.set(\tap_pitchshift_01, (v.value * 31 + -16).round(1).asInteger);
	});
	widgets[\d_tap_1_level_slider].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_level_01, v.value);
	});
	widgets[\d_tap_2_mute_checkbox].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_gate_02, v.value.not.asInteger);
	});
	widgets[\d_tap_2_pan_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_2_pan_static].string_((v.value * 2 + -1).round(0.01).asString);
		~rain_maker_delay_synth.set(\tap_pan_02, (v.value * 2 + -1));
	});
	widgets[\d_tap_2_flttype_popupmenu].items_(["LP", "HP", "BP"]).action_({
		arg v;
		var coeff_value;
		coeff_value = switch (v.value,
			0, {~lpf_2nd_coeff.value((widgets[\d_tap_2_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_2_fltq_knob].value))))},
			1, {~hpf_2nd_coeff.value((widgets[\d_tap_2_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_2_fltq_knob].value))))},
			2, {~bpf_2nd_coeff.value((widgets[\d_tap_2_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_2_fltq_knob].value))))}
		);
		~rain_maker_delay_synth.set(\tap_coeff_a0_02, coeff_value[0]);
		~rain_maker_delay_synth.set(\tap_coeff_a1_02, coeff_value[1]);
		~rain_maker_delay_synth.set(\tap_coeff_a2_02, coeff_value[2]);
		~rain_maker_delay_synth.set(\tap_coeff_b1_02, coeff_value[3]);
		~rain_maker_delay_synth.set(\tap_coeff_b2_02, coeff_value[4]);
	});
	widgets[\d_tap_2_fltcut_knob].mode_(\vert).keystep_(0.000050050).step_(0.000050050).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_2_fltcut_static].string_((v.value.linexp(0, 1, 20, 20000)).round(1).asInteger.asString ++ " Hz");
		widgets[\d_tap_2_flttype_popupmenu].valueAction_(widgets[\d_tap_2_flttype_popupmenu].value);
	});
	widgets[\d_tap_2_fltq_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_2_fltq_static].string_((0.1 * (10 ** (2 * v.value))).round(0.1).asString);
		widgets[\d_tap_2_flttype_popupmenu].valueAction_(widgets[\d_tap_2_flttype_popupmenu].value);
	});
	widgets[\d_tap_2_ps_knob].mode_(\vert).keystep_(0.032258065).step_(0.032258065).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_2_ps_static].string_((v.value * 31 + -16).round(1).asInteger.asString);
		~rain_maker_delay_synth.set(\tap_pitchshift_02, (v.value * 31 + -16).round(1).asInteger);
	});
	widgets[\d_tap_2_level_slider].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_level_02, v.value);
	});
	widgets[\d_tap_3_mute_checkbox].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_gate_03, v.value.not.asInteger);
	});
	widgets[\d_tap_3_pan_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_3_pan_static].string_((v.value * 2 + -1).round(0.01).asString);
		~rain_maker_delay_synth.set(\tap_pan_03, (v.value * 2 + -1));
	});
	widgets[\d_tap_3_flttype_popupmenu].items_(["LP", "HP", "BP"]).action_({
		arg v;
		var coeff_value;
		coeff_value = switch (v.value,
			0, {~lpf_2nd_coeff.value((widgets[\d_tap_3_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_3_fltq_knob].value))))},
			1, {~hpf_2nd_coeff.value((widgets[\d_tap_3_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_3_fltq_knob].value))))},
			2, {~bpf_2nd_coeff.value((widgets[\d_tap_3_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_3_fltq_knob].value))))}
		);
		~rain_maker_delay_synth.set(\tap_coeff_a0_03, coeff_value[0]);
		~rain_maker_delay_synth.set(\tap_coeff_a1_03, coeff_value[1]);
		~rain_maker_delay_synth.set(\tap_coeff_a2_03, coeff_value[2]);
		~rain_maker_delay_synth.set(\tap_coeff_b1_03, coeff_value[3]);
		~rain_maker_delay_synth.set(\tap_coeff_b2_03, coeff_value[4]);
	});
	widgets[\d_tap_3_fltcut_knob].mode_(\vert).keystep_(0.000050050).step_(0.000050050).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_3_fltcut_static].string_((v.value.linexp(0, 1, 20, 20000)).round(1).asInteger.asString ++ " Hz");
		widgets[\d_tap_3_flttype_popupmenu].valueAction_(widgets[\d_tap_3_flttype_popupmenu].value);
	});
	widgets[\d_tap_3_fltq_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_3_fltq_static].string_((0.1 * (10 ** (2 * v.value))).round(0.1).asString);
		widgets[\d_tap_3_flttype_popupmenu].valueAction_(widgets[\d_tap_3_flttype_popupmenu].value);
	});
	widgets[\d_tap_3_ps_knob].mode_(\vert).keystep_(0.032258065).step_(0.032258065).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_3_ps_static].string_((v.value * 31 + -16).round(1).asInteger.asString);
		~rain_maker_delay_synth.set(\tap_pitchshift_03, (v.value * 31 + -16).round(1).asInteger);
	});
	widgets[\d_tap_3_level_slider].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_level_03, v.value);
	});
	widgets[\d_tap_4_mute_checkbox].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_gate_04, v.value.not.asInteger);
	});
	widgets[\d_tap_4_pan_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_4_pan_static].string_((v.value * 2 + -1).round(0.01).asString);
		~rain_maker_delay_synth.set(\tap_pan_04, (v.value * 2 + -1));
	});
	widgets[\d_tap_4_flttype_popupmenu].items_(["LP", "HP", "BP"]).action_({
		arg v;
		var coeff_value;
		coeff_value = switch (v.value,
			0, {~lpf_2nd_coeff.value((widgets[\d_tap_4_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_4_fltq_knob].value))))},
			1, {~hpf_2nd_coeff.value((widgets[\d_tap_4_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_4_fltq_knob].value))))},
			2, {~bpf_2nd_coeff.value((widgets[\d_tap_4_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_4_fltq_knob].value))))}
		);
		~rain_maker_delay_synth.set(\tap_coeff_a0_04, coeff_value[0]);
		~rain_maker_delay_synth.set(\tap_coeff_a1_04, coeff_value[1]);
		~rain_maker_delay_synth.set(\tap_coeff_a2_04, coeff_value[2]);
		~rain_maker_delay_synth.set(\tap_coeff_b1_04, coeff_value[3]);
		~rain_maker_delay_synth.set(\tap_coeff_b2_04, coeff_value[4]);
	});
	widgets[\d_tap_4_fltcut_knob].mode_(\vert).keystep_(0.000050050).step_(0.000050050).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_4_fltcut_static].string_((v.value.linexp(0, 1, 20, 20000)).round(1).asInteger.asString ++ " Hz");
		widgets[\d_tap_4_flttype_popupmenu].valueAction_(widgets[\d_tap_4_flttype_popupmenu].value);
	});
	widgets[\d_tap_4_fltq_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_4_fltq_static].string_((0.1 * (10 ** (2 * v.value))).round(0.1).asString);
		widgets[\d_tap_4_flttype_popupmenu].valueAction_(widgets[\d_tap_4_flttype_popupmenu].value);
	});
	widgets[\d_tap_4_ps_knob].mode_(\vert).keystep_(0.032258065).step_(0.032258065).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_4_ps_static].string_((v.value * 31 + -16).round(1).asInteger.asString);
		~rain_maker_delay_synth.set(\tap_pitchshift_04, (v.value * 31 + -16).round(1).asInteger);
	});
	widgets[\d_tap_4_level_slider].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_level_04, v.value);
	});
	widgets[\d_tap_5_mute_checkbox].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_gate_05, v.value.not.asInteger);
	});
	widgets[\d_tap_5_pan_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_5_pan_static].string_((v.value * 2 + -1).round(0.01).asString);
		~rain_maker_delay_synth.set(\tap_pan_05, (v.value * 2 + -1));
	});
	widgets[\d_tap_5_flttype_popupmenu].items_(["LP", "HP", "BP"]).action_({
		arg v;
		var coeff_value;
		coeff_value = switch (v.value,
			0, {~lpf_2nd_coeff.value((widgets[\d_tap_5_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_5_fltq_knob].value))))},
			1, {~hpf_2nd_coeff.value((widgets[\d_tap_5_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_5_fltq_knob].value))))},
			2, {~bpf_2nd_coeff.value((widgets[\d_tap_5_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_5_fltq_knob].value))))}
		);
		~rain_maker_delay_synth.set(\tap_coeff_a0_05, coeff_value[0]);
		~rain_maker_delay_synth.set(\tap_coeff_a1_05, coeff_value[1]);
		~rain_maker_delay_synth.set(\tap_coeff_a2_05, coeff_value[2]);
		~rain_maker_delay_synth.set(\tap_coeff_b1_05, coeff_value[3]);
		~rain_maker_delay_synth.set(\tap_coeff_b2_05, coeff_value[4]);
	});
	widgets[\d_tap_5_fltcut_knob].mode_(\vert).keystep_(0.000050050).step_(0.000050050).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_5_fltcut_static].string_((v.value.linexp(0, 1, 20, 20000)).round(1).asInteger.asString ++ " Hz");
		widgets[\d_tap_5_flttype_popupmenu].valueAction_(widgets[\d_tap_5_flttype_popupmenu].value);
	});
	widgets[\d_tap_5_fltq_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_5_fltq_static].string_((0.1 * (10 ** (2 * v.value))).round(0.1).asString);
		widgets[\d_tap_5_flttype_popupmenu].valueAction_(widgets[\d_tap_5_flttype_popupmenu].value);
	});
	widgets[\d_tap_5_ps_knob].mode_(\vert).keystep_(0.032258065).step_(0.032258065).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_5_ps_static].string_((v.value * 31 + -16).round(1).asInteger.asString);
		~rain_maker_delay_synth.set(\tap_pitchshift_05, (v.value * 31 + -16).round(1).asInteger);
	});
	widgets[\d_tap_5_level_slider].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_level_05, v.value);
	});
	widgets[\d_tap_6_mute_checkbox].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_gate_06, v.value.not.asInteger);
	});
	widgets[\d_tap_6_pan_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_6_pan_static].string_((v.value * 2 + -1).round(0.01).asString);
		~rain_maker_delay_synth.set(\tap_pan_06, (v.value * 2 + -1));
	});
	widgets[\d_tap_6_flttype_popupmenu].items_(["LP", "HP", "BP"]).action_({
		arg v;
		var coeff_value;
		coeff_value = switch (v.value,
			0, {~lpf_2nd_coeff.value((widgets[\d_tap_6_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_6_fltq_knob].value))))},
			1, {~hpf_2nd_coeff.value((widgets[\d_tap_6_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_6_fltq_knob].value))))},
			2, {~bpf_2nd_coeff.value((widgets[\d_tap_6_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_6_fltq_knob].value))))}
		);
		~rain_maker_delay_synth.set(\tap_coeff_a0_06, coeff_value[0]);
		~rain_maker_delay_synth.set(\tap_coeff_a1_06, coeff_value[1]);
		~rain_maker_delay_synth.set(\tap_coeff_a2_06, coeff_value[2]);
		~rain_maker_delay_synth.set(\tap_coeff_b1_06, coeff_value[3]);
		~rain_maker_delay_synth.set(\tap_coeff_b2_06, coeff_value[4]);
	});
	widgets[\d_tap_6_fltcut_knob].mode_(\vert).keystep_(0.000050050).step_(0.000050050).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_6_fltcut_static].string_((v.value.linexp(0, 1, 20, 20000)).round(1).asInteger.asString ++ " Hz");
		widgets[\d_tap_6_flttype_popupmenu].valueAction_(widgets[\d_tap_6_flttype_popupmenu].value);
	});
	widgets[\d_tap_6_fltq_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_6_fltq_static].string_((0.1 * (10 ** (2 * v.value))).round(0.1).asString);
		widgets[\d_tap_6_flttype_popupmenu].valueAction_(widgets[\d_tap_6_flttype_popupmenu].value);
	});
	widgets[\d_tap_6_ps_knob].mode_(\vert).keystep_(0.032258065).step_(0.032258065).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_6_ps_static].string_((v.value * 31 + -16).round(1).asInteger.asString);
		~rain_maker_delay_synth.set(\tap_pitchshift_06, (v.value * 31 + -16).round(1).asInteger);
	});
	widgets[\d_tap_6_level_slider].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_level_06, v.value);
	});
	widgets[\d_tap_7_mute_checkbox].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_gate_07, v.value.not.asInteger);
	});
	widgets[\d_tap_7_pan_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_7_pan_static].string_((v.value * 2 + -1).round(0.01).asString);
		~rain_maker_delay_synth.set(\tap_pan_07, (v.value * 2 + -1));
	});
	widgets[\d_tap_7_flttype_popupmenu].items_(["LP", "HP", "BP"]).action_({
		arg v;
		var coeff_value;
		coeff_value = switch (v.value,
			0, {~lpf_2nd_coeff.value((widgets[\d_tap_7_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_7_fltq_knob].value))))},
			1, {~hpf_2nd_coeff.value((widgets[\d_tap_7_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_7_fltq_knob].value))))},
			2, {~bpf_2nd_coeff.value((widgets[\d_tap_7_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_7_fltq_knob].value))))}
		);
		~rain_maker_delay_synth.set(\tap_coeff_a0_07, coeff_value[0]);
		~rain_maker_delay_synth.set(\tap_coeff_a1_07, coeff_value[1]);
		~rain_maker_delay_synth.set(\tap_coeff_a2_07, coeff_value[2]);
		~rain_maker_delay_synth.set(\tap_coeff_b1_07, coeff_value[3]);
		~rain_maker_delay_synth.set(\tap_coeff_b2_07, coeff_value[4]);
	});
	widgets[\d_tap_7_fltcut_knob].mode_(\vert).keystep_(0.000050050).step_(0.000050050).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_7_fltcut_static].string_((v.value.linexp(0, 1, 20, 20000)).round(1).asInteger.asString ++ " Hz");
		widgets[\d_tap_7_flttype_popupmenu].valueAction_(widgets[\d_tap_7_flttype_popupmenu].value);
	});
	widgets[\d_tap_7_fltq_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_7_fltq_static].string_((0.1 * (10 ** (2 * v.value))).round(0.1).asString);
		widgets[\d_tap_7_flttype_popupmenu].valueAction_(widgets[\d_tap_7_flttype_popupmenu].value);
	});
	widgets[\d_tap_7_ps_knob].mode_(\vert).keystep_(0.032258065).step_(0.032258065).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_7_ps_static].string_((v.value * 31 + -16).round(1).asInteger.asString);
		~rain_maker_delay_synth.set(\tap_pitchshift_07, (v.value * 31 + -16).round(1).asInteger);
	});
	widgets[\d_tap_7_level_slider].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_level_07, v.value);
	});
	widgets[\d_tap_8_mute_checkbox].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_gate_08, v.value.not.asInteger);
	});
	widgets[\d_tap_8_pan_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_8_pan_static].string_((v.value * 2 + -1).round(0.01).asString);
		~rain_maker_delay_synth.set(\tap_pan_08, (v.value * 2 + -1));
	});
	widgets[\d_tap_8_flttype_popupmenu].items_(["LP", "HP", "BP"]).action_({
		arg v;
		var coeff_value;
		coeff_value = switch (v.value,
			0, {~lpf_2nd_coeff.value((widgets[\d_tap_8_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_8_fltq_knob].value))))},
			1, {~hpf_2nd_coeff.value((widgets[\d_tap_8_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_8_fltq_knob].value))))},
			2, {~bpf_2nd_coeff.value((widgets[\d_tap_8_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_8_fltq_knob].value))))}
		);
		~rain_maker_delay_synth.set(\tap_coeff_a0_08, coeff_value[0]);
		~rain_maker_delay_synth.set(\tap_coeff_a1_08, coeff_value[1]);
		~rain_maker_delay_synth.set(\tap_coeff_a2_08, coeff_value[2]);
		~rain_maker_delay_synth.set(\tap_coeff_b1_08, coeff_value[3]);
		~rain_maker_delay_synth.set(\tap_coeff_b2_08, coeff_value[4]);
	});
	widgets[\d_tap_8_fltcut_knob].mode_(\vert).keystep_(0.000050050).step_(0.000050050).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_8_fltcut_static].string_((v.value.linexp(0, 1, 20, 20000)).round(1).asInteger.asString ++ " Hz");
		widgets[\d_tap_8_flttype_popupmenu].valueAction_(widgets[\d_tap_8_flttype_popupmenu].value);
	});
	widgets[\d_tap_8_fltq_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_8_fltq_static].string_((0.1 * (10 ** (2 * v.value))).round(0.1).asString);
		widgets[\d_tap_8_flttype_popupmenu].valueAction_(widgets[\d_tap_8_flttype_popupmenu].value);
	});
	widgets[\d_tap_8_ps_knob].mode_(\vert).keystep_(0.032258065).step_(0.032258065).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_8_ps_static].string_((v.value * 31 + -16).round(1).asInteger.asString);
		~rain_maker_delay_synth.set(\tap_pitchshift_08, (v.value * 31 + -16).round(1).asInteger);
	});
	widgets[\d_tap_8_level_slider].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_level_08, v.value);
	});
	widgets[\d_tap_9_mute_checkbox].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_gate_09, v.value.not.asInteger);
	});
	widgets[\d_tap_9_pan_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_9_pan_static].string_((v.value * 2 + -1).round(0.01).asString);
		~rain_maker_delay_synth.set(\tap_pan_09, (v.value * 2 + -1));
	});
	widgets[\d_tap_9_flttype_popupmenu].items_(["LP", "HP", "BP"]).action_({
		arg v;
		var coeff_value;
		coeff_value = switch (v.value,
			0, {~lpf_2nd_coeff.value((widgets[\d_tap_9_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_9_fltq_knob].value))))},
			1, {~hpf_2nd_coeff.value((widgets[\d_tap_9_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_9_fltq_knob].value))))},
			2, {~bpf_2nd_coeff.value((widgets[\d_tap_9_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_9_fltq_knob].value))))}
		);
		~rain_maker_delay_synth.set(\tap_coeff_a0_09, coeff_value[0]);
		~rain_maker_delay_synth.set(\tap_coeff_a1_09, coeff_value[1]);
		~rain_maker_delay_synth.set(\tap_coeff_a2_09, coeff_value[2]);
		~rain_maker_delay_synth.set(\tap_coeff_b1_09, coeff_value[3]);
		~rain_maker_delay_synth.set(\tap_coeff_b2_09, coeff_value[4]);
	});
	widgets[\d_tap_9_fltcut_knob].mode_(\vert).keystep_(0.000050050).step_(0.000050050).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_9_fltcut_static].string_((v.value.linexp(0, 1, 20, 20000)).round(1).asInteger.asString ++ " Hz");
		widgets[\d_tap_9_flttype_popupmenu].valueAction_(widgets[\d_tap_9_flttype_popupmenu].value);
	});
	widgets[\d_tap_9_fltq_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_9_fltq_static].string_((0.1 * (10 ** (2 * v.value))).round(0.1).asString);
		widgets[\d_tap_9_flttype_popupmenu].valueAction_(widgets[\d_tap_9_flttype_popupmenu].value);
	});
	widgets[\d_tap_9_ps_knob].mode_(\vert).keystep_(0.032258065).step_(0.032258065).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_9_ps_static].string_((v.value * 31 + -16).round(1).asInteger.asString);
		~rain_maker_delay_synth.set(\tap_pitchshift_09, (v.value * 31 + -16).round(1).asInteger);
	});
	widgets[\d_tap_9_level_slider].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_level_09, v.value);
	});
	widgets[\d_tap_10_mute_checkbox].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_gate_10, v.value.not.asInteger);
	});
	widgets[\d_tap_10_pan_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_10_pan_static].string_((v.value * 2 + -1).round(0.01).asString);
		~rain_maker_delay_synth.set(\tap_pan_10, (v.value * 2 + -1));
	});
	widgets[\d_tap_10_flttype_popupmenu].items_(["LP", "HP", "BP"]).action_({
		arg v;
		var coeff_value;
		coeff_value = switch (v.value,
			0, {~lpf_2nd_coeff.value((widgets[\d_tap_10_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_10_fltq_knob].value))))},
			1, {~hpf_2nd_coeff.value((widgets[\d_tap_10_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_10_fltq_knob].value))))},
			2, {~bpf_2nd_coeff.value((widgets[\d_tap_10_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_10_fltq_knob].value))))}
		);
		~rain_maker_delay_synth.set(\tap_coeff_a0_10, coeff_value[0]);
		~rain_maker_delay_synth.set(\tap_coeff_a1_10, coeff_value[1]);
		~rain_maker_delay_synth.set(\tap_coeff_a2_10, coeff_value[2]);
		~rain_maker_delay_synth.set(\tap_coeff_b1_10, coeff_value[3]);
		~rain_maker_delay_synth.set(\tap_coeff_b2_10, coeff_value[4]);
	});
	widgets[\d_tap_10_fltcut_knob].mode_(\vert).keystep_(0.000050050).step_(0.000050050).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_10_fltcut_static].string_((v.value.linexp(0, 1, 20, 20000)).round(1).asInteger.asString ++ " Hz");
		widgets[\d_tap_10_flttype_popupmenu].valueAction_(widgets[\d_tap_10_flttype_popupmenu].value);
	});
	widgets[\d_tap_10_fltq_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_10_fltq_static].string_((0.1 * (10 ** (2 * v.value))).round(0.1).asString);
		widgets[\d_tap_10_flttype_popupmenu].valueAction_(widgets[\d_tap_10_flttype_popupmenu].value);
	});
	widgets[\d_tap_10_ps_knob].mode_(\vert).keystep_(0.032258065).step_(0.032258065).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_10_ps_static].string_((v.value * 31 + -16).round(1).asInteger.asString);
		~rain_maker_delay_synth.set(\tap_pitchshift_10, (v.value * 31 + -16).round(1).asInteger);
	});
	widgets[\d_tap_10_level_slider].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_level_10, v.value);
	});
	widgets[\d_tap_11_mute_checkbox].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_gate_11, v.value.not.asInteger);
	});
	widgets[\d_tap_11_pan_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_11_pan_static].string_((v.value * 2 + -1).round(0.01).asString);
		~rain_maker_delay_synth.set(\tap_pan_11, (v.value * 2 + -1));
	});
	widgets[\d_tap_11_flttype_popupmenu].items_(["LP", "HP", "BP"]).action_({
		arg v;
		var coeff_value;
		coeff_value = switch (v.value,
			0, {~lpf_2nd_coeff.value((widgets[\d_tap_11_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_11_fltq_knob].value))))},
			1, {~hpf_2nd_coeff.value((widgets[\d_tap_11_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_11_fltq_knob].value))))},
			2, {~bpf_2nd_coeff.value((widgets[\d_tap_11_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_11_fltq_knob].value))))}
		);
		~rain_maker_delay_synth.set(\tap_coeff_a0_11, coeff_value[0]);
		~rain_maker_delay_synth.set(\tap_coeff_a1_11, coeff_value[1]);
		~rain_maker_delay_synth.set(\tap_coeff_a2_11, coeff_value[2]);
		~rain_maker_delay_synth.set(\tap_coeff_b1_11, coeff_value[3]);
		~rain_maker_delay_synth.set(\tap_coeff_b2_11, coeff_value[4]);
	});
	widgets[\d_tap_11_fltcut_knob].mode_(\vert).keystep_(0.000050050).step_(0.000050050).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_11_fltcut_static].string_((v.value.linexp(0, 1, 20, 20000)).round(1).asInteger.asString ++ " Hz");
		widgets[\d_tap_11_flttype_popupmenu].valueAction_(widgets[\d_tap_11_flttype_popupmenu].value);
	});
	widgets[\d_tap_11_fltq_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_11_fltq_static].string_((0.1 * (10 ** (2 * v.value))).round(0.1).asString);
		widgets[\d_tap_11_flttype_popupmenu].valueAction_(widgets[\d_tap_11_flttype_popupmenu].value);
	});
	widgets[\d_tap_11_ps_knob].mode_(\vert).keystep_(0.032258065).step_(0.032258065).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_11_ps_static].string_((v.value * 31 + -16).round(1).asInteger.asString);
		~rain_maker_delay_synth.set(\tap_pitchshift_11, (v.value * 31 + -16).round(1).asInteger);
	});
	widgets[\d_tap_11_level_slider].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_level_11, v.value);
	});
	widgets[\d_tap_12_mute_checkbox].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_gate_12, v.value.not.asInteger);
	});
	widgets[\d_tap_12_pan_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_12_pan_static].string_((v.value * 2 + -1).round(0.01).asString);
		~rain_maker_delay_synth.set(\tap_pan_12, (v.value * 2 + -1));
	});
	widgets[\d_tap_12_flttype_popupmenu].items_(["LP", "HP", "BP"]).action_({
		arg v;
		var coeff_value;
		coeff_value = switch (v.value,
			0, {~lpf_2nd_coeff.value((widgets[\d_tap_12_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_12_fltq_knob].value))))},
			1, {~hpf_2nd_coeff.value((widgets[\d_tap_12_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_12_fltq_knob].value))))},
			2, {~bpf_2nd_coeff.value((widgets[\d_tap_12_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_12_fltq_knob].value))))}
		);
		~rain_maker_delay_synth.set(\tap_coeff_a0_12, coeff_value[0]);
		~rain_maker_delay_synth.set(\tap_coeff_a1_12, coeff_value[1]);
		~rain_maker_delay_synth.set(\tap_coeff_a2_12, coeff_value[2]);
		~rain_maker_delay_synth.set(\tap_coeff_b1_12, coeff_value[3]);
		~rain_maker_delay_synth.set(\tap_coeff_b2_12, coeff_value[4]);
	});
	widgets[\d_tap_12_fltcut_knob].mode_(\vert).keystep_(0.000050050).step_(0.000050050).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_12_fltcut_static].string_((v.value.linexp(0, 1, 20, 20000)).round(1).asInteger.asString ++ " Hz");
		widgets[\d_tap_12_flttype_popupmenu].valueAction_(widgets[\d_tap_12_flttype_popupmenu].value);
	});
	widgets[\d_tap_12_fltq_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_12_fltq_static].string_((0.1 * (10 ** (2 * v.value))).round(0.1).asString);
		widgets[\d_tap_12_flttype_popupmenu].valueAction_(widgets[\d_tap_12_flttype_popupmenu].value);
	});
	widgets[\d_tap_12_ps_knob].mode_(\vert).keystep_(0.032258065).step_(0.032258065).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_12_ps_static].string_((v.value * 31 + -16).round(1).asInteger.asString);
		~rain_maker_delay_synth.set(\tap_pitchshift_12, (v.value * 31 + -16).round(1).asInteger);
	});
	widgets[\d_tap_12_level_slider].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_level_12, v.value);
	});
	widgets[\d_tap_13_mute_checkbox].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_gate_13, v.value.not.asInteger);
	});
	widgets[\d_tap_13_pan_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_13_pan_static].string_((v.value * 2 + -1).round(0.01).asString);
		~rain_maker_delay_synth.set(\tap_pan_13, (v.value * 2 + -1));
	});
	widgets[\d_tap_13_flttype_popupmenu].items_(["LP", "HP", "BP"]).action_({
		arg v;
		var coeff_value;
		coeff_value = switch (v.value,
			0, {~lpf_2nd_coeff.value((widgets[\d_tap_13_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_13_fltq_knob].value))))},
			1, {~hpf_2nd_coeff.value((widgets[\d_tap_13_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_13_fltq_knob].value))))},
			2, {~bpf_2nd_coeff.value((widgets[\d_tap_13_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_13_fltq_knob].value))))}
		);
		~rain_maker_delay_synth.set(\tap_coeff_a0_13, coeff_value[0]);
		~rain_maker_delay_synth.set(\tap_coeff_a1_13, coeff_value[1]);
		~rain_maker_delay_synth.set(\tap_coeff_a2_13, coeff_value[2]);
		~rain_maker_delay_synth.set(\tap_coeff_b1_13, coeff_value[3]);
		~rain_maker_delay_synth.set(\tap_coeff_b2_13, coeff_value[4]);
	});
	widgets[\d_tap_13_fltcut_knob].mode_(\vert).keystep_(0.000050050).step_(0.000050050).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_13_fltcut_static].string_((v.value.linexp(0, 1, 20, 20000)).round(1).asInteger.asString ++ " Hz");
		widgets[\d_tap_13_flttype_popupmenu].valueAction_(widgets[\d_tap_13_flttype_popupmenu].value);
	});
	widgets[\d_tap_13_fltq_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_13_fltq_static].string_((0.1 * (10 ** (2 * v.value))).round(0.1).asString);
		widgets[\d_tap_13_flttype_popupmenu].valueAction_(widgets[\d_tap_13_flttype_popupmenu].value);
	});
	widgets[\d_tap_13_ps_knob].mode_(\vert).keystep_(0.032258065).step_(0.032258065).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_13_ps_static].string_((v.value * 31 + -16).round(1).asInteger.asString);
		~rain_maker_delay_synth.set(\tap_pitchshift_13, (v.value * 31 + -16).round(1).asInteger);
	});
	widgets[\d_tap_13_level_slider].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_level_13, v.value);
	});
	widgets[\d_tap_14_mute_checkbox].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_gate_14, v.value.not.asInteger);
	});
	widgets[\d_tap_14_pan_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_14_pan_static].string_((v.value * 2 + -1).round(0.01).asString);
		~rain_maker_delay_synth.set(\tap_pan_14, (v.value * 2 + -1));
	});
	widgets[\d_tap_14_flttype_popupmenu].items_(["LP", "HP", "BP"]).action_({
		arg v;
		var coeff_value;
		coeff_value = switch (v.value,
			0, {~lpf_2nd_coeff.value((widgets[\d_tap_14_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_14_fltq_knob].value))))},
			1, {~hpf_2nd_coeff.value((widgets[\d_tap_14_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_14_fltq_knob].value))))},
			2, {~bpf_2nd_coeff.value((widgets[\d_tap_14_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_14_fltq_knob].value))))}
		);
		~rain_maker_delay_synth.set(\tap_coeff_a0_14, coeff_value[0]);
		~rain_maker_delay_synth.set(\tap_coeff_a1_14, coeff_value[1]);
		~rain_maker_delay_synth.set(\tap_coeff_a2_14, coeff_value[2]);
		~rain_maker_delay_synth.set(\tap_coeff_b1_14, coeff_value[3]);
		~rain_maker_delay_synth.set(\tap_coeff_b2_14, coeff_value[4]);
	});
	widgets[\d_tap_14_fltcut_knob].mode_(\vert).keystep_(0.000050050).step_(0.000050050).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_14_fltcut_static].string_((v.value.linexp(0, 1, 20, 20000)).round(1).asInteger.asString ++ " Hz");
		widgets[\d_tap_14_flttype_popupmenu].valueAction_(widgets[\d_tap_14_flttype_popupmenu].value);
	});
	widgets[\d_tap_14_fltq_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_14_fltq_static].string_((0.1 * (10 ** (2 * v.value))).round(0.1).asString);
		widgets[\d_tap_14_flttype_popupmenu].valueAction_(widgets[\d_tap_14_flttype_popupmenu].value);
	});
	widgets[\d_tap_14_ps_knob].mode_(\vert).keystep_(0.032258065).step_(0.032258065).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_14_ps_static].string_((v.value * 31 + -16).round(1).asInteger.asString);
		~rain_maker_delay_synth.set(\tap_pitchshift_14, (v.value * 31 + -16).round(1).asInteger);
	});
	widgets[\d_tap_14_level_slider].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_level_14, v.value);
	});
	widgets[\d_tap_15_mute_checkbox].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_gate_15, v.value.not.asInteger);
	});
	widgets[\d_tap_15_pan_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_15_pan_static].string_((v.value * 2 + -1).round(0.01).asString);
		~rain_maker_delay_synth.set(\tap_pan_15, (v.value * 2 + -1));
	});
	widgets[\d_tap_15_flttype_popupmenu].items_(["LP", "HP", "BP"]).action_({
		arg v;
		var coeff_value;
		coeff_value = switch (v.value,
			0, {~lpf_2nd_coeff.value((widgets[\d_tap_15_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_15_fltq_knob].value))))},
			1, {~hpf_2nd_coeff.value((widgets[\d_tap_15_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_15_fltq_knob].value))))},
			2, {~bpf_2nd_coeff.value((widgets[\d_tap_15_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_15_fltq_knob].value))))}
		);
		~rain_maker_delay_synth.set(\tap_coeff_a0_15, coeff_value[0]);
		~rain_maker_delay_synth.set(\tap_coeff_a1_15, coeff_value[1]);
		~rain_maker_delay_synth.set(\tap_coeff_a2_15, coeff_value[2]);
		~rain_maker_delay_synth.set(\tap_coeff_b1_15, coeff_value[3]);
		~rain_maker_delay_synth.set(\tap_coeff_b2_15, coeff_value[4]);
	});
	widgets[\d_tap_15_fltcut_knob].mode_(\vert).keystep_(0.000050050).step_(0.000050050).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_15_fltcut_static].string_((v.value.linexp(0, 1, 20, 20000)).round(1).asInteger.asString ++ " Hz");
		widgets[\d_tap_15_flttype_popupmenu].valueAction_(widgets[\d_tap_15_flttype_popupmenu].value);
	});
	widgets[\d_tap_15_fltq_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_15_fltq_static].string_((0.1 * (10 ** (2 * v.value))).round(0.1).asString);
		widgets[\d_tap_15_flttype_popupmenu].valueAction_(widgets[\d_tap_15_flttype_popupmenu].value);
	});
	widgets[\d_tap_15_ps_knob].mode_(\vert).keystep_(0.032258065).step_(0.032258065).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_15_ps_static].string_((v.value * 31 + -16).round(1).asInteger.asString);
		~rain_maker_delay_synth.set(\tap_pitchshift_15, (v.value * 31 + -16).round(1).asInteger);
	});
	widgets[\d_tap_15_level_slider].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_level_15, v.value);
	});
	widgets[\d_tap_16_mute_checkbox].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_gate_16, v.value.not.asInteger);
	});
	widgets[\d_tap_16_pan_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_16_pan_static].string_((v.value * 2 + -1).round(0.01).asString);
		~rain_maker_delay_synth.set(\tap_pan_16, (v.value * 2 + -1));
	});
	widgets[\d_tap_16_flttype_popupmenu].items_(["LP", "HP", "BP"]).action_({
		arg v;
		var coeff_value;
		coeff_value = switch (v.value,
			0, {~lpf_2nd_coeff.value((widgets[\d_tap_16_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_16_fltq_knob].value))))},
			1, {~hpf_2nd_coeff.value((widgets[\d_tap_16_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_16_fltq_knob].value))))},
			2, {~bpf_2nd_coeff.value((widgets[\d_tap_16_fltcut_knob].value.linexp(0, 1, 20, 20000)), s.sampleRate, (0.1 * (10 ** (2 * widgets[\d_tap_16_fltq_knob].value))))}
		);
		~rain_maker_delay_synth.set(\tap_coeff_a0_16, coeff_value[0]);
		~rain_maker_delay_synth.set(\tap_coeff_a1_16, coeff_value[1]);
		~rain_maker_delay_synth.set(\tap_coeff_a2_16, coeff_value[2]);
		~rain_maker_delay_synth.set(\tap_coeff_b1_16, coeff_value[3]);
		~rain_maker_delay_synth.set(\tap_coeff_b2_16, coeff_value[4]);
	});
	widgets[\d_tap_16_fltcut_knob].mode_(\vert).keystep_(0.000050050).step_(0.000050050).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_16_fltcut_static].string_((v.value.linexp(0, 1, 20, 20000)).round(1).asInteger.asString ++ " Hz");
		widgets[\d_tap_16_flttype_popupmenu].valueAction_(widgets[\d_tap_16_flttype_popupmenu].value);
	});
	widgets[\d_tap_16_fltq_knob].mode_(\vert).action_({
		arg v;
		value_static_texts[\d_tap_16_fltq_static].string_((0.1 * (10 ** (2 * v.value))).round(0.1).asString);
		widgets[\d_tap_16_flttype_popupmenu].valueAction_(widgets[\d_tap_16_flttype_popupmenu].value);
	});
	widgets[\d_tap_16_ps_knob].mode_(\vert).keystep_(0.032258065).step_(0.032258065).alt_scale_(1.0).action_({
		arg v;
		value_static_texts[\d_tap_16_ps_static].string_((v.value * 31 + -16).round(1).asInteger.asString);
		~rain_maker_delay_synth.set(\tap_pitchshift_16, (v.value * 31 + -16).round(1).asInteger);
	});
	widgets[\d_tap_16_level_slider].action_({
		arg v;
		~rain_maker_delay_synth.set(\tap_level_16, v.value);
	});
	widgets[\d_tap_1_mute_checkbox].valueAction_(false);
	widgets[\d_tap_1_pan_knob].valueAction_((0 - -1) * 0.5);
	widgets[\d_tap_1_flttype_popupmenu].valueAction_(0);
	widgets[\d_tap_1_fltcut_knob].valueAction_((20000 - 20) * 5.005005005005005e-05);
	widgets[\d_tap_1_fltq_knob].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_1_ps_knob].valueAction_((0 - -16) * 0.03225806451612903);
	widgets[\d_tap_1_level_slider].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_2_mute_checkbox].valueAction_(false);
	widgets[\d_tap_2_pan_knob].valueAction_((0 - -1) * 0.5);
	widgets[\d_tap_2_flttype_popupmenu].valueAction_(0);
	widgets[\d_tap_2_fltcut_knob].valueAction_((20000 - 20) * 5.005005005005005e-05);
	widgets[\d_tap_2_fltq_knob].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_2_ps_knob].valueAction_((0 - -16) * 0.03225806451612903);
	widgets[\d_tap_2_level_slider].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_3_mute_checkbox].valueAction_(false);
	widgets[\d_tap_3_pan_knob].valueAction_((0 - -1) * 0.5);
	widgets[\d_tap_3_flttype_popupmenu].valueAction_(0);
	widgets[\d_tap_3_fltcut_knob].valueAction_((20000 - 20) * 5.005005005005005e-05);
	widgets[\d_tap_3_fltq_knob].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_3_ps_knob].valueAction_((0 - -16) * 0.03225806451612903);
	widgets[\d_tap_3_level_slider].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_4_mute_checkbox].valueAction_(false);
	widgets[\d_tap_4_pan_knob].valueAction_((0 - -1) * 0.5);
	widgets[\d_tap_4_flttype_popupmenu].valueAction_(0);
	widgets[\d_tap_4_fltcut_knob].valueAction_((20000 - 20) * 5.005005005005005e-05);
	widgets[\d_tap_4_fltq_knob].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_4_ps_knob].valueAction_((0 - -16) * 0.03225806451612903);
	widgets[\d_tap_4_level_slider].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_5_mute_checkbox].valueAction_(false);
	widgets[\d_tap_5_pan_knob].valueAction_((0 - -1) * 0.5);
	widgets[\d_tap_5_flttype_popupmenu].valueAction_(0);
	widgets[\d_tap_5_fltcut_knob].valueAction_((20000 - 20) * 5.005005005005005e-05);
	widgets[\d_tap_5_fltq_knob].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_5_ps_knob].valueAction_((0 - -16) * 0.03225806451612903);
	widgets[\d_tap_5_level_slider].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_6_mute_checkbox].valueAction_(false);
	widgets[\d_tap_6_pan_knob].valueAction_((0 - -1) * 0.5);
	widgets[\d_tap_6_flttype_popupmenu].valueAction_(0);
	widgets[\d_tap_6_fltcut_knob].valueAction_((20000 - 20) * 5.005005005005005e-05);
	widgets[\d_tap_6_fltq_knob].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_6_ps_knob].valueAction_((0 - -16) * 0.03225806451612903);
	widgets[\d_tap_6_level_slider].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_7_mute_checkbox].valueAction_(false);
	widgets[\d_tap_7_pan_knob].valueAction_((0 - -1) * 0.5);
	widgets[\d_tap_7_flttype_popupmenu].valueAction_(0);
	widgets[\d_tap_7_fltcut_knob].valueAction_((20000 - 20) * 5.005005005005005e-05);
	widgets[\d_tap_7_fltq_knob].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_7_ps_knob].valueAction_((0 - -16) * 0.03225806451612903);
	widgets[\d_tap_7_level_slider].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_8_mute_checkbox].valueAction_(false);
	widgets[\d_tap_8_pan_knob].valueAction_((0 - -1) * 0.5);
	widgets[\d_tap_8_flttype_popupmenu].valueAction_(0);
	widgets[\d_tap_8_fltcut_knob].valueAction_((20000 - 20) * 5.005005005005005e-05);
	widgets[\d_tap_8_fltq_knob].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_8_ps_knob].valueAction_((0 - -16) * 0.03225806451612903);
	widgets[\d_tap_8_level_slider].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_9_mute_checkbox].valueAction_(false);
	widgets[\d_tap_9_pan_knob].valueAction_((0 - -1) * 0.5);
	widgets[\d_tap_9_flttype_popupmenu].valueAction_(0);
	widgets[\d_tap_9_fltcut_knob].valueAction_((20000 - 20) * 5.005005005005005e-05);
	widgets[\d_tap_9_fltq_knob].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_9_ps_knob].valueAction_((0 - -16) * 0.03225806451612903);
	widgets[\d_tap_9_level_slider].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_10_mute_checkbox].valueAction_(false);
	widgets[\d_tap_10_pan_knob].valueAction_((0 - -1) * 0.5);
	widgets[\d_tap_10_flttype_popupmenu].valueAction_(0);
	widgets[\d_tap_10_fltcut_knob].valueAction_((20000 - 20) * 5.005005005005005e-05);
	widgets[\d_tap_10_fltq_knob].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_10_ps_knob].valueAction_((0 - -16) * 0.03225806451612903);
	widgets[\d_tap_10_level_slider].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_11_mute_checkbox].valueAction_(false);
	widgets[\d_tap_11_pan_knob].valueAction_((0 - -1) * 0.5);
	widgets[\d_tap_11_flttype_popupmenu].valueAction_(0);
	widgets[\d_tap_11_fltcut_knob].valueAction_((20000 - 20) * 5.005005005005005e-05);
	widgets[\d_tap_11_fltq_knob].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_11_ps_knob].valueAction_((0 - -16) * 0.03225806451612903);
	widgets[\d_tap_11_level_slider].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_12_mute_checkbox].valueAction_(false);
	widgets[\d_tap_12_pan_knob].valueAction_((0 - -1) * 0.5);
	widgets[\d_tap_12_flttype_popupmenu].valueAction_(0);
	widgets[\d_tap_12_fltcut_knob].valueAction_((20000 - 20) * 5.005005005005005e-05);
	widgets[\d_tap_12_fltq_knob].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_12_ps_knob].valueAction_((0 - -16) * 0.03225806451612903);
	widgets[\d_tap_12_level_slider].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_13_mute_checkbox].valueAction_(false);
	widgets[\d_tap_13_pan_knob].valueAction_((0 - -1) * 0.5);
	widgets[\d_tap_13_flttype_popupmenu].valueAction_(0);
	widgets[\d_tap_13_fltcut_knob].valueAction_((20000 - 20) * 5.005005005005005e-05);
	widgets[\d_tap_13_fltq_knob].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_13_ps_knob].valueAction_((0 - -16) * 0.03225806451612903);
	widgets[\d_tap_13_level_slider].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_14_mute_checkbox].valueAction_(false);
	widgets[\d_tap_14_pan_knob].valueAction_((0 - -1) * 0.5);
	widgets[\d_tap_14_flttype_popupmenu].valueAction_(0);
	widgets[\d_tap_14_fltcut_knob].valueAction_((20000 - 20) * 5.005005005005005e-05);
	widgets[\d_tap_14_fltq_knob].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_14_ps_knob].valueAction_((0 - -16) * 0.03225806451612903);
	widgets[\d_tap_14_level_slider].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_15_mute_checkbox].valueAction_(false);
	widgets[\d_tap_15_pan_knob].valueAction_((0 - -1) * 0.5);
	widgets[\d_tap_15_flttype_popupmenu].valueAction_(0);
	widgets[\d_tap_15_fltcut_knob].valueAction_((20000 - 20) * 5.005005005005005e-05);
	widgets[\d_tap_15_fltq_knob].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_15_ps_knob].valueAction_((0 - -16) * 0.03225806451612903);
	widgets[\d_tap_15_level_slider].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_16_mute_checkbox].valueAction_(false);
	widgets[\d_tap_16_pan_knob].valueAction_((0 - -1) * 0.5);
	widgets[\d_tap_16_flttype_popupmenu].valueAction_(0);
	widgets[\d_tap_16_fltcut_knob].valueAction_((20000 - 20) * 5.005005005005005e-05);
	widgets[\d_tap_16_fltq_knob].valueAction_((0 - 0) * 1.0);
	widgets[\d_tap_16_ps_knob].valueAction_((0 - -16) * 0.03225806451612903);
	widgets[\d_tap_16_level_slider].valueAction_((0 - 0) * 1.0);

	widgets[\d_grid_popupmenu].valueAction_(0);
	widgets[\d_stack_popupmenu].valueAction_(0);
	widgets[\d_time_numberbox].valueAction_(500);
	widgets[\d_div_popupmenu].valueAction_(0);
	widgets[\d_grain_quantity_popupmenu].valueAction_(4);
	widgets[\d_grain_size_numberbox].valueAction_(300);
	widgets[\d_global_ps_knob].valueAction_((0 - -16) * 0.03225806451612903);
	widgets[\d_pingpong_checkbox].valueAction_(false);
	widgets[\d_reverse_checkbox].valueAction_(false);
	widgets[\d_time_clk_checkbox].valueAction_(true);
	widgets[\d_feedback_knob].valueAction_((0.9 - 0) * 1.0);
	widgets[\d_fb_tone_knob].valueAction_((0 - -1) * 0.5);
	widgets[\d_fb_tap_l_popupmenu].valueAction_(7);
	widgets[\d_fb_tap_r_popupmenu].valueAction_(7);
	widgets[\d_fb_ps_l_knob].valueAction_((0 - -16) * 0.03225806451612903);
	widgets[\d_fb_ps_r_knob].valueAction_((0 - -16) * 0.03225806451612903);
	widgets[\d_slip_knob].valueAction_((0 - -16) * 0.03225806451612903);
	widgets[\d_groove_popupmenu].valueAction_(0);
	widgets[\d_gveamt_knob].valueAction_((1 - 0) * 1.0);
	widgets[\d_mod_wave_popupmenu].valueAction_(0);
	widgets[\d_mod_level_knob].valueAction_((0 - 0) * 0.06666666666666667);
	widgets[\d_mod_rate_numberbox].valueAction_(1);
	widgets[\c_patt_popupmenu].valueAction_(0);
	widgets[\c_slope_popupmenu].valueAction_(0);
	widgets[\c_div_popupmenu].valueAction_(11);
	widgets[\c_feedback_knob].valueAction_((0.5 - 0) * 1.0);
	widgets[\c_level_knob].valueAction_(1);
	widgets[\c_combsize_clk_checkbox].valueAction_(false);
	widgets[\c_combsize_knob].valueAction_(0.5473);
	widgets[\c_mod_wave_popupmenu].valueAction_(0);
	widgets[\c_mod_level_knob].valueAction_((0 - 0) * 0.06666666666666667);
	widgets[\c_mod_rate_numberbox].valueAction_(1);
	widgets[\c_fb_num_numberbox].valueAction_(64);
	widgets[\c_fb_config_knob].valueAction_(1);
	widgets[\g_routing_popupmenu].valueAction_(0);
	widgets[\g_mix_knob].valueAction_((0.5 - 0) * 1.0);
	widgets[\g_tempo_numberbox].valueAction_(120);

	d_control_section.addSpanning(label_static_texts[\d_grid_label], 0, 0, align:\center);
	d_control_section.addSpanning(widgets[\d_grid_popupmenu], 1, 0, align:\center);
	d_control_section.addSpanning(label_static_texts[\d_stack_label], 0, 1, align:\center);
	d_control_section.addSpanning(widgets[\d_stack_popupmenu], 1, 1, align:\center);
	d_control_section.addSpanning(label_static_texts[\d_time_label], 0, 2, columnSpan: 2, align:\center);
	d_control_section.addSpanning(HLayout([label_static_texts[\d_time_clk_label], align: \center], [widgets[\d_time_clk_checkbox], align: \center]), 1, 2, align:\center);
	d_control_section.addSpanning(widgets[\d_time_numberbox], 1, 3, align:\center);
	d_control_section.addSpanning(label_static_texts[\d_div_label], 0, 4, align:\center);
	d_control_section.addSpanning(widgets[\d_div_popupmenu], 1, 4, align:\center);
	d_control_section.addSpanning(label_static_texts[\d_grain_quantity_label], 0, 5, align:\center);
	d_control_section.addSpanning(widgets[\d_grain_quantity_popupmenu], 1, 5, align:\center);
	d_control_section.addSpanning(label_static_texts[\d_grain_size_label], 0, 6, align:\center);
	d_control_section.addSpanning(widgets[\d_grain_size_numberbox], 1, 6, align:\center);
	d_control_section.addSpanning(label_static_texts[\d_global_ps_label], 0, 7, align:\center);
	d_control_section.addSpanning(GridLayout.rows([widgets[\d_global_ps_knob], align:\center], [value_static_texts[\d_global_ps_static], align:\center]), 1, 7, align:\center);
	d_control_section.addSpanning(label_static_texts[\d_feedback_label], 2, 0, align:\center);
	d_control_section.addSpanning(GridLayout.rows([widgets[\d_feedback_knob], align:\center], [value_static_texts[\d_feedback_static], align:\center]), 3, 0, align:\center);
	d_control_section.addSpanning(label_static_texts[\d_fb_tone_label], 2, 1, align:\center);
	d_control_section.addSpanning(GridLayout.rows([widgets[\d_fb_tone_knob], align:\center], [value_static_texts[\d_fb_tone_static], align:\center]), 3, 1, align:\center);
	d_control_section.addSpanning(label_static_texts[\d_fb_tap_l_label], 2, 2, align:\center);
	d_control_section.addSpanning(widgets[\d_fb_tap_l_popupmenu], 3, 2, align:\center);
	d_control_section.addSpanning(label_static_texts[\d_fb_tap_r_label], 2, 3, align:\center);
	d_control_section.addSpanning(widgets[\d_fb_tap_r_popupmenu], 3, 3, align:\center);
	d_control_section.addSpanning(label_static_texts[\d_fb_ps_l_label], 2, 4, align:\center);
	d_control_section.addSpanning(GridLayout.rows([widgets[\d_fb_ps_l_knob], align:\center], [value_static_texts[\d_fb_ps_l_static], align:\center]), 3, 4, align:\center);
	d_control_section.addSpanning(label_static_texts[\d_fb_ps_r_label], 2, 5, align:\center);
	d_control_section.addSpanning(GridLayout.rows([widgets[\d_fb_ps_r_knob], align:\center], [value_static_texts[\d_fb_ps_r_static], align:\center]), 3, 5, align:\center);
	d_control_section.addSpanning(label_static_texts[\d_slip_label], 2, 6, align:\center);
	d_control_section.addSpanning(GridLayout.rows([widgets[\d_slip_knob], align:\center], [value_static_texts[\d_slip_static], align:\center]), 3, 6, align:\center);
	d_control_section.addSpanning(label_static_texts[\d_groove_label], 2, 7, align:\center);
	d_control_section.addSpanning(widgets[\d_groove_popupmenu], 3, 7, align:\center);
	d_control_section.addSpanning(label_static_texts[\d_gveamt_label], 2, 8, align:\center);
	d_control_section.addSpanning(GridLayout.rows([widgets[\d_gveamt_knob], align:\center], [value_static_texts[\d_gveamt_static], align:\center]), 3, 8, align:\center);
	d_control_section.addSpanning(label_static_texts[\d_mod_wave_label], 4, 0, align:\center);
	d_control_section.addSpanning(widgets[\d_mod_wave_popupmenu], 5, 0, align:\center);
	d_control_section.addSpanning(label_static_texts[\d_mod_level_label], 4, 1, align:\center);
	d_control_section.addSpanning(GridLayout.rows([widgets[\d_mod_level_knob], align:\center], [value_static_texts[\d_mod_level_static], align:\center]), 5, 1, align:\center);
	d_control_section.addSpanning(label_static_texts[\d_mod_rate_label], 4, 2, align:\center);
	d_control_section.addSpanning(widgets[\d_mod_rate_numberbox], 5, 2, align:\center);
	d_control_section.addSpanning(label_static_texts[\g_routing_label], 4, 3, align:\center);
	d_control_section.addSpanning(widgets[\g_routing_popupmenu], 5, 3, align:\center);
	d_control_section.addSpanning(label_static_texts[\g_mix_label], 4, 4, align:\center);
	d_control_section.addSpanning(GridLayout.rows([widgets[\g_mix_knob], align:\center], [value_static_texts[\g_mix_static], align:\center]), 5, 4, align:\center);
	d_control_section.addSpanning(label_static_texts[\g_tempo_label], 4, 5, align:\center);
	d_control_section.addSpanning(widgets[\g_tempo_numberbox], 5, 5, align:\center);
	d_control_section.addSpanning(label_static_texts[\d_pingpong_label], 4, 6, align:\center);
	d_control_section.addSpanning(widgets[\d_pingpong_checkbox], 5, 6, align:\center);
	d_control_section.addSpanning(label_static_texts[\d_reverse_label], 4, 7, align:\center);
	d_control_section.addSpanning(widgets[\d_reverse_checkbox], 5, 7, align:\center);

	d_tap_section.addSpanning(label_static_texts[\d_tap_1_mute_label], 0, 0, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_1_mute_checkbox], 0, 1, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_2_mute_checkbox], 0, 2, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_3_mute_checkbox], 0, 3, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_4_mute_checkbox], 0, 4, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_5_mute_checkbox], 0, 5, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_6_mute_checkbox], 0, 6, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_7_mute_checkbox], 0, 7, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_8_mute_checkbox], 0, 8, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_9_mute_checkbox], 0, 9, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_10_mute_checkbox], 0, 10, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_11_mute_checkbox], 0, 11, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_12_mute_checkbox], 0, 12, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_13_mute_checkbox], 0, 13, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_14_mute_checkbox], 0, 14, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_15_mute_checkbox], 0, 15, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_16_mute_checkbox], 0, 16, align:\center);
	d_tap_section.addSpanning(label_static_texts[\d_tap_1_pan_label], 1, 0, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_1_pan_knob], align:\center], [value_static_texts[\d_tap_1_pan_static], align:\center]), 1, 1, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_2_pan_knob], align:\center], [value_static_texts[\d_tap_2_pan_static], align:\center]), 1, 2, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_3_pan_knob], align:\center], [value_static_texts[\d_tap_3_pan_static], align:\center]), 1, 3, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_4_pan_knob], align:\center], [value_static_texts[\d_tap_4_pan_static], align:\center]), 1, 4, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_5_pan_knob], align:\center], [value_static_texts[\d_tap_5_pan_static], align:\center]), 1, 5, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_6_pan_knob], align:\center], [value_static_texts[\d_tap_6_pan_static], align:\center]), 1, 6, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_7_pan_knob], align:\center], [value_static_texts[\d_tap_7_pan_static], align:\center]), 1, 7, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_8_pan_knob], align:\center], [value_static_texts[\d_tap_8_pan_static], align:\center]), 1, 8, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_9_pan_knob], align:\center], [value_static_texts[\d_tap_9_pan_static], align:\center]), 1, 9, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_10_pan_knob], align:\center], [value_static_texts[\d_tap_10_pan_static], align:\center]), 1, 10, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_11_pan_knob], align:\center], [value_static_texts[\d_tap_11_pan_static], align:\center]), 1, 11, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_12_pan_knob], align:\center], [value_static_texts[\d_tap_12_pan_static], align:\center]), 1, 12, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_13_pan_knob], align:\center], [value_static_texts[\d_tap_13_pan_static], align:\center]), 1, 13, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_14_pan_knob], align:\center], [value_static_texts[\d_tap_14_pan_static], align:\center]), 1, 14, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_15_pan_knob], align:\center], [value_static_texts[\d_tap_15_pan_static], align:\center]), 1, 15, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_16_pan_knob], align:\center], [value_static_texts[\d_tap_16_pan_static], align:\center]), 1, 16, align:\center);
	d_tap_section.addSpanning(label_static_texts[\d_tap_1_flttype_label], 2, 0, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_1_flttype_popupmenu], 2, 1, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_2_flttype_popupmenu], 2, 2, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_3_flttype_popupmenu], 2, 3, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_4_flttype_popupmenu], 2, 4, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_5_flttype_popupmenu], 2, 5, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_6_flttype_popupmenu], 2, 6, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_7_flttype_popupmenu], 2, 7, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_8_flttype_popupmenu], 2, 8, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_9_flttype_popupmenu], 2, 9, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_10_flttype_popupmenu], 2, 10, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_11_flttype_popupmenu], 2, 11, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_12_flttype_popupmenu], 2, 12, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_13_flttype_popupmenu], 2, 13, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_14_flttype_popupmenu], 2, 14, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_15_flttype_popupmenu], 2, 15, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_16_flttype_popupmenu], 2, 16, align:\center);
	d_tap_section.addSpanning(label_static_texts[\d_tap_1_fltcut_label], 3, 0, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_1_fltcut_knob], align:\center], [value_static_texts[\d_tap_1_fltcut_static], align:\center]), 3, 1, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_2_fltcut_knob], align:\center], [value_static_texts[\d_tap_2_fltcut_static], align:\center]), 3, 2, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_3_fltcut_knob], align:\center], [value_static_texts[\d_tap_3_fltcut_static], align:\center]), 3, 3, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_4_fltcut_knob], align:\center], [value_static_texts[\d_tap_4_fltcut_static], align:\center]), 3, 4, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_5_fltcut_knob], align:\center], [value_static_texts[\d_tap_5_fltcut_static], align:\center]), 3, 5, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_6_fltcut_knob], align:\center], [value_static_texts[\d_tap_6_fltcut_static], align:\center]), 3, 6, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_7_fltcut_knob], align:\center], [value_static_texts[\d_tap_7_fltcut_static], align:\center]), 3, 7, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_8_fltcut_knob], align:\center], [value_static_texts[\d_tap_8_fltcut_static], align:\center]), 3, 8, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_9_fltcut_knob], align:\center], [value_static_texts[\d_tap_9_fltcut_static], align:\center]), 3, 9, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_10_fltcut_knob], align:\center], [value_static_texts[\d_tap_10_fltcut_static], align:\center]), 3, 10, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_11_fltcut_knob], align:\center], [value_static_texts[\d_tap_11_fltcut_static], align:\center]), 3, 11, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_12_fltcut_knob], align:\center], [value_static_texts[\d_tap_12_fltcut_static], align:\center]), 3, 12, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_13_fltcut_knob], align:\center], [value_static_texts[\d_tap_13_fltcut_static], align:\center]), 3, 13, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_14_fltcut_knob], align:\center], [value_static_texts[\d_tap_14_fltcut_static], align:\center]), 3, 14, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_15_fltcut_knob], align:\center], [value_static_texts[\d_tap_15_fltcut_static], align:\center]), 3, 15, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_16_fltcut_knob], align:\center], [value_static_texts[\d_tap_16_fltcut_static], align:\center]), 3, 16, align:\center);
	d_tap_section.addSpanning(label_static_texts[\d_tap_1_fltq_label], 4, 0, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_1_fltq_knob], align:\center], [value_static_texts[\d_tap_1_fltq_static], align:\center]), 4, 1, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_2_fltq_knob], align:\center], [value_static_texts[\d_tap_2_fltq_static], align:\center]), 4, 2, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_3_fltq_knob], align:\center], [value_static_texts[\d_tap_3_fltq_static], align:\center]), 4, 3, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_4_fltq_knob], align:\center], [value_static_texts[\d_tap_4_fltq_static], align:\center]), 4, 4, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_5_fltq_knob], align:\center], [value_static_texts[\d_tap_5_fltq_static], align:\center]), 4, 5, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_6_fltq_knob], align:\center], [value_static_texts[\d_tap_6_fltq_static], align:\center]), 4, 6, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_7_fltq_knob], align:\center], [value_static_texts[\d_tap_7_fltq_static], align:\center]), 4, 7, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_8_fltq_knob], align:\center], [value_static_texts[\d_tap_8_fltq_static], align:\center]), 4, 8, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_9_fltq_knob], align:\center], [value_static_texts[\d_tap_9_fltq_static], align:\center]), 4, 9, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_10_fltq_knob], align:\center], [value_static_texts[\d_tap_10_fltq_static], align:\center]), 4, 10, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_11_fltq_knob], align:\center], [value_static_texts[\d_tap_11_fltq_static], align:\center]), 4, 11, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_12_fltq_knob], align:\center], [value_static_texts[\d_tap_12_fltq_static], align:\center]), 4, 12, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_13_fltq_knob], align:\center], [value_static_texts[\d_tap_13_fltq_static], align:\center]), 4, 13, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_14_fltq_knob], align:\center], [value_static_texts[\d_tap_14_fltq_static], align:\center]), 4, 14, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_15_fltq_knob], align:\center], [value_static_texts[\d_tap_15_fltq_static], align:\center]), 4, 15, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_16_fltq_knob], align:\center], [value_static_texts[\d_tap_16_fltq_static], align:\center]), 4, 16, align:\center);
	d_tap_section.addSpanning(label_static_texts[\d_tap_1_ps_label], 5, 0, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_1_ps_knob], align:\center], [value_static_texts[\d_tap_1_ps_static], align:\center]), 5, 1, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_2_ps_knob], align:\center], [value_static_texts[\d_tap_2_ps_static], align:\center]), 5, 2, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_3_ps_knob], align:\center], [value_static_texts[\d_tap_3_ps_static], align:\center]), 5, 3, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_4_ps_knob], align:\center], [value_static_texts[\d_tap_4_ps_static], align:\center]), 5, 4, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_5_ps_knob], align:\center], [value_static_texts[\d_tap_5_ps_static], align:\center]), 5, 5, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_6_ps_knob], align:\center], [value_static_texts[\d_tap_6_ps_static], align:\center]), 5, 6, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_7_ps_knob], align:\center], [value_static_texts[\d_tap_7_ps_static], align:\center]), 5, 7, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_8_ps_knob], align:\center], [value_static_texts[\d_tap_8_ps_static], align:\center]), 5, 8, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_9_ps_knob], align:\center], [value_static_texts[\d_tap_9_ps_static], align:\center]), 5, 9, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_10_ps_knob], align:\center], [value_static_texts[\d_tap_10_ps_static], align:\center]), 5, 10, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_11_ps_knob], align:\center], [value_static_texts[\d_tap_11_ps_static], align:\center]), 5, 11, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_12_ps_knob], align:\center], [value_static_texts[\d_tap_12_ps_static], align:\center]), 5, 12, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_13_ps_knob], align:\center], [value_static_texts[\d_tap_13_ps_static], align:\center]), 5, 13, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_14_ps_knob], align:\center], [value_static_texts[\d_tap_14_ps_static], align:\center]), 5, 14, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_15_ps_knob], align:\center], [value_static_texts[\d_tap_15_ps_static], align:\center]), 5, 15, align:\center);
	d_tap_section.addSpanning(GridLayout.rows([widgets[\d_tap_16_ps_knob], align:\center], [value_static_texts[\d_tap_16_ps_static], align:\center]), 5, 16, align:\center);
	d_tap_section.addSpanning(label_static_texts[\d_tap_1_level_label], 6, 0, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_1_level_slider], 6, 1, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_2_level_slider], 6, 2, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_3_level_slider], 6, 3, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_4_level_slider], 6, 4, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_5_level_slider], 6, 5, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_6_level_slider], 6, 6, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_7_level_slider], 6, 7, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_8_level_slider], 6, 8, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_9_level_slider], 6, 9, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_10_level_slider], 6, 10, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_11_level_slider], 6, 11, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_12_level_slider], 6, 12, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_13_level_slider], 6, 13, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_14_level_slider], 6, 14, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_15_level_slider], 6, 15, align:\center);
	d_tap_section.addSpanning(widgets[\d_tap_16_level_slider], 6, 16, align:\center);

	c_control_section.addSpanning(label_static_texts[\c_patt_label], 0, 0, align:\center);
	c_control_section.addSpanning(widgets[\c_patt_popupmenu], 1, 0, align:\center);
	c_control_section.addSpanning(label_static_texts[\c_slope_label], 0, 1, align:\center);
	c_control_section.addSpanning(widgets[\c_slope_popupmenu], 1, 1, align:\center);
	c_control_section.addSpanning(label_static_texts[\c_level_label], 0, 2, align:\center);
	c_control_section.addSpanning(GridLayout.rows([widgets[\c_level_knob], align:\center], [value_static_texts[\c_level_static], align:\center]), 1, 2, align:\center);
	c_control_section.addSpanning(label_static_texts[\c_combsize_label], 2, 0, columnSpan: 2, align:\center);
	c_control_section.addSpanning(HLayout([label_static_texts[\c_combsize_clk_label], align: \center], [widgets[\c_combsize_clk_checkbox], align: \center]), 3, 0, align:\center);
	c_control_section.addSpanning(GridLayout.rows([widgets[\c_combsize_knob], align:\center], [value_static_texts[\c_combsize_static], align:\center]), 3, 1, align:\center);
	c_control_section.addSpanning(label_static_texts[\c_div_label], 2, 2, align:\center);
	c_control_section.addSpanning(widgets[\c_div_popupmenu], 3, 2, align:\center);
	c_control_section.addSpanning(label_static_texts[\c_feedback_label], 4, 0, align:\center);
	c_control_section.addSpanning(GridLayout.rows([widgets[\c_feedback_knob], align:\center], [value_static_texts[\c_feedback_static], align:\center]), 5, 0, align:\center);
	c_control_section.addSpanning(label_static_texts[\c_fb_num_label], 4, 1, align:\center);
	c_control_section.addSpanning(widgets[\c_fb_num_numberbox], 5, 1, align:\center);
	c_control_section.addSpanning(label_static_texts[\c_fb_config_label], 4, 2, align:\center);
	c_control_section.addSpanning(GridLayout.rows([widgets[\c_fb_config_knob], align:\center], [value_static_texts[\c_fb_config_static], align:\center]), 5, 2, align:\center);
	c_control_section.addSpanning(label_static_texts[\c_mod_wave_label], 6, 0, align:\center);
	c_control_section.addSpanning(widgets[\c_mod_wave_popupmenu], 7, 0, align:\center);
	c_control_section.addSpanning(label_static_texts[\c_mod_level_label], 6, 1, align:\center);
	c_control_section.addSpanning(GridLayout.rows([widgets[\c_mod_level_knob], align:\center], [value_static_texts[\c_mod_level_static], align:\center]), 7, 1, align:\center);
	c_control_section.addSpanning(label_static_texts[\c_mod_rate_label], 6, 2, align:\center);
	c_control_section.addSpanning(widgets[\c_mod_rate_numberbox], 7, 2, align:\center);

	splitter = UserView().background_(Color.black).fixedWidth_(2);
	win = Window.new("RainMaker").alwaysOnTop_(true).layout_(HLayout(VLayout(d_control_section, d_tap_section), splitter, VLayout(c_control_section, UserView()))).front.onClose_({
		~rain_maker_grp.freeAll;
		~rain_maker_grp.free;
		~rain_maker_bus.free;
		~rain_maker_tmp_bus.free;
	});
	~rain_maker_delay_synth.set(\t_rev_change, 1);
};
~rain_maker_gui.value;
);

// Some use cases of Rainmaker
/******************************************
Sometimes the phasor controlling heads are not in sync for some reason, causing comb section to pickup the click, run the following to fix
~rain_maker_delay_synth.set(\t_rev_change, 1);
******************************************/

(
~ping_player = SynthDef(\ping, { arg out = 0;
	Out.ar(out, Splay.ar([
		Decay.ar(Impulse.ar(1), 0.3, VarSaw.ar(400, width: 0.1, mul: 0.5)),
		Decay.ar(Impulse.ar(1), 0.3, VarSaw.ar(1200, width: 0.1, mul: 0.5)),
	]));
}).play(s, [\out, ~rain_maker_bus]);
);
~ping_player.free;

~pad_audio = Buffer.read(s, thisProcess.nowExecutingPath.dirname ++ "/sounds/pads.wav");
(
SynthDef(\help_RecordBuf_playback, { arg out = 0, bufnum = 0;
	var playbuf;
	playbuf = PlayBuf.ar(2,bufnum);
    FreeSelfWhenDone.kr(playbuf);
    Out.ar(out, playbuf * 0.25);
}).play(s, [\out, ~rain_maker_bus, \bufnum, ~pad_audio]);
)

~drum_audio = Buffer.read(s, thisProcess.nowExecutingPath.dirname ++ "/sounds/drumloop0.wav");
(
~player = SynthDef(\help_RecordBuf_playback, { arg out = 0, bufnum = 0;
	var playbuf;
	playbuf =PlayBuf.ar(2,bufnum, loop: 1);
    FreeSelfWhenDone.kr(playbuf);
    Out.ar(out, playbuf * 0.5);
}).play(s, [\out, ~rain_maker_bus, \bufnum, ~drum_audio]);
)
~player.free;

s.freeAll;
