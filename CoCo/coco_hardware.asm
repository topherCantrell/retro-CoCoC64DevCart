; 6833 SAM Mapped into Color Computer memory at $FFC0
; There are no data lines to the SAM. Bits are set by
; writing to odd addresses and cleared by writing to
; even addresses. The LSB of each of several fields 
; appears first in memory as follows:

; V0 V1 V2    F0 F1 F2 F3 F4 F5 F6    P0    R0 R1    M0 M1    TY

address _SAM_VIDEO_MODE=0xFFC0
;
; Video Mode (v0-V2)
; 000 AI, AE, S4, S6
; 001 G1C, G1R
; 010 G2C
; 011 G2R
; 100 G3C
; 101 G3R
; 110 G6R, G6C
; 111 Not Used

address _SAM_DISPLAY_OFFSET=0xFFC6
;
; VDG Display Offset (F0-F6)
; Upper 7 bits of offset means these are in 512 byte pages ...
; 0000001 = 00000010 00000000 -> 512
; BASIC ROM initializes to 0x0400 at startup

address _SAM_PAGE_NUMBER=0xFFD4
;
; Page Number (P1)
; Allows for two pages in lower 32K address ... not used

address _SAM_CPU_RATE=0xFFD6
;
; CPU Rate (R0-R1)
; 00 0.89 MHz
; 01 0.89 MHz, 1.79 MHz
; 10 Not Used
; 11 Not Used

address _SAM_MEMORY_SIZE=0xFFDA
; Memory size (M0-M1)
; 00  4K
; 01 16K
; 10 32/64K
; 11 Not used

address _SAM_ALL_RAM=0xFFDE
; Map type (TY)
; 0 for normal mode (32K RAM, upper half ROM)
; 1 for all-RAM (64K RAM, no ROM)

; Input/Output Devices
address _PIA_0   =  0xFF00
address _PIA_1   =  0xFF20
address _PIA_CART=  0xFF40

; 6809 Vectors
address _VECTOR_RESET    =  0xFFFE
address _VECTOR_NMI      =  0xFFFC
address _VECTOR_SW1      =  0xFFFA
address _VECTOR_IRQ      =  0xFFF8
address _VECTOR_FIRQ     =  0xFFF6
address _VECTOR_SWI2     =  0xFFF4
address _VECTOR_SWI3     =  0xFFF2
address _VECTOR_NOT_USED =  0xFFF0

; ROM Areas
address _ROM_EXTENDED =  0x8000
address _ROM_BASIC    =  0xA000
address _ROM_CART     =  0xC000

; OS Service Vectors in ROM
address _ROM_POLCAT =  0xA000 ; Polls keyboard for a character
address _ROM_CHROUT =  0xA002 ; Outputs a character to screen or device
address _ROM_CSRDON =  0xA004 ; Starts cassette and prepares for reading
address _ROM_BLKIN  =  0xA006 ; Reads a block from cassette
address _ROM_BLKOUT =  0xA008 ; Writes a block to cassette
address _ROM_JOYIN  =  0xA00A ; Reads joystick values

; Text mode uses the following character set:
; 0-64     reversed characters
; 64-128   normal characters
; 128-255  graphics patterns
; @ABCDEFGHIJKLMNOPQRSTUVWXYZ[\] UP-ARROW LEFT-ARROW SPACE !"#$%&'()*+,-./0123456789:;<=>?

;ASCIITRANS:
;        fcb     32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
;        fcb       32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
;        fcb     96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111
;        fcb       112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127
;        fcb     64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79
;        fcb       80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95
;        fcb     0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
;        fcb       16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31 
