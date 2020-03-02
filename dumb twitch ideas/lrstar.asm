!star_power = $1490
!freeram = $7FB500	;change this if needed
init:
LDA #$00
STA !freeram
RTL
main:
LDA !freeram
BEQ .checkbuttons	;if freeram is zero, check buttons
LDA #$FF 			;if freeram is not zero, give mario star power then check buttons
STA !star_power
.checkbuttons
LDA $18
AND #%00110000 ;axlr---- if nothing is being pressed, return
BEQ .return
LDA !freeram	;if freeram is not zero and buttons are being pressed, set it to 0
BNE .zero
LDA #$01		;else set it to 1 and then return
STA !freeram
BRA .return
.zero
LDA #$00
STA !freeram
STA !star_power
.return
RTL
