CODE_04FB0A:					;| Used as a generic overworld sprite GFX routine. $00 = xpos, $02 = ypos, A = tile/props, carry = size.
	STA.w $0242|!addr,Y				;|\ 
	XBA							;|| Store tile number and YXPPCCCT.
	STA.w $0243|!addr,Y				;|/
	LDA $01						;|\ Return if horizontally offscreen.
	BNE Return04FB36			;|/
	LDA $00						;|\ Store X position.
	STA.w $0240|!addr,Y				;|/
	LDA $03						;|\ Return if vertically offscreen.
	BNE Return04FB36			;|/
	PHP							;|
	LDA $02						;|\ Store Y position.
	STA.w $0241|!addr,Y				;|/
	TYA							;|\ 
	LSR							;||
	LSR							;||
	PLP							;||
	PHY							;|| Store tile size.
	TAY							;||
	ROL							;||
	ASL							;||
	AND.b #$03					;||
	STA.w $0430|!addr,Y				;|/
	PLY							;|
	DEY							;|
	DEY							;|
	DEY							;|
	DEY							;|
Return04FB36:					;|
	RTL							;|
