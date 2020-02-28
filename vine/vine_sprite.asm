; Growing vine misc RAM:
	; $1540 - Timer for going behind objects after being spawned from a block. Set to #$3E when spawned from a block.
	; $154C - Set to #$2C when spawned from a block.
!tile = $02  ;empty
print "INIT ",pc
GrowingVineInit:
	RTL

print "MAIN ",pc
GrowingVineWrap:
	PHB							;$02DB4C	|
	PHK							;$02DB4D	|
	PLB							;$02DB4E	|
	JSR GrowingVine				;$02DB4F	|
	PLB							;$02DB52	|
	RTL							;$02DB53	|
	
GrowingVine:					;-----------| Growing vine MAIN.
	LDA $64						;$01C183	|
	PHA							;$01C185	|
	LDA.w $1540,X				;$01C186	|\ 
	CMP.b #$20					;$01C189	||
	BCC CODE_01C191				;$01C18B	|| If spawned from a block, send behind objects.
	LDA.b #$10					;$01C18D	||
	STA $64						;$01C18F	|/
CODE_01C191:					;			|
	JSL $0190B2					;$01C191	| Set up OAM.
	LDY.w $15EA,X				;$01C194	|\ 
	LDA $14						;$01C197	||
	LSR							;$01C199	||
	LSR							;$01C19A	||
	LSR							;$01C19B	|| Set tile based on frame.
	LSR							;$01C19C	||
	LDA.b #$AC					;$01C19D	||| Vine frame A.
	BCC CODE_01C1A3				;$01C19F	||
	LDA.b #$AE					;$01C1A1	||| Vine frame B.
CODE_01C1A3:					;			||
	STA.w $0302,Y				;$01C1A3	|/
	PLA							;$01C1A6	|
	STA $64						;$01C1A7	|
	LDA $9D						;$01C1A9	|\ Return if game frozen.
	BNE Return01C1ED			;$01C1AB	|/
	LDA.b #$F0					;$01C1AD	|\\ Vine's Y speed.
	STA $AA,X					;$01C1AF	|/
	JSL $01801A					;$01C1B1	| Update position.
	LDA.w $1540,X				;$01C1B4	|\ 
	CMP.b #$20					;$01C1B7	|| Don't interact with objects while being spawned from a block.
	BCS CODE_01C1CB				;$01C1B9	|/
	JSL $019138					;$01C1BB	| Interact with blocks.
	LDA.w $1588,X				;$01C1BE	|\ 
	BNE CODE_01C1C8				;$01C1C1	||
	LDA.w $14D4,X				;$01C1C3	|| Erase the vine if it hit a block or it's off the top of the level.
	BPL CODE_01C1CB				;$01C1C6	||
CODE_01C1C8:					;			||
	JMP OffScrEraseSprite		;$01C1C8	|/

CODE_01C1CB:					;```````````| Spawn a vine tile beneath the sprite.
	LDA $D8,X					;$01C1CB	|\ 
	AND.b #$0F					;$01C1CD	|| Return if not centered on a tile.
	CMP.b #$00					;$01C1CF	||
	BNE Return01C1ED			;$01C1D1	|/
	LDA $E4,X					;$01C1D3	|\ 
	STA $9A						;$01C1D5	||
	LDA.w $14E0,X				;$01C1D7	||
	STA $9B						;$01C1DA	||
	LDA $D8,X					;$01C1DC	||
	STA $98						;$01C1DE	|| Spawn the tile.
	LDA.w $14D4,X				;$01C1E0	||
	STA $99						;$01C1E3	||
	LDA.b #!tile				;$01C1E5	||
	STA $9C						;$01C1E7	||
	JSL $00BEB0					;$01C1E9	|/
Return01C1ED:					;			|
	RTS							;$01C1ED	|
	
OffScrEraseSprite:				;```````````| Subroutine to erase a sprite when offscreen.
	LDA $9E,X					;$01AC80	|\ 
	CMP.b #$1F					;$01AC82	||
	BNE CODE_01AC8E				;$01AC84	|| If sprite 1F (MagiKoopa), just make
	STA.w $18C1					;$01AC86	|| it look for a new position again.
	LDA.b #$FF					;$01AC89	||
	STA.w $18C0					;$01AC8B	|/
CODE_01AC8E:					;			|
	LDA.w $14C8,X				;$01AC8E	|\ 
	CMP.b #$08					;$01AC91	||
	BCC OffScrKillSprite		;$01AC93	||
	LDY.w $161A,X				;$01AC95	||
	CPY.b #$FF					;$01AC98	|| Erase the sprite.
	BEQ OffScrKillSprite		;$01AC9A	||  If it wasn't killed, set it to respawn.
	LDA.b #$00					;$01AC9C	||
	STA.w $1938,Y				;$01AC9E	||
OffScrKillSprite:				;			||
	STZ.w $14C8,X				;$01ACA1	|/
Return01ACA4:					;			|
	RTS							;$01ACA4	|