; Tower Dream (SFC) (CRC32: AA2D5C55)
; Expand player name entry to 8 letters

lorom

org $58E84
cmp #$0006

org $592A0
lda #$0006 ;max letters, for backspace

org $59432
lda #$0006 ;max letters

org $59445
nop ;remove 1 ADC, count only 1
nop
nop
tax
Loop:
 lda $1E18,x
 tay
 lda $10
 xba
 sta $1E18,x
 sty $10
 inx ;advance 1 step only
 dec $12
bne Loop

org $59478
lda #$aaaa ;fill with space

org $5913E
cmp #$0005

org $58E84
cmp #$0005

org $58DC4
lda $878000,x

org $58C3D ;write only 6 chars to save
nop #7
;lda $1e3e ;original
;sta $70002e,x

org $59464 ;space before name entry
lda #$AAAA

org $59280 ;DMA one more tile for name
ldx #$0140

org $5A40B ;player name select to show 6 letters  
bank $05

sep #$30
lda #$04
sta $10
ldx #$00
ldy #$00
NextPlayer: {
	lda #$06
	sta $12
	NextLetter: {
		lda $1e38,x
		bne WriteLetter
		lda #$AB ;write Period if letter is empty
		WriteLetter:
		sta $1f84,y
		inx
		iny
		dec $12
		bne NextLetter
		}
	inx ;save is 8 bytes, so skip 2
	inx
	tya
	clc
	adc #$03
	tay
	dec $10
	bne NextPlayer
	}
rep #$30
rts
warnpc $05a439

org $878000 ;lookup table for character cursor position
CharCursorPos:
db $6F,$00,$77,$00,$7F,$00,$87,$00,$8F,$00,$97,$00,$9F,$00,$99,$00