<CsoundSynthesizer>
<CsOptions>
-odac3 -b1024 -B2048 -M1 -+rtmidi=mme 	; realtime audio out
;-oMyFile.wav			; output to audio file 
</CsOptions>
<CsInstruments>

	sr = 44100  
	ksmps = 10
	nchnls = 2	
	0dbfs = 1

	massign 1, 33

;***************************************************
;ftables
;***************************************************

	giSine		ftgen	0, 0, 65536, 10, 1				; sine wave
	giSaw		ftgen	0, 0, 65536, 10, 1, 1/2, 1/3, 1/4, 1/5, 1/6	; saw wave
	giSquare	ftgen	0, 0, 65536, 10, 1, 0, 1/3, 0, 1/5, 0, 1/7	; square wave


;***************************************************
; midi control input instrument
;***************************************************
	instr	20

#include "midi_control_inputs.inc"

	endin
;***************************************************

;***************************************************
; sine wave instrument
;***************************************************
	instr	31
	
; midi interoperatibility, make instrument usable both for midi and score activation
	midinoteonkey p5, p4				; put notenumber into p5, and velocity into p4
	p4		= (p3 < 0 ? (p4*0.5)-64 : p4)	; very simple velocity to dB mapping (velocity=0 give -64dB, velocity=106 give -1dB)

	iamp		= ampdbfs(p4)			; amp in dB relative to 0dbfs
	iNote		= p5				; p5 used as "midi note number"
	icps		= 440 * semitone(iNote-69)	; cps from midi note number
	iPan		= 0.5				; panning (0=left, 1=right)
	iReverbSend	= 0.3				; reverb send amount
	iDelaySend	= 1				; delay send amount

; envelope
	iAttack		= 0.01
	iDecay		= 0.3
	iSustain 	= 0.8
	iRelease 	= 0.1
	amp		madsr	iAttack, iDecay, iSustain, iRelease

; audio generator
	a1		oscil	amp, icps, giSine

; master amp and panning
	aLeft		= a1 * iamp * sqrt(iPan)	; (square root) equal power panning
	aRight		= a1 * iamp * sqrt(1-iPan)	; (square root) equal power panning
	aMono		= a1 * iamp			; mono signal for effects sends

; send dry signal to master 
	chnmix		aLeft, "MasterAudioLeft"
	chnmix		aRight, "MasterAudioRight"

; effect send
	chnmix		aLeft * iReverbSend, "ReverbSendLeft"
	chnmix		aRight * iReverbSend, "ReverbSendRight"
	chnmix		aMono * iDelaySend, "DelaySend"
	
	endin
;***************************************************

;***************************************************
; sawtooth wave instrument with lowpass filter
;***************************************************
	instr	32,33
#include "sawtooth_filter_instr.inc"
	endin
;***************************************************

;***************************************************
; simple delay with feedback
;***************************************************
	instr 98

; audio input
	ain		chnget	"DelaySend"
	inLevel		= 0.25
	ain		= ain * inLevel

; delay effect
	iDelayTime	= 0.5
	iFeedLevel	= 0.5
	iFilterCutoff	= 1500
	aFeedback	init 0
	ain		= ain + aFeedback
	aDelay		delay	ain, iDelayTime
	aFeedback	= aDelay*iFeedLevel

; send signal to master 
	chnmix		aDelay, "MasterAudioLeft"
	chnmix		aDelay, "MasterAudioRight"

; effect send
	iReverbSend	= 0.3			; reverb send from delay effect
	chnmix		aDelay * iReverbSend, "ReverbSendLeft"
	chnmix		aDelay * iReverbSend, "ReverbSendRight"

; clear chn channels used for mixing 
	aClear		= 0
	chnset		aClear, "DelaySend"

	endin
;***************************************************

;***************************************************
; simple reverb
;***************************************************
	instr 99

; audio input
	ainL		chnget	"ReverbSendLeft"
	ainR		chnget	"ReverbSendRight"
	inLevel		= 0.25
	ainL		= ainL * inLevel
	ainR		= ainR * inLevel

; reverb effect
	kfblvl		= 0.85
	kfco		= 7000
	aLeft, aRight 	reverbsc ainL, ainR, kfblvl, kfco

; send signal to master 
	chnmix	aLeft,	"MasterAudioLeft"
	chnmix	aRight,	"MasterAudioRight"

; clear chn channels used for mixing 
	aClear		= 0
	chnset		aClear, "ReverbSendLeft"
	chnset		aClear, "ReverbSendRight"

	endin
;***************************************************

;***************************************************
; recording to file
;***************************************************
	instr 100

; audio input
	a1		chnget	"MasterAudioLeft"
	a2		chnget	"MasterAudioRight"

; write to file
	iFormat = 14 				; 16bit wav, 
						; use iFormat = 16 for 32bit wav, and 
						; iFormat = 18 for 24bit wav, and 
	fout	"demofile.wav", iFormat, a1, a2	; write a stereo audio file

	endin

;***************************************************

;***************************************************
; master audio out
;***************************************************
	instr 101

; audio input
	a1		chnget	"MasterAudioLeft"
	a2		chnget	"MasterAudioRight"

	outch		1, a1, 2, a2

; clear chn channels used for mixing 
	aClear		= 0
	chnset		aClear, "MasterAudioLeft"
	chnset		aClear, "MasterAudioRight"

	endin

;***************************************************

</CsInstruments>
<CsScore>
;{} statement

#define scorelength # 100 #		; macro to set overall score length, used as duration for "always on" instruments

t 0 480
i32	0	0	0	0	; bogus statement, set p2 to zero
#define tema1 #
; 	start	dur	amp	note
i32	+	1	-15	57	;a
i32	+	.	.	64	;e
i32	+	.	.	67	;g
i32	+	.	.	60	;c
i32	+	.	.	62	;d
i32	+	.	.	69	;a
i32	+	.	.	60	;c
i32	+	.	.	62	;d
i32	+	.	.	55	;g
i32	+	.	.	57	;a
i32	+	.	.	60	;c
i32	+	.	.	62	;d
i32	+	.	.	67	;g
i32	+	.	.	69	;a
i32	+	.	.	76	;e
i32	+	.	.	60	;c
i32	+	.	.	62	;d
i32	+	.	.	67	;g
i32	+	.	.	74	;d
i32	+	.	.	79	;g
i32	+	.	.	78	;fiss
i32	+	.	.	74	;d
i32	+	.	.	69	;a
i32	+	.	.	66	;fiss
i32	+	.	.	67	;g
i32	+	.	.	62	;d
i32	+	.	.	64	;e
i32	+	.	.	60	;c
i32	+	.	.	55	;g
#

$tema1
$tema1

i 20  0 $scorelength		; midi control input
i 98  0 $scorelength		; delay effect
i 99  0 $scorelength		; reverb effect
i 100 0 $scorelength		; write to file in realtime session
i 101 0 $scorelength		; master audio out


e

</CsScore>
</CsoundSynthesizer>
