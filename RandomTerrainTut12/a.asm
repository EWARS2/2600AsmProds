; Test program - EWARS_2

	processor 6502
	include "vcs.h"
	include "macro.h"
	
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
; After this, X = 0 = 


StartOfFrame


; Start of vertical blank processing
	lda #0
	sta VBLANK
	
	lda #2
	sta VSYNC
	
; 3 scanlines of VSYNC signal
	sta WSYNC
	sta WSYNC
	sta WSYNC
	
	lda #0
	sta VSYNC
	
; 37 scanlines of VBlank
	ldx #36
DrawVBlank
	dex
	sta WSYNC
	bne DrawVBlank

; 192 scanlines of picture
	ldx $FE
	inx
	stx $FE
	
	REPEAT 192; scanlines, this is terribly ineffecient
	
	inx
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	stx COLUBK
	sta WSYNC
	
	REPEND
	
	
	lda #%01000010
	sta VBLANK ; end of screen - enter blanking
	
; 30 scanlines of overscan
	ldx #29
DrawOverscan
	dex
	sta WSYNC
	bne DrawOverscan

	jmp StartOfFrame


	org $FFFA
	.word Reset  ; NMI
	.word Reset  ; RESET
	.word Reset  ; IRQ

	END