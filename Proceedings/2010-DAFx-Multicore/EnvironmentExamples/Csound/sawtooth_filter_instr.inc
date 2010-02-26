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
	a1		oscil	amp, icps, giSaw			; oscillator

;ringmodulator
	kRingModRatio	chnget "RingModRatio"
	kRingModAmount	chnget "RingModAmount"
	aModulator	oscil	1, icps*kRingModRatio, giSine		; modulation oscillator
	a1		= (aModulator*a1*kRingModAmount) + \		; ringmodulation and 
			  (a1*(1-kRingModAmount))			; mix with dry signal

; lowpass filter
	kCutoff		chnget	"LowpassCutoff"				; get cutoff frequency from named channel
	kResonance	chnget	"LowpassResonance"			; get resonance amount from named channel
	kDistortion	= 0.6
	a1		lpf18 a1, kCutoff, kResonance, kDistortion	; lowpass filter


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
