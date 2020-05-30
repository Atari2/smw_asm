print "INIT", pc
InitSuperKoopa:					;-----------| Swooping Super Koopa INIT
	LDA.b #$28					;$018528	|\\ Initial Y speed of the swooping Super Koopas.
	STA !AA,X					;$01852A	|/
	%SubHorzPos()
	TYA							;$01857F	|
	STA.w !157C,X				;$018580	|
	STZ !151C,x
	RTL							;$018583	|



	; Super Koopa misc RAM:
	; $C2   - Phase pointer for the ground Super Koopa. 0 = running, 1 = jumping, 2 = flying.
	; $151C - Flag to set if the koopa has already spawned a lightning
	; $1534 - Flag to indicate the Super Koopa has a feather (flashing cape).
	; $157C - Horizontal direction the sprite is facing.
	; $1602 - Animation frame. 2/3 = flying, 4/5 = dying
	;		   Ground Koopa only: 0/1 = walking, 6/7 = sprinting, 7/8 = jumping

print "MAIN", pc
SuperKoopaMain:					;-----------| Super Koopa MAIN
	PHB							;$02EB27	|
	PHK							;$02EB28	|
	PLB							;$02EB29	|
	JSR CODE_02EB31				;$02EB2A	|
	PLB							;$02EB2D	|
	RTL							;$02EB2E	|

DATA_02EB2F:					;$02EB2F	| X speeds for the Super Koopas that start in mid-air.
	db $18,$E8

CODE_02EB31:
	JSR CODE_02ECDE				;$02EB31	| Draw GFX.
	LDA.w !14C8,X				;$02EB34	|\ 
	CMP.b #$02					;$02EB37	|| Branch if the Koopa isn't dying.
	BNE CODE_02EB49				;$02EB39	|/
	LDY.b #$04					;$02EB3B	|\ 
CODE_02EB3D:					;			||
	LDA $14						;$02EB3D	||
	AND.b #$04					;$02EB3F	||
	BEQ CODE_02EB44				;$02EB41	|| Handle dying animation (4/5).
	INY							;$02EB43	||
CODE_02EB44:					;			||
	TYA							;$02EB44	||
	STA.w !1602,X				;$02EB45	|/
	RTS							;$02EB48	|

CODE_02EB49:					;```````````| Super Koopa isn't dead.
	LDA $9D						;$02EB49	|\ Return if game frozen.
	BNE Return02EB7C			;$02EB4B	|/
	LDA #$00
    %SubOffScreen()
	JSL $01803A		            ;$02EB50	| Process Mario and sprite interaction.
	JSL $018022		            ;$02EB54	|\ Update X and Y position.
	JSL $01801A		            ;$02EB57	|/
	LDA !151C,x
	BNE +
	%SubHorzPos()
	REP #$20
	LDA $0E
	CMP #$0009
	BCS +
	SEP #$20
	JSR GenSumoLightning
	LDA #$01
	STA !151C,x
	+
	SEP #$20
	LDY.w !157C,X				;$02EB60	|\ 
	LDA.w DATA_02EB2F,Y			;$02EB63	|| Set X speed based on direction.
	STA !B6,X					;$02EB66	|/
	JSR CODE_02EBF8				;$02EB68	| Handle flying animation.
	LDA $13						;$02EB6B	|\ 
	AND.b #$01					;$02EB6D	||
	BNE Return02EB7C			;$02EB6F	|| Return if not done swooping downwards.
	LDA !AA,X					;$02EB71	||
	CMP.b #$F0					;$02EB73	||| Maximum upwards Y speed for the 'swoop'.
	BMI Return02EB7C			;$02EB75	||
	CLC							;$02EB77	||
	ADC.b #$FF					;$02EB78	||| Upwards acceleration of the Super Koopa's 'swoop'.
	STA !AA,X					;$02EB7A	|/
Return02EB7C:					;			|
	RTS							;$02EB7C	|

DATA_02EB89:					;$02EB89	| Max X speeds for the Super Koopa that starts on the ground.
	db $18,$E8

DATA_02EB8B:					;$02EB8B	| X accelerations for the ground Super Koopa prior to taking off.
	db $01,$FF

CODE_02EBF8:					;			|
	LDY.b #$02					;$02EBF8	|\ 
	LDA $13						;$02EBFA	||
	AND.b #$04					;$02EBFC	||
	BEQ CODE_02EC01				;$02EBFE	|| Alternate animation frame (2/3) every four frames.
	INY							;$02EC00	||
CODE_02EC01:					;			||
	TYA							;$02EC01	||
	STA.w $1602,X				;$02EC02	|/
	RTS							;$02EC05	|



DATA_02EC06:					;$02EC06	| X offfsets for each tile of the Super Koopa. The second set is when X flipped (facing left).
	db $08,$08,$10,$00
	db $08,$08,$10,$00
	db $08,$10,$10,$00
	db $08,$10,$10,$00
	db $09,$09,$00,$00
	db $09,$09,$00,$00
	db $08,$10,$00,$00
	db $08,$10,$00,$00
	db $08,$10,$00,$00
	
	db $00,$00,$F8,$00			; X flipped offsets.
	db $00,$00,$F8,$00
	db $00,$F8,$F8,$00
	db $00,$F8,$F8,$00
	db $FF,$FF,$00,$00
	db $FF,$FF,$00,$00
	db $00,$F8,$00,$00
	db $00,$F8,$00,$00
	db $00,$F8,$00,$00

DATA_02EC4E:					;$02EC4E	| Y offsets for each tile of the Super Koopa.
	db $00,$08,$08,$00
	db $00,$08,$08,$00
	db $03,$03,$08,$00
	db $03,$03,$08,$00
	db $FF,$07,$00,$00
	db $FF,$07,$00,$00
	db $FD,$FD,$00,$00
	db $FD,$FD,$00,$00
	db $FD,$FD,$00,$00

SuperKoopaTiles:				;$02EC72	| Tile numbers for each tile of the Super Koopa.
	db $C8,$D8,$D0,$E0						; 0 - Walking A
	db $C9,$D9,$C0,$E2						; 1 = Walking B
	db $E4,$E5,$F2,$E0						; 2 = Flight A
	db $F4,$F5,$F2,$E0						; 3 = Flight B
	db $DA,$CA,$E0,$CF						; 4 = Dying A
	db $DB,$CB,$E0,$CF						; 5 = Dying B
	db $E4,$E5,$E0,$CF						; 6 = Running A
	db $F4,$F5,$E2,$CF						; 7 = Running B / Jumping A
	db $E4,$E5,$E2,$CF						; 8 = Jumping B

DATA_02EC96:					;$02EC96	| Extra YXPPCCCT values for each tile of the Super Koopa (specifically, the Y and T bits).
	db $03,$03,$03,$00						; Bit 1 being set indicates the tile is a cape tile.
	db $03,$03,$03,$00
	db $03,$03,$01,$01
	db $03,$03,$01,$01
	db $83,$83,$80,$00
	db $83,$83,$80,$00
	db $03,$03,$00,$01
	db $03,$03,$00,$01
	db $03,$03,$00,$01

DATA_02ECBA:					;$02ECBA	| Tile sizes for each tile of the Super Koopa. 00 = 8x8, 02 = 16x16.
	db $00,$00,$00,$02
	db $00,$00,$00,$02
	db $00,$00,$00,$02
	db $00,$00,$00,$02
	db $00,$00,$02,$00
	db $00,$00,$02,$00
	db $00,$00,$02,$00
	db $00,$00,$02,$00
	db $00,$00,$02,$00

CODE_02ECDE:					;-----------| Super Koopa GFX routine.
	%GetDrawInfo()
	LDA.w !157C,X				;$02ECE1	|\ 
	STA $02						;$02ECE4	||
	LDA.w !15F6,X				;$02ECE6	|| $02 = Horizontal direction
	AND.b #$0E					;$02ECE9	|| $03 = Animation frame (times 4)
	STA $05						;$02ECEB	|| $04 = Counter for the current tile number
	LDA.w !1602,X				;$02ECED	|| $05 = Super Koopa palette
	ASL							;$02ECF0	||
	ASL							;$02ECF1	||
	STA $03						;$02ECF2	|/
	PHX							;$02ECF4	|
	STZ $04						;$02ECF5	|
CODE_02ECF7:					;			|
	LDA $03						;$02ECF7	|
	CLC							;$02ECF9	|
	ADC $04						;$02ECFA	|
	TAX							;$02ECFC	|
	LDA $01						;$02ECFD	|\ 
	CLC							;$02ECFF	|| Set Y position for the tile.
	ADC.w DATA_02EC4E,X			;$02ED00	||
	STA.w $0301|!addr,Y				;$02ED03	|/
	LDA.w SuperKoopaTiles,X		;$02ED06	|\ Set the tile number.
	STA.w $0302|!addr,Y				;$02ED09	|/
	PHY							;$02EDeC	|
	TYA							;$02ED0D	|\ 
	LSR							;$02ED0E	||
	LSR							;$02ED0F	|| Set the size of the tile.
	TAY							;$02ED10	||
	LDA.w DATA_02ECBA,X			;$02ED11	||
	STA.w $0460|!addr,Y				;$02ED14	|/
	PLY							;$02ED17	|
	LDA $02						;$02ED18	|
	LSR							;$02ED1A	|
	LDA.w DATA_02EC96,X			;$02ED1B	|\ 
	AND.b #$02					;$02ED1E	|| Branch if not a cape tile.
	BEQ CODE_02ED4D				;$02ED20	|/
	PHP							;$02ED22	|
	PHX							;$02ED23	|
	LDX.w $15E9					;$02ED24	|
	LDA.w !1534,X				;$02ED27	|\ Branch if the cape isn't flashing (i.e. feather Super Koopa).
	BEQ CODE_02ED3B				;$02ED2A	|/
	LDA $14						;$02ED2C	|\ 
	LSR							;$02ED2E	||
	AND.b #$01					;$02ED2F	|| Get palette to use for the flashing Super Koopa cape (alternating red/yellow).
	PHY							;$02ED31	||
	TAY							;$02ED32	||
	LDA.w DATA_02ED39,Y			;$02ED33	|/
	PLY							;$02ED36	|
	BRA CODE_02ED44				;$02ED37	|

DATA_02ED39:					;$02ED39	| Palettes for the Super Koopa cape when flashing (i.e. feather Super Koopa).
	db $10,$0A

CODE_02ED3B:					;```````````| Non-flashing cape tile.
	LDA !9E,X					;$02ED3B	|\ 
	CMP.b #$72					;$02ED3D	||
	LDA.b #$08					;$02ED3F	|| Get palette to use for the Super Koopa's cape (red or yellow).
	BCC CODE_02ED44				;$02ED41	||
	LSR							;$02ED43	|/
CODE_02ED44:					;			|
	PLX							;$02ED44	|
	PLP							;$02ED45	|
	ORA.w DATA_02EC96,X			;$02ED46	|\ Get YXPPCCCT for the cape tile.
	AND.b #$FD					;$02ED49	|/
	BRA CODE_02ED52				;$02ED4B	|

CODE_02ED4D:					;```````````| Non-cape tile.
	LDA.w DATA_02EC96,X			;$02ED4D	|\ Just get the YXPPCCCT directly.
	ORA $05						;$02ED50	|/
CODE_02ED52:					;			|
	ORA $64						;$02ED52	|\ 
	BCS CODE_02ED5F				;$02ED54	||
	PHA							;$02ED56	||
	TXA							;$02ED57	||
	CLC							;$02ED58	||
	ADC.b #$24					;$02ED59	|| Set YXPPCCCT, accounting for X flip.
	TAX							;$02ED5B	||
	PLA							;$02ED5C	||
	ORA.b #$40					;$02ED5D	||
CODE_02ED5F:					;			||
	STA.w $0303|!addr,Y				;$02ED5F	|/
	LDA $00						;$02ED62	|\ 
	CLC							;$02ED64	|| Set X position for the tile.
	ADC.w DATA_02EC06,X			;$02ED65	||
	STA.w $0300|!addr,Y				;$02ED68	|/
	INY							;$02ED6B	|
	INY							;$02ED6C	|
	INY							;$02ED6D	|
	INY							;$02ED6E	|
	INC $04						;$02ED6F	|\ 
	LDA $04						;$02ED71	|| Loop for all four tiles.
	CMP.b #$04					;$02ED73	||
	BNE CODE_02ECF7				;$02ED75	|/
	PLX							;$02ED77	|
	LDY.b #$FF					;$02ED78	|\ 
	LDA.b #$03					;$02ED7A	|| Upload 4 manually-sized tiles.
	JSL $01B7B3
    RTS

GenSumoLightning:				;-----------| Subroutine to spawn the Sumo Bro.'s lightning.
	JSL $02A9E4					;$02DD8F	|\ Find an empty sprite slot and return if none found.
	BMI Return02DDC5			;$02DD93	|/
	LDA.b #$2B					;$02DD95	|\\ Sprite to spawn (2B - lightning bolt).
	STA !9E,Y				;$02DD97	||
	LDA.b #$08					;$02DD9A	||| State to spawn in.
	STA.w !14C8,Y				;$02DD9C	|/
	LDA !E4,X					;$02DD9F	|\ 
	ADC.b #$04					;$02DDA1	||
	STA !E4,Y				;$02DDA3	||
	LDA.w !14E0,X				;$02DDA6	||
	ADC.b #$00					;$02DDA9	|| Spawn at the Sumo Bro's position.
	STA.w !14E0,Y				;$02DDAB	||
	LDA !D8,X					;$02DDAE	||
	STA !D8,Y				;$02DDB0	||
	LDA.w !14D4,X				;$02DDB3	||
	STA.w !14D4,Y				;$02DDB6	|/
	PHX							;$02DDB9	|
	TYX							;$02DDBA	|
	JSL $07F7D2					;$02DDBB	|	 How long the lightning bolt has block interaction disabled for after spawning.
	STZ.w !1FE2,X				;$02DDC1	|/
	PLX							;$02DDC4	|
Return02DDC5:					;			|
	RTS							;$02DDC5	|