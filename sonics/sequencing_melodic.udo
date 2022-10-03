#ifndef UDO_MELSEQUENCING
#define UDO_MELSEQUENCING ##

/*
	Melodic pattern sequencer base
	Slim excerpt for Partial Emergence

	This file is part of the SONICS UDO collection by Richard Knight 2021
		License: GPL-2.0-or-later
		http://1bpm.net
*/


#include "sonics/__config__.udo"		; using fftsize for tuning
#include "sonics/chords.udo"			; chord data
#include "sonics/sequencing.udo"		; sequencer base
#include "sonics/wavetables.udo"		; for tuning

; if these are set, then don't launch the manager automatically. sequencing_melodic_persistence will load accordingly
#ifdef MEL_INITPATH
	#define MEL_HASINIT ##
#end
#ifdef MEL_INITDB
	#define MEL_HASINIT ##
#end

;-------------------------internal-globals--------------------------------------------------------------------------

gimel_number init 12									; number of melodic sections available

gimel_state ftgen 0, 0, -4, -7, 0						; state: current section, next section, current_step (gimel_number)
gimel_chords ftgen 0, 0, -gimel_number, -7, 0			; chord indexes from melodic.udo for each section
gimel_notes ftgen 0, 0, -gimel_number, -7, 0			; midi note numbers for each section
gimel_lengths ftgen 0, 0, -gimel_number, -7, 0			; lengths in beats for each section
gimel_action1 ftgen 0, 0, -gimel_number, -7, 0			; follow action 1 for each section
gimel_action2 ftgen 0, 0, -gimel_number, -7, 0			; follow action 2 for each section
gimel_actionthreshold ftgen 0, 0, -gimel_number, -7, 0	; follow action threshold - below 0.5 is action1, above is action2
gimel_active ftgen 0, 0, -gimel_number, -7, 0			; whether each section is active or to be ignored
gimel_importance ftgen 0, 0, -gimel_number, -7, 0		; arbitrary section importance , 0 to 1
gimel_mod1 ftgen 0, 0, -gimel_number, -7, 0				; arbitrary modulation 1, 0 to 1
gimel_mod2 ftgen 0, 0, -gimel_number, -7, 0				; arbitrary modulation 2, 0 to 1
gimel_mod3 ftgen 0, 0, -gimel_number, -7, 0				; arbitrary modulation 3, 0 to 1
gimel_mod4 ftgen 0, 0, -gimel_number, -7, 0				; arbitrary modulation 4, 0 to 1

gimel_future ftgen 0, 0, -8, -7, 0 						; future sections: 8 in the future
gimel_current_notes ftgen 0, 0, -13, -7, 0				; current notes: index 0 is the length
gimel_next_notes ftgen 0, 0, -13, -7, 0					; next notes: index 0 is the length
gimel_temp_random ftgen 0, 0, -gimel_number, -7, 0		; temp storage for pattern randomisation

gkmel_section_change init 0								; section change trigger
gkmel_futures_refresh_trig init 0						; trigger to set if futures are to be recalculated
gkmel_pause init 0										; pause progression changes

; actions: static actions and pattern references filled by _mel_refreshactions
gSmel_actions[] init 1 


; names and references for persistence and introspection: essentially the tables to be saved
gSmel_names[] fillarray "chords", "notes", "lengths", "action1", "action2",\
	"actionthreshold", "active", "importance", "mod1", "mod2", "mod3", "mod4"
gimel_fns[] fillarray gimel_chords, gimel_notes, gimel_lengths, gimel_action1, gimel_action2,\
	gimel_actionthreshold, gimel_active, gimel_importance, gimel_mod1, gimel_mod2, gimel_mod3, gimel_mod4



;-----------------------------opcodes-------------------------------------------------------------------------------

/*
	Refresh the actions list: static actions and pattern references
*/
opcode _mel_refreshactions, 0, 0
	Smel_baseactions[] fillarray "Same", "Next", "Previous", "Random"
	gSmel_actions[] init lenarray(Smel_baseactions) + gimel_number
	index = 0
	while (index < lenarray(gSmel_actions)) do
		if (index < 4) then
			gSmel_actions[index] = Smel_baseactions[index]
		else
			gSmel_actions[index] = sprintf("Section %d", index - 3)
		endif
		index += 1
	od
endop
_mel_refreshactions() ; initialise


/*
	Get a random midi note from the current section chord

	inote mel_randomnote

	inote	random note from current chord
*/
opcode mel_randomnote, i, 0
	ilen = table:i(0, gimel_current_notes)
	index = round(random(1, ilen-1))
	xout table:i(index, gimel_current_notes)
endop


/*
	Get a random midi note from the current section chord

	knote mel_randomnote

	knote	random note from current chord
*/
opcode mel_randomnote, k, 0
	klen = table:k(0, gimel_current_notes)
	kindex = round:k(random:k(1, klen-1))
	xout table:k(kindex, gimel_current_notes)
endop


/*
	Get the current section at k-rate
	
	ksection _mel_currentsectionget

	ksection	current section
*/
opcode _mel_currentsectionget, k, 0
	xout table:k(0, gimel_state)
endop


/*
	Get the next section at k-rate
	
	ksection _mel_nextsectionget

	ksection	next section
*/
opcode _mel_nextsectionget, k, 0
	xout table:k(0, gimel_future)
endop


/*
	Set the current section at k-rate
	
	_mel_currentsectionset ksection

	ksection	current section to set
*/
opcode _mel_currentsectionset, 0, k
	ksection xin
	tablew ksection, 0, gimel_state
endop


/*
	Get the current section at init time
	
	isection _mel_currentsectionget

	usection	current section
*/
opcode _mel_currentsectionget, i, 0
	xout table:i(0, gimel_state)
endop


/*
	Get the length of the current section in seconds

	iseconds mel_length

	iseconds 	length in seconds
*/
opcode mel_length, i, 0
	xout table:i(_mel_currentsectionget:i(), gimel_lengths) * i(gkseq_beattime)
endop


/*
	Get the length of the current section in seconds

	kseconds mel_length

	kseconds 	length in seconds
*/
opcode mel_length, k, 0
	xout table:k(_mel_currentsectionget:k(), gimel_lengths) * gkseq_beattime
endop


/*
	Get the current MIDI note numbers as an array
	inotes[] mel_currentnotes

	inotes[]	the note numbers
*/
opcode mel_currentnotes, i[], 0
	ilen = table:i(0, gimel_current_notes)
	iout[] init ilen
	index = 0
	while (index < ilen) do
		iout[index] = table:i(index+1, gimel_current_notes)
		index += 1
	od
	xout iout
endop


/*
	Call Sinstrument when ktrig is fired, for each note (passed as p4) and the current section length accordingly
	mel_eachnote Sinstrument, ktrig[, klength = mel_length:k()]

	Sinstrument		the instrument name to call
	ktrig			trigger to active call
	klength			duration of instrument to call, defaulting to mel_length:k()
	
*/
opcode mel_eachnote, 0, SkJ
	Sinstrument, ktrig, klength xin
	if (ktrig == 1) then
		kdur = (klength == -1 ) ? mel_length:k() : klength
		kindex = 0
		while (kindex < table:k(0, gimel_current_notes)) do
			schedulek Sinstrument, 0, kdur, table:k(kindex + 1, gimel_current_notes)
			kindex += 1
		od
	endif
endop

/*
	Get the most important entry from futures table
	
	kbestindex, kimportance, kbeats mel_future_mostimportant

	kbestindex		index in gimel_future
	kimportance		the importance measure
	kbeats			number of beats until the event occurs
*/
opcode mel_future_mostimportant, kkk, 0
	kindex = 0
	kimportance = -9999
	kbestindex = 0
	kbeats = table:k(table:k(0, gimel_state), gimel_lengths) ; current duration base
	while (kindex < ftlen(gimel_future)) do
		ksection = table:k(kindex, gimel_future)
		kimportancetemp = table:k(ksection, gimel_importance)
		if (kimportancetemp > kimportance) then
			kimportance = kimportancetemp
			kbestindex = kindex
		endif
		kindex += 1
	od

	kindex = 0
	while (kindex < kbestindex) do
		kbeats += table:k(table:k(kindex, gimel_future), gimel_lengths)
		kindex += 1
	od

	xout kbestindex, kimportance, kbeats ; * gkseq_beattime
endop


/*
	Get the most important entry from futures table
	
	ibestindex, iimportance, ibeats mel_future_mostimportant

	ibestindex		index in gimel_future
	importance		the importance measure
	ibeats			number of beats until the event occurs
*/
opcode mel_future_mostimportant, iii, 0 
	index = 0
	importance = -9999
	ibestindex = 0
	ibeats = table:i(table:i(0, gimel_state), gimel_lengths) ; current duration base
	while (index < ftlen(gimel_future)) do
		isection = table:i(index, gimel_future)
		importancetemp = table:i(isection, gimel_importance)
		if (importancetemp > importance) then
			importance = importancetemp
			ibestindex = index
		endif
		index += 1
	od

	index = 0
	while (index < ibestindex) do
		ibeats += table:i(table:i(index, gimel_future), gimel_lengths)
		index += 1
	od
	xout ibestindex, importance, ibeats ; * i(gkseq_beattime)
endop



/*
	Calculate the next section from a given section
	
	knext _mel_calculatenext kcurrent

	knext		the calculated next section index
	kcurrent	the section index to base the calculation upon
*/
opcode _mel_calculatenext, k, k
	kthissection xin
	knextsection = -1
	
	if (random:k(0, 1) <= table:k(kthissection, gimel_actionthreshold)) then
		knextaction = table:k(kthissection, gimel_action2)
	else
		knextaction = table:k(kthissection, gimel_action1)
	endif


	; if current is not active, go to next ?
	kcurrentactive = table:k(kthissection, gimel_active)
	if (kcurrentactive == 0 && knextaction == 0) then
		knextaction = 1
	endif

	; same
	if (knextaction == 0) then
		knextsection = kthissection

	; next or previous
	elseif (knextaction >= 1 && knextaction <= 3) then ; specified action
		kcount = 0
		kactive = 0
		knextsection = kthissection
		while (kactive == 0 && kcount < gimel_number) do ; loop until active section found or all sections checked

			if (knextaction == 1) then	; next
				if (knextsection + 1 > gimel_number - 1) then
					knextsection = 0
				else
					knextsection += 1
				endif

			elseif (knextaction == 2) then	; previous
				if (knextsection -1 < 0) then
					knextsection = gimel_number - 1
				else
					knextsection -= 1
				endif
			endif

			kactive = table:k(knextsection, gimel_active)
			kcount += 1
		od

	; random
	elseif (knextaction == 3) then
		kindex = 0
		krandmax = 0
		while (kindex < gimel_number) do
			if (table:k(kindex, gimel_active) == 1) then
				tablew kindex, krandmax, gimel_temp_random
				krandmax += 1
			endif
			kindex += 1
		od

		knextsection = table:k(round(random(0, krandmax - 1)), gimel_temp_random)

	; specific section
	elseif (knextaction >= 4) then ; specific active pattern
		if (table:k(knextaction - 4, gimel_active) == 1) then
			knextsection = knextaction - 4
		else
			knextsection = kthissection
		endif
	endif
	xout knextsection
endop


/*
	Set gimel_next_notes from the first entry in the futures table
*/
opcode _mel_setnextnotes, 0, 0
	knext = table:k(0, gimel_future)
	chordmidibyindextof gimel_next_notes, table:k(knext, gimel_chords), table:k(knext, gimel_notes)
endop


/*
	Pop the next future entry from the futures table, move all future entries down one 
		and add a new calculated entry accordingly

	kcurrent _mel_future_pop

	kcurrent	the current section to be used now
*/
opcode _mel_future_pop, k, 0
	imax = ftlen(gimel_future)
	kcurrent = table:k(0, gimel_future)


	kindex = 0
	while (kindex < imax - 1) do
		tablew table:k(kindex + 1, gimel_future), kindex, gimel_future
		kindex += 1
	od

	; write new last entry
	tablew _mel_calculatenext(table:k(kindex, gimel_future)), imax - 1, gimel_future

	_mel_setnextnotes()

	xout kcurrent
endop


/*
	Recalculate the futures table (in the event of parameters being changed at runtime etc)
*/
opcode _mel_futures_refresh, 0, O
	kindexStart xin ; usually 0, can be a start index (ie 1 leaves the first entry in place)
	kindex = kindexStart
	imax = ftlen(gimel_future)
	; TODO do first, etc
	while (kindex < imax) do
		if (kindex == 0) then
			kcurrent = table:k(0, gimel_state) ; 0 ; get current, rather than 0...
		else
			kcurrent = table:k(kindex - 1, gimel_future)
		endif

		tablew _mel_calculatenext(kcurrent), kindex, gimel_future
		kindex += 1
	od

	_mel_setnextnotes()
endop


/*
	Set next section, for host control
	
	p4		section number to set as next
*/
instr mel_setnextsection
	isection = p4
	if (table:i(isection, gimel_active) == 1) then
		tablew isection, 0, gimel_future
		gkmel_futures_refresh_trig = 2
	endif
	turnoff
endin


/*
	Refresh the futures table, for host control
*/
instr mel_futures_refresh
	gkmel_futures_refresh_trig = 1
	turnoff
endin


/*
	Randomise all section parameters
*/
opcode _mel_randomise, 0, 0
	index = 0
	iactives[] init 4 + gimel_lengths
	iactivenum = 4
	while (index < gimel_number) do
		tablew round(random(0, lenarray(gSchords) - 1)), index, gimel_chords
		tablew round(random(4, 8)), index, gimel_lengths
		tablew round(random(48, 70)), index, gimel_notes
		tablew random(0, 1), index, gimel_actionthreshold
		tablew random(0, 1), index, gimel_importance
		tablew random(0, 1), index, gimel_mod1
		tablew random(0, 1), index, gimel_mod2
		tablew random(0, 1), index, gimel_mod3
		tablew random(0, 1), index, gimel_mod4
		

		iactive = round(random(0, 1))
		if (iactive == 1) then
			iactives[iactivenum-1] = iactive
			iactivenum += 1
		endif
		tablew iactive, index, gimel_active
		index += 1
	od

	; set next action to only active sections
	index = 0
	while (index < gimel_number) do
		iaction1 = iactives[round(random(0, iactivenum))]
		iaction2 = iactives[round(random(0, iactivenum))]
		tablew iaction1, index, gimel_action1
		tablew iaction2, index, gimel_action2
		index += 1
	od
endop


/*
	Randomise all section parameters
*/
instr mel_randomise
	_mel_randomise()
	gkmel_futures_refresh_trig = 1
	turnoff
endin


/*
	Initialise the sequencer sections; monitor for gkseq_beat triggers and change sections accordingly
*/
instr _mel_manager
#ifndef MEL_HASINIT
	_mel_randomise()
#end
	
	gkmel_futures_refresh_trig init 1
	
	if (gkmel_futures_refresh_trig != 0) then
		_mel_futures_refresh(gkmel_futures_refresh_trig - 1) ; if gkmel_futures_refresh_trig is 2, then omit first, otherwise recalculate all
		gkmel_futures_refresh_trig = 0

	endif

	kstep init 0
	gkmel_section_change = 0

	
	; do something with gkmel_pause == 0
	if (gkseq_beat == 1) then
		if (kstep == 0) then
			tablecopy gimel_current_notes, gimel_next_notes
			kcurrent = _mel_future_pop:k()
			_mel_currentsectionset(kcurrent)
			gkmel_section_change = 1
		endif
		
		if (kstep < table:k(_mel_currentsectionget:k(), gimel_lengths) - 1) then  ; current step < current length
			kstep += 1
		else
			kstep = 0
		endif

	endif ; end each beat
	

endin

#ifndef MEL_HASINIT
alwayson "_mel_manager"
#end



#end
