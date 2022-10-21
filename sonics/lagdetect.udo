#ifndef UDO_LAGDETECT
#define UDO_LAGDETECT ##
/*
	Processing lag detection

	This file is part of the SONICS UDO collection by Richard Knight 2022
		License: GPL-2.0-or-later
		http://1bpm.net
*/

#define LAG_DFLT_TTHRESH #0.05#


/*
	Detect when the CPU cannot keep up with proessing: when the realtime clock differs from Csound's clock by a specified threshold time.
	The trigger klagging is output periodically every iautotimethreshold*2 seconds rather than continuously

	klagging, ktimesincelastlag lagdetect [iautotimethreshold=LAG_DFLT_TTHRESH]

	klagging			trigger indicating lag has been detected in this k-cycle
	ktimesincelastlag	time in seconds sine the last lag detected
	iautotimethreshold	if realtime clock and Csound clock differ more than this number of seconds, lag is assumed
*/
opcode lagdetect, kk, j
	iautotimethreshold xin
	iautotimethreshold = (iautotimethreshold == -1) ? $LAG_DFLT_TTHRESH : iautotimethreshold
	kstartrt init rtclock:i()
	kclockrt rtclock
	kstarts init times:i()
	kclocks times    
	klag = abs:k((kclocks - kstarts) - (kclockrt - kstartrt))

	klagging = 0
	; if time difference is above threshold and last adjustment is double threshold, reduce parameters and reset times
	if (klag > iautotimethreshold && kclockrt - kstartrt > iautotimethreshold * 2) then
		kstartrt = kclockrt
		kstarts = kclocks
		klagging = 1		
	endif
	xout klagging, kclocks - kstarts
endop


/*
	Detect when the CPU cannot keep up with proessing: when the realtime clock differs from Csound's clock by a specified threshold time
	The trigger klagging is output periodically every iautotimethreshold*2 seconds rather than continuously

	klagging lagdetect [iautotimethreshold=LAG_DFLT_TTHRESH]

	klagging	trigger indicating lag has been detected in this k-cycle
	iautotimethreshold	if realtime clock and Csound clock differ more than this number of seconds, lag is assumed
*/
opcode lagdetect, k, j
	iautotimethreshold xin
	klagging, ktimesincelag lagdetect iautotimethreshold
	xout klagging
endop

#end
