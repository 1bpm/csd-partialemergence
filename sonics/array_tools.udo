#ifndef UDO_ARRAYTOOLS
#define UDO_ARRAYTOOLS ##
/*
	Array tools
	Slim excerpt for Partial Emergence

	This file is part of the SONICS UDO collection by Richard Knight 2021
		License: GPL-2.0-or-later
		http://1bpm.net
*/


/*
	Get a random value from an array

	ivalue arr_random iarray[]

	ivalue		selected value
	iarray[]	array to evaluate
*/
opcode arr_random, i, i[]
	iarray[] xin
	ivalue = iarray[round(random(0, lenarray(iarray) - 1))]
	xout ivalue
endop

#end
