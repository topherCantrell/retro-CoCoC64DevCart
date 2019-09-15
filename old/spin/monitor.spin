CON
  _clkmode        = xtal1 + pll16x
  _xinfreq        = 5_000_000

CON
  PIN_CA1 = 16  ' Output to CoCo
  PIN_CA2 = 17  ' Input from CoCo

OBJ    
    PST      : "Parallax Serial Terminal"

pub hdwtest | c,d

  PauseMSec(2000) 
  PST.start(115200)
  ' 0:7  PortA(output to CoCo's A input) 
  ' 8:15 PortB(input from CoCo's B output)
  ' 16   CA1 (output to CoCo)
  ' 17   CA2 (input from CoCo)    
  dira := %001_00000000_11111111
  outa := %000_00000000_00000000

  PST.str(string("Ready: +,-, ,XX",13))

  repeat

    c := PST.CharIn

    if c=="-"
      outa[PIN_CA1] := 0
      PST.str(string("Set CA1 to low",13))
    elseif c=="+"
      outa[PIN_CA1] := 1
      PST.str(string("Set CA1 to high",13))
    elseif c==" "
      PST.str(string("All inputs: "))
      PST.bin(ina[PIN_CA2],1)
      PST.char(" ")
      d:=ina / 256
      d:= d & $FF
      PST.bin(d,8)
      PST.char(13)
    else
      PST.str(string("..."))
      d := PST.CharIn
      c := parseHex(c) * 16 + parseHex(d)
      d := outa & $FFFF_FF00
      outa := d + c      
      PST.str(string(":Wrote value "))
      PST.hex(c,2)
      PST.str(string(" to output ",13))

pri parseHex(c)
  if c=>"0" and c=<"9"
    return c-"0"
  if c=>"A" and c=<"F"
    return c-"A"+10
  if c=>"a" and c=<"f"
    return c-"a"+10
  return 0  

PRI PauseMSec(Duration)
  waitcnt(((clkfreq / 1_000 * Duration - 3932) #> 381) + cnt)
      