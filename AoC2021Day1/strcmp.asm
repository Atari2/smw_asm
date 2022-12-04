; $00, $01, $02 -> 24-bit address to str1
; $03, $04, $05 -> 24-bit address to str2
; clobbers $00-$08
; returns AXY in 8 bit
; return carry set if equal
strcmp:
    jsr strlen
    stx $0A         ;; 0A-0B -> length of str1
    
    ;; save address of str1
    lda $00
    sta $06
    lda $01
    sta $07
    lda $02
    sta $08

    ;; move address of str2
    lda $03
    sta $00
    lda $04
    sta $01
    lda $05
    sta $02
    
    jsr strlen
    stx $0C         ;; 0C-0D -> length of str2

    sep #$20
    lda $0A
    cmp $0C
    bne .strcmp_end
    ldy #$0000
    .loop
    lda [$00],y
    cmp [$06],y
    bne .strcmp_end
    iny
    cpy $0A
    bne .loop
    sec
    sep #$30
    rts
    .strcmp_end:
    sep #$30
    clc
    rts
