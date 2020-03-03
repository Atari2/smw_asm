; Para-Goomba/Bomb misc RAM:
	; $C2   - Swing direction (odd = left, even = right)
	; $151C - Flag for having hit the side of a block. When set, the sprite locks its animation and sinks straight down.
	; $1540 - Timer after landing for the parachute to decend.
	; $1570 - Current "angle" (max #$0F)
	; $157C - Horizontal direction the sprite is facing.
	; $1602 - Current animation frame for the parachute. 0 = normal, 1 = tilt left, 2 = tilt right
	;          For the parachute's subroutine, values are C (normal) and D (tilted).
	;
incsrc "parachute_chuck_tables.asm"

print "INIT ",pc
ParachuteChuckInit:
	RTL


print "MAIN ",pc
ParachuteChuckWrap:				;| MAIN Wrapper
	PHB							;|
	PHK							;|
	PLB							;|
	JSR ParachuteChuck			;|
	PLB							;|
	RTL		

ParachuteChuck:					;-----------| Para-Goomba MAIN / Para-Bomb MAIN
	LDA.w $14C8,X				;|\ 
	CMP.b #$08					;|| Skip to graphics if dead.
	BEQ MainSprite				;||
	JMP ChangeSprite			;|/

MainSprite:
	LDA $9D						;|\ 
	BNE SkipToGfx				;|| Skip movement if game frozen or landing on the ground.
	LDA.w $1540,X				;||
	BNE SkipToGfx				;|/
	LDA $13						;|\ 
	LSR							;||
	BCC SkipSomeMovement		;|| Move downwards one pixel every two frames.
	INC $D8,X					;||
	BNE SkipSomeMovement		;||
	INC.w $14D4,X				;|/
SkipSomeMovement:				;|
	LDA.w $151C,X				;|\ Skip horizontal movement if the sprite hit a wall.
	BNE SkipToGfx				;|/
	LDA $13						;|\ 
	LSR							;||
	BCC UpdateXPos				;||
	LDA $C2,X					;||
	AND.b #$01					;||
	TAY							;|| Every two frames, increase/decrease the current angle.
	LDA.w $1570,X				;|| If at the maximum, invert direction of movement.
	CLC							;||
	ADC.w DATA_01D4E7,Y			;||
	STA.w $1570,X				;||
	CMP.w DATA_01D4E9,Y			;||
	BNE UpdateXPos				;||
	INC $C2,X					;|/
UpdateXPos:						;	
	LDA $B6,X					;|\ 
	PHA							;||
	LDY.w $1570,X				;||
	LDA $C2,X					;||
	LSR							;||
	LDA.w DATA_01D4EB,Y			;||
	BCC SkipUpdateXPos			;||
	EOR.b #$FF					;|| Update X position, using the angle and current direction to find the X speed.
	INC A						;||
SkipUpdateXPos:					;||
	CLC							;||
	ADC $B6,X					;||
	STA $B6,X					;||
	JSL $018022					;||
	PLA							;||
	STA $B6,X					;|/

SkipToGfx:						;| Handle the parachute's graphics.
	LDA #$00	                ;
	%SubOffScreen()				;| Process offscreen from -$40 to +$30.
								;
Graphics:						;| Parachute sprite GFX routine.
	STZ.w $185E					;\\ 
	LDY.b #$F0					;||
	LDA.w $1540,X				;||
	BEQ SkipToDraw				;||
	LSR							;||
	EOR.b #$0F					;||
	STA.w $185E					;||
	CLC							;||
	ADC.b #$F0					;|| Get vertical position for the parachute.
	TAY							;|| Normally one tile above the sprite;
SkipToDraw:						;||  when landing, sinks into it instead.
	STY $00						;||
	LDA $D8,X					;||
	PHA							;||
	CLC							;||
	ADC $00						;||
	STA $D8,X					;||
	LDA.w $14D4,X				;||
	PHA							;||
	ADC.b #$FF					;||
	STA.w $14D4,X				;|/
	LDA.w $15F6,X				;|\ 
	PHA							;|| Set the parachute's palette.
	AND.b #$F1					;||
	ORA.b #$06					;||| Palette to use.
	STA.w $15F6,X				;|/
	LDY.w $1570,X				;|\ 
	LDA.w DATA_01D55E,Y			;|| Get animation frame/direction for the parachute.
	STA.w $1602,X				;||  0C = normal, 0D = tilted.
	LDA.w DATA_01D56E,Y			;||
	STA.w $157C,X				;|/
	JSL $0190B2					;|] Draw a 16x16 tile.
	PLA							;||
	STA.w $15F6,X				;|/
	LDA.w $15EA,X				;|
	CLC							;|
	ADC.b #$04					;|
	STA.w $15EA,X				;|
	LDY.w $1570,X				;|\ 
	LDA $E4,X					;|\ 
	PHA							;||
	CLC							;||
	ADC.w DATA_01D57E,Y			;||
	STA $E4,X					;|| Get horizontal position for the Goomba/Bob-omb.
	LDA.w $14E0,X				;||
	PHA							;||
	ADC.w DATA_01D58E,Y			;||
	STA.w $14E0,X				;|/
	STZ $00						;|\ 
	LDA.w DATA_01D59E,Y			;||
	SEC							;||
	SBC.w $185E					;||
	BPL NoDec					;||
	DEC $00						;||
NoDec:							;|| Get vertical position for the Goomba/Bob-omb, offset from the parachute.
	CLC							;|| 
	ADC $D8,X					;||
	STA $D8,X					;||
	LDA.w $14D4,X				;||
	ADC $00						;||
	STA.w $14D4,X				;|/
	LDA.w $1602,X				;|\ 
	SEC							;||
	SBC.b #$0C					;||
	CMP.b #$01					;||
	BNE TiltedMove				;|| Get animation frame for the Goomba/Bob-omb.
	CLC							;||  00 = normal, 01 = tilted left, 02 = tilted right.
	ADC.w $157C,X				;||
TiltedMove:						;
	STA.w $1602,X				;|/
	LDA.w $1540,X				;|\ 
	BEQ Landed					;||	If it landed on the ground, clear the animation frame.
	STZ.w $1602,X				;|/
Landed:							;
	LDY.w $1602,X				;|\ 
	LDA.w DATA_01D5B0,Y			;|| Draw four 8x8s.
	JSL $018042					;|/
	JSR SubSprSprPMarioSpr		;| Process interaction with Mario and other sprites.
	LDA.w $1540,X				;|\ 
	BEQ HasntLanded				;|| Branch depending on whether the sprite has landed or in the process of landing.
	DEC A						;||
	BNE ProcessLanding			;|/
	STZ $AA,X					;|\ 
	PLA							;||
	PLA							;||
	PLA							;||
	STA.w $14D4,X				;||
	PLA							;||
	STA $D8,X					;||
	;LDA.b #$80					;||
	;STA.w $1540,X				;|| Turn the sprite into a Bob-omb/Goomba, and set its stun timer.
ChangeSprite:					;||
	LDA !extra_byte_1,x			;|| Use the extra byte
	STA $9E,X					;||
	PHA                         ;|/ Preserve A
	LDA #$00                    ;	The sprite is not custom anymore
	STA !7FAB10,x               ;
	PLA                         ;
	JSL $07F78B					;|	Load sprite tables
	RTS							;|
	
SubSprSprPMarioSpr:	
	JSL $018032			
	JMP MarioSprInteractRt

ProcessLanding:					;| Landed on the ground, waiting for parachute to fall.
	JSL $019138					;|
	LDA.w $1588,x           	;|
	AND.b #$04					;|
	BEQ IsOnGround				;|
	JSR SetSomeYSpeed			;|| Useless. (likely leftover from an older version)
IsOnGround:						;|
	JSL $01801A					;||
	INC $AA,X					;|/
	BRA RestorePosValue			;| Restore position values.
								;|
HasntLanded:					;| Hasn't landed.
	TXA							;|\ 
	EOR $13						;||
	LSR							;|| Process object interaction every other frame.
	BCC RestorePosValue			;||
	JSL $019138					;|/
	LDA.w $1588,X				;|
	AND.b #$03					;|\ 
	BEQ CheckGround				;||
	LDA.b #$01					;|| If it hits the side of a block, lock its angle at #$07.
	STA.w $151C,X				;||
	LDA.b #$07					;||
	STA.w $1570,X				;|/
CheckGround:					;|
	LDA.w $1588,x           	;|
	AND.b #$04					;|\ 
	BEQ RestorePosValue			;|| If it hits the ground, start the "falling parachute" timer.
	LDA.b #$20					;||
	STA.w $1540,X				;|/
RestorePosValue:				;|
	PLA							;|\ 
	STA.w $14E0,X				;||
	PLA							;||
	STA $E4,X					;|| Restore position values.
	PLA							;||
	STA.w $14D4,X				;||
	PLA							;||
	STA $D8,X					;|/			
	RTS							;|
								;|
SetSomeYSpeed:					;| Subroutine to set Y speed for a sprite when on the ground.
	LDA.w $1588,X				;|\ 
	BMI CODE_019A10				;||
	LDA.b #$00					;|| 
	LDY.w $15B8,X				;|| If standing on a slope or Layer 2, give the sprite a Y speed of #$18.
	BEQ CODE_019A12				;|| Else, clear its Y speed.
CODE_019A10:					;||
	LDA.b #$18					;||
CODE_019A12:					;||
	STA $AA,X					;|/
	RTS							;|

MarioSprInteractRt:
	LDA.w $167A,X				;$01A7E4	|\ 
	AND.b #$20					;$01A7E7	||
	BNE ProcessInteract			;$01A7E9	||
	TXA							;$01A7EB	||
	EOR $13						;$01A7EC	||
	AND.b #$01					;$01A7EE	|| Return if not a frame in which interaction is processed for the sprite, or the sprite is horizontally offscreen.
	ORA.w $15A0,X				;$01A7F0	||
	BEQ ProcessInteract			;$01A7F3	||
ReturnNoContact:				;			||
	CLC							;$01A7F5	||
	RTS							;$01A7F6	|/


ProcessInteract:				;-----------| The actual Mario-sprite interaction routine.
	%SubHorzPos()				;$01A7F7	|
	LDA $0F						;$01A7FA	|\ 
	CLC							;$01A7FC	||
	ADC.b #$50					;$01A7FD	||
	CMP.b #$A0					;$01A7FF	|| Return if Mario is not within a 10x12 space around the sprite.
	BCS ReturnNoContact			;$01A801	||  (i.e. not within any hitbox whatsoever)
	%SubVertPos()				;$01A803	||
	LDA $0E						;$01A806	|| That said, this is a single-byte compare, so this space loops each screen anyway.
	CLC							;$01A808	||  (thankfully, the CheckForContact makes sure of that anyway).
	ADC.b #$60					;$01A809	||
	CMP.b #$C0					;$01A80B	||
	BCS ReturnNoContact			;$01A80D	|/
CODE_01A80F:					;			|
	LDA $71						;$01A80F	|\ 
	CMP.b #$01					;$01A811	|| Return if Mario is performing a special animation.
	BCS ReturnNoContact			;$01A813	|/
	LDA.b #$00					;$01A815	|\ 
	BIT.w $0D9B					;$01A817	||
	BVS CODE_01A822				;$01A81A	||
	LDA.w $13F9					;$01A81C	|| Return if Mario and the sprite are on different layers.
	EOR.w $1632,X				;$01A81F	||
CODE_01A822:					;			||
	BNE ReturnNoContact2		;$01A822	|/
	JSL $03B664					;$01A824	|\ 
	JSL $03B69F					;$01A828	|| Return if Mario is not in contact with the sprite.
	JSL $03B72B					;$01A82C	||
	BCC ReturnNoContact2		;$01A830	|/
	LDA.w $167A,X				;$01A832	|\ 
	BPL DefaultInteractR		;$01A835	|| Handle default interaction. Else, return carry set.
	SEC							;$01A837	|/
	RTS							;$01A838	|



DATA_01A839:					;$01A839	| X speeds to gives sprites when killed by a star.
	db $F0,$10

DefaultInteractR:				;-----------| Subroutine to handle default interaction when Mario is actually touching a sprite.
	LDA.w $1490					;$01A83B	|\ 
	BEQ CODE_01A87E				;$01A83E	||
	LDA.w $167A,X				;$01A840	|| Branch if Mario doesn't have star power or the sprite can't be killed by a star.
	AND.b #$02					;$01A843	||
	BNE CODE_01A87E				;$01A845	|/


CODE_01A847:					;```````````| Mario is touching a sprite with either star power or sliding into it.
	JSL $01AB6F					;$01A847	|
	INC.w $18D2					;$01A84B	|\ 
	LDA.w $18D2					;$01A84E	||
	CMP.b #$08					;$01A851	||
	BCC CODE_01A85A				;$01A853	|| Increase kill count and give corresponding points.
	LDA.b #$08					;$01A855	||
	STA.w $18D2					;$01A857	||
CODE_01A85A:					;			||
	JSL	$02ACE5					;$01A85A	|/
	LDY.w $18D2					;$01A85E	|\ 
	CPY.b #$08					;$01A861	||
	BCS CODE_01A86B				;$01A863	|| Get SFX for being hit with star power.
	LDA.w DATA_01A61E-1,Y		;$01A865	||
	STA.w $1DF9					;$01A868	|/
CODE_01A86B:					;			|
	LDA.b #$02					;$01A86B	|\ Kill the sprite.
	STA.w $14C8,X				;$01A86D	|/
	LDA.b #$D0					;$01A870	|\ 
	STA $AA,X					;$01A872	||
	%SubHorzPos()				;$01A874	|| Send flying away from Mario.
	LDA.w DATA_01A839,Y			;$01A877	||
	STA $B6,X					;$01A87A	|/
ReturnNoContact2:				;			|
	CLC							;$01A87C	|
	RTS							;$01A87D	|


CODE_01A87E:					;```````````| Mario doesn't have star power.
	STZ.w $18D2					;$01A87E	|
	LDA.w $154C,X				;$01A881	|\ 
	BNE CODE_01A895				;$01A884	|| Return if the sprite has player contact disabled.
	LDA.b #$08					;$01A886	||  Otherwise, prevent extra contact from occuring.
	STA.w $154C,X				;$01A888	|/
	LDA.w $14C8,X				;$01A88B	|\ 
	CMP.b #$09					;$01A88E	|| Branch if not a carryable sprite.
	BNE CODE_01A897				;$01A890	|/
CODE_01A895:					;			|
	CLC							;$01A895	|
	RTS							;$01A896	|

CODE_01A897:					;```````````| Non-carryable sprite.
	LDA.b #$14					;$01A897	|\\ Distance above the sprite that Mario's position must be to be considered on "top" of it.
	STA $01						;$01A899	||   (increasing this value = smaller safe space)
	LDA $05						;$01A89B	||
	SEC							;$01A89D	||
	SBC $01						;$01A89E	||
	ROL $00						;$01A8A0	||
	CMP $D3						;$01A8A2	||
	PHP							;$01A8A4	||
	LSR $00						;$01A8A5	||
	LDA $0B						;$01A8A7	||
	SBC.b #$00					;$01A8A9	|| Branch to CODE_01A8E6 if:
	PLP							;$01A8AB	||  - Too low to bounce off the sprite (Y position greater than the sprite's).
	SBC $D4						;$01A8AC	||  - Moving upward, the sprite can't be hit while moving upwards,
	BMI CODE_01A8E6				;$01A8AE	||     and Mario hasn't hit any other enemies.
	LDA $7D						;$01A8B0	||  - Both Mario and the sprite are on the ground. 
	BPL CODE_01A8C0				;$01A8B2	||
	LDA.w $190F,X				;$01A8B4	||
	AND.b #$10					;$01A8B7	||
	BNE CODE_01A8C0				;$01A8B9	||
	LDA.w $1697					;$01A8BB	||
	BEQ CODE_01A8E6				;$01A8BE	||
CODE_01A8C0:					;			||
	LDA.w $1588,x
	AND #$04					;$01A8C0	||
	BEQ CODE_01A8C9				;$01A8C3	||
	LDA $72						;$01A8C5	||
	BEQ CODE_01A8E6				;$01A8C7	|/
CODE_01A8C9:					;			|
	LDA.w $1656,X				;$01A8C9	|\ 
	AND.b #$10					;$01A8CC	|| If the sprite can be bounced on, branch.
	BNE CODE_01A91C				;$01A8CE	|/
	LDA.w $140D					;$01A8D0	|\ 
	ORA.w $187A					;$01A8D3	|| If not spinjumping or riding Yoshi, branch.
	BEQ CODE_01A8E6				;$01A8D6	|/
CODE_01A8D8:					;			|
	LDA.b #$02					;$01A8D8	|\ SFX for spinjumping off an enemy that can't be bounced on.
	STA.w $1DF9					;$01A8DA	|/  Also used for bouncing off of disco shells.
	JSL $01AA33					;$01A8DD	| Make Mario bounce upwards.
	JSL $01AB99					;$01A8E1	|
	RTS							;$01A8E5	|

	
CODE_01A8E6:					;```````````| Hitting an enemy without bouncing off of it.
	LDA.w $13ED					;$01A8E6	|\ 
	BEQ CODE_01A8F9				;$01A8E9	||
	LDA.w $190F,X				;$01A8EB	||
	AND.b #$04					;$01A8EE	|| If sliding and the sprite can be killed by sliding, then kill it and return.
	BNE CODE_01A8F9				;$01A8F0	||
	LDA.b #$03					;$01A8F2	||
	STA.w $1DF9
	JSR CODE_01A847				;$01A8F5	||
	RTS							;$01A8F8	|/
CODE_01A8F9:					;			|
	LDA.w $1497					;$01A8F9	|\ 
	BNE Return01A91B			;$01A8FC	|| If Mario is invulnerable or riding Yoshi, return.
	LDA.w $187A					;$01A8FE	||
	BNE Return01A91B			;$01A901	|/
	LDA.w $1686,X				;$01A903	|\ 
	AND.b #$10					;$01A906	||
	BNE CODE_01A911				;$01A908	|| If it changes direction when touched, turn it around.
	%SubHorzPos()				;$01A90A	||
	TYA							;$01A90D	||
	STA.w $157C,X				;$01A90E	|/
CODE_01A911:					;			|
	LDA $9E,X					;$01A911	|\ 
	CMP.b #$53					;$01A913	|| If sprite 53 (throwblock), return.
	BEQ Return01A91B			;$01A915	|/
	JSL $00F5B7					;$01A917	| For everything else, hurt Mario.
Return01A91B:					;			|
	RTS							;$01A91B	|


CODE_01A91C:					;```````````| Hitting an enemy on top, handle bouncing off.
	LDA.w $140D					;$01A91C	|\ 
	ORA.w $187A					;$01A91F	|| If not spinjumping or riding Yoshi, branch.
	BEQ CODE_01A947				;$01A922	|/
CODE_01A924:					;			|
	JSL $01AB99					;$01A924	|
	LDA.b #$F8					;$01A928	|\\ Y speed of Mario when stomping an enemy while spinjumping.
	STA $7D						;$01A92A	||
	LDA.w $187A					;$01A92C	|| Get bounce speed based on whether Mario is spinjumping or riding Yoshi.
	BEQ CODE_01A935				;$01A92F	||
	JSL $01AA33				;$01A931	|/
CODE_01A935:					;			|
	LDA.b #$04					;$019ACB	|\ 
	STA.w $14C8,X				;$019ACD	|| Erase the sprite in a cloud of smoke.
	LDA.b #$1F					;$019AD0	||
	STA.w $1540,X				;$019AD2	|/
	JSL $07FC3B					;$01A938	| Generate the stars from the spinjump.
	JSR CODE_01AB46				;$01A93C	| Increase bounce counter/give points.
	LDA.b #$08					;$01A93F	|\ SFX for spinjumping or Yoshi-stomping an enemy.
	STA.w $1DF9					;$01A941	|/
	RTS


CODE_01A947:					;```````````| Bouncing off an enemy without spinjumping/riding Yoshi.
	JSR CODE_01A8D8				;$01A947	| Set Y speed, display a contact graphic, and set default sound effect (for disco shell).
	LDA.w $187B,X				;$01A94A	|\ 
	BEQ CODE_01A95D				;$01A94D	|| If bouncing on a disco shell (or chuck/etc.), just give Mario some X speed and return.
	%SubHorzPos()				;$01A94F	||
	LDA.b #$18					;$01A952	||| X speed to give Mario to the right of a disco shell/Chuck.
	CPY.b #$00					;$01A954	||
	BEQ CODE_01A95A				;$01A956	||
	LDA.b #$E8					;$01A958	||| X speed to give Mario to the left of a disco shell/Chuck.
CODE_01A95A:					;			||
	STA $7B						;$01A95A	||
	RTS							;$01A95C	|/

CODE_01A95D:
	JSR CODE_01AB46				;$01A95D	| Increase bounce counter/play SFX/give points.
	;LDA.b #$80					;$01A98E	|| Sprite 3F (para-Goomba) and sprite 40 (para-Bomb): turn into a Goomba/Bob-omb and set stun timer.
	;STA.w $1540,X				;$01A990	||
	LDA !extra_byte_1,x					;$01A993	||
CODE_01A99B:					;			|
	STA $9E,X					;$01A99B	|
	LDA.w $15F6,X				;$01A99D	|\ 
	AND.b #$0E					;$01A9A0	||
	STA $0F						;$01A9A2	||
	PHA                         ;|/ Preserve A
	LDA #$00                    ;	The sprite is not custom anymore
	STA !7FAB10,x               ;
	PLA   
	JSL $07F78B					;$01A9A4	|| Respawn the sprite.
	LDA.w $15F6,X				;$01A9A8	||
	AND.b #$F1					;$01A9AB	||
	ORA $0F						;$01A9AD	||
	STA.w $15F6,X				;$01A9AF	|/
	STZ $AA,X					;$01A9B2	|
	LDA $9E,X					;$01A9B4	|\ 
	CMP.b #$02					;$01A9B6	|| Unused?
	BNE Return01A9BD			;$01A9B8	||  Sets the "walked off ledge" flag for the Blue Koopa.
	INC.w $151C,X				;$01A9BA	|/
Return01A9BD:					;			|
	RTS							;$01A9BD	|
	
CODE_01AB46:					;-----------| Subroutine to get bounce sound effect and give points. Also used when bump-kicking shells.
	PHY							;$01AB46	|
	LDA.w $1697					;$01AB47	|\ 
	CLC							;$01AB4A	||
	ADC.w $1626,X				;$01AB4B	||
	INC.w $1697					;$01AB4E	||
	TAY							;$01AB51	|| Increase Mario's bounce counter and get bounce SFX.
	INY							;$01AB52	||
	CPY.b #$08					;$01AB53	||
	BCS CODE_01AB5D				;$01AB55	||
	LDA.w DATA_01A61E-1,Y		;$01AB57	||
	STA.w $1DF9					;$01AB5A	|/
CODE_01AB5D:					;			|
	TYA							;$01AB5D	|
	CMP.b #$08					;$01AB5E	|\ 
	BCC CODE_01AB64				;$01AB60	||
	LDA.b #$08					;$01AB62	|| Give points.
CODE_01AB64:					;			||
	JSL $02ACE5					;$01AB64	|/
	PLY							;$01AB68	|
	RTS							;$01AB69	|
	
DATA_01A61E:					;$01A61E	| SFX for jumping on enemies in a row. Also for hits by a shell and by star power.
	db $13,$14,$15,$16,$17,$18,$19
	