if !sa1 == 1
	!Timer = $40B600
	!sprite = $40B601
else 
	!Timer = $7FB600
	!sprite = $7FB601
endif

!number = $0F

init:
LDA #$10
STA !Timer
LDA #$FF
STA !sprite
RTL

main:
LDA !sprite
CMP #$FF
BEQ .skip
JSR FindSprite
.skip
LDA !Timer
BNE .return
LDA #$11
STA !Timer
LDA !sprite
TAX
PHX 
LDA #$35
JSR random
PLX
STA !9E,x
JSL $07F7D2
.return 
LDA !Timer
DEC A
STA !Timer
RTL


FindSprite:
LDX #!sprite_slots-1
.loop
LDA !9E,x
CMP #!number
BNE .skip
STX !sprite
.skip
DEX
BPL .loop
RTS

random:
    PHX : PHP
    SEP #$30
    PHA
    JSL $01ACF9
    PLX
    CPX #$FF
    BNE .normal
    LDA $148D|!addr
    BRA .end
 
.normal
    INX
    LDA $148D|!addr
 
    if !sa1 == 0
        STA $4202               ; Write first multiplicand.
        STX $4203               ; Write second multiplicand.
        NOP #4                  ; Wait 8 cycles.
        LDA $4217               ; Read multiplication product (high byte).
    else
        STZ $2250               ; Set multiplication mode.
        STA $2251               ; Write first multiplicand.
        STZ $2252
        STX $2253               ; Write second multiplicand.
        STZ $2254
        NOP : BRA $00           ; Wait 5 cycles.
        LDA $2307               ; Read multiplication product.
    endif
.end
    PLP : PLX
RTS