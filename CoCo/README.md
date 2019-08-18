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