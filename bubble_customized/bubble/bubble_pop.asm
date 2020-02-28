!sa1	= 0
!addr	= $0000
!9E = $009E
!1534 = $1534
if read1($00FFD5) == $23
	sa1rom
	!sa1	= 1
	!addr	= $6000
	!9E = $3200
	!1534 = $32B0
endif


org $01F5A1 
	autoclean JSL hack
	NOP

freecode

hack:
	LDA.b #$01
	STA.w $1DF9|!addr
	LDA.w !9E,Y
	CMP.b #$9D
	BNE .skip
	LDA.b #$04
	STA.w !1534,Y
	LDA.b #$19
	STA.w $1DFC|!addr
	.skip
	RTL