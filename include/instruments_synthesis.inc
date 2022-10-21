#ifndef INC_SYNTHESIS_INSTR
#define INC_SYNTHESIS_INSTR ##
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

	Partial Emergence
		by Richard Knight 2022

	Installation submission for the International Csound Conference 2022

	Synthesis instruments

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


/*
	Bass note 1
*/
instr note_bass1
	index = (p4 == -1) ? random(0, 2) : p4
	kfreq table index, gimel_freqs
	kfreq *= 0.25
	kamp table index, gimel_amps
	kenv linseg 0, p3*0.01, 1, p3*0.99, 1
	kamp *= kenv * 0.19

	aphs1 phasor kfreq/2
	aphs2 phasor kfreq/2
	koda = abs(oscil(random(0, 2), random(0, 1)))
	a1 tablei aphs1, gifnSine, 1, 0, 1

	av1L = abs:a(oscil:a(3, 0.1))
	aL tablei (aphs2+a1)+av1L+koda, gifnSine, 1, 0, 1
	av1R = abs:a(oscil:a(4, 0.05))
	aR tablei (aphs2+a1)+av1R+koda, gifnSine, 1, 0, 1
	kfi linseg 0, p3*0.2, 1, p3*0.8, 1

	ilpfreq = random(100, 1000)
	aL butterlp aL, ilpfreq
	aR butterlp aR, ilpfreq

	if (random(0, 1) > 0.4) then
		kamp *= abs:k(oscil:k(0.9, random(0.01, 0.1))) + 0.1
	endif

	bus_mix("reverb1", aL*kamp*0.7, aR*kamp*0.7)
	bus_mix("master", aL*kamp, aR*kamp)
endin




opcode fmsxosc, a, k
	kfreq xin
	ifn = gifnSine
	kfreqoffset = abs:k(oscil:k(1, 0.001))
	
	aoda = abs:a(oscil:a(random(0.01, 1), random(0.001, 1)))
	aphs1 phasor kfreq
	aphs2 phasor kfreq + kfreqoffset
	a1 tablei aphs1, ifn, 1, 0, 1
	a2 tablei aphs2, ifn, 1, 0, 1
	av = abs:a(oscil:a(0.1, 0.01, gifnSine, random(0, 1)))
	aa1 tablei (aphs1+a1)+av+aoda, gifnSine, 1, 0, 1
	aa2 tablei (aphs2+a2)+av+aoda, gifnSine, 1, 0, 1

	adelt = abs:a(oscil:a(50, 0.005))
	aa1 vdelay aa1, adelt, 50
	xout (aa1 + aa2)
endop


instr note_bass2
	index = p4 + 1
	ifreq = cpsmidinn(tab_i(index, gimel_current_notes))

	ifreq *= 0.125

	
	if (random(0, 1) < 0.5) then
		ifreq *= 0.5
	endif

	aL fmsxosc ifreq
	aR fmsxosc ifreq
	
	kamp = abs:k(oscil:k(1, random(0.005, 0.01), gifnSine, random(0, 0.5)))
	klpf = abs:k(oscil:k(6000, random(0.009, 0.05), gifnSine, 0.2)) + 100

	aL = butterlp(aL*kamp, klpf)
	aR = butterlp(aR*kamp, klpf)
	
	aL pareq aL, 100, 0.1, 0.7
	aR pareq aR, 100, 0.1, 0.7

	kenv linseg 0, p3*0.1, 1, p3*0.9, 0
	
	if (random(0, 1) > 0.4) then
		kenv *= abs:k(oscil:k(0.9, random(0.01, 0.1))) + 0.1
	endif

	aL *= 0.19 * kenv
	aR *= 0.19 * kenv
	
	bus_mix("master", aL, aR)
endin


#end
