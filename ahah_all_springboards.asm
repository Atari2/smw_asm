if read1($00FFD5) == $23
	!addr = $6000
	!bank = $000000
	!154C = $32DC
else
	!addr = $0000
	!bank = $800000
	!154C = $154C 
endif

org $01A0A6
autoclean JML hijack

freecode
hijack:
STZ $7B			; zero out mario's x speed
; restore original code
LDA #$10
STA !154C,x
LDA #$0C
STA $149A|!addr
JML $01A0B0|!bank