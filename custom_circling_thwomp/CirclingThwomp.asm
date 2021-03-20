;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Circling Thwomp
;;
;; Extra Bit: YES
;; If set, the Thwomp will go counter clockwise otherwise it'll go clockwise
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Format:                 >   v   <   ^
SPRITE_GRAVITY:		db $04,$04,$FC,$FC
RETURN_SPEED:		db $F0,$F0,$10,$10
BLOCKED_STATE:		db $01,$04,$02,$08
DIRECTION_CHECK:	db $00,$01,$01,$00
POS_TABLE:			db $06,$00,$F6,$00
POS_TABLE_3:		db $00,$00,$FF,$00
PROX_TABLE:			dw $0060,$0024

!START_POS	= $03 ; > Which corner the sprite should start in ($00 = Top Left, $01 = Top Right, $02 = Bottom Right, $03 = Bottom Left)
!EX_RANGE	= $0020
!ANGRY_TILE		= $CA
!TIME_TO_ATTACK = !extra_byte_1

X_OFFSET:		db $FC,$04,$FC,$04,$00
Y_OFFSET:		db $00,$00,$10,$10,$08
TILE_MAP:		db $8E,$8E,$AE,$AE,$C8
PROPERTIES:		db $03,$43,$03,$43,$03

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		print "INIT ",pc
			LDA !E4,x
			ORA #$08
			STA !E4,x
			
			LDA $7FAB10,x
			AND #$04
			BEQ NO_EXTRA_BIT1
			LDA #!START_POS+1
			BRA STORE00
NO_EXTRA_BIT1:
			LDA #!START_POS
STORE00:		AND #$03
			STA $C2,x
INIT_END:	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		print "MAIN ",pc
			PHB
			PHK
			PLB
			JSR SPRITE_CODE_START
			PLB
			RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPRITE_CODE_START:	JSR SUB_GFX

			LDA !14C8,x
			CMP #$08
			BNE RETURN0
			LDA $9D
			BNE RETURN0

			LDA #$03 : %SubOffScreen()
			JSL $01A7DC|!BankB ; Mario <-> sprite interaction routine

			LDA !1534,x
			BEQ WAITING
			DEC
			BEQ ATTACKING
			
RETURNING:		LDA !1540,x
			BNE RETURN0

			STZ !1528,x

			STZ !1534,x
RETURN0:		RTS
RETURN01:		PLA : PLA : RTS
WAITING:		STZ !1528,x
			
			%SubHorzPos()
			REP #$20
			LDA $0E
			BPL +
			EOR #$FFFF : INC
+			PHA
			SEP #$20
			LDA !C2,x
			AND #$01
			BNE Horiz
			TYA : LDY !C2,x
			CMP DIRECTION_CHECK,y
			BNE RETURN01
Horiz:			LDA !C2,x
			AND #$01
			ASL
			TAY
			REP #$20
			PLA
			CMP PROX_TABLE,y
			SEP #$20
			BCC NEXT_STATE

			PHY
			%SubHorzPos()
			PLY
			REP #$20
			LDA $0E
			BPL +
			EOR #$FFFF : INC
+			SEC
			SBC #!EX_RANGE
			CMP PROX_TABLE,y
			SEP #$20
			BCS RETURN0
			
			LDA #$01
			STA !1528,x
			RTS
NEXT_STATE:		LDA #$02
			STA !1528,x

			INC !1534,x

			STZ !B6,x
			STZ !AA,x

			RTS
			
ATTACKING:		JSL $01801A|!BankB ; Update Sprite Y position without gravity
			JSL $018022|!BankB ; Update Sprite X position without gravity
			LDA !C2,x
			AND #$01
			BNE Vertical
			LDY !C2,x			; \ Horizontal Gravity
			LDA !B6,x			; |
			CMP #$C0			; |
			BMI DONT_INC_SPEED		; |
			CLC				; |
			ADC SPRITE_GRAVITY,y		; |
			STA !B6,x			; |
			BRA DONT_INC_SPEED		; /
Vertical:		LDY !C2,x			; \ Vertical Gravity
			LDA !AA,x			; |
			CMP #$C0			; |
			BMI DONT_INC_SPEED		; |
			CLC				; |
			ADC SPRITE_GRAVITY,y		; |
			STA !AA,x			; /
DONT_INC_SPEED:
			LDY !C2,x
			LDA !E4,x
			PHA
			CLC
			ADC POS_TABLE,y
			STA !E4,x
			LDA !14E0,x
			PHA
			ADC POS_TABLE_3,y
			STA !14E0,x

			JSL $019138|!BankB

			PLA
			STA !14E0,x
			PLA
			STA !E4,x
			
			LDY !C2,x
			LDA !1588,x
			AND BLOCKED_STATE,y
			BEQ RETURN1

			LDA #$18		;shake ground
          		STA $1887|!Base2
			
			LDA !7FAB10,x		; \ 
			AND #$04		; | if the Extra Bit is set, decrease sprite state
			BEQ NO_EXTRA_BIT	; |
			LDA !C2,x		; |
			DEC			; |
			BRA STORE		; |
NO_EXTRA_BIT:		LDA !C2,x		; |
			INC			; | otherwise increase
STORE:			AND #$03  		; |
			STA !C2,x		; /

          		LDA #$09	    ;play sound effect
          		STA $1DFC|!Base2

			LDA !TIME_TO_ATTACK,x
			STA !1540,x

			INC !1534,x
RETURN1:		RTS                     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GFX:		%GetDrawInfo()

			LDA !1528,x
			STA $02
			PHX
			LDX #$03
			CMP #$00
			BEQ LOOP_START
			INX
LOOP_START:		LDA $00
			CLC
			ADC X_OFFSET,x
			STA $0300|!Base2,y

			LDA $01
			CLC
			ADC Y_OFFSET,x
			STA $0301|!Base2,y

			LDA PROPERTIES,x
			ORA $64
			STA $0303|!Base2,y

			LDA TILE_MAP,x
			CPX #$04
			BNE NORMAL_TILE
			PHX
			LDX $02
			CPX #$02
			BNE NOT_ANGRY
			LDA #!ANGRY_TILE
NOT_ANGRY:		PLX
NORMAL_TILE:		STA $0302|!Base2,y

			INY
			INY
			INY
			INY
			DEX
			BPL LOOP_START

			PLX

			LDY #$02
			LDA #$04
			JSL $01B7B3|!BankB
			RTS