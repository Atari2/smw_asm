;exploding block disassembly except it uses extra byte 1 to decide which sprite to spawn
;extra bit clear or set doesn't matter
;extra byte 1 = sprite id
;extra byte 2 = 00 if sprite is not custom, 01 if custom
!sprite_to_spawn = !extra_byte_1
!is_custom = !extra_byte_2 
print "INIT", pc
InitExplodingBlk:				;-----------| Exploding block INIT. Also used as a subroutine by the Bowser statue and bubble sprites.
	LDA !sprite_to_spawn,x
	STA $C2,X					;$0183B0	|/
	RTL							;$0183B2	|

; Exploding block misc RAM:
	; $C2   - Sprite ID contained inside the block.
	; $1570 - Frame counter for the block's shaking animation.
	; $157C - Horizontal direction the sprite is facing. Always 0, though.
	; $1602 - Animation frame. Always 0, though.
print "MAIN", pc
ExplodingBlkMain:				;-----------| Exploding block MAIN
	PHB							;$02E417	|
	PHK							;$02E418	|
	PLB							;$02E419	|
	JSR ExplodingBlk				;$02E41A	|
	PLB							;$02E41D	|
	RTL							;$02E41E	|
	
ExplodingBlk:
	JSL $0190B2					;$02E41F	| Draw a 16x16 sprite.
	LDA $9D						;$02E423	|\ Return if game frozen.
	BNE Return02E462			;$02E425	|/	
MainBlk:					;			|
	LDY.b #$00					;$02E42D	|
	INC.w $1570,X				;$02E42F	|
	LDA.w $1570,X				;$02E432	|\ 
	AND.b #$40					;$02E435	||
	BEQ MarioNotNear				;$02E437	||
	LDY.b #$04					;$02E439	||
	LDA.w $1570,X				;$02E43B	||
	AND.b #$04					;$02E43E	|| Handle the shaking animation.
	BEQ MarioNotNear				;$02E440	||
	LDY.b #$FC					;$02E442	||
MarioNotNear:					;			||
	STY $B6,X					;$02E444	||
	JSL $018022					;$02E446	|/
	JSL $01803A					;$02E449	| Process Mario and sprite interaction.
	JSR CheckMarioSide				;$02E44D	|\ 
	LDA $0F						;$02E450	||
	CLC							;$02E452	||
	ADC.b #$60					;$02E453	||
	CMP.b #$C0					;$02E455	|| If Mario is within 6 tiles of the sprite and the sprite isn't offscreen, make it explode.
	BCS Return02E462			;$02E457	||
	LDY.w $15A0,X				;$02E459	||
	BNE Return02E462			;$02E45C	||
	JSL SpawnSpriteLabel				;$02E45E	|/
Return02E462:					;			|
	RTS							;$02E462	|


SpawnSpriteLabel:					;```````````| Subroutine to spawn a sprite from the exploding block.
	LDA $C2,X					;$02E463	|\ Get sprite id from C2
	PHA                         ;$02E465	|| Put it on the stack for later
	LDA !is_custom,X			; Is it a custom sprite?	
	BEQ .not_custom				; if not, continue as normal							
	LDA.b #$D0
	STA $03
	STZ $02
	STZ $00
	STZ $01
	SEC 						; if yes, set carry and get A from stack (sprite id in C2)
	PLA
	%SpawnSprite()				; then just call pixi's routine
	STX $0B 					; preserve original sprite index somewhere
	TYX							; transfer the new index from Y to X
	BRA .custom					; give the speed to the correct sprite and create the shatter effect
	.not_custom
	PLA 						
	STA $9E,X	
	JSL $07F7D2					;$02E467	|/
	LDA.b #$D0					;$02E46B	| Y speed to give sprites spawned from the exploding block.
	STA $AA,X					;$02E46D	|
	.custom
	JSR CheckMarioSide				;$02E46F	|\ 
	TYA							;$02E472	|| Turn the sprite towards Mario.
	STA.w $157C,X				;$02E473	|/
	LDA $E4,X					;$02E476	|\ 
	STA $9A						;$02E478	||
	LDA.w $14E0,X				;$02E47A	||
	STA $9B						;$02E47D	||
	LDA $D8,X					;$02E47F	||
	STA $98						;$02E481	||
	LDA.w $14D4,X				;$02E483	|| Create a shatter effect at the sprite's position.
	STA $99						;$02E486	||
	PHB							;$02E488	||
	LDA.b #$02					;$02E489	||
	PHA							;$02E48B	||
	PLB							;$02E48C	||
	LDA.b #$00					;$02E48D	||
	JSL $028663					;$02E48F	|/
	PLB							;$02E493	|
	LDA !is_custom,X			; was the spawned sprite custom?
	BEQ .end					; if not, just end
	LDX $0B						; if yes, get the X preserved earlier and kill this sprite
	LDA #$00					; kill this
	STA $14C8,X					; please (can I do stz ? no idea, better be safe)
	.end
	RTL							;$02E494	|
	

CheckMarioSide:					;-----------| Subroutine to check which side of the sprite Mario is on (duplicate of SubHorzPosBnk2). Returns Y: 00 = right, 01 = left.
	LDY.b #$00					;$02D4FA	|
	LDA $94						;$02D4FC	|
	SEC							;$02D4FE	|
	SBC $E4,X					;$02D4FF	|
	STA $0F						;$02D501	|
	LDA $95						;$02D503	|
	SBC.w $14E0,X				;$02D505	|
	BPL Return02D50B			;$02D508	|
	INY							;$02D50A	|
Return02D50B:					;			|
	RTS							;$02D50B	|