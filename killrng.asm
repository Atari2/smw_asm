;this simple patch basically destroys the rng routine in smw
;replacing with a very arbitrary routine that always returns $7F

org $01ACF9
	LDA #$7F		;arbitrary value
	STA $148C
	STA $148D
	STA $148E
	RTL
