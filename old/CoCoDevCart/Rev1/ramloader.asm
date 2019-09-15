
        INCLUDE "coco_hardware.asm"
        INCLUDE "dev_cart.asm"

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

	org	ROM_CART       ; 0xC000 is the start of the cartridge ROM

        LBRA    OS_LOADER_APPLICATION

RAMRUN_APPLICATION:
        LBSR     IDE_CART_INIT  ; Set the data direction on the cartridge ports   
TOP:
        BSR     ReadWord       ; Read the destination
        TFR     D,X            ; Use for loading
        TFR     D,U            ; Use for executing
        BSR     ReadWord       ; Read the length of the data
        TFR     D,Y            ; Into an index
L1:     BSR     ReadByte       ; Read the data byte
        STA     ,X+            ; Store the data to RAM
        STA     $400           ; Visual progress
        LEAY    -1,Y           ; Decrement the count
        BNE     L1             ; Go back to load all
        JSR     ,U             ; Execute the loaded code
        BRA     TOP            ; If we should get back, start over

ReadWord:
        BSR     ReadByte       ; Read MSB
        PSHS    A              ; Hold it
        BSR     ReadByte       ; Read LSB
        TFR     A,B            ; Into B
        PULS    A              ; MSB to A
        RTS                    ; Word returned in D

ReadByte:
        PSHS    X              ; We will mangle ...
        PSHS    B              ; ... these
        LDX     #2             ; Two groups of 4 bits to load
        LDA     #0             ; Initial return value
RB_1:   LDB     IDE_CART_PIA1  ; Read the loader port
        ANDB    #$70           ; We only want these three bits
        CMPB    #$40           ; Test the clock bit
        BLO     RB_1           ; Loop back until the clock is 1
        RORB                   ; Shift ...
        RORB                   ; ... D1 ...
        RORB                   ; ... into ...
        RORB                   ; ... carry ...
        RORB                   ; ... flag
        ROLA                   ; Shift D1 into A
        RORB                   ; Shift D0 into carry
        ROLA                   ; Shift D0 into A
RB_2:   LDB     IDE_CART_PIA1  ; Read the loader port
        ANDB    #$70           ; We only want these three bits
        CMPB    #$40           ; Test the clock bit
        BGE     RB_2           ; Loop back until the clock is 0
        RORB                   ; Shift ...
        RORB                   ; ... D1 ...
        RORB                   ; ... into ...
        RORB                   ; ... carry ...
        RORB                   ; ... flag
        ROLA                   ; Shift D1 into A
        RORB                   ; Shift D0 into carry
        ROLA                   ; Shift D0 into A
        LEAX    -1,X           ; All groups of 2 done?
        BNE     RB_1           ; No ... go back
        PULS    B              ; Restore ...
        PULS    X              ; ... B and X      
        RTS                    


; Taking care not to modify the bits around the output bit so
; we can bitbang the IDE remotely

WriteByte:
        PSHS    X              ; We will mangle ...
        PSHS    B              ; ... these
        LDX     #4             ; Four groups of 2 bits
WB_3:   ROLA                   ; Get data bit ...
        ROLB                   ; ... into ...
        ROLB                   ; ... B3 ...
        ROLB                   ; ... for ...
        ROLB                   ; ... output
        ANDB    #$08           ; There are other outputs here 
        PSHS    B               ; Hold our bit-change
        LDB     IDE_CART_PIA1+2 ; Get the current output value of the port
        ANDB    #$FF-8          ; Mask off our bit spot
        ORB     ,S+             ; Add in our bit
        STB     IDE_CART_PIA1+2  ; Write the bit out        
WB_1:   LDB     IDE_CART_PIA1  ; Wait ...
        ANDB    #$70           ; ... for ...
        CMPB    #$40           ; ... clock to ...
        BLO     WB_1           ; ... go high
        ROLA                   ; Get data bit ...
        ROLB                   ; ... into ...
        ROLB                   ; ... B3 ...
        ROLB                   ; ... for ...
        ROLB                   ; ... output
        ANDB    #$08           ; There are other outputs here
        PSHS    B               ; Hold our bit-change
        LDB     IDE_CART_PIA1+2 ; Get the current output value of the port
        ANDB    #$FF-8          ; Mask off our bit spot
        ORB     ,S+             ; Add in our bit
        STB     IDE_CART_PIA1+2  ; Write the bit out         
WB_2:   LDB     IDE_CART_PIA1  ; Wait ...
        ANDB    #$70           ; ... for ...
        CMPB    #$40           ; ... clock to ...
        BGE     WB_2           ; ... go high
        LEAX    -1,X           ; All bits done?
        BNE     WB_3           ; No ... do them all
        PULS    B              ; Restore ...
        PULS    X              ; ... B and X
        RTS

;===========================================================================
EXECUTE_ROM_BANK:
        PSHS    A              ; Hold the bank number
        LDX     #SELECT_ROM_BANK ; Code in ROM
        LDU     #$4000         ; Destination in RAM
        LDY     #SRB_DONE-SELECT_ROM_BANK ; Calculate size of the routine
DRB_1:  LDA     ,X+            ; Move ...
        STA     ,U+            ; ... code ...
        LEAY    -1,Y           ; ... to ...
        BNE     DRB_1          ; ... RAM
        PULS    A              ; Restore the bank
        LDX     #$C000         ; Set return address ...
        PSHS    X              ; ... to ROM start
        JMP     $4000          ; Switch banks and go to the start        

;===========================================================================
SELECT_ROM_BANK:
; You MUST run this from RAM since the ROM bank will change
        TFR     A,B            ; Hold this
        ROLA                   ; Bit-0 shifted ...
        ROLA                   ; ... to ....
        ROLA                   ; ... bit 3
        ANDA    #8             ; All we want is the one bit
        ORA     #$34           ; Mask in the other control bits
        ROLB                   ; Bit-1 shifted ...
        ROLB                   ; ... to bit 3
        ANDB    #8             ; All we want is the one bit
        ORB     #$34           ; Mask in the other control bits
        STA     IDE_CART_PIA1+3 ; Set CB2 to output bit 0 of the bank number
        STB     IDE_CART_PIA0+3 ; Set CB2 to output bit 1 of the bank number
        RTS
SRB_DONE:

;===========================================================================
IDE_CART_INIT:
; This twiddles the bits to select ROM bank 0 ... of course this code is
; stored in bank 0, which means bank 0 is already selected, so nothing
; should change.
        LDA  #0
        STA  IDE_CART_PIA0     ; IDE Data bus ...
        STA  IDE_CART_PIA0+2   ; ... as inputs                           
        STA  IDE_CART_PIA1     ; PRG inputs
        LDA  #$FF
        STA  IDE_CART_PIA1+2   ; IDE Control lines as outputs        
        LDA  #$34              ; 0011 0100 (CA2 and CB2 output 0 to ROM B0, B1)
        STA  IDE_CART_PIA0+1   ; Switch in the PIA ...
        STA  IDE_CART_PIA0+3   ; ... registers and ...
        STA  IDE_CART_PIA1+1   ; ... set Cx2s as ...
        STA  IDE_CART_PIA1+3   ; ... outputs (output = 1)
        RTS

;===========================================================================
DOALLRAM:
        LDX     #ALLRAM        ; Code in ROM
        LDU     #$4000         ; Destination in RAM
        LDY     #ARDONE-ALLRAM ; Calculate size of ALLRAM routine
DAR_1:  LDA     ,X+            ; Move ...
        STA     ,U+            ; ... code ...
        LEAY    -1,Y           ; ... to ...
        BNE     DAR_1          ; ... RAM
        JSR     $4000          ; Call the ALLRAM routine in RAM
        RTS

;===========================================================================
ALLRAM:
        PSHS    CCR            ; Save interrupt status
        ORCC    #$50           ; Turn off interrupts
        LDX     #$8000         ; Start of ROM
AR_1:   STA     SAM_ALL_RAM    ; Switch ROM bank ON
        LDA     ,X             ; Get value from ROM
        STA     SAM_ALL_RAM+1  ; Switch ROM bank OFF
        STA     ,X+            ; Store value to RAM under ROM bank
        CMPX    #$FF00         ; Reached the end of the upper 32K?
        BNE     AR_1           ; No ... go back for more
        PULS    CCR            ; Restore interrupts
        RTS
ARDONE:

;===========================================================================

; Remember ... when POKING FF46, be sure to keep B3 (output) as 0

ADBUS_APPLICATION:
         BSR     IDE_CART_INIT  ; Set the data direction on the cartridge ports 

ADBUS:
        LBSR    ReadByte       ; Get the command
        CMPA    #1             ; POKE?
        LBEQ     ADBUS_POKE     ; Do POKE
        CMPA    #2             ; PEEK?
        LBEQ     ADBUS_PEEK     ; Do PEEK

        CMPA    #9
        LBEQ     ADBUS_READSECTOR
        CMPA    #10
        LBEQ     ADBUS_WRITESECTOR
        CMPA    #11
        LBEQ    ADBUS_DRIVEINFO

        RTS                    ; Unknown command ... done

ADBUS_DRIVEINFO:
        LBSR   ReadByte
        PSHS   B
        LBSR   ReadWord
        TFR    D,U
        PULS   B
        LBSR   DRIVE_INFO
        BRA    ADBUS       

ADBUS_READSECTOR:
        LBSR   ReadByte
        PSHS   B
        LBSR   ReadWord
        PSHS   D
        LBSR   ReadWord
        PSHS   D
        LBSR   ReadWord
        TFR    D,U
        PULS   Y
        PULS   X
        PULS   B
        LBSR   READ_SECTOR
        BRA    ADBUS

ADBUS_WRITESECTOR:
        LBSR   ReadByte
        PSHS   B
        LBSR   ReadWord
        PSHS   D
        LBSR   ReadWord
        PSHS   D
        LBSR   ReadWord
        TFR    D,U
        PULS   Y
        PULS   X
        PULS   B
        LBSR   WRITE_SECTOR
        BRA    ADBUS

ADBUS_POKE:
        LBSR    ReadWord       ; Address
        TFR     D,X            ; Hold it
        LBSR    ReadByte       ; Get the value
        STA     ,X             ; Store it
        BRA     ADBUS          ; Back to top

ADBUS_PEEK:
        LBSR    ReadWord       ; Address
        TFR     D,X            ; Hold it
        LDA     ,X             ; Get the value from address
        LBSR    WriteByte      ; Send it back to host
        LBRA     ADBUS          ; Back to top

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
PULL_BUFFER: ; Y = destination
  PSHS  X
  PSHS  Y
  PSHS  D
  LDB   #0
  LDA   #ATA_REG_DATA
PBU_1:
  BSR   READ_IDE_REGISTER
  EXG   X,D
  EXG   A,B
  EXG   X,D
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
  EXG   X,D
  EXG   A,B
  EXG   X,D
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

  PSHS   X ; We'll be using X, but we need it later
  PSHS   X ; In fact, we'll need it twice

  LDX    #1  
  LDA    #ATA_REG_SECTORCOUNT  ; 2
  LBSR   WRITE_IDE_REGISTER

  TFR    Y,X   
  LDA    #ATA_REG_SECTORNUM    ; 3
  LBSR   WRITE_IDE_REGISTER

  TFR    Y,D
  TFR    A,B
  TFR    D,X
  LDA    #ATA_REG_CYLINDERLOW  ; 4
  LBSR   WRITE_IDE_REGISTER
  
  PULS   X
  LDA    #ATA_REG_CYLINDERHIGH ; 5
  LBSR   WRITE_IDE_REGISTER

  PULS   X
  TFR    X,D
  TFR    A,B  
  ANDB   #$0F
  ORB    ,S+ 
  TFR    D,X 
  LDA    #ATA_REG_DRIVEHEAD    ; 6
  LBSR   WRITE_IDE_REGISTER
  RTS

;===========================================================================
WAIT_FOR_READY:
  PSHS   D
  PSHS   X
WFR_1:
  LDA    #ATA_REG_STATUS_COMMAND
  LBSR   READ_IDE_REGISTER  ; Read the status register
  TFR    X,D
  ANDB   #$D0             ; Mask off our area
  CMPB   #$50             ; Ready?
  BNE    WFR_1            ; No ... wait
  PULS   X
  PULS   D                
  RTS

;===========================================================================
DRIVE_INFO: ; B=Drive, U=Buffer
  PSHS   A
  PSHS   X
  PSHS   U
  BSR   WAIT_FOR_READY
  ANDB   #1
  ORB    #$0E
  LSLB
  LSLB
  LSLB
  LSLB
  TFR    D,X  
  LDA    #ATA_REG_DRIVEHEAD
  LBSR   WRITE_IDE_REGISTER
  LDX    #$EC
  LDA    #ATA_REG_STATUS_COMMAND
  LBSR   WRITE_IDE_REGISTER
  BSR   WAIT_FOR_READY
  TFR    U,Y
  LBSR   PULL_BUFFER
  PULS   U
  PULS   X
  PULS   A
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
  PSHS   X
  PSHS   Y
  PSHS   U
  BSR   WAIT_FOR_READY
  LBSR    PREP_SECTOR_ACCESS
  LDX    #$20
  LDA    #ATA_REG_STATUS_COMMAND
  LBSR   WRITE_IDE_REGISTER
  BSR   WAIT_FOR_READY
  TFR    U,Y
  LBSR   PULL_BUFFER
  LDA    #ATA_REG_STATUS_COMMAND
  LBSR   READ_IDE_REGISTER
  PULS   U
  PULS   Y
  PULS   X
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
  PSHS   X
  PSHS   Y
  PSHS   U
  BSR   WAIT_FOR_READY
  LBSR   PREP_SECTOR_ACCESS
  LDX    #$30
  LDA    #ATA_REG_STATUS_COMMAND
  LBSR   WRITE_IDE_REGISTER
  LBSR   WAIT_FOR_READY
  TFR    U,Y
  LBSR   PUSH_BUFFER
  LDA    #ATA_REG_STATUS_COMMAND
  LBSR   READ_IDE_REGISTER
  PULS   U
  PULS   Y
  PULS   X
  PULS   A 
  RTS  

;===========================================================================

OS_LOADER_APPLICATION:

  LBSR     IDE_CART_INIT  ; Set the data direction on the cartridge ports 

  LDX    #0      ; Start looking with ...  
  LDY    #528+32 ; ... sector 528 (first data sector for my 256M formatted for FAT)
  LDB    #0      ; Drive 0 (MASTER)
  STB    1024
  LDU    #$600   ; Destination buffer

OS_LOAD_A:  

  BSR    READ_SECTOR
  INC    1024

  LDA    0,U
  CMPA   #'C'
  BNE    MOVE_ON
  LDA    1,U
  CMPA   #'O'
  BNE    MOVE_ON
  LDA    2,U
  CMPA   #'C'
  BNE    MOVE_ON
  LDA    3,U
  CMPA   #'O'
  BNE    MOVE_ON
  LDA    4,U
  CMPA   #'O'
  BNE    MOVE_ON
  LDA    5,U
  CMPA   #'S'
  BEQ    FOUND

MOVE_ON:
  LEAY   1,Y
  BNE    OS_LOAD_A

; NO OS FILE ON DISK
  LDA    #254
  STA    1024
  RTS

FOUND:
  INC    1025
  LDX    #$1000
  
F1: 
  LDA    ,U+
  STA    ,X+
  CMPU   #$600+512
  BNE    F1
  CMPX   #$3000
  BEQ    OS_DONE

  PSHS  X
  LDX   #0
  LDU   #$600
  LEAY  1,Y
  LBSR   READ_SECTOR
  INC   1026
  PULS  X
  BRA   F1

OS_DONE:
  JSR   $1006
  RTS

