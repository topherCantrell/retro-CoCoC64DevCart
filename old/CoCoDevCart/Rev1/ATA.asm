

    INCLUDE "dev_cart.asm"

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

; ATA Register numbers (IDE addresses)
;
ATA_REG_DATA                 equ $0
ATA_ERROR_FEATURE_REGISTER   equ $1
ATA_REG_SECTORCOUNT          equ $2
ATA_REG_SECTORNUM            equ $3
ATA_REG_CYLINDERLOW          equ $4
ATA_REG_CYLINDERHIGH         equ $5
ATA_REG_DRIVEHEAD            equ $6
ATA_REG_STATUS_COMMAND       equ $7

  org $4000

  PULS  X ; RETURN to BASIC

  LDX   #0
  LDY   #0
  LDB   #0
  LDU   #1024+32*4
  LBSR  READ_SECTOR
 
  ;LDA   #ATA_REG_DRIVEHEAD
  ;LDB   #0
  ;LBSR  WRITE_IDE_REGISTER

  ;LDA   #ATA_REG_STATUS_COMMAND
  ;LDB   #$EC
  ;LBSR  WRITE_IDE_REGISTER

  ;LDY   #1024+32*4
  ;LBSR  PULL_BUFFER

  LDA   #ATA_REG_STATUS_COMMAND
  LBSR  READ_IDE_REGISTER
  STB   1024

  RTS

;===========================================================================
SET_DATABUS_DIRECTION: ; Value in B
  PSHS   D                  ; Hold for a secondpoke 1025,
  LDA    PIA_0_A_CONTROL    ; Control for 0PA
  ANDA   #$FF-4             ; Turn off bit 1
  STA    PIA_0_A_CONTROL    ; DDR now active
  STB    PIA_0_A_DATA       ; Set direction
  ORA    #4                 ; DDR now ...
  STA    PIA_0_A_CONTROL    ; ... inactive
  LDA    PIA_0_B_CONTROL    ; Control for 0PB
  ANDA   #$FF-4             ; Turn off bit 1
  STA    PIA_0_B_CONTROL    ; DDR now active
  STB    PIA_0_B_DATA       ; Set direction
  ORA    #4                 ; DDR now ...
  STA    PIA_0_B_CONTROL    ; ... inactive
  PULS   D
  RTS

;===========================================================================
WRITE_IDE_REGISTER: ; A=address, X=value
; Set 16-bit data bus as output
; Data bus MSB = X
; Data bus LSB = X
; CONTROL = IDECONTROL_ADDR_CS_MASK    | address (ADDR + CS0)
; CONTROL = IDECONTROL_ADDR_CS_WR_MASK | address (ADDR + CS0 + WR)
; CONTROL = IDECONTROL_ADDR_CS_MASK    | address (ADDR + CS0)
; CONTROL = IDECONTROL_ADDR_MASK       | address (ADDR)
; Set 16-bit data bus as input
  PSHS   D                  ; Preserve for caller

  PSHS   A
  
  LDB    #255
  BSR    SET_DATABUS_DIRECTION

  TFR    X,D
  STA    PIA_0_A_DATA      ; Data -- MSB  
  STB    PIA_0_B_DATA      ; Data -- LSB
  
  PULS   A                

  ; CS, CS-WR, CS, OFF
  TFR    A,B
  ORB    #IDECONTROL_ADDR_CS_MASK
  STB    PIA_1_B_DATA

  TFR    A,B
  ORB    #IDECONTROL_ADDR_CS_WR_MASK
  STB    PIA_1_B_DATA

  TFR    A,B
  ORB    #IDECONTROL_ADDR_CS_MASK
  STB    PIA_1_B_DATA

  TFR    A,B
  ORB    #IDECONTROL_ADDR_MASK
  STB    PIA_1_B_DATA

  LDB    #0
  BSR    SET_DATABUS_DIRECTION

  PULS   D
  RTS

;===========================================================================
READ_IDE_REGISTER: ; A=address, X=value
; CONTROL = IDECONTROL_ADDR_CS_MASK    | address (ADDR + CS0)
; CONTROL = IDECONTROL_ADDR_CS_RD_MASK | address (ADDR + CS0 + RD)
; X = Data bus LSB
; X = Data bus MSB
; CONTROL = IDECONTROL_ADDR_MASK       | address (ADDR)
  PSHS   B
  TFR    A,B
  ORB    #IDECONTROL_ADDR_CS_MASK
  STB    PIA_1_B_DATA

  TFR    A,B
  ORB    #IDECONTROL_ADDR_CS_RD_MASK
  STB    PIA_1_B_DATA

  PSHS   A
  LDA    PIA_0_A_DATA
  LDB    PIA_0_B_DATA
  TFR    D,X
  PULS   A

  TFR    A,B
  ORB    #IDECONTROL_ADDR_MASK
  STB    PIA_1_B_DATA

  PULS   B
  RTS

;===========================================================================
WAIT_FOR_READY:
  PSHS   D
  LDA    #ATA_REG_STATUS_COMMAND
WFR_1:
  INC    1025
  BSR    READ_IDE_REGISTER  ; Read the status register
  STB    1026
  ANDB   #$D0             ; Mask off our area
  CMPB   #$50             ; Ready?
  BNE    WFR_1            ; No ... wait
  PULS   D                
  RTS

;===========================================================================
PULL_BUFFER: ; Y = destination
  PSHS  X
  PSHS  Y
  PSHS  D
  LDB   #0
  LDA   #ATA_REG_DATA
PBU_1:
  BSR   READ_IDE_REGISTER
  ; MAY NEED TO REVERSE-ENDIAN
  STX   ,Y++
  DECB
  BNE   PBU_1
  PULS  D
  PULS  Y
  PULS  X
  RTS

;===========================================================================
PUSH_BUFFER: ; Y = source
  PSHS  X
  PSHS  Y
  PSHS  D
  LDB   #0
  LDA   #ATA_REG_DATA
PSB_1:
  LDX   ,Y++
  ; MAY NEED TO REVERSE-ENDIAN
  LBSR   WRITE_IDE_REGISTER
  DECB
  BNE   PSB_1
  PULS  D
  PULS  Y
  PULS  X
  RTS

;===========================================================================
PREP_SECTOR_ACCESS: ; B=Drive, X=SectorMSW, Y=SectorLSW
; int a = (0x0E | (drive&1))<<4;
; writeRegister8(ATA_REG_SECTORCOUNT,1);
; writeRegister8(ATA_REG_SECTORNUM,       sector      &0xFF      );
; writeRegister8(ATA_REG_CYLINDERLOW,    (sector>>8)  &0xFF      );
; writeRegister8(ATA_REG_CYLINDERHIGH,   (sector>>16) &0xFF      );  
; writeRegister8(ATA_REG_DRIVEHEAD,     ((sector>>24) &0x0F) | a );
  ANDB   #1
  ORB    #$0E
  LSLB
  LSLB
  LSLB
  LSLB
  PSHS   B

  LDB    #1
  LDA    #ATA_REG_SECTORCOUNT  
  LBSR   WRITE_IDE_REGISTER

  TFR    Y,D
  LDA    #ATA_REG_SECTORNUM
  LBSR   WRITE_IDE_REGISTER

  TFR    Y,D
  TFR    A,B
  LDA    #ATA_REG_CYLINDERLOW
  LBSR   WRITE_IDE_REGISTER

  TFR    X,D
  LDA    #ATA_REG_CYLINDERHIGH
  LBSR    WRITE_IDE_REGISTER

  TFR    X,D
  TFR    A,B
  ANDB   #$0F
  ORB    ,S+
  STB    1024
  LDB    #0
  LDA    #ATA_REG_DRIVEHEAD
  LBSR   WRITE_IDE_REGISTER
  RTS

;===========================================================================
READ_SECTOR: ; B=Drive, X=SectorMSW, Y=SectorLSW, U=Buffer (return status in B)
; waitForReady();
; PREP
; writeRegister8(ATA_REG_STATUS_COMMAND,0x20);
; waitForReady();
; pullBuffer(buffer);
; a = readRegister8(ATA_REG_STATUS_COMMAND);
; return a;

  PSHS   A
  PSHS   Y
  LBSR   WAIT_FOR_READY
  BSR    PREP_SECTOR_ACCESS
  LDB    #$20
  LDA    #ATA_REG_STATUS_COMMAND
  LBSR   WRITE_IDE_REGISTER
  LBSR   WAIT_FOR_READY
  TFR    U,Y
  LBSR   PULL_BUFFER
  LDA    #ATA_REG_STATUS_COMMAND
  LBSR   READ_IDE_REGISTER
  PULS   Y
  PULS   A
  RTS

;===========================================================================
WRITE_SECTOR: ; B=Drive, X=SectorMSW, Y=BufferLSW, U=Buffer (return status in B)
; int a = (0x0E | (drive&1))<<4;
; waitForReady();
; PREP
; writeRegister8(ATA_REG_STATUS_COMMAND,0x30);
; waitForReady();  
; pushBuffer(buffer);
; a = readRegister8(ATA_REG_STATUS_COMMAND);
; return a;

  PSHS   A
  PSHS   Y
  LBSR   WAIT_FOR_READY
  BSR    PREP_SECTOR_ACCESS
  LDB    #$30
  LDA    #ATA_REG_STATUS_COMMAND
  LBSR   WRITE_IDE_REGISTER
  LBSR   WAIT_FOR_READY
  TFR    U,Y
  LBSR   PUSH_BUFFER
  LDA    #ATA_REG_STATUS_COMMAND
  LBSR   READ_IDE_REGISTER
  PULS   Y
  PULS   A
  RTS
