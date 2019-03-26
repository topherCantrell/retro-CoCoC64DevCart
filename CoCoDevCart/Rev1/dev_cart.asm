;
; CoCo IDE Development Cartridge
;
; The EPROM on the cartridge is a 32K part giving us 4 banks of 8K.
; The banks are selected through the first PIA. On powerup, bank 0
; is active.
;
; There is an 8-bit general-purpose port connector on the cartridge
; board. This port is wired to various I/O pins of the PIAs.
;
; There are two PIAs on the cartridge ... one at FF40 and one at FF44.
; These PIAs are hooked to the IDE connector allowing an ATA drive
; to be bit banged. Note that 4 of the wires run through inverters.
;
; FF40-A MSB of IDE Data
;      B LSB of IDE Data
;      CA1 nc
;      CA2 nc
;      CB1 nc
;      CB2 ROM B1
;
; FF44-A-0 nc
;        1 nc
;        2 nc
;        3 PRG6    
;        4 PRG1 (LOADER READ BIT 0)
;        5 PRG2 (LOADER READ BIT 1)
;        6 PRG3 (LOADER READ CLOCK) 
;        7 PRG7 (LOADER WRITE BIT 0) (NOT on 1st round)
;
; FF44-B-0 IDE A0
;        1 IDE A1
;        2 IDE A2
;        3 nc (This is PRG7 on the 1st round)
;        4 IDE CS1P (inverted)
;        5 IDE CS3P (inverted)
;        6 IDE WR   (inverted)
;        7 IDE RD   (inverted)
;       CA1 nc
;       CA2 PRG8
;       CB1 PRG5
;       CB2 ROM B0

IDE_CART_PIA0 equ $FF40
IDE_CART_PIA1 equ $FF44

PIA_0_A_DATA     equ  IDE_CART_PIA0
PIA_0_A_CONTROL  equ  IDE_CART_PIA0+1
PIA_0_B_DATA     equ  IDE_CART_PIA0+2
PIA_0_B_CONTROL  equ  IDE_CART_PIA0+3
PIA_1_A_DATA     equ  IDE_CART_PIA1
PIA_1_A_CONTROL  equ  IDE_CART_PIA1+1
PIA_1_B_DATA     equ  IDE_CART_PIA1+2
PIA_1_B_CONTROL  equ  IDE_CART_PIA1+3

; The Development-cartridge hardware uses a single PIA port to control the
; IDE signals. The bits of Port B of the 2nd PIA is mapped as follows. Write
; to address PIA_1_B_DATA to control the IDE signals (note that the upper 4 signals
; are inverted).

; Ports A and B of the 1st PIA are connected to the IDE's 16-bit data bus
; with B being the LSB and A being the MSB.

; When idle, the CONTROL should be 0 (everything unasserted)

; PB0 = A0
; PB1 = A1
; PB2 = A2
; PB3 = (data write in 1st round)
; PB4 = * CS1P [C] (Assert for command access)
; PB5 = * CS3P [m] (Master/Slave select ... keep unasserted)
; PB6 = * WR [W]
; PB7 = * RD [R]
;                                       RWmC -AAA
IDECONTROL_ADDR_MASK         equ $0   ; 0000 0000
IDECONTROL_ADDR_CS_MASK      equ $10  ; 0001 0000
IDECONTROL_ADDR_CS_WR_MASK   equ $50  ; 0101 0000
IDECONTROL_ADDR_CS_RD_MASK   equ $90  ; 1001 0000

;IDE_CART_INIT:
; This twiddles the bits to select ROM bank 0 ... of course this code is
; stored in bank 0, which means bank 0 is already selected, so nothing
; should change.
;        LDA  #0
;        STA  IDE_CART_PIA0   ; IDE Data bus ...
;        STA  IDE_CART_PIA0+2 ; ... as inputs                    
;        STA  IDE_CART_PIA1   ; PRG port as inputs
;        LDA  #255
;        STA  IDE_CART_PIA1+2 ; IDE Control lines as outputs        
;        LDA  #$34            ; 0011 0100 (CA2 and CB2 output 0 to ROM B0, B1)
;        STA  IDE_CART_PIA0+1 ; Switch in the PIA ...
;        STA  IDE_CART_PIA0+3 ; ... registers and ...
;        STA  IDE_CART_PIA1+1 ; ... set Cx2s as ...
;        STA  IDE_CART_PIA1+3 ; ... outputs (output = 1)
;        RTS

