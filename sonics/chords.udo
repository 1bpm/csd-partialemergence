#ifndef UDO_CHORDS
#define UDO_CHORDS ##
/*
	Chord interval data and harmonic formation opcodes
	Slim excerpt for Partial Emergence
	
	This file is part of the SONICS UDO collection by Richard Knight 2021
		License: GPL-2.0-or-later
		http://1bpm.net
*/


; chord names 
gSchords[] fillarray "Augmented", 
	"Augmented 11th", 
	"Augmented major 7th", 
	"Augmented 7th", 
	"Augmented 6th", 
	"Diminished",
	"Diminished major 7th",
	"Diminished 7th",
	"Dominant",
	"Dominant 11th",
	"Dominant minor 9th",
	"Dominant 9th",
	"Dominant parallel",
	"Dominant 7th",
	"Dominant 7th b5",
	"Dominant 13th",
	"Dream",
	"Elektra",
	"Farben",
	"Harmonic 7th",
	"Augmented 9th",
	"Leadingtone",
	"Lydian",
	"Major",
	"Major 11th",
	"Major 7th",
	"Major 7th sharp 11th",
	"Major 6th",
	"Major 9th",
	"Major 13th",
	"Mediant",
	"Minor",
	"Minor 11th",
	"Minor major 7th",
	"Minor 9th",
	"Minor 7th",
	"Half diminished 7th",
	"Minor 6th",
	"Minor 13th",
	"Mu",
	"Mystic",
	"Neapolitan",
	"Ninth augmented 5th",
	"Ninth b5th",
	"Northern lights",
	"Napoleon hexachord",
	"Petrushka",
	"Power",
	"Psalms",
	"Secondary dominant",
	"Secondary leadingtone",
	"Secondary supertonic",
	"Sevensix",
	"7th b9",
	"7th suspension 4",
	"Sixth 9th",
	"Suspended",
	"Subdominant",
	"Subdominant parallel",
	"Submediant",
	"Subtonic",
	"Supertonic",
	"So what",
	"Thirteenth b9th",
	"Thirteenth b9th b5th",
	"Tonic counter parallel",
	"Tonic",
	"Tonic parallel",
	"Tristan",
	"Viennese trichord 1",
	"Viennese trichord 2"

; octave and note names
gSoctaves[] fillarray "-1", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"
gSnotenames[] fillarray "C", "C#", "D", "D#", "E", "F", "F#", "G", "A", "Asharp", "B"

; chord interval definitions with index in gichordfns corresponding to names in gSchords
gichordfns = ftgen(0, 0, -71, -2, 0)
tabw_i(ftgen(0, 0, -3, -2, 0, 4, 8), 0, gichordfns)
tabw_i(ftgen(0, 0, -6, -2, 0, 4, 7, 10, 2, 6), 1, gichordfns)
tabw_i(ftgen(0, 0, -4, -2, 0, 4, 8, 11), 2, gichordfns)
tabw_i(ftgen(0, 0, -4, -2, 0, 4, 8, 10), 3, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 6, 8), 4, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 3, 6), 5, gichordfns)
tabw_i(ftgen(0, 0, -4, -2, 0, 3, 6, 11), 6, gichordfns)
tabw_i(ftgen(0, 0, -4, -2, 0, 3, 6, 9), 7, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 4, 7), 8, gichordfns)
tabw_i(ftgen(0, 0, -6, -2, 0, 4, 7, 10, 2, 5), 9, gichordfns)
tabw_i(ftgen(0, 0, -5, -2, 0, 4, 7, 10, 1), 10, gichordfns)
tabw_i(ftgen(0, 0, -5, -2, 0, 4, 7, 10, 2), 11, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 3, 7), 12, gichordfns)
tabw_i(ftgen(0, 0, -4, -2, 0, 4, 7, 10), 13, gichordfns)
tabw_i(ftgen(0, 0, -4, -2, 0, 4, 6, 10), 14, gichordfns)
tabw_i(ftgen(0, 0, -7, -2, 0, 4, 7, 10, 2, 5, 9), 15, gichordfns)
tabw_i(ftgen(0, 0, -4, -2, 0, 5, 6, 7), 16, gichordfns)
tabw_i(ftgen(0, 0, -5, -2, 0, 7, 9, 1, 4), 17, gichordfns)
tabw_i(ftgen(0, 0, -5, -2, 0, 8, 11, 4, 9), 18, gichordfns)
tabw_i(ftgen(0, 0, -4, -2, 0, 4, 7, 10), 19, gichordfns)
tabw_i(ftgen(0, 0, -5, -2, 0, 4, 7, 10, 3), 20, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 3, 6), 21, gichordfns)
tabw_i(ftgen(0, 0, -5, -2, 0, 4, 7, 11, 6), 22, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 4, 7), 23, gichordfns)
tabw_i(ftgen(0, 0, -6, -2, 0, 4, 7, 11, 2, 5), 24, gichordfns)
tabw_i(ftgen(0, 0, -4, -2, 0, 4, 7, 11), 25, gichordfns)
tabw_i(ftgen(0, 0, -5, -2, 0, 4, 7, 11, 6), 26, gichordfns)
tabw_i(ftgen(0, 0, -4, -2, 0, 4, 7, 9), 27, gichordfns)
tabw_i(ftgen(0, 0, -5, -2, 0, 4, 7, 11, 2), 28, gichordfns)
tabw_i(ftgen(0, 0, -7, -2, 0, 4, 7, 11, 2, 6, 9), 29, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 3, 7), 30, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 3, 7), 31, gichordfns)
tabw_i(ftgen(0, 0, -6, -2, 0, 3, 7, 10, 2, 5), 32, gichordfns)
tabw_i(ftgen(0, 0, -4, -2, 0, 3, 7, 11), 33, gichordfns)
tabw_i(ftgen(0, 0, -5, -2, 0, 3, 7, 10, 2), 34, gichordfns)
tabw_i(ftgen(0, 0, -4, -2, 0, 3, 7, 10), 35, gichordfns)
tabw_i(ftgen(0, 0, -4, -2, 0, 3, 6, 10), 36, gichordfns)
tabw_i(ftgen(0, 0, -4, -2, 0, 3, 7, 9), 37, gichordfns)
tabw_i(ftgen(0, 0, -7, -2, 0, 3, 7, 10, 2, 5, 9), 38, gichordfns)
tabw_i(ftgen(0, 0, -4, -2, 0, 2, 4, 7), 39, gichordfns)
tabw_i(ftgen(0, 0, -6, -2, 0, 6, 10, 4, 9, 2), 40, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 1, 5, 8), 41, gichordfns)
tabw_i(ftgen(0, 0, -5, -2, 0, 4, 8, 10, 2), 42, gichordfns)
tabw_i(ftgen(0, 0, -5, -2, 0, 4, 6, 10, 2), 43, gichordfns)
tabw_i(ftgen(0, 0, -11, -2, 1, 2, 8, 0, 3, 6, 7, 10, 11, 4, 7), 44, gichordfns)
tabw_i(ftgen(0, 0, -6, -2, 0, 1, 4, 5, 8, 9), 45, gichordfns)
tabw_i(ftgen(0, 0, -6, -2, 0, 1, 4, 6, 7, 10), 46, gichordfns)
tabw_i(ftgen(0, 0, -2, -2, 0, 7), 47, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 3, 7), 48, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 4, 7), 49, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 3, 6), 50, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 3, 7), 51, gichordfns)
tabw_i(ftgen(0, 0, -5, -2, 0, 4, 7, 9, 10), 52, gichordfns)
tabw_i(ftgen(0, 0, -5, -2, 0, 4, 7, 10, 1), 53, gichordfns)
tabw_i(ftgen(0, 0, -4, -2, 0, 5, 7, 10), 54, gichordfns)
tabw_i(ftgen(0, 0, -5, -2, 0, 4, 7, 9, 2), 55, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 5, 7), 56, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 4, 7), 57, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 3, 7), 58, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 3, 7), 59, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 4, 7), 60, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 3, 7), 61, gichordfns)
tabw_i(ftgen(0, 0, -5, -2, 0, 5, 10, 3, 7), 62, gichordfns)
tabw_i(ftgen(0, 0, -6, -2, 0, 4, 7, 10, 1, 9), 63, gichordfns)
tabw_i(ftgen(0, 0, -6, -2, 0, 4, 6, 10, 1, 9), 64, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 3, 7), 65, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 4, 7), 66, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 3, 7), 67, gichordfns)
tabw_i(ftgen(0, 0, -4, -2, 0, 3, 6, 10), 68, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 1, 6), 69, gichordfns)
tabw_i(ftgen(0, 0, -3, -2, 0, 6, 7), 70, gichordfns)



/*
	Get chord intervals array by index
	intervals[] chordintervalsbyindex index

	intervals[]		intervals for the chord obtained from gichordfns
	index			index in gichordfns to retrieve, corresponding to gSchords names
*/
opcode chordintervalsbyindex, i[], i
	index xin
	intervals[] tab2array table:i(index, gichordfns)
	xout intervals
endop


/*
	Get chord intervals array by index
	kintervals[] chordintervalsbyindex kindex

	kintervals[]	intervals for the chord obtained from gichordfns
	kindex			index in gichordfns to retrieve, corresponding to gSchords names
*/
opcode chordintervalsbyindex, k[], k
	kindex xin
	kintervals[] init 99 ; TODO : FIX AROUND THIS??
	copyf2array kintervals, table:k(kindex, gichordfns) 
	;kintervals[] tab2array 
	xout kintervals
endop


/*
	Get index of chord name
	index chordindexbyname Schord

	index		index in gichordfns and gSchords
	Schord		chord name as in gSchords
*/
opcode chordindexbyname, i, S
	Schord xin
	index = 0
	while (index < lenarray(gSchords)) do
		if (strcmp(gSchords[index], Schord) == 0) then
			igoto done
		endif
		index += 1
	od
	index = 0
done:
	xout index
endop



/*
	Get index of chord name
	index chordindexbyname Schord

	kindex		index in gichordfns and gSchords
	Schord		chord name as in gSchords
*/
opcode chordindexbyname, k, S
	Schord xin
	kindex = 0
	while (kindex < lenarray:k(gSchords)) do
		if (strcmpk(gSchords[kindex], Schord) == 0) then
			kgoto done
		endif
		kindex += 1
	od
	kindex = 0
done:
	xout kindex
endop


/*
	Get chord intervals by name: return the array from gichordfns that corresponds to the gSchords entry
	intervals[] chordintervals Schord

	intervals[] 	intervals for the chord obtained from gichordfns
	Schord			chord name as in gSchords
*/
opcode chordintervals, i[], S
	Schord xin
	index  chordindexbyname Schord
	intervals[] chordintervalsbyindex index
	xout intervals
endop


/*
	Get chord intervals by name: return the array from gichordfns that corresponds to the gSchords entry
	kintervals[] chordintervals Schord

	kintervals[] 	intervals for the chord obtained from gichordfns
	Schord			chord name as in gSchords
*/
opcode chordintervals, k[], S
	Schord xin
	kindex  chordindexbyname Schord
	kintervals[] chordintervalsbyindex kindex
	xout kintervals
endop

 


/*
	Get the midi note numbers or hz for a chord named Schord using inote as the root midi note number
	inotes[] chordmidi Schord, inote, [iashz=0]

	inotes[]	midi note numbers or hz
	Schord		chord name as in gSchords
	inote		root midi note number
	iashz		1 returns hz, 0 returns midi note numbers
*/
opcode chordmidi, i[], Sio
	Schord, inote, iashz xin
	intervals[] chordintervals Schord
	index = 0
	while (index < lenarray:i(intervals)) do
		ivalue = intervals[index] + inote
		intervals[index] = (iashz == 1) ? cpsmidinn:i(ivalue) : ivalue
		index += 1
	od
	xout intervals
endop


/*
	Get the midi note numbers or hz for a chord named Schord using knote as the root midi note number
	knotes[] chordmidi Schord, knote, [iashz=0]

	knotes[]	midi note numbers or hz
	Schord		chord name as in gSchords
	knote		root midi note number
	iashz		1 returns hz, 0 returns midi note numbers
*/
opcode chordmidi, k[], Sko
	Schord, knote, iashz xin
	kintervals[] chordintervals Schord
	kindex = 0
	while (kindex < lenarray:k(kintervals)) do
		kvalue = kintervals[kindex] + knote
		kintervals[kindex] = (iashz == 1) ? cpsmidinn:k(kvalue) : kvalue
		kindex += 1
	od
	xout kintervals
endop



/*
	Get the midi note numbers or hz for a chord from gichordfns by index, using inote as the root midi note number
	inotes[] chordmidibyindex index, inote, [iashz=0]

	inotes[]	midi note numbers or hz
	index		chord index as in gichordfns
	inote		root midi note number
	iashz		1 returns hz, 0 returns midi note numbers
*/
opcode chordmidibyindex, i[], iio
	indexc, inote, iashz xin
	intervals[] chordintervalsbyindex indexc
	index = 0
	while (index < lenarray:i(intervals)) do
		ivalue = intervals[index] + inote
		intervals[index] = (iashz == 1) ? cpsmidinn:i(ivalue) : ivalue
		index += 1
	od
	xout intervals
endop



/*
	Get the midi note numbers or hz for a chord from gichordfns by index, using knote as the root midi note number
	knotes[] chordmidibyindex kindex, knote, [iashz=0]

	knotes[]	midi note numbers or hz
	kindex		chord index as in gichordfns
	knote		root midi note number
	iashz		1 returns hz, 0 returns midi note numbers
*/
opcode chordmidibyindex, k[], kko
	kindexc, knote, iashz xin
	kintervals[] chordintervalsbyindex kindexc
	kindex = 0
	while (kindex < lenarray:k(kintervals)) do
		kvalue = kintervals[kindex] + knote
		kintervals[kindex] = (iashz == 1) ? cpsmidinn:k(kvalue) : kvalue
		kindex += 1
	od
	xout kintervals
endop


/*
	Insert midi note numbers or hz for a chord into a table at k-rate, with the first index set as the length, as used by sequencing_melodic.udo

	chordmidibyindextof ifn, kindex, knote, iashz

	ifn			table to set values in
	kindex		chord index as in gichordfns
	knote		root midi note number
	iashz		1 returns hz, 0 sets midi note numbers
	
*/
opcode chordmidibyindextof, 0, ikko
	ifn, kindexc, knote, iashz xin
	kintervalfn = table:k(kindexc, gichordfns)
	klen = tableng:k(kintervalfn)
	tablewkt klen, 0, ifn
	kindex = 0
	while (kindex < klen) do
		tablewkt tablekt:k(kindex, kintervalfn)+knote, kindex+1, ifn
		kindex += 1
	od
endop
	

/*
	Insert midi note numbers or hz for a chord into a table at init time, with the first index set as the length, as used by sequencing_melodic.udo

	chordmidibyindextof ifn, kindex, knote, iashz

	ifn			table to set values in
	index		chord index as in gichordfns
	inote		root midi note number
	iashz		1 returns hz, 0 sets midi note numbers
	
*/
opcode chordmidibyindextof, 0, iiio
	ifn, indexc, inote, iashz xin
	intervalfn = table:i(indexc, gichordfns)
	ilen = tableng:i(intervalfn)
	tablew ilen, 0, ifn
	index = 0
	while (index < ilen) do
		tablew table:i(index, intervalfn)+inote, index+1, ifn
		index += 1
	od
endop


/*
	LEGACY SUPPORT: possibly deprecated
	Get the note frequencies for a chord named Schord using inote as the root midi note number
	inotes[] chordmidicps Schord, inote

	inotes[]	note frequencies in hz
	Schord		chord name as in gSchords
	inote		root midi note number
*/
opcode chordmidicps, i[], Si
	Schord, inote xin
	inotes[] chordmidi Schord, inote, 1
	xout inotes
endop



/*
	LEGACY SUPPORT: possibly deprecated
	Get the note frequencies for a chord from gichordfns by index, using inote as the root midi note number
	inotes[] chordmidicpsbyindex index, inote

	inotes[]	note frequencies in hz
	index		chord index as in gichordfns
	inote		root midi note number
*/
opcode chordmidicpsbyindex, i[], ii
	index, inote xin
	inotes[] chordmidibyindex index, inote, 1
	xout inotes
endop




#end

