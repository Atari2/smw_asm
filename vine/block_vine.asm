!sprite = $00 	;sprite number to spawn
db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside

MarioBelow:
LDA #!sprite
SEC
%spawn_sprite_block() 
BCS MarioFireball
TAX
LDA #$3E
STA $1540,x
LDA #$2C
STA $154C,x
LDA $10
STA $01
STZ $00
TXA
%move_spawn_relative()
LDA #$03
STA $1DFC
LDA #$01
LDX #$0D
LDY #$00
%spawn_bounce_sprite()	;spawn the bounce sprite	
MarioAbove:
MarioSide:

TopCorner:
BodyInside:
HeadInside:

WallFeet:
WallBody:
RTL
SpriteV:
%check_sprite_kicked_vertical()
BCC MarioFireball
BCS +
SpriteH:
%check_sprite_kicked_horizontal()
BCC MarioFireball
+
%sprite_block_position()
MarioCape:
BRA MarioBelow
MarioFireball:
RTL

print "A block that spawns a vine"