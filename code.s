jmp entry

INCLUDE "ataridef.s"
INCLUDE "gfx/sprites.inc"

; Vars
ENUM $800

vwTempWord:     DSW 1
vwTempWord2:    DSW 1
vwTempWord3:    DSW 1

ENDE
ENUM $4000

mDMARAM:        DSB $1000
mCharRAM:       DSB $400
mDisplayList:   DSB $100

ENDE

; Affects: Stack, A
; Push byte (immediate)
MACRO phab_i value
    lda #value
    pha
ENDM

; Affects: Stack, A
; Push byte (from address)
MACRO phab_a valueloc
	lda valueloc
	pha
ENDM

; Affects: Stack, A
; Push word (immediate)
MACRO phaw_i value
	phab_i >value
	phab_i <value
ENDM

; Affects: Stack, A
; Push word (from address)
MACRO phaw_a valueloc
    phab_a >valueloc
    phab_a <valueloc
ENDM

; Affects: Stack, A
; Pull and store byte in memory
MACRO pla_sb byteloc
    pla
    sta byteloc
ENDM

; Affects: Stack, A
; Pull word into memory
MACRO pla_sw wordloc
    plab wordloc
    plab wordloc+1
ENDM

; Stop processor
MACRO kil
    DB $42
ENDM

entry:
    sei
    cld
    clc

    jsr srSelfTest

    phaw_i dChars
    phaw_i mCharRAM
    jsr srDataCopy
	jmp loop

    phaw_i dDisplayList
    phaw_i mDisplayList
    jsr srDataCopy
    
    jsr srSetDisplay
	
    phaw_i dSprMarioBigJump
    jsr srLoadSprite

    ; Why isn't any sprite showing?
	
loop:

    inc mCharRAM
    clc
    
    jsr srWaitVSync

    jmp loop
	
; Unused -- I haven't figured out how to
; set the NMI/IRQ/RESET vector yet :(
nmi:
irq:
    rti

srSelfTest: ; Self-test macros and other stuff for debugging

    phaw $00FF
    plaw vwTempWord

    ; ram should be 'FF 00'
    lda vwTempWord
    cmp #$FF
    bne +
    lda vwTempWord+1
    cmp #$00
    bne +
    rts

+:  kil
    jmp +

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


; Copy data.
; Stackargs(source_address, target_address)
; source: db length, db data[length]
srDataCopy:
    pla_sw vwTempWord  ; pull return address 
    pla_sw vwTempWord3 ; pull data target addr
    pla_sw vwTempWord2 ; pull data source addr

    ldx #0
    lda (vwTempWord2),x
    tay
    inc vwTempWord2+1
    bcc +
    inc vwTempWord2
+:-:lda (vwTempWord2),x
    sta (vwTempWord3),x
    dey
    beq +
    inx
    jmp -
+:  ; Return
    jmp (vwTempWord)

dDisplayList:
DB dDisplayListEnd-dDisplayList

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
DB dCharsEnd-dChars
    DB 0
    DB "  HELLO WORLD !!!  " AS_ATASCII
dCharsEnd:
