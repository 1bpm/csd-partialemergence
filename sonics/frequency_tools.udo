#ifndef UDO_FREQUENCYTOOLS
#define UDO_FREQUENCYTOOLS ##
/*
	Frequency tools/effects: shifters, ring modulation, delays, chorus etc
	Slim excerpt for Partial Emergence

	This file is part of the SONICS UDO collection by Richard Knight 2021
		License: GPL-2.0-or-later
		http://1bpm.net
*/

#include "sonics/wavetables.udo"



/*
	Mono frequency shifter with hilbert transform
	
	aoutput freqshift1 ainput, kfrequency
	
	aoutput		output audio
	ainput		input audio
	kfrequency	shift frequency [MIN(-10000) MAX(10000) DEFAULT(-500)]
*/
opcode freqshift1, a, ak
	ain, kfreq xin
	asin oscili 1, kfreq, gifnSine
	acos oscili 1, kfreq, gifnSine, .25
	areal, aimag hilbert ain
	amod1 = areal * acos
	amod2 = aimag * asin
	ashift = (amod1 - amod2) * 0.7
	xout ashift
endop


/*
	Stereo frequency shifter with hilbert transform
	
	aoutputL, aoutputR freqshift1 ainputL, ainputR, kfrequency

	aoutputL	output audio left
	aoutputR	output audio right
	ainputL		input audio left
	ainputR		input audio right
	kfrequency	shift frequency [MIN(-10000) MAX(10000) DEFAULT(-500)]
*/
opcode freqshift1, aa, aak
	ainL, ainR, kfreq xin
	asin oscili 1, kfreq, gifnSine
	acos oscili 1, kfreq, gifnSine, .25
	arealL, aimagL hilbert ainL
	arealR, aimagR hilbert ainR
	amod1L = arealL * acos
	amod2L = aimagL * asin
	amod1R = arealR * acos
	amod2R = aimagR * asin
	ashiftL = (amod1L - amod2L) * 0.7
	ashiftR = (amod1R - amod2R) * 0.7
	xout ashiftL, ashiftR
endop


/*
	Mono ring modulator with hilbert transform
	
	aoutput ringmod1 ainput, kfrequency

	aoutput		output audio
	ainput		input audio
	kfrequency	modulation frequency [MIN(0) MAX(10000) DEFAULT(440)]
*/
opcode ringmod1, a, ak
	ain, kfreq xin
	asin oscili 1, kfreq, gifnSine
	acos oscili 1, kfreq, gifnSine, .25
	areal, aimag hilbert ain
	amod1 = areal * acos
	amod2 = aimag * asin
	aupshift = (amod1 - amod2) * 0.7
	adownshift = (amod1 + amod2) * 0.7
	xout aupshift+adownshift
endop

/*
	Stereo ring modulator with hilbert transform
	
	aoutputL, aoutputR ringmod1 ainputL, ainputR, kfrequency

	aoutputL	output audio left
	aoutputR	output audio right
	ainputL		input audio left
	ainputR		input audio right
	kfrequency	modulation frequency [MIN(0) MAX(10000) DEFAULT(440)]
*/
opcode ringmod1, aa, aak
	ainL, ainR, kfreq xin
	asin oscili 1, kfreq, gifnSine
	acos oscili 1, kfreq, gifnSine, .25
	arealL, aimagL hilbert ainL
	arealR, aimagR hilbert ainR
	amod1L = arealL * acos
	amod2L = aimagL * asin
	amod1R = arealR * acos
	amod2R = aimagR * asin
	aupshiftL = (amod1L - amod2L) * 0.7
	adownshiftL = (amod1L + amod2L) * 0.7
	aupshiftR = (amod1R - amod2R) * 0.7
	adownshiftR = (amod1R + amod2R) * 0.7
	xout aupshiftL+adownshiftL, aupshiftR+adownshiftR
endop


/*
	Mono frequency shifter with direct modulation
	
	aoutput freqshift2 ainput, kfrequency, [kshiftmode=1]

	aoutput		output audio
	ainput		input audio
	kfrequency	shift frequency [MIN(-10000) MAX(10000) DEFAULT(-500)]
	kshiftmode	shift mode [TYPE(bool) DEFAULT(1)]
*/
opcode freqshift2, a, akP
	ain, kfreq, kshiftmode xin
	isr4 = sr * 0.25

	ko1frq = isr4 - (1 - kshiftmode) * kfreq
	aqo1r oscil 1.0, ko1frq, gifnSine, 0.25 ; cosine
	aqo1i oscil 1.0, ko1frq, gifnSine, 0.0 ; sine

	ko2frq = isr4 + kshiftmode * kfreq
	aqo2r oscil 1.0, ko2frq, gifnSine, 0.25 ; cosine
	aqo2i oscil 1.0, ko2frq, gifnSine, 0.0 ; sine
	awq1r = ain * aqo1r

	awf1r biquad awq1r, 1, 1.6375276435, 1, 1, -0.93027644018, 0.37171017225
	awf2r biquad awf1r, 1, 0.56037176307, 1, 1, -0.40320752514, 0.73736786626
	awf3r biquad awf2r, 1, 0.19165327787, 1, 1, -0.15398586410, 0.94001488557
	aw1fr = awf3r * 0.051532459925
	awq2r = aw1fr * aqo2r

	awq1i = ain * aqo1i
	awf1i biquad awq1i, 1, 1.6375276435, 1, 1, -0.93027644018, 0.37171017225
	awf2i biquad awf1i, 1, 0.56037176307, 1, 1, -0.40320752514, 0.73736786626
	awf3i biquad awf2i, 1, 0.19165327787, 1, 1, -0.15398586410, 0.94001488557

	aw1fi = awf3i * 0.051532459925
	awq2i = aw1fi * aqo2i
	aout = awq2r + awq2i
	xout aout
endop


/*
	Stereo frequency shifter with direct modulation
	
	aoutputL, aoutputR freqshift2 ainputL, ainputR, kfrequency, [kshiftmode=1]

	aoutputL	output audio left
	aoutputR	output audio right
	ainputL		input audio left
	ainputR		input audio right
	kfrequency	shift frequency [MIN(-10000) MAX(10000) DEFAULT(-500)]
	kshiftmode	shift mode [TYPE(bool) DEFAULT(1)]
*/
opcode freqshift2, aa, aakP
	ainL, ainR, kfreq, kshiftmode xin
	isr4 = sr * 0.25

	ko1frq = isr4 - (1 - kshiftmode) * kfreq
	aqo1r oscil 1.0, ko1frq, gifnSine, 0.25 ; cosine
	aqo1i oscil 1.0, ko1frq, gifnSine, 0.0 ; sine
	ko2frq = isr4 + kshiftmode * kfreq
	aqo2r oscil 1.0, ko2frq, gifnSine, 0.25 ; cosine
	aqo2i oscil 1.0, ko2frq, gifnSine, 0.0 ; sine

	awq1rL = ainL * aqo1r
	awq1rR = ainR * aqo1r

	; Left
	awf1rL biquad awq1rL, 1, 1.6375276435, 1, 1, -0.93027644018, 0.37171017225
	awf2rL biquad awf1rL, 1, 0.56037176307, 1, 1, -0.40320752514, 0.73736786626
	awf3rL biquad awf2rL, 1, 0.19165327787, 1, 1, -0.15398586410, 0.94001488557
	aw1frL = awf3rL * 0.051532459925
	awq2rL = aw1frL * aqo2r

	awq1iL = ainL * aqo1i
	awf1iL biquad awq1iL, 1, 1.6375276435, 1, 1, -0.93027644018, 0.37171017225
	awf2iL biquad awf1iL, 1, 0.56037176307, 1, 1, -0.40320752514, 0.73736786626
	awf3iL biquad awf2iL, 1, 0.19165327787, 1, 1, -0.15398586410, 0.94001488557

	aw1fiL = awf3iL * 0.051532459925
	awq2iL = aw1fiL * aqo2i
	aoutL = awq2rL + awq2iL

	; Right
	awf1rR biquad awq1rR, 1, 1.6375276435, 1, 1, -0.93027644018, 0.37171017225
	awf2rR biquad awf1rR, 1, 0.56037176307, 1, 1, -0.40320752514, 0.73736786626
	awf3rR biquad awf2rR, 1, 0.19165327787, 1, 1, -0.15398586410, 0.94001488557
	aw1frR = awf3rR * 0.051532459925
	awq2rR = aw1frR * aqo2r

	awq1iR = ainR * aqo1i
	awf1iR biquad awq1iR, 1, 1.6375276435, 1, 1, -0.93027644018, 0.37171017225
	awf2iR biquad awf1iR, 1, 0.56037176307, 1, 1, -0.40320752514, 0.73736786626
	awf3iR biquad awf2iR, 1, 0.19165327787, 1, 1, -0.15398586410, 0.94001488557

	aw1fiR = awf3iR * 0.051532459925
	awq2iR = aw1fiR * aqo2i
	aoutR = awq2rR + awq2iR

	xout aoutL, aoutR
endop



/*
	Bit depth reducer/crusher
	
	aout bitcrush ain, [krush=16]

	aout	crushed signal
	ain		input signal
	krush	bits to reduce to [TYPE(int) MIN(1) MAX(128) DEFAULT(16)]
	
*/
opcode bitcrush, a, aJ
	a1, krush xin
	krush = (krush == -1) ? 16 : krush
	a1 = round:a(a1 * krush) / krush
	xout a1
endop


/*
	Bit depth reducer/crusher (stereo)
	
	aoutL, aoutR bitcrush ainL, ainR, [krush=16]

	aoutL	crushed signal left
	aoutR	crushed signal right
	ainL	input signal left
	ainR	input signal right
	krush	bits to reduce to [TYPE(int) MIN(1) MAX(128) DEFAULT(16)]
	
*/
opcode bitcrush, aa, aaJ
	aL, aR, krush xin
	krush = (krush == -1) ? 16 : krush
	aL = round:a(aL * krush) / krush
	aR = round:a(aR * krush) / krush
	xout aL, aR
endop



/*
	Resonant delay based tuner

	aout delaytuner ain, kfrequency, kfeedback

	aout		tuned/delayed signal summed with input
	ain			input signal
	kfrequency	cps to tune to [MIN(20) MAX(10000) DEFAULT(440)]
	kfeedback	feedback amount [MIN(0) MAX(1) DEFAULT(0.5)]
*/
opcode delaytuner, a, akk
	ain, kfrequency, kfeedback xin
	adump delayr 1
	adelayed deltap (1/kfrequency)
	delayw ain + (adelayed * kfeedback)
	aout = ain + adelayed
	xout aout
endop


/*
	Resonant delay based tuner (stereo)

	aoutL, aoutR delaytuner ainL, ainR, kfrequency, kfeedback

	aoutL, aoutR	tuned/delayed signal summed with input
	ainL, ainR		input signal
	kfrequency		cps to tune to [MIN(20) MAX(10000) DEFAULT(440)]
	kfeedback		feedback amount [MIN(0) MAX(1) DEFAULT(0.5)]
*/
opcode delaytuner, aa, aakk
	ainL, ainR, kfrequency, kfeedback xin
	aoutL delaytuner ainL, kfrequency, kfeedback
	aoutR delaytuner ainR, kfrequency, kfeedback
	xout aoutL, aoutR
endop


/*
	Resonant delay based tuner with hold control. When held, only outputs effected, not dry
	
	aout glitchtuner ain, kfrequency, ktrig

	aout			output signal
	ain				input signal
	kfrequency		cps to tune to [MIN(20) MAX(10000) DEFAULT(440)]
	khold			apply if 1, bypass if 0
*/
opcode glitchtuner, a, akk
	ain, kfrequency, khold xin
	adump delayr 1
	adelayed deltap (1/kfrequency)
	if (khold >= 1) then
		aout = adelayed
	else
		aout = ain
	endif
	delayw aout
	xout aout
endop


/*
	Resonant delay based tuner with hold control (stereo). When held, only outputs effected, not dry
	
	aout glitchtuner ain, kfrequency, ktrig

	aoutL, aoutR	output signal
	ainL, ainR		input signal
	kfrequency		cps to tune to [MIN(20) MAX(10000) DEFAULT(440)]
	khold			apply if 1, bypass if 0
*/
opcode glitchtuner, aa, aakk
	ainL, ainR, kfrequency, khold xin
	aoutL glitchtuner ainL, kfrequency, khold
	aoutR glitchtuner ainR, kfrequency, khold
	xout aoutL, aoutR
endop



/*
	Simple chorus

	aoutL, aoutR simplechorus ainL, ainR, irateL, irateR

	aoutL, aoutR	output signal
	ainL, ainR		input signal
	irateL			delay rate in Hz left
	irateR			delay rate in Hz right
*/
opcode simplechorus, aa, aaii
	aL, aR, irateL, irateR xin
	alfoL oscil irateL, unirand(1)
	alfoR oscil irateR, unirand(1)
	aL vdelay3 aL, (0.01 + alfoL) * 1000, 1000
	aR vdelay3 aR, (0.01 + alfoR) * 1000, 1000
	xout aL, aR
endop

#end

