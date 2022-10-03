#ifndef UDO_MELSEQUENCINGPERSIST
#define UDO_MELSEQUENCINGPERSIST ##
/*
	Melodic sequencer persistence: saving/loading from files and database
	Slim excerpt for Partial Emergence

	This file is part of the SONICS UDO collection by Richard Knight 2021, 2022
		License: GPL-2.0-or-later
		http://1bpm.net
*/

#include "sonics/sequencing_melodic.udo"
#include "sonics/array_tools.udo"

/*
	Load state from file

	p4	path to load from
*/
instr mel_loadstate_fs
	Spath = p4
	isize = -1
	iline = 0
	
	ftload Spath, 1,\
		gimel_chords, gimel_notes, 
		gimel_lengths, gimel_action1,\ 
		gimel_action2, gimel_actionthreshold,\
		gimel_active, gimel_importance,\
		gimel_mod1, gimel_mod2,\
		gimel_mod3, gimel_mod4,\
		gimel_state
	
	gkmel_futures_refresh_trig = 1
	turnoff
endin



; if MEL_INITPATH is set, load the specified progression data accordingly
#ifdef MEL_HASINIT
instr _mel_persistence_init
#ifdef MEL_INITPATH
	subinstrinit "mel_loadstate_fs", "$MEL_INITPATH"
#end
	alwayson "_mel_manager"
	turnoff
endin
schedule "_mel_persistence_init", 0, 60

; end MEL_HASINIT
#end 

#end
