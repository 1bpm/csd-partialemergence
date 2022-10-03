#ifndef UDO_FNMI_SINEBLIP
#define UDO_FNMI_SINEBLIP ##
/*
	Stochastic sequenced sine blip instrument
	Slim excerpt for Partial Emergence

	This file is part of the SONICS UDO collection by Richard Knight 2021
		License: GPL-2.0-or-later
		http://1bpm.net
*/

#include "sonics/bussing.udo"
#include "sonics/sequencing_melodic.udo"


/*
	Randomised sine blip playback internal instrument
*/
instr _fnmi_sineblip
	Sbus = p4
	inote = mel_randomnote:i() + 12
	if (random(0, 1) > 0.5) then
		inote += 12
	endif

	if (random(0, 1) > 0.5) then
		inote += 12
	endif

	if (random(0, 1) > 0.5) then
		inote += 12
	endif

	if (random(0, 1) > 0.99) then
		inote += 1
	endif
	ibasefreq = cpsmidinn(inote)
	ifreqL = ibasefreq + random(-5, 5)
	ifreqR = ibasefreq + random(-5, 5)
	iampL = random(0.5, 1)
	iampR = random(0.5, 1)
	aL oscil iampL, ifreqL
	aR oscil iampR, ifreqR

	if (random(0, 1) > 0.5) then
		kamp line 1, p3, 0
	else
		kamp linseg 1, p3*0.9, 1, p3*0.1, 0
	endif
	bus_mix(Sbus, aL*0.6*kamp, aR*0.6*kamp)
endin


/*
	Randomised sine blip playback scheduler
*/
instr fnmi_sineblips
	if (p4 == 0) then
		Sbus = "main"
	else
		Sbus = p4
	endif

	inum = random(1, 8)
	iqtime = i(gkseq_quartertime)
	itimeindex = random(0, 8)
	index = 0
	while (index < inum) do
		itime = seq_swingtime:i(iqtime * itimeindex, itimeindex)
		schedule "_fnmi_sineblip", itime, random(0.05, 0.1), Sbus
		itimeindex += random(1, 4)
		index += 1
	od
	xtratim iqtime * itimeindex
endin

#end
