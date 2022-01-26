
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
