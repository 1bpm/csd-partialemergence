#ifndef UDO_FNMI_PORTCHORD
#define UDO_FNMI_PORTCHORD ##
/*
	Portamento recursive chord players
	Slim excerpt for Partial Emergence

	This file is part of the SONICS UDO collection by Richard Knight 2021
		License: GPL-2.0-or-later
		http://1bpm.net
*/

#include "sonics/__config__.udo"
#include "sonics/sequencing_melodic_persistence.udo"
#include "sonics/sequencing_melodic_portamento.udo"
#include "sonics/wavetables.udo"
#include "sonics/sounddb.udo"


/*
	Play continuous chords from melodic sequencer with portamento, using oscil as an instrument and a specified wavetable

	aL, aR portchord_wave [iwavefn=gifnSine, ifreqmult=1, ivibdepth=1, ivibrate=3, index=0]

	aL, aR			stereo outputs
	iwavefn			the f-table to use with oscil
	ifreqmult		frequency multiplier of the chord note frequencies to be applied
	ivibdepth		vibrato depth
	ivibrate		vibrato rate in Hz
	index			internal start index of the chord notes; could also be used to specify starting note offset
*/
opcode portchord_wave, aa, jpjjo
	iwavefn, ifreqmult, ivibdepth, ivibrate, index xin
	
	iwavefn = (iwavefn == -1) ? gifnSine : iwavefn
	ivibdepth = (ivibdepth == -1) ? 1 : ivibdepth
	ivibrate = (ivibrate == -1) ? 3 : ivibrate

	kamp table index, gimel_amps
	kfreq table index, gimel_freqs

	klfo = oscil:k(ivibdepth, ivibrate) ;oscil:k(7, 5)
	kfreq += klfo
	kfreq *= ifreqmult

	;kamp portk kamp, (i(gkseq_beattime) * gimel_portamento_beatratio) ; fade out when change

	aL oscil kamp*0.1, kfreq, iwavefn
	ipan = random(0, 1)
	aR = aL * ipan
	aL *= (1 - ipan)

	if (index + 1 < ftlen(gimel_amps)) then
		aLx, aRx portchord_wave iwavefn, ifreqmult, ivibdepth, ivibrate, index + 1
		aL += aLx
		aR += aRx
	endif

	xout aL, aR
endop



/*
	Play continuous chords from melodic sequencer with portamento, using a sounddb collection as source sounds

	aL, aR portchord_sound icollectionid [, imode=1, ifreqmult=1, ifftsize=giFFTsize, index=0]

	aL, aR			stereo outputs
	icollectionid	collection ID from sounddb to use for the playback
	imode			0 = read with sndwarp; 1 = read with mincer
	ifreqmult		frequency multiplier of the chord note frequencies to be applied
	ifftsize		FFT size to use when imode = 1 ; default to global setting in __config__.udo
	index			internal start index of the chord notes; could also be used to specify starting note offset
*/
opcode portchord_sound, aa, ippjo
	icollectionid, imode, ifreqmult, ifftsize, index xin

	ifftsize = (ifftsize == -1) ? giFFTsize : ifftsize

	inote = round(random(50, 80))
	ibasefreq = cpsmidinn(inote)
	ifileid, ipitchratio sounddb_mel_nearestnote icollectionid, inote

	ifn = gisounddb[ifileid][0]
	ichannels = gisounddb[ifileid][1]
	idur = gisounddb[ifileid][2]
	irmsnorm = gisounddb[ifileid][3]

	kampb table index, gimel_amps
	kfreq table index, gimel_freqs

	kamp portk kampb, (i(gkseq_beattime) * gimel_portamento_beatratio) ; fade out when change

	kpitch = (kfreq / ibasefreq) * ifreqmult ; actual pitch adjustment

	istart = random(0.05, 0.2)
	iend = random(istart+0.1, 0.8) 
	atime = abs(oscil(iend - istart, random(0.001, 0.1), gifnSine, random(0, 1))) + istart


	klfo = oscil:k(random(0.0001, 0.009), random(1, 5)) + 1
	kpitch *= klfo

	if (kamp != 0) then
		if (imode == 0) then
			kpitch *= (ftsr(ifn) / sr) ; adjustment for sndwarp required
			
			;apitch interp kpitch
			aL, aR sndwarpst kamp, atime, kpitch, ifn, istart, 4410, 441, 8, gifnHalfSine, 1

		else
			if (ichannels == 2) then
				aL, aR mincer atime, kamp, kpitch, ifn, 0, ifftsize
			else
				aL mincer atime, kamp, kpitch, ifn, 0, ifftsize
				aR = aL
			endif
		endif
	endif

	aL *= (1 - irmsnorm) * 0.5
	aR *= (1 - irmsnorm) * 0.5

	; recursion for all chord parts
	if (index + 1 < ftlen(gimel_amps)) then
		aLx, aRx portchord_sound icollectionid, imode, ifreqmult, ifftsize, index + 1
		aL += aLx
		aR += aRx
	endif
	xout aL, aR
endop

#end
