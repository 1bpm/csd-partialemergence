#ifndef INC_GLOBALEFFECTS_INSTR
#define INC_GLOBALEFFECTS_INSTR ##
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

	Partial Emergence
		by Richard Knight 2022

	Installation submission for the International Csound Conference 2022

	Global effects

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


/*
	Reverb
*/
instr global_reverb1
	aL, aR bus_read "reverb1"
	aL, aR freeverb aL, aR, 0.8, 0.6
	bus_mix("master", aL, aR)
endin


/*
	Delay 1
*/
instr global_delay1
	aL, aR bus_read "delay1"
	;aL *= abs(oscil(1, 1))
	;aR *= abs(oscil(1, 1))
	kfeedback = abs:k(oscil:k(0.5, 4)) + 0.2

	aLdlr delayr 0.8
	kdeltime = abs(oscil(0.02, 0.04)) + 0.1
	aLdel deltapi kdeltime + 0.002
	delayw aL + (aLdel * kfeedback)
	aRdlr delayr 0.8
	aRdel deltapi kdeltime + 0.001
	delayw aR + (aRdel * kfeedback)
	bus_mix("master", aLdel, aRdel)
endin


/*
	Delay 2
*/
instr global_delay2
	aL, aR bus_read "delay2"
	ifreq1 = 0.25
	kfdbkL = abs(oscil(0.8, 1.63))
	kfdbkR = abs(oscil(0.8, 1.67))

	atimeL = abs(oscil(0.2, ifreq1)) + 0.01
	atimeR = abs(oscil(0.2, ifreq1)) + 0.01

	aLdlr delayr 1
	aLdel deltapi atimeL
	aLdel butterhp aLdel, 130
	delayw aL + (aLdel * kfdbkL)

	aRdlr delayr 1
	aRdel deltapi atimeR
	aRdel butterhp aRdel, 130
	delayw aR + (aRdel * kfdbkR)

	bus_mix("master", aLdel, aRdel)
endin



/*
	Cyclical PVS sampler
*/
instr global_pvsamp1 
	aL, aR bus_read "pvsamp1"
	ir = 512
	ksampling init 1
	ktime = timeinsts()
	ksamplestarttime init 0
	kplaystarttime init 0
	imaxlength = 5
	ksamplelength init random(2, imaxlength)
	kplaylength init random(2, imaxlength)
	krevsend init random(0, 0.4)
	kdotune init (random(0, 1) > 0.8) ? 1 : 0
	kdohpf init round(random(0, 1))
	khpfreq init random(100, 2000)
	kreadrate init random(0.01, 0.3)
	
	if (ksampling == 1) then
		fL1 pvsanal aL, ir, ir/4, ir, 1
		fR1 pvsanal aR, ir, ir/4, ir, 1
	
		ibufL, ktL pvsbuffer fL1, imaxlength
		ibufR, ktR pvsbuffer fR1, imaxlength

		if (ktime - ksamplestarttime >= ksamplelength) then
			ksampling = 0
			kplaylength = random:k(2, imaxlength*0.9)
			kplaystarttime = ktime
			kdohpf = round:k(random:k(0, 1))
			khpfreq = random:k(100, 2000)
			kdotune = (random:k(0, 1) > 0.8) ? 1 : 0
			krevsend = random:k(0, 0.6)
			kreadrate = random:k(0.01, 0.3)
		endif
	endif

	if (ksampling == 0 && ktime - kplaystarttime >= kplaylength) then
		ksampling = 1
		ksamplestarttime = ktime
		ksamplelength = random:k(2, imaxlength)
	endif

	ktime = abs:k(oscil:k(1, kreadrate))
	;ktime = portk(random:k(0, 1), 5)

	iscales[] fillarray 0.25, 0.5, 1, 2, 4
	iscale = iscales[round(random(0, lenarray(iscales) - 1))]

	fL2 pvsbufread ktime*port(kplaylength, 0.1), ibufL
	fR2 pvsbufread ktime*port(kplaylength, 0.1), ibufR
	fL3 pvscale fL2, iscale
	fR3 pvscale fR2, iscale

	aL pvsynth fL3
	aR pvsynth fR3
	
	if (kdotune == 1) then
		aL, aR mel_tune_portamento aL*0.8, aR*0.8, gifnSine, 16, 1024, 4
	endif

	if (kdohpf == 1) then
		aL butterhp aL, khpfreq*random(0.8, 1.2)
		aR butterhp aR, khpfreq*random(0.8, 1.2)
	endif

	bus_mix("reverb1", aL*krevsend, aR*krevsend)
	bus_mix("master", aL, aR)

endin



/*
	Cyclical PVS sampler
*/
instr global_pvsamp1x
#ifdef DEBUG
	prints sprintf("Reloaded %s\n", nstrstr(p1))
#end
	aL, aR bus_read "pvsamp1"
	ir = 2048
	ksampling init 1


	ilength = random(2, max(p3*0.2, 2))
	
	if (ksampling == 1) then
		fL1 pvsanal aL, ir, ir/4, ir, 1
		fR1 pvsanal aR, ir, ir/4, ir, 1
	
		ibufL, ktL pvsbuffer fL1, ilength
		ibufR, ktR pvsbuffer fR1, ilength

		if (timeinsts() >= ilength) then
			ksampling = 0
		endif
	endif


	ktime = abs:k(oscil:k(1, random(0.01, 0.3)))
	;ktime = portk(random:k(0, 1), 5)

	iscales[] fillarray 0.25, 0.5, 1, 2, 4
	iscale = iscales[round(random(0, lenarray(iscales) - 1))]

	fL2 pvsbufread ktime*ilength, ibufL
	fR2 pvsbufread ktime*ilength, ibufR
	fL3 pvscale fL2, iscale
	fR3 pvscale fR2, iscale

	ilengthadj = p3 - ilength
	kamp linseg 0, ilength, 0, ilengthadj*0.1, 1, ilengthadj*0.7, 1, ilengthadj*0.2, 0
	aL pvsynth fL3
	aR pvsynth fR3

	if (random(0, 1) > 0.6) then
		bus_mix("reverb1", aL, aR)
	endif
	
	if (random(0, 1) > 0.7) then
		aL, aR mel_tune_portamento aL*0.8, aR*0.8, gifnSine, 16, 1024, 4
	endif

	if (random(0, 1) > 0.6) then
		ihpfreq random 100, 3000
		aL butterhp aL, ihpfreq*random(0.8, 1.2)
		aR butterhp aR, ihpfreq*random(0.8, 1.2)
	endif

	bus_mix("master", aL*kamp, aR*kamp)

	; reload periodically
	if (lastcycle() == 1) then
		schedulek(p1, 1, random(3, 20))
	endif 
endin

#end
