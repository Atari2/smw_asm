;;disassembled by Atari2.0, all code taken from smw-irq, made by p4plus2 along with the contribution of thomas (kaizoman) so big thanks to them.
;;bubble that spawns a disco shell (requires a custom sprite https://www.smwcentral.net/?p=section&a=details&id=3442)
;;this sprite works differently depending if you set the extra bit.
;;if extra bit clear (02) it will interact as soon as it spawns, if set (03) it will wait 20 frames
;;REQUIRES extra byte 1 to be set to the number that the flashing shell has in your list.txt

incsrc "bubble_disco_tables.asm" ;;get 'em tables
print "INIT", pc
InitBubbleSpr:					;| Bubble INIT
	DEC.w !1534,X				;|
	%SubHorzPos()			    ;|
	TYA							;|
	STA.w !157C,X				;|
	RTL							;|

print "MAIN ", pc

BubbleSpriteMain:				;| Bubble MAIN
	PHB							;|
	PHK							;|
	PLB							;|
	JSR CODE_02D8BB				;|
	PLB							;|
	RTL							;|
				
	; Bubble misc RAM:
	; $151C - Vertical direction of acceleration. Even = down, odd = up.
	; $1534 - Timer for the bubble. Pops when it runs out.
	; $157C - Horizontal direction of movement. 0 = right, 1 = left.
CODE_02D8BB:	;-----------| Actual bubble MAIN
	LDA.w !15EA,X				;|\ 
	CLC							;||
	ADC.b #$14					;|| Set up a 16x16 tile for the sprite inside the bubble.
	STA.w !15EA,X				;||
	JSL $0190B2					;|/  call to JSL wrapper for SubSprGFX2Entry1. This routine draws a single 16x16					;$02D8C8	|
	PHX							;
	LDY.w !15EA,X				;
	LDA $14						;
	LSR
	LSR
	AND #$03					;|\			
	TAX							;|| Set actual YXPPCCCT for the tile.
	LDA $64
	AND #$CE
	ORA BubbleSprGfxProp1,X	;||
	STA.w $0303|!addr,Y			;|/
	LDA.w BubbleSprTiles1,X		;|| Set actual tile number for the tile, animating it on an 4-frame cycle.
CODE_02D8E4:					;||
	STA.w $0302|!addr,Y			;|/
	PLX							;|
	LDA.w !1534,X				;|\ 
	CMP.b #$60					;||
	BCS CODE_02D8F3				;|| Draw the bubble.
	AND.b #$02					;||  If the bubble's timer is close to running out, make it flash every 2 frames.
	BEQ CODE_02D8F6				;||
CODE_02D8F3:					;||
	JSR GfxRoutine				;|/
CODE_02D8F6:					;|
	LDA.w !14C8,X				;|\ 
	CMP.b #$02					;||
	BNE CODE_02D904				;|| If the bubble hasn't been killed by... something, reset it to its normal state?
	LDA.b #$08					;||  Not sure what the point of this is, but it's the reason you get a million points from throwing shells at bubbles.
	STA.w !14C8,X				;||
	BRA CODE_02D96B				;|/ 
CODE_02D904:					;|
	LDA $9D						;|\ Return if game frozen.
	BNE Return02D977			;|/
	LDA $13						;|\ 
	AND.b #$01					;||
	BNE CODE_02D91D				;||
	DEC.w !1534,X				;|| Decrease lifespan timer every 2 frames.
	LDA.w !1534,X				;|| If about to run out, play the pop sound.
	CMP.b #$04					;||
	BNE CODE_02D91D				;||
	LDA.b #$19					;||\ SFX for popping the bubble.
	STA.w $1DFC|!addr			;|//
CODE_02D91D:					;|
	LDA.w !1534,X				;|\ 
	DEC A						;|| Branch if time to erase the bubble and spawn the sprite inside.
	BEQ CODE_02D978				;|/
	CMP.b #$07					;|\ Return if the bubble is already popping.
	BCC Return02D977			;|/
    LDA.b #$00
	%SubOffScreen()				;| 	Process offscreen from -$40 to +$30.
	JSL $018022					;|\ Update X/Y position. SpriteXposNograv
	JSL $01801A					;|/ SpriteYposNograv
	JSL $019138     			;|	sprite-object interaction 
    LDY.w !157C,X				;|\ 
	LDA.w BubbleSprXSpeed,Y		;|| Store X speed.
	STA !B6,X					;|/
	LDA $13						;|\ 
	AND.b #$01					;||
	BNE CODE_02D958				;||
	LDA.w !151C,X				;||
	AND.b #$01					;||
	TAY							;|| Update Y speed every other frame.
	LDA !AA,X					;||  If at the maximum Y speed in the current direction, invert the direction of acceleration.
	CLC							;||
	ADC.w BubbleSprYAccel,Y		;||
	STA !AA,X					;||
	CMP.w BubbleSprYMax,Y		;||
	BNE CODE_02D958				;||
	INC.w !151C,X				;|/
CODE_02D958:					;|
	LDA.w !1588,X				;|\ Branch if hitting a block.
	BNE CODE_02D96B				;|/
	JSL $018032		        	;| Process sprite interaction.
	JSL $01A7DC         		;|\ Return if not being touching by Mario.
	BCC Return02D977			;|/
	STZ $7D						;|\ Clear Mario's speed.
	STZ $7B						;|/
CODE_02D96B:					;| Bubble has been hit.
	LDA.w !1534,X				;|\ 
	CMP.b #$07					;||
	BCC Return02D977			;|| Drop its lifespan timer down so it pops.
	LDA.b #$06					;||
	STA.w !1534,X				;|/
Return02D977:					;|
	RTS							;|


CODE_02D978:					;| Erasing the bubble and replacing it with the disco.
	STZ $00
	STZ $01
	STZ $02
	STZ $03
	LDA !extra_byte_1,x
	SEC
	%SpawnSprite()
	%BEC(+)
	PHX
	TYX 
	LDA #$20
	STA.w !154C,X
	PLX
	+
	STZ !14C8,x					;| Kill the sprite
	RTS							;|

GfxRoutine:						;| Bubble GFX routine.
	%GetDrawInfo()				;|
	LDA $14						;|\ 
	LSR							;||
	LSR							;||
	LSR							;|| $02 = index to the offset tables for each frame of animation.
	AND.b #$03					;||
	TAY							;||
	LDA.w DATA_02D9D2,Y			;||
	STA $02						;|/
	LDA.w !15EA,X				;|
	SEC							;|
	SBC.b #$14					;|
	STA.w !15EA,X				;|
	TAY							;|
	PHX							;|
	LDA.w !1534,X				;|\ $03 = Timer for the popping animation.
	STA $03						;|/
	LDX.b #$04					;|| Number of tiles to use for the bubble (excluding the sprite inside).
CODE_02D9F8:					;|
	PHX							;|
	TXA							;|
	CLC							;|
	ADC $02						;|
	TAX							;|
	LDA $00						;|\ 
	CLC							;|| Store X position to OAM.
	ADC.w BubbleTileDispX,X		;||
	STA.w $0300|!addr,Y			;|/
	LDA $01						;|\ 
	CLC							;|| Store Y position to OAM.
	ADC.w BubbleTileDispY,X		;||
	STA.w $0301|!addr,Y			;|/
	PLX							;|
	LDA.w BubbleTiles,X			;|\ Store tile number to OAM.
	STA.w $0302|!addr,Y			;|/
	LDA.w BubbleGfxProp,X		;|\ 
	ORA $64						;|| Store YXPPCCCT to OAM.
	STA.w $0303|!addr,Y			;|/
	LDA $03						;|\ 
	CMP.b #$06					;|| If popping the bubble, change the tile number and YXPPCCCT.
	BCS CODE_02DA37				;||
	CMP.b #$03					;||
	LDA.b #$02					;||\ 
	ORA $64						;||| Change YXPPCCCT.
	STA.w $0303|!addr,Y			;||/
	LDA.b #$64					;||\\ Tile A to use for the bubble's pop animation.
	BCS CODE_02DA34				;|||
	LDA.b #$66					;|||| Tile B to use for the bubble's pop animation.
CODE_02DA34:					;|||
	STA.w $0302|!addr,Y			;|//
CODE_02DA37:					;|
	PHY							;|
	TYA							;|\ 
	LSR							;||
	LSR							;|| Set size for the tile
	TAY							;||
	LDA.w BubbleSize,X			;||
	STA.w $0460|!addr,Y			;|/
	PLY							;|
	INY							;|\ 
	INY							;||
	INY							;|| Loop for all of the tiles.
	INY							;||
	DEX							;||
	BPL CODE_02D9F8				;|/
	PLX							;|
	LDY.b #$FF					;|\ 
	LDA.b #$04					;|| Upload 5 manually-sized tiles.
	JSL $01B7B3					;|/ ;finish OAM write
	RTS							;|


