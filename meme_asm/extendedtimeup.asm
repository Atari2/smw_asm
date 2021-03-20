;this patch slows down a bit the time it takes for the GAME OVER / TIME UP! screen to slide across the screen
if read1($00978D) == $04
	org $00978C
		db $E9,$01
	print "Patch applied!"
else 
	org $00978C
		db $E9,$04
	print "Patch restored!"
endif
;AD 3C 14 D0 05 CE 3D 14 D0 00
;5C 00 00 00
if read1($00975D) == $AD
	org $00975D
		autoclean JML hijack
		NOP #6
else 
	org $00975D
		db $AD,$3C,$14,$D0,$05,$CE,$3D,$14,$D0,$00
endif
freecode
hijack:
LDA.w $143C		
BEQ +
JML $00978B
+
LDA $14
AND #$03
CMP #$02
BEQ +
DEC.w $143D		
BEQ +
JML $00978E
+
JML $009767