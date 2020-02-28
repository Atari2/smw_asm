RhinoStatePtrs:					;$036C66	| Dino Rhino/Torch state pointers.
	dw CODE_039CA8							; 0 - Walking
	dw CODE_039D41							; 1 - Horizontal fire
	dw CODE_039D41							; 2 - Vertical fire
	dw CODE_039C74							; 3 - Jumping

DATA_039C6E:					;$039C6E	| Low X position shifts to push the Dino Rhino/Torch out of walls.
	db $00,$FE,$02

DATA_039C71:					;$039C71	| High X position shifts to push the Dino Rhino/Torch out of walls.
	db $00,$FF,$00

DinoSpeed:						;$039CA3	| X speeds for the Dino Rhino and Dino Torch.
	db $08,$F8								; Rhino
	db $10,$F0								; Torch

DinoFlameTable:					;$039D01	| Animation data for the Dino Torch's fire. In the format XY: Y = animation frame for the Dino, X = 4 - length of the flame
	db $41,$42,$42,$32,$22,$12,$02,$02		; Horizontal
	db $02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02,$02,$02,$02,$02,$12
	db $22,$32,$42,$42,$42,$42,$41,$41
	db $41,$43,$43,$33,$23,$13,$03,$03		; Vertical
	db $03,$03,$03,$03,$03,$03,$03,$03
	db $03,$03,$03,$03,$03,$03,$03,$13
	db $23,$33,$43,$43,$43,$43,$41,$41

DinoFlame1:						;$039D9E	|
	db $DC,$02,$10,$02

DinoFlame2:						;$039DA2	|
	db $FF,$00,$00,$00

DinoFlame3:						;$039DA6	|
	db $24,$0C,$24,$0C

DinoFlame4:						;$039DAA	|
	db $02,$DC,$02,$DC

DinoFlame5:						;$039DAE	|
	db $00,$FF,$00,$FF

DinoFlame6:						;$039DA2	|
	db $0C,$24,$0C,$24
DinoTorchTileDispX:				;$039DFE	| X offsets for the Dino Torch and its flame. Fifth byte corresponds to the actual Dino.
	db $D8,$E0,$EC,$F8,$00					; Normal
	db $FF,$FF,$FF,$FF,$00					; Jumping

DinoTorchTileDispY:				;$039E08	| Y offsets for the Dino Torch and its flame. Fifth byte corresponds to the actual Dino.
	db $00,$00,$00,$00,$00
	db $D8,$E0,$EC,$F8,$00

DinoFlameTiles:					;$039E12	| Tile numbers for the Dino Torch's flame. Fifth byte of each row unused.
	db $80,$82,$84,$86,$00
	db $88,$8A,$8C,$8E,$00

DinoTorchGfxProp:				;$039E1C	| YXPPCCCT for the Dino Torch and its flame. Fifth byte corresponds to the actual Dino.
	db $09,$05,$05,$05,$0F

DinoTorchTiles:					;$039E21	| Tile numbers for the Dino Torch.
	db $EA,$AA,$C4,$C6

DinoRhinoTileDispX:				;$039E25	| X offsets for the Dino Rhino.
	db $F8,$08,$F8,$08
	db $08,$F8,$08,$F8

DinoRhinoGfxProp:				;$039E2D	| YXPPCCCT for the Dino Rhino.
	db $2F,$2F,$2F,$2F
	db $6F,$6F,$6F,$6F

DinoRhinoTileDispY:				;$039E35	| Y offsets for the Dino Rhino.
	db $F0,$F0,$00,$00

DinoRhinoTiles:					;$039E39	| Tile numbers for the Dino Rhino.
	db $C0,$C2,$E4,$E6
	db $C0,$C2,$E0,$E2
	db $C8,$CA,$E8,$E2
	db $CC,$CE,$EC,$EE

DinoTilesWritten:				;$039F32	| How many tiles (-1) to upload to OAM for the Dino Torch, indexed by the length its flame.
	db $04,$03,$02,$01,$00

	;RTS							;$039F37	| (why is this here?)
