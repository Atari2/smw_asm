; Para-Goomba/Bomb misc RAM:
	; $C2   - Swing direction (odd = left, even = right)
	; $151C - Flag for having hit the side of a block. When set, the sprite locks its animation and sinks straight down.
	; $1540 - Timer after landing for the parachute to decend.
	; $1570 - Current "angle" (max #$0F)
	; $157C - Horizontal direction the sprite is facing.
	; $1602 - Current animation frame for the parachute. 0 = normal, 1 = tilt left, 2 = tilt right
	;          For the parachute's subroutine, values are C (normal) and D (tilted).
	;
incsrc "parachute_global_tables.asm"

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
	BCC SkipSomeMovement		;|| Move upwards one pixel every two frames.
	DEC $D8,X					;||
	BNE SkipSomeMovement		;||
	DEC.w $14D4,X				;|/
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
	LDA !14C8,x
	BNE NotDead
	PLA : PLA : PLA : PLA
	RTS
	NotDead:
	LDA.w $1540,X				;|\ 
	BNE +
	JMP HasntLanded				;|| Branch depending on whether the sprite has landed or in the process of landing.
	+
	DEC A						;||
	BNE ProcessLanding			;|/
	STZ $AA,X					;|\ 
	PLA							;||
	PLA							;||
	PLA							;||
	STA.w $14D4,X				;||
	PLA							;||
	STA $D8,X					;||
ChangeSprite:					;||
	STZ $00
	STZ $01
	STZ $02
	STZ $03
	LDA !extra_byte_1,x			;|| Use the extra byte
	CLC
	%SpawnSprite()
	LDA.b #$80					;||
	STA.w $1540,y				;|| Turn the sprite into a Bob-omb/Goomba, and set its stun timer.
	STZ !14C8,x
	RTS							;|
	
SubSprSprPMarioSpr:	
	JSL $018032			
	JSL $01A7DC
	BCC Return001
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
	BMI Return000				;$01A8AE	||     and Mario hasn't hit any other enemies.
	JSR CODE_01A91C
	STZ $14C8,x
	STZ $00
	STZ $01
	STZ $02
	STZ $03
	LDA !extra_byte_1,x
	CLC
	%SpawnSprite()
	LDA.b #$80					;||
	STA.w $1540,Y
	BRA Return001
	Return000:
	JSL $00F5B7
	Return001:
	RTS


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
	JSL $01AA33					;$01A931	|/
CODE_01A935:					;			|
	JSR CODE_019ACB				;$01A935	| Turn the sprite into a smoke cloud.
	JSL	$07FC3B					;$01A938	| Generate the stars from the spinjump.
	JSR CODE_01AB46				;$01A93C	| Increase bounce counter/give points.
	LDA.b #$08					;$01A93F	|\ SFX for spinjumping or Yoshi-stomping an enemy.
	STA.w $1DF9					;$01A941	|/
	RTS
	
CODE_01A947:					;```````````| Bouncing off an enemy without spinjumping/riding Yoshi.
	JSR CODE_01AB46				;$01A8DA	|/  Also used for bouncing off of disco shells.
	JSL $01AA33					;$01A8DD	| Make Mario bounce upwards.
	JSL $01AB99					;$01A8E1	|	Set Y speed, display a contact graphic, and set default sound effect (for disco shell).
	LDA #$00
	%SubHorzPos()	;$01A94F	||
	RTS							;$01A95C	|/
	
CODE_019ACB:					;```````````| Subroutine to make a sprite poof. Used by the throwblock, P-switch, Bowser's fire, some sprites in lava, and spinjumped sprites.
	LDA.b #$04					;$019ACB	|\ 
	STA.w $14C8,X				;$019ACD	|| Erase the sprite in a cloud of smoke.
	LDA.b #$1F					;$019AD0	||
	STA.w $1540,X				;$019AD2	|/
	RTS							;$019AD5	|
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