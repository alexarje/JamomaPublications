<CsoundSynthesizer>
<CsOptions>
;-odac1 -d
-omulticable.wav -d			; output to audio file 
</CsOptions>
<CsInstruments>

	sr = 44100  
	ksmps = 10
	nchnls = 2	
	0dbfs = 1


;***************************************************
;ftables
;***************************************************

	giSaw		ftgen	0, 0, 65536, 10, 1, 1/2, 1/3, 1/4, 1/5, 1/6	; saw wave


;***************************************************
; oscillator
;***************************************************
	instr 1

	; simple oscillator
	iamp		= ampdbfs(p4)
	icps		= p5
	a1		oscil	iamp, icps, giSaw
	
	; use p6 to set the number in the channel name
	Sname		sprintf	"Signal_%i", p6		
			chnset	a1, Sname
	
	endin


;***************************************************
; multichannel filter, event handler
;***************************************************
	instr 2

	iNumC		= p4		; number of channels
	iCF		= p5		; filter cutoff
	ichnNum		= 0		; init the channel number
makeEvent:
	ichnNum		= ichnNum + 1
	event_i	"i", 3, 0, p3, ichnNum, iCF
	if ichnNum < iNumC igoto makeEvent
	endin

;***************************************************
; multichannel filter, audio processing
;***************************************************
	instr 3	
	instance	= p4
	iCF		= p5
	Sname		sprintf	"Signal_%i", instance		
	a1		chnget	Sname
	a1		butterlp a1, iCF
			chnset	a1, Sname
	endin


;***************************************************
; master audio out, event handler
;***************************************************
	instr 91

	iNumC		= p4		; number of channels
	ichnNum		= 0		; init the channel number
makeEvent:
	ichnNum		= ichnNum + 1
	event_i	"i", 99, 0, p3, ichnNum
	if ichnNum < iNumC igoto makeEvent
	endin

;***************************************************
; master audio out, audio processing
;***************************************************
	instr 99

	instance	= p4
	Sname		sprintf	"Signal_%i", instance		
	a1		chnget	Sname

	; send to audio output (hardware or file) on  channel 1 and 2
	outch	1, a1, 2, a1		

	; clear audio channel
	aClear		= 0
			chnset aClear, Sname
	endin


;***************************************************

</CsInstruments>
<CsScore>

; run oscillators, generate a multichannel test signal
; 	start	dur	amp	freq	ch
i 1	0	5	-10	200	1
i 1	0	5	-10	300	2
i 1	0	5	-10	400	3
i 1	0	5	-10	500	4
i 1	0	5	-10	600	5

; run filter
;	start	dur	numC	cutoff
i 2	0	6	5	100

;master audio out
;	start	dur	numC
i 91	0	6	5

e

</CsScore>
</CsoundSynthesizer>
