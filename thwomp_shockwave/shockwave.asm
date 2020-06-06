!Direction = !151C ;#$00 -> left, #$40 -> right
!Tile = $0A
!Prop = $33		;YXPPCCCT
print "INIT", pc
ShockWaveInit:
PHX
LDA !Direction,x
AND #$40
ROL #3
TAX
LDA.l Speeds,x
PLX
STA !B6,x
STZ !AA,x
RTL

print "MAIN", pc
PHB : PHK : PLB
JSR ShockWaveMain
PLB
RTL

Speeds:
	db $20, $E0

ShockWaveMain:
JSR ShockWaveGfx
LDA $9D
BNE Return
LDA #$00
%SubOffScreen()
JSL $01A7DC	
BCC NoTouchy
JSL $00F5B7			;hurt mario and stun
NoTouchy:
JSL $019138			;process block interaction
LDA.w !1588,X		;if blocked by the sides, kill it
AND #$03
BEQ UpdatePos
JSR ShatterPieces
STZ !14C8,x
RTS
UpdatePos:
JSL $01802A
Return:
RTS

ShatterPieces:
LDA !14E0,x
XBA
LDA !E4,x
REP #$20
STA $9A
SEP #$20
LDA !14D4,x
XBA
LDA !D8,x
REP #$20
STA $98
SEP #$20
PHB
LDA #$02
PHA
PLB		; set data bank to 02
LDA #$00	; 00 cause shatter wanna be brown
JSL $028663
PLB		; restore our data bank
RTS 

ShockWaveGfx:
%GetDrawInfo()
LDA $00
STA $0300|!addr,y
LDA $01
STA $0301|!addr,y
LDA #!Tile
STA $0302|!addr,y
LDA #!Prop
ORA !Direction,x
STA $0303|!addr,y
LDY #$02
LDA #$00
JSL $01B7B3
RTS
