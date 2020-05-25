; Turning code stolen from Blind Devil's Rounding Boo
; GetDrawInfo stolen from pixi

!SavedX = $7FB500
!MaxXSpd = $06
!TimeToTurn = $40
!StartingY = $40
!StartingX = $58

macro GetOAMIndex()
    LDY #$FC
    ?-
    LDA $0301,Y
    CMP #$F0
    BEQ ?+
    DEY #4
    BPL ?-
    RTL         ;if Y == 0, kill everything
    ?+
endmacro

macro GetSprIndex()
    LDX #$0C
    ?-
    LDA $14C8,X
    BEQ ?+
    DEX
    BPL ?-
    LDX #$FF    ;if not found, set to FF
    ?+
endmacro

macro SetOAMProp(XPos, YPos, Tile, Props, Size)
    LDA <XPos> : STA $0300,y    ; xpos on screen
    LDA <YPos> : STA $0301,y    ; ypos on screen
    LDA <Tile> : STA $0302,y    ; tile
    LDA <Props> : STA $0303,y   ; yxppccct
    TYA : LSR #$2 : TAY
    LDA <Size> : STA $0460,y
endmacro

macro savex(Routine)
    PHX : JSL <Routine> : PLX
endmacro

init:

%GetSprIndex()
TXA
STA !SavedX     ; save this index for later
CMP #$FF        ; if it's $FF it means no slot was found
BEQ +
JSL $07F7D2       ; Init sprite tables
LDA #!StartingX
STA $E4,x
LDA #!StartingY
STA $D8,x
STZ $14D4,x
STZ $14E0,X
LDA #!TimeToTurn
STA $1540,x
STZ $157C,x
STZ $B6,x
+ RTL

main:

LDA !SavedX         ; get x index
CMP #$FF
BNE +
RTL                 ; if X==FF, return cause no slot was found
+
TAX

LDA $1540,x
BEQ ++
DEC $1540,x         ; decrement counter cause apparently code to decrement it doesn't run on overworld
++

LDA $C2,x           ; set Y speed for wobbly effect
AND.b #$01
TAY
LDA $AA,X
CLC : ADC.w SpeedTable,Y
STA $AA,x
CMP.w SpeedY,Y
BNE +
INC $C2,x
+

JSL SetAnimationFrame   ; calculate correct animation frame

LDA $1540,x             ; if counter and speed are 0, time to turn
ORA $B6,x
BNE .noswap

LDA #!TimeToTurn        ; turn speed and direction
STA $1540,x

LDA $157C,x
EOR #$01
STA $157C,x

.noswap
LDA $14
AND #$03
BNE .updatepos

LDY $157C,x
LDA $1540,x
BNE .domax

CPY #$00
BEQ .decrright
BRA .decrleft

.domax
LDA $157C,x
LSR : LDA #!MaxXSpd
BCS .goingleft

CMP $B6,x
BEQ .updatepos

.decrleft
INC $B6,x
BRA .updatepos

.goingleft
EOR #$FF : INC
CMP $B6,x
BEQ .updatepos

.decrright
DEC $B6,x

.updatepos 
%savex($01801A)   ; save x because these destroy x and restore it using 15E9 which I can't use
%savex($018022)

JSL GetDrawInfo   
;CPY #$FF          ; if invalid was triggered, we already inverted speeds so skip
;BEQ +
;LDA $15A0,x       ; check offscreen flags supposedly set by GetDrawInfo
;ORA $186C,x
;BNE +
LDY $1602,x
LDA Tiles,y
STA $02
LDY $157C,x
LDA Props,y
STA $03
%GetOAMIndex()
%SetOAMProp($00, $01, $02, $03, #$00)     
+ RTL

Props:
    db $73, $03
Tiles:
    db $B0, $B1
SpeedY:
    db $18, $E8
SpeedTable:
    db $01,$FF
; 0000 -> 1A -> custom tailored for YI
; C000 -> 1C -> custom tailored for YI
GetDrawInfo:   
LDA $14E0,x 	
XBA
LDA $E4,X			; load 16 bit x-position in A	
REP #$20
SEC : SBC.w $1A
STA $00				; store in $00, $01
CLC : ADC.w #$0040	; add #$0040 (why this value?)
CMP.w #$0180		; cmp to 0180? what is the function of this CMP if there's no branch after it
SEP #$20			
LDA $01				; load low byte of x position (subtracted and + 0040)
BEQ +				
LDA #$01			; if not zero, load #$01 instead to set the h offscreen flag
+
STA $15A0,X
TDC					; no idea what this does
ROL A				; or this
STA $15C4,x			; store this into another weird offscreen flag
BNE .invalid

LDA $14D4,X			; what the actual fuck is going on here
XBA
LDA $190F,X			; why 190F
AND #$20
BEQ .CheckOnce
.CheckTwice         ; this label appears unused? not sure why it's here
LDA $D8,x			; load low byte of Y pos
REP #$21			; go into 16 bit, but why 21?
ADC.w #$001C		; add something without CLC ?
SEC : SBC.w $1C		; subtract layer 1 Y position
SEP #$20	
LDA $14D4,X			; load high byte again?
XBA 				
BEQ .CheckOnce		; something something
LDA #$02			; set the offscreen Y flag		
.CheckOnce	
STA $186C,X			; sprite off screen flag
LDA $D8,X
REP #$21			; again #21?
ADC.w #$000C		
SEC : SBC.w $1C		; subtract the layer 1 Y position AGAIN?
SEP #$21
SBC #$0C			
STA $01				; this is all mystery math
XBA
BEQ .OnScreenY
INC $186C,X			; 186C again, for some reason
.OnScreenY
RTL

.invalid        
LDY #$FF        	; i modified this because I don't need to kill any banks or stuff
RTL

SetAnimationFrame:				
	INC.w $1570,X				
	LDA.w $1570,X				
    LSR #3
	AND.b #$01					
	STA.w $1602,X				
	RTL							