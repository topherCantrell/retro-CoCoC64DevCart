
define CPU = 6502


;@build Tool assemble hello.asm hello.bin -list
;@build tools.DevCart COM10 run hello.bin 0x6000


0x6000:

main:

    INC  0x548
    RTS

