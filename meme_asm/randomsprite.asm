;bad ideas, basically loops throught all sprite slots, then randomizes their number

!value = $35 ;this is the upper bound of the random value, set it higher than 35 at your own risk
!table_reset = 1 ;set this to 0 if we want to maximize fun (and possible crashes)
!freeram = $7FB500	;can be changed if needed
if !sa1 == 1
	!freeram = $40B500
endif
!frames = $40	;not in decimal, how many frames

init: 
	LDA #!frames
	STA !freeram
RTL
main:
LDA !freeram
BNE .return
LDA #!frames
STA !freeram
LDX #!sprite_slots-1
.loop
LDA !14C8,X
CMP #$08
BMI .skip
LDA #!value
JSR random
STA !9E,x
if !table_reset == 1
	JSL $07F7D2
endif
.skip
DEX
BPL .loop
.return
LDA !freeram
DEC A
STA !freeram
RTL


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