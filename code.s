jmp entry

INCLUDE "ataridef.s"
INCLUDE "gfx/sprites.inc"

; Vars
ENUM $800

vwTempWord: DSW 1
vwTempWord2: DSW 1

ENDE

ENUM $2000

mDMARAM: DSB $FFF

ENDE

entry:
    sei
    cld
    clc

    jsr srSetDisplay

loop:

    inc mCharRAM
    clc
    
    jsr srWaitVSync

    jsr srLoadSprite
    DW dSprMarioBigStand

    jmp loop

srSetDisplay:
    lda #%00111010
    sta DMACTL

    lda #>mDisplayList
    sta DLISTH
    lda #<mDisplayList
    sta DLISTL

    lda #<mDMARAM
    sta PMBASE

    lda #20
    sta HPOSP0
    lda dSprMarioBigStand+0
    sta SIZEP0
    lda #2 ; Tell CTIA to recieve DMA
    sta GRACTL

    rts

srLoadSprite:
    ; Get addr from after jsr call
    pla
    clc
    adc #2
    sta vwTempWord
    pla
    sta vwTempWord+1
    bcc @nc
    inc vwTempWord
@nc:
    
    ; Load size and color
    ldy #0
    lda (vwTempWord),y
    sta SIZEP0
    tax ; save on x because we can't read SIZEPx
    iny
    lda (vwTempWord),y
    sta COLPM0
    iny ; skip other two colors
    iny
    
    ; Load sprite ptr
    lda (vwTempWord),y
    sta vwTempWord2
    iny
    lda (vwTempWord),y
    sta vwTempWord2+1

    ldy #0
@l: lda (vwTempWord2),y
    sta mDMARAM+$200,y
    dex
    beq @r
    iny
    jmp @l

@r: ; Return
    jmp (vwTempWord)

srWaitVSync:    ; Wait until VCOUNT=0
@l: sta WSYNC   ; wait for value to change
    sta WSYNC   
    lda VCOUNT
    beq @r      ; "if equal" to zero
    jmp @l
@r: rts

mDisplayList:

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

mCharRAM:
DB 0
DB "  HELLO WORLD !!!  " AS_ATASCII
PAD mCharRAM+$400, "A" AS_ATASCII