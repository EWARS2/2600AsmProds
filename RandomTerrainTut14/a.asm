; Test program - EWARS_2

	processor 6502
	include "vcs.h"
	include "macro.h"
	
;--------------------------------------------------------------------
	;SEG.U variables
	;org $80
;LAB1 ds 4 ; def 4 bytes of space for this var
;LAB2 ds 1 ; def 1 byte of space for this var
;--------------------------------------------------------------------
	
	SEG			; Start
	org $F000 	; of cartridge
Reset


; Magic 8-byte solution that Inits Stack, mem & pointer
; Thx Random Terrain & Andrew Davie!
		ldx #0
		txa
Clear 	dex
		txs
		pha
		bne Clear
; After this, A=X=0


; Innit
	lda #$45
	sta COLUPF
	
	lda #%00000000
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


; 37 scanlines of VBlank
				ldx #36
VerticalBlank	sta WSYNC
				dex
				bne VerticalBlank



; 192 scanlines of picture
	ldx #0 ; this counts our scanline number
	
	lda #%11111111
	sta PF0
	sta PF1
	sta PF2

	
; We won't bother rewriting PF# every scanline
; of the top 8 lines - they never change!
Top8Lines	sta WSYNC
			inx
			cpx #8	; Are we @ line 8?
			bne Top8Lines ; If not, do another.


; Now we want 176 lines of "Wall"
; Note: 176 (Middle) + 8 (Top) + 8 (Bottom) = 192 scanlines
		lda #%00010000 ; PF0 is mirrored <-- direction
		sta PF0 ; low 4 bits are ignored
		lda #0
		sta PF1
		sta PF2

; Again we don't bother writing PF# every scanline
; They don't change!

MiddleLines		sta WSYNC
				
				
				lda #$FF
				sta PF0
				sta PF1
				sta PF2
				lda #%00000000
				
				
				
				ldy #0
Wait			iny		; This is all me trying to make asymetrical playfield work
				cpy #5
				bne Wait
				
				
				
				
				inx
				cpx #184
				bne MiddleLines


; Finally, our bottom 8 scanlines
	lda #%11111111
	sta PF0
	sta PF1
	sta PF2
	
Bottom8Lines	sta WSYNC
				inx
				cpx #192
				bne Bottom8Lines

	lda #%01000010
	sta VBLANK ; End of screen - enter blanking


; 30 lines of overscan
			ldx #0
Overscan	sta WSYNC
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