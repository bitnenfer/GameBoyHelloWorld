section "Interrupt V-BLANK", ROM0[$0040]
	reti
section "Interrupt LCD STAT", ROM0[$0048]
	reti
section "Interrupt Timer", ROM0[$0050]
	reti
section "Interrupt Serial", ROM0[$0058]
	reti
section "Interrupt Joypad", ROM0[$0060]
	reti
section "Entry Point", ROM0[$0100]
	nop
	jp $0150
section "Nintendo Logo", ROM0[$0104]
db $CE, $ED, $66, $66, $CC, $0D, $00, $0B, $03, $73, $00, $83, $00, $0C, $00, $0D
db $00, $08, $11, $1F, $88, $89, $00, $0E, $DC, $CC, $6E, $E6, $DD, $DD, $D9, $99
db $BB, $BB, $67, $63, $6E, $0E, $EC, $CC, $DD, $DC, $99, $9F, $BB, $B9, $33, $3E
section "Title", ROM0[$0134]
db "HELLO WORLD"
section "Manufacturer Code", ROM0[$013F]
db $00
section "CGB Flag", ROM0[$0143]
db $00
section "New Licensee Code", ROM0[$0144]
db $01, $4B
section "SGB Flag", ROM0[$0146]
db $00
section "Cartridge Type", ROM0[$0147]
db $00
section "ROM Size", ROM0[$0148]
db $00
section "Ext RAM Size", ROM0[$0149]
db $00
section "Destination Code", ROM0[$014A]
db $01
section "Old Licensee Code", ROM0[$014B]
db $00
section "Mask ROM Version number", ROM0[$014C]
db $00
section "Header Checksum", ROM0[$014D]
db $7E
section "Global Checksum", ROM0[$014E]
db $00, $00

section "Hello World Program", ROM0[$0150]

include "registers.asm"
include "sprites.asm"

dma_transfer equ $FF80

main:
	; Turn LCD OFF
	ld a, [rLCDC]
	res 7, a
	res 0, a
	ld [rLCDC], a

	ld de, start_dma_sr_addr
	ld hl, $FF80
	ld b, end_dma_sr_addr-start_dma_sr_addr
	call memcpy

	; Clear Shadow OAM
	xor a
	ld hl, $C100
	ld b, $A0
.clear_shadow_oam:
	ld [hl+], a
	dec b
	jr nz, .clear_shadow_oam

	; Turn LCD ON & Enable Sprites
	ld a, [rLCDC]
	set 7, a
	set 1, a
	ld [rLCDC], a

	; Setup sprite
	ld a, 160/2
	ld [rSPRITE0_X], a
	ld a, 144/2
	ld [rSPRITE0_Y], a
	ld a, $19
	ld [rSPRITE0_TILE], a
	xor a
	ld [rSPRITE0_ATTRIB], a


main_loop:
.wait_vblank:
	ld a, [rLY]
	cp 144
	jr nz, .wait_vblank
	call dma_transfer

	; DOWN - START
	; UP - SELECT
	; LEFT - B
	; RIGHT - A

	ld a, %00001000
	ld [$FF00], a
	ld a, [$FF00]
	ld a, [$FF00]
	ld a, [$FF00]
	ld a, [$FF00]
	ld a, [$FF00]
	ld a, [$FF00]
	ld b, a
.test_right:
	bit 0, b
	jr nz, .test_left
	ld a, [rSPRITE0_X]
	inc a
	ld [rSPRITE0_X], a
	jr .test_up
.test_left:
	bit 1, b
	jr nz, .test_up
	ld a, [rSPRITE0_X]
	dec a
	ld [rSPRITE0_X], a
.test_up:
	bit 2, b
	jr nz, .test_down
	ld a, [rSPRITE0_Y]
	dec a
	ld [rSPRITE0_Y], a
	jr .no_buttons
.test_down:
	bit 3, b
	jr nz, .no_buttons
	ld a, [rSPRITE0_Y]
	inc a
	ld [rSPRITE0_Y], a
.no_buttons:
	jr main_loop


	; DE = Source Address
	; HL = Destination Address
	; B = Copy Size
memcpy:
.copy_loop:
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, .copy_loop
	ret

start_dma_sr_addr:
	ld a, $C1
	ldh [DMA], a
	ld a, $28
wait:
	dec a
    db $20
    db $FD
    ret
end_dma_sr_addr:

section "Vars", WRAM0
tmp: ds $01