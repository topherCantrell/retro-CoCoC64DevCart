    
    org   $1000
    fcc   'COCOOS'

    LDX   #$400
    LDA   #0
L1: STA   ,X+
    INCA
    CMPA  #0
    BNE   L1

L2: INC  $400
    BRA  L2