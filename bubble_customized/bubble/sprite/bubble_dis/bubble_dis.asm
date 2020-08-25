;;disassembled by Atari2.0, all code taken from smw-irq, made by p4plus2 along with the contribution of thomas (kaizoman) so big thanks to them. 
;;this sprite works differently depending if you set the extra bit. If not, it'll be vanilla.
incsrc "bubble_dis_tables.asm" ;;get 'em tables
print "INIT", pc
InitBubbleSpr:					;-----------| Bubble INIT
	PHB : PHK : PLB
	%BES(.set_custom)			;;if the extra bit is set, use extra_byte_1
	JSR InitExplodingBlk        ;;if the extra bit isn't set, just use vanilla setting (aka X pos)
	BRA .continue
	.set_custom
	LDA !extra_byte_1,X ;;safety measure, if extra byte is > 3, set it to 00
	CMP #$04
	BCS .zero
	TAY
	BRA .continue
	.zero
	LDY #$00
	.continue
	STY !C2,X					;$018567	|/
	DEC.w !1534,X				;$018569	|
	JSR FaceMario				;$01856C	|
	PLB
	RTL
print "MAIN ", pc

BubbleSpriteMain:				;-----------| Bubble MAIN
	PHB							;$02D8AD	|
	PHK							;$02D8AE	|
	PLB							;$02D8AF	|
	JSR CODE_02D8BB				;$02D8B0	|
	PLB							;$02D8B3	|
	RTL							;$02D8B4	|

FaceMario:						;-----------| Subroutine to make a sprite face Mario.
	%SubHorzPos()			    ;$01857C	|
	TYA							;$01857F	|
	STA.w !157C,X				;$018580	|					;			|
	RTS							;$018583	|E
	; Bubble misc RAM:
	; $C2   - Sprite inside the bubble. 0 = Goomba, 1 = Bob-omb, 2 = fish, 3 = mushroom
	; $151C - Vertical direction of acceleration. Even = down, odd = up.
	; $1534 - Timer for the bubble. Pops when it runs out.
	; $157C - Horizontal direction of movement. 0 = right, 1 = left.
CODE_02D8BB:	;-----------| Actual bubble MAIN
	LDA.w !15EA,X				;$02D8BB	|\ 
	CLC							;$02D8BE	||
	ADC.b #$14					;$02D8BF	|| Set up a 16x16 tile for the sprite inside the bubble.
	STA.w !15EA,X				;$02D8C1	||
	JSL $0190B2				;$02D8C4	|/  call to JSL wrapper for SubSprGFX2Entry1. This routine draws a single 16x16					;$02D8C8	|
	PHX
	LDA !C2,X					;$02D8C9	|\ 
	LDY.w !15EA,X				;$02D8CB	||
	TAX							;$02D8CE	|| Set actual YXPPCCCT for the tile.
	LDA.w BubbleSprGfxProp1,X	;$02D8CF	||
	ORA $64						;$02D8D2	||
	STA.w $0303|!addr,Y				;$02D8D4	|/
	LDA $14						;$02D8D7	|\ 
	ASL							;$02D8D9	||
	ASL							;$02D8DA	||
	ASL							;$02D8DB	||
	LDA.w BubbleSprTiles1,X		;$02D8DC	|| Set actual tile number for the tile, animating it on an 4-frame cycle.
	BCC CODE_02D8E4				;$02D8DF	||
	LDA.w BubbleSprTiles2,X		;$02D8E1	||
CODE_02D8E4:					;			||
	STA.w $0302|!addr,Y				;$02D8E4	|/
	PLX							;$02D8E7	|
	LDA.w !1534,X				;$02D8E8	|\ 
	CMP.b #$60					;$02D8EB	||
	BCS CODE_02D8F3				;$02D8ED	|| Draw the bubble.
	AND.b #$02					;$02D8EF	||  If the bubble's timer is close to running out, make it flash every 2 frames.
	BEQ CODE_02D8F6				;$02D8F1	||
CODE_02D8F3:					;			||
	JSR GfxRoutine				;$02D8F3	|/
CODE_02D8F6:				;			|
	LDA.w !14C8,X				;$02D8F6	|\ 
	CMP.b #$02					;$02D8F9	||
	BNE CODE_02D904				;$02D8FB	|| If the bubble hasn't been killed by... something, reset it to its normal state?
	LDA.b #$08					;$02D8FD	||  Not sure what the point of this is, but it's the reason you get a million points from throwing shells at bubbles.
	STA.w !14C8,X				;$02D8FF	||
	BRA CODE_02D96B				;$02D902	|/ 
CODE_02D904:					;			|
	LDA $9D						;$02D904	|\ Return if game frozen.
	BNE Return02D977			;$02D906	|/
	LDA $13						;$02D908	|\ 
	AND.b #$01					;$02D90A	||
	BNE CODE_02D91D				;$02D90C	||
	DEC.w !1534,X				;$02D90E	|| Decrease lifespan timer every 2 frames.
	LDA.w !1534,X				;$02D911	|| If about to run out, play the pop sound.
	CMP.b #$04					;$02D914	||
	BNE CODE_02D91D				;$02D916	||
	LDA.b #$19					;$02D918	||\ SFX for popping the bubble.
	STA.w $1DFC|!addr				;$02D91A	|//
CODE_02D91D:					;			|
	LDA.w !1534,X				;$02D91D	|\ 
	DEC A						;$02D920	|| Branch if time to erase the bubble and spawn the sprite inside.
	BEQ CODE_02D978				;$02D921	|/
	CMP.b #$07					;$02D923	|\ Return if the bubble is already popping.
	BCC Return02D977			;$02D925	|/
    LDA.b #$00
	%SubOffScreen()		;$02D927	| Process offscreen from -$40 to +$30.
	JSL $018022		;$02D92A	|\ Update X/Y position. SpriteXposNograv
	JSL $01801A		;$02D92D	|/ SpriteYposNograv
	JSL $019138     ;sprite-object interaction 
    LDY.w !157C,X				;$02D934	|\ 
	LDA.w BubbleSprXSpeed,Y		;$02D937	|| Store X speed.
	STA !B6,X					;$02D93A	|/
	LDA $13						;$02D93C	|\ 
	AND.b #$01					;$02D93E	||
	BNE CODE_02D958				;$02D940	||
	LDA.w !151C,X				;$02D942	||
	AND.b #$01					;$02D945	||
	TAY							;$02D947	|| Update Y speed every other frame.
	LDA !AA,X					;$02D948	||  If at the maximum Y speed in the current direction, invert the direction of acceleration.
	CLC							;$02D94A	||
	ADC.w BubbleSprYAccel,Y		;$02D94B	||
	STA !AA,X					;$02D94E	||
	CMP.w BubbleSprYMax,Y		;$02D950	||
	BNE CODE_02D958				;$02D953	||
	INC.w !151C,X				;$02D955	|/
CODE_02D958:					;			|
	LDA.w !1588,X				;$02D958	|\ Branch if hitting a block.
	BNE CODE_02D96B				;$02D95B	|/
	JSL $018032		        	;$02D95D	| Process sprite interaction.
	JSL $01A7DC         		;$02D961	|\ Return if not being touching by Mario.
	BCC Return02D9A0			;$02D965	|/
	STZ $7D						;$02D967	|\ Clear Mario's speed.
	STZ $7B						;$02D969	|/
CODE_02D96B:					;```````````| Bubble has been hit.
	LDA.w !1534,X				;$02D96B	|\ 
	CMP.b #$07					;$02D96E	||
	BCC Return02D977			;$02D970	|| Drop its lifespan timer down so it pops.
	LDA.b #$06					;$02D972	||
	STA.w !1534,X				;$02D974	|/
Return02D977:					;			|
	RTS							;$02D977	|


CODE_02D978:	;```````````| Erasing the bubble and replacing it with the sprite inside.					
	LDY !C2,X
	LDA.w BubbleSprites,Y		;$02D97A	|| Get the sprite to spawn.
	STA !9E,X
	PHA 
	JSL $07F7D2						;$02D984	|
	PLY 
	LDA.b #$20					;$02D985	|\ 
	CPY.b #$74					;$02D987	||
	BNE CODE_02D98D				;$02D989	|| Disable contact for the sprite with Mario for a bit.
	LDA.b #$04					;$02D98B	||
CODE_02D98D:					;			||
	STA.w !154C,X				;$02D98D	|/
	LDA !9E,X					;$02D990	|\ 
	CMP.b #$0D					;$02D992	|| Initialize the Bob-Omb's stun timer.
	BNE CODE_02D999				;$02D994	||
	DEC.w !1540,X				;$02D996	|/
CODE_02D999:					;			|
	%SubHorzPos()			;$02D999	|\ 
	TYA							;$02D99C	|| Turn the sprite towards Mario.
	STA.w !157C,X				;$02D99D	|/
Return02D9A0:					;			|
	RTS							;$02D9A0	|

GfxRoutine:					;-----------| Bubble GFX routine.
	%GetDrawInfo()			;$02D9D6	|
	LDA $14						;$02D9D9	|\ 
	LSR							;$02D9DB	||
	LSR							;$02D9DC	||
	LSR							;$02D9DD	|| $02 = index to the offset tables for each frame of animation.
	AND.b #$03					;$02D9DE	||
	TAY							;$02D9E0	||
	LDA.w DATA_02D9D2,Y			;$02D9E1	||
	STA $02						;$02D9E4	|/
	LDA.w !15EA,X				;$02D9E6	|
	SEC							;$02D9E9	|
	SBC.b #$14					;$02D9EA	|
	STA.w !15EA,X				;$02D9EC	|
	TAY							;$02D9EF	|
	PHX							;$02D9F0	|
	LDA.w !1534,X				;$02D9F1	|\ $03 = Timer for the popping animation.
	STA $03						;$02D9F4	|/
	LDX.b #$04					;$02D9F6	|| Number of tiles to use for the bubble (excluding the sprite inside).
CODE_02D9F8:					;			|
	PHX							;$02D9F8	|
	TXA							;$02D9F9	|
	CLC							;$02D9FA	|
	ADC $02						;$02D9FB	|
	TAX							;$02D9FD	|
	LDA $00						;$02D9FE	|\ 
	CLC							;$02DA00	|| Store X position to OAM.
	ADC.w BubbleTileDispX,X		;$02DA01	||
	STA.w $0300|!addr,Y				;$02DA04	|/
	LDA $01						;$02DA07	|\ 
	CLC							;$02DA09	|| Store Y position to OAM.
	ADC.w BubbleTileDispY,X		;$02DA0A	||
	STA.w $0301|!addr,Y				;$02DA0D	|/
	PLX							;$02DA10	|
	LDA.w BubbleTiles,X			;$02DA11	|\ Store tile number to OAM.
	STA.w $0302|!addr,Y				;$02DA14	|/
	LDA.w BubbleGfxProp,X		;$02DA17	|\ 
	ORA $64						;$02DA1A	|| Store YXPPCCCT to OAM.
	STA.w $0303|!addr,Y				;$02DA1C	|/
	LDA $03						;$02DA1F	|\ 
	CMP.b #$06					;$02DA21	|| If popping the bubble, change the tile number and YXPPCCCT.
	BCS CODE_02DA37				;$02DA23	||
	CMP.b #$03					;$02DA25	||
	LDA.b #$02					;$02DA27	||\ 
	ORA $64						;$02DA29	||| Change YXPPCCCT.
	STA.w $0303|!addr,Y				;$02DA2B	||/
	LDA.b #$64					;$02DA2E	||\\ Tile A to use for the bubble's pop animation.
	BCS CODE_02DA34				;$02DA30	|||
	LDA.b #$66					;$02DA32	|||| Tile B to use for the bubble's pop animation.
CODE_02DA34:					;			|||
	STA.w $0302|!addr,Y				;$02DA34	|//
CODE_02DA37:					;			|
	PHY							;$02DA37	|
	TYA							;$02DA38	|\ 
	LSR							;$02DA39	||
	LSR							;$02DA3A	|| Set size for the tile
	TAY							;$02DA3B	||
	LDA.w BubbleSize,X			;$02DA3C	||
	STA.w $0460|!addr,Y				;$02DA3F	|/
	PLY							;$02DA42	|
	INY							;$02DA43	|\ 
	INY							;$02DA44	||
	INY							;$02DA45	|| Loop for all of the tiles.
	INY							;$02DA46	||
	DEX							;$02DA47	||
	BPL CODE_02D9F8				;$02DA48	|/
	PLX							;$02DA4A	|
	LDY.b #$FF					;$02DA4B	|\ 
	LDA.b #$04					;$02DA4D	|| Upload 5 manually-sized tiles.
	JSL $01B7B3					;$02B7A7	|/ ;finish OAM write
	RTS							;$02B7AB	|
InitExplodingBlk:				;-----------| Exploding block INIT. Also used as a subroutine by the Bowser statue and bubble sprites.
	LDA !E4,X					;$0183A4	|\ 
	LSR							;$0183A6	||
	LSR							;$0183A7	||
	LSR							;$0183A8	||
	LSR							;$0183A9	|| Get the sprite number for the block to spawn based on its X position.
	AND.b #$03					;$0183AA	||
	TAY							;$0183AC	||
	LDA.w ExplodingBlkSpr,Y		;$0183AD	||
	STA !C2,X					;$0183B0	|/
	RTS							;$0183B2	|


