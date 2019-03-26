; 6833 SAM Mapped into Color Computer memory at $FFC0
; There are no data lines to the SAM. Bits are set by
; writing to odd addresses and cleared by writing to
; even addresses. The LSB of each of several fields 
; appears first in memory as follows:

; V0 V1 V2    F0 F1 F2 F3 F4 F5 F6    P0    R0 R1    M0 M1    TY

SAM_VIDEO_MODE EQU $FFC0
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

SAM_DISPLAY_OFFSET EQU $FFC6
;
; VDG Display Offset (F0-F6)
; Upper 7 bits of offset means these are in 512 byte pages ...
; 0000001 = 00000010 00000000 -> 512
; BASIC ROM initializes to 0x0400 at startup

SAM_PAGE_NUMBER EQU $FFD4
;
; Page Number (P1)
; Allows for two pages in lower 32K address ... not used

SAM_CPU_RATE EQU $FFD6
;
; CPU Rate (R0-R1)
; 00 0.89 MHz
; 01 0.89 MHz, 1.79 MHz
; 10 Not Used
; 11 Not Used

SAM_MEMORY_SIZE EQU $FFDA
; Memory size (M0-M1)
; 00  4K
; 01 16K
; 10 32/64K
; 11 Not used

SAM_ALL_RAM EQU $FFDE
; Map type (TY)
; 0 for normal mode (32K RAM, upper half ROM)
; 1 for all-RAM (64K RAM, no ROM)

; Input/Output Devices
PIA_0    EQU   $FF00
PIA_1    EQU   $FF20
PIA_CART EQU   $FF40

; 6809 Vectors
VECTOR_RESET     EQU   $FFFE
VECTOR_NMI       EQU   $FFFC
VECTOR_SW1       EQU   $FFFA
VECTOR_IRQ       EQU   $FFF8
VECTOR_FIRQ      EQU   $FFF6
VECTOR_SWI2      EQU   $FFF4
VECTOR_SWI3      EQU   $FFF2
VECTOR_NOT_USED  EQU   $FFF0

; ROM Areas
ROM_EXTENDED  EQU   $8000
ROM_BASIC     EQU   $A000
ROM_CART      EQU   $C000

; OS Service Vectors in ROM
ROM_POLCAT  EQU   $A000 ; Polls keyboard for a character
ROM_CHROUT  EQU   $A002 ; Outputs a character to screen or device
ROM_CSRDON  EQU   $A004 ; Starts cassette and prepares for reading
ROM_BLKIN   EQU   $A006 ; Reads a block from cassette
ROM_BLKOUT  EQU   $A008 ; Writes a block to cassette
ROM_JOYIN   EQU   $A00A ; Reads joystick values

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
