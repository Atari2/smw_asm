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
	BNE +		;if it's already toggled, don't bother
	LDA #$01
	STA !Toggle
	PHX			;better safe than sorry amiright
	LDX #!sprite_slots-1	
	.loop
	LDA !9E,x
	CMP #$35
	BNE .skip
	LDA !15F6,x	
	STA !YoshiColor	;loop throught all the sprite slots, find yoshi, and save his original palette
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
