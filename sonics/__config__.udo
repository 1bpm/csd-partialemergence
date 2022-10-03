#ifndef UDO_CONFIG
#define UDO_CONFIG ##
/*
	SONICS config
	Slim excerpt for Partial Emergence

	This file is part of the SONICS UDO collection by Richard Knight 2021
		License: GPL-2.0-or-later
		http://1bpm.net
*/


; database: allow macro overrides from command line or pre-include etc
#ifndef PGDB_HOST
#define PGDB_HOST #192.168.1.69#
#endif

#ifndef PGDB_NAME
#define PGDB_NAME #partialemergence#
#endif

#ifndef PGDB_USER
#define PGDB_USER #partialemergence#
#endif

#ifndef PGDB_PASSWORD
#define PGDB_PASSWORD #dj939jfh9sh948nd#
#endif


; FFT defaults
giFFTsize = 512
giFFTwinFactor = 4

#end
