; This is a custom layer 2 scroll that rises and sinks
; it starts automatically and changes directions automatically once it hits the limits
; Speed and limits ($Bottom/$Top) are customizable
; Mostly based on the LayerScroll by Erik (https://www.smwcentral.net/?p=section&a=details&id=14515)
; Heavily modified by Atari2.0
;========================================;
; NOTE: BG Scroll settings SHOULD BE     ;
; H: Constant, V: None.                  ;
;========================================;

!RisingOrSinking = $18B4|!addr
!Bottom = $7F
!Top = $01
!Speed = $07                ; valid values: 01, 03, 07, 0F, 1F, 3F, 7F. the larger, the slower.
!StartRiseOrSink = $00 ; 00, starts by rising, 01 starts by sinking
; don't touch.

!CurrentLayerY = $20
!NFrameLayerY = $1468|!addr

init:
LDA #!StartRiseOrSink
STA !RisingOrSinking
RTL

main:
       LDA $14
       AND #!Speed
       ORA $9D
       BNE Return
       LDA !RisingOrSinking
       AND #$01
       BEQ Rising
Sinking:
       LDA !CurrentLayerY   ;\ if already at the limit, return
       CMP #!Bottom         ; |
       BEQ InvertAndReturn        ;/
       REP #$20             ;\ move the layer
       DEC !NFrameLayerY  ; |
       SEP #$20             ;
Return:
       RTL
Rising:
       LDA !CurrentLayerY   ;\ if already at the limit, return
       CMP #!Top         ; |
       BEQ InvertAndReturn        ;/
       REP #$20             ;\ move the layer
       INC !NFrameLayerY  ; |
       SEP #$20             ;
       RTL
InvertAndReturn:
       INC !RisingOrSinking
       RTL