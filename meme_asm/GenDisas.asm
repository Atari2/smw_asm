
	
Print "INIT ",pc
	LDA #$02
	STA $18B9|!addr
	RTL
Print "MAIN ",pc
PHB
PHK
PLB
JSR GenParaEnemy
PLB
RTL

DATA_02B31F:					;$02B31F	| Table of the sprites each Para-X generator spawns. Each generator can spawn two different sprites.
	db $3F,$40,$3F,$40,$3F,$40						; Sprite B

DATA_02B325:					;$02B325	| Initial X speeds for the Para-X generator sprites.
	db $FA,$FB,$FC,$FD

SpriteToSpawn:
	db $0F,$0D
	
GenParaEnemy:					;-----------| Para-Goomba/Bob-Omb generator MAIN.
	LDA $14						;$02B329	|\ 
	AND.b #$7F					;$02B32B	|| Return if not time to generate a Para-enemy.
	BNE Return02B386			;$02B32D	|/			
	LDA #$05					;$02B33B	||
	%Random()
	TAY
	LDA.w DATA_02B31F,Y		;$02B348	||
	PHA
	SEC
	%SpawnSprite()
	BCS Return02B386
	TYX
	PLA
	CMP #$40
	BEQ +
	LDY #$00
	BRA ++
	+
	LDY #$01
	++
	LDA SpriteToSpawn,y
	STA !extra_byte_1,x
	LDA $1C						;$02B351	|\ 
	SEC							;$02B353	||
	SBC.b #$20					;$02B354	||
	STA !D8,X					;$02B356	|| Set spawn Y position just above the screen.
	LDA $1D						;$02B358	||
	ADC.b #$00					;$02B35A	||
	STA.w !14D4,X				;$02B35C	|/
	LDA.w $148D					;$02B35F	|\ 
	AND.b #$FF					;$02B362	||
	CLC							;$02B364	||
	ADC.b #$30					;$02B365	|| Set spawn X at a random side of the screen.
	PHP							;$02B367	||
	ADC $1A						;$02B368	||
	STA $E4,X					;$02B36A	||
	PHP							;$02B36C	||
	AND.b #$0E					;$02B36D	||\ Set a random initial angle.
	STA.w $1570,X				;$02B36F	||/
	LSR							;$02B372	||\ 
	AND.b #$03					;$02B373	|||
	TAY							;$02B375	||| Set a random initial X speed.
	LDA.w DATA_02B325,Y			;$02B376	|||
	STA $B6,X					;$02B379	||/
	LDA $1B						;$02B37B	||
	PLP							;$02B37D	||
	ADC.b #$00					;$02B37E	||
	PLP							;$02B380	||
	ADC.b #$00					;$02B381	||
	STA.w $14E0,X				;$02B383	|/
Return02B386:					;			|
	RTS							;$02B386	|
