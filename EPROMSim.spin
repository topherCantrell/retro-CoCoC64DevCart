CON
        _clkmode        = xtal1 + pll16x
        _xinfreq        = 5_000_000

' P0..P7  : D0..D7
' P8..P24 : A0..A16
' P25     : /OE
' P26     : /CE
' P27     : /WE

OBJ  

  PST         : "Parallax Serial Terminal"

VAR

PUB main | i, j, k, m   

  'PauseMSec(2000)
        
  PST.Start(57600) 
  'PST.Home
  'PST.Clear
  'PST.Str(string("Started",13))
    
  outa := %0000_111_00000000000000000_00000000 | i      ' Prepare the output pins (nothing asserted)
  dira := dira | %0000_111_11111111111111111_00000000   ' Address and control: output, Data: inputs
        
  k := 0 ' Checksum

  ' Read the 128K data
  repeat i from 0 to 127
    repeat m from 0 to 1023
      j := PST.charIn
      'writeRAM(i*1024+m,j)
      k := k + j

  ' Echo back the checksum
  PST.hex(k,8)

  ' Release the bus
  dira := dira & %1111_000_00000000000000000_00000000   ' Inactive ... let the host have the bus
  

PUB testRAM | i, j, k, m

  repeat i from 0 to 127
    repeat m from 0 to 1023
      writeRAM(i*1024+m,0)
    PST.char(".")        

  PST.Str(string(13,"Cleared",13))

  j := -1
  repeat i from 0 to 127
    repeat m from 0 to 1023
      k := readRAM(i*1024+m)
        if(k<>0)
          j := i*1024+m
    PST.char(".")

  PST.char(13)
  if j==-1
    PST.Str(string("PASSED"))
  else
    PST.Str(string("FAILED"))
    PST.hex(j,8)
  
PUB writeRAM(address, data) | i

    i := (address<<8 | data) ' Address and data into position

    dira := dira | %00000000_00000000_00000000_11111111   ' Data: output
    
    outa := %0000_001_00000000000000000_00000000 | i      ' Signal a write with address and data
    'PauseMSec(1)                                        ' Give the chip some time
    outa := %0000_111_00000000000000000_00000000 | i      ' De assert the write but leave address and data
    'PauseMSec(1)                                        ' Give the chip some time
    
    dira := dira & %11111111_11111111_11111111_00000000   ' Data as inputs again 

PUB readRAM(address) | i , r

    address := address << 8 ' Address into position
    
    outa := %0000_100_00000000000000000_00000000 | address  ' Signal a read with address
    'PauseMSec(1)                                          ' Give the chip some time
    r := ina                                                ' Get the value
    outa := %0000_111_00000000000000000_00000000 | address  ' De assert the read but leave address
    'PauseMSec(1)                                          ' Give the chip some time

    return r&$FF                                            ' Return the value    
 
PRI PauseMSec(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)  