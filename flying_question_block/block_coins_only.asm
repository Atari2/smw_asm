;;Flying question block disassembly, done by Atari2.0
;;code taken from smw-irq, commented by p4plus2 and thomas (kaizoman)
;;SA-1 compatible
if defined("addr") == 0			;check if !addr exists (added in pixi 1.2.10)
	if read1($00FFD5) == $23
		!addr = $6000
	else
		!addr = $0000
	endif 
endif
!sprite_to_spawn = !extra_byte_1	; 0 = coin, 1 = fireflower, 2 = feather, 3 = 1-up
print "INIT ",pc
InitFlyingQBlock:				;-----------| Flying question block INIT
	LDA #!sprite_to_spawn		;Only use coins plx
	STA.w !151C,X				;$01AD61	|/
	INC.w !157C,X				;$01AD64	| Set the sprite to face left.
	RTL							;$01AD67	|
	
print "MAIN ", pc
FlyingBlockWrap:				;-----------| Flying Block MAIN Wrapper
	PHB							;$02D8AD	|
	PHK							;$02D8AE	|
	PLB							;$02D8AF	|
	JSR FlyingQBlock			;$02D8B0	|
	PLB							;$02D8B3	|
	RTL							;$02D8B4	|

	; Flying Question Block misc RAM:
	; $C2   - Indicator that the block has been hit. When 1, it bounces up, and when 2, it comes back down.
	; $151C - Which item to spawn when hit (coin, fireflower, feather, 1up). When small, an additional 4 gets added to this.
	; $1528 - How many pixels the sprite has moved horizontally in the frame.
	; $1534 - Direction of horizontal acceleration. Even = left, odd = right
	; $1558 - Set to #$10 when hit for the first time. (bounce animation timer)
	; $1564 - Set to #$10 when hit.
	; $1570 - Frame counter for animation.
	; $157C - Horizontal direction the sprite is facing. Always set to 1.
	; $1594 - Direction of acceleration. Even = up, odd = down.
	; $163E - Timer for a sprite rising out of the block. Set to #$50 when the sprite is spawned.

FlyingQBlock:					;-----------| Flying question block MAIN
	LDA.w !163E,X				;$01AD6E	|\ 
	BEQ CODE_01AD80				;$01AD71	|| Change OAM index if necessary.
	STZ.w !15EA,X				;$01AD73	|| While spawning something, it becomes either #$04 (no Yoshi) or #$00 (with Yoshi).
	LDA.w $187A|!addr					;$01AD76	||  (because Yoshi uses #$04 while turning)
	BNE CODE_01AD80				;$01AD79	|| However, this causes glitches with multiple blocks, or turning with an item.
	LDA.b #$04					;$01AD7B	||
	STA.w !15EA,X				;$01AD7D	|/
CODE_01AD80:					;			|
	JSL $0190B2					;$01AD80	| Draw a 16x16 sprite. (JSRs to SubSprGfx2Entry1)
	LDY.w !15EA,X				;$01AD83	|
	LDA.w $0301|!addr,Y				;$01AD86	|\ 
	DEC A						;$01AD89	|| Shift the sprite one tile up.
	STA.w $0301|!addr,Y				;$01AD8A	|/
	STZ.w !1528,X				;$01AD8D	|
	LDA !C2,X					;$01AD90	|\ Don't move or draw wings if the block has been hit.
	BNE CODE_01ADF8				;$01AD92	|/
	JSR WingRoutine				;$01AD94	| Draw wings.
	LDA $9D						;$01AD97	|\ Don't move if the game is frozen.
	BNE CODE_01ADF8				;$01AD99	|/
	LDA $13						;$01AD9B	|\\ 
	AND.b #$01					;$01AD9D	||| Only change Y speed every other frame.
	BNE CODE_01ADB7				;$01AD9F	||/
	LDA.w !1594,X				;$01ADA1	||\ 
	AND.b #$01					;$01ADA4	|||
	TAY							;$01ADA6	|||
	LDA !AA,X					;$01ADA7	|||
	CLC							;$01ADA9	||| Handle Y speed acceleration.
	ADC.w DATA_01AD68,Y			;$01ADAA	|||
	STA !AA,X					;$01ADAD	|||
	CMP.w DATA_01AD6A,Y			;$01ADAF	|||
	BNE CODE_01ADB7				;$01ADB2	|||
	INC.w !1594,X				;$01ADB4	|//
CODE_01ADB7:					;			|
	JSL $01801A					;$01ADB7	| Update Y position.
	LDA !9E,X					;$01ADBA	|\ 
	CMP.b #$83					;$01ADBC	|| Branch if not sprite 84.
	BEQ CODE_01ADE8				;$01ADBE	|/
	LDA.w !1540,X				;$01ADC0	|\\ 
	BNE CODE_01ADE6				;$01ADC3	|||
	LDA $13						;$01ADC5	||| Only change X speed every frame frame, and don't update for a brief time at max speed.
	AND.b #$03					;$01ADC7	|||
	BNE CODE_01ADE6				;$01ADC9	||/
	LDA.w !1534,X				;$01ADCB	||\ 
	AND.b #$01					;$01ADCE	|||
	TAY							;$01ADD0	|||
	LDA !B6,X					;$01ADD1	|||
	CLC							;$01ADD3	||| Handle X speed acceleration.
	ADC.w DATA_01AD68,Y			;$01ADD4	|||
	STA !B6,X					;$01ADD7	|||
	CMP.w DATA_01AD6C,Y			;$01ADD9	|||
	BNE CODE_01ADE6				;$01ADDC	|||
	INC.w !1534,X				;$01ADDE	||/
	LDA.b #$20					;$01ADE1	|| How long to fly at max speed for.
	STA.w !1540,X				;$01ADE3	|/
CODE_01ADE6:					;			|
	BRA CODE_01ADEC				;$01ADE6	|

CODE_01ADE8:
	LDA.b #$F4					;$01ADE8	|\ Sprite 83: move left at a constant rate.
	STA !B6,X					;$01ADEA	|/
CODE_01ADEC:					;			|
	JSL $018022					;$01ADEC	| Update X position. (JSRs to SubSprXPosNoGrvty)
	LDA.w $1491|!addr				;$01ADEF	|\ Preserve how many pixels the block has moved.
	STA.w !1528,X				;$01ADF2	|/
	INC.w !1570,X				;$01ADF5	| Handle animation timer.
CODE_01ADF8:					;			|
	JSL $018032					;$01ADF8	| Process interaciton with other sprites. 
	JSL $01B44F					;$01ADFB	| Make the block solid.
	LDA #$01
	%SubOffScreen()				;$01ADFE	| Process offscreen from -$40 to +$30.
	LDA.w !1558,X				;$01AE01	|\ 
	CMP.b #$08					;$01AE04	||
	BNE CODE_01AE5E				;$01AE06	|| Branch if the block is not exactly halfway through the hit animation.
	LDY !C2,X					;$01AE08	||
	CPY.b #$02					;$01AE0A	||
	BEQ CODE_01AE5E				;$01AE0C	|/
	PHA							;$01AE0E	|
	INC !C2,X					;$01AE0F	|
	LDA.b #$50					;$01AE11	|\ Set the sprite spawn timer.
	STA.w !163E,X				;$01AE13	|/
	LDA !E4,X					;$01AE16	|\ 
	STA $9A						;$01AE18	||
	LDA.w !14E0,X				;$01AE1A	||
	STA $9B						;$01AE1D	|| Set the sprite to spawn at the ? block's position.
	LDA !D8,X					;$01AE1F	||
	STA $98						;$01AE21	||
	LDA.w !14D4,X				;$01AE23	||
	STA $99						;$01AE26	|/
	LDA.b #$FF					;$01AE28	|\ Prevent the ? block from respawning.
	STA.w !161A,X				;$01AE2A	|/
	LDY.w !151C,X				;$01AE2D	|\ 
	LDA $19						;$01AE30	||
	BNE CODE_01AE38				;$01AE32	||
	INY							;$01AE34	|| If Mario doesn't have a powerup, increase index by 4.
	INY							;$01AE35	||
	INY							;$01AE36	||
	INY							;$01AE37	|/
CODE_01AE38:					;			|
	LDA.w DATA_01AE88,Y			;$01AE38	|\ Get index for the sprite to spawn from the block.
	STA $05						;$01AE3B	|/
	PHB							;$01AE3D	|
	LDA.b #$02					;$01AE3E	|\ 
	PHA							;$01AE40	||
	PLB							;$01AE41	|| Spawn the sprite.
	PHX							;$01AE42	||
	JSL $02887D					;$01AE43	||
	PLX							;$01AE47	|/
	LDY.w $185E|!addr			;$01AE48	|
	LDA.b #$01					;$01AE4B	|\ Prevent the powerup from appearing behind FG objects while rising.
	STA.w !1528,Y				;$01AE4D	|/
	LDA.b !9E,Y				;$01AE50	|\ 
	CMP.b #$75					;$01AE53	||
	BNE CODE_01AE5C				;$01AE55	|| If spawning the fireflower, set it to stay still on top of the sprite.
	LDA.b #$FF					;$01AE57	||
	STA.w !C2,Y					;$01AE59	|/
CODE_01AE5C:					;			|
	PLB							;$01AE5C	|
	PLA							;$01AE5D	|
CODE_01AE5E:					;			|
	LSR							;$01AE5E	|\ 
	TAY							;$01AE5F	||
	LDA.w DATA_01AE7F,Y			;$01AE60	||
	STA $00						;$01AE63	||
	LDY.w !15EA,X				;$01AE65	|| Handle the bounce animation for the block when hit.
	LDA.w $0301|!addr,Y				;$01AE68	||
	SEC							;$01AE6B	||
	SBC $00						;$01AE6C	||
	STA.w $0301|!addr,Y				;$01AE6E	|/
	LDA !C2,X					;$01AE71	|
	CMP.b #$01					;$01AE73	|
	LDA.b #$2A					;$01AE75	|| Tile to use for the block normally (? block).
	BCC CODE_01AE7B				;$01AE77	|
	LDA.b #$2E					;$01AE79	|| Tile to use when the block is hit (brown block).
CODE_01AE7B:					;			|
	STA.w $0302|!addr,Y				;$01AE7B	|
	RTS							;$01AE7E	|

DATA_01AD68:					;$01AD68	| X/Y speed accelerations for the flying ? block.
	db $FF,$01

DATA_01AD6A:					;$01AD6A	| Maximum Y speeds for the flying ? block.
	db $F4,$0C

DATA_01AD6C:					;$01AD6C	| Maximum X speeds for the flying ? block.
	db $F0,$10

DATA_01AE7F:					;$01AE7F	| How much to shift the flying ? block each frame of its bounce animation.
	db $00,$03,$05,$07,$08,$08,$07,$05
	db $03

DATA_01AE88:					;$01AE88	| Sprites for the flying ? block to spawn, corresponding to $0288A3.
	db $06,$02,$04,$05			; If Mario is big
	db $06,$01,$01,$05			; If Mario is small
	
WingRoutine:					;-----------| Subroutine to draw wings for the flying ? blocks, as well as the actual Yoshi wings.
	LDA !D8,X					;$019E95	|\ 
	PHA							;$019E97	||
	CLC							;$019E98	||
	ADC.b #$02					;$019E99	||
	STA !D8,X					;$019E9B	|| Offset the wings vertically from the sprite.
	LDA.w !14D4,X				;$019E9D	||
	PHA							;$019EA0	||
	ADC.b #$00					;$019EA1	||
	STA.w !14D4,X				;$019EA3	|/
	LDA !E4,X					;$019EA6	|\ 
	PHA							;$019EA8	||
	SEC							;$019EA9	||
	SBC.b #$02					;$019EAA	||
	STA !E4,X					;$019EAC	|| Offset the wings horizontally from the sprite.
	LDA.w !14E0,X				;$019EAE	||
	PHA							;$019EB1	||
	SBC.b #$00					;$019EB2	||
	STA.w !14E0,X				;$019EB4	|/
	LDA.w !15EA,X				;$019EB7	|\ 
	PHA							;$019EBA	||
	CLC							;$019EBB	|| Increase OAM slot.
	ADC.b #$04					;$019EBC	||
	STA.w !15EA,X				;$019EBE	|/
	LDA.w !157C,X				;$019EC1	|\ 
	PHA							;$019EC4	||
	STZ.w !157C,X				;$019EC5	||
	LDA.w !1570,X				;$019EC8	|| 
	LSR							;$019ECB	|| Upload the left wing to OAM.
	LSR							;$019ECC	||
	LSR							;$019ECD	||
	AND.b #$01					;$019ECE	||
	TAY							;$019ED0	||
	JSR LeftWing				;$019ED1	|/
	LDA !E4,X					;$019ED4	|\ 
	CLC							;$019ED6	||
	ADC.b #$04					;$019ED7	||
	STA !E4,X					;$019ED9	|| Offset the right wing.
	LDA.w !14E0,X				;$019EDB	||
	ADC.b #$00					;$019EDE	||
	STA.w !14E0,X				;$019EE0	|/
	LDA.w !15EA,X				;$019EE3	|\ 
	CLC							;$019EE6	|| Increase OAM slot.
	ADC.b #$04					;$019EE7	||
	STA.w !15EA,X				;$019EE9	|/
	INC.w !157C,X				;$019EEC	|\ Upload the right wing to OAM.
	JSR RightWing				;$019EEF	|/
	PLA							;$019EF2	|\ 
	STA.w !157C,X				;$019EF3	||
	PLA							;$019EF6	||
	STA.w !15EA,X				;$019EF7	||
	PLA							;$019EFA	||
	STA.w !14E0,X				;$019EFB	|| Restore the sprite position, direction, and OAM slot.
	PLA							;$019EFE	||
	STA !E4,X					;$019EFF	||
	PLA							;$019F01	||
	STA.w !14D4,X				;$019F02	||
	PLA							;$019F05	||
	STA !D8,X					;$019F06	|/
	RTS							;$019F08	|
	
LeftWing:					;```````````| Generic subroutine to draw wings, ignoring animation frame or ground interaction.
	STY $02						;$019E35	|
RightWing:					;			|
	LDA.w !186C,X				;$019E37	|\ Don't draw if vertically offscreen.
	BNE Return019E94			;$019E3A	|/
	LDA !E4,X					;$019E3C	|
	STA $00						;$019E3E	|
	LDA.w !14E0,X				;$019E40	|
	STA $04						;$019E43	|
	LDA !D8,X					;$019E45	|
	STA $01						;$019E47	|
	LDY.w !15EA,X				;$019E49	|
	PHX							;$019E4C	|
	LDA.w !157C,X				;$019E4D	|
	ASL							;$019E50	|
	ADC $02						;$019E51	|
	TAX							;$019E53	|
	LDA $00						;$019E54	|\ 
	CLC							;$019E56	||
	ADC.w KoopaWingDispXLo,X	;$019E57	||
	STA $00						;$019E5A	||
	LDA $04						;$019E5C	||
	ADC.w KoopaWingDispXHi,X	;$019E5E	|| Upload the wing's X position.
	PHA							;$019E61	||
	LDA $00						;$019E62	||
	SEC							;$019E64	||
	SBC $1A						;$019E65	||
	STA.w $0300|!addr,Y				;$019E67	|/
	PLA							;$019E6A	|\ 
	SBC $1B						;$019E6B	|| Return if horizontally offscreen.
	BNE CODE_019E93				;$019E6D	|/
	LDA $01						;$019E6F	|\ 
	SEC							;$019E71	||
	SBC $1C						;$019E72	|| Upload the wing's Y position.
	CLC							;$019E74	||
	ADC.w KoopaWingDispY,X		;$019E75	||
	STA.w $0301|!addr,Y				;$019E78	|/
	LDA.w KoopaWingTiles,X		;$019E7B	|\ Upload the tile. 
	STA.w $0302|!addr,Y				;$019E7E	|/
	LDA $64						;$019E81	|\ 
	ORA.w KoopaWingGfxProp,X	;$019E83	|| Upload the YXPPCCCT.
	STA.w $0303|!addr,Y				;$019E86	|/
	TYA							;$019E89	|\ 
	LSR							;$019E8A	||
	LSR							;$019E8B	|| Set the tile size.
	TAY							;$019E8C	||
	LDA.w KoopaWingTileSize,X	;$019E8D	||
	STA.w $0460|!addr,Y				;$019E90	|/
CODE_019E93:					;			|
	PLX							;$019E93	|
Return019E94:					;			|
	RTS							;$019E94	|
	
KoopaWingDispXLo:				;$019E10	| X displacements (lo) for the Parakoopa wings.
	db $FF,$F7,$09,$09						; NOTE: This (and all the below tables!) are ALSO used for the flying ? block wings and flying Yoshi wings.

KoopaWingDispXHi:				;$019E14	| X displacements (hi) for the Parakoopa wings.
	db $FF,$FF,$00,$00

KoopaWingDispY:					;$019E18	| Y displacements for the Parakoopa wings.
	db $FC,$F4,$FC,$F4

KoopaWingTiles:					;$019E1C	| Tilemap for the Parakoopa wings.
	db $5D,$C6,$5D,$C6

KoopaWingGfxProp:				;$019E20	| YXPPCCCT for the Parakoopa wings.
	db $46,$46,$06,$06

KoopaWingTileSize:				;$019E24	| Size of the Parakoopa wings tiles (00 = 8x8, 02 = 16x16).
	db $00,$02,$00,$02