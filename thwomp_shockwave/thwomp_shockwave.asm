!SpriteNum = $01 ; this needs to be the sprite number in list.txt of shockwave.cfg
; Extra bit set -> Stuns the player when the thwomp lands
print "INIT", pc
InitThwomp:						;-----------| Thwomp INIT
	LDA !D8,X					;$01AE96	|\ Preserve spawn Y position.
	STA.w !151C,X				;$01AE98	|/
	LDA !E4,X					;$01AE9B	|\ 
	CLC							;$01AE9D	|| Offset X position.
	ADC.b #$08					;$01AE9E	||
	STA !E4,X					;$01AEA0	|/
	RTL							;$01AEA2	|
	
print "MAIN", pc
PHB : PHK : PLB
JSR Thwomp
PLB 
RTL

Return01AEA2:
	RTS
Thwomp:							;-----------| Thwomp MAIN
	JSR ThwompGfx				;$01AEA3	| Draw graphics.
	LDA.w !14C8,X				;$01AEA6	|\ 
	CMP.b #$08					;$01AEA9	||
	BNE Return01AEA2			;$01AEAB	|| Return if dying or the game is frozen.
	LDA $9D						;$01AEAD	||
	BNE Return01AEA2			;$01AEAF	|/
	LDA #$00
	%SubOffScreen()				;$01AEB1	| Process offscreen from -$40 to +$30.
	JSL $01A7DC					;$01AEB4	| Interaction between mario and sprite in X
	LDA !C2,X					;$01AEB7	|
	ASL
	TAX
	JMP (ThwompStatePtrs,X)		;$01AEB9	|

ThwompStatePtrs:				;$01AEBD	| Pointers to the different phases of the Thwomp.
	dw CODE_01AEC3				; 00 - Waiting for Mario
	dw CODE_01AEFA				; 01 - Falling
	dw CODE_01AF24				; 02 - On ground/rising



CODE_01AEC3:					;-----------| Thwomp phase 0 - waiting for Mario
	LDX $15E9|!addr
	LDA.w !186C,X				;$01AEC3	|\ Make the Thwomp always fall if vertically offscreen.
	BNE CODE_01AEEE				;$01AEC6	|/
	LDA.w !15A0,X				;$01AEC8	|\ Never fall if offscreen horizontally.
	BNE Return01AEF9			;$01AECB	|/
	JSR SubHorzPos
	TYA							;$01AED0	|| Keep track of which side Mario is on.
	STA.w !157C,X				;$01AED1	|/
	STZ.w !1528,X				;$01AED4	|\ 
	LDA $0F						;$01AED7	|| Handle the animation frame.
	CLC							;$01AED9	||
	ADC.b #$40					;$01AEDA	||\ Range around the sprite that Mario has to be for the Thwomp to glare at him.
	CMP.b #$80					;$01AEDC	||/
	BCS CODE_01AEE5				;$01AEDE	||
	LDA.b #$01					;$01AEE0	||| Animation frame to use when Mario is close to the Thwomp.
	STA.w !1528,X				;$01AEE2	|/
CODE_01AEE5:					;			|
	LDA $0F						;$01AEE5	|\ Check if Mario is close enough to drop.
	CLC							;$01AEE7	||
	ADC.b #$24					;$01AEE8	||\ Range around the Thwomp that Mario has to be for it to fall.
	CMP.b #$50					;$01AEEA	||/
	BCS Return01AEF9			;$01AEEC	|/
CODE_01AEEE:					;			|
	LDA.b #$02					;$01AEEE	|\\ Animation frame to use when the Thwomp is falling.
	STA.w !1528,X				;$01AEF0	||
	INC !C2,X					;$01AEF3	|| Set the sprite to start falling.
	STZ !AA,x
Return01AEF9:					;			|
	RTS							;$01AEF9	|

SubHorzPos:						;-----------| Subroutine to check horizontal proximity of Mario to a sprite.
	LDY.b #$00					;$01AD30	|  Returns the side in Y (0 = right) and distance in $0F.
	LDA $D1						;$01AD32	|
	SEC							;$01AD34	|
	SBC !E4,X					;$01AD35	|
	STA $0F						;$01AD37	|
	LDA $D2						;$01AD39	|
	SBC.w !14E0,X				;$01AD3B	|
	BPL Return01AD41			;$01AD3E	|
	INY							;$01AD40	|
Return01AD41:					;			|
	RTS							;$01AD41	|

CODE_01AEFA:					;-----------| Thwomp phase 1 - falling
	LDX $15E9|!addr
	JSL $01801A					;$01AEFA	|
	LDA !AA,X					;$01AEFD	| 
	CMP.b #$3E					;$01AEFF	|| Max falling speed for the Thwomp.
	BCS CODE_01AF07				;$01AF01	|
	ADC.b #$04					;$01AF03	|| Acceleration of the Thwomp.
	STA !AA,X					;$01AF05	|
CODE_01AF07:					;			|
	JSL $019138					;$01AF07	|\ 
	LDA.w !1588,X				;$01800E	|
	AND.b #$04					;$018011	|| If the thwomp hasn't hit a block, return.
	BEQ Return01AF23			;$01AF0D	|/
	JSR SetSomeYSpeed			;$01AF0F	| Set ground Y speed.
	LDA.b #$18					;$01AF12	|| Time to shake the screen.
	STA.w $1887|!addr			;$01AF14	|
	%BEC(NoStun)				; Only stun the player if on ground and extra bit set
	LDA $13EF|!addr
	BEQ NoStun
	LDA #$10
	STA $18BD|!addr
	NoStun:
	JSR SpawnShockwave
	LDA.b #$09					;$01AF17	|\ SFX for the Thwomp hitting the ground.
	STA.w $1DFC|!addr			;$01AF19	|/
	LDA.b #$40					;$01AF1C	|| How long to wait on the ground.
	STA.w !1540,X				;$01AF1E	|
	INC !C2,X					;$01AF21	|
Return01AF23:					;			|
	RTS							;$01AF23	|

SpawnShockwave:
	LDA #$08
	STA $00
	JSR Spawn
	BCS Failed
	LDA #$00
	STA !151C,y
	LDA #$F8
	STA $00
	JSR Spawn
	BCS Failed
	LDA #$40
	STA !151C,y
	Failed:
	RTS

Spawn:
	LDA #$10
	STA $01
	STZ $02
	STZ $03
	LDA #!SpriteNum
	SEC
	%SpawnSprite()
	RTS
	
CODE_01AF24:					;-----------| Thwomp phase 2 - on ground/rising
	LDX $15E9|!addr
	LDA.w !1540,X				;$01AF24	|\ Return if waiting on the ground.
	BNE Return01AF3F			;$01AF27	|/
	STZ.w !1528,X				;$01AF29	|
	LDA !D8,X					;$01AF2C	|\ 
	CMP.w !151C,X				;$01AF2E	||
	BNE CODE_01AF38				;$01AF31	|| If the Thwomp reaches its spawn height, return to phase 0.
	STZ !C2,x
	RTS							;$01AF37	|

CODE_01AF38:
	LDA.b #$F0					;$01AF38	|| Speed to rise up at.
	STA !AA,X					;$01AF3A	|
	JSL $01801A					;$01AF3C	|
Return01AF3F:					;			|
	RTS							;$01AF3F	|



ThwompDispX:					;$01AF40	| X position offsets for each of the Thwomp's tiles.
	db $FC,$04,$FC,$04,$00					; Fifth byte is used only when the Thwomp isn't using its normal expression. Same for the below.

ThwompDispY:					;$01AF45	| Y position offsets for each of the Thwomp's tiles.
	db $00,$00,$10,$10,$08

ThwompTiles:					;$01AF4A	| Tile numbers for the Thwomp.
	db $8E,$8E,$AE,$AE,$C8

ThwompGfxProp:					;$01AF4F	| YXPPCCCT for each of the Thwomp's tiles.
	db $03,$43,$03,$43,$03

ThwompGfx:						;-----------| GFX subroutine for the Thwomp.
	%GetDrawInfo()
	LDA.w !1528,X				;$01AF57	|
	STA $02						;$01AF5A	|
	PHX							;$01AF5C	|
	LDX.b #$03					;$01AF5D	|\\ 
	CMP.b #$00					;$01AF5F	||| Upload 4 tiles. If not using the default facial expression, upload a fifth one.
	BEQ CODE_01AF64				;$01AF61	|||
	INX							;$01AF63	||/
CODE_01AF64:					;			||
	LDA $00						;$01AF64	||\ 
	CLC							;$01AF66	|||
	ADC.w ThwompDispX,X			;$01AF67	|||
	STA.w $0300|!addr,Y				;$01AF6A	||| Upload X and Y position.
	LDA $01						;$01AF6D	|||
	CLC							;$01AF6F	|||
	ADC.w ThwompDispY,X			;$01AF70	|||
	STA.w $0301|!addr,Y				;$01AF73	||/
	LDA.w ThwompGfxProp,X		;$01AF76	||\ 
	ORA $64						;$01AF79	||| Upload YXPPCCCT.
	STA.w $0303|!addr,Y				;$01AF7B	||/
	LDA.w ThwompTiles,X			;$01AF7E	||\ 
	CPX.b #$04					;$01AF81	|||
	BNE CODE_01AF8F				;$01AF83	|||
	PHX							;$01AF85	|||
	LDX $02						;$01AF86	||| Upload the tile number.
	CPX.b #$02					;$01AF88	|||
	BNE CODE_01AF8E				;$01AF8A	|||
	LDA.b #$CA					;$01AF8C	|||| Tile number to use for the angry Thwomp's face.
CODE_01AF8E:					;			|||
	PLX							;$01AF8E	|||
CODE_01AF8F:					;			|||
	STA.w $0302|!addr,Y				;$01AF8F	||/
	INY							;$01AF92	||
	INY							;$01AF93	||
	INY							;$01AF94	||
	INY							;$01AF95	||
	DEX							;$01AF96	||
	BPL CODE_01AF64				;$01AF97	|/
	PLX							;$01AF99	|
	LDA.b #$04					;$01AF9A	|\ Draw 5 16x16 tiles.
	LDY.b #$02					;$01B37E	||
	JSL $01B7B3					;$01B380	|/
	RTS


SetSomeYSpeed:					;-----------| Subroutine to set Y speed for a sprite when on the ground.
	LDA.w !1588,X				;$019A04	|\ 
	BMI CODE_019A10				;$019A07	||
	LDA.b #$00					;$019A09	|| 
	LDY.w !15B8,X				;$019A0B	|| If standing on a slope or Layer 2, give the sprite a Y speed of #$18.
	BEQ CODE_019A12				;$019A0E	|| Else, clear its Y speed.
CODE_019A10:					;			||
	LDA.b #$18					;$019A10	||
CODE_019A12:					;			||
	STA !AA,X					;$019A12	|/
	RTS							;$019A14	|