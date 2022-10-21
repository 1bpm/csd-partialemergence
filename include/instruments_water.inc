#ifndef INC_WATER_INSTR
#define INC_WATER_INSTR ##
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

	Partial Emergence
		by Richard Knight 2022

	Installation submission for the International Csound Conference 2022

	Water instruments

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "sonics/soundxdb.udo"
#include "sonics/array_tools.udo"
#include "sonics/sequencing_melodic.udo"
#include "sonics/sequencing_melodic_portamento.udo"
#include "sonics/bussing.udo"
#include "sonics/frequency_tools.udo"
#include "sonics/wavetables.udo"

; sound collections
gisnd_waterpaddling[] sounddb_getcollection "Water.Paddling"
gisnd_waterdrop[] sounddb_getcollection "Water.Droplet"


instr play_waterpaddling1
	ifileid = arr_random(gisnd_waterpaddling)
	ifn = gisounddb[ifileid][0]
	idur = gisounddb[ifileid][2]

	kfreqshift init -100
	ipitch = random(0.5, 1.2)
	ktime init random(0, idur)
	aL, aR mincer a(port(ktime, 0.1, random(0, idur))), 1, ipitch, ifn, 0, pow(2, round(random(4, 7))) ;64

	aL, aR freqshift1 aL, aR, port(kfreqshift, 0.2)

	if (random:k(0, 1) > 0.2) then
		ktime = random:k(0, idur)
	endif

	if (random:k(0, 1) > 0.2) then
		kfreqshift = random(-1000, -100)
	endif

	kamp linseg 1, p3*0.8, 1, p3*0.2, 0
	aL *= kamp * 1.8
	aR *= kamp * 1.8

	if (random(0, 1) > 0.8) then
		bus_mix("delay1", aL*random(0, 0.3), aR*random(0, 0.3))
	endif

	if (random(0, 1) > 0.3) then
		bus_mix("reverb1", aL*random(0.2, 0.8), aR*random(0.2, 0.8))
	endif

	if (random(0, 1) > 0.5) then
		bus_mix("pvsamp1", aL*0.6, aR*0.6)
	endif

	bus_mix("master", aL, aR)
endin


instr _phrase_waterbubbler1_item
	ipitch = p4
	iamp = p5
	ioutmain = p6
	ifileid = arr_random(gisnd_waterdrop)
	ifn = gisounddb[ifileid][0]
	idur = gisounddb[ifileid][2]
	p3 = idur / ipitch
	kamp linseg 1, p3*0.8, 1, p3*0.2, 0
	kamp *= iamp
	aL, aR loscil kamp, ipitch, ifn, 1
	aL, aR freqshift1 aL, aR, random(-1000, -400)
	ipan = random(0, 1)

	if (random(0, 1) > 0.5) then
		aLr resony aL, table:k(0, gimel_freqs)*2, 4, 16, 10
		aRr resony aL, table:k(0, gimel_freqs)*2, 4, 16, 10
		aL balance aLr, aL
		aR balance aRr, aR
		aL dcblock aL
		aR dcblock aR
	endif


	if (random(0, 1) > 0.8) then
		bus_mix("delay1", aL*0.2, aR*0.2)
	endif

	if (random(0, 1) > 0.8) then
		bus_mix("reverb1", aL*0.5, aR*0.5)
	endif

	if (random(0, 1) > 0.8) then
		bus_mix("pvsamp1", aL, aR)
	endif

	Schannel = (ioutmain == 1) ? "main" : "phrase_waterbubbler"
	bus_mix(Schannel, aL*(1-ipan), aR*ipan)
endin


instr phrase_waterbubbler1
	ioutmain = p4
	kamp linseg 0, p3*0.1, 1, p3*0.8, 1, p3*0.1, 0
	iamp = random(0.25, 0.5)
	kamp *= iamp
	kfreq = abs:k(oscil:k(30, 0.01)) + 10
	kmetro metro kfreq
	if (kmetro == 1) then
		schedulek("_phrase_waterbubbler1_item", random:k(0, 0.2), 1, random:k(0.8, 1.2), random:k(0.5, 1)*kamp, ioutmain)
	endif
endin


instr note_drop1
	ifileid = arr_random(gisnd_waterdrop)
	ifn = gisounddb[ifileid][0]
	idur = gisounddb[ifileid][2]
	ipitch = random(0.6, 1.3)
	p3 = idur / ipitch
	aL, aR loscil 1, ipitch, ifn, 1
	kamp linseg 1, p3*0.9, 1, p3*0.1, 0
	iamp = random(0.7, 1)
	ipan = random(0, 1)
	aL *= kamp * iamp * ipan
	aR *= kamp * iamp * (1-ipan)
	bus_mix("pvsamp1", aL*random(0, 0.3), aR*random(0, 0.3))
	bus_mix("reverb1", aL*random(0, 0.2), aR*random(0, 0.2))
	bus_mix("master", aL, aR)
endin


instr _phrase_droproll1_item
	ifileid = arr_random(gisnd_waterdrop)
	ifn = gisounddb[ifileid][0]
	idur = gisounddb[ifileid][2]
	ipitch = random(0.1, 1.3)
	p3 = idur / ipitch
	aL, aR loscil 1, ipitch, ifn, 1
	kamp linseg 1, p3*0.9, 1, p3*0.1, 0
	ipan = random(0, 1)
	aL *= kamp * ipan
	aR *= kamp * (1-ipan)
	bus_mix("droproll1_item", aL, aR)
	bus_mix("pvsamp1", aL*random(0, 0.5), aR*random(0, 0.5))
endin

instr phrase_droproll1
	iamp = p4
	ifreq1 = random(0.00001, 20)
	kmetrofreq expseg ifreq1, p3, 19.99 - ifreq1
	klpf linseg random(4000, 22050), p3, random(4000, 22050)
	kamp linseg 0, p3*0.3, 1, p3*0.4, 1, p3*0.3, 0
	kmetro metro kmetrofreq
	if (kmetro == 1) then
		schedulek("_phrase_droproll1_item", random:k(0, 0.2), 1)
	endif

	aL, aR bus_read "droproll1_item"
	aL butterlp aL, klpf
	aR butterlp aR, klpf
	aL *= kamp * 0.7 * iamp
	aR *= kamp * 0.7 * iamp
	bus_mix("reverb1", aL*0.2, aR*0.2)
	bus_mix("master", aL, aR)
endin


instr transition_droplets1
	iriseratio = p4
	kamp expseg 0.00001, p3*iriseratio, 1, p3*(1-iriseratio), 0.00001
	kmetro metro 30
	if (kmetro == 1) then
		schedulek("_phrase_droproll1_item", random:k(0, 0.2), 1)
	endif

	aL, aR bus_read "droproll1_item"
	aL *= kamp * 2.5
	aR *= kamp * 2.5
	bus_mix("reverb1", aL*0.43, aR*0.43)
	bus_mix("master", aL, aR)
endin


instr transition_waterbubbler1
	ioutmain = p4
	iriseratio = p4
	kamp expseg 0.00001, p3*iriseratio, 1, p3*(1-iriseratio), 0.00001
	kfreq = abs:k(oscil:k(30, 0.01)) + 10
	kmetro metro kfreq
	if (kmetro == 1) then
		schedulek("_phrase_waterbubbler1_item", random:k(0, 0.2), 1, random:k(0.8, 1.2), random:k(0.5, 1)*kamp, 1)
	endif
endin


instr phrase_dropstretch1
	ireadpitch = p4
	ido_reson = p5
	ifades = p6
	iresonfreqratio = p7
	ifileid = arr_random(gisnd_waterdrop)
	ifn = gisounddb[ifileid][0]
	idur = gisounddb[ifileid][2]
	istart = random(0, idur*0.2)
	iend = random(idur*0.4, idur*0.8) ; 0.3, 0.4
	atime = abs:a(oscil:a(iend-istart, random(0.001, 0.1), gifnSine, random(0, 1)))
	kenv = abs:k(oscil:k(0.8, random(0.01, 0.1), gifnSine, random(0, 1))) + 0.2

	aL, aR sndwarpst 1, atime, ireadpitch, ifn, istart, 441*random(1, 10), 44*random(1, 10), 8, gifnHalfSine, 1

	if (ifades == 1) then
		kamp linseg 0, p3*0.25, 1, p3*0.5, 1, p3*0.25, 0
	else
		kamp linsegr 1, p3, 1, 2, 0
	endif
	aL *= kamp * kenv
	aR *= kamp * kenv
	
	if (ido_reson == 1) then
		aLr resony aL, table:k(0, gimel_freqs)*2*iresonfreqratio, 2, 16, 10
		aRr resony aR, table:k(1, gimel_freqs)*2*iresonfreqratio, 2, 16, 10 ; *4*
		aL balance butterhp(aLr, 50), aL
		aR balance butterhp(aRr, 50), aR
	endif
	
	aL pareq aL, 1000, 0.4, 0.75
	aR pareq aR, 1000, 0.4, 0.75

	bus_mix("master", aL, aR)
endin


#end
