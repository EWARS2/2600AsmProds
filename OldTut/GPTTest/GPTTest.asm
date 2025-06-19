	processor 6502
	include "vcs.h"
	org $F000

PlayerX = $80
PlayerY = $F0
BulletX = $90
BulletY = $F4

	;.segment "CODE"

Start
    SEI
    CLD
    LDX #$40
    STX VSYNC
    LDA #$00
    STA WSYNC
    STA COLUBK
    LDA #$2D
    STA GRP0
    STA GRP1
    LDA #$08
    STA CTRLPF
    LDA #<PlayerGraphics
    STA ENAM0
    LDA #>PlayerGraphics
    STA ENAM0+1
    LDA #<BulletGraphics
    STA ENAM1
    LDA #>BulletGraphics
    STA ENAM1+1

MainLoop
    JSR PlayerMovement
    JSR BulletMovement
    JMP MainLoop

PlayerMovement
    LDA SWCHA
    AND #$10
    BEQ NoMove
    LDA SWCHA
    AND #$01
    BEQ MoveLeft
    LDA PlayerX
    DEY
    STY PlayerY
    LDA PlayerY
    BNE NoMove
    LDY #$0A
    STY PlayerY
    LDA TIM64T,Y
    STA WSYNC
    JMP NoMove
MoveLeft
    LDA PlayerX
    DEX
    STX PlayerX
    LDA PlayerX
    BEQ NoMove
    LDY #$02
    STY PlayerX
    LDA TIM64T,Y
    STA WSYNC
NoMove
    RTS

BulletMovement
    LDA PlayerY
    BEQ NoBullet
    LDA BulletY
    BNE NoBullet
    LDA PlayerX
    BEQ NoBullet
    LDA BulletX
    BNE NoBullet
    LDA PlayerX
    LDY #$03
    STA BulletX
    LDA PlayerY
    STY BulletY
NoBullet
    RTS

PlayerGraphics
    .byte %00000100
    .byte %00001110
    .byte %01111111
    .byte %00111100

BulletGraphics
    .byte %00001000
    .byte %00001000
    .byte %00001000
    .byte %00001000

;.segment "RAM"

    .ds 32

	org $FFFC
	.word Start
	.word Start
