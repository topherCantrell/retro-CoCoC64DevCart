; Bootstrap Loader

; This is the first version of a PC-to-COCO file transfer utility to be burned into
; a cartridge ROM. This is a simple version to be tested with basic poke before
; burned. Once validated, the boostrap loader can be used to test other loaders
; that use more complicated two-way communications.

; This code uses Port B of the 2nd PIA chip. The 2nd PIA is mapped to
; address FF44..FF47. Port B is at FF46..FF47.

;@build tools.assembler.Assembler loader.asm loader.bin -list
;@build tools.coco.DevCartLoader loader.bin


define CPU = 6809

0x7000:
	LDA	#0		; Select the ...
	STA	0xFF47		; ... data-direction register port B
	STA	0xFF46		; All inputs port B
	LDA	#4		; Select the ...
	STA	0xFF47		; ... data register port B

	BSR 	readByte	; Read the destination LSB
	TFR 	A,B		; Hold it
	BSR	readByte	; Read the destination MSB
	TFR	D,X		; Destination to X

	BSR	readByte	; Read the count LSB
	TFR	A,B		; Hold it
	BSR	readByte	; Read the count MSB
	TFR	D,Y		; Count to Y

        PSHS    X		; Push destination on stack ... we'll "return" there

readLoop:
        BSR     readByte	; Get the next byte
        STA     ,X+		; Store it to memory
        LEAY    -1,Y		; All done?
        BNE     readLoop	; No ... do all

        RTS			; Jump to the loaded code


; Read a byte from the Port B. The upper 4 bits of B are the 
; data with the most-significant-nibble coming first followed
; by the least significant. The lower bit is the data clock.
; The MSN is read on 0->1 transition. The LSN is read on 1->0.
;
readByte:

; Read Upper 4 bits of data
wait1:	LDA	0xFF46		; Get port B data
	ANDA	#1		; Lower bit a 0?
	BEQ	wait1		; Yes ... wait for the clock

	LDA	0xFF46		; Get port B data
	ANDA	#0xF0		; Only need the upper 4 bits
        STA     0x0400          ; To screen for progress

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
	ORA	0x0400		;

	RTS			; Return value in A
