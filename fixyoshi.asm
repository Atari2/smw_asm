!babyYoshiDMA = $1869       ; 2 consecutive bytes of empty and unused ram
!yoshiDMA = $1415           ; 2 consecutive bytes of empty and unused ram
!tile = $24                 ; tile to use, modify this in tandem with DMA destination, default is smiley coin
!DMADestination = $6240     ; DMA destination is kinda hard to explain. valid values are $6000-$6FFF
                            ; the third digit (C in this case) indicates the row of the page (8x8 rows, so each single tile is 2 rows)
                            ; the 2 indicates how many 8x8 tiles the destination needs to be offset from the page (in this case 1 full 16x16 tile)
                            ; the last digit is always 0 for alignment


org $02EA2F
    LDA.b #!tile      

org $02EA41
    JML loadBabyYoshiFlag

org $01EEB7
    autoclean JML loadFlag

org $00A34D
    JML uploadYoshiDMA

freecode
    loadFlag:
    STA !yoshiDMA
    STA $0D8B
    CLC
    JML $01EEBB

    loadBabyYoshiFlag:
    STA !babyYoshiDMA
    STA $0D8B
    CLC
    JML $02EA45

    uploadYoshiDMA:
    JSR CheckAndWriteBabyYoshi  ;| do the check before we override the tiles so we can get the value
    LDA.w #$6000				;|\ Write the next set of tiles to the first row of SP1.
	STA.w $2116					;|/
	LDX.b #$00					;|
    SEP #$20
    LDA $18E2
    ORA $18DF
    BEQ .noYoshi                ; if yoshi is in the level, override the baby yoshi possible tiles
    REP #$20
    LDA !yoshiDMA
    STA $0D8B
    CLC : ADC #$0200
    STA $0D95
    .noYoshi
    REP #$20
.uploadLoop					    ;|
	LDA.w $0D85,X				;|\ Upload the top halves of the player/Yoshi/Podoboo tiles.
	STA.w $4322					;|/
	LDA.w #$0040				;|\ Upload x40 bytes (2 tiles)
	STA.w $4325					;|/
	LDY.b #$04					;|\ Enable DMA on channel on channel 2.
	STY.w $420B					;|/
	INX							;|
	INX							;|
	CPX.w $0D84					;|
	BCC .uploadLoop				;|
    JML $00A36D

    CheckAndWriteBabyYoshi:
    SEP #$20
    LDX #$0B
    .checkLoop
    LDA $9E,x
    CMP #$2D
    BEQ .foundBabyYoshi
    DEX
    BPL .checkLoop
    REP #$20
    RTS

    .foundBabyYoshi             ; manually upload baby yoshi tiles
    REP #$20
    LDA.w !babyYoshiDMA
    STA $4322
    LDA.w #$0040
    STA $4325
    LDA.w #!DMADestination
    STA $2116
    LDY.b #$04
    STY $420B
    LDA.w !babyYoshiDMA
    CLC : ADC.w #$0200
    STA $4322
    LDA.w #$0040
    STA $4325
    LDA.w #!DMADestination+$0100
    STA $2116
    LDY.b #$04
    STY $420B
    RTS