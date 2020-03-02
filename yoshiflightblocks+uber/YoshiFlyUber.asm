;Yoshi Fly - Adds a freeRAM trigger which gives Yoshi permanent flight like the Yoshi wing sublevels in vanilla
;by dtothefourth

!Toggle = $7FB520	;FreeRAM must match the blocks or whatever you want to trigger it with
!Timer  = $7FB521	;FreeRAM
!YoshiColor = $7FB522
!Timed	= 0			; 0 for infinite / disabled by blocks 1 for timed
!Length = #$40		; How long to last if timed, in 4 frame increments
!bluepalette = $06
if !sa1 == 1
	!Timer = $408520		
	!Toggle = $408521
	!YoshiColor = $408522
endif
init:
	LDA #$00
	STA !Toggle
	STA !YoshiColor
	RTL

main:
	LDA !Toggle
	BEQ +

	LDA #$02
	STA $141E|!addr
	STA $1410|!addr
	
	LDX #!sprite_slots-1		;loop throught all the sprites, find yoshi and give him a great blue palette
	.loop
	LDA !9E,X
	CMP #$35
	BNE .skip
	LDA !15F6,X
	AND #%11110001	;preserve his other YXPPCCCT properties
	ORA #!bluepalette	;add the palette in
	STA !15F6,X
	.skip
	DEX 
	BPL .loop
	
	if !Timed

	LDA !Timer
	DEC
	BNE ++
	STA !Toggle
	++
	STA !Timer

	endif

	+

	RTL