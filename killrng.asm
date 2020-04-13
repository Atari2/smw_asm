;this simple patch basically destroys the rng routine in smw
;replacing with a very arbitrary routine that always returns $7F (althought you can change it)
;note: the rest of the routine isn't NOPed out because I was lazy
org $01ACF9
	LDA #$7F		;arbitrary value
	STA $148C
	STA $148D
	STA $148E
	RTL
