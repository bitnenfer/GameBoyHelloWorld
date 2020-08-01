if !def(_REGISTERS_)
_REGISTERS_ equ 1

; *** MBC5 Equates ***

rRAMG        EQU $0000 ; $0000->$1fff
rROMB0       EQU $2000 ; $2000->$2fff
rROMB1       EQU $3000 ; $3000->$3fff - If more than 256 ROM banks are present.
rRAMB        EQU $4000 ; $4000->$5fff - Bit 3 enables rumble (if present)

; Interrupt Instruction Info
; EI     ;Enable Interrupts  (ie. IME=1)
; DI     ;Disable Interrupts (ie. IME=0)
; RETI   ;Enable Ints & Return (same as the opcode combination EI, RET)
; <INT>  ;Disable Ints & Call to Interrupt Vector

; Interrupt Enable
; Bit 0: V-Blank  Interrupt Enable  (INT 40h)  (1=Enable)
; Bit 1: LCD STAT Interrupt Enable  (INT 48h)  (1=Enable)
; Bit 2: Timer    Interrupt Enable  (INT 50h)  (1=Enable)
; Bit 3: Serial   Interrupt Enable  (INT 58h)  (1=Enable)
; Bit 4: Joypad   Interrupt Enable  (INT 60h)  (1=Enable)
rINT_ENABLE equ $FFFF

; Interrupt Flag
; Bit 0: V-Blank  Interrupt Request (INT 40h)  (1=Request)
; Bit 1: LCD STAT Interrupt Request (INT 48h)  (1=Request)
; Bit 2: Timer    Interrupt Request (INT 50h)  (1=Request)
; Bit 3: Serial   Interrupt Request (INT 58h)  (1=Request)
; Bit 4: Joypad   Interrupt Request (INT 60h)  (1=Request)
rINT_FLAG equ $FF0F

; DIV - Divider Register (R/W)
; Can't use DIV because RGBDS complains :/
rDIV_REG equ $FF04

; TIMA - Timer Counter (R/W)
rTIMA equ $FF05

; TMA - Timer Modulo (R/W)
rTMA equ $FF06

; TAC - Timer Control (R/W)
; Bit  2   - Timer Enable
; Bits 1-0 - Input Clock Select
;            00: CPU Clock / 1024 (DMG, CGB:   4096 Hz, SGB:   ~4194 Hz)
;            01: CPU Clock / 16   (DMG, CGB: 262144 Hz, SGB: ~268400 Hz)
;            10: CPU Clock / 64   (DMG, CGB:  65536 Hz, SGB:  ~67110 Hz)
;            11: CPU Clock / 256  (DMG, CGB:  16384 Hz, SGB:  ~16780 Hz)
; 
; Note: The "Timer Enable" bit only affects the timer, the divider is ALWAYS counting.
rTAC equ $FF07

; Work Ram
WRAM equ $C000

; DMG Display
; -----------
LCD_MAP_TOTAL_WIDTH equ $20
LCD_MAP_TOTAL_HEIGHT equ $20
LCD_WIDTH equ $A0
LCD_HEIGHT equ $90

; FF40 - LCDC - LCD Control (R/W)
;  Bit 7 - LCD Display Enable             (0=Off, 1=On)
;  Bit 6 - Window Tile Map Display Select (0=9800-9BFF, 1=9C00-9FFF)
;  Bit 5 - Window Display Enable          (0=Off, 1=On)
;  Bit 4 - BG & Window Tile Data Select   (0=8800-97FF, 1=8000-8FFF)
;  Bit 3 - BG Tile Map Display Select     (0=9800-9BFF, 1=9C00-9FFF)
;  Bit 2 - OBJ (Sprite) Size              (0=8x8, 1=8x16)
;  Bit 1 - OBJ (Sprite) Display Enable    (0=Off, 1=On)
;  Bit 0 - BG Display (for CGB see below) (0=Off, 1=On)
rLCDC equ $FF40

; FF41 - STAT - LCDC Status (R/W)
;   Bit 6 - LYC=LY Coincidence Interrupt (1=Enable) (Read/Write)
;   Bit 5 - Mode 2 OAM Interrupt         (1=Enable) (Read/Write)
;   Bit 4 - Mode 1 V-Blank Interrupt     (1=Enable) (Read/Write)
;   Bit 3 - Mode 0 H-Blank Interrupt     (1=Enable) (Read/Write)
;   Bit 2 - Coincidence Flag  (0:LYC<>LY, 1:LYC=LY) (Read Only)
;   Bit 1-0 - Mode Flag       (Mode 0-3, see below) (Read Only)
;             0: During H-Blank
;             1: During V-Blank
;             2: During Searching OAM-RAM
;             3: During Transfering Data to LCD Driver
rLCDS equ $FF41

; Scroll Y (R/W)
rSCY equ $FF42

; Scroll X (R/W)
rSCX equ $FF43

; LCDC Y-Coordinate (R)
rLY equ $FF44

; LY Compare (R/W)
rLYC equ $FF45

; Window Y Position (R/W)
rWY equ $FF4A

; Window X Position minus 7 (R/W)
rWX equ $FF4B

; FF47 - BGP - BG Palette Data (R/W) - Non CGB Mode Only
; This register assigns gray shades to the color numbers of the BG and Window tiles.
;   Bit 7-6 - Shade for Color Number 3
;   Bit 5-4 - Shade for Color Number 2
;   Bit 3-2 - Shade for Color Number 1
;   Bit 1-0 - Shade for Color Number 0
; The four possible gray shades are:
;   0  White
;   1  Light gray
;   2  Dark gray
;   3  Black
; In CGB Mode the Color Palettes are taken from CGB Palette Memory instead.
rBGP equ $FF47

; FF48 - OBP0 - Object Palette 0 Data (R/W) - Non CGB Mode Only
rOBJP0 equ $FF48

; FF49 - OBP1 - Object Palette 1 Data (R/W) - Non CGB Mode Only
rOBJP1 equ $FF49

; FF46 - DMA - DMA Transfer and Start Address (W)
; Writing to this register launches a DMA transfer from ROM or RAM 
; to OAM memory (sprite attribute table). The written value specifies
; the transfer source address divided by 100h, ie. source & 
; destination are:
;   Source:      XX00-XX9F   ;XX in range from 00-F1h
;   Destination: FE00-FE9F
; It takes 160 microseconds until the transfer has completed 
; (80 microseconds in CGB Double Speed Mode), during this time the 
; CPU can access only HRAM (memory at FF80-FFFE). For this reason, 
; the programmer must copy a short procedure into HRAM, and use this 
; procedure to start the transfer from inside HRAM, and wait until 
; the transfer has finished:
;    ld  (0FF46h),a ;start DMA transfer, a=start address/100h
;    ld  a,28h      ;delay...
;   wait:           ;total 5x40 cycles, approx 200ms
;    dec a          ;1 cycle
;    jr  nz,wait    ;4 cycles
; Most programs are executing this procedure from inside of their 
; VBlank procedure, but it is possible to execute it during 
; display redraw also, allowing to display more than 40 sprites on 
; the screen (ie. for example 40 sprites in upper half, and other 
; 40 sprites in lower half of the screen).
DMA equ $FF46

VRAM_TILE_START equ $8000
VRAM_TILE_END equ $97FF
VRAM_BGMAP0_START equ $9800
VRAM_BGMAP0_END equ $9BFF
VRAM_BGMAP1_START equ $9C00
VRAM_BGMAP1_END equ $9FFF
VRAM_BGMAP_STRIDE equ $20

; OAM Data
; Byte0 - Y Position
; Specifies the sprites vertical position on the screen (minus 16).
; An offscreen value (for example, Y=0 or Y>=160) hides the sprite.
; 
; Byte1 - X Position
; Specifies the sprites horizontal position on the screen (minus 8).
; An offscreen value (X=0 or X>=168) hides the sprite, but the sprite
; still affects the priority ordering - a better way to hide a sprite is to set its Y-coordinate offscreen.
; 
; Byte2 - Tile/Pattern Number
; Specifies the sprites Tile Number (00-FF). This (unsigned) value selects a tile from memory at 8000h-8FFFh. In CGB Mode this could be either in VRAM Bank 0 or 1, depending on Bit 3 of the following byte.
; In 8x16 mode, the lower bit of the tile number is ignored. Ie. the upper 8x8 tile is "NN AND FEh", and the lower 8x8 tile is "NN OR 01h".
; 
; Byte3 - Attributes/Flags:
;   Bit7   OBJ-to-BG Priority (0=OBJ Above BG, 1=OBJ Behind BG color 1-3)
;          (Used for both BG and Window. BG color 0 is always behind OBJ)
;   Bit6   Y flip          (0=Normal, 1=Vertically mirrored)
;   Bit5   X flip          (0=Normal, 1=Horizontally mirrored)
;   Bit4   Palette number  **Non CGB Mode Only** (0=OBP0, 1=OBP1)
;   Bit3   Tile VRAM-Bank  **CGB Mode Only**     (0=Bank 0, 1=Bank 1)
;   Bit2-0 Palette number  **CGB Mode Only**     (OBP0-7)
rOAM0 equ $FE00
rOAM0_Y equ $FE00
rOAM0_X equ $FE01
rOAM0_TILE equ $FE02
rOAM0_ATTRIB equ $FE03
rOAM1 equ $FE04
rOAM1_Y equ $FE04
rOAM1_X equ $FE05
rOAM1_TILE equ $FE06
rOAM1_ATTRIB equ $FE07
rOAM2 equ $FE08
rOAM2_Y equ $FE08
rOAM2_X equ $FE09
rOAM2_TILE equ $FE0A
rOAM2_ATTRIB equ $FE0B
rOAM3 equ $FE0C
rOAM3_Y equ $FE0C
rOAM3_X equ $FE0D
rOAM3_TILE equ $FE0E
rOAM3_ATTRIB equ $FE0F
rOAM4 equ $FE10
rOAM4_Y equ $FE10
rOAM4_X equ $FE11
rOAM4_TILE equ $FE12
rOAM4_ATTRIB equ $FE13
rOAM5 equ $FE14
rOAM5_Y equ $FE14
rOAM5_X equ $FE15
rOAM5_TILE equ $FE16
rOAM5_ATTRIB equ $FE17
rOAM6 equ $FE18
rOAM6_Y equ $FE18
rOAM6_X equ $FE19
rOAM6_TILE equ $FE1A
rOAM6_ATTRIB equ $FE1B
rOAM7 equ $FE1C
rOAM7_Y equ $FE1C
rOAM7_X equ $FE1D
rOAM7_TILE equ $FE1E
rOAM7_ATTRIB equ $FE1F
rOAM8 equ $FE20
rOAM8_Y equ $FE20
rOAM8_X equ $FE21
rOAM8_TILE equ $FE22
rOAM8_ATTRIB equ $FE23
rOAM9 equ $FE24
rOAM9_Y equ $FE24
rOAM9_X equ $FE25
rOAM9_TILE equ $FE26
rOAM9_ATTRIB equ $FE27
rOAM10 equ $FE28
rOAM10_Y equ $FE28
rOAM10_X equ $FE29
rOAM10_TILE equ $FE2A
rOAM10_ATTRIB equ $FE2B
rOAM11 equ $FE2C
rOAM11_Y equ $FE2C
rOAM11_X equ $FE2D
rOAM11_TILE equ $FE2E
rOAM11_ATTRIB equ $FE2F
rOAM12 equ $FE30
rOAM12_Y equ $FE30
rOAM12_X equ $FE31
rOAM12_TILE equ $FE32
rOAM12_ATTRIB equ $FE33
rOAM13 equ $FE34
rOAM13_Y equ $FE34
rOAM13_X equ $FE35
rOAM13_TILE equ $FE36
rOAM13_ATTRIB equ $FE37
rOAM14 equ $FE38
rOAM14_Y equ $FE38
rOAM14_X equ $FE39
rOAM14_TILE equ $FE3A
rOAM14_ATTRIB equ $FE3B
rOAM15 equ $FE3C
rOAM15_Y equ $FE3C
rOAM15_X equ $FE3D
rOAM15_TILE equ $FE3E
rOAM15_ATTRIB equ $FE3F
rOAM16 equ $FE40
rOAM16_Y equ $FE40
rOAM16_X equ $FE41
rOAM16_TILE equ $FE42
rOAM16_ATTRIB equ $FE43
rOAM17 equ $FE44
rOAM17_Y equ $FE44
rOAM17_X equ $FE45
rOAM17_TILE equ $FE46
rOAM17_ATTRIB equ $FE47
rOAM18 equ $FE48
rOAM18_Y equ $FE48
rOAM18_X equ $FE49
rOAM18_TILE equ $FE4A
rOAM18_ATTRIB equ $FE4B
rOAM19 equ $FE4C
rOAM19_Y equ $FE4C
rOAM19_X equ $FE4D
rOAM19_TILE equ $FE4E
rOAM19_ATTRIB equ $FE4F
rOAM20 equ $FE50
rOAM20_Y equ $FE50
rOAM20_X equ $FE51
rOAM20_TILE equ $FE52
rOAM20_ATTRIB equ $FE53
rOAM21 equ $FE54
rOAM21_Y equ $FE54
rOAM21_X equ $FE55
rOAM21_TILE equ $FE56
rOAM21_ATTRIB equ $FE57
rOAM22 equ $FE58
rOAM22_Y equ $FE58
rOAM22_X equ $FE59
rOAM22_TILE equ $FE5A
rOAM22_ATTRIB equ $FE5B
rOAM23 equ $FE5C
rOAM23_Y equ $FE5C
rOAM23_X equ $FE5D
rOAM23_TILE equ $FE5E
rOAM23_ATTRIB equ $FE5F
rOAM24 equ $FE60
rOAM24_Y equ $FE60
rOAM24_X equ $FE61
rOAM24_TILE equ $FE62
rOAM24_ATTRIB equ $FE63
rOAM25 equ $FE64
rOAM25_Y equ $FE64
rOAM25_X equ $FE65
rOAM25_TILE equ $FE66
rOAM25_ATTRIB equ $FE67
rOAM26 equ $FE68
rOAM26_Y equ $FE68
rOAM26_X equ $FE69
rOAM26_TILE equ $FE6A
rOAM26_ATTRIB equ $FE6B
rOAM27 equ $FE6C
rOAM27_Y equ $FE6C
rOAM27_X equ $FE6D
rOAM27_TILE equ $FE6E
rOAM27_ATTRIB equ $FE6F
rOAM28 equ $FE70
rOAM28_Y equ $FE70
rOAM28_X equ $FE71
rOAM28_TILE equ $FE72
rOAM28_ATTRIB equ $FE73
rOAM29 equ $FE74
rOAM29_Y equ $FE74
rOAM29_X equ $FE75
rOAM29_TILE equ $FE76
rOAM29_ATTRIB equ $FE77
rOAM30 equ $FE78
rOAM30_Y equ $FE78
rOAM30_X equ $FE79
rOAM30_TILE equ $FE7A
rOAM30_ATTRIB equ $FE7B
rOAM31 equ $FE7C
rOAM31_Y equ $FE7C
rOAM31_X equ $FE7D
rOAM31_TILE equ $FE7E
rOAM31_ATTRIB equ $FE7F
rOAM32 equ $FE80
rOAM32_Y equ $FE80
rOAM32_X equ $FE81
rOAM32_TILE equ $FE82
rOAM32_ATTRIB equ $FE83
rOAM33 equ $FE84
rOAM33_Y equ $FE84
rOAM33_X equ $FE85
rOAM33_TILE equ $FE86
rOAM33_ATTRIB equ $FE87
rOAM34 equ $FE88
rOAM34_Y equ $FE88
rOAM34_X equ $FE89
rOAM34_TILE equ $FE8A
rOAM34_ATTRIB equ $FE8B
rOAM35 equ $FE8C
rOAM35_Y equ $FE8C
rOAM35_X equ $FE8D
rOAM35_TILE equ $FE8E
rOAM35_ATTRIB equ $FE8F
rOAM36 equ $FE90
rOAM36_Y equ $FE90
rOAM36_X equ $FE91
rOAM36_TILE equ $FE92
rOAM36_ATTRIB equ $FE93
rOAM37 equ $FE94
rOAM37_Y equ $FE94
rOAM37_X equ $FE95
rOAM37_TILE equ $FE96
rOAM37_ATTRIB equ $FE97
rOAM38 equ $FE98
rOAM38_Y equ $FE98
rOAM38_X equ $FE99
rOAM38_TILE equ $FE9A
rOAM38_ATTRIB equ $FE9B
rOAM39 equ $FE9C
rOAM39_Y equ $FE9C
rOAM39_X equ $FE9D
rOAM39_TILE equ $FE9E
rOAM39_ATTRIB equ $FE9F

; DMG joypad
; ----------

; FF00 - P1/JOYP - Joypad (R/W)
; The eight gameboy buttons/direction keys are arranged in form of a 2x4 matrix. 
; Select either button or direction keys by writing to this register, 
; then read-out bit 0-3.
;   Bit 7 - Not used
;   Bit 6 - Not used
;   Bit 5 - P15 Select Button Keys      (0=Select)
;   Bit 4 - P14 Select Direction Keys   (0=Select)
;   Bit 3 - P13 Input Down  or Start    (0=Pressed) (Read Only)
;   Bit 2 - P12 Input Up    or Select   (0=Pressed) (Read Only)
;   Bit 1 - P11 Input Left  or Button B (0=Pressed) (Read Only)
;   Bit 0 - P10 Input Right or Button A (0=Pressed) (Read Only)

rJOYP equ $FF00

; DMG Sound
; ---------

; Sound Control Registers
; =======================
;
; FF24 - NR50 - Channel control / ON-OFF / Volume (R/W)
; The volume bits specify the "Master Volume" for Left/Right sound output.
;   Bit 7   - Output Vin to SO2 terminal (1=Enable)
;   Bit 6-4 - SO2 output level (volume)  (0-7)
;   Bit 3   - Output Vin to SO1 terminal (1=Enable)
;   Bit 2-0 - SO1 output level (volume)  (0-7)
; The Vin signal is received from the game cartridge bus, allowing external hardware in the cartridge to supply a fifth sound channel, additionally to the gameboys internal four channels. As far as I know this feature isn't used by any existing games.
rNR50 equ $FF24

; FF25 - NR51 - Selection of Sound output terminal (R/W)
;   Bit 7 - Output sound 4 to SO2 terminal
;   Bit 6 - Output sound 3 to SO2 terminal
;   Bit 5 - Output sound 2 to SO2 terminal
;   Bit 4 - Output sound 1 to SO2 terminal
;   Bit 3 - Output sound 4 to SO1 terminal
;   Bit 2 - Output sound 3 to SO1 terminal
;   Bit 1 - Output sound 2 to SO1 terminal
;   Bit 0 - Output sound 1 to SO1 terminal
rNR51 equ $FF25

; FF26 - NR52 - Sound on/off
; If your GB programs don't use sound then write 00h to this register to save 16% or more on GB power consumption. Disabeling the sound controller by clearing Bit 7 destroys the contents of all sound registers. Also, it is not possible to access any sound registers (execpt FF26) while the sound controller is disabled.
;   Bit 7 - All sound on/off  (0: stop all sound circuits) (Read/Write)
;   Bit 3 - Sound 4 ON flag (Read Only)
;   Bit 2 - Sound 3 ON flag (Read Only)
;   Bit 1 - Sound 2 ON flag (Read Only)
;   Bit 0 - Sound 1 ON flag (Read Only)
rNR52 equ $FF26

; Sound Channel 1 - Tone & Sweep
; ===============================
;
; FF10 - NR10 - Channel 1 Sweep register (R/W)
;   Bit 6-4 - Sweep Time
;   Bit 3   - Sweep Increase/Decrease
;              0: Addition    (frequency increases)
;              1: Subtraction (frequency decreases)
;   Bit 2-0 - Number of sweep shift (n: 0-7)
; Sweep Time:
;   000: sweep off - no freq change
;   001: 7.8 ms  (1/128Hz)
;   010: 15.6 ms (2/128Hz)
;   011: 23.4 ms (3/128Hz)
;   100: 31.3 ms (4/128Hz)
;   101: 39.1 ms (5/128Hz)
;   110: 46.9 ms (6/128Hz)
;   111: 54.7 ms (7/128Hz)
; 
; The change of frequency (NR13,NR14) at each shift is calculated by the following formula where X(0) is initial freq & X(t-1) is last freq:
;   X(t) = X(t-1) +/- X(t-1)/2^n
rNR10 equ $FF10

; FF11 - NR11 - Channel 1 Sound length/Wave pattern duty (R/W)
;   Bit 7-6 - Wave Pattern Duty (Read/Write)
;   Bit 5-0 - Sound length data (Write Only) (t1: 0-63)
; Wave Duty:
;   00: 12.5% ( _-------_-------_------- )
;   01: 25%   ( __------__------__------ )
;   10: 50%   ( ____----____----____---- ) (normal)
;   11: 75%   ( ______--______--______-- )
; Sound Length = (64-t1)*(1/256) seconds
; The Length value is used only if Bit 6 in NR14 is set.
rNR11 equ $FF11

; FF12 - NR12 - Channel 1 Volume Envelope (R/W)
;   Bit 7-4 - Initial Volume of envelope (0-0Fh) (0=No Sound)
;   Bit 3   - Envelope Direction (0=Decrease, 1=Increase)
;   Bit 2-0 - Number of envelope sweep (n: 0-7)
;             (If zero, stop envelope operation.)
; Length of 1 step = n*(1/64) seconds
rNR12 equ $FF12

; FF13 - NR13 - Channel 1 Frequency lo (Write Only)
; Lower 8 bits of 11 bit frequency (x).
; Next 3 bit are in NR14 ($FF14)
rNR13 equ $FF13

; FF14 - NR14 - Channel 1 Frequency hi (R/W)
;   Bit 7   - Initial (1=Restart Sound)     (Write Only)
;   Bit 6   - Counter/consecutive selection (Read/Write)
;             (1=Stop output when length in NR11 expires)
;   Bit 2-0 - Frequency's higher 3 bits (x) (Write Only)
; Frequency = 131072/(2048-x) Hz
rNR14 equ $FF14

; Sound Channel 2 - Tone
; ======================
;
; FF16 - NR21 - Channel 2 Sound Length/Wave Pattern Duty (R/W)
;   Bit 7-6 - Wave Pattern Duty (Read/Write)
;   Bit 5-0 - Sound length data (Write Only) (t1: 0-63)
; Wave Duty:
;   00: 12.5% ( _-------_-------_------- )
;   01: 25%   ( __------__------__------ )
;   10: 50%   ( ____----____----____---- ) (normal)
;   11: 75%   ( ______--______--______-- )
; Sound Length = (64-t1)*(1/256) seconds
; The Length value is used only if Bit 6 in NR24 is set.
rNR21 equ $FF16

; FF17 - NR22 - Channel 2 Volume Envelope (R/W)
;   Bit 7-4 - Initial Volume of envelope (0-0Fh) (0=No Sound)
;   Bit 3   - Envelope Direction (0=Decrease, 1=Increase)
;   Bit 2-0 - Number of envelope sweep (n: 0-7)
;             (If zero, stop envelope operation.)
; Length of 1 step = n*(1/64) seconds
rNR22 equ $FF17

; FF18 - NR23 - Channel 2 Frequency lo data (W)
; Frequency's lower 8 bits of 11 bit data (x).
; Next 3 bits are in NR24 ($FF19).
rNR23 equ $FF18

; FF19 - NR24 - Channel 2 Frequency hi data (R/W)
;   Bit 7   - Initial (1=Restart Sound)     (Write Only)
;   Bit 6   - Counter/consecutive selection (Read/Write)
;             (1=Stop output when length in NR21 expires)
;   Bit 2-0 - Frequency's higher 3 bits (x) (Write Only)
; Frequency = 131072/(2048-x) Hz
rNR24 equ $FF19

; Sound Channel 3 - Wave Output
; =============================
;
; FF1A - NR30 - Channel 3 Sound on/off (R/W)
;   Bit 7 - Sound Channel 3 Off  (0=Stop, 1=Playback)  (Read/Write)
rNR30 equ $FF1A

; FF1B - NR31 - Channel 3 Sound Length
;   Bit 7-0 - Sound length (t1: 0 - 255)
; Sound Length = (256-t1)*(1/256) seconds
; This value is used only if Bit 6 in NR34 is set.
rNR31 equ $FF1B

; FF1C - NR32 - Channel 3 Select output level (R/W)
;   Bit 6-5 - Select output level (Read/Write)
; Possible Output levels are:
;   0: Mute (No sound)
;   1: 100% Volume (Produce Wave Pattern RAM Data as it is)
;   2:  50% Volume (Produce Wave Pattern RAM data shifted once to the right)
;   3:  25% Volume (Produce Wave Pattern RAM data shifted twice to the right)
rNR32 equ $FF1C

; FF1D - NR33 - Channel 3 Frequency's lower data (W)
; Lower 8 bits of an 11 bit frequency (x).
rNR33 equ $FF1D

; FF1E - NR34 - Channel 3 Frequency's higher data (R/W)
;   Bit 7   - Initial (1=Restart Sound)     (Write Only)
;   Bit 6   - Counter/consecutive selection (Read/Write)
;             (1=Stop output when length in NR31 expires)
;   Bit 2-0 - Frequency's higher 3 bits (x) (Write Only)
; Frequency = 4194304/(64*(2048-x)) Hz = 65536/(2048-x) Hz
rNR34 equ $FF1E

; FF30-FF3F - Wave Pattern RAM
; Contents - Waveform storage for arbitrary sound data
WAVE_START equ $FF30
WAVE_END equ $FF3F

; Sound Channel 4 - Noise
; =======================
;
; FF20 - NR41 - Channel 4 Sound Length (R/W)
;   Bit 5-0 - Sound length data (t1: 0-63)
; Sound Length = (64-t1)*(1/256) seconds
; The Length value is used only if Bit 6 in NR44 is set.
rNR41 equ $FF20

; FF21 - NR42 - Channel 4 Volume Envelope (R/W)
;   Bit 7-4 - Initial Volume of envelope (0-0Fh) (0=No Sound)
;   Bit 3   - Envelope Direction (0=Decrease, 1=Increase)
;   Bit 2-0 - Number of envelope sweep (n: 0-7)
;             (If zero, stop envelope operation.)
; Length of 1 step = n*(1/64) seconds
rNR42 equ $FF21

; FF22 - NR43 - Channel 4 Polynomial Counter (R/W)
; The amplitude is randomly switched between high and low at the given frequency. A higher frequency will make the noise to appear 'softer'.
; When Bit 3 is set, the output will become more regular, and some frequencies will sound more like Tone than Noise.
;   Bit 7-4 - Shift Clock Frequency (s)
;   Bit 3   - Counter Step/Width (0=15 bits, 1=7 bits)
;   Bit 2-0 - Dividing Ratio of Frequencies (r)
; Frequency = 524288 Hz / r / 2^(s+1) ;For r=0 assume r=0.5 instead
rNR43 equ $FF22

; FF23 - NR44 - Channel 4 Counter/consecutive; Inital (R/W)
;   Bit 7   - Initial (1=Restart Sound)     (Write Only)
;   Bit 6   - Counter/consecutive selection (Read/Write)
;             (1=Stop output when length in NR41 expires)
rNR44 equ $FF23

endc
