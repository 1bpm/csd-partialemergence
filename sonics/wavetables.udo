#ifndef UDO_WAVETABLES
#define UDO_WAVETABLES ##

/*
	Standard regular wave function tables
	Slim excerpt for Partial Emergence

	This file is part of the SONICS UDO collection by Richard Knight 2021
		License: GPL-2.0-or-later
		http://1bpm.net
*/

ipoints = 16384
gifnSine ftgen 0, 0, ipoints, 10, 1
gifnSquare ftgen 0, 0, ipoints, 10, 1, 0 , .33, 0, .2 , 0, .14, 0 , .11, 0, .09 
gifnSaw ftgen 0, 0, ipoints, 10, 0, .2, 0, .4, 0, .6, 0, .8, 0, 1, 0, .8, 0, .6, 0, .4, 0, .2
gifnPulse ftgen 0, 0, ipoints, 10, 1, 1, 1, 1, 0.7, 0.5, 0.3, 0.1
gifnCosine ftgen 0, 0, ipoints, 9, 1, 1, 90
gifnHalfSine ftgen 0, 0, 1024, 9, 0.5, 1, 0
gifnSigmoid ftgen 0, 0, 257, 9, .5, 1, 270

giwavetables[] fillarray gifnSine, gifnSquare, gifnSaw, gifnPulse, gifnCosine, gifnHalfSine, gifnSigmoid
gSwavetables[] fillarray "Sine", "Square", "Saw", "Pulse", "Cosine", "Half sine", "Sigmoid"

opcode wavetable_random, i, 0
	xout giwavetables[int(random(0, lenarray(giwavetables)-1))]
endop

#end

