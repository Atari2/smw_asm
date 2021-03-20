; this is an autoscroll that goes from mario's spawn point up to screen 00 in a vertical level
; modify these values if you want to fiddle with autoscroll speed and stop point
; it also freezes mario in place, hides him and disables player controls
!Speed = #$0100 ; -> this is a negative value in 2's complement, the more negative the faster, max speed is technically #$8000 but going that high breaks the game
!StopPoint = #$1A31 ; -> this is a screen position, 0031 == screen 00 in a LM vertical level, 0131 == screen 01 in a LM vertical level and so on
!Flag = $7FB500 ; 1 byte of freeram of your choice
!timerwithmusic = 1 ; leaving this to 1, will add an FF frames timer to the level end and keep the music on the overworld, putting 0 will remove the timer AND will kill overworld music
!UpOrDown = $00  ; change this to 02 to make it go opposite direction
!DecOrInc = INC	; change this to DEC to make it go opposite direction
!BPLorBMI = BMI ; change this to BPL to make it go opposite direction
; do not modify these values because those are addresses
!Layer1YSpeed = $1448
!Direction = $55	
!ScrollTimer = $1440
!Layer1NextFrame = $1464
!TempUpdateValue = $1450
init:
	LDA #$00
	STA !Flag
	LDY #$20
	STY !ScrollTimer 	; set starting timer
	RTL
	
main:
	LDA !Flag
	BEQ +
	CMP #$02
	BEQ ++
	JMP EndLevelAndReturn
	++
	RTL
	+
	LDA #$0B	; set freeze flag, disable player controls and hide mario
	STA $71
	LDA #$01
	STA $13FB
	STZ $1412
	LDA #$FF
	STA $78		
	LDA !ScrollTimer
	BEQ .startSinking	
	DEC.w !ScrollTimer		
	BRA .return
	.startSinking:
	LDA #!UpOrDown
	STA !Direction
	REP #$20
	LDA.w !Layer1YSpeed		
	CMP.w !Speed
	BEQ .maxSpeed
	!DecOrInc
	STA.w !Layer1YSpeed
	.maxSpeed:
	LDA.w !Layer1NextFrame
	CMP.w !StopPoint
	!BPLorBMI .noStopSinking
	STZ.w !Layer1YSpeed
	SEP #$20
	LDA #$01
	STA !Flag
	REP #$20
	.noStopSinking:
	BNE .noDelay
	LDY #$20
	STY !ScrollTimer
	.noDelay:
	JSR CalcNextPosition
	SEP #$20
	.return:
	RTL

CalcNextPosition:				
	LDA.w !TempUpdateValue					 
	AND.w #$00FF				
	CLC							
	ADC.w !Layer1YSpeed			
	STA.w !TempUpdateValue				
	AND.w #$FF00				
	BPL .addSpeedNext				 ; Add the layer's speed to its position.
	ORA.w #$00FF				
	.addSpeedNext:				
	XBA							
	CLC							
	ADC.w !Layer1NextFrame				
	STA.w !Layer1NextFrame			
	RTS
	
EndLevelAndReturn:
	STZ $71
	STZ $13FB
	LDA !Flag
	INC A
	STA !Flag
	if !timerwithmusic
		LDA #$03
		STA $13D9|!addr
		LDA #$FF
		STA $1493
	else 
		LDA #$01
		STA $13CE|!addr
		STA $0DD5|!addr
		STZ $1DE9|!addr
		LDA #$0B
		STA $0100|!addr
	endif
	RTL	
