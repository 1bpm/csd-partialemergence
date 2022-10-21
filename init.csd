<CsoundSynthesizer>
<CsOptions>
-odac
-m0
-d
</CsOptions>
<CsLicence>
Creative Commons Attribution-NonCommercial-ShareAlike (CC BY-NC-SA)
</CsLicence>
<CsShortLicence>
2
</CsShortLicence>
<CsInstruments>
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
	
	Partial Emergence
		by Richard Knight 2022

	Installation submission for the International Csound Conference 2022

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

sr = 44100
ksmps = 128
nchnls = 2
0dbfs  = 2.5
seed 0

; set DEBUG to enable lag detection and linear progression
;#define DEBUG ##

; path to progressions
#define PROGRESSIONPATH #progressions#

; initial progression; macro used by sequencing_melodic_persistence.udo
#define MEL_INITPATH #$PROGRESSIONPATH/progression1.fnmlmel#

; SONICS includes
#include "include/soundexport.xdb"  ; sound database extract
#include "sonics/soundxdb.udo"							
#include "sonics/array_tools.udo"						
#include "sonics/sequencing.udo"
#include "sonics/sequencing_melodic.udo"
#include "sonics/sequencing_melodic_portamento.udo"
#include "sonics/sequencing_melodic_persistence.udo"
#include "sonics/bussing.udo"
#include "sonics/instrument_sineblips.udo"
#ifdef DEBUG
#include "sonics/lagdetect.udo"
#endif

; installation specific includes
#include "include/effects_global.inc"
#include "include/instruments_water.inc"
#include "include/instruments_idiophone.inc"
#include "include/instruments_hybrid.inc"
#include "include/instruments_synthesis.inc"
#include "include/sequence_sections.inc"


/*
	Sections:
		Array index of dimension 1 corresponds to "sequencer_s%d" instrument, where %d is the index
		
		Array index of dimension 2:
			0	duration minimum
			1	duration maximum
			2	follow section A
			3 	follow section A/B chance ratio (0 = always A, 1 = always B)
			4	action section 2
*/
gisections[][] init 18, 5

#ifdef DEBUG  
gisections fillarray\           ;       test linear progression
	60, 90,  1, 0.3, 1 ,\		; 0		idiophone single notes
	60, 90,  2, 0.3, 2 ,\		; 1		idiophone chords, alternate mel sections with stretch chords
	60, 90,  3, 0.5, 3 ,\		; 2		bass, idiophone single notes
	60, 90,  4, 0.2, 4 ,\		; 3		bass, idiophone chords
	60, 90,  5, 0.3, 5 ,\		; 4		resonated drop stretch and idiophone notes/stretch
	60, 90,  6, 0.3, 6 ,\		; 5		resonated drop stretch
	60, 90,  7, 0.5, 7 ,\		; 6		tuned drops, stretch chords
	60, 90,  8, 0.7, 8 ,\		; 7		tuned drops, stretch chords more prominent
	60, 90,  9, 0.7, 9 ,\		; 8		drop stretch
	60, 90, 10, 0.5, 10,\		; 9		low portamento chords
	60, 90, 11, 0.5, 11,\		; 10	glitch chord, sines, drops
	60, 90, 12, 0.5, 12,\		; 11	water drops, low minimal chords, resonated drops, stretch water
	60, 90, 13, 0.5, 13,\		; 12	minimal, resonated drops
	60, 90, 14, 0.5, 14,\		; 13	reson drops buildup
	60, 90, 15, 0.5, 15,\ 		; 14	low drop resonated portamento chords
	60, 90, 16, 0.2, 16,\		; 15	water to idiophone 
	60, 90, 17, 0.5, 17,\		; 16	idiophone/drop resonated chords, slower
	30, 60,  0, 0.5, 0			; 17	water paddling hits, resonated drop stretch

#else 
gisections fillarray\          ;     live progression
	43  ,95  ,1  ,0.2  ,2  ,\  ;  0  idiophone single notes
	63  ,125 ,2  ,0.3  ,12 ,\  ;  1  idiophone chords, alternate mel sections with stretch chords
	42  ,110 ,3  ,0.2  ,4  ,\  ;  2  bass, idiophone single notes
	76  ,134 ,4  ,0.2  ,5  ,\  ;  3  bass, idiophone chords
	61  ,92  ,5  ,0.15 ,13 ,\  ;  4  resonated drop stretch and idiophone notes/stretch
	57  ,93  ,11 ,0.2  ,6  ,\  ;  5  resonated drop stretch
	47  ,105 ,5  ,0.8  ,7  ,\  ;  6  tuned drops, stretch chords
	61  ,101 ,14 ,0.7  ,8  ,\  ;  7  tuned drops, stretch chords more prominent
	67  ,105 ,5  ,0.8  ,9  ,\  ;  8  drop stretch
	53  ,113 ,13 ,0.4  ,1  ,\  ;  9  low portamento chords
	65  ,124 ,15 ,0.3  ,0  ,\  ; 10	 glitch chord, sines, drops
	58  ,113 ,8  ,0.5  ,12 ,\  ; 11	 water drops, low minimal chords, resonated drops, stretch water
	81  ,153 ,15 ,0.5  ,14 ,\  ; 12	 minimal, resonated drops
	69  ,112 ,17 ,0.8  ,10 ,\  ; 13	 reson drops buildup
	62  ,103 ,3  ,0.4  ,9  ,\  ; 14	 low drop resonated portamento chords
	54  ,101 ,16 ,0.2  ,5  ,\  ; 15	 water to idiophone 
	71  ,116 ,17 ,0.4  ,4  ,\  ; 16	 idiophone/drop resonated chords, slower
	33  ,66  ,6  ,0.5  ,7	   ; 17	 water paddling hits, resonated drop stretch
#endif

; initial section
ginitsection = 0


; possible melodic progressions which are files in $PROGRESSIONPATH
gSprogressions[] fillarray "progression1.fnmlmel", "progression2.fnmlmel", "progression3.fnmlmel"
gicurrentprogression init 0


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

	Control instruments

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


/*
	Call all performance instruments accordingly
*/
instr boot
	gkseq_tempo init 100
	SbootInstrs[] fillarray "audio_output", "sequencer_main", "global_delay1", "global_delay2", "global_reverb1", "global_pvsamp1"
	index = 0
	while (index < lenarray(SbootInstrs)) do
		schedule(SbootInstrs[index], 0, -1)
		index += 1
	od
	gimel_portamento_beatratio = 4
	turnoff
endin



/*
	Master output mastering/processing
*/
instr audio_output
	; gkmastervolume
	aL, aR bus_read "master"
	iexcite = 1
	aL += (exciter(aL, 3000, 20000, 10, 10)*iexcite)
	aR += (exciter(aR, 3000, 20000, 10, 10)*iexcite)
	bus_masterout(aL, aR)
endin


/*
	Set random melodic progression
*/
instr set_progression
	index = int(random(0, lenarray(gSprogressions)))

	; only set if it differs from current
	if (index != gicurrentprogression) then
		gicurrentprogression = index
		Sprogression = gSprogressions[index]
		prints sprintf("Progression change: %s\n", Sprogression)
		subinstrinit "mel_loadstate_fs", strcat("$PROGRESSIONPATH/", Sprogression)
	endif
	turnoff
endin



/*
	Main section sequencer
*/
instr sequencer_main

	; set up initial instrument at init time
	initduration = random(gisections[ginitsection][0], gisections[ginitsection][1])
	ksection init ginitsection
	ksectiontime init initduration
	schedule(sprintf("sequencer_s%d", ginitsection), 0, initduration)
	prints sprintf("Section %d\n", ginitsection)

	; react to section changes at k-rate
	kabstime timeinsts
	klaststarttime init 0

	; if current section time is up, schedule next
	if (kabstime - klaststarttime >= ksectiontime) then
		
		; determine next section based on follow action threshold
		kchance = random:k(0, 1)
		if (kchance <= gisections[ksection][3]) then
			ksection = gisections[ksection][4]
		else
			ksection = gisections[ksection][2]
		endif

		; get duration between specified min and max
		ksectiontime = random:k(gisections[ksection][0], gisections[ksection][1]) + random:k(0.5, 1)

		; schedule section subsequencer and print status
		schedulek sprintfk("sequencer_s%d", ksection), 0, ksectiontime
		printf "Section %d\n", ksection+random:k(1, 4), ksection

		; set a new chord progression if relevant
		if (random:k(0, 1) >= 0.5) then
			schedulek("set_progression", 0, 1)
		endif

		if (random:k(0, 1) > 0.5) then
			seq_settempo(random:k(20, 100))
		endif

		klaststarttime = kabstime
	endif

#ifdef DEBUG
	; write lag detection report for debugging
	if (lagdetect:k() == 1) then
		fprintks "lagreport.txt", "Lag in section %d at %f\n", ksection, kabstime - klaststarttime
	endif
#endif

endin

</CsInstruments>
<CsScore>
f0 z
i"boot" 0.5 1 ; delay to account for initial melodic progression load
</CsScore>
</CsoundSynthesizer>