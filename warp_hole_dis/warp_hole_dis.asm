print "INIT ",pc

WarpHoleInit:	;this sprite has a great init
RTL

print "MAIN ", pc
WarpHoleWrap:
	PHB							
	PHK							
	PLB							
	JSR WarpHoleMain			
	PLB							
	RTL	
	
WarpHoleMain:
	JSL $01A7DC					;$02EADA	|\ Return if Mario isn't in contact.
	BCC Return02EAF0			;$02EADE	|/
	STZ $7B						;$02EAE0	|\ 
	LDA $E4,X					;$02EAE2	||
	CLC							;$02EAE4	||
	ADC.b #$0A					;$02EAE5	|| Clear his X speed and push him 10 pixels right.
	STA $94						;$02EAE7	||
	LDA.w $14E0,X				;$02EAE9	||
	ADC.b #$00					;$02EAEC	||
	STA $95						;$02EAEE	|/
Return02EAF0:					;			|
	RTS							;$02EAF1	|