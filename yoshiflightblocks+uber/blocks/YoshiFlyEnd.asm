;Example block to trigger Yoshi Flight
;For use with YoshiFlyUber.asm
;by dtothefourth

!Toggle = $7FB520 ;FreeRAM, must match YoshiFlyUber.asm
!YoshiColor = $7FB522
!sprite_slots = 12
if !sa1 == 1
	!sprite_slots = 22
	!Toggle = $408521
	!YoshiColor = $408522
endif
db $42 ; enable corner and inside offsets
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireBall : JMP MarioCorner : JMP BodyInside : JMP HeadInside



HeadInside:
BodyInside:
	LDA $187A|!addr
	BEQ +
	LDA !Toggle
	BEQ +		;if it's not toggled, don't do anything
	LDA #$00		
	STA !Toggle	
	PHX			;better safe than sorry
	LDX #!sprite_slots-1
	.loop
	LDA !9E,x
	CMP #$35
	BNE .skip
	LDA !YoshiColor		;loop throught all the sprites, find yoshi, give him his palette back and zero out the previous one
	STA !15F6,X
	LDA #$00
	STA !YoshiColor
	BRA .end
	.skip
	DEX
	BPL .loop
	.end
	PLX
	+
MarioBelow:
MarioAbove:
MarioSide:
MarioCorner:
MarioFireBall:
MarioCape:
SpriteV:
SpriteH:
	RTL
