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
    jsr srLoadSprite
    DW dSprMarioBigStand

    ; Why isn't any sprite showing?

loop:

    inc mCharRAM
    clc
    
    jsr srWaitVSync

    jmp loop

srSetDisplay:
    lda #%00111010
    sta DMACTL

    lda #$40 ; OS default NMI
    sta NMIEN

    lda #>mDisplayList ; Give ANTIC displaylist
    sta DLISTH
    lda #<mDisplayList
    sta DLISTL

    lda #>mDMARAM ; Give ANTIC DMARAM addr
    sta PMBASE

    lda #20 ; set up p0
    sta HPOSP0

    lda dSprMarioBigStand+0 ; TODO: move this to srLoadSprite
    sta SIZEP0

    lda #%00000010 ; Tell CTIA to recieve DMA
    sta GRACTL

    rts

srLoadSprite:   ; Loads a sprite('s C1) into dDMARAM
    ; Get addr from after jsr call
    pla
    clc
    adc #1
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
    sta mDMARAM+$400,y
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