;a door that forces you to enter
;needs to be act as 1F
db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

MarioBelow:
MarioAbove:
MarioSide:

TopCorner:
RTL
BodyInside:
HeadInside:
LDA $72
BNE MarioFireball
LDA $94						
CLC							
ADC.b #$04					
AND.b #$0F					
CMP.b #$08	
BCS MarioFireball
LDA #%00001000
TSB $15
TSB $16				
WallFeet:
WallBody:

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
RTL
print "A door that forces you to enter"
