; Thanks to Thomas and p4plus2 for the SMW disassembly from where I took the original sprite
; If extra bit is set, extra byte 1 is gonna be used to determine how sprite AD will behave
; Valid values:
; #$00 -> will behave as vanilla, X position will dictate starting initial direction of movement 
; #$11 -> won't behave vanilla, will move down first disregarding x position
; #$01 -> won't behave vanilla, will move up first disregarding x position

!RetractSpeed = $F0
!ExtendSpeed = $20
!RetractTimer = $2F
!ExtendTimer = $18
!WaitBeforeRetract = $30
!WaitBeforeExtend = $30
!BasedOnX = !extra_byte_1
!DownOrUp = !extra_byte_1

; Valid values are $00 = down, $10 = up
; Extra bit clear -> sprite AC
; Extra bit set -> sprite AD

print "INIT ",pc
InitWoodSpike:					;-----------| Wooden spike INIT (downwards)
	%BES(InitWoodSpike2)		; If extra bit clear behave like sprite AC, if set behave like sprite AD
	LDA !D8,X					;|\ 
	SEC							;||
	SBC.b #$40					;||
	STA !D8,X					;|| Raise the spike upwards 4 tiles from its spawn position.
	LDA.w !14D4,X				;||
	SBC.b #$00					;||
	STA.w !14D4,X				;|/
	RTL
InitWoodSpike2:					;| Wooden spike 2 INIT
	LDA !BasedOnX,x
	AND #$01
	BNE NotVanilla
	LDA !E4,X					;|\
	BRA SetStartingPos
	NotVanilla:
	LDA !DownOrUp,x
	SetStartingPos:
	AND #$10
	STA.w !151C,X				;|/
	RTL							;|

print "MAIN ",pc
PHB : PHK : PLB
	JSR WoodenSpike
PLB
RTL

; Wooden spike misc RAM:
	; $C2   - Sprite phase pointer. Mod 4: 0 = retracting, 1 = waiting to extend, 2 = extending, 3 = waiting to retract
	; $151C - Initial direction of movement. 00 = down, 10 = up
	; $1540 - Phase timer.
	
WoodenSpike:					;-----------| Wooden Spike MAIN
	JSR WoodSpikeGfx			;| Draw GFX.
	LDA $9D						;|\ Return if game frozen.
	BNE Return039440			;|/
	LDA #$00
	%SubOffScreen()				;| Process offscreen from -$40 to +$30.
	JSR CODE_039488				;| Process interaction with Mario.
	LDA !C2,X					;|
	AND.b #$03					;|
	ASL
	TAX
	JMP (WoodenSpikePtrs,x)		;|

WoodenSpikePtrs:				;| Wooden Spike phase pointers.
	dw RetractingPtr			;| 0 - Retracting
	dw WaitingExtractPtr		;| 1 - Waiting to extend
	dw ExtendingPtr				;| 2 - Extending
	dw WaitingRetractPtr		;| 3 - Waiting to retract

Return039440:
	RTS							;|



ExtendingPtr:					;-----------| Wooden Spike phase 2 - Extending
	LDX $15E9|!addr
	LDA.w !1540,X				;|\ Branch if done extending.
	BEQ CODE_03944A				;|/
	LDA.b #!ExtendSpeed			;|\\ How quickly to extend the wooden spike.
	BRA CODE_039475				;|/

CODE_03944A:					;| Done extending.
	LDA.b #!WaitBeforeRetract	;|\\ How long to wait before retracting the spike.
	BRA SetTimerNextState		;|/



WaitingExtractPtr:				;-----------| Wooden Spike phase 1 - Waiting to extend
	LDX $15E9|!addr
	LDA.w !1540,X				;|\ Return if not time to extend yet.
	BNE Return039457			;|/
	LDA.b #!ExtendTimer			;|\\ How long to spend extending.
	BRA SetTimerNextState		;|/
Return039457:					;|
	RTS							;|



RetractingPtr:					;-----------| Wooden Spike phase 0 - Retracting
	LDX $15E9|!addr
	LDA.w !1540,X				;|\ Branch if done retracting.
	BEQ CODE_039463				;|/
	LDA.b #!RetractSpeed		;|\\ How quickly to retract the spike.
	JSR CODE_039475				;|/
	RTS							;|

CODE_039463:					;| Done retracting.
	LDA.b #!WaitBeforeExtend	;|\\ How long to wait before extending the spike.
SetTimerNextState:				;||
	STA.w !1540,X				;||
	INC !C2,X					;|/
	RTS							;|



WaitingRetractPtr:				;-----------| Wooden Spike phase 3 - Waiting to retract
	LDX $15E9|!addr
	LDA.w !1540,X				;|\ Return if not time to retract.
	BNE Return039474			;|/
	LDA.b #!RetractTimer		;|\\ How long to spend retracting the spike.
	BRA SetTimerNextState		;|/
Return039474:					;|
	RTS							;|



CODE_039475:					;| Retracting/extending the sprite: set Y speed.
	LDY.w !151C,X				;|\ 
	BEQ CODE_03947D				;||
	EOR.b #$FF					;|| Store Y speed.
	INC A						;||  If the spike is sprite AD in an odd X position, invert the given Y speed.
CODE_03947D:					;||
	STA !AA,X					;|/ 
	JSL $01801A					;| Update Y position.
	RTS							;|



DATA_039484:					;| Distances (lo) to push Mario out of the wooden spike when he's touching the side of it.
	db $01,$FF

DATA_039486:					;| Distances (hi) to push Mario out of the wooden spike when he's touching the side of it.
	db $00,$FF

CODE_039488:					;| Routine for processing interaction between the wooden spike and Mario.
	JSL $01A7DC					;|\ Return if not in contact with Mario.
	BCC Return0394B0			;|/
	JSR SubHorzPosBnk3				;|\ 
	LDA $0F						;||
	CLC							;|| Branch if not within 4 pixels of the sprite.
	ADC.b #$04					;||
	CMP.b #$08					;||
	BCS CODE_03949F				;|/
	JSL $00F5B7					;| Hurt Mario.
	RTS							;|

CODE_03949F:					;| Not within 4 pixels of the sprite; touching the sides.
	LDA $94						;|\ 
	CLC							;||
	ADC.w DATA_039484,Y			;||
	STA $94						;|| Push Mario to the side of the sprite.
	LDA $95						;||
	ADC.w DATA_039486,Y			;||
	STA $95						;|/
	STZ $7B						;| Clear Mario's X speed.
Return0394B0:					;|
	RTS							;|



WoodSpikeDispY:					;| Y offsets for each tile of the wooden spike.
	db $00,$10,$20,$30,$40		;| Downwards-pointing
	db $40,$30,$20,$10,$00		;| Upwards-pointing

WoodSpikeTiles:					;| Tile numbers for each tile of the wooden spike.
	db $6A,$6A,$6A,$6A,$4A		;| Downwards-pointing
	db $6A,$6A,$6A,$6A,$4A		;| Upwards-pointing

WoodSpikeGfxProp:				;| YXPPCCCT for each tile of the wooden spike.
	db $81,$81,$81,$81,$81		;| Downwards-pointing
	db $01,$01,$01,$01,$01		;| Upwards-pointing

WoodSpikeGfx:					;| Wooden spike GFX routine
	%GetDrawInfo()				;|
	STZ $02						;|\ 
	%BEC(CODE_0394DE)
	LDA.b #$05					;||
	STA $02						;|/
CODE_0394DE:					;|
	PHX							;|
	LDX.b #$04					;|
WoodSpikeGfxLoopSt:				;| Tile loop.
	PHX							;|
	TXA							;|\ 
	CLC							;|| Get index for the current tile.
	ADC $02						;||
	TAX							;|/
	LDA $00						;|\ Store X position to OAM.
	STA.w $0300|!addr,Y			;|/ 
	LDA $01						;|\ 
	CLC							;|| Store Y position to OAM.
	ADC.w WoodSpikeDispY,X		;||
	STA.w $0301|!addr,Y			;|/
	LDA.w WoodSpikeTiles,X		;|\ Store tile number to OAM.
	STA.w $0302|!addr,Y			;|/
	LDA.w WoodSpikeGfxProp,X	;|\ Store YXPPCCCT to OAM.
	STA.w $0303|!addr,Y			;|/
	INY							;|\ 
	INY							;||
	INY							;||
	INY							;|| Loop for all of the tiles.
	PLX							;||
	DEX							;||
	BPL WoodSpikeGfxLoopSt		;|/ 
	PLX							;|
	LDY.b #$02					;|\ 
	LDA.b #$04					;|| Upload 5 16x16 tiles.
	JSL $01B7B3					;|/
	RTS							;|

SubHorzPosBnk3:					;-----------| Subroutine to check horizontal proximity of Mario to a sprite.
	LDY.b #$00					;$03B817	|  Returns the side in Y (0 = right) and distance in $0F.
	LDA $94						;$03B819	|
	SEC							;$03B81B	|
	SBC !E4,X					;$03B81C	|
	STA $0F						;$03B81E	|
	LDA $95						;$03B820	|
	SBC.w !14E0,X				;$03B822	|
	BPL Return03B828			;$03B825	|
	INY							;$03B827	|
Return03B828:					;			|
	RTS							;$03B828	|





