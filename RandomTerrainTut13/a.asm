; Test program - EWARS_2

	processor 6502
	include "vcs.h"
	include "macro.h"
	
;--------------------------------------------------------------------
	
PATTERN				= $80	; Storage location (1st byte in RAM)
TIMETOCHANGE		= 2	; Speed of "Animation" - Can be adjusted
	
;--------------------------------------------------------------------
	
	SEG
	org $F000 ; Start of cartridge



Reset



; Magic 8-byte solution that Inits Stack, mem & pointer
; Thx Random Terrain & Andrew Davie!
	ldx #0
	txa
Clear dex
	txs
	pha
	bne Clear
; After this, A=X=0



; Innit
	sta PATTERN
	ldy #0
	
	lda #1
	sta CTRLPF

	

StartOfFrame
; Start of new frame
; Start of VBlank processing
	lda #0
	sta VBLANK
	lda #2
	sta VSYNC
	
; 3 Scanlines of VSYNC signal
	sta WSYNC
	sta WSYNC
	sta WSYNC

	lda #0
	sta VSYNC


; 37 scnalines of VBlank
	ldx #0
VerticalBlank
	sta WSYNC
	inx
	cpx #37
	bne VerticalBlank

; Handle a change in the pattern once every 20 frames
; & write the pattern to PF1
	iny
	cpy #TIMETOCHANGE
	bne notyet
	
	ldy #0
	inc PATTERN
notyet

	lda PATTERN
	sta PF1
	

; 192 scanlines of picture
	ldx #0
Picture
	;stx COLUBK
	sta WSYNC
	
	stx COLUPF
	stx PF2
	
	inx
	cpx #192
	bne Picture

	lda #%01000010
	sta VBLANK
	
; 30 lines of overscan
	ldx #0
Overscan
	sta WSYNC
	inx
	cpx #30
	bne Overscan
	
	
	jmp StartOfFrame
	
	


	org $FFFA
InterruptVectors
	.word Reset  ; NMI
	.word Reset  ; RESET
	.word Reset  ; IRQ

	END