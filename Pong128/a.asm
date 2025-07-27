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
	
	
	
	
	
; Y still hasn't been init yet
; This is also where the copy2RAM code is gonna go
; when the core game is finished


; This is where the actual code will be run.
; At least temporarily. Will try to splice this
; into the kernel to allow for smaller code.
StartOfFrame 
	sta HMOVE
	;sta RESMP0
	;sta RESMP1



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
			;stx COLUBK
			
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
			


; Positions an object horizontally
; Inputs: A = Desired position.
; X = Desired object to be positioned (0-5).
; scanlines: If control comes on or before cycle 73 then 1 scanline is consumed.
; If control comes after cycle 73 then 2 scanlines are consumed.
; Outputs: X = unchanged
; A = Fine Adjustment value.
; Y = the "remainder" of the division by 15 minus an additional 15.
; control is returned on cycle 6 of the next scanline.
PosObject   SUBROUTINE
            sta WSYNC                ; 00     Sync to start of scanline.
            sec                      ; 02     Set the carry flag so no borrow will be
                                     ;        applied during the division.
.divideby15 sbc #15                  ; 04     Waste the necessary amount of time
                                     ;        dividing X-pos by 15!
            bcs .divideby15          ; 06/07  11/16/21/26/31/36/41/46/51/56/61/66
            tay
            lda fineAdjustTable,y    ; 13 -> Consume 5 cycles by guaranteeing we
                                     ;       cross a page boundary
            sta HMP0,x
            sta RESP0,x              ; 21/ 26/31/36/41/46/51/56/61/66/71
                                     ; Set the rough position.
            rts
;-----------------------------
; This table converts the "remainder" of the division by 15 (-1 to -15) to the correct
; fine adjustment value. This table is on a page boundary to guarantee the processor
; will cross a page boundary and waste a cycle in order to be at the precise position
; for a RESP0,x write
            ORG $FF00 ;$Fx00 $F000
fineAdjustBegin
            DC.B %01110000; Left 7 
            DC.B %01100000; Left 6
            DC.B %01010000; Left 5
            DC.B %01000000; Left 4
            DC.B %00110000; Left 3
            DC.B %00100000; Left 2
            DC.B %00010000; Left 1
            DC.B %00000000; No movement.
            DC.B %11110000; Right 1
            DC.B %11100000; Right 2
            DC.B %11010000; Right 3
            DC.B %11000000; Right 4
            DC.B %10110000; Right 5
            DC.B %10100000; Right 6
            DC.B %10010000; Right 7
fineAdjustTable EQU fineAdjustBegin - %11110001; NOTE: %11110001 = -15




	org $FFFA
InterruptVectors
	.word Reset  ; NMI
	.word Reset  ; RESET
	.word Reset  ; IRQ
	END
