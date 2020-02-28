!controller = $18  ;currently uses axlr----
!check = %00110000 ;change this if you want other buttons, currently checks L/R, format axlr----
main:
LDA $72
BEQ +
LDA !controller
AND #!check
BEQ +
LDA $13ED
BNE .zero
LDA #$1C
STA $13ED
BRA +
.zero
STZ $13ED
+ RTL