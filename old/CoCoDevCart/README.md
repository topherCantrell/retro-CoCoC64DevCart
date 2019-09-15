# 10/26/2008

The old version that reads a CFLASH works great. But I'm thinking of a new board with a propeller
chip for smarts that can communicate with lots of peripherals. Thus:
SPEC - Smart Peripheral Extension Card.
The propeller will communicate with an SD card, an external PC (through the USB cable) and a
PS/2 keyboard. On boot, the COCO ROM will bootstrap a 1K program from the propeller and
execute it.

CoCoSPEC.sch and CoCoSPEC.pcb are the new board. I wired up part of the PCB.

For an OS, how about a SWI scheme like Dungeons of Daggorath and keep the vector in the first
512 bytes of memory. Second 512 is reserved for kernel. Screen starts at 1024. Kernel from
C000 to EFFF. All RAM mode.

```
SWI 0 - Get disk info
    1 - Read sector
    2 - Write sector
   50 - Read PS/2 key
   51 - Read USB terminal
   52 - Write USB terminal
12/31/2010
```

Dang. Has it really been 2 years? How time flies. The EPROM works great. I just started 
testing the PIAs.

```
PIAs

..00 A Direction/IO
..01 A Control
..02 B Direction/IO
..03 B Control

FF40 is 65344
FF41 is 65345 
FF42 is 65346 
FF43 is 65347

FF44 is 65348
FF45 is 65349 
FF46 is 65350
FF47 is 65351

Testing FF44-B


FF46 <- 0
FF47 <- 4

Blue wire bit 7
Brown wire bit 6
```

OK. Wrapping up for the year. See you at the end of 2011.

Search for "fullduplexserial" to get propeller serial communication and pipe that through the USB to PC.
Write first bootstrap in BASIC and save on tape (just like the old days).

# 12/24/2011

```
Poke 65351,0			;  FF47 <-0 select in data-direction register
Poke 65350,255			;  FF46 <- FF (all outputs)
Poke 65351,4			;  FF47 <- 4 select out data-direction register
Poke 65350, 128 or 64 or 192	;  Twiddle bits

Poke 65351,0			;  FF47 <-0 select in data-direction register
Poke 65350,0   			;  FF46 <-0 All inputs
Poke 65351,0			;  FF47 <-4 selectoutn data-direction register
Print peek(65350)		; Read bits
```

Works great. Using the propeller demo board and the parallax serial terminal. I can send bits back and forth. Now to solder on some more wires … 8 data bits should get it.

# 12/16/2011

Technically it works. The boot-loader burned into the ROM downloads a program through the propeller and executes it. I was able to download the all-ram code and then the Dungeons of Daggorath.
The assembler needs lots and lots of work. The communication mechanism needs lots of work. Eventually I need to drop the 2nd PIA and replace it wi

