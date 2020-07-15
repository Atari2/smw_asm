DATA_02DB54:					;$02DB54	| Horizontal accelerations for the flying turnblock platform.
	db $01,$FF

DATA_02DB56:					;$02DB56	| Max X speeds for the flying turnblock platform.
	db $20,$E0

DATA_02DB58:					;$02DB58	| Vertical accelerations for the flying turnblock platform.
	db $02,$FE

DATA_02DB5A:					;$02DB5A	| Vertical accelerations check (?) for the flying turnblock platform.
	db $20,$E0
	
DATA_02DC0F:					;$02DC0F	| X offsets for each of the flying turnblock platform's tiles.
	db $00,$10,$F2,$1E
	db $00,$10,$FA,$1E

DATA_02DC17:					;$02DC17	| Y offsets for each of the flying turnblock platform's tiles.
	db $00,$00,$F6,$F6
	db $00,$00,$FE,$FE

HmrBroPlatTiles:				;$02DC1F	| Tile numbers for each of the flying turnblock platform's tiles.
	db $40,$40,$C6,$C6
	db $40,$40,$5D,$5D

DATA_02DC27:					;$02DC27	| YXPPCCCT for each of the flying turnblock platform's tiles.
	db $32,$32,$72,$32
	db $32,$32,$72,$32

DATA_02DC2F:					;$02DC2F	| Sizes for each of the flying turnblock platform's tiles.
	db $02,$02,$02,$02
	db $02,$02,$00,$00

DATA_02DC37:					;$02DC37	| Additional Y offsets for the hit animation of the platform's blocks.
	db $00,$04,$06,$08,$08,$06,$04,$00	
	