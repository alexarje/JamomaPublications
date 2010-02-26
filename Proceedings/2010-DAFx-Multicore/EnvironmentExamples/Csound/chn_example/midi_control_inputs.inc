; midi control input
	kctrl1		ctrl7	1, 1, 0, 1
	kctrl2		ctrl7	1, 2, 0, 1
	kctrl3		ctrl7	1, 3, 0, 1
	kctrl4		ctrl7	1, 4, 0, 1

; set initial values for midi inputs
			initc7	1, 1, 0.5
			initc7	1, 2, 0.5
			initc7	1, 3, 0.5
			initc7	1, 4, 0.5

; filtering of midi controls	
	kctrl1		tonek	kctrl1, 4
	kctrl2		tonek	kctrl2, 4
	kctrl3		tonek	kctrl3, 4
	kctrl4		tonek	kctrl4, 4

; midi control routing and mapping
	kCutoff		= (kctrl1*3000) + 20		; range 20 to 3200
	kResonance	= kctrl2			; range 0 to 1
	kRingModRatio	= kctrl3+1			; range 1 to 2
	kRingModAmount	= kctrl4			; range 0 to 1
	
; send values to channels
	chnset		kCutoff, "LowpassCutoff"
	chnset		kResonance, "LowpassResonance"
	chnset		kRingModRatio, "RingModRatio"
	chnset		kRingModAmount, "RingModAmount"
