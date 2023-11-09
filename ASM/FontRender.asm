; Tower Dream (SFC) (CRC32: AA2D5C55)
; Skip font decoding and render one unencoded tile

lorom

; bypass decoding of glyph
; $20 retains source of glyph

org $80BFAD
jmp $C055

; render one tile. source: $20, 1bpp. target: $1A, 4bpp

org $05E895
ldx #$0000 ;loop counter
CopyAndPad: {
	lda [$20]
	sta [$1A] ;write 2 bytes from source
	inc $1A
	lda #$0000
	sta [$1A] ;and write a 00 byte
	inc $1A
	inc $20 ;next source byte
	inx
	cpx #$0010 ;read 16 bytes
	bne CopyAndPad
}
jmp $E918