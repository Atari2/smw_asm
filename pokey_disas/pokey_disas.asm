;;Pokey disassembly
	; If extra bit is set, it uses the extra byte 1 to determine how long the pokey should be
	; 01 -> 1 segment
	; 03 -> 2 segments
	; 07 -> 3 segments
	; 0F -> 4 segments
	; 1F -> 5 segments (maximum)
	; Pokey misc RAM:
	; $C2   - Number of segments in the Pokey, bitwise (---x xxxx). Bits will shift right to fill in any "holes" that appear, so that they stay sequential.
	;		   For the individual segments, it represents the number of segments that were above it in the Pokey. If 0, the segment is the head.
	; $151C - Non-sequential mirror of $C2 (holes do not get filled in until another piece is removed). Used for determining how much of the Pokey needs to "fall" when a middle segment is removed.
	; $1534 - Flag to decide whether the sprite is an actual Pokey or just a segment.
	; $1540 - Timer for the "falling" animation of the segments while they realign when a piece in the middle is removed.
	; $1558 - Timer to disable thrown sprites from hurting the Pokey. Set whenever a Pokey segment is knocked off.
	; $1570 - Frame counter for turning towards Mario.
	; $157C - Horizontal direction the sprite is moving in.

!NumberOfSegments = !extra_byte_1
!ExtraByteSpeed0 = !extra_byte_3
!ExtraByteSpeed1 = !extra_byte_2
!frames_check = !extra_byte_4

print "INIT ",pc

InitPokey:						;-----------| Pokey INIT
	%BEC(BitClear)				;			|| If the extra bit is clear branch
	LDA !NumberOfSegments,X			;			|| if set, use extra_byte_1 to determine the number of segments
	BRA StorePokeySize
	BitClear:
	LDA.b #$1F					;$01854B	|\\ Number of segments to give the Pokey when riding Yoshi, bitwise (---x xxxx). Max is 5 (1F).
	LDY.w $187A					;$01854D	||
	BNE StorePokeySize			;$018550	||
	LDA.b #$07					;$018552	||| Number of segments to give the Pokey when not riding Yoshi, bitwise (---x xxxx). Max is 5 (1F).
StorePokeySize:					;			|/
	STA $C2,X					;-----------| Subroutine to make a sprite face Mario.
	%SubHorzPos()				;$01857C	|
	TYA							;$01857F	|
	STA.w $157C,X				;$018580	|				;			|
	RTL						;$018583	|

	
print "MAIN ",pc
PokeyMain:						;-----------| Pokey MAIN
	PHB							;$02B636	|
	PHK							;$02B637	|
	PLB							;$02B638	|
	JSR PokeyMainRt				;$02B639	| Run main routine.
	LDA $C2,X					;$02B63C	|\ 
	PHX							;$02B63E	||
	LDX.b #$04					;$02B63F	||
	LDY.b #$00					;$02B641	||
PokeyLoopStart:					;			||
	LSR							;$02B643	||
	BCC BitNotSet				;$02B644	|| Count the number of segments remaining in the Pokey and change
	INY							;$02B646	||  the size of the its hitbox depending on how many are left.
BitNotSet:						;			||
	DEX							;$02B647	||
	BPL PokeyLoopStart			;$02B648	||
	PLX							;$02B64A	||
	LDA.w PokeyClipIndex,Y		;$02B64B	||
	STA.w $1662,X				;$02B64E	|/
	PLB							;$02B651	|
	RTL							;$02B652	|

PokeySpeed:						;$02B663	| X speeds for the Pokey.
	db $02,$FE

PokeyClipIndex:					;$02B630	| Clipping values ($1662) for the Pokey, corresponding to how many segments are left.
	db $1B,$1B,$1A,$19,$18,$17

AND_Lower_Segment:					;$02B653	| AND values for each of the lower segments in the Pokey.
	db $01,$02,$04,$08

AND_Below_Segment:					;$02B657	| AND values to get all of the segments below the ones specified above.
	db $00,$01,$03,$07

AND_Above_Segment:					;$02B65B	| AND values to get all the segments above and including the ones specified above.
	db $FF,$FE,$FC,$F8

PokeyTileDispX:					;$02B661	| X offsets for animating the Pokey segments as it moves.
	db $00,$01,$00,$FF

Y_Offset_Fall:					;$02B665	| Y offsets for handling the "fall" animation of higher Pokey segments when a segment in the middle is removed.
	db $00,$05,$09,$0C,$0E,$0F,$10,$10
	db $10,$10,$10,$10,$10
	
PokeyMainRt:					;-----------| The actual Pokey MAIN
	LDA.w $1534,X				;$02B672	|\ Branch if in single segment form.
	BNE PokeySegment				;$02B675	|/
	LDA.w $14C8,X				;$02B677	|\ 
	CMP.b #$08					;$02B67A	|| Branch if not dead.
	BEQ ActualPokey				;$02B67C	|/
	JMP GraphicRoutine				;$02B67E	| Skip to graphics.


PokeySegment:					;```````````| Pokey segment.
	JSL $0190B2					;$02B681	| Draw a 16x16.
	LDY.w $15EA,X				;$02B685	|
	LDA $C2,X					;$02B688	|\ 
	CMP.b #$01					;$02B68A	||
	LDA.b #$8A					;$02B68C	||| Tile for the Pokey's head when seperated.
	BCC NotSeparated				;$02B68E	||
	LDA.b #$E8					;$02B690	||| Tile for the Pokey's body when seperated.
NotSeparated:					;			||
	STA.w $0302,Y				;$02B692	|/
	LDA.w $14C8,X				;$02B695	|\ 
	CMP.b #$08					;$02B698	|| Return if the segment was killed (under normal circumstances, this should always return at this point).
	BNE Return02B6A6			;$02B69A	|/
	JSL $01801A					;$02B69C	|\ 
	INC $AA,X					;$02B69F	|| Apply gravity to the segment. There's no limit, though, so this will invert fairly quickly.
	INC $AA,X					;$02B6A1	|/
	%SubOffScreen()				;$02B6A3	| Process offscreen from -$40 to +$30.
Return02B6A6:					;			|
	RTS							;$02B6A6	|


ActualPokey:					;```````````| Actual Pokey.
	LDA $C2,X					;$02B6A7	|\ 
	BNE PokeyAlive				;$02B6A9	|| If there are no segments left, erase the sprite.
ErasePokey:					;			||
	STZ.w $14C8,X				;$02B6AB	|/
	RTS							;$02B6AE	|

PokeyAlive:						;```````````| Pokey is alive.
	CMP.b #$20					;$02B6AF	|\ Erase the Pokey if there are more than 5 segments?
	BCS ErasePokey				;$02B6B1	|/
	LDA $9D						;$02B6B3	|\ Skip to graphics if game frozen.
	BEQ +
	JMP GraphicRoutine				;$02B6B5	|/
	+
	%SubOffScreen()				;$02B6B7	| Process offscreen from -$40 to +$30.
	JSL $01A7DC					;$02B6BA	| Process interaction with Mario.
	INC.w $1570,X				;$02B6BE	|\ 
	LDA !frames_check,X
	STA $0A
	LDA.w $1570,X				;$02B6C1	||
	AND.b $0A					;$02B6C4	||| How often to check Mario's side.
	BNE SetXSpeed				;$02B6C6	||
	JSR CheckMarioSide				;$02B6C8	|| Handle changing direction towards Mario.
	TYA							;$02B6CB	||
	STA.w $157C,X				;$02B6CC	|/
SetXSpeed:					;			|
	%BEC(SetNormalSpeed) 
	LDY.w $157C,X
	TYA
	BEQ UseByteThree
	LDA !ExtraByteSpeed0,X
	BRA ExtraByteSpeed
	UseByteThree:
	LDA !ExtraByteSpeed1,X
	BRA ExtraByteSpeed
	SetNormalSpeed:
	LDY.w $157C,X				;$02B6CF	|\ 
	LDA.w PokeySpeed,Y			;$02B6D2	|| Set the Pokey's X speed.
	ExtraByteSpeed:
	STA $B6,X					;$02B6D5	|/
	JSL $018022					;$02B6D7	|\ Update X/Y position.  (without gravity)
	JSL $01801A					;$02B6DA	|/
	LDA $AA,X					;$02B6DD	|\ 
	CMP.b #$40					;$02B6DF	||
	BPL ApplyGravity				;$02B6E1	|| Apply gravity.
	CLC							;$02B6E3	||
	ADC.b #$02					;$02B6E4	||| How fast the Pokey accelerates downwards.
	STA $AA,X					;$02B6E6	|/
ApplyGravity:					;			|
	JSL $019138					;$02B6E8	| Process interaction with blocks.
	LDA.w $1588,X				;$02B6EC	|\ 
	AND.b #$04					;$02B6EF	|| Clear Y speed if on the ground.
	BEQ NoClearSpeed				;$02B6F1	||
	STZ $AA,X					;$02B6F3	|/
NoClearSpeed:					;			|
	LDA.w $1588,X				;$02B6F5	|\ 
	AND.b #$03					;$02B6F8	||
	BEQ InvertDirection				;$02B6FA	|| Invert direction if touching a wall.
	LDA.w $157C,X				;$02B6FC	||
	EOR.b #$01					;$02B6FF	||
	STA.w $157C,X				;$02B701	|/
InvertDirection:					;			|
	JSR ThrownSpriteInteraction				;$02B704	| Process interaction with thrown sprites.
	LDY.b #$00					;$02B707	|\ 
ShiftLoop:					;			||
	LDA $C2,X					;$02B709	||
	AND.w AND_Lower_Segment,Y			;$02B70B	||
	BNE SkipLoop				;$02B70E	||
	LDA $C2,X					;$02B710	||
	PHA							;$02B712	||
	AND.w AND_Below_Segment,Y			;$02B713	||
	STA $00						;$02B716	|| Shift the bits for the remaining segments in the Pokey so they they stay in sequence.
	PLA							;$02B718	||  (i.e. no "1001", make it "0011" instead)
	LSR							;$02B719	||
	AND.w AND_Above_Segment,Y			;$02B71A	||
	ORA $00						;$02B71D	||
	STA $C2,X					;$02B71F	||
SkipLoop:					;			||
	INY							;$02B721	||
	CPY.b #$04					;$02B722	||
	BNE ShiftLoop				;$02B724	|/
	
;;Graphics
GraphicRoutine:					;```````````| Pokey GFX routine.
	%GetDrawInfo()				;$02B726	|
	LDA $01						;$02B729	|\ 
	CLC							;$02B72B	|| Shift on-screen X position down 5 tiles, so the base is at the bottom of the Pokey.
	ADC.b #$40					;$02B72C	||
	STA $01						;$02B72E	|/
	LDA $C2,X					;$02B730	|\ 
	STA $02						;$02B732	|| $02 = Segment count ($C2)
	STA $07						;$02B734	|| $03 = Extra Y offset to be added if a piece was been removed.
	LDA.w $151C,X				;$02B736	|| $04 = Non-sequential segment count ($151C)
	STA $04						;$02B739	|| $05 = Extra Y offset actually being added to each segment. Starts at 0, but changes when a removed piece is encountered.
	LDY.w $1540,X				;$02B73B	|| $06 = Loop counter
	LDA.w Y_Offset_Fall,Y			;$02B73E	|| $07 = Mirror of segment count ($C2)
	STA $03						;$02B741	||
	STZ $05						;$02B743	|/
	LDY.w $15EA,X				;$02B745	|
	PHX							;$02B748	|
	LDX.b #$04					;$02B749	|
GfxLoop:					;```````````| Main segment GFX loop.
	STX $06						;$02B74B	|
	LDA $14						;$02B74D	|\ 
	LSR							;$02B74F	||
	LSR							;$02B750	||
	LSR							;$02B751	||
	CLC							;$02B752	||
	ADC $06						;$02B753	||
	AND.b #$03					;$02B755	||
	TAX							;$02B757	|| Set X position, animating the "wiggle" of the segments in the process.
	LDA $07						;$02B758	||
	CMP.b #$01					;$02B75A	||
	BNE XPosWiggle				;$02B75C	||
	LDX.b #$00					;$02B75E	||
XPosWiggle:					;			||
	LDA $00						;$02B760	||
	CLC							;$02B762	||
	ADC.w PokeyTileDispX,X		;$02B763	||
	STA.w $0300,Y				;$02B766	|/
	LDX $06						;$02B769	|
	LDA $01						;$02B76B	|\ 
	LSR $02						;$02B76D	||
	BCC ShiftYPos				;$02B76F	||
	LSR $04						;$02B771	||
	BCS SetYPos				;$02B773	||
	PHA							;$02B775	|| Set Y position;
	LDA $03						;$02B776	||  if the segment is currently "falling" (i.e. a middle segment was knocked off),
	STA $05						;$02B778	||  then add the extra Y offset to it and all higher pieces for animating that.
	PLA							;$02B77A	||
SetYPos:					;			||
	SEC							;$02B77B	||
	SBC $05						;$02B77C	||
	STA.w $0301,Y				;$02B77E	|/
ShiftYPos:					;			|
	LDA $01						;$02B781	|\ 
	SEC							;$02B783	|| Shift Y position for the next segment one tile upwards.
	SBC.b #$10					;$02B784	||
	STA $01						;$02B786	|/
	LDA $02						;$02B788	|\ 
	LSR							;$02B78A	||
	LDA.b #$E8					;$02B78B	||| Tile to use for the Pokey's body.
	BCS SetTileToUse				;$02B78D	||
	LDA.b #$8A					;$02B78F	||| TIle to use for the Pokey's head.
SetTileToUse:					;			||
	STA.w $0302,Y				;$02B791	|/
	LDA.b #$05					;$02B794	|\\ Palette to use for the YXPPCCCT of the Pokey.
	ORA $64						;$02B796	||
	STA.w $0303,Y				;$02B798	|/
	INY							;$02B79B	|
	INY							;$02B79C	|
	INY							;$02B79D	|
	INY							;$02B79E	|
	DEX							;$02B79F	|\ Loop for all 5 segments (regardless of how many are actually still there).
	BPL GfxLoop				;$02B7A0	|/
	PLX							;$02B7A2	|
	LDA.b #$04					;$02B7A3	|\ 
	LDY.b #$02					;$02B7A5	|| Upload 5 16x16s.
UnusedLabel:					;			||
	JSL $01B7B3					;$02B7A7	|/ (FinishOAMWrite)
	RTS							;$02B7AB	|

;;Pokey routines

ThrownSpriteInteraction:					;-----------| Routine to process interaction between a Pokey and other sprites (for being hurt by thrown items).
	LDY.b #$09					;$02B7AC	|
InteractionLoop:					;			|
	TYA							;$02B7AE	|
	EOR $13						;$02B7AF	|\ 
	LSR							;$02B7B1	||
	BCS SkipInteractionLoop				;$02B7B2	|| Skip slot if not a frame to process interaction,
	LDA.w $14C8,Y				;$02B7B4	||  or the sprite is not in a thrown state.
	CMP.b #$0A					;$02B7B7	||
	BNE SkipInteractionLoop				;$02B7B9	|/
	PHB							;$02B7BB	|
	LDA.b #$03					;$02B7BC	|
	PHA							;$02B7BE	|
	PLB							;$02B7BF	|
	PHX							;$02B7C0	|
	TYX							;$02B7C1	|
	JSL $03B6E5					;$02B7C2	|\ 
	PLX							;$02B7C6	||
	JSL $03B69F					;$02B7C7	|| Branch if in contact.
	JSL $03B72B					;$02B7CB	||
	PLB							;$02B7CF	||
	BCS SpriteInContact				;$02B7D0	|/
SkipInteractionLoop:					;			|
	DEY							;$02B7D2	|\ Loop for all the remaining sprite slots.
	BPL InteractionLoop				;$02B7D3	|/
Return02B7D5:					;			|
	RTS							;$02B7D5	|

SpriteInContact:					;```````````| Thrown sprite is in contact with the Pokey.
	LDA.w $1558,X				;$02B7D6	|\ Return if thrown sprite interaction is temporarily disabled.
	BNE Return02B7D5			;$02B7D9	|/
	LDA.w $00D8,Y				;$02B7DB	|\ 
	SEC							;$02B7DE	||
	SBC $D8,X					;$02B7DF	|| Knock off the Pokey segment being touched.
	PHY							;$02B7E1	||
	STY.w $1695					;$02B7E2	||
	JSR RemovePokeySgmntRt		;$02B7E5	|/
	PLY							;$02B7E8	|
	JSR SpawnDetached				;$02B7E9	|
	RTS							;$02B7EC	|



RemovePokeySgmntRt:				;-----------| Subroutine to remove a segment from a Pokey. Load A with the Y position being touched.
	LDY.b #$00					;$02B7ED	|\ 
	CMP.b #$09					;$02B7EF	||
	BMI RemoveSegment				;$02B7F1	||
	INY							;$02B7F3	||
	CMP.b #$19					;$02B7F4	||
	BMI RemoveSegment				;$02B7F6	|| Figure out which segment is being killed/eaten (Y = 0-4)
	INY							;$02B7F8	||
	CMP.b #$29					;$02B7F9	||
	BMI RemoveSegment				;$02B7FB	||
	INY							;$02B7FD	||
	CMP.b #$39					;$02B7FE	||
	BMI RemoveSegment				;$02B800	||
	INY							;$02B802	|/
RemoveSegment:					;			|
	LDA $C2,X					;$02B803	|\ 
	AND.w PokeyUnsetBit,Y		;$02B805	|| Remove the segment.
	STA $C2,X					;$02B808	||
	STA.w $151C,X				;$02B80A	|/
	LDA.w AND_Removed_Piece,Y			;$02B80D	|\ Get AND value for determining the number of segments above the piece later.
	STA $0D						;$02B810	|/
	LDA.b #$0C					;$02B812	|\ Set timer for the "falling" animation of the rest of the Pokey.
	STA.w $1540,X				;$02B814	|/
	ASL							;$02B817	|\ Temporarily disable extra interaction with the Pokey for thrown sprites.
	STA.w $1558,X				;$02B818	|/
	RTS							;$02B81B	|

PokeyUnsetBit:					;$02B824	| AND values to clear bits for the Pokey.
	db $EF,$F7,$FB,$FD,$FE

AND_Removed_Piece:					;$02B829	| AND values for tracking the number of segments above the removed piece.
	db $E0,$F0,$F8,$FC,$FE					; Indicates a tile is the head if this ANDed with the segments in the Pokey is 0.


SpawnDetached:					;-----------| Routine to spawn a detatched Pokey segment when hit by a thrown sprite.
	JSL $02A9E4					;$02B82E	|\ Return if no empty sprite slot exists.
	BMI Return02B881			;$02B832	|/
	LDA.b #$02					;$02B834	|\ 
	STA.w $14C8,Y				;$02B836	||
	LDA.b #$70					;$02B839	||| Sprite to spawn (Pokey).
	STA.w $009E,Y				;$02B83B	|/
	LDA $E4,X					;$02B83E	|\ 
	STA.w $00E4,Y				;$02B840	|| Set X position at the Pokey.
	LDA.w $14E0,X				;$02B843	||
	STA.w $14E0,Y				;$02B846	|/
	PHX							;$02B849	|
	TYX							;$02B84A	|
	JSL $07F7D2					;$02B84B	|
	LDX.w $1695					;$02B84F	|\ 
	LDA $D8,X					;$02B852	||
	STA.w $00D8,Y				;$02B854	|| Set Y position at the thrown sprite.
	LDA.w $14D4,X				;$02B857	||
	STA.w $14D4,Y				;$02B85A	|/
	LDA $B6,X					;$02B85D	|\ 
	STA $00						;$02B85F	||
	ASL							;$02B861	|| Set X speed as half the thrown sprite's.
	ROR $00						;$02B862	||
	LDA $00						;$02B864	||
	STA.w $00B6,Y				;$02B866	|/
	LDA.b #$E0					;$02B869	|\\ Y speed to give the detatched segment.
	STA.w $00AA,Y				;$02B86B	|/
	PLX							;$02B86E	|
	LDA $C2,X					;$02B86F	|\ 
	AND $0D						;$02B871	|| Store a value representing the number of segments above the current one, for determining if it's the head.
	STA.w $C2,Y					;$02B873	|/
	LDA.b #$01					;$02B876	|\ Set flag for the sprite being a single segment.
	STA.w $1534,Y				;$02B878	|/
	LDA.b #$01					;$02B87B	|\ Give 200 points.
	JSL $02ACE1					;$02B87D	|/
Return02B881:					;			|
	RTS							;$02B881	|
	
	
;; Routines Used 
CheckMarioSide:					;-----------| Subroutine to check which side of the sprite Mario is on (duplicate of SubHorzPosBnk2). Returns Y: 00 = right, 01 = left.
	LDY.b #$00					;$02D4FA	|
	LDA $94						;$02D4FC	|
	SEC							;$02D4FE	|
	SBC $E4,X					;$02D4FF	|
	STA $0F						;$02D501	|
	LDA $95						;$02D503	|
	SBC.w $14E0,X				;$02D505	|
	BPL Return02D50B			;$02D508	|
	INY							;$02D50A	|
Return02D50B:					;			|
	RTS							;$02D50B	|
