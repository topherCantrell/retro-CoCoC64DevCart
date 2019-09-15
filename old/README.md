# TRS80 Color Computer

![](cocodevsch1.jpg)

![](cocodevsch2.jpg)

![](cocodevpcb.jpg)

![](devcartpropsch.jpg)

# Software

In a forum, Chip Gracey insists that a current limit resistor should be used on incoming 5V signals. Others suggest 1k. The protection diodes can
"wear out" over long periods. The CoCo software needs to drive these low between communication sessions.

On the 6821, the A port works with the 3.3V propeller outputs. Port A needs to be input FROM propeller. Port B needs to be output TO propeller.

TODO Verify this.
TODO Check if CA1 (input) works with 3.3 input from propeller.

# 8/18/2019

I made the board mods to bring CA1 and CA2 to the IDC connector.

```

POKE &HFF47,0     ; Data-direction register port B
POKE &HFF46,255   ; All output port B
POKE &HFF47,4     ; Data register port B

POKE &HFF46,0     ; Data appears on prop ina[8,9,10,11,12,13,14,15]

POKE &HFF45,0     ; Data-direction register port A
POKE &HFF44,0     ; All inputs port A
POKE &HFF45,4     ; Data register port A

PRINT PEEK(&HFF44) ; Data from prop outa[0,1,2,3,4,5,6,7]



FF45: 00_100_1_10        38

CA2 is BUSY to propeller. When CA2 is high, the CoCo has not read the last data sent.
When CA2 is low, the propeller can can the next byte.

The upper bit of FF45 is the data-received to the CoCo. When the bit is 1, the A register
contains new data to read. Reading the data clears the bit.

When CA1 transitions from low to high, the upper bit of FF45 becomes 1 and CA2 becomes 1. This signals the CoCo
code to read the value from register A. This signals the prop to wait before sending the next byte.

When the CoCo code reads the value from register A, the upper bit of FF45 becomes 0 and CA2 becomes 0. This signals
the CoCo code to wait for a value. This signals the prop to send the next byte.-
```