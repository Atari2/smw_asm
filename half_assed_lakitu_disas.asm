

x_position_offset:					;$04F8A6	| 
	db $01,$01,$03,$01,$01,$01,$01,$02
y_position_offset:					;			|
	db $0C,$0C,$12,$12,$12,$12,$0C,$0C
max_x_pos_offset:					;			|
	db $10,$00,$08,$00,$20,$00,$20,$00
max_y_pos_offset:					;			|
	db $10,$00,$30,$00,$08,$00,$10,$00
z_speed_offset:					;			|
	db $01,$FF

max_x_speed:					;			|
	db $10,$F0

max_z_speed:					;			|
	db $10,$F0

init:
rtl

;;; starts at $04F8CC
main:
jsr update_low_pos
clc 							; -> set carry?
jsr draw_shadow					; draw the shadow under the lakitu
jsr get_draw_info
rep #$20
lda $02 						; -> move y position to $04
sta $04 
sep #$20
jsr frame_counter_plus_timer_offset ; literally 3 lines??? why a jsr
ldx #$06
and #$10 							; if counter not multiple of 16
beq gfx_upload_loop					; 
inx
gfx_upload_loop:
stx $06
lda $00
clc : adc x_position_offset,x		; add some kind of offset to x position
sta $00
bcc x_pos_off
inc $01							; increment transfer addition overflow to high byte of x pos
x_pos_off:
lda $04
clc : adc y_position_offset,x	; add y position offset
sta $02
lda $05
adc #$00
sta $03 						; fix high byte with carry from previous operation
lda #$32
xba 
lda #$28
ldy $0DDF 						; get oam index
jsr gfx_upload_routine
sty $0DDF 						; put back incremented oam index
ldx #$06
dex #2						; loop throught all tiles
bpl gfx_upload_loop
ldx $0DDE
jsr get_draw_info 				;draw the lakitu
lda #$32
xba
lda #$26
sec
ldy $0DDF
jsr gfx_upload_routine
sty $0DDF
lda $0E15,x 					; misc table, never used, only used for Bowser ow sprite
beq circle_around_mario:		; this always jumps over because $0E15 is only used in the ow bowser sprite and it's always 00
jmp not_used_routine			; this is literally never called
circle_around_mario:
lda $0E05,x						; misc table, probably direction
and #$01						; get bit 0 of this
tay								; transfer to y
lda $0EB5,x						; load sprite_z_speed
clc : adc z_speed_offset,y			; add speed offset based on $0E05
sta $0EB5,x						; store speed back
cmp max_z_speed,y				; if speed is max, invert direction I guess
bne set_pos:
lda $0E05,x
eor #$01						
lda $0E05,x
set_pos:						; set position, the routine here sets up scratch ram ($00, $02, $06, $08)
jsr calculate_relative_pos_mario	; A is 16-bit mode from here on out	
ldy $0DF5,x						; some kind of timer for ??? 
lda $0E04,x						; load 0E04, this is secretly $0E05 but we're in 16-bit so loads 1 byte before
asl								; x2
eor $00							; eor with x pos difference
bpl load_80_maybe						; if positive skip
lda $06							; load scratch ram with (possibly the inverse of) mario-sprite position
cmp max_x_pos_offset,y				; this is just to set the carry flag
lda #$0040							; load #$0040
bcs store_to_misc						; if carry set go to...
load_80_maybe:
lda $0E04,x							;
eor $02								; this time eor with $02 and x2
asl				
bcc store_to_misc						; 
lda $08								; set carry again, this time with 
cmp max_y_pos_offset,y				; y position
lda #$0080							; load #$0080
store_to_misc:						
sep #$20							; exit from 16-bit mode
bcc skip_frame_count						; if carry clear, skip inverting $0E05
eor $0E05,x									; eor what's in A with $0E05 and store it back
sta $0E05,x													
jsr frame_counter_plus_timer_offset			; load timer
and #$06									; not a power of 2 ? not sure
sta $0DF5,x									; store it to misc
skip_frame_count:
txa
clc : adc #$10
tax											; add 10 to sprite index?
lda $0DF5,x									; read from another timer
asl											; x2
jsl with_index							
ldx $0DDE									; reload the original sprite index
lda $0E05,x									; 0E05 x 4 ?
asl #2										; may be to set carry
with_index:
ldy #$00									; set Y depending on $0E05									
bcs anstore_to_misc
iny
anstore_to_misc:
lda $0E95,x									; check x speed
clc : adc z_speed_offset,y					; add z speed offset
cmp max_x_speed,y							; if max speed, do nothing
beq return										
sta $0E95,x									; else store it
return:
rtl



