MarioSprInteract:				;-----------| Subroutine to handle interaction between Mario and the sprite in X.
	PHB							;$01A7DC	|  With default interaction disabled, returns carry set if in contact and clear if not.
	PHK							;$01A7DD	|  With default interaction, all routines are handled internally.
	PLB							;$01A7DE	|   (star power, slide-killing, Mario damage, bouncing, carrying, etc.)
	JSR MarioSprInteractRt		;$01A7DF	|
	PLB							;$01A7E2	|
	RTL							;$01A7E3	|  Also sets $0F/$0E with values from SubHorzPos/SubVertPos.

MarioSprInteractRt:
	LDA.w $167A,X				;$01A7E4	|\ 
	AND.b #$20					;$01A7E7	||
	BNE ProcessInteract			;$01A7E9	||
	TXA							;$01A7EB	||
	EOR $13						;$01A7EC	||
	AND.b #$01					;$01A7EE	|| Return if not a frame in which interaction is processed for the sprite, or the sprite is horizontally offscreen.
	ORA.w $15A0,X				;$01A7F0	||
	BEQ ProcessInteract			;$01A7F3	||
ReturnNoContact:				;			||
	CLC							;$01A7F5	||
	RTS							;$01A7F6	|/


ProcessInteract:				;-----------| The actual Mario-sprite interaction routine.
	%SubHorzPos()			;$01A7F7	|
	LDA $0F						;$01A7FA	|\ 
	CLC							;$01A7FC	||
	ADC.b #$50					;$01A7FD	||
	CMP.b #$A0					;$01A7FF	|| Return if Mario is not within a 10x12 space around the sprite.
	BCS ReturnNoContact			;$01A801	||  (i.e. not within any hitbox whatsoever)
	%SubVertPos()			;$01A803	||
	LDA $0E						;$01A806	|| That said, this is a single-byte compare, so this space loops each screen anyway.
	CLC							;$01A808	||  (thankfully, the CheckForContact makes sure of that anyway).
	ADC.b #$60					;$01A809	||
	CMP.b #$C0					;$01A80B	||
	BCS ReturnNoContact			;$01A80D	|/
CODE_01A80F:					;			|
	LDA $71						;$01A80F	|\ 
	CMP.b #$01					;$01A811	|| Return if Mario is performing a special animation.
	BCS ReturnNoContact			;$01A813	|/
	LDA.b #$00					;$01A815	|\ 
	BIT.w $0D9B					;$01A817	||
	BVS CODE_01A822				;$01A81A	||
	LDA.w $13F9					;$01A81C	|| Return if Mario and the sprite are on different layers.
	EOR.w $1632,X				;$01A81F	||
CODE_01A822:					;			||
	BNE ReturnNoContact2		;$01A822	|/
	JSL $03B664		            ;$01A824	|\ GetMarioClipping
	JSL $03B69F            		;$01A828	|| GetMarioClippingA Return if Mario is not in contact with the sprite.
	JSL $03B72B		            ;$01A82C	|| CheckForContact
	BCC ReturnNoContact2		;$01A830	|/
	LDA.w $167A,X				;$01A832	|\ 
	BPL DefaultInteractR		;$01A835	|| Handle default interaction. Else, return carry set.
	SEC							;$01A837	|/
	RTS							;$01A838	|



DATA_01A839:					;$01A839	| X speeds to gives sprites when killed by a star.
	db $F0,$10

DefaultInteractR:				;-----------| Subroutine to handle default interaction when Mario is actually touching a sprite.
	LDA.w $1490					;$01A83B	|\ 
	BEQ CODE_01A87E				;$01A83E	||
	LDA.w $167A,X				;$01A840	|| Branch if Mario doesn't have star power or the sprite can't be killed by a star.
	AND.b #$02					;$01A843	||
	BNE CODE_01A87E				;$01A845	|/


CODE_01A847:					;```````````| Mario is touching a sprite with either star power or sliding into it.
	JSL $01AB6F			        ;$01A847	| DispContactSpr
	INC.w $18D2					;$01A84B	|\ 
	LDA.w $18D2					;$01A84E	||
	CMP.b #$08					;$01A851	||
	BCC CODE_01A85A				;$01A853	|| Increase kill count and give corresponding points.
	LDA.b #$08					;$01A855	||
	STA.w $18D2					;$01A857	||
CODE_01A85A:					;			||
	JSL $02ACE5				    ;$01A85A	|/ GivePoints
	LDY.w $18D2					;$01A85E	|\ 
	CPY.b #$08					;$01A861	||
	BCS CODE_01A86B				;$01A863	|| Get SFX for being hit with star power.
	LDA.w DATA_01A61E-1,Y		;$01A865	||
	STA.w $1DF9					;$01A868	|/
CODE_01A86B:					;			|
	LDA.b #$02					;$01A86B	|\ Kill the sprite.
	STA.w $14C8,X				;$01A86D	|/
	LDA.b #$D0					;$01A870	|\ 
	STA $AA,X					;$01A872	||
	%SubHorzPos()    			;$01A874	|| Send flying away from Mario.
	LDA.w DATA_01A839,Y			;$01A877	||
	STA $B6,X					;$01A87A	|/
ReturnNoContact2:				;			|
	CLC							;$01A87C	|
	RTS							;$01A87D	|


CODE_01A87E:					;```````````| Mario doesn't have star power.
	STZ.w $18D2					;$01A87E	|
	LDA.w $154C,X				;$01A881	|\ 
	BNE CODE_01A895				;$01A884	|| Return if the sprite has player contact disabled.
	LDA.b #$08					;$01A886	||  Otherwise, prevent extra contact from occuring.
	STA.w $154C,X				;$01A888	|/
	LDA.w $14C8,X				;$01A88B	|\ 
	CMP.b #$09					;$01A88E	|| Branch if not a carryable sprite.
	BNE CODE_01A897				;$01A890	|/
	PHK
    PEA.w .jslrtsreturn-1
    PEA.w $0180CA-1
    JML $01AA42
    .jslrtsreturn			;$01A892	| Handle touching a carryable sprite.
CODE_01A895:					;			|
	CLC							;$01A895	|
	RTS							;$01A896	|

CODE_01A897:					;```````````| Non-carryable sprite.
	LDA.b #$14					;$01A897	|\\ Distance above the sprite that Mario's position must be to be considered on "top" of it.
	STA $01						;$01A899	||   (increasing this value = smaller safe space)
	LDA $05						;$01A89B	||
	SEC							;$01A89D	||
	SBC $01						;$01A89E	||
	ROL $00						;$01A8A0	||
	CMP $D3						;$01A8A2	||
	PHP							;$01A8A4	||
	LSR $00						;$01A8A5	||
	LDA $0B						;$01A8A7	||
	SBC.b #$00					;$01A8A9	|| Branch to CODE_01A8E6 if:
	PLP							;$01A8AB	||  - Too low to bounce off the sprite (Y position greater than the sprite's).
	SBC $D4						;$01A8AC	||  - Moving upward, the sprite can't be hit while moving upwards,
	BMI CODE_01A8E6				;$01A8AE	||     and Mario hasn't hit any other enemies.
	LDA $7D						;$01A8B0	||  - Both Mario and the sprite are on the ground. 
	BPL CODE_01A8C0				;$01A8B2	||
	LDA.w $190F,X				;$01A8B4	||
	AND.b #$10					;$01A8B7	||
	BNE CODE_01A8C0				;$01A8B9	||
	LDA.w $1697					;$01A8BB	||
	BEQ CODE_01A8E6				;$01A8BE	||
CODE_01A8C0:					;			||
	JSR IsOnGround				;$01A8C0	||
	BEQ CODE_01A8C9				;$01A8C3	||
	LDA $72						;$01A8C5	||
	BEQ CODE_01A8E6				;$01A8C7	|/
CODE_01A8C9:					;			|
	LDA.w $1656,X				;$01A8C9	|\ 
	AND.b #$10					;$01A8CC	|| If the sprite can be bounced on, branch.
	BNE CODE_01A91C				;$01A8CE	|/
	LDA.w $140D					;$01A8D0	|\ 
	ORA.w $187A					;$01A8D3	|| If not spinjumping or riding Yoshi, branch.
	BEQ CODE_01A8E6				;$01A8D6	|/
CODE_01A8D8:					;			|
	LDA.b #$02					;$01A8D8	|\ SFX for spinjumping off an enemy that can't be bounced on.
	STA.w $1DF9					;$01A8DA	|/  Also used for bouncing off of disco shells.
	JSL $01AA33			        ;$01A8DD	| Make Mario bounce upwards. BoostMarioSpeed
	JSL $01AB99		            ;$01A8E1	| DispContactMario
	RTS							;$01A8E5	|

	
CODE_01A8E6:					;```````````| Hitting an enemy without bouncing off of it.
	LDA.w $13ED					;$01A8E6	|\ 
	BEQ CODE_01A8F9				;$01A8E9	||
	LDA.w $190F,X				;$01A8EB	||
	AND.b #$04					;$01A8EE	|| If sliding and the sprite can be killed by sliding, then kill it and return.
	BNE CODE_01A8F9				;$01A8F0	||
	JSR PlayKickSfx				;$01A8F2	||
	PHK
    PEA.w .jslrtsreturn-1
    PEA.w $0180CA-1
    JML $01A847
    .jslrtsreturn			;$01A8F5	||
	RTS							;$01A8F8	|/
CODE_01A8F9:					;			|
	LDA.w $1497					;$01A8F9	|\ 
	BNE Return01A91B			;$01A8FC	|| If Mario is invulnerable or riding Yoshi, return.
	LDA.w $187A					;$01A8FE	||
	BNE Return01A91B			;$01A901	|/
	LDA.w $1686,X				;$01A903	|\ 
	AND.b #$10					;$01A906	||
	BNE CODE_01A911				;$01A908	|| If it changes direction when touched, turn it around.
	%SubHorzPos()   			;$01A90A	||
	TYA							;$01A90D	||
	STA.w $157C,X				;$01A90E	|/
CODE_01A911:					;			|
	LDA $9E,X					;$01A911	|\ 
	CMP.b #$53					;$01A913	|| If sprite 53 (throwblock), return.
	BEQ Return01A91B			;$01A915	|/
	JSL $00F5B7				    ;$01A917	| For everything else, hurt Mario.
Return01A91B:					;			|
	RTS							;$01A91B	|


CODE_01A91C:					;```````````| Hitting an enemy on top, handle bouncing off.
	LDA.w $140D					;$01A91C	|\ 
	ORA.w $187A					;$01A91F	|| If not spinjumping or riding Yoshi, branch.
	BEQ CODE_01A947				;$01A922	|/
CODE_01A924:					;			|
	JSL $01AB99		            ;$01A924	|
	LDA.b #$F8					;$01A928	|\\ Y speed of Mario when stomping an enemy while spinjumping.
	STA $7D						;$01A92A	||
	LDA.w $187A					;$01A92C	|| Get bounce speed based on whether Mario is spinjumping or riding Yoshi.
	BEQ CODE_01A935				;$01A92F	||
	JSL $01AA33			        ;$01A931	|/
CODE_01A935:					;			|
	JSR CODE_019ACB				;$01A935	| Turn the sprite into a smoke cloud.
	JSL $07FC3B				    ;$01A938	| Generate the stars from the spinjump.
	PHK
    PEA.w .jslrtsreturn-1
    PEA.w $0180CA-1
    JML $01AB46
    .jslrtsreturn			    ;$01A93C	| Increase bounce counter/give points.
	LDA.b #$08					;$01A93F	|\ SFX for spinjumping or Yoshi-stomping an enemy.
	STA.w $1DF9					;$01A941	|/
	JMP CODE_01A9F2				;$01A944	| Return, handling Lakitu's cloud if applicable.


CODE_01A947:					;```````````| Bouncing off an enemy without spinjumping/riding Yoshi.
	JSR CODE_01A8D8				;$01A947	| Set Y speed, display a contact graphic, and set default sound effect (for disco shell).
	LDA.w $187B,X				;$01A94A	|\ 
	BEQ CODE_01A95D				;$01A94D	|| If bouncing on a disco shell (or chuck/etc.), just give Mario some X speed and return.
	%SubHorzPos()   			;$01A94F	||
	LDA.b #$18					;$01A952	||| X speed to give Mario to the right of a disco shell/Chuck.
	CPY.b #$00					;$01A954	||
	BEQ CODE_01A95A				;$01A956	||
	LDA.b #$E8					;$01A958	||| X speed to give Mario to the left of a disco shell/Chuck.
CODE_01A95A:					;			||
	STA $7B						;$01A95A	||
	RTS							;$01A95C	|/

CODE_01A95D:
	PHK
    PEA.w .jslrtsreturn-1
    PEA.w $0180CA-1
    JML $01AB46
    .jslrtsreturn				;$01A95D	| Increase bounce counter/play SFX/give points.
	LDY $9E,X					;$01A960	|\ 
	LDA.w $1686,X				;$01A962	|| Branch if the sprite doesn't spawn a new sprite when bounce on.
	AND.b #$40					;$01A965	||
    BNE Continue
	JMP CODE_01A9BE	
    Continue:			;$01A967	|/
	CPY.b #$72					;$01A969	|\ 
	BCC CODE_01A979				;$01A96B	||
	PHX							;$01A96D	||
	PHY							;$01A96E	|| Sprite 73 (cape super Koopa): spawn a feather, turn into a normal Koopa.
	JSL $02EAF2				    ;$01A96F	||  (also sprites 72+)
	PLY							;$01A973	||
	PLX							;$01A974	||
	LDA.b #$02					;$01A975	||| Sprite that the cape super Koopa becomes when bounced on.
	BRA CODE_01A99B				;$01A977	|/

CODE_01A979:
	CPY.b #$6E					;$01A979	|\ 
	BNE CODE_01A98A				;$01A97B	||
	LDA.b #$02					;$01A97D	||
	STA $C2,X					;$01A97F	|| Sprite 6E (Dino Rhino): turn into Dino Torch, prepare flame.
	LDA.b #$FF					;$01A981	||
	STA.w $1540,X				;$01A983	||
	LDA.b #$6F					;$01A986	||| Sprite that Dino Rhino becomes when bounced on.
	BRA CODE_01A99B				;$01A988	|/

CODE_01A98A:
	CPY.b #$3F					;$01A98A	|\ 
	BCC CODE_01A998				;$01A98C	||
	LDA.b #$80					;$01A98E	|| Sprite 3F (para-Goomba) and sprite 40 (para-Bomb): turn into a Goomba/Bob-omb and set stun timer.
	STA.w $1540,X				;$01A990	||
	LDA.w SpriteToSpawn-46,Y	;$01A993	||
	BRA CODE_01A99B				;$01A996	|/

CODE_01A998:
	LDA.w SpriteToSpawn,Y		;$01A998	| Sprites 08-0C (Koopas) and sprite 10 (winged Goomba): turn into respective sprites.
CODE_01A99B:					;			|
	STA $9E,X					;$01A99B	|
	LDA.w $15F6,X				;$01A99D	|\ 
	AND.b #$0E					;$01A9A0	||
	STA $0F						;$01A9A2	||
	LDA #$30
	STA $1656,X
	LDA #$18
	STA $1686,X
	LDA #$00
	STA $1662,X 
	STA $190F,X 
	INC A
	STA $167A,X 
	LDA #$0F 
	STA $166E,X                 ;$01A9A4	|| Respawn the sprite.
	LDA.w $15F6,X				;$01A9A8	||
	AND.b #$F1					;$01A9AB	||
	ORA $0F						;$01A9AD	||
	STA.w $15F6,X				;$01A9AF	|/
	STZ $AA,X					;$01A9B2	|
	LDA $9E,X					;$01A9B4	|\ 
	CMP.b #$02					;$01A9B6	|| Unused?
	BNE Return01A9BD			;$01A9B8	||  Sets the "walked off ledge" flag for the Blue Koopa.
	INC.w $151C,X				;$01A9BA	|/
Return01A9BD:					;			|
	RTS							;$01A9BD	|


IsOnGround:						;-----------| Subroutine (JSR) to check if a sprite is touching the top of a solid block.
	LDA.w $1588,X				;$01800E	|
	AND.b #$04					;$018011	|
	RTS							;$018013	|
PlayKickSfx:					;-----------| Play kick sound. Exactly what it says on the tin. Also used for sliding into enemies.
	LDA.b #$03					;$01A728	|\ Kick SFX (for shells, footballs, etc.)
	STA.w $1DF9					;$01A72A	|/
Return01A72D:					;			|
	RTS							;$01A72D	|
CODE_01A9F2:					;			|
	LDA $9E,X					;$01A9F2	|\ 
	CMP.b #$1E					;$01A9F4	||
	BNE Return01AA00			;$01A9F6	|| If killing sprite 1E (Lakitu), erase its cloud too.
	LDY.w $18E1					;$01A9F8	||
	LDA.b #$1F					;$01A9FB	||
	STA.w $1540,Y				;$01A9FD	|/
Return01AA00:					;			|
	RTS							;$01AA00	|
CODE_019ACB:					;```````````| Subroutine to make a sprite poof. Used by the throwblock, P-switch, Bowser's fire, some sprites in lava, and spinjumped sprites.
	LDA.b #$04					;$019ACB	|\ 
	STA.w $14C8,X				;$019ACD	|| Erase the sprite in a cloud of smoke.
	LDA.b #$1F					;$019AD0	||
	STA.w $1540,X				;$019AD2	|/
	RTS		
CODE_01A9BE:					;```````````| Does not spawn a new sprite when bounced on.
	LDA $9E,X					;$01A9BE	|\ 
	SEC							;$01A9C0	||
	SBC.b #$04					;$01A9C1	||
	CMP.b #$0D					;$01A9C3	||
	BCS CODE_01A9CC				;$01A9C5	||
	LDA.w $1407					;$01A9C7	||
	BNE CODE_01A9D3				;$01A9CA	||
CODE_01A9CC:					;			|| If the sprite is set to die when jumped on,
	LDA.w $1656,X				;$01A9CC	||  or if sprite 04-10 and Mario flies into it,
	AND.b #$20					;$01A9CF	||  then squish the sprite.
	BEQ Return4			;$01A9D1	||  Else, branch.
CODE_01A9D3:					;			||
	LDA.b #$03					;$01A9D3	||
	STA.w $14C8,X				;$01A9D5	||
	LDA.b #$20					;$01A9D8	||
	STA.w $1540,X				;$01A9DA	||
	STZ $B6,X					;$01A9DD	||
	STZ $AA,X					;$01A9DF	|/
    Return4:
	RTS							;$01A9E1	|
SpriteToSpawn:					;$01A7C9	| What sprites are spawned when various sprites are bounced off of by Mario, hit by a block, or eaten by Yoshi.
	db $00,$01,$02,$03,$04,$05,$06,$07		; Unused x8
	db $04,$04,$05,$05,$07,$00,$00,$0F		; 08, 09, 0A, 0B, 0C, unused x3
	db $0F,$0F,$0D							; 10, 3F, 40
DATA_01A61E:					;$01A61E	| SFX for jumping on enemies in a row. Also for hits by a shell and by star power.
	db $13,$14,$15,$16,$17,$18,$19