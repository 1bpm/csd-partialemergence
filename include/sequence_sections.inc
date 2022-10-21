#ifndef INC_SECTION_SEQ
#define INC_SECTION_SEQ ##
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

	Partial Emergence
		by Richard Knight 2022

	Installation submission for the International Csound Conference 2022

	Section subsequencers

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "sonics/bussing.udo"
#include "include/instruments_water.inc"
#include "include/instruments_idiophone.inc"
#include "include/instruments_synthesis.inc"


/*
	Pause the melodic progression for the duration of the calling instrumnet
*/
opcode pause_melprogression, 0, 0
	gkmel_pause = 1
	if (lastcycle() == 1) then
		gkmel_pause = 0
	endif
endop


/*
	Call an instrument for outward transition; p4 is passed as the rise ratio of total duration
*/
opcode transition_out, 0, S
	Sinstrument xin
	iduration = random(4, min(12, p3*0.5))
	iriseratio = random(0.5, 0.9)
	schedule(Sinstrument, p3 - (iduration * iriseratio), iduration, iriseratio)
endop


/*
	Call an instrument for inward transition; p4 is passed as short duration for an almost immediate attack
*/
opcode transition_in, 0, S
	Sinstrument xin
	iduration = random(3, min(10, p3*0.25))
	schedule(Sinstrument, 0, iduration, 0.03)
endop


instr sequencer_s0
	transition_in("transition_idiophone_randtime")
	imaxlen = p3
	itime = 0
	while (itime < imaxlen) do
		idur = random(5, 10)
		idur = (idur + itime > imaxlen) ? imaxlen - itime : idur
		schedule("phrase_idiophone1", itime, idur, 1)
		itime += random(idur*0.6, idur*0.8)
	od
	transition_out("transition_idiophone_stretch1")
endin


instr sequencer_s1
	schedule("phrase_idiophone_stretch1", 0, i(gkseq_beattime) * i(gkmel_section_change_due), 0)
	schedule("phrase_idiophone1", 0, i(gkseq_beattime) * i(gkmel_section_change_due), 1)

	kdo init 0
	if (gkmel_section_change == 1) then
		klen = mel_length:k()
		schedulek("phrase_idiophone_stretch1", 0, klen*random:k(1, 1.5), 0)

		if (kdo == 0) then
			schedulek("phrase_idiophone1", 0, klen*random:k(1, 1.3), 0)	; chords
			kdo = 1
		else
			kdo = 0
		endif
	endif
	transition_out("transition_idiophone_randtime")
endin


instr sequencer_s2
	
	schedule("note_bass1", 0, p3, 0)
	schedule("phrase_idiophone1", 0, i(gkseq_beattime) * i(gkmel_section_change_due), 1)

	if (gkmel_section_change == 1) then
		klen = mel_length:k()
		schedulek("phrase_idiophone1", 0, klen, 1) ; single note only
		schedulek("phrase_idiophone_stretch1", 0, klen*1.3, 0)
	endif
	
	if (lastcycle:k() == 1) then
		turnoff2("note_bass1", 0, 1)
	endif

endin


instr sequencer_s3
	schedule("note_bass1", 0, p3, 0)
	schedule("phrase_idiophone_stretch1", 0, i(gkseq_beattime) * i(gkmel_section_change_due), 1)

	if (gkmel_section_change == 1) then
		klen = mel_length:k()
		schedulek("phrase_idiophone1", 0, klen, 0) ; chords
		schedulek("phrase_idiophone_stretch1", 0, klen*0.8, 1)
	endif

	if (lastcycle:k() == 1) then
		turnoff2("note_bass1", 0, 1)
	endif

endin


instr sequencer_s4
	idiophone_change()
	schedule("phrase_dropstretch1", 0, i(gkseq_beattime) * 2 * i(gkmel_section_change_due), random(0.5, 1.5), 1, 1, 0.5)
	if (gkmel_section_change == 1) then
		klen = mel_length:k()
		schedulek("phrase_idiophone1", 0, klen, 1)	; single note only
		schedulek("phrase_idiophone_stretch1", 0, klen*1.3, 1)
	endif
	transition_out("transition_waterbubbler1")
endin


instr sequencer_s5
	imaxlen = p3
	itime = 0
	while (itime < imaxlen) do
		idur = random(5, 20)
		schedule("phrase_dropstretch1", itime, idur, random(0.5, 1.5), 1, 1, 1)
		if (random(0, 1) > 0.5) then
			schedule("phrase_dropstretch1", itime + random(0, 5), idur, random(0.5, 1.5), 1, 1, 2)
		endif
	
		if (random(0, 1) > 0.5) then ; no reson
			schedule("phrase_dropstretch1", itime + random(0, 5), idur, random(0.5, 1.5), 0, 1, 1)
		endif

		if (random(0, 1) > 0.5) then
			schedule("phrase_waterbubbler1", itime, idur, 1)
		endif

		if (random(0, 1) > 0.5) then
			schedule("play_waterpaddling1", itime + random(0, 5), 1)
		endif

		itime += idur * random(0.5, 0.8)
	od
endin


instr sequencer_s6
	schedule("phrase_dropstretch1", 0, i(gkseq_beattime) * 1.5 * i(gkmel_section_change_due), random(0.5, 1.5), 0, 1, 1)
	
	if (gkmel_section_change == 1) then
		;turnoff2 "phrase_idiophone_stretch2", 0, 1
		schedulek("phrase_idiophone_stretch2", 0, mel_length:k()*1.3, 0)
		schedulek("phrase_waterbubbler1", 0, mel_length:k(), 0)
	endif

	awL, awR bus_read "phrase_waterbubbler"
	amL, amR bus_read "note_idiophonestretch2"
	
	ir = 256
	irm = 2
	fwL pvsanal awL, ir, ir/irm, ir, 1
	fwR pvsanal awR, ir, ir/irm, ir, 1
	fmL pvsanal amL, ir, ir/irm, ir, 1
	fmR pvsanal amR, ir, ir/irm, ir, 1
	fxL pvsmorph fwL, fmL, 0, 1
	fxR pvsmorph fwR, fmR, 0, 1
	aL pvsynth fxL
	aR pvsynth fxR
	kamp linseg 0, p3*0.01, 1, p3*0.98, 1, p3*0.01, 0 ; has click at start
	bus_mix("main", aL*kamp, aR*kamp)
endin


instr sequencer_s7
	idiophone_change()
	schedule("phrase_dropstretch1", 0, i(gkseq_beattime) * 1.5 * i(gkmel_section_change_due), random(0.5, 1.5), 1, 1, 8)
	if (gkmel_section_change == 1) then
		schedulek("phrase_idiophone_stretch2", 0, mel_length:k()*1.3, 0)
		schedulek("phrase_waterbubbler1", 0, mel_length:k(), 1)
	endif

	aL, aR bus_read "note_idiophonestretch2"
	bus_mix("delay1", aL*0.2, aR*0.2)
	bus_mix("main", aL*0.8, aR*0.8)
	transition_out("transition_idiophone_randtime")
endin


instr sequencer_s8
	pause_melprogression()
	imaxlen = p3
	itime = 0
	while (itime < imaxlen) do
		idur = random(p3*0.1, p3*0.3)
		idur = (idur + itime > imaxlen) ? imaxlen - itime : idur
		schedule("phrase_dropstretch1", itime, idur, random(0.5, 1.5), 1, 1, 0.5)
		if (random(0, 1) > 0.5) then
			schedule("phrase_dropstretch1", itime + random(0, 5), idur, random(0.5, 1.5), 1, 1, 2)
		endif
	
		if (random(0, 1) > 0.5) then ; no reson
			schedule("phrase_dropstretch1", itime + random(0, 5), idur, random(0.5, 1.5), 0, 1, 1)
		endif

		if (random(0, 1) > 0.2) then
			schedule("play_waterpaddling1", itime + random(0, 5), random(0.5, 6))
			if (random(0, 1) > 0.6) then
				schedule("play_waterpaddling1", itime + random(0, 5), random(0.5, 6))
			endif
		endif
		itime += idur * random(0.5, 1.2)
	od
	transition_out("transition_idiophone_gliss1")
endin


instr sequencer_s9
	transition_in("transition_idiophone_stretch1")
	idiophone_change()
	gimel_portamento_beatratio = 0.4
	imaxlen = p3
	itime = 0
	while (itime < imaxlen) do
		idur = random(5, 20)
		idur = (idur + itime > imaxlen) ? imaxlen - itime : idur
		schedule("phrase_idiophone_stretch3", itime, idur)
		itime += idur
	od
	transition_out("transition_idiophone_stretch1")
endin


instr sequencer_s10
	transition_in("transition_idiophone_randtime")
	gimel_portamento_beatratio = 0.4
	schedule("phrase_idiophone_stretch4", 0, p3)
	schedule("note_bass1", 0, p3, 0)

	kmetrofreq = abs:k(oscil:k(5, 0.01)) + 0.1
	knotemetro = metro(kmetrofreq)
	if (knotemetro == 1) then
		if (random:k(0, 1) > 0.8) then
			kstart = random:k(0, 0.3)
			schedulek("note_hybrid1", kstart, 1, mel_randomnote:k())
			;schedulek("_note_idiophone1", kstart, 0.1, mel_randomnote:k()+12, random:k(2, 7))
			;schedulek("note_drop1", kstart, 0.5)
		endif
	endif

	kdroprollmetro = metro(0.1)
	if (kdroprollmetro == 1 && random:k(0, 1) > 0.5) then
		schedulek("fnmi_sineblips", random:k(0, 2), random:k(3, 10), "reverb1")
		schedulek("phrase_droproll1", random:k(0, 2), random:k(3, 10), 1)
	endif

endin


instr sequencer_s11
	transition_in("transition_idiophone_gliss1")
	; resonated droplets
	kmetrofreq = abs:k(oscil:k(3, 0.01)) + 0.1
	knotemetro = metro(kmetrofreq)
	if (knotemetro == 1) then
		if (random:k(0, 1) > 0.5) then
			schedulek("note_hybrid1", random:k(0, 0.3), 1, mel_randomnote:k())
			if (random:k(0, 1) > 0.5) then
				schedulek("note_hybrid1", random:k(0.3, 1), 1, mel_randomnote:k()+12)
			endif
		endif
	endif

	; water droplets
	kdroprollmetro = metro(0.2)
	if (kdroprollmetro == 1 && random:k(0, 1) > 0.5) then
		schedulek("phrase_droproll1", random:k(0, 2), random:k(3, 10), 0.2)
	endif

	; subtle notes
	if (gkmel_section_change == 1) then
		schedulek("note_idiophonestretch1", random:k(0, 2), random:k(4, 12), mel_randomnote:k()-12, 0)
		schedulek("note_idiophonestretch1", random:k(0, 2), random:k(4, 12), mel_randomnote:k()-12, 0)
		if (random:k(0, 1) > 0.5) then
			schedulek("note_idiophonestretch1", random:k(0, 2), random:k(4, 12), mel_randomnote:k()-12, 0)
			schedulek("note_idiophonestretch1", random:k(0, 2), random:k(4, 12), mel_randomnote:k()-12, 0)
		endif

		; paddling stretch
		schedulek("play_waterpaddling1", random:k(0, 2), random:k(3, 15))

		; bass note
		if (random:k(0, 1) > 0.4) then
			klen = mel_length:k()
			schedulek("note_bass2", random:k(0, 3), random:k(klen, klen*1.5), 0)
		endif
	endif
endin


instr sequencer_s12
	kmetrofreq = abs:k(oscil:k(3, 0.01)) + 0.1
	knotemetro = metro(kmetrofreq)
	if (knotemetro == 1) then
		if (random:k(0, 1) > 0.5) then
			schedulek("note_hybrid1", random:k(0, 0.3), 1, mel_randomnote:k()-12)
		endif
		if (random:k(0, 1) > 0.5) then
			schedulek("note_hybrid1", random:k(0.3, 1), 1, mel_randomnote:k())
		endif
		if (random:k(0, 1) > 0.5) then
			kstart = random:k(0.3, 1)
			schedulek("note_hybrid1", kstart, 1, mel_randomnote:k()+24)
			if (random:k(0, 1) > 0.5) then
				schedulek("note_drop1", kstart, 1)
			endif
		endif
		if (random:k(0, 1) > 0.9) then
			schedulek("phrase_dropstretch1", random:k(0, 3), random:k(4, 7), 2, round:k(random:k(0, 1)), 1, 2)
			schedulek("note_bass2", random:k(0, 3), random:k(4, 5), 0)
		endif
	endif
	schedule("phrase_droproll1", 0, 1, 2.4)
endin


instr sequencer_s13
	if (random(0, 1) >= 0.5) then
		pause_melprogression()
	endif
	idiophone_change()
	iplayidiophone = round(random(0, 1))
	kmetrofreq expseg 0.3, p3, 20
	knotemetro = metro(kmetrofreq)
	if (knotemetro == 1) then
		if (random:k(0, 1) > 0.5) then
			schedulek("note_hybrid1", random:k(0, 0.3), 1, mel_randomnote:k()+12)
			if (iplayidiophone == 1 && active:k("note_idiophonestretch1") == 0) then
				schedulek("note_idiophonestretch1", random:k(0, 2), random:k(1, 3), mel_randomnote:k()-12, 0)
			endif
		endif
		if (random:k(0, 1) > 0.5) then
			schedulek("note_hybrid1", random:k(0.3, 1), 1, mel_randomnote:k())
		endif
		if (random:k(0, 1) > 0.5) then
			kstart = random:k(0.3, 1)
			schedulek("note_hybrid1", kstart, 1, mel_randomnote:k()-12)
			if (random:k(0, 1) > 0.5) then
				schedulek("note_drop1", kstart, 1)
			endif
		endif
	endif
	schedule("phrase_droproll1", 0, 1.3, 2.4)
endin


instr sequencer_s14
	gimel_portamento_beatratio = 0.2
	imaxlen = p3
	iplaydrops = round(random(0, 1))
	itime = 0
	while (itime < imaxlen) do
		idur = random(5, 20)
		idur = (idur + itime > imaxlen) ? imaxlen - itime : idur
		schedule("phrase_hybridstretch1", itime, idur)
		if (iplaydrops == 1) then
			schedule("phrase_droproll1", itime, idur, 0.4)
		endif
		itime += idur
	od

	; play one music box glissando just before the next mel section change
	kglissset init 0
	if (kglissset == 0 && gkmel_section_change == 1) then
		schedulek("phrase_idiophone_gliss1", mel_length:k()-0.5, 1, 3)
		kglissset = 1
	endif

	; water transition out
	transition_out("transition_droplets1")
endin


instr sequencer_s15
	transition_in("transition_idiophone_gliss1")
	idiophone_change()
	pause_melprogression()

	;schedule("phrase_idiophone1", 0, p3, 0)
	schedule("phrase_hybrid2", 0, p3, 0)
	transition_out("transition_waterbubbler1")
endin


instr sequencer_s16
	idiophone_change()
	imaxlen = p3
	itime = 0
	while (itime < imaxlen) do
		idur = random(5, 20)
		idur = (idur + itime > imaxlen) ? imaxlen - itime : idur
		schedule("phrase_hybrid1", itime, idur)
		itime += idur
	od
	transition_out("transition_idiophone_gliss1")
endin


instr sequencer_s17
	pause_melprogression()
	imaxlen = p3
	itime = 0
	while (itime < imaxlen) do
		schedule("note_idiophone_randtime", itime+random(0, 1), random(2, 5))
		schedule("note_idiophone_randtime", itime+random(0, 4), random(2, 5))
		schedule("play_waterpaddling1", itime+random(0, 1), random(1, 2))
		itime += random(5, 20)
	od

	schedule("phrase_dropstretch1", 0, p3, 1, 1, 1, 1)
	schedule("phrase_dropstretch1", 0, p3, 2, 1, 1, 0.5)
	transition_out("transition_droplets1")
endin



#end
