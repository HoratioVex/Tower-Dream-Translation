; Tower Dream (SFC) (CRC32: AA2D5C55)
; Expand player name entry to 8 letters

lorom

org $58E84
cmp #$0008

org $592A0
lda #$0008 ;max letters, for backspace

org $59432
lda #$0008 ;max letters

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
cmp #$0007

org $58E84
cmp #$0007

org $58DC4
lda $878000,x



org $878000 ;lookup table for character cursor position
CharCursorPos:
db $6F,$00,$75,$00,$7B,$00,$81,$00,$87,$00,$8D,$00,$93,$00,$99,$00