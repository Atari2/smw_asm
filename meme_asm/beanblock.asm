db $42
JMP MarioBelow : JMP Return : JMP Return
JMP Return : JMP Return : JMP Return : JMP Return
JMP Return : JMP Return : JMP Return
!sprite = $6B
MarioBelow:
LDA $7D
CMP #$80
BCC Return
PHY
LDA $76
BNE + 
LDA #!sprite+1
BRA ++
+
LDA #!sprite
++
CLC
%spawn_sprite()
PHA
STZ $01
LDA $76
BEQ +
LDA #$10
BRA ++
+
LDA #$00
++
STA $00
PLA
%move_spawn_relative()
LDA #$03
STA $1DFC
LDA #$01
LDX #$0D
LDY #$00
%spawn_bounce_sprite()
PLY
Return:
RTL

print "An invisible block that spawns a bean"