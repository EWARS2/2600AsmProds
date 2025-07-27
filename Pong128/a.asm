; Title: Pong
; Author: EWARS_2
; Description: Pong with no extra needed hardware.
; Fits entrirely in RAM & requires no controllers.

	processor 6502
	include "vcs.h"
	include "macro.h"


	
	SEG			; Start
	org $F000 	; of cartridge
; Magic 8-byte solution that Inits Stack, mem & pointer
; Thx Random Terrain & Andrew Davie!
Reset	ldx #0
		txa
Clear 	dex
		txs
		pha
		bne Clear
; After this, A=X=0





; Innit
	lda #$5E
	sta COLUBK
	lda #$FF
	sta COLUPF
	sta COLUP0
	sta COLUP1
	
	;lda #$FF
	sta GRP0
	sta GRP1
	sta ENAM0
	sta ENAM1
	sta ENABL
	
	
	lda #%00010000
	sta HMP0
	lda #%11110000
	sta HMP1
	
	sta RESMP0
	sta RESMP1
	sta HMOVE
	;sta HMCLR
	
	
	
	
	
; Might want to Innit Y here
; This is also where the copy2RAM code is gonna go


; This is where the actual code will be run.
; At least temporarily. Will try to splice this
; into the kernel to allow for smaller code.
StartOfFrame 
	sta HMOVE
	sta RESMP0
	sta RESMP1



VBlank ; & start of VBlank
	stx VBLANK ; Store 0
	lda #2
	sta VSYNC ; Store 2
	sta WSYNC ; 3 scanlines of VSync
	sta WSYNC
	sta WSYNC
	stx VSYNC ; Store 0


; 37 VBlank + 192 picture = 229 scanlines
; Merging this section of code to save some bytes
			ldx #229
Picture		sta WSYNC
			stx COLUBK
			dex
			bne Picture
; After this, X=0



; It'd be great if the Overscan & End of VBlank code
; code be merged into the Picture loop in the name of
; saved bytes,
; but this would require the loop to go 259 times, which
; would actually probably increase code size.
; (If we used a 16-bit number for the loop.)
; Something to look into.


; End of VBlank
			ldx #%01000010
			stx VBLANK ; Store #%01000010
; 30 lines of overscan
			ldx #29
Overscan	sta WSYNC
			dex
			bne Overscan
; After this, X=0
			jmp StartOfFrame
			

	org $FFFA
InterruptVectors
	.word Reset  ; NMI
	.word Reset  ; RESET
	.word Reset  ; IRQ
	END
