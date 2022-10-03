#ifndef UDO_SEQUENCING
#define UDO_SEQUENCING ##
/*
	Sequencing base
	Slim excerpt for Partial Emergence

	This file is part of the SONICS UDO collection by Richard Knight 2021
		License: GPL-2.0-or-later
		http://1bpm.net
*/

gkseq_tempo init 120		; tempo BPM
gkseq_beat init 0			; trigger fired on each beat
gkseq_beattime init 0		; time in seconds of one beat (read only; set by BPM)
gkseq_quartertime init 0	; time in seconds of one quarter beat (read only; set by BPM)
gkseq_beathz init 0			; Hz of one beat (read only; set by BPM)
gkseq_swing init 0.2		; swing amount


/*
	Instrument to control the main beat metronome and beat time globals
*/
instr _seq_manager
	gkseq_beat metro gkseq_tempo / 60
	gkseq_beattime = 60 / gkseq_tempo
	gkseq_quartertime = gkseq_beattime / 4
	gkseq_beathz = (1 / 60) * gkseq_tempo
endin
alwayson "_seq_manager"



/*
	Get the swung time for a given time, if appropriate. If the index given is a second 16th, time will be swung
	
	kresult seq_swingtime ktime, kindex, kswing

	kresult		resulting time
	ktime		the time to consider
	kindex		beat index, beginning with 0
	kswing		the swing amount (0 to 1)
*/
opcode seq_swingtime, k, kkJ
	ktime, kindex, kswing xin
	kswing = (kswing == -1) ? gkseq_swing : kswing
	if ((kindex+1) % 2 == 0) then
		ktime = ktime + (gkseq_quartertime*kswing)
	endif
	xout ktime
endop


/*
	Get the swung time for a given time, if appropriate. If the index given is a second 16th, time will be swung
	
	iresult seq_swingtime itime, iindex, iswing

	iresult		resulting time
	itime		the time to consider
	iindex		beat index, beginning with 0
	iswing		the swing amount (0 to 1)
*/
opcode seq_swingtime, i, iij
	itime, index, iswing xin
	iswing = (iswing == -1) ? i(gkseq_swing) : iswing
	if ((index+1) % 2 == 0) then
		itime = itime + (i(gkseq_quartertime)*iswing)
	endif
	xout itime
endop


/*
	Set the tempo in BPM

	seq_settempo ktempo

	ktempo	the tempo in BPM
*/
opcode seq_settempo, 0, k
	ktempo xin
	gkseq_tempo = ktempo
endop


/*
	Set the tempo in BPM; typically for host control

	p4		the tempo in BPM
*/
instr seq_settempo
	itempo = p4
	gkseq_tempo = itempo
	turnoff
endin



#end
