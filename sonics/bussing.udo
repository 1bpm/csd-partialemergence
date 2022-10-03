#ifndef UDO_BUSSING
#define UDO_BUSSING ##
/*
	Bus handling
	Slim excerpt for Partial Emergence

	This file is part of the SONICS UDO collection by Richard Knight 2021
		License: GPL-2.0-or-later
		http://1bpm.net
*/

gkmastervolume init 1


/*
	Get the stereo L and R names for a singular bus name
	
	SnameL, SnameR bus_name Sbus

	SnameL		left bus identifier
	SnameR		right bus identifier

	Sbus		bus name
*/
opcode bus_name, SS, S
	Sbus xin
	xout sprintf("%sL", Sbus), sprintf("%sR", Sbus)
endop


/*
	Read from a stereo bus, but do not clear it

	aL, aR bus_tap Sbus

	aL	left channel
	aR	right channel

	Sbus	bus name
*/
opcode bus_tap, aa, S
	Sbus xin
	SbusL, SbusR bus_name Sbus
	aL chnget SbusL
	aR chnget SbusR
	xout aL, aR
endop

/*
	Read from a stereo bus, and then clear the bus
	
	aL, aR bus_read Sbus

	aL	left channel
	aR	right channel

	Sbus	bus name
*/
opcode bus_read, aa, S
	Sbus xin
	SbusL, SbusR bus_name Sbus
	aL chnget SbusL
	aR chnget SbusR
	chnclear SbusL
	chnclear SbusR
	xout aL, aR
endop


/*
	Set to a stereo bus

	bus_set Sbus, aL, aR

	Sbus	bus name
	aL	left channel
	aR	right channel
*/
opcode bus_set, 0, Saa
	Sbus, aL, aR xin
	SbusL, SbusR bus_name Sbus
	chnset aL, SbusL
	chnset aR, SbusR
endop

/*
	Mix to a stereo bus

	bus_mix Sbus, aL, aR

	Sbus	bus name
	aL	left channel
	aR	right channel
*/
opcode bus_mix, 0, Saa
	Sbus, aL, aR xin
	SbusL, SbusR bus_name Sbus
	chnmix aL, SbusL
	chnmix aR, SbusR
endop


/*
	Mix to master bus

	bus_masterout aL, aR

	aL 	left channel
	aR	right channel
*/
opcode bus_masterout, 0, aa
	aL, aR xin
	chnmix aL, "mainL"
	chnmix aR, "mainR"
endop


instr _mainmixer
	aL, aR bus_read "main"
	aL = aL*gkmastervolume
	aR = aR*gkmastervolume
	outs aL, aR
endin
alwayson "_mainmixer"

#end
