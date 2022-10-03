#ifndef UDO_FNMI_GCHORD1
#define UDO_FNMI_GCHORD1 ##
/*
	Portamento glitch-out textural chord player
	Slim excerpt for Partial Emergence

	This file is part of the SONICS UDO collection by Richard Knight 2021
		License: GPL-2.0-or-later
		http://1bpm.net
*/
#include "sonics/wavetables.udo"
#include "sonics/sequencing_melodic_portamento.udo"
#include "sonics/sounddb.udo"
#include "sonics/frequency_tools.udo"
#include "sonics/uniqueid.udo"

/*
	sounddb glitchy chord player
	aL, aR fnmi_gchord1 icollectionid, iattacktime, ireleasetime, icompressmode, kchangechance [, ipitchratio=1, ireadtype=0, ireloadtime=10]
	aL, aR fnmi_gchord1 Scollection, iattacktime, ireleasetime, icompressmode, kchangechance [, ipitchratio=1, ireadtype=0, ireloadtime=10]

	aL, aR 			audio output

	icollectionid	sounddb collection ID to use
	Scollection		sounddb collection name to use
	iattacktime		start fade in time
	ireleasetime	fade out time on host instrument note end
	icompressmode	0 = none ; 1 = harshwall ; 2 = normal
	kchangechance	glitchy item change rate chance (1 = every quarter beat)
	ipitchratio		default pitch augmentation ratio
	ireadtype		0 = sndwarp ; 1 = mincer
	ireloadtime		seconds between reloads of subinstruments to ensure variation in source sound
*/

opcode fnmi_gchord1, aa, iiiikpoj
	icollectionid, iattacktime, ireleasetime, icompressmode, kchangechance, ipitchratio, ireadtype, ireloadtime xin
	ilen = p3
	ireloadtime = (ireloadtime == -1) ? 10 : ireloadtime
	instanceid = uniqueid()

	iusedinstruments[] uniqueinstrnums "_fnmi_gchord1_notehold", ftlen(gimel_freqs)

	; set up notehold instruments
	index = 0
	while (index < lenarray(iusedinstruments)) do
		schedule iusedinstruments[index], 0, ilen, index, icollectionid, ireleasetime, instanceid, ipitchratio, ireadtype
		index += 1
	od


	; reload random notehold instrument at periodic intervals (ie to change source sound)
	klastchangetime init 0
	ktime timeinsts
	if (ktime - klastchangetime > ireloadtime) then
		kindex = round:k(random(0, lenarray(iusedinstruments)-1))
		kinstrument = iusedinstruments[kindex]
		turnoff2 kinstrument, 4, 1
		schedulek kinstrument, ireleasetime*0.5, ilen-ktime, kindex, icollectionid, ireleasetime, instanceid, ipitchratio, ireadtype
		klastchangetime = ktime
	endif


	; if host instrument of opcode ends, turn off all notehold instances
	kreleasing init 0
	if (release:k() == 1 && kreleasing == 0) then
		kreleasing = 1
		kindex = 0
		while (kindex < lenarray(iusedinstruments)) do
			turnoff2 iusedinstruments[kindex], 4, 1
			kindex += 1
		od
	endif

	; if at end of host instrument note length, add release time for relevant fade out
	if (lastcycle:k() == 1) then
		xtratim ireleasetime
	endif

	
	; trigger for variations in individual notehold instruments
	idivisions = 4
	as, aps syncphasor -(gkseq_beathz*idivisions), a(gkseq_beat)
	ktrig trigger k(as), 0.1, 0
	chnset ktrig, sprintf("fnmi_gchord1_qtrig%d", instanceid)


	; 'global' change chance for the notehold instruments
	kchangechance = 0.5
	chnset kchangechance, sprintf("fnmi_gchord1_changechance%d", instanceid)

	; feed from the notehold instruments
	aL, aR bus_read sprintf("fnmi_gchord1_out%d", instanceid)
	
	if (icompressmode == 1) then
		acomp noise 0.2, 0.4
		aL balance aL, acomp
		aR balance aL, acomp
	elseif (icompressmode == 2) then
		aL compress aL, aL, -5, 40, 40, 6, 0, 0.1, 0
		aR compress aR, aR, -5, 40, 40, 6, 0, 0.1, 0
		aL *= 30
		aR *= 30
	endif

	aL dcblock aL
	aR dcblock aR

	
	kamp linsegr 0, iattacktime, 1, ilen - iattacktime, 1, ireleasetime, 0

	xout aL*kamp, aR*kamp
endop

; overload for named collection
opcode fnmi_gchord1, aa, Siiikpoj
	Scollection, iattacktime, ireleasetime, icompressmode, kchangechance, ipitchratio, ireadtype, ireloadtime xin
	aL, aR fnmi_gchord1 sounddb_getcollectionid(Scollection), iattacktime, ireleasetime, icompressmode, kchangechance, ipitchratio, ireadtype, ireloadtime
	xout aL, aR
endop



/*
	Used internally by fnmi_gchord1 for sound generation and return via channel
*/
instr _fnmi_gchord1_notehold
	index = p4
	icollectionid = p5
	ireleasetime = p6
	instanceid = p7
	iuserpitchratio = p8
	ireadtype = p9
	kamp table index, gimel_amps

	aL init 0
	aR init 0
	if (kamp > 0) then  ; all processing
		kamp *= 0.32 ;0.05
		kfreq table index, gimel_freqs
		ibasenote random 30, 50
		ifileid, ipitchratio sounddb_mel_nearestnote icollectionid, ibasenote
		ifn = gisounddb[ifileid][0]

		ipitchratio *= ((ireadtype == 0) ? (ftsr(ifn) / sr) : 1) * iuserpitchratio ; sr adjustment for sndwarp required
		ilen = ftlen(ifn) / ftsr(ifn)

		; pitch lfo
		alfo oscil 2.5,  0.15, gifnSine
		kfreq += k(alfo)

		kpitchratio = (kfreq / cpsmidinn(ibasenote)) * ipitchratio

		istart = random(0, 0.1) ;* ilen
		iend = random(istart+0.1, 0.4) ; 0.9

		kreadmode init 0

		if (kreadmode == 0) then
			atime = (abs(oscil(iend-istart, random(0.001, 0.1), gifnSine, random(0, 1)))) * ilen  ; TODO: don't think + istart is required here
		elseif (kreadmode == 1) then
			atime = (istart * ilen) + ((phasor(random(2, 10)) * (ilen * (iend - istart))))
		else
			atime = (istart * ilen) + ((phasor(-random(2, 10)) * (ilen * (iend - istart))))
		endif

		if (ireadtype == 0) then
			aL, aR sndwarpst kamp, atime, interp(kpitchratio), ifn, istart, 441*random(1, 100), 44*random(1, 10), 8, gifnHalfSine, 1
		elseif (ireadtype == 1) then
			aL, aR mincer atime, kamp, kpitchratio, ifn, 0
		endif

		kdo_crush init 0
		kdo_diff init 0
		kdo_delaytuner init 0
		kdo_ringmod init 0
		kdelmult init 8
		kcrushrange init 4
		kringmodmult init 2
		khpfreq init 150
		kpan init random(0, 1)

		if (kdo_crush == 1) then
			kcrush = abs:k(oscil:k(kcrushrange, random(0.01, 0.3))) + kcrushrange
			kcrushamount = abs:k(oscil:k(0.7, random(0.001, 0.2), gifnSaw, random(0, 1)))
			aLbc, aRbc bitcrush aL, aR, kcrush
			aL += aLbc * kcrushamount
			aR += aRbc * kcrushamount
		endif

		if (kdo_ringmod == 1) then
			aL, aR ringmod1 aL, aR, kfreq*kringmodmult ;portk(kfreq*kringmodmult, 0.01)
		endif

		if (kdo_delaytuner == 1) then
			kdelaytuneramount = abs:k(oscil:k(0.5, random(0.001, 0.2), gifnSine, random(0, 1)))
			aLdt, aRdt delaytuner aL, aR, max:k(1, kpitchratio)*kdelmult, 0.9 ; portk(kdelmult, 0.1)
			aL += aLdt * kdelaytuneramount
			aR += aRdt * kdelaytuneramount
		endif

		aL butterhp aL, khpfreq
		aR butterhp aR, khpfreq

		if (kdo_diff == 1) then
			aL diff aL
		endif

		ktrig = chnget:k(sprintf("fnmi_gchord1_qtrig%d", instanceid))
		kchangechance = chnget:k(sprintf("fnmi_gchord1_changechance%d", instanceid))

		if (ktrig == 1 && random:k(0, 1) < kchangechance) then
			if (random:k(0, 1) > 0.9) then
				kreadmode = round:k(random:k(0, 2))
			endif

			if (random:k(0, 1) > 0.9) then
				khpfreq = random:k(250, 2500)
			endif

			if (random:k(0, 1) > 0.9) then
				kdelmult = round:k(random:k(8, 16))
			endif

			if (random:k(0, 1) > 0.9) then
				kcrushrange = round:k(random:k(2, 64))
			endif

			if (random:k(0, 1) > 0.95) then
				kdo_crush = 1 - kdo_crush
			endif

			if (random:k(0, 1) > 0.95) then
				kdo_delaytuner = 1 - kdo_delaytuner
			endif

			if (random:k(0, 1) > 0.95) then
				kdo_ringmod = 1 - kdo_ringmod
			endif

			if (random:k(0, 1) > 0.95) then
				kringmodmult = pow:k(2, round:k(random:k(-1, 2))) ; 3 up to 8
			endif
			
			if (random:k(0, 1) > 0.9) then
				kpan = random:k(0, 1)
			endif

			if (random:k(0, 1) > 0.9) then
				kdo_diff = 1 - kdo_diff
			endif
		endif

		aL *= kpan
		aR *= (1-kpan)
	endif ; if amp > 0

	krelamp linsegr 1, p3, 1, ireleasetime, 0
	bus_mix(sprintf("fnmi_gchord1_out%d", instanceid), aL*krelamp, aR*krelamp)
endin

#end
