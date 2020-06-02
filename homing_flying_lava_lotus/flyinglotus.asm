;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Flying Volcano Lotus by Darolac
;
; This volcano lotus will fly around with customisable X and Y speed. 
; If the extra bit is clear, it will fly in the top-left direction. If it's set, it will fly in the
; bottom-right one. You can also make them oscilate horizontally (extra bit clear) or vertically (extra 
; bit set) based on a define. Finally, you can completely set its X and Y speed with extra bytes, the first one 
; for the Y speed and the second one for the X speed (those will overrite their previous speed).
;
; Usage with NMSTL is recommended. Based on Volcano Lotus dissasembly by Nekoh.
!home = $01				;00 to not home, 01 to home
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        print "INIT ",pc
        LDA !extra_byte_4,x
        SEC
        SBC #$08
        STA !1594,x
        LDY #$80
		LDA #!home
		ASL #2
        BEQ +
        TYA
+       STA !1FD6,x
        RTL  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                           
                           print "MAIN", pc
                           PHB                       
                           PHK                       
                           PLB                             
                           JSR FVolcanoLotus         
                           PLB                       
                           RTL                       ; Return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!pollen_to_spawn        = $04   ;   Amount of pollen the volcano lotus will spawn.
                                ;   Modify the speed tables below to add more speed values if you change this!
!pollen_number          = $00   ;   Extended sprite number of the pollen/projectile. As you put it in PIXI's list.txt

!pollen_number         := !pollen_number+$13

!only1direction = 1 ; this controls whenether the volcano lotus moves only in one direction,
					; oscilating, or not.

!XSpeed = $0C ; X speed if extra bytes are clear and !only1direction is clear.

YAccel:

db -$01,$01

XSpeed:

db -!XSpeed,!XSpeed

MaxYSpeed:

db -$10,$10

MaxSpeed:

db -$28,$28

Direc:

db -$02,$02

Return:

RTS

FVolcanoLotus:      JSR VolcanoLotusGfx     
                    LDA !14C8,x			; \ 
					EOR #$08			; |load sprite status, check if default/alive, 
					ORA $9D				; |sprites/animation locked flag 
					BNE Return
					%SubOffScreen()
                    STZ !151C,X             
                    JSL $01803A|!BankB 

					LDA !extra_byte_1,x
					ORA !extra_byte_2,x
					BNE Noset
					
					LDY !1570,x
					
					if !only1direction = 0
					
					LDA $14
					AND #$01
					BNE NoAccel
					LDA !AA,x
					CLC
					ADC YAccel,y
					STA !AA,x
					CMP MaxYSpeed,y
					BNE NoAccel
					LDA !1570,x
					EOR #$01
					STA !1570,x
					NoAccel:
					
					LDA !7FAB10,x
					AND #$04
					LSR #2
					TAY
					
					LDA XSpeed,y
					STA !B6,x
					PHY
					JSL $018022|!BankB
					PLY
					LDA !AA,x
					PHA
					SEC
					SBC Direc,y
					STA !AA,x
					JSL $01801A|!BankB	; update sprite Y position without gravity
					PLA
					STA !AA,x
					else
					
					LDA $14
					AND #$01
					BNE NoAccel
					
					LDA !7FAB10,x
					AND #$04
					BEQ X
					
					LDA !AA,x
					CLC
					ADC YAccel,y
					STA !AA,x
					JSL $01801A|!BankB
					LDY !1570,x
					LDA !AA,x
					CMP MaxSpeed,y
					BNE NoAccel
					LDA !1570,x
					EOR #$01
					STA !1570,x
					BRA NoAccel
					X:
					
					LDA !B6,x
					CLC
					ADC YAccel,y
					STA !B6,x
					JSL $018022|!BankB
					LDY !1570,x
					LDA !B6,x
					CMP MaxSpeed,y
					BNE NoAccel
					LDA !1570,x
					EOR #$01
					STA !1570,x
					
					
					NoAccel:
					
					endif
					BRA Alreadyset
					Noset:	
					
					LDA !extra_byte_1,x
					STA !AA,x
                    JSL $01801A|!BankB
					LDA !extra_byte_2,x
					STA !B6,x
					JSL $018022|!BankB
					
					Alreadyset:

CODE_02DFBC:        LDA !C2,X     
                    JSL $0086DF          

VolcanoLotusPtrs:   dw CODE_02DFC9&$FFFF           
                    dw CODE_02DFDF&$FFFF           
                    dw CODE_02DFEF&$FFFF           

Return02DFC8:       RTS                          ; Return 

CODE_02DFC9:        LDA !1540,X             
                    BNE CODE_02DFD6           
                    LDA #$40                
CODE_02DFD0:        STA !1540,X             
                    INC !C2,X     
                    RTS                          ; Return 

CODE_02DFD6:        LSR                       
                    LSR                       
                    LSR                       
                    AND #$01                
                    STA !1602,X             
                    RTS                          ; Return 

CODE_02DFDF:        LDA !1540,X             
                    BNE CODE_02DFE8           
                    LDA #$40                
                    BRA CODE_02DFD0           

CODE_02DFE8:        LSR                       
                    AND #$01                
                    STA !151C,X             
                    RTS                          ; Return 

CODE_02DFEF:        LDA !1540,X             
                    BNE CODE_02DFFB           
                    LDA !extra_byte_3,x                
                    STA !1540,x     
                    STZ !C2,X     
CODE_02DFFB:        CMP !1594,x                
                    BNE CODE_02E002           
                    JSR CODE_02E079         
CODE_02E002:        LDA #$02                
                    STA !1602,X             
                    RTS                          ; Return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Volcano Lotus Graphics Routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


VolcanoLotusTiles:  db $8E,$9E,$E2

!Wing1 = #$5D
!Wing2 = #$C6

Tiles:

db !Wing2,!Wing1

Tilesize:

db $02,$00

XOffset1:

db -$0C,-$04

XOffset2:

db $0C,$0C

YOffset:

db -$07,$01

VolcanoLotusGfx:    
					%GetDrawInfo()

LDA $14
					LSR #3
					AND #$01
					TAX
					
					LDA $00
					STA $0E
					CLC
					ADC XOffset1,x
					STA $0300|!Base2,y
					LDA $00
					CLC
					ADC XOffset2,x
					STA $0304|!Base2,y
					
					LDA $01
					STA $0D
					CLC
					ADC YOffset,x
					STA $0301|!Base2,y
					STA $0305|!Base2,y

					LDA #$76
					STA $0303|!Base2,y
					LDA #$36
					STA $0307|!Base2,y
					
					LDA Tiles,x
					STA $0302|!Base2,y
					STA $0306|!Base2,y
					
					PHY				;
					TYA				;
					LSR #2			;
					TAY				;
					LDA Tilesize,x
					STA $461|!Base2,y
					STA $460|!Base2,y
					PLY
					
					LDX $15E9|!Base2
					LDA #$01			; we draw 2 tiles
					LDY #$FF			; custom sized tiles
					JSL $01B7B3|!BankB	; finish OAM write routine

					LDY !15EA,X
                    LDA $0E                   
                    SEC                       
                    SBC #$08                
                    STA $0310|!Base2,Y
					CLC                       
                    ADC #$08                
                    STA $0308|!Base2,Y    
                    CLC                       
                    ADC #$08                
                    STA $030C|!Base2,Y  					              
                    STA $0314|!Base2,Y
					
                    LDA $0D                   
                    DEC A                     
                    STA $0311|!Base2,Y
					STA $0309|!Base2,Y    
                    STA $030D|!Base2,Y 
                    STA $0315|!Base2,Y    
                    LDA #$80                
                    STA $0312|!Base2,Y          
                    STA $0316|!Base2,Y         
                    LDA !15F6,X     
                    ORA $64
					AND #$30                
                    ORA #$0B
                    STA $0313|!Base2,Y
                    ORA #$40                
                    STA $0317|!Base2,Y

                    LDA #$CE                
                    STA $0312|!Base2,Y          
                    STA $0316|!Base2,Y
  
                    PHX                       
                    LDA !1602,X             
                    TAX                       
                    LDA VolcanoLotusTiles,X 
                    STA $030A|!Base2,Y         
                    INC A                     
                    STA $030E|!Base2,Y         
                    PLX                       
                    LDA !151C,X             
                    CMP #$01                
                    LDA #$39                
                    BCC CODE_02E05B           
                    LDA #$35                
CODE_02E05B:        STA $030B|!Base2,Y     
                    STA $030F|!Base2,Y     
                    LDA !15EA,X   
                    CLC                       
                    ADC #$08                
                    STA !15EA,X

					PHY				;
					TYA				;
					LSR #2			;
					TAY				;
					LDA #$02
					STA $464|!Base2,y
					STA $465|!Base2,y
					LDA #$00
					STA $462|!Base2,y
					STA $463|!Base2,y
					PLY
					
					LDA #$03			; we draw 4 tiles
					LDY #$FF			; custom sized tiles
					JSL $01B7B3|!BankB	; finish OAM write routine
					
                    RTS                          ; Return         

pollen_x_speed:        db $10,$F0,$06,$FA
pollen_y_speed:        db $EC,$EC,$E8,$E8

CODE_02E079:        LDA !15A0,X 
                    ORA !186C,X 
                    BNE Return02E0C4          
                    LDA.b #!pollen_to_spawn-1               
                    STA $00                   
CODE_02E085:        LDY #$07                     ; \ Find a free extended sprite slot 
CODE_02E087:        LDA $170B|!Base2,Y                  ;  | 
                    BEQ CODE_02E090              ;  | 
                    DEY                          ;  | 
                    BPL CODE_02E087              ;  | 
                    RTS                          ; / Return if no free slots 

CODE_02E090:        LDA #!pollen_number                    
                    STA $170B|!Base2,Y                 
                    LDA !E4,X       
                    CLC                       
                    ADC #$04                
                    STA $171F|!Base2,Y   
                    LDA !14E0,X     
                    ADC #$00                
                    STA $1733|!Base2,Y   
                    LDA !D8,X       
                    STA $1715|!Base2,Y   
                    LDA !14D4,X     
                    STA $1729|!Base2,Y                          
                    LDX $00                   
                    LDA pollen_x_speed,X       
                    STA $1747|!Base2,Y   
                    LDA pollen_y_speed,X       
                    STA $173D|!Base2,Y   
					LDX $15E9|!Base2
					BIT !1FD6,x
					BPL NO_HOME
					LDA #$01
					STA $1765|!Base2,y
NO_HOME:			
					DEC $00
					BPL CODE_02E085
					LDA !1FD6,x
					BMI Return02E0C4
					EOR #$01
					STA !1FD6,x
Return02E0C4:       RTS                          ; Return 
    
