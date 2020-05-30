!customredkoopanumber = $00 

print "MAIN", pc
PHB : PHK 
PLB
JSR GenSuperKoopa
PLB 
RTL


DATA_02B1B8:					;$02B1B8	| X offsets (lo) to the sides of the screen for various generators.
	db $E0,$10

DATA_02B1BA:					;$02B1BA	| X offsets (hi) to the sides of the screen for various generators.
	db $FF,$01

GenSuperKoopa:					;-----------| Super Koopa generator MAIN
	LDA $14						;$02B1BC	|\ 
	AND.b #$3F					;$02B1BE	|| Return if not time to spawn a Koopa.
	BNE Return02B206			;$02B1C0	|/
	LDA #!customredkoopanumber
	SEC
	%SpawnSprite()
	BCS Return02B206
	TYX
    JSL $01ACF9
	PHA							;$02B1DA	||
	AND.b #$3F					;$02B1DB	||
	ADC.b #$20					;$02B1DD	||
	ADC $1C						;$02B1DF	|| Set spawn Y at a random position on the screen.
	STA !D8,X					;$02B1E1	||
	LDA $1D						;$02B1E3	||
	ADC.b #$00					;$02B1E5	||
	STA.w !14D4,X				;$02B1E7	|/
	LDA.b #$28					;$02B1EA	|\\ Initial Y speed for the generated Super Koopas.
	STA !AA,X					;$02B1EC	|/
	PLA							;$02B1EE	|
	AND.b #$01					;$02B1EF	|\ 
	TAY							;$02B1F1	||
	LDA $1A						;$02B1F2	||
	CLC							;$02B1F4	||
	ADC.w DATA_02B1B8,Y			;$02B1F5	|| Set spawn X randomly on either side of the screen.
	STA !E4,X					;$02B1F8	||
	LDA $1B						;$02B1FA	||
	ADC.w DATA_02B1BA,Y			;$02B1FC	||
	STA.w !14E0,X				;$02B1FF	|/
	TYA							;$02B202	|\ Set initial direction accordingly.
	STA.w !157C,X				;$02B203	|/
Return02B206:					;			|
	RTS							;$02B206	|