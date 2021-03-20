; this remaps the GFX tile
org $029E82
	db $D3, $C3, $D2, $C2 ; <- change these numbers to change the tile where the splash is located, currently this maps to the
	; 4 8x8s in GFX01 of the Smiley Coin sprite

; this remaps the page to page 00
org $029ED5
	db $04
	