#ifndef INC_MUSICBOX_INSTR
#define INC_MUSICBOX_INSTR ##
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

	Partial Emergence
		by Richard Knight 2022

	Installation submission for the International Csound Conference 2022

	Music box instruments

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "sonics/soundxdb.udo"
#include "sonics/array_tools.udo"
#include "sonics/sequencing_melodic.udo"
#include "sonics/sequencing_melodic_portamento.udo"
#include "sonics/bussing.udo"
#include "sonics/frequency_tools.udo"
#include "sonics/instrument_portchord.udo"
#include "sonics/instrument_gchord1.udo"
#include "sonics/wavetables.udo"


; sound collections
gicol_musicbox sounddb_getcollectionid "MusicBox"
gicol_kalimba sounddb_getcollectionid "Kalimba"
gicol_idiophone = gicol_musicbox
gicol_idiophone_other = gicol_kalimba

opcode idiophone_change, 0, 0
	if (random(0, 1) >= 0.5) then
		gicol_idiophone = gicol_musicbox
		gicol_idiophone_other = gicol_kalimba
	else
		gicol_idiophone = gicol_kalimba
		gicol_idiophone_other = gicol_musicbox
	endif
endop

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

	Sample playback initiation instruments

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


instr note_idiophone_randtime
	ifileid, ipitchratio sounddb_mel_nearestnote gicol_idiophone, mel_randomnote()
	ifn = gisounddb[ifileid][0]
	idur = gisounddb[ifileid][2]
	;p3 = random(4, 8)

	ipitch = round(random(1, 2)) * ipitchratio
	ktime init random(0, idur)
	aL, aR mincer a(port(ktime, 0.001, random(0, idur))), 1, ipitch, ifn, 0, 256 ;64

	if (random:k(0, 1) > 0.1) then
		ktime = random:k(0, idur)
	endif


	kamp linseg 1, p3*0.8, 1, p3*0.2, 0
	aL *= kamp
	aR *= kamp

	if (random(0, 1) > 0.8) then
		bus_mix("delay1", aL*random(0, 0.3), aR*random(0, 0.3))
	endif

	bus_mix("reverb1", aL*random(0.2, 0.8), aR*random(0.2, 0.8))

	if (random(0, 1) > 0.5) then
		bus_mix("pvsamp1", aL*0.6, aR*0.6)
	endif

	bus_mix("master", aL, aR)
endin


/*
	Idiophone chord
	
	p4		one note (0 = play one note, 1 = play chord)
*/
instr phrase_idiophone1
	ionenote = p4

	if (ionenote == 1) then
		knote init mel_randomnote() + (round(random(-2, 4)) * 12)
	endif

	if (random(0, 1) > 0.5) then
		ifreqstart = random(10, 30)
		ifreqend = random(2, 15)
	else
		ifreqstart = random(2, 10)
		ifreqend = random(10, 30)
	endif
	kfreq linseg ifreqstart, p3, ifreqend
	kamp linseg 0, p3*0.1, 1, p3*0.8, 1, p3*0.1, 0

	ktrig metro kfreq
	if (ktrig == 1) then
		if (ionenote != 1) then
			knote = mel_randomnote:k() + (round:k(random:k(-2, 4)) * 12)
		endif
		schedulek("note_idiophone1", random:k(0, 0.1), 0.1, min:k(knote, 127), kamp*2)
	endif
endin


/*
	Idiophone chord using portamento note frequencies
	
	p4		one note (0 = play one note, 1 = play chord)
*/
instr phrase_idiophone2
	ionenote = p4
	ilen = mel_length() * random(1, 10)
	p3 = ilen

	if (ionenote == 1) then
		itlen = table:i(0, gimel_current_notes)
		index = round(random(1, itlen-1))
		kindex init index
		knote init table(index, gimel_current_notes)
		knoteaugment init (round(random(-2, 4)) * 12)
	endif

	kfreq linseg random(20, 60), ilen, random(2, 10)

	kamp linseg 1, p3, 0
	if (random(0, 1) > 0.5) then
		kamp = 1-kamp
	endif

	ktrig metro kfreq
	if (ktrig == 1) then
		if (ionenote != 1) then
			klen = table:k(0, gimel_current_notes)
			kindex = round:k(random:k(1, klen-1))
			knote = table:k(kindex, gimel_current_notes)
			knoteaugment = (round:k(random:k(-2, 4)) * 12)
		endif

		kportfreq = table:k(kindex-1, gimel_freqs)
		kportamp = table:k(kindex-1, gimel_amps)

		if (kportfreq != cpsmidinn:k(knote)) then
			kscale = cpsmidinn:k(knote) / kportfreq
		else
			kscale = 1
		endif
		schedulek("note_idiophone2", random:k(0, 0.1), 1, min:k(knote+knoteaugment, 127), kamp*kportamp, kscale)
	endif
endin


/*
	Stretch idiophone chord

	p4		mode (0 = flipflop loop, 1 = linear loop)
*/
instr phrase_idiophone_stretch1
	imode = p4
	ilen = p3
	index = 1
	inoteaugment = min((round(random(-1, 4)) * 12), 127)
	while (index < table:i(0, gimel_current_notes)) do
		inote = table(index, gimel_current_notes)
		schedule("note_idiophonestretch1", 0, ilen, inote + inoteaugment, imode)
		index += 1
	od
	turnoff
endin


/*
	Stretch music box chord

	p4		mode (0 = flipflop loop, 1 = linear loop)
*/
instr phrase_idiophone_stretch2
	imode = p4
	ilen = p3
	index = 1
	while (index < table:i(0, gimel_current_notes)) do
		inote = table(index, gimel_current_notes)
		schedule("note_idiophonestretch2", 0, ilen, inote, imode, 0, 1) ; no low pass, out to note_idiophonestretch2 bus, mincer read
		schedule("note_idiophonestretch2", 0, ilen, inote-12, imode, 1, 0) ; low pass, master out, sndwarp read
		index += 1
	od
	turnoff
endin


instr phrase_idiophone_stretch3
	ksendDelay1 init 0
	ksendReverb1 init 0.3
	ksendPV1 init 0
	kampx4 init 0
	kamp linsegr 0, 0.5, 1, p3-0.5, 1, 1, 0

	; cpu saving: first arg 0 = sndwarp, 1 = mincer
	aL1, aR1 portchord_sound gicol_idiophone, 0, 0.5, 512
	aL2, aR2 portchord_sound gicol_idiophone, 0, 1, 1024 
	aL3, aR3 portchord_sound gicol_idiophone, 0, 2, 512

	aL = (aL3 * portk(kampx4, 2) + (aL1 + aL2)) * kamp
	aR = (aR3 * portk(kampx4, 2) + (aR1 + aR2)) * kamp

	kchangemetro = metro(0.2)
	if (kchangemetro == 1) then
		if (random:k(0, 1) > 0.6) then
			ksendDelay1 = random:k(0, 0.8)
		endif
	
		if (random:k(0, 1) > 0.6) then
			ksendReverb1 = random:k(0.3, 0.8)
		endif

		if (random:k(0, 1) > 0.6) then
			ksendPV1 = random:k(0, 0.8)
		endif

		if (random:k(0, 1) > 0.6) then
			kampx4 = random:k(0, 1.5)
		endif
	endif

	ksendDelay1p = port(ksendDelay1, 1)
	ksendReverb1p = port(ksendReverb1, 1)
	ksendPV1p = port(ksendPV1, 1)

	bus_mix("delay1", aL*ksendDelay1p, aR*ksendDelay1p)
	bus_mix("reverb1", aL*ksendReverb1p, aR*ksendReverb1p)
	bus_mix("pvsamp1", aL*ksendPV1p, aR*ksendPV1p)
	bus_mix("master", aL, aR)
endin


instr phrase_idiophone_stretch4
	iamp = 0.5
	klpf1 init 22050
	klpf2 init 22050

	ichangechance = random(0.1, 0.6)
	icompressmode = 2 ; 0 = none ; 1 = harshwall ; 2 = normal
	aL1, aR1 fnmi_gchord1 gicol_idiophone, 1, 3, icompressmode, ichangechance, 2, 0 ; 1 is mincer
	aL2, aR2 fnmi_gchord1 gicol_idiophone, 1, 3, icompressmode, ichangechance, 1, 0 

	klpf1p port klpf1, 3
	klpf2p port klpf2, 3
	aL1 butterlp aL1, klpf1p
	aR1 butterlp aR1, klpf1p
	aL2 butterlp aL2, klpf2p
	aR2 butterlp aR2, klpf2p
	kchangemetro = metro(0.2)
	if (kchangemetro == 1) then
		if (random:k(0, 1) > 0.6) then
			klpf1 = random:k(400, 22050)
		endif
	
		if (random:k(0, 1) > 0.6) then
			klpf2 = random:k(400, 22050)
		endif
	endif

	aL = (aL1 + aL2) * iamp
	aR = (aR1 + aR2) * iamp


	bus_mix("master", aL, aR)
	bus_mix("reverb1", aL*0.4, aR*0.4)
	bus_mix("pvsamp1", aL*0.1, aR*0.1)
endin


/*
	Play a short glissando, possibly ascending or descending
*/
instr phrase_idiophone_gliss1
	iamp = p4
	ilen = table:i(0, gimel_current_notes)
	itime = 0
	imultreal = 1
	imaxmult = 6
	iascending = round(random(0, 1))
	if (iascending == 1) then
		iincrement = 1
		istartindex = 1
		imult = 1
	else
		iincrement = -1
		istartindex = ilen
		imult = imaxmult 
	endif
		
	while (imultreal <= imaxmult) do
		indexreal = 1
		index = istartindex
		while (indexreal < ilen) do
			inote = (table:i(index, gimel_current_notes)-12)+(12*imult)
			if (inote >= 127 || inote <= 0) then
				goto complete
			endif
			schedule("note_idiophone1", itime, 0.1, inote, iamp, gicol_idiophone_other)
			itime += random(0.05, 0.1)
			indexreal += 1
			index += iincrement
		od
		imult += iincrement
		imultreal += 1
	od
complete:
	turnoff
endin


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

	Transition instruments

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


instr transition_idiophone_randtime
	iriseratio = p4
	kamp expseg 0.00001, p3*iriseratio, 1, p3*(1-iriseratio), 0.00001
	ifileid, ipitchratio sounddb_mel_nearestnote gicol_idiophone_other, mel_randomnote()
	ifn = gisounddb[ifileid][0]
	idur = gisounddb[ifileid][2]

	ipitch = round(random(1, 2)) * ipitchratio
	ktime init random(0, idur)
	aL, aR mincer a(port(ktime, 0.001, random(0, idur))), 1, ipitch, ifn, 0, 256 ;64

	if (random:k(0, 1) > 0.1) then
		ktime = random:k(0, idur)
	endif

	aL *= kamp * 3
	aR *= kamp * 3

	if (random(0, 1) > 0.8) then
		bus_mix("delay1", aL*random(0, 0.3), aR*random(0, 0.3))
	endif

	bus_mix("reverb1", aL*random(0.4, 0.8), aR*random(0.4, 0.8))

	if (random(0, 1) > 0.5) then
		bus_mix("pvsamp1", aL*0.6, aR*0.6)
	endif

	bus_mix("master", aL, aR)
endin


instr transition_idiophone_gliss1
	iriseratio = p4
	kamp expseg 0.00001, p3*iriseratio, 1, p3*(1-iriseratio), 0.00001
	kmetro metro 20
	kmult init 0
	kincrement init 1
	kindex init 1

	if (kmetro == 1) then
		knote = min:k((table:k(kindex, gimel_current_notes))+(12*kmult), 127)
		schedulek("note_idiophone1", random:k(0, 0.1), 0.1, knote, kamp*3.5, gicol_idiophone_other)
	
		kmaxnotes = table:k(0, gimel_current_notes)
		if ((kindex < kmaxnotes - 1 && kincrement == 1) || (kindex > 1 && kincrement == -1)) then
			kindex += kincrement
		else
			kindex = (kincrement == 1) ? 1 : kmaxnotes - 1
			kmult += kincrement
			if (kmult >= 4) then
				kmult = 4
				kincrement = -1
			elseif (kmult < 0) then
				kmult = 0
				kincrement = 1
			endif
		endif
	
	endif
endin


instr transition_idiophone_stretch1
	iriseratio = p4
	kamp expseg 0.00001, p3*iriseratio, 1, p3*(1-iriseratio), 0.00001

	inotestart = mel_randomnote()
	inoteend = mel_randomnote()
	
	if (random(0, 1) >= 0.5) then
		inotestart += 12
	endif

	if (random(0, 1) >= 0.5) then
		inoteend += 12
	endif

	
	ifileid, ipitchratio sounddb_mel_nearestnote gicol_idiophone_other, inotestart
	ifn = gisounddb[ifileid][0]
	idur = gisounddb[ifileid][2]

	istart = random(0.01, 0.1)
	iend = random(istart+0.05, 0.3) 
	atime = abs(oscil(iend-istart, random(0.001, 0.1), gifnSine, random(0, 1)))
	atime *= idur
	apitchratio line ipitchratio, p3, (ipitchratio * (cpsmidinn(inoteend) / cpsmidinn(inotestart)))

	isndwarpadjust = (ftsr(ifn) / sr) ; adjustment for sndwarp required
	aL, aR sndwarpst kamp, atime, apitchratio*isndwarpadjust, ifn, istart, 4096, 128, 2, gifnHalfSine, 1
	
	bus_mix("reverb1", aL*random(0, 0.8), aR*random(0, 0.8))
	bus_mix("pvsamp1", aL*random(0, 0.2), aR*random(0, 0.2))
	bus_mix("master", aL*1.7, aR*1.7)
endin


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

	Sample playback note instruments

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


/*
	Play music box note with stochastic transforms and sends

	p4		midi note number
	p5		amplitude (0 to 1)
	p6		optional collection, defaults to gicol_idiophone
*/
instr note_idiophone1
	inote = p4
	iamp = p5 * 0.2
	icollection = (p6 == 0) ? gicol_idiophone : p6
	iamp *= random(0.6, 1)
	ifileid, ipitchratio sounddb_mel_nearestnote icollection, inote

	if (active:i(p1) < 50 && (abs(ipitchratio) > 1.8 || random(0, 1) > 0.8)) then
		iloscilratio = 1
		idopvs = 1
	else
		iloscilratio = ipitchratio
		idopvs = 0
	endif

	ifn = gisounddb[ifileid][0]
	idur = gisounddb[ifileid][2]
	p3 = idur / iloscilratio
	kamp linseg iamp, p3*0.6, iamp, p3*0.4, 0
	;ktime line random(0, 0.2), p3, p3
	;aL, aR sndwarpst kamp, ktime, iloscilratio, isound[0], 0, 441*random(1, 100), 44*random(1, 10), 4, gifnHalfSine, 1
	aL, aR loscil kamp, iloscilratio, ifn, 1

	if (idopvs == 1) then
		if (random(0, 1) > 0.75) then
			ipitchratio *= pow(2, int(random(1, 4)))
		endif
		ir = 512
		fL1 pvsanal aL, ir, ir/2, ir, 1
		fR1 pvsanal aR, ir, ir/2, ir, 1
		fL2 pvscale fL1, ipitchratio
		fR2 pvscale fR1, ipitchratio
		aL pvsynth fL2
		aR pvsynth fR2
	endif

	ipan = random(0, 1)
	aL *= ipan
	aR *= (1-ipan)

	if (random(0, 1) > 0.6) then
		aL pareq aL, random(100, 4000), random(0.3, 1.1), 0.7
		aR pareq aR, random(100, 4000), random(0.3, 1.1), 0.7
	endif

	if (random(0, 1) > 0.9) then
		bus_mix("delay1", aL*random(0.1, 0.4), aR*random(0.1, 0.4))
	endif

	if (random(0, 1) > 0.8) then
		;krenv linseg 0, p3*0.1, 1, p3*0.8, 1, p3*0.1, 0
		bus_mix("reverb1", aL*random(0.1, 0.7), aR*random(0.1, 0.7))
	endif

	if (random(0, 1) > 0.5) then
		bus_mix("pvsamp1", aL*random(0.5, 0.8), aR*random(0.5, 0.8))
	endif

	bus_mix("master", aL, aR)
	
endin




/*
	Play music box note with stochastic transforms and sends

	p4		midi note number
	p5		amplitude (0 to 1)
	p6		pitchscale: amount to scale pitch by (for portamento augmentation)
*/
instr note_idiophone2
	inote = p4
	iamp = p5 * 0.2
	ipitchscale = p6

	iamp *= random(0.6, 1)
	kamp linseg iamp, p3*0.6, iamp, p3*0.4, 0
	ifileid, ipitchratio sounddb_mel_nearestnote gicol_idiophone, inote

	kpitchratio init ipitchratio * ipitchscale

	kpitchenv = abs:k(oscil:k(random(0.001, 0.01), random(0.1, 4), gifnSine, random(0, 1))) + 1
	kpitchratio += kpitchenv

	if (kpitchratio > 1.8 || random(0, 1) > 0.8) then
		kloscilratio init 1
		idopvs = 1
	else
		kloscilratio = kpitchratio
		idopvs = 0
	endif

	ifn = gisounddb[ifileid][0]
	idur = gisounddb[ifileid][2]

	p3 = idur
	;ktime line random(0, 0.2), p3, p3
	;aL, aR sndwarpst kamp, ktime, iloscilratio, isound[0], 0, 441*random(1, 100), 44*random(1, 10), 4, gifnHalfSine, 1
	aL, aR loscil kamp, kloscilratio, ifn, 1

	if (idopvs == 1) then
		if (random(0, 1) > 0.5) then
			kpitchratio *= pow(2, int(random(1, 4)))
		endif
		ir = 512
		fL1 pvsanal aL, ir, ir/4, ir, 1
		fR1 pvsanal aR, ir, ir/4, ir, 1
		fL2 pvscale fL1, kpitchratio
		fR2 pvscale fR1, kpitchratio
		aL pvsynth fL2
		aR pvsynth fR2
	endif

	ipan random 0, 1
	aL *= ipan
	aR *= (1-ipan)

	if (random(0, 1) > 0.8) then
		kdenv linseg 0, p3*0.1, 1, p3*0.8, 1, p3*0.1, 0
		bus_mix("delay1", aL*kdenv, aR*kdenv)
	endif

	if (random(0, 1) > 0.8) then
		krenv linseg 0, p3*0.1, 1, p3*0.8, 1, p3*0.1, 0
		bus_mix("reverb1", aL*krenv, aR*krenv)
	endif

	if (random(0, 1) > 0.5) then
		bus_mix("pvsamp1", aL, aR)
	endif
	
	bus_mix("master", aL, aR)
	
endin



/*
	Play held/stretched music box note with stochastic transforms and sends

	p4		midi note number
	p5		mode (0 = forwards and reverse, 1 = linear forwards)
*/
instr note_idiophonestretch1
	inote = p4
	imode = p5
	iamp = 0.6
	kamp linseg 0, p3*0.2, iamp, p3*0.6, iamp, p3*0.2, 0
	ifileid, ipitchratio sounddb_mel_nearestnote gicol_idiophone, inote
	ifn = gisounddb[ifileid][0]
	idur = gisounddb[ifileid][2]
	ipitchratio *= (ftsr(ifn) / sr) ; adjustment for sndwarp required

	if (imode == 0) then
		istart = random(0, 0.3)
		iend = random(istart+0.1, 0.5)
		atime = abs(oscil(iend-istart, random(0.001, 0.1), gifnSine, random(0, 1))) 
	else
		istart = 0
		iend = random(0.1, 0.99)
		atime = (phasor(random(10, 40)) * (iend-istart))
	endif
	

	if (random(0, 1) > 0.5) then
		alfo = oscil(random(0.0001, 0.0009), random(4, 10)) + 1
		apitchratio = ipitchratio * alfo
	else
		apitchratio init ipitchratio
	endif
	
	atime *= idur

	aL, aR sndwarpst kamp, atime, apitchratio, ifn, istart, 441*random(1, 100), 44*random(1, 10), 8, gifnHalfSine, 1

	aL butterhp aL, 150
	aR butterhp aR, 150

	if (random(0, 1) > 0.5) then
		atemp = aL
		aL = aR
		aR = atemp	
	endif

	if (random(0, 1) > 0.2) then
		krenv linseg 0, p3*0.1, 1, p3*0.8, 1, p3*0.1, 0
		bus_mix("reverb1", aL*krenv, aR*krenv)
	endif

	if (random(0, 1) > 0.5) then
		bus_mix("pvsamp1", aL, aR)
	endif
	
	bus_mix("master", aL, aR)
endin




instr note_idiophonestretch2
	inote = p4
	imode = p5
	ilpmode = p6
	ireadmode = p7 ; 0 = sndwarp, 1 = mincer
	iamp = 0.4
	kamp linseg 0, p3*0.2, iamp, p3*0.6, iamp, p3*0.2, 0
	ifileid, ipitchratio sounddb_mel_nearestnote gicol_idiophone, inote
	ifn = gisounddb[ifileid][0]
	idur = gisounddb[ifileid][2]

	if (imode == 0) then
		istart = random(0.05, 0.2)
		iend = random(istart+0.1, 0.8) 
		atime = abs(oscil(iend-istart, random(0.001, 0.1), gifnSine, random(0, 1)))
	else
		istart = 0
		iend = random(0.1, 0.99)
		atime = (phasor(random(10, 40)) * (iend-istart))
	endif
	
	if (random(0, 1) > 0.4) then
		alfo = oscil(random(0.0001, 0.001), random(4, 10)) + 1
		apitchratio = ipitchratio * alfo
	else
		apitchratio init 1
	endif

	atime *= idur
	
	if (ireadmode == 0) then
		isndwarpadjust = (ftsr(ifn) / sr) ; adjustment for sndwarp required
		aL, aR sndwarpst kamp, atime, apitchratio*isndwarpadjust, ifn, istart, 4096, 128, 2, gifnHalfSine, 1
	else
		aL, aR mincer atime+istart, kamp, k(apitchratio), ifn, 0, 512
	endif
	
	ipan = random(0, 1)
	aL *= (1-ipan)
	aR *= (ipan)

	aLh butterhp aL, 150
	aRh butterhp aR, 150


	if (random(0, 1) > 0.8) then
		krenv linseg 0, p3*0.1, 1, p3*0.8, 1, p3*0.1, 0
		bus_mix("reverb1", aLh*krenv, aRh*krenv)
	endif

	if (random(0, 1) > 0.7) then
		bus_mix("pvsamp1", aLh, aRh)
	endif
	
	if (ilpmode == 0) then
		bus_mix("note_idiophonestretch2", aLh, aRh)
	elseif (ilpmode == 1) then
		aL butterlp aL, 500
		aR butterlp aR, 500
		bus_mix("master", aL*0.8, aR*0.8)
	endif
endin




#end
