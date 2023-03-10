#ifndef UDO_FNMI_PORTCHORD
#define UDO_FNMI_PORTCHORD ##
/*
	Portamento recursive chord players
	Slim excerpt for Partial Emergence

	This file is part of the SONICS UDO collection by Richard Knight 2021
		License: GPL-2.0-or-later
		http://1bpm.net
*/

#include "sonics/sequencing_melodic_persistence.udo"
#include "sonics/sequencing_melodic_portamento.udo"
#include "sonics/wavetables.udo"
#include "sonics/soundxdb.udo"




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

	ifftsize = (ifftsize == -1) ? 512 : ifftsize

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
	

	if (kamp != 0) then
		atime = abs(oscil(iend - istart, random(0.001, 0.1), gifnSine, random(0, 1)))

		atime *= idur
		klfo = oscil:k(random(0.0001, 0.009), random(1, 5)) + 1
		kpitch *= klfo
		if (imode == 0) then
			kpitch *= (ftsr(ifn) / sr) ; adjustment for sndwarp required
			
			; atime / 2???
			aL, aR sndwarpst kamp, atime, interp(kpitch), ifn, istart, 4096, 128, 2, gifnHalfSine, 1
			aL pareq aL, 90, 0.5, 0.6
			aR pareq aR, 90, 0.5, 0.6
		else
			if (ichannels == 2) then
				aL, aR mincer atime+istart, kamp, kpitch, ifn, 0, ifftsize
			else
				aL mincer atime+istart, kamp, kpitch, ifn, 0, ifftsize
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
