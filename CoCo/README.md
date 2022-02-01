PortA -- Input from host
PortB:
  7- Input from host
  6- Output to host
  5- x
  4- x
  3- |
  2- | Output nibble ...
  1- | ... to host
  0- |

Init:
- Set the directions
- All outputs 0

WriteByteCoCo:
- Write output upper nibble
- Set OUT to high
- Wait for IN from host is high
- Set OUT to low
- Wait for IN from host is low
- Write output lower nibble
- Set OUT to high
- Wait for IN from host is high
- Set OUT to low
- Wait for IN from host is low

ReadByteCoCo:
- Wait for IN from host is high
- Read byte
- Set OUT to high
- Wait for IN from host is low
- Set OUT to low
- Return byte

WriteByteHost:
- Write output byte
- Set OUT to high
- Wait for IN from host is high
- Set OUT to low
- Wait for IN from host is low

ReadByteHost:
- Wait for IN from host is high
- Read upper nibble
- Set OUT to high
- Wait for IN from host is low
- Set OUT to low
- Wait for IN from host is high
- Read lower nibble
- Set OUT to high
- Wait for IN from host is low
- Set OUT to low
- Return byte
