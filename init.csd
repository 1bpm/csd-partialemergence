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

	Entry point



TODO:

	Apparent memory leak in pvs opcodes
	8 can be loud
	9 chords are wrong, but sounds ok..
	rmsnormal on portchord, check

	double check mincer read / ft sizes in hybrid and gisounddb[x][2]

* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


sr = 44100
ksmps = 64
nchnls = 2
0dbfs  = 4
seed 0

; exit after specified number of seconds
;#define DEBUG_RUNTIME #30#  

; path to progressions; seems to be problematic with base path depending on where Csound is run from
;#define PROGRESSIONPATH #D:/Documents/Csound/csd-partialemergence/progressions#
#define PROGRESSIONPATH #progressions#

; initial progression; macro used by sequencing_melodic_persistence.udo
#define MEL_INITPATH #$PROGRESSIONPATH/progression3.fnmlmel#

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

; installation specific includes
#include "include/debug.inc"
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
gisections[][] init 20, 5
gisections fillarray\
	60, 90,  1, 0.3, 5 ,\		; 0
	60, 90,  2, 0.3, 6 ,\		; 1		chord music box runs, alternate mel sections with stretch chords
	60, 90,  3, 0.5, 1 ,\		; 2		bass, single note music box runs
	60, 90,  4, 0.2, 0 ,\		; 3		bass, chord music box runs
	60, 90,  5, 0.3, 2 ,\		; 4
	60, 90,  6, 0.3, 8 ,\		; 5		drop stretch, resonated
	60, 90,  7, 0.5, 4 ,\		; 6		tuned drops, stretch chords
	60, 90,  8, 0.7, 0 ,\		; 7		tuned drops, stretch chords more prominent
	60, 90,  0, 0.7, 3 ,\		; 8		drop stretch
	60, 90,  9, 0.5, 9 ,\		; 9		low portamento chords
	60, 90, 10, 0.5, 5 ,\		; 10	glitch chord
	60, 90,  5, 0.5, 4 ,\		; 11	water drops, low minimal chords, resonated drops, stretch water
	60, 90, 13, 0.5, 14,\		; 12	minimal, reson drops
	60, 90, 15, 0.5, 10,\		; 13	reson drops buildup
	60, 90,  9, 0.5,  3,\ 		; 14	low drop reson portamento chords
	60, 90, 12, 0.5, 11,\		; 15	just music box chords
	60, 90, 16, 0.5, 16			; 16	

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
	SbootInstrs[] fillarray "global_delay1", "global_delay2", "global_reverb1", "audio_output", "sequencer_main", "global_pvsamp1"
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
	prints sprintf("Start: section %d\n", ginitsection)

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
		ksectiontime = random:k(gisections[ksection][0], gisections[ksection][1])

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
	
endin

</CsInstruments>
<CsScore>
f0 z
i"boot" 0.5 1 ; slight delay to account for initial melodic progression load
</CsScore>
</CsoundSynthesizer>