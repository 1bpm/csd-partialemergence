#ifndef UDO_PGDB
#define UDO_PGDB ##
/*
	PostgreSQL connection and tools
	Slim excerpt for Partial Emergence

	This file is part of the SONICS UDO collection by Richard Knight 2021, 2022
		License: GPL-2.0-or-later
		http://1bpm.net
*/

#include "sonics/__config__.udo"

gidb dbconnect "postgresql", "$PGDB_HOST", "$PGDB_NAME", "$PGDB_USER", "$PGDB_PASSWORD"

#end
