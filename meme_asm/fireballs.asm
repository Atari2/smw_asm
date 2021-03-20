;extra byte 1 has timer for the shoot
;extra byte 2 has the speed of the projectile

print "INIT ",pc

InitSprite:				;load the timer for the fireball
LDA !extra_byte_1,x
STA !1540,x
RTL

print "MAIN ",pc
PHB 
PHK
PLB 
JSR SpriteMain
PLB 
RTL

SpriteMain:

LDA #$00
%SubOffScreen()

LDA !14C8,X
BEQ .return

JSR Graphics		
LDA $9D			;if game locked, return
BNE .return

JSL $01A7DC		;if in contact with mario, hurt him
BCC +
JSL $00F5B7
+

LDA !1540,x		;if timer is 00, shoot and reset the timer
BNE .return

LDA !extra_byte_1,x
STA !1540,x

LDA #$02
%SpawnExtended()

LDA !E4,x      
STA !extended_x_low,y
STA $00               
LDA !14E0,x           
SEC : SBC #$00    
STA !extended_x_high,y
STA $01           

LDA	!D8,x           
STA !extended_y_low,y 
STA $02                
LDA !14D4,x
SEC : SBC #$00        
STA !extended_y_high,y     
STA $03   
     
REP #$20                   
LDA $00                 
SEC : SBC $94
STA $00                 
LDA $02                 
SEC : SBC $96
SBC #$0010              
STA $02                 
SEP #$20  
              
PHY
LDA !extra_byte_2,x
%Random()
CLC : ADC #$10
BNE +
LDA #$10
+
%Aiming()
PLY 

LDA $00                
STA !extended_x_speed,y 
LDA $02                
STA !extended_y_speed,y 

.return 
RTS 

Graphics:
%GetDrawInfo()
LDA $00
STA $0300,y
LDA $01
STA $0301,y
LDA #$2E
STA $0302,y
LDA #%00000010
STA $0303,y
LDA #$00
LDY #$02
JSL $01B7B3
RTS
