#ifndef UDO_MELSEQUENCINGPORT
#define UDO_MELSEQUENCINGPORT ##

/*
	Extension to sequencing_melodic.udo which permits usage of k-rate frequency arrays
	Slim excerpt for Partial Emergence

	This file is part of the SONICS UDO collection by Richard Knight 2021
		License: GPL-2.0-or-later
		http://1bpm.net
*/

#include "sonics/__config__.udo"				; using fftsize for tuning
#include "sonics/sequencing_melodic.udo"
#include "sonics/wavetables.udo"


gimel_freqs ftgen 0, 0, -12, -7, 0		; current notes: index 0 is the length
gimel_amps ftgen 0, 0, -12, -7, 0		; current notes: index 0 is the length
gimel_portamento_beatratio init 0.5		; portamento time as ratio of current beat time
gimel_linetype init 0  					; 0=pre-section, 1=post-section


/*
	Automate a frequency/amp line
*/
instr _mel_linedraw
	index = p4
	ifreq = p5
	iamp = p6

	icurrentfreq table index, gimel_freqs

	if (icurrentfreq == 0 && ifreq != 0) then
		tablew ifreq, index, gimel_freqs
	elseif (ifreq != 0 && icurrentfreq != ifreq) then
		tablew line:k(icurrentfreq, p3, ifreq), index, gimel_freqs
	endif

	icurrentamp table index, gimel_amps
	if (icurrentamp != iamp) then
		tablew line:k(icurrentamp, p3, iamp), index, gimel_amps
	endif
endin


instr _mel_linestep_inner
	if (timeinstk() == 1) then
		turnoff2 "_mel_linedraw", 0, 0
	endif

	if (table:i(1, gimel_next_notes) != 0) then
		index = 0
		while (index < table:i(0, gimel_next_notes)) do
			event_i "i", "_mel_linedraw", 1/kr, p3, index, cpsmidinn(table:i(index + 1, gimel_next_notes)), 1		
			index += 1
		od
		while (index < ftlen(gimel_freqs)) do
			event_i "i", "_mel_linedraw", 1/kr, p3, index, 0, 0
			index += 1
		od
	endif
endin


instr _mel_linestep
	icurrentduration mel_length
	ilinetime = (i(gkseq_beattime) * gimel_portamento_beatratio)
	if (gimel_linetype == 0) then
		inextline = icurrentduration - ilinetime
	else
		inextline = icurrentduration
	endif
	event_i "i", "_mel_linestep_inner", inextline, ilinetime
	turnoff
endin


/*
	Portamento manager: respond to gkmel_section_change trigger by calling _mel_linestep instrument
*/
instr _mel_linemanager
	; set initial freqs
	index = 0
	while (index < table:i(0, gimel_current_notes)) do
		tablew cpsmidinn(table:i(index + 1, gimel_current_notes)), index, gimel_freqs
		tablew 1, index, gimel_amps
		index += 1
	od
	while (index < ftlen(gimel_freqs)) do
		tablew 0, index, gimel_amps
		index += 1
	od

	schedkwhen gkmel_section_change, 0, 1, "_mel_linestep", 0, 1
endin

schedule "_mel_linemanager", 0.1, 36000 ; notes not ready on 0
;alwayson "_mel_linemanager"





/*
	Recursively create a chord to be used by mel_tune_portamento; internal use only

	aout _mel_tune_chord_portamento kfreqmult, ifn, imaxmult, imult, index

	aout			chord output
	kfreqmult		frequency multiplier to apply to tuning
	ifn 			wavetable to use
	imaxmult		multiples of harmonics to generate in tuning
	imult			internal multiplier for recursion
	index			internal index for recursion
	
*/
opcode _mel_tune_chord_portamento, a, kiipo
	kfreqmult, ifn, imaxmult, imult, index xin
	

	if (index + 1 > ftlen(gimel_amps)) then
		index = 0
		imult += 1
	endif
	
	aout = oscil(table:k(index, gimel_amps), kfreqmult * table:k(index, gimel_freqs) * pow:k(2, imult), ifn) * 0.1
	; recursion for all chord parts
	if (imult <= imaxmult) then
		
		aout += _mel_tune_chord_portamento(kfreqmult, ifn, imaxmult, imult, index + 1)
	endif

    xout aout
endop



/*
	Stereo tuning to current melodic sequencer notes
	aoutL, aoutR mel_tune ainL, ainR, ifn, imult [, ifftrate, ifftdiv]

	aoutL, aoutR    	output audio
	ainL, ainR          input audio
	ifn                 wavetable to use
	imaxmult            multiples of harmonics to generate in tuning (defaults to 4)
	ifftrate            fft size, defaults to config default
	ifftdiv             fft window division factor (eg 4, 8, 16), defaults to config default
	kfreqmult			frequency multiplier to apply to tuning
*/
opcode mel_tune_portamento, aa, aaooooP
	aL, aR, ifn, imaxmult, ifftrate, ifftdiv, kfreqmult xin
	ifn = (ifn == 0) ? gifnSine : ifn
	imaxmult = (imaxmult == 0) ? 4 : imaxmult
	ifftrate = (ifftrate == 0) ? giFFTsize : ifftrate
	ifftdiv = (ifftdiv == 0) ? giFFTwinFactor : ifftdiv
	fmods pvsanal _mel_tune_chord_portamento(kfreqmult, ifn, imaxmult), ifftrate, ifftrate/ifftdiv, ifftrate, 1
	fL1 pvsanal aL, ifftrate, ifftrate/ifftdiv, ifftrate, 1
	fR1 pvsanal aR, ifftrate, ifftrate/ifftdiv, ifftrate, 1
	fL2 pvsmorph fL1, fmods, 0, 1
	fR2 pvsmorph fR1, fmods, 0, 1
	aL1 pvsynth fL2
	aR1 pvsynth fR2
	idel = (ifftrate+2)/sr
	aL1 balance aL1, delay(aL, idel)
	aR1 balance aR1, delay(aR, idel)
	xout aL1, aR1
endop


#end

