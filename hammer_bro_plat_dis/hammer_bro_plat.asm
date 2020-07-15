;hammer bro platform , sprite 9C
;taken from smw-irq by Atari2.0. Original disassembly of SMW made by p4plus2 and commented by p4plus2 and kaizoman
	; Flying Hammer Bro. platform misc RAM:
	; $C2   - When the platform is hit from below, this indicates which of the two blocks was hit. 1 = left, 2 = right.
	; $151C - Direction of vertical acceleration. Even = +, odd = -
	; $1528 - Number of pixels moved horizontally in the frame.
	; $1534 - Direction of horizontal acceleration. Even = +, odd = -
	; $1558 - Timer for the bounce animation when the platform is hit from below.
	; $1594 - Slot of the Hammer Bro. riding the platform. #$FF if there is none.
	; $1510 - Has mario touched the Platform already check, 00 if not, 01 if yes
if defined("addr") == 0			;check if !addr exists (added in pixi 1.2.10), needs it for sa-1 compatibility
	if read1($00FFD5) == $23
		!addr = $6000
	else
		!addr = $0000
	endif 
endif
	
incsrc "hammer_bro_plat_tables.asm"
print "INIT ", pc

HammerPlatformInit:
	LDA #$00
	STA !1510,X
	RTL 

print "MAIN ", pc

PltformMainWrap:
	PHB							;$02DB4C	|
	PHK							;$02DB4D	|
	PLB							;$02DB4E	|
	JSR PltformMain				;$02DB4F	|
	PLB							;$02DB52	|
	RTL							;$02DB53	|
	
	
PltformMain:					;-----------| Flying Hammer Bro. platform MAIN
	JSR FlyingPlatformGfx		;$02DB5C	| Draw graphics.
	LDA.b #$FF					;$02DB5F	|\ 
	STA.w !1594,X				;$02DB61	||
	LDY.b #$09					;$02DB64	||
CODE_02DB9E:					;```````````| No Hammer Bro. found.
	LDA $9D						;$02DB9E	|\ Return if game frozen.
	BNE Return02DC0E			;$02DBA0	|/
	LDA #$01
	%SubOffScreen()             ;$02DBA2	| Process offscreen from -$40 to +$A0.
	JSL $01A7DC					;  			check for contact between mario and the current sprite
	BCC .skip
	LDA #$01
	STA !1510,X
	.skip
	LDA $13						;$02DBA5	|\ 
	AND.b #$01					;$02DBA7	|| Update X/Y speed every other frame.
	BNE CODE_02DBD7				;$02DBA9	||
	LDA.w !1534,X				;$02DBAB	||\ 
	AND.b #$01					;$02DBAE	|||
	TAY							;$02DBB0	|||
	LDA !B6,X					;$02DBB1	|||
	CLC							;$02DBB3	||| Handle horizontal acceleration.
	ADC.w DATA_02DB54,Y			;$02DBB4	|||
	STA !B6,X					;$02DBB7	|||
	CMP.w DATA_02DB56,Y			;$02DBB9	|||
	BNE CODE_02DBC1				;$02DBBC	|||
	INC.w !1534,X				;$02DBBE	||/
CODE_02DBC1:					;			||
	LDA.w !151C,X				;$02DBC1	||\ 
	AND.b #$01					;$02DBC4	|||
	TAY							;$02DBC6	|||
	LDA !AA,X					;$02DBC7	|||
	CLC							;$02DBC9	||| Handle vertical acceleration.
	ADC.w DATA_02DB58,Y			;$02DBCA	|||
	STA !AA,X					;$02DBCD	|||
	CMP.w DATA_02DB5A,Y			;$02DBCF	|||
	BNE CODE_02DBD7				;$02DBD2	|||
	INC.w !151C,X				;$02DBD4	|//
CODE_02DBD7:					;			|
	LDA !1510,X
	BEQ .notmove
	JSL $01801A					;$02DBD7	|\ Update X/Y position.
	.notmove
	JSL $018022					;$02DBDA	|/
	STA.w !1528,X				;$02DBDD	|\ Make solid.
	JSL $01B44F					;$02DBE0	|/
	LDA.w !1558,X				;$02DBE4	|\ Return if the block wasn't hit from below.
	BEQ Return02DC0E			;$02DBE7	|/
	LDA.b #$01					;$02DBE9	|\ 
	STA !C2,X					;$02DBEB	||
	JSR CODE_02D4FA				;$02DBED	||
	LDA $0F						;$02DBF0	|| Track which of the blocks in the platform that Mario is hitting.
	CMP.b #$08					;$02DBF2	||
	BMI CODE_02DBF8				;$02DBF4	||
	INC !C2,X					;$02DBF6	|/
CODE_02DBF8:					;			|
	LDY.w !1594,X				;$02DBF8	|\ Return if there isn't a Hammer Bro. on the platform.
	BMI Return02DC0E			;$02DBFB	|/
	LDA.b #$02					;$02DBFD	|\ 
	STA.w !14C8,Y				;$02DBFF	|| Kill the Hammer Bro.
	LDA.b #$C0					;$02DC02	||| Y speed to give the Hammer Bro. when killed by hitting the platform from below.
	STA !AA,Y				;$02DC04	|/
	PHX							;$02DC07	|
	TYX							;$02DC08	|
	JSL $01AB6F					;$02DC09	| Display a contact sprite on the Hammer Bro.
	PLX							;$02DC0D	|
Return02DC0E:					;			|
	RTS							;$02DC0E	|

FlyingPlatformGfx:				;-----------| Flying turnblock platform GFX routine.
	%GetDrawInfo()  			;$02DC3F	|
	LDA !C2,X					;$02DC42	|\ $07 = which block of the platform has been hit from below, if any.
	STA $07						;$02DC44	|/
	LDA.w !1558,X				;$02DC46	|\ 
	LSR							;$02DC49	||
	TAY							;$02DC4A	|| $05 = current vertical offset for said hit block.
	LDA.w DATA_02DC37,Y			;$02DC4B	||
	STA $05						;$02DC4E	|/
	LDY.w !15EA,X				;$02DC50	|
	PHX							;$02DC53	|
	LDA $14						;$02DC54	|\ 
	LSR							;$02DC56	|| $02 = index to the animation tables, for the wings animation
	AND.b #$04					;$02DC57	||
	STA $02						;$02DC59	|/
	LDX.b #$03					;$02DC5B	|| Number of tiles to draw.
CODE_02DC5D:					;			|
	STX $06						;$02DC5D	|
	TXA							;$02DC5F	|\ 
	ORA $02						;$02DC60	||
	TAX							;$02DC62	||
	LDA $00						;$02DC63	|| Store X position to OAM.
	CLC							;$02DC65	||
	ADC.w DATA_02DC0F,X			;$02DC66	||
	STA.w $0300|!addr,Y				;$02DC69	|/
	LDA $01						;$02DC6C	|\ 
	CLC							;$02DC6E	||
	ADC.w DATA_02DC17,X			;$02DC6F	||
	STA.w $0301|!addr,Y				;$02DC72	||
	PHX							;$02DC75	||
	LDX $06						;$02DC76	||
	CPX.b #$02					;$02DC78	|| Store Y position to OAM.
	BCS CODE_02DC8A				;$02DC7A	||  If the block was hit from below, animate its bounce.
	INX							;$02DC7C	||
	CPX $07						;$02DC7D	||
	BNE CODE_02DC8A				;$02DC7F	||
	LDA.w $0301|!addr,Y				;$02DC81	||
	SEC							;$02DC84	||
	SBC $05						;$02DC85	||
	STA.w $0301|!addr,Y				;$02DC87	|/
CODE_02DC8A:					;			|
	PLX							;$02DC8A	|
	LDA.w HmrBroPlatTiles,X		;$02DC8B	|\ Store tile number to OAM.
	STA.w $0302|!addr,Y				;$02DC8E	|/
	LDA.w DATA_02DC27,X			;$02DC91	|\ Store YXPPCCCT to OAM.
	STA.w $0303|!addr,Y				;$02DC94	|/
	PHY							;$02DC97	|
	TYA							;$02DC98	|\ 
	LSR							;$02DC99	||
	LSR							;$02DC9A	|| Store size to OAM.
	TAY							;$02DC9B	||
	LDA.w DATA_02DC2F,X			;$02DC9C	||
	STA.w $0460|!addr,Y				;$02DC9F	|/
	PLY							;$02DCA2	|
	INY							;$02DCA3	|\ 
	INY							;$02DCA4	||
	INY							;$02DCA5	||
	INY							;$02DCA6	|| Loop for all of the tiles.
	LDX $06						;$02DCA7	||
	DEX							;$02DCA9	||
	BPL CODE_02DC5D				;$02DCAA	|/
	JMP CODE_02DB44				;$02DCAC	| Uplaod 4 manually-sized tiles. This JMP is useless
	
	;;JSR'd subroutines
	
CODE_02D4FA:					;-----------| Subroutine to check which side of the sprite Mario is on (duplicate of SubHorzPosBnk2). Returns Y: 00 = right, 01 = left.
	LDY.b #$00					;$02D4FA	|
	LDA $94						;$02D4FC	|
	SEC							;$02D4FE	|
	SBC !E4,X					;$02D4FF	|
	STA $0F						;$02D501	|
	LDA $95						;$02D503	|
	SBC.w !14E0,X				;$02D505	|
	BPL Return02D50B			;$02D508	|
	INY							;$02D50A	|
Return02D50B:					;			|
	RTS							;$02D50B	|
	
CODE_02DB44:					;			|
	PLX							;$02DB44	|
	LDY.b #$FF					;$02DB45	|\ 
	LDA.b #$03					;$02DB47	|| Upload 4 manually-sized tiles to OAM.
	JSL $01B7B3					;$02DB49	|/ JSL to FinishOAMWrite
	RTS