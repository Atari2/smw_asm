;;;;;;; ENTRY POINT AT LINE 367 ;;;;;;  This code was disassembled with SHEX so some of it may be wrongly disassembled data. beware.
    XBA
	REP #$20
	CMP $73D7
	BPL label_87E2E7
	SEC
	SBC $1C
	CMP $6BF2
	BPL label_87E2D5
	CMP $6BF0
	BMI label_87E2D5
	SEP #$A0
	RTL

label_87E2D2:
	LDA #$FF
	RTL

label_87E2D5:
	SEP #$20
	LDA $7616,X
	AND #$04
	BNE label_87E2D2
	LDA $6D9B
	CMP #$80
	BEQ label_87E2D2
	LSR A
	RTL

label_87E2E7:
	SEP #$20
	RTL
	LDA $05
	CMP #$7B
	BNE label_87E2FF
	LDA $54
	AND #$0D
	PHK
	PEA $E2FE
	PEA $80C9
	JML $01839C

label_87E2FF:
	INY
	LDX $02
	JML $02A9DA
	AND #$01
	ORA $0A
	STA $09
	RTL
	AND #$01
	ORA $0A
	STA $7793,X
	JML $02ABD5
	AND #$01
	ORA $0A
	STA $6FB8,Y
	JML $02AB59
	ORA $0A
	STA $7E2A,X
	DEX
	JML $02AA65
	JSL label_87E33F
	AND #$01
	ORA $0A
	JSL $00FD04
	LDA $00
	JML $02A96A

label_87E33F:
	LDA [$CE],Y
	PHA
	AND #$F0
	JML $02A960
	LDA #$01
	STA $55
	LDA $6BF4
	AND #$03
	ASL A
	TAX
	REP #$21
	LDA $87E2AA,X
	SBC #$000F
	STA $6BF0
	LDA $87E2B2,X
	CLC
	ADC #$0010
	STA $6BF2
	LDA #$FFFF
	STA $6BEE
	SEP #$20
	LDA $0EF30C
	STA $0C
	LDA $0EF30D
	STA $0D
	LDA $0EF30E
	STA $0E
	LDA $0EF30F
	CLC
	ADC #$BE
	STA $0F
	REP #$30
	LDY #$0001
	STZ $00
	STZ $02
	LDA $CE
	STA $6CF6
	DEC A
	DEC A
	STA $04
	LDA #$0000
	STA $06
	STA $08
	STA $6D36
	SEP #$20

label_87E3AB:
	STY $0A
	LDA $08
	STA $07

label_87E3B1:
	LDA [$CE],Y
	CMP #$FF
	BNE label_87E3CF
	LDA $6BF5
	BIT #$20
	BEQ label_87E438
	INY
	LDA [$CE],Y
	CMP #$FF
	BEQ label_87E3CF
	CMP #$FE
	BEQ label_87E438
	ASL A
	STA $06
	INY
	BRA label_87E3B1

label_87E3CF:
	TAX
	ASL A
	ASL A
	ASL A
	AND #$10
	ASL A
	STA $02
	INY
	LDA [$CE],Y
	AND #$0F
	ASL A
	TSB $02
	INY
	LDA $0F
	BNE label_87E3FE
	TXA
	AND #$0C
	LSR A
	LSR A
	XBA
	LDA [$CE],Y
	PHY
	TAY
	LDA [$0C],Y
	SBC #$02
	REP #$21
	AND #$00FF
	ADC $01
	TAY
	PLA
	SEP #$20

label_87E3FE:
	INY
	INC $08
	LDA $02
	CMP $00
	BEQ label_87E3B1
	REP #$20
	LDX $00
	LDA $6CF6,X

label_87E40E:
	INX
	INX
	STA $6CF6,X
	CPX $02
	BCC label_87E40E
	LDX $00
	LDA $6D36,X

label_87E41C:
	INX
	INX
	STA $6D36,X
	CPX $02
	BCC label_87E41C
	LDA $0A
	ADC $04
	STA $6CF6,X
	LDA $06
	STA $6D36,X
	SEP #$20
	STX $00
	JMP label_87E3AB

label_87E438:
	LDX $00
	CPX #$003E
	BEQ label_87E45D
	REP #$20
	LDA $6CF6,X

label_87E444:
	INX
	INX
	STA $6CF6,X
	CPX #$003E
	BNE label_87E444
	LDX $00
	LDA $6D36,X

label_87E453:
	INX
	INX
	STA $6D36,X
	CPX #$003E
	BNE label_87E453

label_87E45D:
	SEP #$30
	RTL
	STA $01
	LDA $6BF4
	AND #$03
	ASL A
	TAX
	REP #$21
	LDA $00
	STA $50
	LDA $1C
	AND #$FFF0
	STA $46
	ADC $87E2AA,X
	STA $52
	STA $48
	LDA $46
	CLC
	ADC $87E2B2,X
	STA $46
	SEC
	SBC #$0010
	STA $4A
	LDA $1A
	AND #$FFF0
	SEC
	SBC #$0030
	STA $4C
	CLC
	ADC #$0150
	STA $4E
	SEP #$20
	LDA $49
	AND #$01
	TRB $49
	TSB $48
	LDA $4B
	AND #$01
	TRB $4B
	TSB $4A
	LDA $5B
	AND #$01
	ASL A
	TAX
	LDA #$A0
	STA $45
	STZ $45,X
	LDA $6BF4
	BPL label_87E4F6
	LDA $50
	CMP $6BEE
	STA $6BEE
	BNE label_87E4CF
	LDA #$40
	TSB $45

label_87E4CF:
	LDA $48
	CMP $6BEF
	STA $6BEF
	BNE label_87E4DD
	LDA #$20
	TSB $45

label_87E4DD:
	LDA #$60
	AND $45
	CMP #$60
	BEQ label_87E524
	CMP #$20
	BNE label_87E4F6
	LDA $51
	BMI label_87E4FC
	ASL A
	CMP #$40
	BCC label_87E4FE
	LDX #$3E
	BRA label_87E4FF

label_87E4F6:
	LDA $1B,X
	DEC A
	ASL A
	BPL label_87E4FE

label_87E4FC:
	LDA #$00

label_87E4FE:
	TAX

label_87E4FF:
	REP #$20
	PEI ($CE)
	LDA $6CF6,X
	STA $CE
	LDA $6D36,X
	SEP #$20
	STA $0A
	XBA
	TAX
	PHK
	PEA $E51D
	PEA $B888
	LDY #$01
	JML $02A82C
	PLA
	STA $CE
	PLA
	STA $CF

label_87E524:
	JML $02A84B

checkForEnd:
	LDA $0BF5|!addr
	BIT #$20                ;; check if using the new sprite system
	BEQ useOldSpriteSystem  ;; if so this is the real end, otherwise
	INY
	LDA [$CE],Y             
	BPL dataNotAtEnd       ;; check next byte of sprite data, if positive, continue parsing
	CMP #$FF               ;; if $FF, not end of sprite data, otherwise RTS
	BEQ parseNormally

useOldSpriteSystem:
	JML $02A84B           ;; jumps to RTS

dataNotAtEnd:             ;; parse the Y position jump and store in $0A (upper 7 bits)
	ASL A
	STA $0A
	INY
	BRA SprLoadLoopStart

;; !!!!!!!!! THIS IS WHERE YOU JUMP TO FROM $02A846 !!!!!!!!!!
;; Y is supposedly the offset within the sprite data
;; processor status when entering: 00, XY in 16-bit mode and 8-bit A
LMSprtOffset:
	INX             ;; the original SMW code also increases X and Y by 2, so this is just restoring original code
	INY
	INY             
	BPL SprLoadLoopStart   ;; this code handles when there's a lot of data and the index needs to be wrapped around
	TYA                ;; if Y went in the negatives
	CLC                ;; add it to the sprite data pointer, set it to 0
	ADC $CE            ;; if carry is set, also increase high+bank bytes of data ptr. 
	STA $CE            
	LDY #$00
	BCC SprLoadLoopStart
	INC $CF            ;; increase bank byte

SprLoadLoopStart:
	LDA [$CE],Y         
	CMP #$FF           ;; check if $FF
	BEQ checkForEnd

parseNormally:
	STA $54           ;; $54 is used as scratch RAM (?)
	ASL A
	ASL A
	ASL A
	AND #$10
	STA $02           ;; store partial screen number in $02 ( << 3 & 0b10)
	INY
	LDA [$CE],Y
	STA $00           ;; put 2nd byte of sprite data in $00
	AND #$0F        
	ORA $02           ;; store full screen number
	STA $01           ;; in $01
	CMP $51           ;; CMP with $51 (?)
	BPL label_87E5D3
	LDA #$0F          ;; clear bottom 4 bits of $00 if set
	TRB $00

label_87E575:
	LDA #$20
	BIT $45
	BMI label_87E5B5
	BNE label_87E5B5

label_87E57D:
	LDA $0A
	CMP $49
	BNE label_87E5A7
	LDA $54
	AND #$F1
	CMP $48
	BEQ label_87E595
	CMP $4A
	BNE label_87E5B5
	LDA $0A
	CMP $4B
	BNE label_87E5B5

label_87E595:
	REP #$20
	LDA $00
	CMP $4C
	BMI label_87E5B3
	CMP $4E
	SEP #$20
	BPL label_87E5B5
	JML $02A856

label_87E5A7:
	CMP $4B
	BNE label_87E5B5
	LDA $54
	AND #$F1
	CMP $4A
	BEQ label_87E595

label_87E5B3:
	SEP #$20

label_87E5B5:
	JML $02A846

label_87E5B9:
	BIT $45
	BMI label_87E5CF
	CMP $4F
	BEQ label_87E5C3
	BCS label_87E5CF

label_87E5C3:
	LDA #$20
	AND $45
	BNE label_87E5CF
	LDA #$0F
	TRB $00
	BRA label_87E57D

label_87E5CF:
	JML $02A84B

label_87E5D3:
	BNE label_87E5B9
	LDA $00
	AND #$F0
	STA $00
	CMP $50
	BNE label_87E575
	BIT $45
	BMI label_87E5FC
	BVS label_87E575
	LDA $54
	AND #$01
	ORA $0A
	XBA
	LDA $54
	AND #$F0
	REP #$20
	CMP $52
	BMI label_87E5B3
	CMP $46
	SEP #$20
	BPL label_87E5B5

label_87E5FC:
	JML $02A856