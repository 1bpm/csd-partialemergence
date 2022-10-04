#ifndef UDO_SOUNDXDB
#define UDO_SOUNDXDB ##
/*
	SQL database extract interface to sound object management.
	File containing extract definitions must be included before this.
	Slim excerpt for Partial Emergence

	This file is part of the SONICS UDO collection by Richard Knight 2022
		License: GPL-2.0-or-later
		http://1bpm.net

*/

#ifndef XDB_SET
prints "Database extract not defined; cannot continue.\n\n\n"
exitnow
#end


#ifndef XDB_MINNOTE
#define XDB_MINNOTE #0#
#end





/*
	Get the ID of a filecollection by name

	icollectionid sounddb_getcollectionid Scollection

	icollectionid	collection ID
	Scollection		collection name
*/
opcode sounddb_getcollectionid, i, S
	Scollection xin
	index = 0
	while (index < lenarray(gSxdb_collections)) do
		if (strcmp(gSxdb_collections[index], Scollection) == 0) then
			igoto complete
		endif
		index += 1
	od
	index = -1
complete:
	xout index
endop



/*
	Get the file IDs of a filecollection, also loading each file to gisounddb

	ifileids[] sounddb_getcollection Scollection

	ifileids[]		file IDs in the collection, accessible as indexes to f-tables in gisounddb
	Scollection		collection name
*/
opcode sounddb_getcollection, i[], S
	Scollection xin
	idata[], icollectionid sounddb_getcollection Scollection
	xout idata
endop





/*
	Get the collection ID and file IDs of a filecollection, also loading each file to gisounddb

	ifileids[], icollectionid sounddb_getcollection Scollection

	ifileids[]		file IDs in the collection, accessible as indexes to f-tables in gisounddb
	icollectionid	collection ID
	Scollection		collection name
*/
opcode sounddb_getcollection, i[]i, S
	Scollection xin
	itotalsize = 0
	if (strindex(Scollection, ",") > 0) then
		index = 1
		Stemp = Scollection
		while (index > 0) do
			index strindex Stemp, ","
			if (index > 0) then
				icollectionid = sounddb_getcollectionid(strsub(Stemp, 0, index))
				itotalsize += ftlen(gixdb_collectionsfn[icollectionid])	
				Stemp strsub Stemp, index+1
			else
				icollectionid = sounddb_getcollectionid(Stemp)
				itotalsize += ftlen(gixdb_collectionsfn[icollectionid])	
			endif
		od
		idata[] init itotalsize
		iwriteindex = 0
		index = 1
		Stemp = Scollection
		while (index > 0) do
			index strindex Stemp, ","
			if (index > 0) then
				icollectionid = sounddb_getcollectionid(strsub(Stemp, 0, index))
				ifn = gixdb_collectionsfn[icollectionid]
				ireadindex = 0
				while (ireadindex < ftlen(ifn)) do
					idata[iwriteindex] table ireadindex, ifn
					ireadindex += 1
					iwriteindex += 1
				od
				Stemp strsub Stemp, index+1
			else
				icollectionid = sounddb_getcollectionid(Stemp)
				ifn = gixdb_collectionsfn[icollectionid]
				ireadindex = 0
				while (ireadindex < ftlen(ifn)) do
					idata[iwriteindex] table ireadindex, ifn
					ireadindex += 1
					iwriteindex += 1
				od
			endif
		od

	else
		icollectionid = sounddb_getcollectionid(Scollection)
		idata[] tab2array gixdb_collectionsfn[icollectionid]
		igoto complete
	endif

complete:
	xout idata, icollectionid
endop




/*
	Get the nearest note in a filecollection, return the file ID and the pitch ratio adjustment required to the requested note.

	ifileid, ipitchratio sounddb_mel_nearestnote icollectionid, inote

	ifileid			file ID, corresponding to index in gisounddb
	ipitchratio		pitch ratio adjustment required to make the file match the requested note
	icollectionid	collection ID
	inote			MIDI note number
*/
opcode sounddb_mel_nearestnote, ii, ii
	icollectionid, inote xin
	irefindex = ((inote - $XDB_MINNOTE) + tab_i(icollectionid, gixdb_pitchrefoffset)) * 2
	iselected = round(random(tab_i(irefindex, gixdb_pitchreference), tab_i(irefindex+1, gixdb_pitchreference)))
	ifileid tab_i iselected, gixdb_pitchnotes
	ipitchratio tab_i iselected, gixdb_pitchadjust

	xout ifileid, ipitchratio
endop



/*
	Get the nearest note in a filecollection, return the file ID and the pitch ratio adjustment required to the requested note.

	ifileid, ipitchratio sounddb_mel_nearestnote Scollection, inote

	ifileid			file ID, corresponding to index in gisounddb
	ipitchratio		pitch ratio adjustment required to make the file match the requested note
	Scollection		collection name
	inote			MIDI note number
*/
opcode sounddb_mel_nearestnote, ii, Si
	Scollection, inote xin
	icollectionid = sounddb_getcollectionid(Scollection)
	ifileid, ipitchratio sounddb_mel_nearestnote icollectionid, inote
	xout ifileid, ipitchratio
endop



#end
