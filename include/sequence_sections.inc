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
#include "include/instruments_musicbox.inc"
#include "include/instruments_synthesis.inc"


instr sequencer_s0
	
	if (gkmel_section_change == 1) then
		schedulek "play_musicbox1", 0, 1, 1	; single note only
	endif
	
endin


instr sequencer_s1

	kdo init 0
	if (gkmel_section_change == 1) then
		schedulek("play_musicboxstretch1", 0, mel_length:k()*random:k(1, 1.5), 0)

		if (kdo == 0) then
			schedulek("play_musicbox1", 0, 1, 0)	; chords
			kdo += 1
		elseif (kdo < 4) then
			kdo += 1
		else
			kdo = 0
			if (random:k(0, 1) > 0.5) then
				;event "i", "fms_playnote", 0, random:k(5, 30), -1
			endif
		endif
	endif

endin


instr sequencer_s2
	
	schedule("fms_playnote", 0, p3, 0)

	if (gkmel_section_change == 1) then
		schedulek("play_musicbox1", 0, 1, 1) ; single note only
		schedulek("play_musicboxstretch1", 0, mel_length:k()*1.3, 0)
	endif
	
	if (lastcycle:k() == 1) then
		turnoff2("fms_playnote", 0, 1)
	endif

endin


instr sequencer_s3
	schedule("fms_playnote", 0, p3, 0)

	if (gkmel_section_change == 1) then
		schedulek("play_musicbox1", 0, 1, 0) ; chords
		schedulek("play_musicboxstretch1", 0, mel_length:k()*0.8, 1)
	endif

	if (lastcycle:k() == 1) then
		turnoff2("fms_playnote", 0, 1)
	endif

endin


instr sequencer_s4
	if (gkmel_section_change == 1) then
		schedulek("play_musicbox1", 0, 1, 1)	; single note only
		schedulek("play_musicboxstretch1", 0, mel_length:k()*1.3, 1)
	endif
endin


instr sequencer_s5
	imaxlen = p3
	itime = 0
	while (itime < imaxlen) do
		idur = random(10, 40)
		schedule("playdropstretch", itime, idur, random(0.5, 1.5), 1)
		if (random(0, 1) > 0.5) then
			schedule("playdropstretch", itime + random(0, 5), idur, random(0.5, 1.5), 1)
		endif
	
		if (random(0, 1) > 0.5) then ; no reson
			schedule("playdropstretch", itime + random(0, 5), idur, random(0.5, 1.5), 0)
		endif

		if (random(0, 1) > 0.5) then
			schedule("waterbubbler", itime, idur, 1)
		endif

		if (random(0, 1) > 0.5) then
			schedule("play_waterpaddling1", itime + random(0, 5), 1)
		endif

		itime += idur * random(0.5, 0.8)
	od
endin


instr sequencer_s6
	;schedule("play_musicboxstretch2", 0, mel_length:k()*0.6, 0)
	if (gkmel_section_change == 1) then
		;turnoff2 "play_musicboxstretch2", 0, 1
		schedulek("play_musicboxstretch2", 0, mel_length:k()*1.3, 0)
		schedulek("waterbubbler", 0, mel_length:k(), 0)
	endif

	awL, awR bus_read "waterbubbler"
	amL, amR bus_read "note_musicboxstretch2"
	
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
	if (gkmel_section_change == 1) then
		schedulek("play_musicboxstretch2", 0, mel_length:k()*1.3, 0)
		schedulek("waterbubbler", 0, mel_length:k(), 1)
	endif

	aL, aR bus_read "note_musicboxstretch2"
	bus_mix("delay1", aL*0.7, aR*0.7)
	bus_mix("main", aL, aR)
endin



instr sequencer_s8
	imaxlen = p3
	itime = 0
	while (itime < imaxlen) do
		idur = random(5, 20)
		idur = (idur + itime > imaxlen) ? imaxlen - itime : idur
		schedule("playdropstretch", itime, idur, random(0.5, 1.5), 1)
		if (random(0, 1) > 0.5) then
			schedule("playdropstretch", itime + random(0, 5), idur, random(0.5, 1.5), 1)
		endif
	
		if (random(0, 1) > 0.5) then ; no reson
			schedule("playdropstretch", itime + random(0, 5), idur, random(0.5, 1.5), 0)
		endif

		if (random(0, 1) > 0.5) then
			schedule("play_waterpaddling1", itime + random(0, 5), 1)
		endif

		itime += idur * random(0.5, 0.8)
	od
endin


instr sequencer_s9
	gimel_portamento_beatratio = 0.2
	imaxlen = p3
	itime = 0
	while (itime < imaxlen) do
		idur = random(5, 20)
		idur = (idur + itime > imaxlen) ? imaxlen - itime : idur
		schedule("play_musicboxstretch3", itime, idur)
		itime += idur
	od
endin

instr sequencer_s10
	gimel_portamento_beatratio = 0.4
	schedule("play_musicboxstretch4", 0, p3)
	schedule("fms_playnote", 0, p3, 0)

	kmetrofreq = abs:k(oscil:k(5, 0.01)) + 0.1
	knotemetro = metro(kmetrofreq)
	if (knotemetro == 1) then
		if (random:k(0, 1) > 0.8) then
			kstart = random:k(0, 0.3)
			schedulek("play_hybrid1", kstart, 1, mel_randomnote:k())
			;schedulek("_note_musicbox1", kstart, 0.5, mel_randomnote:k()+12, random:k(2, 7))
			;schedulek("play_drop1", kstart, 0.5)
		endif
	endif

	kdroprollmetro = metro(0.1)
	if (kdroprollmetro == 1 && random:k(0, 1) > 0.5) then
		schedulek("fnmi_sineblips", random:k(0, 2), random:k(3, 10), "reverb1")
		schedulek("play_droproll1", random:k(0, 2), random:k(3, 10), 1)
	endif

endin


instr sequencer_s11

	; resonated droplets
	kmetrofreq = abs:k(oscil:k(3, 0.01)) + 0.1
	knotemetro = metro(kmetrofreq)
	if (knotemetro == 1) then
		if (random:k(0, 1) > 0.5) then
			schedulek("play_hybrid1", random:k(0, 0.3), 1, mel_randomnote:k())
			if (random:k(0, 1) > 0.5) then
				schedulek("play_hybrid1", random:k(0.3, 1), 1, mel_randomnote:k()+12)
			endif
		endif
	endif

	; water droplets
	kdroprollmetro = metro(0.2)
	if (kdroprollmetro == 1 && random:k(0, 1) > 0.5) then
		schedulek("play_droproll1", random:k(0, 2), random:k(3, 10), 0.2)
	endif

	; subtle notes
	if (gkmel_section_change == 1) then
		schedulek("note_musicboxstretch1", random:k(0, 2), random:k(4, 12), mel_randomnote:k()-12, 0)
		schedulek("note_musicboxstretch1", random:k(0, 2), random:k(4, 12), mel_randomnote:k()-12, 0)
		if (random:k(0, 1) > 0.5) then
			schedulek("note_musicboxstretch1", random:k(0, 2), random:k(4, 12), mel_randomnote:k()-12, 0)
			schedulek("note_musicboxstretch1", random:k(0, 2), random:k(4, 12), mel_randomnote:k()-12, 0)
		endif

		; paddling stretch
		schedulek("play_waterpaddling1", random:k(0, 2), random:k(3, 15))

		; bass note
		if (random:k(0, 1) > 0.4) then
			klen = mel_length:k()
			schedulek("fms_playnote2", random:k(0, 3), random:k(klen, klen*1.5), 0)
		endif
	endif
endin



instr sequencer_s12
	kmetrofreq = abs:k(oscil:k(3, 0.01)) + 0.1
	knotemetro = metro(kmetrofreq)
	if (knotemetro == 1) then
		if (random:k(0, 1) > 0.5) then
			schedulek("play_hybrid1", random:k(0, 0.3), 1, mel_randomnote:k()-12)
		endif
		if (random:k(0, 1) > 0.5) then
			schedulek("play_hybrid1", random:k(0.3, 1), 1, mel_randomnote:k())
		endif
		if (random:k(0, 1) > 0.5) then
			kstart = random:k(0.3, 1)
			schedulek("play_hybrid1", kstart, 1, mel_randomnote:k()+24)
			if (random:k(0, 1) > 0.5) then
				schedulek("play_drop1", kstart, 1)
			endif
		endif
		if (random:k(0, 1) > 0.9) then
			schedulek("playdropstretch", random:k(0, 3), random:k(4, 7), 2, round:k(random:k(0, 1)))
			schedulek("fms_playnote2", random:k(0, 3), random:k(4, 5), 0)
		endif
	endif
	schedule("play_droproll1", 0, 1, 2.4)
endin


instr sequencer_s13
	iplaymusicbox = round(random(0, 1))
	kmetrofreq expseg 0.3, p3, 25
	knotemetro = metro(kmetrofreq)
	if (knotemetro == 1) then
		if (random:k(0, 1) > 0.5) then
			schedulek("play_hybrid1", random:k(0, 0.3), 1, mel_randomnote:k()+12)
			if (iplaymusicbox == 1 && active:k("note_musicboxstretch1") == 0) then
				schedulek("note_musicboxstretch1", random:k(0, 2), random:k(1, 3), mel_randomnote:k()-12, 0)
				if (random:k(0, 1) > 0.5) then
					schedulek("note_musicboxstretch1", random:k(0, 2), random:k(2, 4), mel_randomnote:k()+12, 0)
				endif
			endif
		endif
		if (random:k(0, 1) > 0.5) then
			schedulek("play_hybrid1", random:k(0.3, 1), 1, mel_randomnote:k())
		endif
		if (random:k(0, 1) > 0.5) then
			kstart = random:k(0.3, 1)
			schedulek("play_hybrid1", kstart, 1, mel_randomnote:k()-12)
			if (random:k(0, 1) > 0.5) then
				schedulek("play_drop1", kstart, 1)
			endif
		endif
	endif
	schedule("play_droproll1", 0, 1.3, 2.4)
endin


instr sequencer_s14
	gimel_portamento_beatratio = 0.2
	imaxlen = p3
	iplaydrops = round(random(0, 1))
	itime = 0
	while (itime < imaxlen) do
		idur = random(5, 20)
		idur = (idur + itime > imaxlen) ? imaxlen - itime : idur
		schedule("play_hybridstretch1", itime, idur)
		if (iplaydrops == 1) then
			schedule("play_droproll1", itime, idur, 0.4)
		endif
		itime += idur
	od

	; play one music box glissando just before the next mel section change
	kglissset init 0
	if (kglissset == 0 && gkmel_section_change == 1) then
		schedulek("play_musicbox_gliss1", mel_length:k()-0.5, 1, 3)
		kglissset = 1
	endif
endin


instr sequencer_s15
	if (gkmel_section_change == 1) then
		schedulek("play_musicbox1", 0, 1, 0)	; chords
		schedulek("play_droproll1", 0, mel_length:k(), 0.3)
	endif

endin

#end
