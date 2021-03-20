!freeram = $1864 ;can be changed, if 00, normal framerules, if != 00, less framerules
!times = 2
org $01A7EB
	autoclean JML hijack
	NOP #4
;8A 45 13 29 01 1D A0 15
;22 00 00 00

freecode

hijack:
LDA !freeram
BEQ .normal
TXA 
EOR $13
LSR #!times
BRA .return
.normal
TXA							;$01A7EB	||
EOR $13						;$01A7EC	||
.return
AND.b #$01					;$01A7EE	|| Return if not a frame in which interaction is processed for the sprite, or the sprite is horizontally offscreen.
ORA.w $15A0,X				;$01A7F0	||
JML $01A7F3

