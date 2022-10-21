#ifndef INC_HYBRID_INSTR
#define INC_HYBRID_INSTR ##

#include "include/instruments_water.inc"
#include "include/instruments_idiophone.inc"
#include "sonics/array_tools.udo"
#include "sonics/wavetables.udo"
#include "sonics/soundxdb.udo"
#include "sonics/sequencing_melodic.udo"

; reson
instr note_hybrid1
	inote = p4
	
	ifreq = cpsmidinn(inote)
	ifileid = arr_random(gisnd_waterdrop)

	ifn = gisounddb[ifileid][0]
	idur = gisounddb[ifileid][2]
	
	ipitch = random(0.8, 1.6)

	itdur = (idur / ipitch) + random(0.2, 0.5)
	p3 = itdur
	;aL, aR loscil 1, ipitch, ifn, 1
	atime line 0, p3, idur*0.9
	aL, aR mincer atime, 1, ipitch, ifn, 0, 128 ; 1024
	aLr resony aL, ifreq, 2, random(8, 16), 10
	aRr resony aL, ifreq, 2, random(8, 16), 10

	aLr pareq aLr, ifreq, 0.4, 0.7
	aRr pareq aRr, ifreq, 0.4, 0.7

	aL balance aLr, aL
	aR balance aRr, aR
	aL dcblock aL
	aR dcblock aR

	kamp linseg 1, itdur*0.9, 1, itdur*0.1, 0

	iamp = random(0.7, 1)
	ipan = random(0, 1)
	aL *= kamp * iamp * ipan
	aR *= kamp * iamp * (1-ipan)
	bus_mix("pvsamp1", aL*random(0, 0.3), aR*random(0, 0.3))
	bus_mix("reverb1", aL*0.1, aR*0.1)
	bus_mix("delay2", aL*random(0, 0.01), aR*random(0, 0.01))
	bus_mix("master", aL, aR)
endin


instr phrase_hybrid1
	if (random(0, 1) > 0.5) then
		ifreqstart = random(1, 10)
		ifreqend = random(1, 10)
	else
		ifreqstart = random(1, 10)
		ifreqend = random(1, 10)
	endif
	kfreq linseg ifreqstart, p3, ifreqend
	
	kamp init 1
	ktrig metro kfreq
	if (ktrig == 1) then
		knote = min:k(mel_randomnote:k() + (round:k(random:k(-2, 2)) * 12), 127)
		if (random:k(0, 1) >= 0.5) then
			schedulek("note_idiophone1", random:k(0, 0.1), 0.1, knote, kamp*2)
		else
			schedulek("note_hybrid1", random:k(0, 0.1), 0.1, knote)
		endif
	endif
endin


/*
	Chord changing from idiophone to drops
	
	p4		one note (0 = play one note, 1 = play chord)
*/
instr phrase_hybrid2
	ionenote = p4

	if (ionenote == 1) then
		knote init mel_randomnote() + (round(random(-2, 4)) * 12)
	endif

	if (random(0, 1) > 0.5) then
		ifreqstart = random(10, 30)
		ifreqend = random(2, 10)
	else
		ifreqstart = random(2, 10)
		ifreqend = random(10, 30)
	endif
	kfreq linseg ifreqstart, p3, ifreqend

	kamp linseg 0, p3*0.1, 1, p3*0.8, 1, p3*0.1, 0
	ktransition line 1, p3, 0

	ktrig metro kfreq
	if (ktrig == 1) then
		if (random:k(0, 1) >= ktransition) then
			if (ionenote != 1) then
				knote = mel_randomnote:k() + (round:k(random:k(-2, 4)) * 12)
			endif
			schedulek("note_idiophone1", random:k(0, 0.1), 0.1, min:k(knote, 127), kamp*2)
		else
			schedulek("note_drop1", random:k(0, 0.1), 0.1)
		endif
	endif
endin


opcode portchord_drop, aa, iio
	ifreqmult, ireadmode, index xin

	ifileid = arr_random(gisnd_waterdrop)
	ifftsize = 16

	ifn = gisounddb[ifileid][0]
	ichannels = gisounddb[ifileid][1]
	idur = gisounddb[ifileid][2]
	irmsnorm = gisounddb[ifileid][3]

	kampb table index, gimel_amps
	kfreq table index, gimel_freqs

	kamp portk kampb, (i(gkseq_beattime) * gimel_portamento_beatratio) ; fade out when change

	kpitch = line(random(0.8, 1.2), p3, random(0.8, 1.2))

	istart = random(0.05, 0.2)
	iend = random(istart+0.1, 0.8) 
	atime = abs(oscil(iend - istart, random(0.001, 0.1), gifnSine, random(0, 1))) + istart

	klfo = oscil:k(random(0.0001, 0.009), random(1, 5)) + 1
	kfreq *= klfo

	aL init 0
	aR init 0
	if (kamp != 0) then
		if (ireadmode == 0) then
			aLm, aRm mincer atime*idur, kamp, kpitch, ifn, 0, ifftsize
		else
			aLm, aRm sndwarpst kamp, atime*idur, kpitch, ifn, 0, 4410, 441, 8, gifnHalfSine, 1
		endif
		aL resony aLm, kfreq*ifreqmult, 2, random(8, 16), 10
		aR resony aRm, kfreq*ifreqmult, 2, random(8, 16), 10
		aL balance aL, aLm
		aR balance aR, aRm
		aL butterhp aL, 210
		aR butterhp aR, 210
	endif
	ipan = random(0, 1)

	;aL *= (1 - irmsnorm) * 0.5 * ipan
	;aR *= (1 - irmsnorm) * 0.5 * (1-ipan)

	; recursion for all chord parts
	if (index + 1 < ftlen(gimel_amps)) then
		aLx, aRx portchord_drop ifreqmult, ireadmode, index + 1
		aL += aLx
		aR += aRx
	endif
	xout aL, aR
endop



instr phrase_hybridstretch1
	kamp linsegr 1, p3, 1, 1, 0
	kampx3 init 0.2
	kreverb1 init 0
	kreverb2 init 0
	kreverb3 init 0
	aL1, aR1 portchord_drop 0.5, 1
	;aL2, aR2 portchord_drop 1, 1
	aL3, aR3 portchord_drop 4, 1
	k3amp = abs:k(oscil:k(1, 0.1))

	;aL = (aL1 + aL2 + (aL3 * port(k3amp, 1))) * kamp
	;aR = (aR1 + aR2 + (aR3 * port(k3amp, 1))) * kamp

	aL = (aL1 + (aL3 * port(k3amp, 1))) * kamp
	aR = (aR1 + (aR3 * port(k3amp, 1))) * kamp

	kchangemetro = metro(0.2)
	if (kchangemetro == 1) then
		if (random:k(0, 1) > 0.2) then
			kampx3 = random:k(0.2, 1)
		endif
		if (random:k(0, 1) > 0.5) then
			kreverb1 = random:k(0, 0.4)
		endif
		if (random:k(0, 1) > 0.5) then
			kreverb2 = random:k(0, 0.4)
		endif
		if (random:k(0, 1) > 0.5) then
			kreverb3 = random:k(0, 0.4)
		endif
	endif

	aL pareq aL, 1000, 0.4, 0.7
	aR pareq aR, 1000, 0.4, 0.7

	bus_mix("reverb1", aL1*kreverb1, aR1*kreverb1)
	;bus_mix("reverb1", aL2*kreverb2, aR2*kreverb2)
	bus_mix("reverb1", aL3*kreverb3, aR3*kreverb3)
	bus_mix("master", aL, aR)
endin


/*
; pvsmorph
instr note_hybrid1x
	inote = p4
	
	ifileidBox, ipitchBox sounddb_mel_nearestnote gicol_idiophone, inote
	ifileidWater = arr_random(gisnd_waterdrop)

	ifnBox = gisounddb[ifileidBox][0]
	idurBox = gisounddb[ifileidBox][2]
	ifnWater = gisounddb[ifileidWater][0]
	idurWater = gisounddb[ifileidWater][2]
	
	ipitchWater = random(0.8, 1)

	p3 = min((idurWater / ipitchWater), (idurBox / ipitchBox))

	aboxL, aboxR loscil 1, ipitchBox, ifnBox, 1
	awaterL, awaterR loscil 1, ipitchWater, ifnWater, 1
	
	ir = 1024
	fboxL pvsanal aboxL, ir, ir/4, ir, 1
	fboxR pvsanal aboxR, ir, ir/4, ir, 1
	fwaterL pvsanal awaterL, ir, ir/4, ir, 1
	fwaterR pvsanal awaterR, ir, ir/4, ir, 1
	fL pvsmorph fboxL, fwaterL, 1, 0
	fR pvsmorph fboxR, fwaterR, 1, 0
	aL pvsynth fL
	aR pvsynth fR

	kamp linseg 1, p3*0.9, 1, p3*0.1, 0

	iamp = 5

	aL *= kamp * iamp
	aR *= kamp * iamp
	bus_mix("pvsamp1", aL*random(0, 0.1), aR*random(0, 0.1))
	bus_mix("reverb1", aL*random(0, 0.1), aR*random(0, 0.1))
	bus_mix("master", aL, aR)
endin
*/

#end
