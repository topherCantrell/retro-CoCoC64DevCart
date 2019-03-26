
define CPU = 6809

;define CPU = 6502

; build Tool assemble hello.asm hello.bin -list
; build tools.DevCart COM3 run hello.bin 0x6000

;@build tools.DevCart COM4 run daggorath.bin 0xC000

0x6000:

main:

    DEC  0x548    
    jmp  main
    RTS

