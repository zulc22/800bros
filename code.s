jmp entry

INCLUDE "ataridef.s"
INCLUDE "gfx/sprites.inc"

; Vars
ENUM $600

vwTempWord:     DSW 1
vwTempWord2:    DSW 1
vwTempWord3:    DSW 1

ENDE
ENUM $2000

mDMARAM:        DSB $1000
mCharRAM:       DSB $400
mDisplayList:   DSB $100

ENDE

MACRO phab byte
    lda byte
    pha
ENDM

MACRO phaw word
    phab >word
    phab <word
ENDM

MACRO plab byteloc
    pla
    sta byteloc
ENDM

MACRO plaw wordloc
    plab wordloc
    plab wordloc+1
ENDM

entry:
    sei
    cld
    clc

    phaw dChars
    phaw mCharRAM
    jsr srDataCopy

    phaw dDisplayList
    phaw mDisplayList
    jsr srDataCopy
    
    jsr srSetDisplay

    phaw dSprMarioBigJump
    jsr srLoadSprite

    ; Why isn't any sprite showing?

loop:

    inc mCharRAM
    clc
    
    jsr srWaitVSync

    jmp loop

nmi:
irq:
    rti

srSetDisplay:
    lda #%00111010
    sta DMACTL

    lda #0
    sta NMIEN
    lda #0
    sta IRQEN

    lda #>mDisplayList ; Give ANTIC displaylist
    sta DLISTH
    lda #<mDisplayList
    sta DLISTL

    lda #>mDMARAM ; Give ANTIC DMARAM addr
    sta PMBASE

    lda #20 ; set up p0
    sta HPOSP0

    lda #$FF
    sta SIZEP0

    lda #%00000010 ; Tell CTIA to recieve DMA
    sta GRACTL

    rts

srLoadSprite:   ; Loads a sprite('s C1) into dDMARAM
    plaw vwTempWord
    plaw vwTempWord2

    ; Load size and color
    ldy #0
    lda (vwTempWord2),y
    sta SIZEP0
    tax ; save on x because we can't read SIZEPx
    iny
    lda (vwTempWord2),y
    sta COLPM0
    iny ; skip other two colors
    iny
    
    ; Load sprite ptr
    lda (vwTempWord2),y
    sta vwTempWord3
    iny
    lda (vwTempWord2),y
    sta vwTempWord3+1

    ldy #0
@l: lda (vwTempWord2),y
    sta mDMARAM+$400,y
    dex
    beq @r
    iny
    jmp @l

@r: jmp (vwTempWord)

srWaitVSync:    ; Wait until VCOUNT=0
@l: sta WSYNC   ; wait for value to change
    sta WSYNC   
    lda VCOUNT
    beq @r      ; "if equal" to zero
    jmp @l
@r: rts

srFillPage:
    lda #$FF
    ldx #0
@f: sta $2200,x
    sta $2400,x
    inx
    beq @r
    jmp @f
@r: rts

srDataCopy:
    ; Get addr from after jsr call
    plaw vwTempWord
    plaw vwTempWord2
    plaw vwTempWord3

    ldx #0
    lda (vwTempWord2),x
    tay
    inc vwTempWord2+1
    bcc @nc
    inc vwTempWord2
@nc:

@c: lda (vwTempWord2),x
    sta (vwTempWord3),x
    dey
    beq @d
    inx
    jmp @c
@d:
    ; Return
    jmp (vwTempWord)


dDisplayList:
DB dDisplayList-dDisplayListEnd

    DB $70, $70, $70 ; vblank (24 lines)

    DB $40 + $02 ; Load Memory Scan... Do Mode 4
    DW mCharRAM

    ; Tiles
    DB $02
    DB $02
    DB $02
    DB $02
    DB $02
    DB $02
    DB $02
    DB $02
    DB $02
    DB $02
    DB $02
    DB $02
    DB $02
    DB $02
    DB $02
    DB $02
    DB $02
    DB $02
    DB $02
    DB $02
    DB $02
    DB $02
    DB $02

    DB $41 ; Jump after JVB
    DW mDisplayList

dDisplayListEnd:

dChars:
DB dChars-dCharsEnd
    DB 0
    DB "  HELLO WORLD !!!  " AS_ATASCII
dCharsEnd:
