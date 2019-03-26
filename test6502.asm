
;@build Tool assemble loader.asm loader.bin -list

define CPU = 6502

address ptr = 2  ; Used as a pointer to memory being filled
address dst = 4  ; Remember the 2-byte destination
address len = 6  ; Counting down the 2-byte length
address val = 8  ; Bits as they come in

; The 6521 in the development cartridge is tied to the /IO1 signal
; delivered to the cartridge. This selects address DExx.
;
address _DEV_PIA_A = 0xDE00
address _DEV_PIA_B = 0xDE02

; The /EXROM is grounded in the development cartridge. This maps the
; ROM to 8000-9FFF. If the first 9 bytes contain a special signature
; then the C64 kernel will jump to it.
;
0x8000:

# (word)entry       ; RESET vector (start of loader)
# (word)entry       ; NMI vector (start of loader)

# 0xC3, 0xC2, 0xCD, 0x38, 0x30 ; "CBM80" in PETSCII

entry:

  SEI                ; Turn off interrupts

  STX 0xD016         ; Duplicate KERNEL ...
  JSR 0xFDA3         ; ... startup ...
  JSR 0xFD50         ; ...
  JSR 0xFD15         ; ...
  JSR 0xFF5B         ; ...

main:

  LDA  #0            ; Data-direction regsiter
  STA  _DEV_PIA_A+1  ; Activate data ...
  STA  _DEV_PIA_B+1  ; ... direction registers
  STA  _DEV_PIA_A    ; Port A is all inputs
  LDA  #0xFF         ; Port B is all ...
  STA  _DEV_PIA_B    ; ... outputs
  LDA  #4            ; Data register
  STA  _DEV_PIA_A+1  ; Activate data ...
  STA  _DEV_PIA_B+1  ; ... registers

  JSR  readByte      ; Ignore the "X" command (future enhancement)

  JSR  readByte      ; Read dest MSB
  STA  >ptr+1        ; MSB of pointer ...
  STA  >dst+1        ; ... and dest
  JSR  readByte      ; Read dest LSB
  STA  >ptr          ; LSB of poitner ...
  STA  >dst          ; ... and dest

  JSR  readByte      ; MSB of ...
  STA  >len+1        ; ... length
  JSR  readByte      ; LSB of ...
  STA  >len          ; ... length

loadLoop:

  JSR  readByte      ; Get the next byte
  LDY  #0            ; Store it to ...
  STA  (ptr),Y       ; ... destination

  INC  >ptr          ; Bump pointer LSB
  BNE  sk1           ; No carry ... skip the MSB
  INC  >ptr+1        ; Bump pointer MSB  
sk1:

  DEC  >len          ; Count down LSB
  LDA  >len          ; Did LSB wrap ...
  CMP  #0xFF         ; ... around to FF?
  BNE  sk2           ; No ... skip MSB
  DEC  >len+1        ; Count down MSB
sk2:

  LDA  >len          ; Go back until ...
  ORA  >len+1        ; ... len is ...
  BNE  loadLoop      ; ... 0 ...

  LDA  #83           ; Visual notification of ...
  STA  0x404         ; ... execute function

  LDA  #0x80         ; Return to ...
  PHA                ; ... label "entry" at 8019 ...
  LDA  #0x18         ; ... remember that 6502 return ...
  PHA                ; ... is backed up one on stack (8018)

  JMP  (dst)         ; All loaded ... execute the destination

readByte:

  LDA  #0            ; Clear the ...
  STA  >val          ; ... incoming shift
  LDA  _DEV_PIA_A    ; Read the hardware size
  AND  #0b_0001_0000 ; If a 0 then ...
  BEQ  readNibble    ; ... read a nibble at a time (fast)
  
  LDX  #49           ; Show size "1" ...
  STX  0x400         ; ... on screen

  LDX  #4            ; 4 passes through even/odd loop

rbe:
  INC  0x401         ; Visual notification of wait-loop
  LDA  _DEV_PIA_A    ; Check the ...
  AND  #0b_1000_0000 ; ... clock bit
  BEQ  rbe           ; Loop until 1
  LDA  _DEV_PIA_A    ; Get data  
  AND  #0b_0000_0001 ; Keep the lower data bit
  ASL  >val          ; Shift the tally left
  ORA  >val          ; OR in the next bit
  STA  >val          ; Keep the tally

  STA  0x402         ; Visual notification of the bit  

  LDA  #0b_1000_0000 ; Acknowledge the ...
  STA  _DEV_PIA_B    ; ... input bit with a 1

rbo:
  INC  0x401         ; Visual notification of wait-loop
  LDA  _DEV_PIA_A    ; Check the ...
  AND  #0b_1000_0000 ; ... clock bit
  BNE  rbo           ; Loop until 0
  LDA  _DEV_PIA_A    ; Get data
  AND  #0b_0000_0001 ; Keep the lower data bit
  ASL  >val          ; Shift the tally left
  ORA  >val          ; OR in the next bit
  STA  >val          ; Keep the tally

  STA  0x402         ; Visual notification of the bit

  LDA  #0b_0000_0000 ; Acknowledge the ...
  STA  _DEV_PIA_B    ; ... input bit with a 0

  DEX                ; All bits shifted in?
  BNE  rbe           ; No ... keep going

  LDA  >val          ; Get the final value

  INC  0x403         ; Visual notification of a byte read

  RTS                ; Done

readNibble:

  LDA  #52           ; Show size "4" ...
  STA  0x400         ; ... on screen

rne:
  INC  0x401         ; Visual notification of wait-loop
  LDA  _DEV_PIA_A    ; Check the ...
  AND  #0b_1000_0000 ; ... clock bit
  BEQ  rne           ; Loop until 1
  LDA  _DEV_PIA_A    ; Get the data
  LDX  #0b_1000_0000 ; Acknowledge the ...
  STX  _DEV_PIA_B    ; ... input bit with a 1
  AND  #0b_0000_1111 ; Keep the nibble
  ASL  A             ; Shift ...
  ASL  A             ; ... nibble ...
  ASL  A             ; ... to ...
  ASL  A             ; ... upper
  STA  >val          ; Hold the upper nibble

  STA  0x402         ; Visual notification of the nibble

rno:
  INC  0x401         ; Visual notification of wait-loop
  LDA  _DEV_PIA_A    ; Check the ...
  AND  #0b_1000_0000 ; ... clock bit
  BNE  rno           ; Loop until 0
  LDA  _DEV_PIA_A    ; Get the data
  LDX  #0b_0000_0000 ; Acknowledge the ...
  STX  _DEV_PIA_B    ; ... input bit with a 0
  AND  #0b_0000_1111 ; Keep the nibble
  ORA  >val          ; OR upper and lower nibbles

  STA  0x402         ; Visual notification of nibble and byte value

  INC  0x403         ; Visual notification of a byte read

  RTS                ; Done
