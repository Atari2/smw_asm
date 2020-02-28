!sa1	= 0
!addr	= $0000
if read1($00FFD5) == $23
	sa1rom
	!sa1	= 1
	!addr	= $6000
endif

org $028ACD
	autoclean JSL hijack
	NOP #4
	;A9 05 8D FC 1D EE BE 0D
	;goes to
	;22 xx xx xx EA EA EA EA 
freecode
	hijack:
	LDA.b #$05
	STA.w $1DFC|!addr	;play the sound
	LDA.w $0DBE|!addr	;does the player have exactly
	CMP.b #$62			;99-1 in hex
	BEQ +		;if yes, don't increment life counter
	INC.w $0DBE|!addr	;if not, increment it
	+
	RTL
