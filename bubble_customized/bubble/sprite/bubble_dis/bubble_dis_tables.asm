ExplodingBlkSpr:				;$0183A0	| Sprites for the exploding block to spawn (also used for the bubble).
	db $15,$0F,$00,$04

BubbleSprTiles1:				;$02D8A1	| First frame to use for each of the sprites inside the bubble.
	db $A8,$CA,$67,$24

BubbleSprTiles2:				;$02D8A5	| Second frame to use for each of the sprites inside the bubble.
	db $AA,$CC,$69,$24

BubbleSprGfxProp1:				;$02D8A9	| YXPPCCCT to use for each of the sprites inside the bubble.
	db $84,$85,$05,$08

BubbleSprXSpeed:				;$02D8B5	| X speeds for the bubble sprite.
	db $08,$F8

BubbleSprYAccel:				;$02D8B7	| Y accelerations for the bubble sprite.
	db $01,$FF

BubbleSprYMax:					;$02D8B9	| Max Y speeds for the bubble sprite.
	db $0C,$F4

BubbleSprites:					;$02D9A1	| Sprites to contain in the bubble, indexed by spawn X position.
	db $0F,$0D,$15,$74



BubbleTileDispX:				;$02D9A5	| X offsets for each tile in the bubble.
	db $F8,$08,$F8,$08,$FF
	db $F9,$07,$F9,$07,$00
	db $FA,$06,$FA,$06,$00

BubbleTileDispY:				;$02D9B4	| Y offsets for each tile in the bubble.
	db $F6,$F6,$02,$02,$FC
	db $F5,$F5,$03,$03,$FC
	db $F4,$F4,$04,$04,$FB

BubbleTiles:					;$02D9C3	| Tile numbers for each tile of the bubble.
	db $A0,$A0,$A0,$A0,$99

BubbleGfxProp:					;$02D9C8	| YXPPCCCT for each tile of the bubble.
	db $07,$47,$87,$C7,$03

BubbleSize:						;$02D9CD	| Tile size for each tile of the bubble.
	db $02,$02,$02,$02,$00

DATA_02D9D2:					;$02D9D2	| Indices to the X/Y offset tables for each frame of animation.
	db $00,$05,$0A,$05