#ifndef INC_DEBUG
#define INC_DEBUG ##
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

	Partial Emergence
		by Richard Knight 2022

	Installation submission for the International Csound Conference 2022

	Debug
		If $DEBUG_RUNTIME is set, then exit the performance after that number of seconds
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */


#ifdef DEBUG_RUNTIME
#define DEBUG ##

instr debug_exit
	prints "Debug caused exit\n"
	exitnow
endin
schedule("debug_exit", $DEBUG_RUNTIME, 1)

#end

#end

