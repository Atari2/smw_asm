;; to use this patch, check the table at the end of the file
;; let's do an example:
;; if you have $01 for level 106 in that table, upon beating 106 in any way, this patch will check if event 01 has run.
;; if it hasn't it will run the normal exit event of level 106 specified in LM, if it has run however, it will run the secret exit event of level 106 (aka normal exit event + 1)

org $048EF1 
    autoclean JML overworldEventsChange
    NOP

freecode
overworldEventsChange:
PHB : PHK : PLB
JSR subOWEventChange
PLB
LDA.b #$08      ; restore vanilla code
STA.w $0DB1
JML $048EF6


subOWEventChange:
LDX $13BF
LDA runCustom,x
CMP #$FF            ; if $FF, skip over and use vanilla way
BEQ .skip
PHA
LDA #$01
STA $0DD5
PLA
STA $00
JSR checkEvent      ; check if the specified event has run
BEQ +
INC $0DD5           ; if it has run, trigger secret exit
+
.skip
RTS

checkEvent:
AND #$07
TAX
LDA $00
LSR #3
TAY
LDA $1F02,y
AND desc,x
RTS

desc:
    db $80,$40,$20,$10,$08,$04,$02,$01

;; $FF to not run custom code, else, input the event to check for that level
runCustom:
    db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF   ; levels $00-$0F
    db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF   ; levels $10-$1F
    db $FF, $FF, $FF, $FF, $FF                                                          ; levels $20-$24
    db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF   ; levels $101-$110
    db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF   ; levels $111-$120
    db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF   ; levels $121-$130
    db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF                            ; levels $131-$13B