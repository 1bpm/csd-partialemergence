#ifndef UDO_UNIQUEID
#define UDO_UNIQUEID ##
/*
	Unique ID assignments
	Slim excerpt for Partial Emergence

	This file is part of the SONICS UDO collection by Richard Knight 2021, 2022
		License: GPL-2.0-or-later
		http://1bpm.net
*/


; globals for internal use
giUniqueID = 0
giUniqueFrac = 0


/*
	Get a unique integer ID

	id uniqueid

	id	the ID
*/
opcode uniqueid, i, 0
	id = giUniqueID
	giUniqueID += 1
	xout id
endop


/*
	Get a unique decimal/fractional ID

	id uniquefrac

	id the ID
*/
opcode uniquefrac, i, 0
	id = giUniqueFrac
	giUniqueFrac += 0.0000001 ; smallest for 32bit
	if (giUniqueFrac >= 1) then
		giUniqueFrac = 0
	endif
	xout id
endop


/*
	Get an array of unique fractional instrument numbers given a base instrument number

	instrs[] uniqueinstrnums instrnum, inum
	instrs[] uniqueinstrnums Sinstr, inum

	instrs[]	array of unique fractional numbers for the instrument number instrnum
	Sinstr		the base instrument name
	instrnum	the base instrument number
	inum		how many references to generate
*/
opcode uniqueinstrnums, i[], ii
	instrnum, inum xin
	instrs[] init inum
	index = 0
	while (index < inum) do
		instrs[index] = instrnum + uniquefrac()
		index += 1
	od
	xout instrs
endop

; overload for named instrument
opcode uniqueinstrnums, i[], Si
	Sinstr, inum xin
	instrs[] uniqueinstrnums nstrnum(Sinstr), inum
	xout instrs
endop

#endif
