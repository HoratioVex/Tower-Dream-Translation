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
jml $878010
ReturnToOldBank:
rts

org $878010 ;switch to name and load next
lda $16
inc
sta $26
lda $18
sta $28
lda #$1ec2
sta $16
stz $18
LoadNext:
lda [$16],y
xba
and #$FF00
cmp #$0000
beq IfZero
ora #$0082
jml ReturnToOldBank
IfZero:
jml $05e885

org $05e880
jml LoadNext ;next char in name

org $05D895 ;construct string for AI profile winrate
lda #$aaaa
sta $1ec4
sta $1ec5

org $059b0b
adc #$6f50 ;player number string: "Px"

org $05D8D5
;sep #$30
lda $10
beq SkipFirstDigit
asl
tax
lda $05d913,x
sta $1ec4
SkipFirstDigit:
lda $12
asl
tax
lda $05d913,x
sta $1ec8
lda $14
asl
tax
lda $05d913,x
sta $1ec7
lda $16
asl
tax
lda $05d913,x
sta $1ec6

org $5d855 ;construct string for level select data window numbers (hook)
jml ConstructLevelData

org $878036 ;copied loop, can't hook after it
ConstructLevelData:
lda $12
bne LSLoadDigit
lda $1ec6,y
bne LSLoadDigit
lda $14
cmp #$0001
beq LSLoadDigit
lda #$000a
bra LSWriteDigit
LSLoadDigit:
lda $1ec6,y
ora $12
sta $12
lda $1ec6,y
LSWriteDigit:
asl
tax
lda $05d913,x
sta $1ec6,y
iny
iny
dec $14
bne ConstructLevelData
sep #$20 ;copy digits forward
lda $1ec9
sta $1ec8
lda $1ecb
sta $1ec9
lda $1ecd
sta $1eca
rep #$20
stz $1ecb
jml $05d883

org $5882c ;construct string for level load window
lda #$aaaa ;init with space

org $58837
cpx #$0018 ;6*4 instead of 8*4 tiles

org $58888 ;write 6 letters (COM)
jml LevelLoadCom
MultBy6: ;can't bitshift, help with table
db $00,$06,$0C,$12
org $588b0 ;write 6 letters (player)
jml LevelLoadPly

org $878081
LevelLoadCom:
bank $05
tay
sep #$20
lda MultBy6,y
tay
lda #$06
sta $12
LLCLoop:
lda $0588cc,x
sta $1ec4,y
inx
iny
dec $12
bne LLCLoop
rep #$20
jml $588a0

LevelLoadPly:
tay
sep #$20
lda MultBy6,y
tay
lda #$06
sta $12
LLPLoop:
lda $700028,x
beq LLPSkip
sta $1ec4,y
LLPSkip:
inx
iny
dec $12
bne LLPLoop
rep #$20
jml $588ca

nop #4