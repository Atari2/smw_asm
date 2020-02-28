; Dino Rhino/Torch misc RAM:
	; $C2   - Pointers to different routines. Fire is unused in the Rhino.
	;		   0 = walking, 1 = fire horz, 2 = fire vert, 3 = jumping
	; $151C - Length of the Dino Torch's flame (0 = max, 4 = none). Also set for the Rhino at spawn, but otherwise unused.
	; $1540 - Timer to wait before starting/stopping a flame. Rhino sets on spawn but doesn't use.
	; $1570 - Frame counter for animation.
	; $157C - Horizontal direction the sprite is facing.
	; $1602 - Animation frame.
	; 0/1 = walking, 2 = fire sideways, 3 = fire up

incsrc "dino_rhino_tables.asm" ;get all the tables!

print "INIT ",pc
InitDinos:						;-----------| Dino Rhino INIT
	LDA.b #$04					;$018558	| Set the length of the Dino Torch's flame to none (?) 
	STA.w $151C,X				;$01855A	| This is actually part of the bob-omb init routine, gets reused for this
	LDA.b #$FF					;$01855D	|
	STA.w $1540,X				;$01855F	| Set the timer to wait before starting a flame to #$FF 
	JSR FaceMario				;$018562	|

print "MAIN ",pc
DinoMainRt:
	PHB							;$039C3F	|
	PHK							;$039C40	|
	PLB							;$039C41	|
    WDM
	JSR DinoMainSubRt			;$039C42	| Calls main routine
	PLB							;$039C45	|
	RTL							;$039C46	|
FaceMario:						;-----------| Subroutine to make a sprite face Mario.
	%SubHorzPos()			    ;$01857C	|
	TYA							;$01857F	|
	STA.w !157C,X				;$018580	|					;			|
	RTS		

DinoMainSubRt:
	JSR DinoGfxRt				;$039C47	| Draw graphics.
	LDA $9D						;$039C4A	|\ 
	BNE Return039CA3			;$039C4C	||
	LDA.w $14C8,X				;$039C4E	|| Return if game frozen or sprite dead.
	CMP.b #$08					;$039C51	||
	BNE Return039CA3			;$039C53	|/
    LDA #$03
	%SubOffScreen()		        ;$039C55	| Process offscreen from -$40 to +$30.
	JSL $01A7DC		            ;$039C58	| Process interaction with Mario.
	JSL $01802A			        ;$039C5C	| Update X/Y position, apply gravity, and process block interaction.
	LDA $C2,X					;$039C60	|
	JSL $0086DF				    ;$039C62	| ExecutePtr , routine to jump to a 16-bit address in a table, basically JSR (addr,x). A contains the index to jump to

CODE_039C74:					;-----------| Dino Rhino/Torch rhino 3 - Jumping
	LDA $AA,X					;$039C74	|\ 
	BMI CODE_039C89				;$039C76	||
	STZ $C2,X					;$039C78	||
	LDA.w $1588,X				;$039C7A	|| Return to state 0 if it starts falling,
	AND.b #$03					;$039C7D	||  and invert direction if it's hitting a wall at that time.
	BEQ CODE_039C89				;$039C7F	||
	LDA.w $157C,X				;$039C81	||
	EOR.b #$01					;$039C84	||
	STA.w $157C,X				;$039C86	|/
CODE_039C89:					;			|
	STZ.w $1602,X				;$039C89	|
	LDA.w $1588,X				;$039C8C	|\ 
	AND.b #$03					;$039C8F	||
	TAY							;$039C91	||
	LDA $E4,X					;$039C92	||
	CLC							;$039C94	|| Push back from walls.
	ADC.w DATA_039C6E,Y			;$039C95	||
	STA $E4,X					;$039C98	||
	LDA.w $14E0,X				;$039C9A	||
	ADC.w DATA_039C71,Y			;$039C9D	||
	STA.w $14E0,X				;$039CA0	|/
Return039CA3:					;			|
	RTS							;$039CA3	|



CODE_039CA8:					;-----------| Dino Rhino/Torch phase 0 - Walking
	LDA.w $1588,X				;$039CA8	|\ 
	AND.b #$04					;$039CAB	|| If not on the ground, push the Rhino back from walls and return.
	BEQ CODE_039C89				;$039CAD	|/
	LDA.w $1540,X				;$039CAF	|\ 
	BNE CODE_039CC8				;$039CB2	||
	LDA $9E,X					;$039CB4	||
	CMP.b #$6E					;$039CB6	||
	BEQ CODE_039CC8				;$039CB8	|| If the Dino Torch's timer hits 0, spit fire in a random direction.
	LDA.b #$FF					;$039CBA	||
	STA.w $1540,X				;$039CBC	||
	JSL GetRand					;$039CBF	||
	AND.b #$01					;$039CC3	||
	INC A						;$039CC5	||
	STA $C2,X					;$039CC6	|/
CODE_039CC8:					;			|
	TXA							;$039CC8	|\ 
	ASL							;$039CC9	||
	ASL							;$039CCA	||
	ASL							;$039CCB	||
	ASL							;$039CCC	||
	ADC $14						;$039CCD	|| Turn towards Mario every 64 frames. (when on the ground)
	AND.b #$3F					;$039CCF	||
	BNE CODE_039CDA				;$039CD1	||
	%SubHorzPos()			    ;$039CD3	|| SubHorzPosBnk3
	TYA							;$039CD6	||
	STA.w $157C,X				;$039CD7	|/
CODE_039CDA:					;			|
	LDA.b #$10					;$039CDA	|\ Set ground Y speed.
	STA $AA,X					;$039CDC	|/
	LDY.w $157C,X				;$039CDE	|\ 
	LDA $9E,X					;$039CE1	||
	CMP.b #$6E					;$039CE3	||
	BEQ CODE_039CE9				;$039CE5	||
	INY							;$039CE7	|| Set X speed.
	INY							;$039CE8	||
CODE_039CE9:					;			||
	LDA.w DinoSpeed,Y			;$039CE9	||
	STA $B6,X					;$039CEC	|/
	JSR DinoSetGfxFrame			;$039CEE	| Animate the Dino Rhino/Torch's walking.
	LDA.w $1588,X				;$039CF1	|\ 
	AND.b #$03					;$039CF4	|| If it runs into a block, jump.
	BEQ Return039D00			;$039CF6	||
	LDA.b #$C0					;$039CF8	||| Jump speed.
	STA $AA,X					;$039CFA	||
	LDA.b #$03					;$039CFC	||
	STA $C2,X					;$039CFE	|/
Return039D00:					;			|
	RTS							;$039D00	|

CODE_039D41:					;-----------| Dino Rhino/Torch phase 1/2- Horizontal/Vertical fire
	STZ $B6,X					;$039D41	| Clear X speed.
	LDA.w $1540,X				;$039D43	|\\ 
	BNE DinoFlameTimerSet		;$039D46	||| If done shooting fire, return to phase 0.
	STZ $C2,X					;$039D48	||/
	LDA.b #$40					;$039D4A	||
	STA.w $1540,X				;$039D4C	||
	LDA.b #$00					;$039D4F	||
DinoFlameTimerSet:				;			||
	CMP.b #$C0					;$039D51	||\ Branch if not time to play the fire sound.
	BNE CODE_039D5A				;$039D53	||/
	LDY.b #$17					;$039D55	||\ SFX for the Dino Torch shooting fire.
	STY.w $1DFC					;$039D57	|//
CODE_039D5A:					;			|
	LSR							;$039D5A	|\ 
	LSR							;$039D5B	||
	LSR							;$039D5C	||
	LDY $C2,X					;$039D5D	||
	CPY.b #$02					;$039D5F	||
	BNE CODE_039D66				;$039D61	||
	CLC							;$039D63	|| Get current frame of animation for the Dino Rhino.
	ADC.b #$20					;$039D64	||
CODE_039D66:					;			||
	TAY							;$039D66	||
	LDA.w DinoFlameTable,Y		;$039D67	||
	PHA							;$039D6A	||
	AND.b #$0F					;$039D6B	||
	STA.w $1602,X				;$039D6D	|/
	PLA							;$039D70	|\ 
	LSR							;$039D71	||
	LSR							;$039D72	||
	LSR							;$039D73	|| Get height of the flame, and return if not at full length.
	LSR							;$039D74	||
	STA.w $151C,X				;$039D75	||
	BNE Return039D9D			;$039D78	|/
	LDA $9E,X					;$039D7A	|\ 
	CMP.b #$6E					;$039D7C	||
	BEQ Return039D9D			;$039D7E	||
	TXA							;$039D80	||
	EOR $13						;$039D81	|| Return if:
	AND.b #$03					;$039D83	|| - Sprite is not the Dino Torch.
	BNE Return039D9D			;$039D85	|| - Not a frame to process interaction with Mario.
	JSR DinoFlameClipping		;$039D87	|| - The flame is not in contact with Mario.
	JSL $03B664		            ;$039D8A	|| - Mario has invulnerability frames. GetMarioClipping
	JSL $03B72B			        ;$039D8E	|| - CheckForContact
	BCC Return039D9D			;$039D92	||
	LDA.w $1490					;$039D94	||
	BNE Return039D9D			;$039D97	|/
	JSL $00F5B7				    ;$039D99	| Hurt Mario.
Return039D9D:					;			|
	RTS							;$039D9D	|

DinoFlameClipping:				;-----------| Subroutine to get clipping data for the Dino Torch's flame.
	LDA.w $1602,X				;$039DB6	|\ 
	SEC							;$039DB9	||
	SBC.b #$02					;$039DBA	||
	TAY							;$039DBC	|| Get index to the above tables for the flame.
	LDA.w $157C,X				;$039DBD	||
	BNE CODE_039DC4				;$039DC0	||
	INY							;$039DC2	||
	INY							;$039DC3	|/
CODE_039DC4:					;			|
	LDA $E4,X					;$039DC4	|\ 
	CLC							;$039DC6	||
	ADC.w DinoFlame1,Y			;$039DC7	||
	STA $04						;$039DCA	|| Get clipping X position.
	LDA.w $14E0,X				;$039DCC	||
	ADC.w DinoFlame2,Y			;$039DCF	||
	STA $0A						;$039DD2	|/
	LDA.w DinoFlame3,Y			;$039DD4	|\ Get clipping width.
	STA $06						;$039DD7	|/
	LDA $D8,X					;$039DD9	|\ 
	CLC							;$039DDB	||
	ADC.w DinoFlame4,Y			;$039DDC	||
	STA $05						;$039DDF	|| Get clipping Y position.
	LDA.w $14D4,X				;$039DE1	||
	ADC.w DinoFlame5,Y			;$039DE4	||
	STA $0B						;$039DE7	|/
	LDA.w DinoFlame6,Y			;$039DE9	|\ Get clipping height.
	STA $07						;$039DEC	|/
	RTS							;$039DEE	|



DinoSetGfxFrame:				;-----------| Subroutine to handle animating the Dino Rhino / Torch's walk cycle.
	INC.w $1570,X				;$039DEF	|\ 
	LDA.w $1570,X				;$039DF2	||
	AND.b #$08					;$039DF5	||
	LSR							;$039DF7	|| Set animation frame (0/1).
	LSR							;$039DF8	||
	LSR							;$039DF9	||
	STA.w $1602,X				;$039DFA	|/
	RTS							;$039DFD	|

DinoGfxRt:						;-----------| Dino Rhino/Torch GFX routine
	%GetDrawInfo()			    ;$039E49	|
	LDA.w $157C,X				;$039E4C	|\ $02 = horizontal direction
	STA $02						;$039E4F	|/
	LDA.w $1602,X				;$039E51	|\ $04 = animation frame
	STA $04						;$039E54	|/
	LDA $9E,X					;$039E56	|\ 
	CMP.b #$6F					;$039E58	|| Branch for the Dino Torch.
	BEQ CODE_039EA9				;$039E5A	|/
	PHX							;$039E5C	|
	LDX.b #$03					;$039E5D	|
CODE_039E5F:					;```````````| Dino Rhino tile loop.
	STX $0F						;$039E5F	|
	LDA $02						;$039E61	|\ 
	CMP.b #$01					;$039E63	||
	BCS CODE_039E6C				;$039E65	||
	TXA							;$039E67	||
	CLC							;$039E68	|| Store YXPPCCCT to OAM.
	ADC.b #$04					;$039E69	||
	TAX							;$039E6B	||
CODE_039E6C:					;			||
	LDA.w DinoRhinoGfxProp,X	;$039E6C	||
	STA.w $0303,Y				;$039E6F	|/
	LDA.w DinoRhinoTileDispX,X	;$039E72	|\ 
	CLC							;$039E75	|| Store X position to OAM.
	ADC $00						;$039E76	||
	STA.w $0300,Y				;$039E78	|/
	LDA $04						;$039E7B	|\ 
	CMP.b #$01					;$039E7D	||
	LDX $0F						;$039E7F	|| Store Y position to OAM.
	LDA.w DinoRhinoTileDispY,X	;$039E81	||  Make the Dino Rhino shift up and down with the walk animation as well.
	ADC $01						;$039E84	||
	STA.w $0301,Y				;$039E86	|/
	LDA $04						;$039E89	|\ 
	ASL							;$039E8B	||
	ASL							;$039E8C	||
	ADC $0F						;$039E8D	|| Store tile number to OAM.
	TAX							;$039E8F	||
	LDA.w DinoRhinoTiles,X		;$039E90	||
	STA.w $0302,Y				;$039E93	|/
	INY							;$039E96	|\ 
	INY							;$039E97	||
	INY							;$039E98	||
	INY							;$039E99	|| Loop for all tiles.
	LDX $0F						;$039E9A	||
	DEX							;$039E9C	||
	BPL CODE_039E5F				;$039E9D	|/
	PLX							;$039E9F	|
	LDA.b #$03					;$039EA0	|\ 
	LDY.b #$02					;$039EA2	|| Upload 4 16x16 tiles.
	JSL $01B7B3			        ;$039EA4	|/ FinishOAMWrite
	RTS							;$039EA8	|


CODE_039EA9:					;```````````| Dino Torch GFX routine.
	LDA.w $151C,X				;$039EA9	|\ $03 = length of the torch's flame (4 = none, 0 = max)
	STA $03						;$039EAC	|/
	LDA.w $1602,X				;$039EAE	|\ $04 = animation frame (this was already set though, so useless).
	STA $04						;$039EB1	|/
	PHX							;$039EB3	|
	LDA $14						;$039EB4	|\ 
	AND.b #$02					;$039EB6	||
	ASL							;$039EB8	||
	ASL							;$039EB9	||
	ASL							;$039EBA	||
	ASL							;$039EBB	||
	ASL							;$039EBC	|| $05 = animation frame for the flame
	LDX $04						;$039EBD	||
	CPX.b #$03					;$039EBF	||
	BEQ CODE_039EC4				;$039EC1	||
	ASL							;$039EC3	||
CODE_039EC4:					;			||
	STA $05						;$039EC4	|/
	LDX.b #$04					;$039EC6	|
CODE_039EC8:					;```````````| Dino Torch tile loop
	STX $06						;$039EC8	|
	LDA $04						;$039ECA	|\ 
	CMP.b #$03					;$039ECC	||
	BNE CODE_039ED5				;$039ECE	||
	TXA							;$039ED0	||
	CLC							;$039ED1	||
	ADC.b #$05					;$039ED2	||
	TAX							;$039ED4	||
CODE_039ED5:					;			||
	PHX							;$039ED5	|| Store X position to OAM.
	LDA.w DinoTorchTileDispX,X	;$039ED6	||  Invert offset if facing right.
	LDX $02						;$039ED9	||
	BNE CODE_039EE0				;$039EDB	||
	EOR.b #$FF					;$039EDD	||
	INC A						;$039EDF	||
CODE_039EE0:					;			||
	PLX							;$039EE0	||
	CLC							;$039EE1	||
	ADC $00						;$039EE2	||
	STA.w $0300,Y				;$039EE4	|/
	LDA.w DinoTorchTileDispY,X	;$039EE7	|\ 
	CLC							;$039EEA	|| Store Y position to OAM.
	ADC $01						;$039EEB	||
	STA.w $0301,Y				;$039EED	|/
	LDA $06						;$039EF0	|\ 
	CMP.b #$04					;$039EF2	||
	BNE CODE_039EFD				;$039EF4	||
	LDX $04						;$039EF6	||
	LDA.w DinoTorchTiles,X		;$039EF8	|| Store tile number to OAM.
	BRA CODE_039F00				;$039EFB	||
CODE_039EFD:					;			||
	LDA.w DinoFlameTiles,X		;$039EFD	||
CODE_039F00:					;			||
	STA.w $0302,Y				;$039F00	|/
	LDA.b #$00					;$039F03	|\ 
	LDX $02						;$039F05	||
	BNE CODE_039F0B				;$039F07	||
	ORA.b #$40					;$039F09	||
CODE_039F0B:					;			||
	LDX $06						;$039F0B	||
	CPX.b #$04					;$039F0D	|| Store YXPPCCCT to OAM.
	BEQ CODE_039F13				;$039F0F	||
	EOR $05						;$039F11	||
CODE_039F13:					;			||
	ORA.w DinoTorchGfxProp,X	;$039F13	||
	ORA $64						;$039F16	||
	STA.w $0303,Y				;$039F18	|/
	INY							;$039F1B	|\ 
	INY							;$039F1C	||
	INY							;$039F1D	||
	INY							;$039F1E	|| Loop for all tiles.
	DEX							;$039F1F	||
	CPX $03						;$039F20	||
	BPL CODE_039EC8				;$039F22	|/
	PLX							;$039F24	|
	LDY.w $151C,X				;$039F25	|\ 
	LDA.w DinoTilesWritten,Y	;$039F28	|| Upload some number of 16x16 tiles.
	LDY.b #$02					;$039F2B	||
	JSL $01B7B3			        ;$039F2D	|/ FinishOAMWrite
	RTS							;$039F31	|

GetRand:						;-----------| Random number generation routine. Outputs in $148C/$148D (returns $148C)
	PHY							;$01ACF9	|
	LDY.b #$01					;$01ACFA	|
	JSL CODE_01AD07				;$01ACFC	| Run RNG for high byte.
	DEY							;$01AD00	|
	JSL CODE_01AD07				;$01AD01	| Run RNG for low byte.
	PLY							;$01AD05	|
	RTL							;$01AD06	|

CODE_01AD07:
	LDA.w $148B					;$01AD07	|\ 
	ASL							;$01AD0A	||
	ASL							;$01AD0B	|| With a = $148B:
	SEC							;$01AD0C	||  a = 5a + 1;
	ADC.w $148B					;$01AD0D	||
	STA.w $148B					;$01AD10	|/
	ASL.w $148C					;$01AD13	|\ 
	LDA.b #$20					;$01AD16	||
	BIT.w $148C					;$01AD18	|| With b = $148C:
	BCC CODE_01AD21				;$01AD1B	||  if (b.4 = b.7) {
	BEQ CODE_01AD26				;$01AD1D	||    b = 2b + 1;
	BNE CODE_01AD23				;$01AD1F	||  } else {
CODE_01AD21:					;			||    b = 2b;
	BNE CODE_01AD26				;$01AD21	||  }
CODE_01AD23:					;			||
	INC.w $148C					;$01AD23	|/
CODE_01AD26:					;			|
	LDA.w $148C					;$01AD26	|\ 
	EOR.w $148B					;$01AD29	|| Invert byte B with byte A and output the result.
	STA.w $148D,Y				;$01AD2C	|/
	RTL							;$01AD2F	|
