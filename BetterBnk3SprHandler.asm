if read1($00FFD5) == $23
    sa1rom
    !9E = $3200
else
    !9E = $9E
endif

; Sprites handled by Bnk3CallSprMain
org $03A263
    RTS : NOP       ; nuke the PLB : RTL that bowser has.
org $03A118
Bnk3CallSprMain:
	PHB							
	PHK							
	PLB
    PEA .return-1							
	LDA !9E,x
    CMP #$A0
    BCS .skipSearch			
    LDY #$03<<1     ; this will all make sense
    .findlowindexloop
    CMP LowIdIndexes,y
    BNE +
    JMP CallSprite
    +
    DEY #2          ; yes the reason I'm doubling Y is so that I don't have to do TYA : ASL : TAY, since the cycle count is the same
    BPL .findlowindexloop
    .skipSearch
    SBC #$A0        ; carry is already set
    ASL 
    TAY 
    LDA Bnk3Sprites+1,y
    STA $01
    LDA Bnk3Sprites,y
    STA $00
    JMP ($0000)					

LowIdIndexes:
dw $001B, $0051, $007A, $007C       ; trust me there's a reason these are 2 bytes each

LowIdTable:
dw $8012-1	;$1B -> Football                     
dw $C34C-1	;$51 -> Ninji                        
dw $C816-1	;$7A -> FireworkMain                 
dw $AC97-1	;$7C -> PrincessPeach


Bnk3Sprites:
dw $A259	;$A0 -> BowserFight                  
dw $B163	;$A1 -> BowserBowlingBall            
dw $B2A9	;$A2 -> MechaKoopa
CallSprite: ;$A3-$A7   -> CallSprite subroutine
    LDA LowIdTable+1,y
    PHA
    LDA LowIdTable,y
    PHA
    RTS     ; using RTS instead of JMP ($0000) because I don't have enough bytes, it's only 1 cycle difference anyway
    NOP     ; ugh alignment
dw $9F38	;$A8 -> Blargg                       
dw $9890	;$A9 -> Reznor                       
dw $96F6	;$AA -> Fishbone                     
dw $9517	;$AB -> RexMainRt                    
dw $9423	;$AC -> WoodenSpike                  
dw $9423	;$AD -> WoodenSpike                  
dw $9065	;$AE -> FishinBoo
.return   	; yes I'm really doing this
dw $6BAB  	;$AF -> Translates to PLB : RTL            
dw $8F7A	;$B0 -> BooStream                    
dw $9284	;$B1 -> CreateEatBlock               
dw $9214	;$B2 -> FallingSpike                 
dw $8EEC	;$B3 -> StatueFireball 
dw $0000  	;$B4 -> Unused  Will find a use for these 1 day
dw $0000  	;$B5 -> Unused              
dw $8F75	;$B6 -> ReflectingFireball           
dw $8C2F	;$B7 -> CarrotTopLift                
dw $8C2F	;$B8 -> CarrotTopLift                
dw $8D6F	;$B9 -> InfoBox                      
dw $8DBB	;$BA -> TimedLift                    
dw $8E79	;$BB -> GrayCastleBlock              
dw $8A3C	;$BC -> BowserStatue                 
dw $8958	;$BD -> SlidingKoopa                 
dw $88A3	;$BE -> Swooper                      
dw $8770	;$BF -> MegaMole                     
dw $86FF	;$C0 -> GrayLavaPlatform             
dw $85F6	;$C1 -> FlyingTurnBlocks             
dw $84CA	;$C2 -> Blurp                        
dw $852F	;$C3 -> PorcuPuffer                  
dw $8454	;$C4 -> GrayFallingPlat              
dw $8087	;$C5 -> BigBooBoss                   
dw $C4DC	;$C6 -> DarkRoomWithLight            
dw $C30F	;$C7 -> InvisMushroom                
dw $C1F5	;$C8 -> LightSwitch                  

warnpc $03A258