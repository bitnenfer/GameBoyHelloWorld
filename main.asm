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

main:
	ld a, [$FF40]
	res 7, a
	ld [$FF40], a

	ld de, letter_h
	ld hl, $8200
	ld b, 16
	call tile_memcpy

	ld de, letter_e
	ld hl, $8210
	ld b, 16
	call tile_memcpy

	ld de, letter_l
	ld hl, $8220
	ld b, 16
	call tile_memcpy

	ld de, letter_o
	ld hl, $8230
	ld b, 16
	call tile_memcpy

	ld de, letter_w
	ld hl, $8240
	ld b, 16
	call tile_memcpy

	ld de, letter_r
	ld hl, $8250
	ld b, 16
	call tile_memcpy

	ld de, letter_d
	ld hl, $8260
	ld b, 16
	call tile_memcpy

	ld a, $20 	 	; H
	ld [$9800], a
	ld a, $21 		; E
	ld [$9801], a
	ld a, $22 		; L
	ld [$9802], a
	ld a, $22		; L
	ld [$9803], a
	ld a, $23 		; O
	ld [$9804], a

	ld a, $24 		; W
	ld [$9806], a
	ld a, $23 		; O
	ld [$9807], a
	ld a, $25 		; R
	ld [$9808], a
	ld a, $22 		; L
	ld [$9809], a
	ld a, $26 		; D
	ld [$980A], a

	ld a, 144 / 2
	ld [$FE00], a
	ld a, 160 / 2
	ld [$FE01], a
	ld a, $19
	ld [$FE02], a

	xor a
	ld [scroll_x], a

	ld a, [$FF40]
	set 7, a
	set 1, a
	ld [$FF40], a

main_loop:
	ld a, [scroll_x]
	ld [$FF43], a

.wait_scroll_limit:
	ld a, [$FF44]
	cp 9
	jr nz, .wait_scroll_limit	

	xor a
	ld [$FF43], a

.wait_vblank:
	ld a, [$FF44]
	cp 144
	jr nz, .wait_vblank

	ld a, [$FE00]
	inc a
	ld [$FE00], a
	ld a, [$FE01]
	inc a
	ld [$FE01], a

	ld a, [scroll_x]
	inc a
	ld [scroll_x], a

	jr main_loop

	; DE = Source Address
	; HL = Destination Address
	; B = Copy Size
tile_memcpy:
.copy_loop:
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, .copy_loop
	ret

letter_h:
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01111111
db %01111111
db %01111111
db %01111111
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011

letter_e:
db %01111111
db %01111111
db %01111111
db %01111111
db %01100000
db %01100000
db %01111111
db %01111111
db %01111111
db %01111111
db %01100000
db %01100000
db %01111111
db %01111111
db %01111111
db %01111111

letter_l:
db %01100000
db %01100000
db %01100000
db %01100000
db %01100000
db %01100000
db %01100000
db %01100000
db %01100000
db %01100000
db %01100000
db %01100000
db %01111111
db %01111111
db %01111111
db %01111111

letter_o:
db %00111110
db %00111110
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %00111110
db %00111110

letter_w:
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01101011
db %01101011
db %01101011
db %01101011
db %01101011
db %01101011
db %00111110
db %00111110

letter_r:
db %01111111
db %01111111
db %01111111
db %01111111
db %01100011
db %01100011
db %01111100
db %01111100
db %01111111
db %01111111
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011

letter_d:
db %01111110
db %01111110
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01100011
db %01111110
db %01111110

section "Vars", WRAM0
scroll_x: ds $01