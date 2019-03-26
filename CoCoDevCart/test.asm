;@build tools.assembler.Assembler test.asm test.bin -list
;@build tools.coco.DevCartLoader X test.bin 0x420 


define CPU = 6809

0x420:

loop:
  LDA 0x400
  INCA
  STA 0x400
  BRA loop