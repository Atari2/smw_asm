DATA_01D55E:					;$01D55E	| Animation frames for the parachute, indexed by the sprite's angle ($1570).
	db $0D,$0D,$0D,$0D,$0C,$0C,$0C,$0C
	db $0C,$0C,$0C,$0C,$0D,$0D,$0D,$0D

DATA_01D56E:					;$01D56E	| Horizontal directions for the frames designated above.
	db $00,$00,$00,$00,$00,$00,$00,$00
	db $01,$01,$01,$01,$01,$01,$01,$01
	
DATA_01D57E:					;$01D57E	| X offsets (low) for the Goomba/Bob-omb.
	db $F8,$F8,$FA,$FA,$FC,$FC,$FE,$FE
	db $02,$02,$04,$04,$06,$06,$08,$08
DATA_01D58E:					;$01D58E	| X offsets (high) for the Goomba/Bob-omb.
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
	db $00,$00,$00,$00,$00,$00,$00,$00

DATA_01D59E:					;$01D59E	| Y offsets for the Goomba/Bob-omb from the parachute.
	db $0E,$0E,$0F,$0F,$10,$10,$10,$10
	db $10,$10,$10,$10,$0F,$0F,$0E,$0E
	
DATA_01D5B0:					;$01D5B0	| YXPPCCCT data indexes of each frame for the Goomba/Bob-omb's draw call.
	db $01,$05,$00
	
DATA_01D4E7:					;$01D4E7	| Increment/decrement values, used for the parachute sprite's angles and Ludwig's shell speed.
	db $01,$FF

DATA_01D4E9:					;$01D4E9	| Max/min angle values for the parachute sprite.
	db $0F,$00

DATA_01D4EB:					;$01D4EB	| X speeds for each angular value (00-0F). Inverted when moving left.
	db $00,$02,$04,$06,$08,$0A,$0C,$0E
	db $0E,$0C,$0A,$08,$06,$04,$02,$00
	
