; build tools.assembler.Assembler monitor.asm monitor.bin -list
; build tools.coco.DevCartLoader monitor.bin 0x7000
; build pause 4000
;@build tools.coco.DevCartLoader L ..\roms\daggorath.bin 0xC000 E 0xC000

; TODO:Assembler better error message if I leave the ":" off the origin "0x7000"

; TODO:Communication need a throttle mechanism for large files sent over COM6 with no flow. Right now we
;   rely on long delays

define CPU = 6809

include coco_hardware.asm

address _DEV_PIA_0 = 0xFF40
address _DEV_PIA_1 = 0xFF44

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

        JMP     MONITOR         ; Start the monitor in RAM (JMP ... *NOT* BRA)

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

MONITOR:        

        LDA	#0		; Select the ...
	STA	0xFF47		; ... data-direction register port B
        LDA     #0b_0000_11_10  ; Inputs and outputs
	STA	0xFF46		; Directions of pins on port B
	LDA	#4		; Select the ...
	STA	0xFF47		; ... data register port B

main:   LDA     #77             ; M for "MONITOR"
        STA     0x402           ; Tell the user where we are
        BSR     readByte        ; Get the command
        CMPA    #76             ; 'L' for LOAD
        BEQ     DO_LOAD         ; Do load routine
        CMPA    #69             ; 'E' for EXECUTE
        BEQ     DO_EXECUTE      ; Do execute routine
        CMPA    #65             ; 'A' for ABORT
        BEQ     DO_ABORT        ; Do abort
        CMPA    #85             ; 'U' for UPLOAD
        BEQ     DO_UPLOAD       ; Do upload
        LDA     #63             ; '?'
        STA     0x403           ; Show that an error occurred
        BRA     main            ; Back to the top to wait

DO_ABORT:
        STA     0x402           ; Show the command
        RTS                     ; Only works when executed from BASIC

DO_UPLOAD:
        STA     0x402
        BSR 	readByte	; Read the source LSB
	TFR 	A,B		; Hold it
	BSR	readByte	; Read the source MSB
	TFR	D,X		; Source to X

	BSR	readByte	; Read the count LSB
	TFR	A,B		; Hold it
	BSR	readByte	; Read the count MSB
	TFR	D,Y		; Count to Y    

        BSR     upload          ; Call the upload routine
        BRA     main            ; Back to main

DO_LOAD:
        STA     0x402           ; Show the command
	BSR 	readByte	; Read the destination LSB
	TFR 	A,B		; Hold it
	BSR	readByte	; Read the destination MSB
	TFR	D,X		; Destination to X

	BSR	readByte	; Read the count LSB
	TFR	A,B		; Hold it
	BSR	readByte	; Read the count MSB
	TFR	D,Y		; Count to Y         

        BSR     load            ; Do the load

        BRA     main            ; Back to monitor

DO_EXECUTE:
        STA     0x402           ; Show the command
	BSR 	readByte	; Read the destination LSB
	TFR 	A,B		; Hold it
	BSR	readByte	; Read the destination MSB
        TFR     D,U             ; Destination to U
        JSR     ,U              ; Jump to the code (return here)
        BRA     main            ; Back to monitor

; ================================================================================
; I/O functions

upload: LDA     ,X+             ; Get the next byte
        BSR     writeByte       ; Send it to the host
        LEAY    -1,Y            ; All sent?
        BNE     upload          ; No ... do all
        RTS                     ; Done

load:   BSR     readByte	; Get the next byte
        STA     ,X+		; Store it to memory
        LEAY    -1,Y		; All done?
        BNE     load    	; No ... do all    
        RTS                     ; Done

; Read a byte from the Port B. The upper 4 bits of B are the 
; data with the most-significant-nibble coming first followed
; by the least significant. The lower bit is the data clock.
; The MSN is read on 0->1 transition. The LSN is read on 1->0.
; Bit 1 is an ACK bit from the coco back to the propeller. It
; Toggles with each nibble read.
;
readByte:

; Read Upper 4 bits of data
wait1:  LDA	0xFF46		; Get port B data
	ANDA	#1		; Lower bit a 0?
	BEQ	wait1		; Yes ... wait for the clock

	LDA	0xFF46		; Get port B data
	ANDA	#0xF0		; Only need the upper 4 bits
        STA     0x0400          ; To screen for progress

        LDA     #2              ; Set ACK ...
        STA     0xFF46          ; ... to 1

wait2:	LDA	0xFF46		; Get port B data
	ANDA	#1		; Lower bit a 0?
	BNE	wait2		; No ... wait for the clock

	LDA	0xFF46		; Get port B data
	LSRA			; Shift ...
	LSRA			; ... the ...
	LSRA			; ... LSN ...
	LSRA			; ... into place        
	ANDA	#0x0F		; Keep only the lower 4 bits
	STA     0x0401          ; To screen for progress
	ORA	0x0400		; Combine nibbles

        CLR     0xFF46          ; Clear ACK

	RTS			; Return value in A


writeByte:

        PSHS    A,B             ; Preserve the registers
        TFR     A,B             ; Original value to B
        
        ASRA                    ; xx00yy00
        ASRA                    ; ...
        ASRA                    ; ...
        ASRA                    ; ...
        ANDA    #0b00001100     ; ... 
        ORA     #2              ; Toggle clock 0 to 1
        STA     0xFF46          ; Send 2 bits to host

wait3:  LDA     0xFF46          ; Wait for ...
        ANDA    #1              ; ... ACK to ...
        BEQ     wait3           ; ... toggle from 0 to 1

        TFR     B,A             ; Original value
        ASRA                    ; 00xxyy00
        ASRA                    ; ...
        ANDA    #0b00001100     ; ...
        STA     0xFF46          ; Send 2 bits to host (clock 1 to 0)

wait4:  LDA     0xFF46          ; Wait for ...
        ANDA    #1              ; ... ACK to ...
        BNE     wait4           ; ... toggle from 1 to 0

        TFR     B,A             ; 0000**00  
        ANDA    #0b00001100     ; ...
        ORA     #2              ; Toggle clock from 0 to 1
        STA     0xFF46          ; Send 2 bits to host
 
wait5:  LDA     0xFF46          ; Wait for ...
        ANDA    #1              ; ... ACK to ...
        BEQ     wait5           ; ... toggle from 0 to 1

        TFR     B,A             ; Original value
        ASLA                    ; 0000yyxx
        ASLA                    ; ...
        ANDA    #0b00001100     ; ...
        STA     0xFF46          ; Send 2 bits to host (clock 1 to 0)

wait6:  LDA     0xFF46          ; Wait for ...
        ANDA    #1              ; ... ACK to ...
        BNE     wait6           ; ... toggle from 1 to 0

        PULS    A,B,PC          ; Restore and out

