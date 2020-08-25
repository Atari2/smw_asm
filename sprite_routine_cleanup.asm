; this patch redirects all copy pasted routines for sprites for multiple banks (suboffscreen, subhorz/vertpos and getdrawinfo) all to freespace, this leaves a bunch of unused bytes that can be utilized in banks 1, 2 and 3. It also fixes a minor bug related to SubVertPosBnk3
; how many bytes does it save:
	; all the suboffscreens save 0xBF (191) bytes in bank 1 (plus other 20 bytes for the tables at $01AC0D), 0x9B (155) bytes in bank 2 (plus other 20 bytes for the tables at $02D003), 0x95 (149) bytes in bank 3 (plus other 20 bytes for the tables at $03B83B)
	; the subhorzpos save 0x0C (12) bytes in bank 1, 2 and 3
	; the subvertpos save 0x0C (12) bytes in bank 1, 2 and 3, it also fixes a bug where SubVertPosBnk3 returns the wrong scratch ram.
	; getdrawinfo save 0x6E (110) bytes in bank 1 (plus other 4 bytes for the tables at $01A361), 0x66 (102) bytes in bank 2 (plus other 4 bytes for the tables at $02D374), 0x66 (102) bytes in bank 3 (plus other 4 bytes for the tables at $03B75C)
	; this patch frees in total 0x3B9 (953) bytes from banks 1,2,3 of which 0x15D (349) in bank 1, 0x131 (305) in bank 2 and 0x12B (299) in bank 3.

if read1($00FFD5) == $23		; check if the rom is sa-1
	sa1rom
	!SA1 = 1
	!dp = $3000
	!addr = $6000
	!bank = $000000
	!bankA = $4000000
else
	!SA1 = 0
	!dp = $0000
	!addr = $0000
	!bank = $800000
	!bankA = $7E0000
endif

macro define_sprite_table(name, addr, addr_sa1)
	if !SA1 == 0
		!<name> = <addr>
	else
		!<name> = <addr_sa1>
	endif
endmacro

%define_sprite_table("9E", $9E, $3200)
%define_sprite_table("186C", $186C, $7642)
%define_sprite_table("15A0", $15A0, $3376)
%define_sprite_table("D8", $D8, $3216)
%define_sprite_table("E4", $E4, $322C)
%define_sprite_table("15C4", $15C4, $7536)
%define_sprite_table("14C8", $14C8, $3242)
%define_sprite_table("14D4", $14D4, $3258)
%define_sprite_table("14E0", $14E0, $326E)
%define_sprite_table("190F", $190F, $7658)
%define_sprite_table("15EA", $15EA, $33A2)
%define_sprite_table("167A", $167A, $7616)
%define_sprite_table("161A", $161A, $7578)
%define_sprite_table("1938", $1938, $418A00) ;; change the $1938 to $7FAF00 if you've got pixi inserted


org $01AC33|!bank
	autoclean JSL cleanSubOff
	RTS

org $02D027|!bank
	autoclean JSL cleanSubOff
	RTS

org $03B85F|!bank
	autoclean JSL cleanSubOff
	RTS

org $01AD30|!bank
	autoclean JSL cleanSubHorzPos
	RTS

org $02848D|!bank
	autoclean JSL cleanSubHorzPos
	RTS

org $03B817|!bank
	autoclean JSL cleanSubHorzPos
	RTS

org $01AD42|!bank
	autoclean JSL cleanSubVertPos
	RTS

org $02D50C|!bank
	autoclean JSL cleanSubVertPos
	RTS

org $03B829|!bank
	autoclean JSL cleanSubVertPos
	RTS

org $01A365|!bank
	autoclean JSL cleanGetDrawInfo
	CPY #$FF
	BNE +
	PLA : PLA
	+
	RTS

org $02D378|!bank
	autoclean JSL cleanGetDrawInfo
	CPY #$FF
	BNE +
	PLA : PLA
	+
	RTS

org $03B760|!bank
	autoclean JSL cleanGetDrawInfo
	CPY #$FF
	BNE +
	PLA : PLA
	+
	RTS

freecode

cleanGetDrawInfo:
	PHB : PHK : PLB
	JSR GetDrawInfo
	PLB
	RTL

GetDrawInfo:
	STZ.w !186C,X				;|\ Initialize offscreen flags.
	STZ.w !15A0,X				;|/
	LDA !E4,X					;|\
	CMP $1A						;||
	LDA.w !14E0,X				;|| Check if offscreen horizontally, and set the flag if so.
	SBC $1B						;||
	BEQ CODE_01A379				;||
	INC.w !15A0,X				;|/
CODE_01A379:					;|
	LDA.w !14E0,X				;|\
	XBA							;||
	LDA !E4,X					;||
	REP #$20					;||
	SEC							;||
	SBC $1A						;||
	CLC							;|| Handle horizontal offscreen flag for 4 tiles offscreen. (-40 to +40)
	ADC.w #$0040				;||  If so, return the sprite's graphical routine.
	CMP.w #$0180				;||
	SEP #$20					;||
	ROL							;||
	AND.b #$01					;||
	STA.w !15C4,X				;||
	BNE CODE_01A3CB				;|/
	LDY.b #$00					;|\
	LDA.w !14C8,X				;||
	CMP.b #$09					;||
	BEQ CODE_01A3A6				;||
	LDA.w !190F,X				;||
	AND.b #$20					;||
	BEQ CODE_01A3A6				;||
	INY							;||
CODE_01A3A6:					;||
	LDA $03,s					;|| read bank
	CMP #$01					;|| if bank == 01
	BNE .notBank1
	LDA !D8,X					;||
	CLC							;||
	ADC.w DATA_01A361,Y			;|| Check if vertically offscreen, and set the flag if so.
	BRA .continue
	.notBank1
	LDA !D8,X					;||
	CLC							;||
	ADC.w DATA_02D374,Y			;|| Check if vertically offscreen, and set the flag if so.
	.continue
	PHP							;||  If the sprite has a two-tile death frame, $186C's bits will be set for each tile.
	CMP $1C						;||  Top tile = bit 0
	ROL $00						;||  Bottom tile = bit 1
	PLP							;||
	LDA.w !14D4,X				;||
	ADC.b #$00					;||
	LSR $00						;||
	SBC $1D						;||
	BEQ CODE_01A3C6				;||
	LDA.w !186C,X				;||
	ORA.w DATA_01A363,Y			;||
	STA.w !186C,X				;||
CODE_01A3C6:					;||
	DEY							;||
	BPL CODE_01A3A6				;|/
	LDY.w !15EA,X				;|\
	LDA !E4,X					;||
	SEC							;||
	SBC $1A						;||
	STA $00						;|| Return onscreen position in $00 and $01, and OAM index in Y.
	LDA !D8,X					;||
	SEC							;||
	SBC $1C						;||
	STA $01						;|/
	RTS							;|


CODE_01A3CB:					;| Sprite more than 4 tiles offscreen.
	LDY #$FF
	RTS

DATA_01A361:					;| Y position offsets to the bottom of a sprite, for checking if offscreen.
	db $10,$20

DATA_01A363:					;| Bits to set in $186C, for each tile of a two-tile sprite.
	db $01,$02

DATA_02D374:					;| Y position offsets to the bottom of a sprite, for checking if offscreen.
	db $0C,$1C

cleanSubVertPos:				;| Subroutine to check vertical proximity of Mario to a sprite.
	LDY.b #$00					;|  Returns the side in Y (0 = below) and distance in $0E.
	PHB : PLA
	CMP #$01
	BEQ .inBank1
	BRA .notBank1
	.inBank1:
	LDA $D4 : PHA
	LDA $D3						;|
	BRA .subVertPos
	.notBank1:
	LDA $97 : PHA
	LDA $96
	.subVertPos
	SEC							;|
	SBC !D8,X					;|
	STA $0E						;|
	PLA						;|
	SBC.w !14D4,X				;|
	BPL .return					;|
	INY							;|
.return:						;|
	RTL							;|

cleanSubHorzPos:
	LDY #$00
	PHB : PLA
	CMP #$01
	BEQ .inBank1
	BRA .notBank1
	.inBank1
	LDA $D2 : PHA
	LDA $D1
	BRA .subHorzPos
	.notBank1
	LDA $95 : PHA
	LDA $94
	.subHorzPos
	SEC							;|
	SBC !E4,X					;|
	STA $0F						;|
	PLA							;|
	SBC.w !14E0,X				;|
	BPL .return					;|
	INY							;|
	.return
	RTL

cleanSubOff:
	PHB : PHK : PLB
	LDA $01,s
	DEC
	ASL
	PHX
	TAX
	JSR (SubOffScreenPtr,x)
	PLX
	PLB
	RTL
SubOffScreenPtr:
	dw SubOffScreenBnk1
	dw SubOffScreenBnk2
	dw SubOffScreenBnk3

SubOffScreenBnk1:					;			|
	LDX $15E9|!addr
	JSR IsSprOffScreen			;$01AC33	|\ Return if not offscreen.
	BEQ Return01ACA4			;$01AC36	|/
	LDA $5B						;$01AC38	|\
	AND.b #$01					;$01AC3A	|| Branch if in a vertical level.
	BNE OffscreenVertBnk1		;$01AC3C	|/
	LDA !D8,X					;$01AC3E	|\
	CLC							;$01AC40	||
	ADC.b #$50					;$01AC41	|| Erase the sprite if below the level.
	LDA.w !14D4,X				;$01AC43	||
	ADC.b #$00					;$01AC46	||
	CMP.b #$02					;$01AC48	||
	BPL OffScrEraseSprite		;$01AC4A	|/
	LDA.w !167A,X				;$01AC4C	|\
	AND.b #$04					;$01AC4F	|| Return if set to process offscreen.
	BNE Return01ACA4			;$01AC51	|/
	LDA $13						;$01AC53	|\
	AND.b #$01					;$01AC55	||
	ORA $03						;$01AC57	||
	STA $01						;$01AC59	||
	TAY							;$01AC5B	||
	LDA $1A						;$01AC5C	||
	CLC							;$01AC5E	||
	ADC.w SpriteOffScreen3,Y	;$01AC5F	||
	ROL $00						;$01AC62	||
	CMP !E4,X					;$01AC64	|| Check if within the horizontal bounds specified by the routine call. Alternates sides each frame.
	PHP							;$01AC66	||  If it is within the bounds (i.e. onscreen), return.
	LDA $1B						;$01AC67	||
	LSR $00						;$01AC69	||
	ADC.w SpriteOffScreen4,Y	;$01AC6B	||
	PLP							;$01AC6E	||
	SBC.w !14E0,X				;$01AC6F	||
	STA $00						;$01AC72	||
	LSR $01						;$01AC74	||
	BCC CODE_01AC7C				;$01AC76	||
	EOR.b #$80					;$01AC78	||
	STA $00						;$01AC7A	||
CODE_01AC7C:					;			||
	LDA $00						;$01AC7C	||
	BPL Return01ACA4			;$01AC7E	|/
OffScrEraseSprite:				;```````````| Subroutine to erase a sprite when offscreen.
	LDA !9E,X					;$01AC80	|\
	CMP.b #$1F					;$01AC82	||
	BNE CODE_01AC8E				;$01AC84	|| If sprite 1F (MagiKoopa), just make
	STA.w $18C1|!addr					;$01AC86	|| it look for a new position again.
	LDA.b #$FF					;$01AC89	||
	STA.w $18C0|!addr					;$01AC8B	|/
CODE_01AC8E:					;			|
	LDA.w !14C8,X				;$01AC8E	|\
	CMP.b #$08					;$01AC91	||
	BCC OffScrKillSprite		;$01AC93	||
	LDY.w !161A,X				;$01AC95	||
	CPY.b #$FF					;$01AC98	|| Erase the sprite.
	BEQ OffScrKillSprite		;$01AC9A	||  If it wasn't killed, set it to respawn.
	LDA.b #$00					;$01AC9C	||
	STA.w !1938,Y				;$01AC9E	||
OffScrKillSprite:				;			||
	STZ.w !14C8,X				;$01ACA1	|/
Return01ACA4:					;			|
	RTS							;$01ACA4	|

OffscreenVertBnk1:				;```````````| Offscreen routine for a vertical level.
	LDA.w !167A,X				;$01ACA5	|\
	AND.b #$04					;$01ACA8	|| Return if set to process offscreen.
	BNE Return01ACA4			;$01ACAA	|/
	LDA $13						;$01ACAC	|\
	LSR							;$01ACAE	|| Process every other frame.
	BCS Return01ACA4			;$01ACAF	|/
	LDA !E4,X					;$01ACB1	|\
	CMP.b #$00					;$01ACB3	||
	LDA.w !14E0,X				;$01ACB5	|| Erase the sprite if of either side of the level.
	SBC.b #$00					;$01ACB8	||
	CMP.b #$02					;$01ACBA	||
	BCS OffScrEraseSprite		;$01ACBC	|/
	LDA $13						;$01ACBE	|\
	LSR							;$01ACC0	||
	AND.b #$01					;$01ACC1	||
	STA $01						;$01ACC3	||
	TAY							;$01ACC5	||
	BEQ CODE_01ACD2				;$01ACC6	||
	LDA !9E,X					;$01ACC8	||
	CMP.b #$22					;$01ACCA	||
	BEQ Return01ACA4			;$01ACCC	||
	CMP.b #$24					;$01ACCE	||
	BEQ Return01ACA4			;$01ACD0	||
CODE_01ACD2:					;			||
	LDA $1C						;$01ACD2	|| Check if within the vertical bounds of the screen. Alternates sides each frame.
	CLC							;$01ACD4	||  If it is within the bounds (i.e. onscreen), return.
	ADC.w SpriteOffScreen1,Y	;$01ACD5	||
	ROL $00						;$01ACD8	|| Sprite 22 and sprite 24 (green net Koopas) will not despawn off the top of the screen.
	CMP !D8,X					;$01ACDA	||  (was probably intended to sprite 23 instead of 24)
	PHP							;$01ACDC	||
	LDA.w $1D					;$01ACDD	||
	LSR $00						;$01ACE0	||
	ADC.w SpriteOffScreen2,Y	;$01ACE2	||
	PLP							;$01ACE5	||
	SBC.w !14D4,X				;$01ACE6	||
	STA $00						;$01ACE9	||
	LDY $01						;$01ACEB	||
	BEQ CODE_01ACF3				;$01ACED	||
	EOR.b #$80					;$01ACEF	||
	STA $00						;$01ACF1	||
CODE_01ACF3:					;			||
	LDA $00						;$01ACF3	||
	BPL Return01ACA4			;$01ACF5	||
	BMI OffScrEraseSprite		;$01ACF7	|/

SubOffScreenBnk2:					;			|
	LDX $15E9|!addr
	JSR IsSprOffScreen		;$02D027	|\ Return if not offscreen.
	BEQ Return02D090			;$02D02A	|/
	LDA $5B						;$02D02C	|\
	AND.b #$01					;$02D02E	|| Branch if in a vertical level.
	BNE OffscreenVertBnk2		;$02D030	|/
	LDA $03						;$02D032	|\
	CMP.b #$04					;$02D034	|| Don't erase below the level if using SubOffscreenX4 (for the mushroom scale platforms).
	BEQ CODE_02D04D				;$02D036	|/
	LDA !D8,X					;$02D038	|\
	CLC							;$02D03A	||
	ADC.b #$50					;$02D03B	|| Erase the sprite if below the level.
	LDA.w !14D4,X				;$02D03D	||
	ADC.b #$00					;$02D040	||
	CMP.b #$02					;$02D042	||
	BPL OffScrEraseSprBnk2		;$02D044	|/
	LDA.w !167A,X				;$02D046	|\
	AND.b #$04					;$02D049	|| Return if set to process offscreen.
	BNE Return02D090			;$02D04B	|/
CODE_02D04D:					;			|
	LDA $13						;$03D04D	|\
	AND.b #$01					;$02D04F	||
	ORA $03						;$02D051	||
	STA $01						;$02D053	||
	TAY							;$02D055	||
	LDA $1A						;$02D056	||
	CLC							;$02D058	||
	ADC.w DATA_02D007,Y			;$02D059	||
	ROL $00						;$02D05C	||
	CMP !E4,X					;$02D05E	|| Check if within the horizontal bounds specified by the routine call. Alternates sides each frame.
	PHP							;$02D060	||  If it is within the bounds (i.e. onscreen), return.
	LDA $1B						;$02D061	||
	LSR $00						;$02D063	||
	ADC.w DATA_02D00F,Y			;$02D065	||
	PLP							;$02D068	||
	SBC.w !14E0,X				;$02D069	||
	STA $00						;$02D06C	||
	LSR $01						;$02D06E	||
	BCC CODE_02D076				;$02D070	||
	EOR.b #$80					;$02D072	||
	STA $00						;$02D074	||
CODE_02D076:					;			||
	LDA $00						;$02D076	||
	BPL Return02D090			;$02D078	|/
OffScrEraseSprBnk2:				;```````````| Subroutine to erase a sprite when offscreen.
	LDA.w !14C8,X				;$02D07A	|\
	CMP.b #$08					;$02D07D	||
	BCC OffScrKillSprBnk2		;$02D07F	||
	LDY.w !161A,X				;$02D081	||
	CPY.b #$FF					;$02D084	|| Erase the sprite.
	BEQ OffScrKillSprBnk2		;$02D086	||  If it wasn't killed, set it to respawn.
	LDA.b #$00					;$02D088	||
	STA.w !1938,Y				;$02D08A	||
OffScrKillSprBnk2:				;			||
	STZ.w !14C8,X				;$02D08D	|/
Return02D090:					;			|
	RTS							;$02D090	|

OffscreenVertBnk2:				;```````````| Offscreen routine for a vertical level.
	LDA.w !167A,X				;$02D091	|\
	AND.b #$04					;$02D094	|| Return if set to process offscreen.
	BNE Return02D090			;$02D096	|/
	LDA $13						;$02D098	|\
	LSR							;$02D09A	||
	BCS Return02D090			;$02D09B	||
	AND.b #$01					;$02D09D	||
	STA $01						;$02D09F	||
	TAY							;$02D0A1	||
	LDA $1C						;$02D0A2	||
	CLC							;$02D0A4	||
	ADC.w DATA_02D003,Y			;$02D0A5	||
	ROL $00						;$02D0A8	|| Check if within the vertical bounds specified by the routine call. Alternates sides each frame.
	CMP !D8,X					;$02D0AA	||  If it is within the bounds (i.e. onscreen), return.
	PHP							;$02D0AC	||
	LDA.w $1D					;$02D0AD	||
	LSR $00						;$02D0B0	||
	ADC.w DATA_02D005,Y			;$02D0B2	||
	PLP							;$02D0B5	||
	SBC.w !14D4,X				;$02D0B6	||
	STA $00						;$02D0B9	||
	LDY $01						;$02D0BB	||
	BEQ CODE_02D0C3				;$02D0BD	||
	EOR.b #$80					;$02D0BF	||
	STA $00						;$02D0C1	||
CODE_02D0C3:					;			||
	LDA $00						;$02D0C3	||
	BPL Return02D090			;$02D0C5	||
	BMI OffScrEraseSprBnk2		;$02D0C7	|/

IsSprOffScreen:				;```````````| Returns with a value indicating whether the sprite is offscreen or not.
	LDA.w !15A0,X				;$02D0C9	|
	ORA.w !186C,X				;$02D0CC	|
	RTS							;$02D0CF	|

SubOffScreenBnk3:					;			|
	LDX $15E9|!addr
	JSR IsSprOffScreen		;$03B85F	|
	BEQ Return03B8C2			;$03B862	|
	LDA $5B						;$03B864	|
	AND.b #$01					;$03B866	|
	BNE OffscreenVertBnk3		;$03B868	|
	LDA !D8,X					;$03B86A	|
	CLC							;$03B86C	|
	ADC.b #$50					;$03B86D	|
	LDA.w !14D4,X				;$03B86F	|
	ADC.b #$00					;$03B872	|
	CMP.b #$02					;$03B874	|
	BPL OffScrEraseSprBnk3		;$03B876	|
	LDA.w !167A,X				;$03B878	|
	AND.b #$04					;$03B87B	|
	BNE Return03B8C2			;$03B87D	|
	LDA $13						;$03B87F	|
	AND.b #$01					;$03B881	|
	ORA $03						;$03B883	|
	STA $01						;$03B885	|
	TAY							;$03B887	|
	LDA $1A						;$03B888	|
	CLC							;$03B88A	|
	ADC.w DATA_03B83F,Y			;$03B88B	|
	ROL $00						;$03B88E	|
	CMP !E4,X					;$03B890	|
	PHP							;$03B892	|
	LDA $1B						;$03B893	|
	LSR $00						;$03B895	|
	ADC.w DATA_03B847,Y			;$03B897	|
	PLP							;$03B89A	|
	SBC.w !14E0,X				;$03B89B	|
	STA $00						;$03B89E	|
	LSR $01						;$03B8A0	|
	BCC CODE_03B8A8				;$03B8A2	|
	EOR.b #$80					;$03B8A4	|
	STA $00						;$03B8A6	|
CODE_03B8A8:					;			|
	LDA $00						;$03B8A8	|
	BPL Return03B8C2			;$03B8AA	|
OffScrEraseSprBnk3:				;			|
	LDA.w !14C8,X				;$03B8AC	|
	CMP.b #$08					;$03B8AF	|
	BCC OffScrKillSprBnk3		;$03B8B1	|
	LDY.w !161A,X				;$03B8B3	|
	CPY.b #$FF					;$03B8B6	|
	BEQ OffScrKillSprBnk3		;$03B8B8	|
	LDA.b #$00					;$03B8BA	|
	STA.w !1938,Y				;$03B8BC	|
OffScrKillSprBnk3:				;			|
	STZ.w !14C8,X				;$03B8BF	|
Return03B8C2:					;			|
	RTS							;$03B8C2	|

OffscreenVertBnk3:
	LDA.w !167A,X				;$03B8C3	|
	AND.b #$04					;$03B8C6	|
	BNE Return03B8C2			;$03B8C8	|
	LDA $13						;$03B8CA	|
	LSR							;$03B8CC	|
	BCS Return03B8C2			;$03B8CD	|
	AND.b #$01					;$03B8CF	|
	STA $01						;$03B8D1	|
	TAY							;$03B8D3	|
	LDA $1C						;$03B8D4	|
	CLC							;$03B8D6	|
	ADC.w DATA_03B83B,Y			;$03B8D7	|
	ROL $00						;$03B8DA	|
	CMP !D8,X					;$03B8DC	|
	PHP							;$03B8DE	|
	LDA.w $1D					;$03B8DF	|
	LSR $00						;$03B8E2	|
	ADC.w DATA_03B83D,Y			;$03B8E4	|
	PLP							;$03B8E7	|
	SBC.w !14D4,X				;$03B8E8	|
	STA $00						;$03B8EB	|
	LDY $01						;$03B8ED	|
	BEQ CODE_03B8F5				;$03B8EF	|
	EOR.b #$80					;$03B8F1	|
	STA $00						;$03B8F3	|
CODE_03B8F5:					;			|
	LDA $00						;$03B8F5	|
	BPL Return03B8C2			;$03B8F7	|
	BMI OffScrEraseSprBnk3		;$03B8F9	|

DATA_03B83B:
SpriteOffScreen1:
DATA_02D003:					;$02D003	| Low bytes of the vertical offscreen processing distances in bank 2.
	db $40,$B0

DATA_03B83D:
SpriteOffScreen2:
DATA_02D005:					;$02D005	| High bytes of the vertical offscreen processing distances in bank 2.
	db $01,$FF


SpriteOffScreen3:				;$01AC11	| Low bytes of the horizontal offscreen processing distances.
	db $30,$C0,$A0,$C0,$A0,$F0,$60,$90

DATA_02D007:					;$03D007	| Low bytes for offscreen processing distances in bank 2.
	db $30,$C0,$A0,$C0,$A0,$70,$60,$B0

DATA_03B83F:					;$03B83F	| Low bytes for offscreen processing distances in bank 03.
	db $30,$C0,$A0,$80,$A0,$40,$60,$B0

DATA_03B847:
SpriteOffScreen4:
DATA_02D00F:					;$02D00F	| High bytes for offscreen processing distances in bank 2.
	db $01,$FF,$01,$FF,$01,$FF,$01,$FF
