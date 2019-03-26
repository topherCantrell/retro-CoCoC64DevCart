                                           
                                           ;  processor 6809
                                           ;  build-command java Blend zoo.asm z2.asm
                                           ;  build-command a09 -LZ2.LST z2.asm
                                           
                                           ;  ------- To Do -----
                                           ;  The CFLASH I/O routines
                                           
                                           ;  ------- Future Enhancements -----
                                           ;  When you enter a question, the game should strip off any trailing "?"
                                           ;  A show-zoo facility to show all nodes in the zoo would be handy
                                           
                                           ;  ------- Lessons learned for book -------
                                           
                                           ;  Talk about inheritance and polymorphism and such with FILE_IO and
                                           ;  CFLASH_FILE_IO
                                           
                                           ;  Unit testing is so very important. Lots of functions seem to work
                                           ;  except I didn't make sure the current-position was updated and 
                                           ;  I didn't make sure registers were preserved and un-needed returns
                                           ;  were correct (that I later came to use). Develop lots of little
                                           ;  scaffolding code that won't get used in production, but will get used
                                           ;  along the way. DON'T DELETE IT ... just comment it out or move it. You'll
                                           ;  test again later.
                                           
                                           ;  Debug facilities like register-dump and memory view is vital. Develop
                                           ;  those for the reader.
                                           
                                           ;  It would be nice if there were a tool-facility to manage stack variables
                                           ;  to keep track of things like "4,S" automatically.
                                           
                                           ;  In making functions generic, you'll be stacking and unstacking a lot of things
                                           ;  needlessly to ensure nothing gets changed. The alternative is to force the
                                           ;  caller to preserve data across calls. This is equally viable and preferrable
                                           ;  in speed-critical situations.
                                           
                                           ;  Good debug techniques: increment screen memory in and out of a function so you can
                                           ;  see the call tree. Also increment after steps in a suspect function. Or just uncomment 
                                           ;  lines of a function one by one ... especially the calls.
                                           ;  Substitue indirect calls temporarily with absolutes.
                                           ;  Stress the importance of unit-testing a method or set of methods completely. Throw-away
                                           ;  debug code ... but just comment it out! You'll find later that you suspect a function
                                           ;  is failing even though you thought you tested it fully. Stick in the increment-while-true
                                           ;  to see if you are getting to a spot. Store values to the screen memory for inspection.
                                           
                                           ;  With all the indexed addressing, the LEA is most needed. It's power becomes clear.
                                           ;  Talk about this instruction when you talk about indexed addressing.
                                           
                                           ;  The LEA is used to add and subtract from the index registers even though it
                                           ;  doesn't look like a standard add/subtract. It takes longer too ... longer
                                           ;  instruction.
                                           ;  Comment that this is a LEA even though it doesn't look like one!
                                           
                                           ;  When you first start working on a platform you'll spend a lot of time creating
                                           ;  librarys of things (strings, screen, etc) that will pay off in the future.
                                           ;  Don't worry if you find yourself straying from the course of your game ... remember
                                           ;  you are writing lots of future games too.
                                           
                                           ;  Took a while to code this game because I created a lot of library
                                           ;  functions (strings, screen, etc) that will pay off in my next
                                           ;  application (show NavalWar, for instance)
                                           
                                           ;  Observations:
                                           ;  Not a lot of local variables to work with in assembler. You have to either
                                           ;  frame-up the stack or create lots of these globals.
                                           
                                           ;  Talk about abstraction. We hid the screen-cursor behind functions. Advantages?
                                           ;  Disadvantages? We didn't hide the CurrentSize and CurrentPosition. They are more
                                           ;  concrete ... talk about this.
                                           
                                           ;  Would be nice if the tool could figure out data context so we could drop '#' and
                                           ;  use '&' when we need to.
                                           
                                           ; <EditorTab name="ZOO_NODE">
                                           ;  StructureDefinition ZOO_NODE {
                                           ;    2 DataOffset
                                           ;    2 YesNextNode
                                           ;    2 NoNextNode
                                           ;    256 Text
                                           ;  }
                                           ; </EditorTab>
                                           
                                           ; <EditorTab name="FILE_IO">
                                           ;  StructureDefinition FILE_IO {
                                           ;    2 FnReadBytes  ; X=this, Y=number, U=buffer
                                           ;    2 FnWriteBytes ; X=this, Y=number, U=buffer
                                           ;    2 FnFlush      ; X=this
                                           ;    2 FnSeek       ; X=this, Y=position
                                           ;    2 FnGetSize    ; X=this, Y<=size
                                           ;  --------
                                           ;    2 CurrentPosition
                                           ;    2 CurrentSize
                                           ;  }
                                           
                                           ;  StructureDefinition CFLASH_FILE_IO : FILE_IO {
                                           ;  Inheriting all of FILE_IO's members first
                                           ;    1   Drive
                                           ;    2   StartSector
                                           ;    2   CurrentOffsetInSector
                                           ;    2   CurrentCachedSector
                                           ;    1   Dirty
                                           ;    512 SectorCache
                                           ;  }
                                           ; </EditorTab>
                                           
                                           ; <EditorTab name="RAM">
                                           
                                           ;  BASIC scratch memory takes from $0000 to $0400
                                           ;  Screen sits at $0400 - $04FF
                                           ;  Stack runs from $04FF - $1000
                                           ;  Program lives from $1000 to $1FFF
                                           ;  Variable memory lives from $2000 to $2FFF
                                           ;  RAMDRIVE eats the remainder of RAM from $3000 on
                                           
                 org      $2000            ; OLine=115
NODE_BUF_LAST    rmb      262              ;  StructureUsage NODE_BUF_LAST     is ZOO_NODE
NODE_BUF_CURRENT rmb      262              ;  StructureUsage NODE_BUF_CURRENT  is ZOO_NODE
NODE_BUF_NEW_1   rmb      262              ;  StructureUsage NODE_BUF_NEW_1    is ZOO_NODE
NODE_BUF_NEW_2   rmb      262              ;  StructureUsage NODE_BUF_NEW_2    is ZOO_NODE
ZOO_IO           rmb      534              ;  StructureUsage CFLASH_FILE_IO    is CFLASH_FILE_IO
INPUT_BUFFER     rmb      16               ; OLine=121
SCREEN_CURSOR    rmb      2                ; OLine=122
TEMP_A           rmb      2                ; OLine=123
                                           
                 org      $3000            ; OLine=125
RAM_DRIVE        rmb      $1000            ; OLine=126  At least 4K left in a 16K system
                                           
                                           
                                           ; </EditorTab>
                                           
                                           ; <EditorTab name="START">
                                           
                                           ; org $C000
                 org      $1000            ; OLine=134
                                           
                 fcc      "COCOOS"         ; OLine=136  Preamble checked by the RAMLOADER. Execution begins at $1006.
                                           
                 LDS      #$1000           ; OLine=138
                                           
                 LDB      #96              ; OLine=140
                 LBSR     CLEAR_SCREEN     ; OLine=141
                                           
                                           ; X = #ZOO_IO
                                           ; INIT_RAM_FILE()
                                           
                                           ;  The RAMLOADER leaves the last-loaded-sector in Y
                 LEAY     1,Y              ; OLine=147  Assume the data area is right after the program
                 LDX      #ZOO_IO          ; OLine=148
                 LBSR     INIT_CFLASH_FILE ; OLine=149
                                           
                 LDX      #MSG_WELCOME     ; OLine=151
                 LBSR     PRINT_MESSAGE    ; OLine=152
                                           
FLOW_A_1_OUTPUT_BEGIN:                           
                                           ;   LBRA  FLOW_A_1_1_INPUT
                                           ;  FLOW_A_1_1_INPUT:
                                           ;  polarity 0
                                           ;   LBRA FLOW_A_1_OUTPUT_TRUE
                                           ;  FLOW_A_1_OUTPUT_TRUE:
                 LDX      #ZOO_IO          ; OLine=155
                 LBSR     PLAY_ZOO         ; OLine=156
                 LBRA     FLOW_A_1_OUTPUT_BEGIN 
                                           ;  FLOW_A_1_OUTPUT_FALSE:
                                           ;  FLOW_A_1_OUTPUT_END:
                                           
                                           ; </EditorTab>
                                           
                                           ; <EditorTab name="CFLASH FILE I/O">
                                           ; =======================================================================
                                           ;  CFLASH FILE IO FUNCTIONS
                                           ; =======================================================================
                                           
INIT_CFLASH_FILE:                           ;  --SubroutineContextBegins--
                                           ;  StructureUsage X is CFLASH_FILE_IO
                                           
                 STY      15,X             
                                           
                 LDB      #0               ; OLine=171
                 STB      14,X             
                 STB      21,X             
                                           
                 LDD      #CFLASH_READ_BYTES ; OLine=175
                 STD      0,X              
                 LDD      #CFLASH_WRITE_BYTES ; OLine=177
                 STD      2,X              
                 LDD      #CFLASH_FLUSH    ; OLine=179
                 STD      4,X              
                 LDD      #CFLASH_SEEK     ; OLine=181
                 STD      6,X              
                 LDD      #CFLASH_GET_SIZE ; OLine=183
                 STD      8,X              
                 LDD      #0               ; OLine=185
                 STD      10,X             
                                           
                                           ;  Set the size to max and then use the read-bytes to find
                                           ;  3 consecutive 0's. Then end point is the middle 0.
                                           ;  Back off the size (if found 3)  
                                           
                 LDD      $FFFF            ; OLine=192
                 STD      12,X             
                                           
                 RTS                       ;  --SubroutineContextEnds--
                                           
ROM_OS_READ_SECTOR equ      $C2F8            ; OLine=197
ROM_OS_WRITE_SECTOR equ      $C322            ; OLine=198
                                           
CFLASH_FLUSH:                              ;  --SubroutineContextBegins--
                                           
                                           ;  StructureUsage X is CFLASH_FILE_IO
                                           
                 LDB      21,X             
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_2_1_INPUT
                                           ;  FLOW_A_2_1_INPUT:
                                           ;  polarity 0
                 CMPB     #0               
                                           ;   LBEQ FLOW_A_2_OUTPUT_TRUE
                                           ;   LBRA FLOW_A_2_OUTPUT_FALSE
                                           ;  FLOW_A_2_OUTPUT_FALSE:
                                           ;   LBRA  FLOW_A_2_OUTPUT_END
                                           ;  FLOW_A_2_OUTPUT_TRUE:
                                           ;       return CLEAN-OrphanReturn- 
                                           ;  FLOW_A_2_OUTPUT_END:
                                           
                 PSHS     A                ; OLine=209
                 PSHS     X                ; OLine=210
                 PSHS     Y                ; OLine=211
                 PSHS     U                ; OLine=212
                                           
                 LDD      #0               ; OLine=214
                 STB      21,X             
                 STD      17,X             
                 STY      19,X             
                                           
                 LDB      14,X             
                                           
                 TFR      Y,D              ; OLine=221
                 ADDD     15,X             
                 TFR      D,Y              ; OLine=223
                 LEAU     22,X             
                 LDX      #0               ; OLine=225
                                           
                                           ;  B=Drive, X=SectorMSW, Y=SectorLSW, U=Buffer (return status in B)  
                 JSR      ROM_OS_WRITE_SECTOR ; OLine=228
                                           
                 PULS     U                ; OLine=230
                 PULS     Y                ; OLine=231
                 PULS     X                ; OLine=232
                 PULS     A                ; OLine=233
                                           
                 RTS                       ;  --SubroutineContextEnds--
                                           
CACHE_SECTOR:                              ;  --SubroutineContextBegins--
                                           
                 LBSR     CFLASH_FLUSH     ; OLine=239  Make sure the cache is written out (if dirty)
                                           
                                           ;  StructureUsage X is CFLASH_FILE_IO
                                           
                 PSHS     A                ; OLine=243
                 PSHS     X                ; OLine=244
                 PSHS     Y                ; OLine=245
                 PSHS     U                ; OLine=246
                                           
                 LDD      #0               ; OLine=248
                 STB      21,X             
                 STD      17,X             
                 STY      19,X             
                                           
                 LDB      14,X             
                                           
                 TFR      Y,D              ; OLine=255
                 ADDD     15,X             
                 TFR      D,Y              ; OLine=257
                 LEAU     22,X             
                 LDX      #0               ; OLine=259
                                           
                                           ;  B=Drive, X=SectorMSW, Y=SectorLSW, U=Buffer (return status in B)  
                 JSR      ROM_OS_READ_SECTOR ; OLine=262
                                           
                 PULS     U                ; OLine=264
                 PULS     Y                ; OLine=265
                 PULS     X                ; OLine=266
                 PULS     A                ; OLine=267
                                           
                 RTS                       ;  --SubroutineContextEnds--
                                           
CFLASH_READ_BYTES:                           ;  --SubroutineContextBegins--
                                           ;  StructureUsage X is CFLASH_FILE_IO
                 RTS                       ;  --SubroutineContextEnds--
                                           
CFLASH_WRITE_BYTES:                           ;  --SubroutineContextBegins--
                                           ;  StructureUsage X is CFLASH_FILE_IO
                 RTS                       ;  --SubroutineContextEnds--
                                           
CFLASH_SEEK:                               ;  --SubroutineContextBegins--
                                           ;  StructureUsage X is CFLASH_FILE_IO
                 RTS                       ;  --SubroutineContextEnds--
                                           
CFLASH_GET_SIZE:                           ;  --SubroutineContextBegins--
                                           ;  StructureUsage X is CFLASH_FILE_IO 
                 LDY      12,X             
                 RTS                       ;  --SubroutineContextEnds--
                                           
                                           ; </EditorTab>
                                           
                                           ; <EditorTab name="RAM FILE I/O">
                                           ; =======================================================================
                                           ;  RAM FILE IO FUNCTIONS
                                           ; =======================================================================
                                           
INIT_RAM_FILE:                             ;  --SubroutineContextBegins--
                                           ;  StructureUsage X is FILE_IO
                                           
                 PSHS     D                ; OLine=298
                                           
                 PSHS     X                ; OLine=300
                 PSHS     Y                ; OLine=301
                 PSHS     U                ; OLine=302
                                           ;  Copy RAM_DRIVE from ROM to RAM
                 LDX      #RAM_DRIVE_ROM   ; OLine=304
                 LDY      #RAM_DRIVE       ; OLine=305
                 LDU      #ZOO_END-RAM_DRIVE_ROM ; OLine=306
                                           ;  FLOW_A_3_OUTPUT_BEGIN:
FLOW_A_3_OUTPUT_TRUE:                           
                 LDA      ,X+              ; OLine=308
                 STA      ,Y+              ; OLine=309
                 LEAU     -1,U             ; OLine=310
                                           ;   LBRA  FLOW_A_3_1_INPUT
                                           ;  FLOW_A_3_1_INPUT:
                                           ;  polarity 0
                 CMPU     #0               
                 LBNE     FLOW_A_3_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_3_OUTPUT_FALSE
                                           ;  FLOW_A_3_OUTPUT_FALSE:
                                           ;  FLOW_A_3_OUTPUT_END:
                 PULS     U                ; OLine=312
                 PULS     Y                ; OLine=313
                 PULS     X                ; OLine=314
                                           
                 LDD      #RAM_READ_BYTES  ; OLine=316
                 STD      0,X              
                 LDD      #RAM_WRITE_BYTES ; OLine=318
                 STD      2,X              
                 LDD      #RAM_FLUSH       ; OLine=320
                 STD      4,X              
                 LDD      #RAM_SEEK        ; OLine=322
                 STD      6,X              
                 LDD      #RAM_GET_SIZE    ; OLine=324
                 STD      8,X              
                 LDD      #0               ; OLine=326
                 STD      10,X             
                 LDD      #ZOO_END-RAM_DRIVE_ROM ; OLine=328
                 STD      12,X             
                 PULS     D                ; OLine=330
                 RTS                       ;  --SubroutineContextEnds--
                                           
RAM_READ_BYTES:                            ;  --SubroutineContextBegins--
                                           ;  StructureUsage X is FILE_IO
                                           
                 PSHS     D                ; OLine=336
                 PSHS     Y                ; OLine=337
                 PSHS     U                ; OLine=338
                                           
                 PSHS     X                ; OLine=340
                                           
                                           ;  Limit Y to what we have
                 LDD      12,X             
                 SUBD     10,X             
                 STD      4,S              ; OLine=345  ?? Return value?
                 TFR      Y,D              ; OLine=346
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_4_1_INPUT
                                           ;  FLOW_A_4_1_INPUT:
                                           ;  polarity 0
                 CMPD     4,S              
                 LBGT     FLOW_A_4_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_4_OUTPUT_FALSE
                                           ;  FLOW_A_4_OUTPUT_FALSE:
                 LBRA     FLOW_A_4_OUTPUT_END 
FLOW_A_4_OUTPUT_TRUE:                           
                 LDD      4,S              ; OLine=348
FLOW_A_4_OUTPUT_END:                           
                 STD      4,S              ; OLine=350
                 TFR      D,Y              ; OLine=351
                                           
                                           ;  Get the absolute RAM pointer to X
                 LDD      10,X             
                 ADDD     #RAM_DRIVE       ; OLine=355
                 TFR      D,X              ; OLine=356
                                           
                                           ;  Do the copy
                                           ;  FLOW_A_5_OUTPUT_BEGIN:
FLOW_A_5_OUTPUT_TRUE:                           
                 LDA      ,X+              ; OLine=360
                 STA      ,U+              ; OLine=361
                 LEAY     -1,Y             ; OLine=362
                                           ;   LBRA  FLOW_A_5_1_INPUT
                                           ;  FLOW_A_5_1_INPUT:
                                           ;  polarity 0
                 CMPY     #0               
                 LBNE     FLOW_A_5_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_5_OUTPUT_FALSE
                                           ;  FLOW_A_5_OUTPUT_FALSE:
                                           ;  FLOW_A_5_OUTPUT_END:
                                           
                 LDD      4,S              ; OLine=365
                                           
                 PULS     X                ; OLine=367
                 ADDD     10,X             
                 STD      10,X             
                                           
                 PULS     U                ; OLine=371
                 PULS     Y                ; OLine=372
                 PULS     D                ; OLine=373
                                           
                 RTS                       ;  --SubroutineContextEnds--
                                           
RAM_WRITE_BYTES:                           ;  --SubroutineContextBegins--
                                           ;  StructureUsage X is FILE_IO
                                           
                 PSHS     D                ; OLine=380
                 PSHS     Y                ; OLine=381
                 PSHS     U                ; OLine=382
                 PSHS     X                ; OLine=383
                                           
                                           ;  Get the absolute RAM pointer to X
                 LDD      10,X             
                 ADDD     #RAM_DRIVE       ; OLine=387
                 TFR      D,X              ; OLine=388
                                           
                 LDD      #0               ; OLine=390
                 STD      2,S              ; OLine=391
                                           
                                           ;  Do the copy
                                           ;  FLOW_A_6_OUTPUT_BEGIN:
FLOW_A_6_OUTPUT_TRUE:                           
                 LDA      ,U+              ; OLine=395
                 STA      ,X+              ; OLine=396
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_7_1_INPUT
                                           ;  FLOW_A_7_1_INPUT:
                                           ;  polarity 0
                 CMPA     -1,X             
                 LBNE     FLOW_A_6_OUTPUT_END ; CLEAN-JumpToJump- FLOW_A_7_OUTPUT_TRUE
                                           ;   LBRA FLOW_A_7_OUTPUT_FALSE
                                           ;  FLOW_A_7_OUTPUT_FALSE:
                 LBRA     FLOW_A_7_OUTPUT_END 
                                           ;  FLOW_A_7_OUTPUT_TRUE:
                 LBRA     FLOW_A_6_OUTPUT_END ; OLine=398    
FLOW_A_7_OUTPUT_END:                           
                 INC      2,S              ; OLine=400
                 LEAY     -1,Y             ; OLine=401
                                           ;   LBRA  FLOW_A_6_1_INPUT
                                           ;  FLOW_A_6_1_INPUT:
                                           ;  polarity 0
                 CMPY     #0               
                 LBNE     FLOW_A_6_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_6_OUTPUT_FALSE
                                           ;  FLOW_A_6_OUTPUT_FALSE:
FLOW_A_6_OUTPUT_END:                           
                                           
                 PULS     X                ; OLine=404
                 LDD      2,S              ; OLine=405
                 ADDD     10,X             
                 STD      10,X             
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_8_1_INPUT
                                           ;  FLOW_A_8_1_INPUT:
                                           ;  polarity 0
                 CMPD     12,X             
                 LBGT     FLOW_A_8_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_8_OUTPUT_FALSE
                                           ;  FLOW_A_8_OUTPUT_FALSE:
                 LBRA     FLOW_A_8_OUTPUT_END 
FLOW_A_8_OUTPUT_TRUE:                           
                 STD      12,X             
FLOW_A_8_OUTPUT_END:                           
                 PULS     U                ; OLine=411
                 PULS     Y                ; OLine=412
                 PULS     D                ; OLine=413
                                           
                 RTS                       ;  --SubroutineContextEnds--
                                           
RAM_FLUSH:                                 ;  --SubroutineContextBegins--
                                           ;  Nothing to do for RAM files  
                 RTS                       ;  --SubroutineContextEnds--
                                           
RAM_SEEK:                                  ;  --SubroutineContextBegins--
                                           ;  StructureUsage X is FILE_IO
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_9_1_INPUT
                                           ;  FLOW_A_9_1_INPUT:
                                           ;  polarity 0
                 CMPY     12,X             
                 LBGT     FLOW_A_9_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_9_OUTPUT_FALSE
                                           ;  FLOW_A_9_OUTPUT_FALSE:
                 LBRA     FLOW_A_9_OUTPUT_END 
FLOW_A_9_OUTPUT_TRUE:                           
                 LDY      12,X             
FLOW_A_9_OUTPUT_END:                           
                 STY      10,X             
                 RTS                       ;  --SubroutineContextEnds--
                                           
RAM_GET_SIZE:                              ;  --SubroutineContextBegins--
                                           ;  StructureUsage X is FILE_IO
                 LDY      12,X             
                 RTS                       ;  --SubroutineContextEnds--
                                           ; </EditorTab>
                                           
                                           ; <EditorTab name="PlayZoo()">
                                           
PLAY_ZOO:                                  ;  --SubroutineContextBegins--
                                           
                 LDY      #8               ; OLine=439  First ZOO node (after preamble)  
                                           
                 PSHS     X                ; OLine=441
                 LDX      #MSG_INSTRUCTIONS ; OLine=442
                 LBSR     PRINT_MESSAGE    ; OLine=443
                 PULS     X                ; OLine=444
                                           
FLOW_A_10_OUTPUT_BEGIN:                           
                                           ;   LBRA  FLOW_A_10_1_INPUT
                                           ;  FLOW_A_10_1_INPUT:
                                           ;  polarity 0
                                           ;   LBRA FLOW_A_10_OUTPUT_TRUE
                                           ;  FLOW_A_10_OUTPUT_TRUE:
                                           
                 LBSR     LOAD_ZOO_NODE    ; OLine=448
                                           
                 LDU      #NODE_BUF_CURRENT ; OLine=450
                                           ;  StructureUsage U is ZOO_NODE
                 LDD      2,U              
                                           
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_11_1_INPUT
                                           ;  FLOW_A_11_1_INPUT:
                                           ;  polarity 0
                 CMPD     #0               
                 LBEQ     FLOW_A_11_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_11_OUTPUT_FALSE
                                           ;  FLOW_A_11_OUTPUT_FALSE:
                 //       Question node    ; OLine=490
                 PSHS     X                ; OLine=491
                                           
                 LEAX     6,U              
                 LBSR     PRINT_MESSAGE    ; OLine=494
                                           
                 LDX      #MSG_QUESTION_MARK ; OLine=496
                 LBSR     PRINT_MESSAGE    ; OLine=497
                                           
                 LDX      #MSG_YN          ; OLine=499
                 LBSR     PRINT_MESSAGE    ; OLine=500
                                           
                 PSHS     U                ; OLine=502
                 LDX      #INPUT_BUFFER    ; OLine=503
                 LDU      #4               ; OLine=504
                 LBSR     INPUT_STRING     ; OLine=505
                 LBSR     LINE_FEED        ; OLine=506
                 PULS     U                ; OLine=507
                                           
                 LDA      ,X               ; OLine=509
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_14_1_INPUT
                                           ;  FLOW_A_14_1_INPUT:
                                           ;  polarity 0
                 CMPA     #'Y'             
                 LBEQ     FLOW_A_14_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_14_OUTPUT_FALSE
                                           ;  FLOW_A_14_OUTPUT_FALSE:
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_15_1_INPUT
                                           ;  FLOW_A_15_1_INPUT:
                                           ;  polarity 0
                 CMPA     #'N'             
                 LBEQ     FLOW_A_15_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_15_OUTPUT_FALSE
                                           ;  FLOW_A_15_OUTPUT_FALSE:
                 LBRA     FLOW_A_14_OUTPUT_END ; CLEAN-JumpToJump- FLOW_A_15_OUTPUT_END
FLOW_A_15_OUTPUT_TRUE:                           
                 LBSR     COPY_CURRENT_TO_LAST ; OLine=514
                 LDY      4,U              
                                           ;  FLOW_A_15_OUTPUT_END:
                 LBRA     FLOW_A_14_OUTPUT_END 
FLOW_A_14_OUTPUT_TRUE:                           
                 LBSR     COPY_CURRENT_TO_LAST ; OLine=511
                 LDY      2,U              
FLOW_A_14_OUTPUT_END:                           
                                           
                 PULS     X                ; OLine=518
                 LBRA     FLOW_A_10_OUTPUT_BEGIN ; CLEAN-JumpToJump- FLOW_A_11_OUTPUT_END
FLOW_A_11_OUTPUT_TRUE:                           
                 //       Animal node      ; OLine=455
                 PSHS     X                ; OLine=456
                                           
                 LDX      #MSG_ISIT        ; OLine=458
                 LBSR     PRINT_MESSAGE    ; OLine=459
                 LEAX     6,U              
                 LBSR     PRINT_MESSAGE    ; OLine=461
                 LDX      #MSG_QUESTION_MARK ; OLine=462
                 LBSR     PRINT_MESSAGE    ; OLine=463
                                           
                 LDX      #MSG_YN          ; OLine=465
                 LBSR     PRINT_MESSAGE    ; OLine=466
                                           
                 PSHS     U                ; OLine=468
                 LDX      #INPUT_BUFFER    ; OLine=469
                 LDU      #3               ; OLine=470
                 LBSR     INPUT_STRING     ; OLine=471
                 LBSR     LINE_FEED        ; OLine=472
                 PULS     U                ; OLine=473
                                           
                 LDA      ,X               ; OLine=475
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_12_1_INPUT
                                           ;  FLOW_A_12_1_INPUT:
                                           ;  polarity 0
                 CMPA     #'Y'             
                 LBEQ     FLOW_A_12_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_12_OUTPUT_FALSE
                                           ;  FLOW_A_12_OUTPUT_FALSE:
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_13_1_INPUT
                                           ;  FLOW_A_13_1_INPUT:
                                           ;  polarity 0
                 CMPA     #'N'             
                 LBEQ     FLOW_A_13_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_13_OUTPUT_FALSE
                                           ;  FLOW_A_13_OUTPUT_FALSE:
                 LBRA     FLOW_A_12_OUTPUT_END ; CLEAN-JumpToJump- FLOW_A_13_OUTPUT_END
FLOW_A_13_OUTPUT_TRUE:                           
                 PULS     X                ; OLine=482
                 LBSR     ADD_TO_ZOO       ; OLine=483
                 RTS                       ; OLine=484
                                           ;  FLOW_A_13_OUTPUT_END:
                 LBRA     FLOW_A_12_OUTPUT_END 
FLOW_A_12_OUTPUT_TRUE:                           
                 LDX      #MSG_I_GOT_IT    ; OLine=477
                 LBSR     PRINT_MESSAGE    ; OLine=478
                 PULS     X                ; OLine=479
                 RTS                       ; OLine=480
FLOW_A_12_OUTPUT_END:                           
                                           
                 PULS     X                ; OLine=487
                                           
                                           ;  FLOW_A_11_OUTPUT_END:
                                           
                 LBRA     FLOW_A_10_OUTPUT_BEGIN 
                                           ;  FLOW_A_10_OUTPUT_FALSE:
                                           ;  FLOW_A_10_OUTPUT_END:
                                           
                                           ;   RTS ; --SubroutineContextEnds-- CLEAN-OrphanReturn- 
                                           ; </EditorTab>
                                           
                                           ; <EditorTab name="AddToZoo()">
ZOO_GATHER_INFO:                           ;  --SubroutineContextBegins--
                                           
                                           ;  This function gathers all the data about the user's new animal:
                                           ;  NODE_BUF_NEW_1 <= the new question (0's for links)
                                           ;  NODE_BUF_NEW_2 <= the new animal (0's for links)
                                           ;  TEMP_A <= the user's answer character ('Y' or 'N')
                                           
                 PSHS     D                ; OLine=534
                 PSHS     X                ; OLine=535
                 PSHS     Y                ; OLine=536
                 PSHS     U                ; OLine=537
                                           
                 LDB      #96              ; OLine=539
                 LBSR     CLEAR_SCREEN     ; OLine=540
                                           
                 LDX      #MSG_STUMP       ; OLine=542
                 LBSR     PRINT_MESSAGE    ; OLine=543
                                           
                 LDU      #NODE_BUF_NEW_2  ;  StructureUsage U is ZOO_NODE
                 LDD      #0               ; OLine=546
                 STD      0,U              
                 STD      2,U              
                 STD      4,U              
                 LEAX     6,U              
                 LDU      #32              ; OLine=551
                 LBSR     INPUT_STRING     ; OLine=552
                 LBSR     LINE_FEED        ; OLine=553
                                           
                 LDX      #MSG_GIVE        ; OLine=555
                 LBSR     PRINT_MESSAGE    ; OLine=556
                 LDB      #'('             ; OLine=557
                 LBSR     PRINT_CHARACTER  ; OLine=558
                 LDU      #NODE_BUF_CURRENT ; OLine=559
                 LEAX     6,U              
                 LBSR     PRINT_MESSAGE    ; OLine=561
                 LDX      #MSG_FROM        ; OLine=562
                 LBSR     PRINT_MESSAGE    ; OLine=563
                 LDU      #NODE_BUF_NEW_2  ; OLine=564
                 LEAX     6,U              
                 LBSR     PRINT_MESSAGE    ; OLine=566
                 LDB      #')'             ; OLine=567
                 LBSR     PRINT_CHARACTER  ; OLine=568
                 LDB      #':'             ; OLine=569
                 LBSR     PRINT_CHARACTER  ; OLine=570
                 LBSR     LINE_FEED        ; OLine=571
                                           
                 LDU      #NODE_BUF_NEW_1  ; OLine=573
                 LDD      #0               ; OLine=574
                 STD      0,U              
                 STD      2,U              
                 STD      4,U              
                 LEAX     6,U              
                 LDU      #256             
                 LBSR     INPUT_STRING     ; OLine=580
                 LBSR     LINE_FEED        ; OLine=581
                                           
                 LDX      #MSG_WHAT        ; OLine=583
                 LBSR     PRINT_MESSAGE    ; OLine=584 
                                           
                 LDX      #INPUT_BUFFER    ; OLine=586
                 LDU      #4               ; OLine=587
                 LBSR     INPUT_STRING     ; OLine=588
                 LBSR     LINE_FEED        ; OLine=589
                                           
                                           ;  Hang on to answer for a bit
                 LDA      ,X               ; OLine=592
                 STA      TEMP_A           ; OLine=593
                                           
                 PULS     U                ; OLine=595
                 PULS     Y                ; OLine=596
                 PULS     X                ; OLine=597
                 PULS     D                ; OLine=598
                                           
                 RTS                       ;  --SubroutineContextEnds--
                                           
ADD_TO_ZOO:                                ;  --SubroutineContextBegins--
                                           
                                           ;  ZOO_GATHER_INFO()
                                           
                                           ;  D = STRLEN(NODE_BUF_NEW_1->Text)
                                           ;  NODE_BUF_NEW_1->YesNextNode = D + 5 + X->CurrentSize
                                           ;  NODE_BUF_NEW_1->NoNextNode = NODE_BUF_CURRENT->DataOffset
                                           
                                           ;  if(TEMP_A != 'Y') {
                                           ;     D = NODE_BUF_NEW_1->YesNextNode
                                           ;     NODE_BUF_NEW_1->YesNextNode = NODE_BUF_NEW_1->NoNextNode
                                           ;     NODE_BUF_NEW_1->NoNextNode = D
                                           ;  }
                                           
                                           ;  B = APPEND_NODE(NODE_BUF_NEW_1)
                                           ;  if(B==0) {
                                           ;    return
                                           ;    OUT_OF_DISK_SPACE()
                                           ;  }
                                           
                                           ;  B = APPEND_NODE(NODE_BUF_NEW_2)
                                           ;  if(B==0) {
                                           ;    return
                                           ;    OUT_OF_DISK_SPACE()
                                           ;  }
                                           
                                           ;  D = NODE_BUF_CURRENT->DataOffset
                                           ;  Y = NODE_BUF_LAST->DataOffset
                                           ;  if(D!=NODE_BUF_LAST->YesNextNode) {
                                           ;    Y = Y + 2
                                           ;  }
                                           
                                           ;  X->FnSeek(Y)
                                           ;  B = X->FnWriteBytes(2,NODE_BUF_NEW_1->DataOffset)
                                           ;  
                                           
                                           
                                           ;  NODE_BUF_NEW_1->NoNextNode = NODE_BUF_CURRENT->DataOffset
                                           
                 PSHS     D                ; OLine=641
                 PSHS     X                ; OLine=642
                 PSHS     Y                ; OLine=643
                 PSHS     U                ; OLine=644
                                           
                 PSHS     X                ;  StructureUsage X is FILE_IO
                                           
                 LBSR     ZOO_GATHER_INFO  ; OLine=648
                                           
                                           ;  Now we have collected all the information.
                                           ;  Build the new question node and new animal node.
                                           
                                           ;  The NEW_1 contains the question. For now we'll set
                                           ;  the YES link to the new animal and the NO link
                                           ;  to the last guess (CURRENT)
                                           
                 LEAX     NODE_BUF_NEW_1+6 
                 LBSR     STRLEN           ; OLine=658
                                           
                 ADDD     #5               ; OLine=660
                 LDX      ,S               ; OLine=661  FileIO pointer back to X
                 ADDD     12,X             
                 STD      NODE_BUF_NEW_1+2 
                 LDD      NODE_BUF_CURRENT+0 
                 STD      NODE_BUF_NEW_1+4 
                                           
                                           ;  If the user's answer is not "YES" for the new animal, swap
                                           ;  the Yes/No links
                                           
                 LDA      TEMP_A           ; OLine=670
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_16_1_INPUT
                                           ;  FLOW_A_16_1_INPUT:
                                           ;  polarity 0
                 CMPA     #'Y'             
                 LBNE     FLOW_A_16_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_16_OUTPUT_FALSE
                                           ;  FLOW_A_16_OUTPUT_FALSE:
                 LBRA     FLOW_A_16_OUTPUT_END 
FLOW_A_16_OUTPUT_TRUE:                           
                 LDD      NODE_BUF_NEW_1+2 
                 LDX      NODE_BUF_NEW_1+4 
                 STX      NODE_BUF_NEW_1+2 
                 STD      NODE_BUF_NEW_1+4 
FLOW_A_16_OUTPUT_END:                           
                                           
                 PULS     X                ; OLine=678  Restoring the FILE_IO
                                           
                                           ;  Append question node to end of zoo
                 LDU      #NODE_BUF_NEW_1  ;  StructureUsage U is ZOO_NODE
                 LBSR     APPEND_NODE      ; OLine=682
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_17_1_INPUT
                                           ;  FLOW_A_17_1_INPUT:
                                           ;  polarity 0
                 CMPB     #0               
                 LBEQ     FLOW_A_17_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_17_OUTPUT_FALSE
                                           ;  FLOW_A_17_OUTPUT_FALSE:
                 LBRA     FLOW_A_17_OUTPUT_END 
FLOW_A_17_OUTPUT_TRUE:                           
                 LBSR     OUT_OF_DISK_SPACE ; OLine=684
                 PULS     U                ; OLine=685
                 PULS     Y                ; OLine=686
                 PULS     X                ; OLine=687
                 PULS     D                ; OLine=688
                 RTS                       ; OLine=689
FLOW_A_17_OUTPUT_END:                           
                                           
                                           ;  Append new animal node to end of zoo
                 LDU      #NODE_BUF_NEW_2  ; OLine=693
                 LBSR     APPEND_NODE      ; OLine=694
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_18_1_INPUT
                                           ;  FLOW_A_18_1_INPUT:
                                           ;  polarity 0
                 CMPB     #0               
                 LBEQ     FLOW_A_18_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_18_OUTPUT_FALSE
                                           ;  FLOW_A_18_OUTPUT_FALSE:
                 LBRA     FLOW_A_18_OUTPUT_END 
FLOW_A_18_OUTPUT_TRUE:                           
                 LBSR     OUT_OF_DISK_SPACE ; OLine=696
                 PULS     U                ; OLine=697
                 PULS     Y                ; OLine=698
                 PULS     X                ; OLine=699
                 PULS     D                ; OLine=700
                 RTS                       ; OLine=701
FLOW_A_18_OUTPUT_END:                           
                                           
                                           ;  At this point the nodes were added successfully.
                                           ;  We need to change the link in the last question (LAST) to
                                           ;  point to the new question.
                                           
                 LDD      NODE_BUF_CURRENT+0 
                 LDY      NODE_BUF_LAST+0  
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_19_1_INPUT
                                           ;  FLOW_A_19_1_INPUT:
                                           ;  polarity 0
                 CMPD     NODE_BUF_LAST+2  
                 LBNE     FLOW_A_19_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_19_OUTPUT_FALSE
                                           ;  FLOW_A_19_OUTPUT_FALSE:
                 LBRA     FLOW_A_19_OUTPUT_END 
FLOW_A_19_OUTPUT_TRUE:                           
                 LEAY     2,Y              ; OLine=711
FLOW_A_19_OUTPUT_END:                           
                                           
                                           ;  Y points to the data offset of the link to change
                 JSR      [6,X]            
                                           
                 LEAU     NODE_BUF_NEW_1+0 
                 LDY      #2               ; OLine=718
                 JSR      [2,X]            
                                           
                 PULS     U                ; OLine=721
                 PULS     Y                ; OLine=722
                 PULS     X                ; OLine=723
                 PULS     D                ; OLine=724
                                           
                 RTS                       ;  --SubroutineContextEnds--
                                           
APPEND_NODE:                               ;  --SubroutineContextBegins--
                 PSHS     A                ; OLine=729
                 PSHS     Y                ; OLine=730
                 PSHS     U                ; OLine=731
                                           ;  StructureUsage U is ZOO_NODE
                                           ;  StructureUsage X is FILE_IO
                 LDY      12,X             
                 STY      0,U              ;  This is the new home
                 JSR      [6,X]            
                 PSHS     X                ; OLine=737
                 LEAX     6,U              
                 LBSR     STRLEN           ; OLine=739
                 PULS     X                ; OLine=740
                 ADDD     #5               ; OLine=741
                 TFR      D,Y              ; OLine=742
                 LEAU     2,U              
                 JSR      [2,X]            
                 PSHS     Y                ; OLine=745
                 SUBD     ,S++             ; OLine=746
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_20_1_INPUT
                                           ;  FLOW_A_20_1_INPUT:
                                           ;  polarity 0
                 CMPD     #0               
                 LBNE     FLOW_A_20_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_20_OUTPUT_FALSE
                                           ;  FLOW_A_20_OUTPUT_FALSE:
                 LDB      #1               ; OLine=750
                 LBRA     FLOW_A_20_OUTPUT_END 
FLOW_A_20_OUTPUT_TRUE:                           
                 LDB      #0               ; OLine=748
FLOW_A_20_OUTPUT_END:                           
                 PULS     U                ; OLine=752
                 PULS     Y                ; OLine=753
                 PULS     A                ; OLine=754
                 RTS                       ;  --SubroutineContextEnds--
                                           
OUT_OF_DISK_SPACE:                           ;  --SubroutineContextBegins--
                 PSHS     X                ; OLine=758
                 LDX      #MSG_OUT_OF_SPACE ; OLine=759
                 LBSR     PRINT_MESSAGE    ; OLine=760
                 PULS     X                ; OLine=761
                 RTS                       ;  --SubroutineContextEnds--
                                           
                                           ; </EditorTab>
                                           
                                           ; <EditorTab name="Zoo Functions">
                                           ; =======================================================================
                                           ;  ZOO DATABASE FUNCTIONS
                                           ; =======================================================================
                                           
LOAD_ZOO_NODE:                             ;  --SubroutineContextBegins--
                                           ;  StructureUsage X is FILE_IO 
                 PSHS     D                ; OLine=773
                 PSHS     Y                ; OLine=774
                 PSHS     U                ; OLine=775
                 LDU      #NODE_BUF_CURRENT ;  StructureUsage U is ZOO_NODE
                 STY      0,U              
                 JSR      [6,X]            
                 LEAU     2,U              ; OLine=779
                 LDY      #4               ; OLine=780
                 JSR      [0,X]            
                 LEAU     4,U              ; OLine=782
                 LDY      #1               ; OLine=783
                                           ;  FLOW_A_21_OUTPUT_BEGIN:
FLOW_A_21_OUTPUT_TRUE:                           
                 JSR      [0,X]            
                 LDA      ,U+              ; OLine=786
                                           ;   LBRA  FLOW_A_21_1_INPUT
                                           ;  FLOW_A_21_1_INPUT:
                                           ;  polarity 0
                 CMPA     #0               
                 LBNE     FLOW_A_21_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_21_OUTPUT_FALSE
                                           ;  FLOW_A_21_OUTPUT_FALSE:
                                           ;  FLOW_A_21_OUTPUT_END:
                                           
                 PULS     U                ; OLine=789
                 PULS     Y                ; OLine=790
                 PULS     D                ; OLine=791
                 RTS                       ;  --SubroutineContextEnds--
                                           
COPY_CURRENT_TO_LAST:                           ;  --SubroutineContextBegins--
                 PSHS     A                ; OLine=795
                 PSHS     X                ; OLine=796
                 PSHS     Y                ; OLine=797
                 PSHS     U                ; OLine=798
                 LDX      #NODE_BUF_CURRENT ; OLine=799
                 LDU      #NODE_BUF_LAST   ; OLine=800
                 LDY      #262             
                                           ;  FLOW_A_22_OUTPUT_BEGIN:
FLOW_A_22_OUTPUT_TRUE:                           
                 LDA      ,X+              ; OLine=803
                 STA      ,U+              ; OLine=804
                 LEAY     -1,Y             ; OLine=805
                                           ;   LBRA  FLOW_A_22_1_INPUT
                                           ;  FLOW_A_22_1_INPUT:
                                           ;  polarity 0
                 CMPY     #0               
                 LBNE     FLOW_A_22_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_22_OUTPUT_FALSE
                                           ;  FLOW_A_22_OUTPUT_FALSE:
                                           ;  FLOW_A_22_OUTPUT_END:
                 PULS     U                ; OLine=807
                 PULS     Y                ; OLine=808
                 PULS     X                ; OLine=809
                 PULS     A                ; OLine=810
                 RTS                       ;  --SubroutineContextEnds--
                                           
                                           ; DUMP_ZOO() { ; X=start, Y=num bytes
                                           ;    U = #$400
                                           ;    do {
                                           ;     A = ,X+
                                           ;     ,U+ = A
                                           ;     --Y
                                           ;    } while(Y!=0);
                                           ; }
                                           
                                           ; </EditorTab>
                                           
                                           ; <EditorTab name="Screen Functions">
                                           
CLEAR_SCREEN:                              ;  --SubroutineContextBegins--
                 PSHS     X                ; OLine=827
                 LDX      #$400            ; OLine=828
                 STX      SCREEN_CURSOR    ; OLine=829
FLOW_A_23_OUTPUT_BEGIN:                           
                                           ;   LBRA  FLOW_A_23_1_INPUT
                                           ;  FLOW_A_23_1_INPUT:
                                           ;  polarity 1
                 CMPX     #$600            
                 LBEQ     FLOW_A_23_OUTPUT_FALSE 
                                           ;   LBRA FLOW_A_23_OUTPUT_TRUE
                                           ;  FLOW_A_23_OUTPUT_TRUE:
                 STB      ,X+              ; OLine=831
                 LBRA     FLOW_A_23_OUTPUT_BEGIN 
FLOW_A_23_OUTPUT_FALSE:                           
                                           ;  FLOW_A_23_OUTPUT_END:
                 PULS     X                ; OLine=833
                 RTS                       ;  --SubroutineContextEnds--
                                           
SET_SCREEN_CURSOR:                           ;  --SubroutineContextBegins--
                 STY      SCREEN_CURSOR    ; OLine=837
                 RTS                       ;  --SubroutineContextEnds--
GET_SCREEN_CURSOR:                           ;  --SubroutineContextBegins--
                 LDY      SCREEN_CURSOR    ; OLine=840
                 RTS                       ;  --SubroutineContextEnds--
                                           
PRINT_MESSAGE:                             ;  --SubroutineContextBegins--
                 PSHS     B                ; OLine=844
                 PSHS     X                ; OLine=845
                                           
FLOW_A_24_OUTPUT_BEGIN:                           
                                           ;   LBRA  FLOW_A_24_1_INPUT
                                           ;  FLOW_A_24_1_INPUT:
                                           ;  polarity 0
                                           ;   LBRA FLOW_A_24_OUTPUT_TRUE
                                           ;  FLOW_A_24_OUTPUT_TRUE:
                 LDB      ,X+              ; OLine=848
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_25_1_INPUT
                                           ;  FLOW_A_25_1_INPUT:
                                           ;  polarity 0
                 CMPB     #0               
                 LBEQ     FLOW_A_24_OUTPUT_END ; CLEAN-JumpToJump- FLOW_A_25_OUTPUT_TRUE
                                           ;   LBRA FLOW_A_25_OUTPUT_FALSE
                                           ;  FLOW_A_25_OUTPUT_FALSE:
                 LBRA     FLOW_A_25_OUTPUT_END 
                                           ;  FLOW_A_25_OUTPUT_TRUE:
                 LBRA     FLOW_A_24_OUTPUT_END ; OLine=850     
FLOW_A_25_OUTPUT_END:                           
                 LBSR     PRINT_CHARACTER  ; OLine=852
                 LBRA     FLOW_A_24_OUTPUT_BEGIN 
                                           ;  FLOW_A_24_OUTPUT_FALSE:
FLOW_A_24_OUTPUT_END:                           
                                           
                 PULS     X                ; OLine=855
                 PULS     B                ; OLine=856
                 RTS                       ;  --SubroutineContextEnds--
                                           
PRINT_CHARACTER:                           ;  --SubroutineContextBegins--
                 PSHS     D                ; OLine=860
                 PSHS     U                ; OLine=861
                 PSHS     Y                ; OLine=862
                                           
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_26_1_INPUT
                                           ;  FLOW_A_26_1_INPUT:
                                           ;  polarity 0
                 CMPB     #13              
                 LBEQ     FLOW_A_26_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_26_OUTPUT_FALSE
                                           ;  FLOW_A_26_OUTPUT_FALSE:
                 LDU      #ASCIITRANS      ; OLine=867
                 LDB      B,U              ; OLine=868
                 LBSR     GET_SCREEN_CURSOR ; OLine=869
                 STB      ,Y+              ; OLine=870
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_27_1_INPUT
                                           ;  FLOW_A_27_1_INPUT:
                                           ;  polarity 0
                 CMPY     #$600            
                 LBGE     FLOW_A_27_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_27_OUTPUT_FALSE
                                           ;  FLOW_A_27_OUTPUT_FALSE:
                 LBRA     FLOW_A_27_OUTPUT_END 
FLOW_A_27_OUTPUT_TRUE:                           
                 LBSR     SCROLL           ; OLine=872
                 LEAY     -32,Y            ; OLine=873
FLOW_A_27_OUTPUT_END:                           
                 LBSR     SET_ScREEN_CURSOR ; OLine=875
                 LBRA     FLOW_A_26_OUTPUT_END 
FLOW_A_26_OUTPUT_TRUE:                           
                 LBSR     LINE_FEED        ; OLine=865
FLOW_A_26_OUTPUT_END:                           
                                           
                 PULS     Y                ; OLine=878
                 PULS     U                ; OLine=879
                 PULS     D                ; OLine=880
                 RTS                       ;  --SubroutineContextEnds--
                                           
LINE_FEED:                                 ;  --SubroutineContextBegins--
                 PSHS     D                ; OLine=884
                 PSHS     Y                ; OLine=885
                 LBSR     GET_SCREEN_CURSOR ; OLine=886
                 TFR      Y,D              ; OLine=887
                 TFR      B,A              ; OLine=888
                 ANDA     #31              ; OLine=889
                 LDB      #' '             ; OLine=890
                                           ;  FLOW_A_28_OUTPUT_BEGIN:
FLOW_A_28_OUTPUT_TRUE:                           
                 LBSR     PRINT_CHARACTER  ; OLine=892
                 INCA                      ; OLine=893
                                           ;   LBRA  FLOW_A_28_1_INPUT
                                           ;  FLOW_A_28_1_INPUT:
                                           ;  polarity 0
                 CMPA     #32              
                 LBNE     FLOW_A_28_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_28_OUTPUT_FALSE
                                           ;  FLOW_A_28_OUTPUT_FALSE:
                                           ;  FLOW_A_28_OUTPUT_END:
                 PULS     Y                ; OLine=895
                 PULS     D                ; OLine=896
                 RTS                       ;  --SubroutineContextEnds--
                                           
PRINT_HEX_DIGIT:                           ;  --SubroutineContextBegins--
                 PSHS     B                ; OLine=900
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_29_1_INPUT
                                           ;  FLOW_A_29_1_INPUT:
                                           ;  polarity 0
                 CMPB     #10              
                 LBLT     FLOW_A_29_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_29_OUTPUT_FALSE
                                           ;  FLOW_A_29_OUTPUT_FALSE:
                 SUBB     #10              ; OLine=904
                 ADDB     #'A'             ; OLine=905
                 LBRA     FLOW_A_29_OUTPUT_END 
FLOW_A_29_OUTPUT_TRUE:                           
                 ADDB     #'0'             ; OLine=902
FLOW_A_29_OUTPUT_END:                           
                 LBSR     PRINT_CHARACTER  ; OLine=907
                 PULS     B                ; OLine=908
                 RTS                       ;  --SubroutineContextEnds--
                                           
PRINT_HEX_WORD:                            ;  --SubroutineContextBegins--
                 PSHS     D                ; OLine=912
                 PSHS     D                ; OLine=913
                 TFR      A,B              ; OLine=914
                 LSRB                      ; OLine=915
                 LSRB                      ; OLine=916
                 LSRB                      ; OLine=917
                 LSRB                      ; OLine=918
                 LBSR     PRINT_HEX_DIGIT  ; OLine=919
                 TFR      A,B              ; OLine=920
                 ANDB     #$0F             ; OLine=921
                 LBSR     PRINT_HEX_DIGIT  ; OLine=922
                 PULS     D                ; OLine=923
                 TFR      B,A              ; OLine=924
                 LSRB                      ; OLine=925
                 LSRB                      ; OLine=926
                 LSRB                      ; OLine=927
                 LSRB                      ; OLine=928
                 LBSR     PRINT_HEX_DIGIT  ; OLine=929
                 TFR      A,B              ; OLine=930
                 ANDB     #$0F             ; OLine=931
                 LBSR     PRINT_HEX_DIGIT  ; OLine=932
                 PULS     D                ; OLine=933
                 RTS                       ;  --SubroutineContextEnds--
                                           
SCROLL:                                    ;  --SubroutineContextBegins--
                 PSHS     D                ; OLine=937
                 PSHS     X                ; OLine=938
                 LDX      #$400            ; OLine=939
                                           ;  FLOW_A_30_OUTPUT_BEGIN:
FLOW_A_30_OUTPUT_TRUE:                           
                 LDA      32,X             ; OLine=941
                 STA      ,x+              ; OLine=942
                                           ;   LBRA  FLOW_A_30_1_INPUT
                                           ;  FLOW_A_30_1_INPUT:
                                           ;  polarity 0
                 CMPX     #$600-32         
                 LBNE     FLOW_A_30_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_30_OUTPUT_FALSE
                                           ;  FLOW_A_30_OUTPUT_FALSE:
                                           ;  FLOW_A_30_OUTPUT_END:
                 LDA      #96              ; OLine=944
                                           ;  FLOW_A_31_OUTPUT_BEGIN:
FLOW_A_31_OUTPUT_TRUE:                           
                 STA      ,x+              ; OLine=946
                                           ;   LBRA  FLOW_A_31_1_INPUT
                                           ;  FLOW_A_31_1_INPUT:
                                           ;  polarity 0
                 CMPX     #$600            
                 LBNE     FLOW_A_31_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_31_OUTPUT_FALSE
                                           ;  FLOW_A_31_OUTPUT_FALSE:
                                           ;  FLOW_A_31_OUTPUT_END:
                 PULS     x                ; OLine=948
                 PULS     D                ; OLine=949
                 RTS                       ;  --SubroutineContextEnds--
                                           
INPUT_STRING:                              ;  --SubroutineContextBegins--
                                           
                 PSHS     X                ; OLine=954
                 PSHS     U                ; OLine=955
                 PSHS     Y                ; OLine=956
                 PSHS     D                ; OLine=957
                                           
                 LBSR     GET_SCREEN_CURSOR ; OLine=959
                                           
                 PSHS     X                ; OLine=961
                 LEAU     -1,U             ; OLine=962
                 PSHS     U                ; OLine=963
                 TFR      X,D              ; OLine=964
                 ADDD     ,S               ; OLine=965
                 STD      ,S               ; OLine=966
                                           
                 LDU      #ASCIITRANS      ; OLine=968
                                           
FLOW_A_32_OUTPUT_BEGIN:                           
                                           ;   LBRA  FLOW_A_32_1_INPUT
                                           ;  FLOW_A_32_1_INPUT:
                                           ;  polarity 0
                                           ;   LBRA FLOW_A_32_OUTPUT_TRUE
                                           ;  FLOW_A_32_OUTPUT_TRUE:
                                           
                 LDA      #128             ; OLine=972
                 STA      ,Y               ; OLine=973
                 JSR      [$A000]          ; OLine=974
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_33_1_INPUT
                                           ;  FLOW_A_33_1_INPUT:
                                           ;  polarity 0
                 LBEQ     FLOW_A_32_OUTPUT_BEGIN ; CLEAN-JumpToJump- FLOW_A_33_OUTPUT_TRUE
                                           ;   LBRA FLOW_A_33_OUTPUT_FALSE
                                           ;  FLOW_A_33_OUTPUT_FALSE:
                 LBRA     FLOW_A_33_OUTPUT_END 
                                           ;  FLOW_A_33_OUTPUT_TRUE:
                 LBRA     FLOW_A_32_OUTPUT_BEGIN ; OLine=976 
FLOW_A_33_OUTPUT_END:                           
                                           
                                           ;  Process ENTER
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_34_1_INPUT
                                           ;  FLOW_A_34_1_INPUT:
                                           ;  polarity 0
                 CMPA     #13              
                 LBEQ     FLOW_A_34_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_34_OUTPUT_FALSE
                                           ;  FLOW_A_34_OUTPUT_FALSE:
                 LBRA     FLOW_A_34_OUTPUT_END 
FLOW_A_34_OUTPUT_TRUE:                           
                 LDA      #0               ; OLine=981
                 STA      ,X               ; OLine=982
                 LBSR     SET_SCREEN_CURSOR ; OLine=983
                 PULS     X                ; OLine=984
                 PULS     X                ; OLine=985
                                           
                 PULS     D                ; OLine=987
                 PULS     Y                ; OLine=988
                 PULS     U                ; OLine=989
                 PULS     X                ; OLine=990
                 RTS                       ; OLine=991
FLOW_A_34_OUTPUT_END:                           
                                           
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_35_1_INPUT
                                           ;  FLOW_A_35_1_INPUT:
                                           ;  polarity 0
                 CMPA     #8               
                 LBEQ     FLOW_A_35_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_35_OUTPUT_FALSE
                                           ;  FLOW_A_35_OUTPUT_FALSE:
                 LBRA     FLOW_A_35_OUTPUT_END 
FLOW_A_35_OUTPUT_TRUE:                           
                                           ;  Make there is something to erase
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_36_1_INPUT
                                           ;  FLOW_A_36_1_INPUT:
                                           ;  polarity 0
                 CMPX     2,S              
                 LBGT     FLOW_A_36_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_36_OUTPUT_FALSE
                                           ;  FLOW_A_36_OUTPUT_FALSE:
                 LBRA     FLOW_A_32_OUTPUT_BEGIN ; CLEAN-JumpToJump- FLOW_A_36_OUTPUT_END
FLOW_A_36_OUTPUT_TRUE:                           
                 LEAX     -1,X             ; OLine=997
                 LDA      #96              ; OLine=998
                 STA      ,Y               ; OLine=999
                 LEAY     -1,Y             ; OLine=1000
                                           ;  FLOW_A_36_OUTPUT_END:
                 LBRA     FLOW_A_32_OUTPUT_BEGIN ; OLine=1002
FLOW_A_35_OUTPUT_END:                           
                                           
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_37_1_INPUT
                                           ;  FLOW_A_37_1_INPUT:
                                           ;  polarity 0
                 CMPX     ,S               
                 LBEQ     FLOW_A_32_OUTPUT_BEGIN ; CLEAN-JumpToJump- FLOW_A_37_OUTPUT_TRUE
                                           ;   LBRA FLOW_A_37_OUTPUT_FALSE
                                           ;  FLOW_A_37_OUTPUT_FALSE:
                 LBRA     FLOW_A_37_OUTPUT_END 
                                           ;  FLOW_A_37_OUTPUT_TRUE:
                                           ;  No more room in buffer
                 LBRA     FLOW_A_32_OUTPUT_BEGIN ; OLine=1007
FLOW_A_37_OUTPUT_END:                           
                                           
                                           ;  Store key in buffer
                 STA      ,X+              ; OLine=1011
                                           
                                           ;  Echo key to screen     
                 LDA      A,U              ; OLine=1014
                 STA      ,Y+              ; OLine=1015
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_38_1_INPUT
                                           ;  FLOW_A_38_1_INPUT:
                                           ;  polarity 0
                 CMPY     #$600            
                 LBEQ     FLOW_A_38_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_38_OUTPUT_FALSE
                                           ;  FLOW_A_38_OUTPUT_FALSE:
                 LBRA     FLOW_A_32_OUTPUT_BEGIN ; CLEAN-JumpToJump- FLOW_A_38_OUTPUT_END
FLOW_A_38_OUTPUT_TRUE:                           
                 LBSR     SCROLL           ; OLine=1017
                 LEAY     -32,Y            ; OLine=1018
                                           ;  FLOW_A_38_OUTPUT_END:
                                           
                 LBRA     FLOW_A_32_OUTPUT_BEGIN 
                                           ;  FLOW_A_32_OUTPUT_FALSE:
                                           ;  FLOW_A_32_OUTPUT_END:
                                           
                                           ;   RTS ; --SubroutineContextEnds-- CLEAN-OrphanReturn- 
                                           
ASCIITRANS:                                ; OLine=1025
                 fcb      32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32 ; OLine=1026
                 fcb      32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32 ; OLine=1027
                 fcb      96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111 ; OLine=1028
                 fcb      112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127 ; OLine=1029
                 fcb      64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79 ; OLine=1030
                 fcb      80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95 ; OLine=1031
                 fcb      0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 ; OLine=1032
                 fcb      16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31 ; OLine=1033
                                           
                                           ; </EditorTab>
                                           
                                           
                                           ; <EditorTab name="String Functions">
                                           
                                           ;  STRING FUNCTIONS
STRCPY:                                    ;  --SubroutineContextBegins--
                 PSHS     A                ; OLine=1042  TOPHER REGSAVE(A,X,Y)
                 PSHS     X                ; OLine=1043
                 PSHS     Y                ; OLine=1044
                                           ;  FLOW_A_39_OUTPUT_BEGIN:
FLOW_A_39_OUTPUT_TRUE:                           
                 LDA      ,X+              ; OLine=1046
                 STA      ,Y+              ; OLine=1047
                                           ;   LBRA  FLOW_A_39_1_INPUT
                                           ;  FLOW_A_39_1_INPUT:
                                           ;  polarity 0
                 CMPA     #0               
                 LBNE     FLOW_A_39_OUTPUT_TRUE 
                                           ;   LBRA FLOW_A_39_OUTPUT_FALSE
                                           ;  FLOW_A_39_OUTPUT_FALSE:
                                           ;  FLOW_A_39_OUTPUT_END:
                 PULS     Y                ; OLine=1049  REGRESTORE()
                 PULS     X                ; OLine=1050
                 PULS     A                ; OLine=1051
                 RTS                       ;  --SubroutineContextEnds--
                                           
STRLEN:                                    ;  --SubroutineContextBegins--
                 PSHS     X                ; OLine=1055
                 PSHS     Y                ; OLine=1056
                 LDY      #0               ; OLine=1057
FLOW_A_40_OUTPUT_BEGIN:                           
                                           ;   LBRA  FLOW_A_40_1_INPUT
                                           ;  FLOW_A_40_1_INPUT:
                                           ;  polarity 0
                                           ;   LBRA FLOW_A_40_OUTPUT_TRUE
                                           ;  FLOW_A_40_OUTPUT_TRUE:
                 LDA      ,X+              ; OLine=1059
                                           ;  polarity 1
                                           ;   LBRA  FLOW_A_41_1_INPUT
                                           ;  FLOW_A_41_1_INPUT:
                                           ;  polarity 0
                 CMPA     #0               
                 LBEQ     FLOW_A_40_OUTPUT_END ; CLEAN-JumpToJump- FLOW_A_41_OUTPUT_TRUE
                                           ;   LBRA FLOW_A_41_OUTPUT_FALSE
                                           ;  FLOW_A_41_OUTPUT_FALSE:
                 LBRA     FLOW_A_41_OUTPUT_END 
                                           ;  FLOW_A_41_OUTPUT_TRUE:
                 LBRA     FLOW_A_40_OUTPUT_END ; OLine=1061 
FLOW_A_41_OUTPUT_END:                           
                 LEAY     1,Y              ; OLine=1063
                 LBRA     FLOW_A_40_OUTPUT_BEGIN 
                                           ;  FLOW_A_40_OUTPUT_FALSE:
FLOW_A_40_OUTPUT_END:                           
                 TFR      Y,D              ; OLine=1065
                 PULS     Y                ; OLine=1066
                 PULS     X                ; OLine=1067
                 RTS                       ;  --SubroutineContextEnds--
                                           
                                           ; </EditorTab>
                                           
                                           ; <EditorTab name="Messages">
MSG_STUMP:                                 ; OLine=1073
                                           ;  NTCA("YOU STUMPED ME! LET'S ADD YOUR\nANIMAL TO THE ZOO. WHAT WERE\nYOU THINKING OF?\n")
                 fcc      "YOU STUMPED ME! LET'S ADD YOUR" 
                 fcb      13               
                 fcc      "ANIMAL TO THE ZOO. WHAT WERE" 
                 fcb      13               
                 fcc      "YOU THINKING OF?" 
                 fcb      13               
                                           
                 fcb      0                
MSG_YN:                                    ; OLine=1076
                                           ;  NTCA("YES OR NO (Y/N): "
                 fcc      "YES OR NO (Y/N): " 
                 fcb      0                
                                           
MSG_QUESTION_MARK:                           ; OLine=1079
                                           ;  NTCA("?\n")
                 fcc      "?"              
                 fcb      13               
                                           
                 fcb      0                
MSG_ISIT:                                  ; OLine=1082
                                           ;  NTCA("IS IT A ")
                 fcc      "IS IT A "       
                 fcb      0                
                                           
MSG_I_GOT_IT:                              ; OLine=1085
                                           ;  NTCA("\nI GOT IT!\n\n")
                 fcb      13               
                 fcc      "I GOT IT!"      
                 fcb      13               
                 fcb      13               
                                           
                 fcb      0                
MSG_WELCOME:                               ; OLine=1088
                                           ;  NTCA("WELCOME TO THE COCO ZOO!\n\n")
                 fcc      "WELCOME TO THE COCO ZOO!" 
                 fcb      13               
                 fcb      13               
                                           
                 fcb      0                
MSG_INSTRUCTIONS:                           ; OLine=1091
                                           ;  NTCA("THINK OF AN ANIMAL AND I WILL\nTRY TO GUESS IT.\n\n")
                 fcc      "THINK OF AN ANIMAL AND I WILL" 
                 fcb      13               
                 fcc      "TRY TO GUESS IT." 
                 fcb      13               
                 fcb      13               
                                           
                 fcb      0                
MSG_GIVE:                                  ; OLine=1094
                                           ;  NTCA("ENTER A QUESTION THAT SEPARATES\nMY GUESS FROM YOUR ANIMAL\n")
                 fcc      "ENTER A QUESTION THAT SEPARATES" 
                 fcb      13               
                 fcc      "MY GUESS FROM YOUR ANIMAL" 
                 fcb      13               
                                           
                 fcb      0                
MSG_FROM:                                  ; OLine=1097
                                           ;  NTCA(" FROM ")
                 fcc      " FROM "         
                 fcb      0                
                                           
MSG_WHAT:                                  ; OLine=1100
                                           ;  NTCA("WHAT WOULD THE ANSWER BE FOR\nYOUR ANIMAL (Y/N)? ")
                 fcc      "WHAT WOULD THE ANSWER BE FOR" 
                 fcb      13               
                 fcc      "YOUR ANIMAL (Y/N)? " 
                 fcb      0                
                                           
MSG_OUT_OF_SPACE:                           ; OLine=1103
                                           ;  NTCA("SORRY! NO MORE ROOM IN THE\nZOO FOR YOUR ANIMAL!\n")
                 fcc      "SORRY! NO MORE ROOM IN THE" 
                 fcb      13               
                 fcc      "ZOO FOR YOUR ANIMAL!" 
                 fcb      13               
                                           ; </EditorTab>
                 fcb      0                
                                           
                                           ; <EditorTab name="Initial Zoo">
                                           ; =======================================================================
                                           ;  INITIAL ZOO
                                           ; =======================================================================
                                           
RAM_DRIVE_ROM:                             ; OLine=1112
                 fcc      'COCO ZOO'       ; OLine=1113  Preamble for disk-file
ZOO_NODE_1:                                ; OLine=1114
                 fcw      ZOO_NODE_2-RAM_DRIVE_ROM ; OLine=1115
                 fcw      ZOO_NODE_3-RAM_DRIVE_ROM ; OLine=1116
                                           ;  NTCA("DOES IT LIVE ON LAND")
                 fcc      "DOES IT LIVE ON LAND" 
                 fcb      0                
ZOO_NODE_2:                                ; OLine=1118
                 fcw      0                ; OLine=1119
                 fcw      0                ; OLine=1120
                                           ;  NTCA("COW")
                 fcc      "COW"            
                 fcb      0                
ZOO_NODE_3:                                ; OLine=1122
                 fcw      0                ; OLine=1123
                 fcw      0                ; OLine=1124
                                           ;  NTCA("SHARK")   
                 fcc      "SHARK"          
                 fcb      0                
ZOO_END:                                   ; OLine=1126
                                           ; </EditorTab>
                                           
                 '                         ; OLine=1129
                                           
