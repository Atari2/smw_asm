!sa1	= 0
!addr	= $0000
!BankB = $800000
if read1($00FFD5) == $23
	sa1rom
	!BankB = $000000
	!sa1	= 1
	!addr	= $6000
	!9E = $3200
	!1534 = $32B0
endif
org $01A97D 
	autoclean JSL hack
	BCC ++    ;is the carry set (aka has a custom sprite been spawned?)
	RTS       ;if yes, return 
	++  	  ;if not, please just continue with normal code
	NOP #4	
	
freecode

hack:
LDA.b #$02 ;do normal SMW stuff
STA $C2,X
LDA.b #$FF
STA.w $1540,X
LDA $7FAB10,X  ;if the sprite is custom AND it's a dino rhino (checked earlier)
AND #$08
BEQ +
LDA #$6F  ;load #$6F dino torch
SEC   		;set custom 
PHY
STZ $00
STZ $01
JSL spawn_sprite  ;and spawn it with pixi's routine
PLY
SEC   ;set carry again to be sure
BRA normal  ;then branch to normal code
+
CLC   ;if not custom sprite, clear carry and return
normal:
RTL

spawn_sprite:
	PHX
	XBA
	LDX #$0B
	-
		LDA $14C8,x
		BEQ +
			DEX
		BPL -
		SEC
		BRA .no_slot
	+
	XBA
	STA $9E,x
	JSL $07F7D2|!BankB
	
	BCC +
		LDA $9E,x
		STA $7FAB9E,x
		
		REP #$20
		LDA $00 : PHA
		LDA $02 : PHA
		SEP #$20
		
		JSL $0187A7|!BankB			; this sucker kills $00-$02
				
		REP #$20
		PLA : STA $02
		PLA : STA $00
		SEP #$20
		
		LDA #$08
		STA $7FAB10,x
	+
	
	LDA #$01
	STA $14C8,x
	
	TXY
	PLX

	LDA $00					; \
	CLC : ADC $E4,x		; |
	STA.w $E4,y				; | store x position + x offset (low byte)
	LDA #$00					; |
	BIT $00					; | create high byte based on $00 in A and add
	BPL +						; | to x position
	DEC						; |
+	ADC $14E0,x				; |
	STA $14E0,y				; /
		
	LDA $01					; \ 
 	CLC : ADC $D8,x		; |
	STA.w $D8,y				; | store y position + y offset	
	LDA #$00					; |
	BIT $01					; | create high byte based on $01 in A and add
	BPL +						; | to y position
	DEC						; |
+	ADC $14D4,x				; |
	STA $14D4,y				; /
	
	LDA $02					; \ store x speed
	STA.w $B6,y				; /
	LDA $03					; \ store y speed
	STA.w $AA,y				; /	
	
	CLC
	RTL	
	
.no_slot:
	TXY
	PLX
	RTL