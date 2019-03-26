CON
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

OBJ  

  PST         : "Parallax Serial Terminal"

VAR

PUB main | i

  dira := $00_FF   ' Lower 8 are output to PIA Port A
                   ' Upper 8 are inputs from PIA Port B
                   

' Pin 7 of the connector (PA4) should be grounded for "nibble" transfers or left floating
' for "bit" transfers.

' For testing this bit is tied to the propeller PA4. For bit transfers make sure outa is $10
' when DevCart starts up. This puts the cartridge in "bit" mode. For nibble transfers make sure
' outa is $00 when DevCart starts up. This puts the cartridge in "nibble" mode.
' 
' You will have to program the PROP with the new outa value and power cycle the system.

' The DevCart waits on the clock pin (Pin 10 PA7) to go high. This clock pin should be pulled to
' ground with a 1K resistor to prevent falsbe-triggers when the propeller resets and floats
' its I/O pins.
                           
  outa := $0        ' Nibble at a time
  'outa := $10      ' Bit at a time  
    
  PST.Start(57_600)
    
  ' Very simple for now ... just pass on anything we get
  repeat
    i := PST.CharIn
    sendByte(i)
   
PUB sendByte(val)
  sendByteNibbleSync(val)           ' Use the sync-line version

PUB sendByteBitSync(val)
  outa := ((val>>7)&1) | $90
  repeat while (ina & $8000) == 0  
  outa := ((val>>6)&1) | $10
  repeat while (ina & $8000) <> 0  
  outa := ((val>>5)&1) | $90
  repeat while (ina & $8000) == 0  
  outa := ((val>>4)&1) | $10
  repeat while (ina & $8000) <> 0  
  outa := ((val>>3)&1) | $90
  repeat while (ina & $8000) == 0  
  outa := ((val>>2)&1) | $10
  repeat while (ina & $8000) <> 0  
  outa := ((val>>1)&1) | $90
  repeat while (ina & $8000) == 0  
  outa := ((val)&1)    | $10
  repeat while (ina & $8000) <> 0     

PUB sendByteBitTimed(val) | i
  outa := ((val>>7)&1) | $90
  PauseMSec(1000)
  outa := ((val>>6)&1) | $10
  PauseMSec(1000)
  outa := ((val>>5)&1) | $90
  PauseMSec(1000)
  outa := ((val>>4)&1) | $10
  PauseMSec(1000)
  outa := ((val>>3)&1) | $90
  PauseMSec(1000)
  outa := ((val>>2)&1) | $10
  PauseMSec(1000)
  outa := ((val>>1)&1) | $90
  PauseMSec(1000)
  outa := ((val)&1)    | $10
  PauseMSec(1000)      

PUB sendByteNibbleSync(val)
  outa := (val>>4) | %10000000 
  repeat while (ina & $8000) == 0
  outa := val&%00001111            
  repeat while (ina & $8000) <> 0  

PUB sendByteNibbleTimed(val)
  outa := (val>>4) | %10000000
  PauseMSec(100)
  outa := val&%00001111
  PauseMSec(100)  
 
PRI PauseMSec(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)  