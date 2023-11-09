; Tower Dream (SFC) (CRC32: AA2D5C55)
; Switch char encoding to one byte

lorom

org $05E856
nop ;delete 2nd advance
nop

org $05E864
jmp InsertSecondByte

org $05FFD4
InsertSecondByte: ;supply $82 highbyte to A's lowbyte
lda [$16],y
xba
and #$FF00
ora #$0082
cmp #$F082 ;special break cases replaced: name variable
beq BranchVariable
cmp #$0082 ;end string
rts
BranchVariable:
jmp $E86F