#ifndef INC_WATER_INSTR
#define INC_WATER_INSTR ##
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

	Partial Emergence
		by Richard Knight 2022

	Installation submission for the International Csound Conference 2022

	Water instruments

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "sonics/sounddb.udo"
#include "sonics/array_tools.udo"
#include "sonics/sequencing_melodic.udo"
#include "sonics/sequencing_melodic_portamento.udo"
#include "sonics/bussing.udo"
#include "sonics/frequency_tools.udo"

; sound collections
gisnd_waterpaddling[] sounddb_getcollection "Water.Paddling"
gisnd_waterdrop[] sounddb_getcollection "Water.Droplet"


instr play_waterpaddling1
	ifileid = arr_random(gisnd_waterpaddling)
	ifn = gisounddb[ifileid][0]
	idur = gisounddb[ifileid][2]
	p3 = random(4, 8)

	ktime init 0	
	ipitch = random(0.5, 0.9)
	aL, aR mincer a(port(ktime, 1)), 1, ipitch, ifn, 0, 128

	if (random:k(0, 1) > 0.5) then
		ktime = random:k(0, idur)
	endif

	kamp linseg 1, p3*0.8, 1, p3*0.2, 0
	aL *= kamp * 0.7
	aR *= kamp * 0.7

	if (random(0, 1) > 0.8) then
		bus_mix("delay1", aL*0.3, aR*0.3)
	endif

	if (random(0, 1) > 0.8) then
		bus_mix("reverb1", aL, aR)
	endif

	if (random(0, 1) > 0.5) then
		bus_mix("pvsamp1", aL, aR)
	endif

	bus_mix("master", aL, aR)
endin


instr _play_waterbubbler_drop
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
		aLr resony aL, table:k(0, gimel_freqs)*2, 4, 16, 4
		aRr resony aL, table:k(0, gimel_freqs)*2, 4, 16, 1
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

	Schannel = (ioutmain == 1) ? "main" : "waterbubbler"
	bus_mix(Schannel, aL*(1-ipan), aR*ipan)
endin


instr waterbubbler
	ioutmain = p4
	kamp linseg 0, p3*0.1, 1, p3*0.8, 1, p3*0.1, 0
	iamp = random(0.25, 0.5)
	kamp *= iamp
	kfreq = abs:k(oscil:k(30, 0.01)) + 10
	kmetro metro kfreq
	if (kmetro == 1) then
		schedulek("_play_waterbubbler_drop", random:k(0, 0.2), 1, random:k(0.8, 1.2), random:k(0.5, 1)*kamp, ioutmain)
	endif
endin


instr play_drop1
	ifileid = arr_random(gisnd_waterdrop)
	ifn = gisounddb[ifileid][0]
	idur = gisounddb[ifileid][2]
	ipitch = random(0.6, 1.3)
	p3 = idur / ipitch
	aL, aR loscil 1, ipitch, ifn, 1
	kamp linseg 1, p3*0.8, 1, p3*0.2, 0
	aL *= kamp
	aR *= kamp
	bus_mix("pvsamp1", aL*random(0, 0.3), aR*random(0, 0.3))
	bus_mix("reverb1", aL*random(0, 0.2), aR*random(0, 0.2))
	bus_mix("master", aL, aR)
endin


instr _play_droproll1_item
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

instr play_droproll1
	iamp = p4
	ifreq1 = random(0.00001, 20)
	kmetrofreq expseg ifreq1, p3, 19.99 - ifreq1
	klpf linseg random(4000, 22050), p3, random(4000, 22050)
	kamp linseg 0, p3*0.3, 1, p3*0.4, 1, p3*0.3, 0
	kmetro metro kmetrofreq
	if (kmetro == 1) then
		schedulek("_play_droproll1_item", random:k(0, 0.2), 1)
	endif

	aL, aR bus_read "droproll1_item"
	aL butterlp aL, klpf
	aR butterlp aR, klpf
	aL *= kamp * 0.7 * iamp
	aR *= kamp * 0.7 * iamp
	bus_mix("reverb1", aL*0.2, aR*0.2)
	bus_mix("master", aL, aR)
endin


instr playdropstretch
	ipitch = p4
	ido_reson = p5
	ifileid = arr_random(gisnd_waterdrop)
	ifn = gisounddb[ifileid][0]
	idur = gisounddb[ifileid][2]
	istart = random(0, idur*0.2)
	iend = random(idur*0.3, idur*0.5)
	atime = abs(oscil(iend-istart, random(0.001, 0.1), gifnSine, random(0, 1))) ; + istart ; needed???

	aL, aR sndwarpst 1, atime, ipitch, ifn, istart, 441*random(1, 10), 44*random(1, 10), 8, gifnHalfSine, 1
	kamp linseg 0, p3*0.25, 1, p3*0.5, 1, p3*0.25, 0
	aL *= kamp
	aR *= kamp
	
	if (ido_reson == 1) then
		aLr resony aL, table:k(0, gimel_freqs)*2, 4, 16, 10
		aRr resony aL, table:k(0, gimel_freqs)*4, 4, 16, 10
		aL balance aLr, aL
		aR balance aRr, aR
	endif
	
	aL pareq aL, 1000, 0.4, 0.75
	aR pareq aR, 1000, 0.4, 0.75

	bus_mix("master", aL, aR)
endin

/*
instr playclayrummagetretch
	ipitch = p4
	ipitchend = ipitch * random(0.5, 1)
	kpitch line ipitch, p3, ipitchend
	ifileid = arr_random(gisnd_clayrummage)
	ifn = gisounddb[ifileid][0]
	idur = gisounddb[ifileid][2]
	istart = random(0, idur*0.2)
	iend = random(idur*0.3, idur*0.5)
	atime = abs(oscil(iend-istart, random(0.001, 0.1), gifnSine, random(0, 1))) ; + istart ; needed???

	aL, aR sndwarpst 1, atime, kpitch, ifn, istart, 441*random(60, 100), 44*random(6, 10), 4, gifnHalfSine, 1
	kamp linseg 0, p3*0.25, 1, p3*0.5, 1, p3*0.25, 0
	aLx exciter aL, 3000, 20000, 10, 10
	aRx exciter aR, 3000, 20000, 10, 10

	aL pareq aL, 1200, 0.6, 0.6
	aR pareq aR, 1200, 0.6, 0.6

	aL pareq aL, 120, 6, 0.6
	aR pareq aR, 120, 6, 0.6

	aL += aLx
	aR += aRx
	aL, aR mel_tune_portamento aL, aR
	aL *= kamp
	aR *= kamp
	bus_mix("master", aL, aR)
endin
*/

#end
