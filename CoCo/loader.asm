
;@build Tool assemble loader.asm loader.bin -list

define CPU = 6809

; The 6821 in the development cartridge is tied to the /SCS signal
; delivered to the cartridge. This selects address FF4x.
;
address _DEV_PIA_A = 0xFF40
address _DEV_PIA_B = 0xFF42

address _SAM_ALL_RAM=0xFFDE

; The monitor program is copied to E000-EFFF (All-RAM mode) and execute.
; The code up to the line of ========== is guaranteed relocatable allowing the
; coping code to run in ROM and JMP to RAM.
;
0xE000:       

        BSR     DOALLR          ; Copy ROM to ALL-RAM mode

        LDX     #0xC000         ; Cartridge memory
        LDU     #0xE000         ; RAM area
        LDY     #0x1000         ; 4K
Copy1:  LDA     ,X+             ; Copy ...
        STA     ,U+             ; ... monitor ...
        LEAY    -1,Y            ; ... to ...
        BNE     Copy1           ; ... RAM

        JMP     main            ; Start the monitor in RAM (JMP ... *NOT* BRA)

; ================================================================================
; Utility functions

; This routine copies the ALLRAM routine to memory and executes it there.
; This routine can't run in ROM since ROM gets switched out momentarily
; during the copy.
;
DOALLR: LDX     #ALLRAM          ; Start of ALLRAM function
        LDU     #0x7F00          ; Destination in upper RAM
        LDY     #ALLRAME-ALLRAM  ; Number of bytes to copy
DAR1:   LDA     ,X+              ; Copy the ...
        STA     ,U+              ; ... routine ...
        LEAY    -1,Y             ; ... to ...
        BNE     DAR1             ; ... RAM
        JMP     0x7F00           ; Execute routine (return to our caller)
;
; This routine copies the contents of ROM into the upper 32 bytes
; of all-ram mode.
;
ALLRAM: PSHS    CC             ; Save interrupt status
        ORCC    #0x50          ; Turn off interrupts
        LDX     #0x8000        ; Start of ROM
AR_1:   STA     _SAM_ALL_RAM   ; Switch ROM bank ON
        LDA     ,X             ; Get value from ROM
        STA     _SAM_ALL_RAM+1 ; Switch ROM bank OFF
        STA     ,X+            ; Store value to RAM under ROM bank
        CMPX    #0xFF00        ; Reached the end of ROM?
        BNE     AR_1           ; No ... go back for more
        PULS    CC             ; Restore interrupts
        RTS
ALLRAME:

;===========================================================================

main:

  LDA     #0            ; Data-direction regsiter
  STA     _DEV_PIA_A+1  ; Activate data ...
  STA     _DEV_PIA_B+1  ; ... direction registers
  STA     _DEV_PIA_A    ; Port A is all inputs
  LDA     #0xFF         ; Port B is all ...
  STA     _DEV_PIA_B    ; ... outputs
  LDA     #4            ; Data register
  STA     _DEV_PIA_A+1  ; Activate data ...
  STA     _DEV_PIA_B+1  ; ... registers

  BSR     readByte      ; Ignore the "X" command (future enhancement)

  BSR     readByte      ; Read dest MSB
  PSHS    B             ; Hold the MBB  
  BSR     readByte      ; Read dest LSB
  PULS    A             ; MSB back to D
  TFR     D,U           ; Destination to U
  
  LDX     #main         ; The loaded program ...
  PSHS    X             ; ... can "return" to top of loader
  TFR     D,X           ; Push destination on stack ... 
  PSHS    X             ; ... we'll "return" to execute program 

  BSR     readByte      ; MSB of length
  PSHS    B             ; Hold MSB
  BSR     readByte      ; LSB of length
  PULS    A             ; MSB back to D
  TFR     D,Y           ; Count to Y

readLoop:
  BSR     readByte	    ; Get the next byte
  STB     ,U+		    ; Store it to memory
  LEAY    -1,Y		    ; All done?
  BNE     readLoop	    ; No ... do all
  
  RTS			        ; Jump to the loaded code

readByte:
  
  LDA     _DEV_PIA_A    ; Read the hardware size
  ANDA    #0b_0001_0000 ; If a 0 then ...
  BEQ     readNibble    ; ... read a nibble at a time (fast)
  
  LDA     #49           ; Show size "1" ...
  STA     0x400         ; ... on screen

  LDB     #0            ; Clear the incoming shift
  LDX     #4            ; 4 passes through even/odd loop

rbe:
  INC     0x401         ; Visual notification of wait-loop
  LDA     _DEV_PIA_A    ; Check the ...
  ANDA    #0b_1000_0000 ; ... clock bit
  BEQ     rbe           ; Loop until 1
  ASLB                  ; Shift the running result
  LDA     _DEV_PIA_A    ; Get data  
  ANDA    #0b_0000_0001 ; Keep the lower data bit
  BEQ     rbe1          ; Data us 0 ... leave the 0
  ORB     #1            ; Or in the 1 data bit
rbe1:
  STB     0x402         ; Visual notification of the bit  

  LDA     #0b_1000_0000 ; Acknowledge the ...
  STA     _DEV_PIA_B    ; ... input bit with a 1

rbo:
  INC     0x401         ; Visual notification of wait-loop
  LDA     _DEV_PIA_A    ; Check the ...
  ANDA    #0b_1000_0000 ; ... clock bit
  BNE     rbo           ; Loop until 0
  ASLB
  LDA     _DEV_PIA_A    ; Get data  
  ANDA    #0b_0000_0001 ; Keep the lower data bit
  BEQ     rbo1          ; Data us 0 ... leave the 0
  ORB     #1            ; Or in the 1 data bit
rbo1:
  STB     0x402         ; Visual notification of the bit

  LDA     #0b_0000_0000 ; Acknowledge the ...
  STA     _DEV_PIA_B    ; ... input bit with a 0

  LEAX    -1,X          ; All bits shifted in?
  BNE     rbe           ; No ... keep going
  
  INC     0x403         ; Visual notification of a byte read

  RTS                   ; Done (result in B)

readNibble:

  LDA     #52           ; Show size "4" ...
  STA     0x400         ; ... on screen

rne:
  INC     0x401         ; Visual notification of wait-loop
  LDA     _DEV_PIA_A    ; Check the ...
  ANDA    #0b_1000_0000 ; ... clock bit
  BEQ     rne           ; Loop until 1
  LDB     _DEV_PIA_A    ; Get the data
  LDA     #0b_1000_0000 ; Acknowledge the ...
  STA     _DEV_PIA_B    ; ... input bit with a 1
  ANDB    #0b_0000_1111 ; Keep the nibble
  ASLB                  ; Shift ...
  ASLB                  ; ... nibble ...
  ASLB                  ; ... to ...
  ASLB                  ; ... upper
  TFR     D,X           ; Upper nibble to X
  
  STB     0x402         ; Visual notification of the nibble

rno:
  INC     0x401         ; Visual notification of wait-loop
  LDA     _DEV_PIA_A    ; Check the ...
  ANDA    #0b_1000_0000 ; ... clock bit
  BNE     rno           ; Loop until 0
  LDB     _DEV_PIA_A    ; Get the data
  LDA     #0b_0000_0000 ; Acknowledge the ...
  STA     _DEV_PIA_B    ; ... input bit with a 0
  ANDB    #0b_0000_1111 ; Keep the nibble
  ABX                   ; Add upper and lower nibble together
  TFR     X,D           ; Result byte to B

  STB     0x402         ; Visual notification of nibble and byte value

  INC     0x403         ; Visual notification of a byte read

  RTS                   ; Done
