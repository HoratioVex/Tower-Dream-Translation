;misc board functions

lorom

org $81a8d9 ;(81a8e2 too?) Remove adding checksums to money total
nop #3

org $819c21
db $aa,$aa,$aa,$aa,$aa,$aa,$aa,$aa

org $80a131 ;write current player name
jsr ExtendToWordXP
nop #2

org $80a13e
nop #2
lda $24
clc
adc #$0010

org $80a153
nop
cpx #$0006

org $80b801
; skip jsr $80c103 (prepare&outline char at $2b9)
CopyCharacter:
sep #$20
ldx $24
ldy #$0002 ;move up 2 pixels to match baseline of number
.LoopU: ;write upper half
	lda [$20],y
	ora #$FF ;mask background
	sta $00,x
	inx
	lda [$20],y
	sta $00,x
	inx
	iny
	cpy #$000A
bne .LoopU
rep #$20
lda $24
clc
adc #$0060
tax
sep #$20
.LoopD:
	lda [$20],y
	ora #$FF
	sta $00,x
	inx
	lda [$20],y
	sta $00,x
	inx
	iny
	cpy #$000E
bne .LoopD
.LoopEmpty: ;2 empty rows for padding
	lda #$FF
	sta $00,x
	inx
	lda #$00
	sta $00,x
	inx
	iny
	cpy #$0010
bne .LoopEmpty
.LoopBorder: ;draw lower border for bottom half, 2px height
	lda #$00
	sta $00,x
	inx
	lda #$FF
	sta $00,x
	inx
	iny
	cpy #$0012
bne .LoopBorder
jmp $b954

org $80A307 ;write 1 char in msg window
php
rep #$30
phb
phx
phy
jsr ExtendToWordXP
jsr $c3be
jsl $80c27c
;jsl $80c103
jsl $80890b
jsr $a626
ply
plx
plb
plp
rtl
warnpc $80a324

org $80A626 ;write 1 char to VRAM
MsgWriteChar:
php
rep #$30
phx
phy
lda $24
sta $2116
sep #$20
ldy #$0000
.LoopU: 
	lda [$20],y
	ora #$FF ;mask background
	sta $2118
	lda [$20],y
	sta $2119
	iny
	cpy #$0008
bne .LoopU
rep #$30
lda $24
clc
adc #$0080
sta $2116
sep #$20
.LoopD: 
	lda [$20],y
	ora #$FF ;mask background
	sta $2118
	lda [$20],y
	sta $2119
	iny
	cpy #$0010
bne .LoopD

rep #$30
lda $24
clc
adc #$0010
sta $24
ply
plx
plp
rts
warnpc $80a782

org $809AC5 ;adv 1 char only
nop #2


org $80fb00 ;freespace
ExtendToWordXP:
xba
and #$FF00
bne .Letter
lda #$aa82
.Letter:
ora #$0082
sta $0a
rts
;jmp $a136


warnpc $80ffb0 ;interrupt table
