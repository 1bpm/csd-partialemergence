#ifndef UDO_SOUNDDB
#define UDO_SOUNDDB ##
/*
	SQL database interface to sound object management.
	Slim excerpt for Partial Emergence

	This file is part of the SONICS UDO collection by Richard Knight 2021
		License: GPL-2.0-or-later
		http://1bpm.net

*/

; if XDB extract has been loaded, don't use database
#ifdef XDB_SET
#include "sonics/soundxdb.udo"
#else

#include "sonics/pgdb.udo"

; set max number of files for global array allocation
imaxindex dbscalar gidb, "SELECT MAX(id)+1 FROM file"
gisounddb[][] init imaxindex, 4


/*
	Load file to gisounddb: to be used internally and passed parameters from database
	
	_sounddb_loadfile ifileid, Spath, ichannels, iduration, irmsnorm, isamplerate

	ifileid			database file ID, corresponds to index of gisounddb
	Spath			path to load sound file from
	ichannels		number of channels
	iduration		sound duration
	irmsnorm		normalisation factor
	isamplerate		sample rate
*/
opcode _sounddb_loadfile, 0, iSiiii
	ifileid, Spath, ichannels, iduration, irmsnorm, isamplerate xin
	isize = iduration * isamplerate * ichannels
	ifn = ftgen(0, 0, isize, 1, strcat("$SOUND_BASE/", Spath), 0, 0, 0)
	gisounddb[ifileid][0] = ifn
	gisounddb[ifileid][1] = ichannels
	gisounddb[ifileid][2] = iduration
	gisounddb[ifileid][3] = irmsnorm
endop


/*
	Get file details for a give file ID

	ifn, ichannels, iduration, irmsnorm sounddb_get ifileid

	ifn			ftable number containing sound
	ichannels	number of channels in file
	iduration	duration of file in seconds
	irmsnorm	RMS normalisation factor
	ifileid		file ID to look up
*/
opcode sounddb_get, iiii, i
	ifileid xin
	xout gisounddb[ifileid][0], gisounddb[ifileid][1], gisounddb[ifileid][2], gisounddb[ifileid][3]
endop


/*
	Load files to gisounddb if not already loaded, to be passed a 2D string array as returned from a database query. Returns the file IDs in an array

	ifileids[] _sounddb_loadobject SqueryResult[][]

	ifileids[]			database file IDs, which also correspond to indexes in gisounddb
	SqueryResult[][]	query result from database with each row containing file ID, path, channels, duration, RMS normalisation factor and samplerate
*/
opcode _sounddb_loadobject, i[], S[][]
	Sres[][] xin
	iarraylength = lenarray(Sres)
	idata[] init iarraylength
	index = 0
	while (index < iarraylength) do
		ifileid strtod Sres[index][0] ; fileid
		idata[index] = ifileid

		if (gisounddb[ifileid][0] == 0) then ; load required
			_sounddb_loadfile ifileid, Sres[index][1], strtod(Sres[index][2]), strtod(Sres[index][3]), strtod(Sres[index][4]), strtod(Sres[index][5])
		endif	
		index += 1
	od
	xout idata
endop


/*
	Load a sound to gisounddb if not already loaded, based on a specified query using f_nearestnote.
	Return the file ID and the result of column 6, which is the ratio to the nearest pitch requested.
	Used internally by the sounddb_mel_nearestnote opcodes which select one row

	ifileid, ipitchratio _sounddb_mel_nearestnote_inner Squery

	ifileid			file ID
	ipitchratio		pitch ratio to note requested
	Squery			query to evaluate
*/
opcode _sounddb_mel_nearestnote_inner, ii, S
	Squery xin
	Sres[][] dbarray gidb, Squery
	ifileid strtod Sres[0][0]

	if (gisounddb[ifileid][0] == 0) then ; load required
		_sounddb_loadfile ifileid, Sres[0][1], strtod(Sres[0][2]), strtod(Sres[0][3]), strtod(Sres[0][4]), strtod(Sres[0][5])
	endif	
	xout ifileid, strtod(Sres[0][6])
endop


; nearest note query base
#define SOUNDDB_NNQUERYBASE #SELECT file_id, path, channels, duration, rmsnormal, samplerate, pitchratio FROM f_nearestnote#


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
	ifileid, ipitchratio _sounddb_mel_nearestnote_inner sprintf("$SOUNDDB_NNQUERYBASE (%f, '%s')", inote, Scollection)
	xout ifileid, ipitchratio
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
	ifileid, ipitchratio _sounddb_mel_nearestnote_inner sprintf("$SOUNDDB_NNQUERYBASE (%f, %d)", inote, icollectionid)
	xout ifileid, ipitchratio
endop


/*
	Get the ID of a filecollection by name

	icollectionid sounddb_getcollectionid Scollection

	icollectionid	collection ID
	Scollection		collection name
*/
opcode sounddb_getcollectionid, i, S
	Scollection xin
	icollectionid = dbscalar(gidb, sprintf("SELECT id FROM filecollection WHERE name = '%s'", Scollection))
	xout icollectionid
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
	Sbase = {{select file_id, path, channels, duration, rmsnormal, samplerate, fc.id
		from svw.analysis_basic_collectionnorm a
		join filecollection fc on fc.id = a.filecollection_id
		where %s
	}}

	if (strindex(Scollection, ",") > 0) then
		Sclause = "(1=2"
		index = 1
		Stemp = Scollection
		while (index > 0) do
			index strindex Stemp, ","
			if (index > 0) then
				Sclause strcat Sclause, sprintf(" OR fc.name='%s'", strsub(Stemp, 0, index))		
				Stemp strsub Stemp, index+1
			else
				Sclause strcat Sclause, sprintf(" OR fc.name='%s'", Stemp)
			endif
		od
		Sclause strcat Sclause, ")"
	else
		Sclause = sprintf("fc.name = '%s'", Scollection)
	endif

	Squery sprintf Sbase, Sclause
prints Squery
prints "\n\n"
	Sres[][] dbarray gidb, Squery
	idata[] _sounddb_loadobject Sres
	icollectionid = strtod(Sres[0][6])
	xout idata, icollectionid
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

; end of XDB_SET
#end

#end
