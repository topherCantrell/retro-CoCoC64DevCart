
processor 6809
; build-command java Blend zoo.asm z2.asm
; build-command a09 -LZ2.LST z2.asm

; ------- To Do -----
; The CFLASH I/O routines

; ------- Future Enhancements -----
; When you enter a question, the game should strip off any trailing "?"
; A show-zoo facility to show all nodes in the zoo would be handy

; ------- Lessons learned for book -------

; Talk about inheritance and polymorphism and such with FILE_IO and
; CFLASH_FILE_IO

; Unit testing is so very important. Lots of functions seem to work
; except I didn't make sure the current-position was updated and 
; I didn't make sure registers were preserved and un-needed returns
; were correct (that I later came to use). Develop lots of little
; scaffolding code that won't get used in production, but will get used
; along the way. DON'T DELETE IT ... just comment it out or move it. You'll
; test again later.

; Debug facilities like register-dump and memory view is vital. Develop
; those for the reader.

; It would be nice if there were a tool-facility to manage stack variables
; to keep track of things like "4,S" automatically.

; In making functions generic, you'll be stacking and unstacking a lot of things
; needlessly to ensure nothing gets changed. The alternative is to force the
; caller to preserve data across calls. This is equally viable and preferrable
; in speed-critical situations.

; Good debug techniques: increment screen memory in and out of a function so you can
; see the call tree. Also increment after steps in a suspect function. Or just uncomment 
; lines of a function one by one ... especially the calls.
; Substitue indirect calls temporarily with absolutes.
; Stress the importance of unit-testing a method or set of methods completely. Throw-away
; debug code ... but just comment it out! You'll find later that you suspect a function
; is failing even though you thought you tested it fully. Stick in the increment-while-true
; to see if you are getting to a spot. Store values to the screen memory for inspection.

; With all the indexed addressing, the LEA is most needed. It's power becomes clear.
; Talk about this instruction when you talk about indexed addressing.

; The LEA is used to add and subtract from the index registers even though it
; doesn't look like a standard add/subtract. It takes longer too ... longer
; instruction.
; Comment that this is a LEA even though it doesn't look like one!

; When you first start working on a platform you'll spend a lot of time creating
; librarys of things (strings, screen, etc) that will pay off in the future.
; Don't worry if you find yourself straying from the course of your game ... remember
; you are writing lots of future games too.

; Took a while to code this game because I created a lot of library
; functions (strings, screen, etc) that will pay off in my next
; application (show NavalWar, for instance)

; Observations:
; Not a lot of local variables to work with in assembler. You have to either
; frame-up the stack or create lots of these globals.

; Talk about abstraction. We hid the screen-cursor behind functions. Advantages?
; Disadvantages? We didn't hide the CurrentSize and CurrentPosition. They are more
; concrete ... talk about this.

; Would be nice if the tool could figure out data context so we could drop '#' and
; use '&' when we need to.

;<EditorTab name="ZOO_NODE">
StructureDefinition ZOO_NODE {
  2 DataOffset
  2 YesNextNode
  2 NoNextNode
  256 Text
}
;</EditorTab>

;<EditorTab name="FILE_IO">
StructureDefinition FILE_IO {
  2 FnReadBytes  ; X=this, Y=number, U=buffer
  2 FnWriteBytes ; X=this, Y=number, U=buffer
  2 FnFlush      ; X=this
  2 FnSeek       ; X=this, Y=position
  2 FnGetSize    ; X=this, Y<=size
; --------
  2 CurrentPosition
  2 CurrentSize
}

StructureDefinition CFLASH_FILE_IO : FILE_IO {
; Inheriting all of FILE_IO's members first
  1   Drive
  2   StartSector
  2   CurrentOffsetInSector
  2   CurrentCachedSector
  1   Dirty
  512 SectorCache
}
;</EditorTab>

;<EditorTab name="RAM">

; BASIC scratch memory takes from $0000 to $0400
; Screen sits at $0400 - $04FF
; Stack runs from $04FF - $1000
; Program lives from $1000 to $1FFF
; Variable memory lives from $2000 to $2FFF
; RAMDRIVE eats the remainder of RAM from $3000 on

  org $2000
NODE_BUF_LAST    rmb  sizeof(ZOO_NODE)        StructureUsage NODE_BUF_LAST     is ZOO_NODE
NODE_BUF_CURRENT rmb  sizeof(ZOO_NODE)        StructureUsage NODE_BUF_CURRENT  is ZOO_NODE
NODE_BUF_NEW_1   rmb  sizeof(ZOO_NODE)        StructureUsage NODE_BUF_NEW_1    is ZOO_NODE
NODE_BUF_NEW_2   rmb  sizeof(ZOO_NODE)        StructureUsage NODE_BUF_NEW_2    is ZOO_NODE
ZOO_IO           rmb  sizeof(CFLASH_FILE_IO)  StructureUsage CFLASH_FILE_IO    is CFLASH_FILE_IO
INPUT_BUFFER     rmb  16
SCREEN_CURSOR    rmb  2
TEMP_A           rmb  2

  org $3000
RAM_DRIVE        rmb  $1000 ; At least 4K left in a 16K system


;</EditorTab>

;<EditorTab name="START">

 ;org $C000
  org $1000

  fcc "COCOOS" ; Preamble checked by the RAMLOADER. Execution begins at $1006.

  S = #$1000

  B = #96
  CLEAR_SCREEN()

  ;X = #ZOO_IO
  ;INIT_RAM_FILE()

  ; The RAMLOADER leaves the last-loaded-sector in Y
  LEAY 1,Y           ; Assume the data area is right after the program
  X = #ZOO_IO
  INIT_CFLASH_FILE()
  
  X = #MSG_WELCOME
  PRINT_MESSAGE()
  
  while(true) {
    X = #ZOO_IO
    PLAY_ZOO()
  }

;</EditorTab>

;<EditorTab name="CFLASH FILE I/O">
;=======================================================================
; CFLASH FILE IO FUNCTIONS
;=======================================================================

INIT_CFLASH_FILE() { ; X=this
  StructureUsage X is CFLASH_FILE_IO

  X->StartSector = Y

  B = #0
  X->Drive = B
  X->Dirty = B
 
  D = #CFLASH_READ_BYTES
  X->FnReadBytes = D
  D = #CFLASH_WRITE_BYTES
  X->FnWriteBytes = D
  D = #CFLASH_FLUSH
  X->FnFlush = D
  D = #CFLASH_SEEK
  X->FnSeek = D
  D = #CFLASH_GET_SIZE
  X->FnGetSize = D
  D = #0
  X->CurrentPosition = D

  ; Set the size to max and then use the read-bytes to find
  ; 3 consecutive 0's. Then end point is the middle 0.
  ; Back off the size (if found 3)  
    
  D = $FFFF
  X->CurrentSize = D  
  
}

ROM_OS_READ_SECTOR   equ  $C2F8 
ROM_OS_WRITE_SECTOR  equ  $C322

CFLASH_FLUSH() { ; X=this, B<=status

   StructureUsage X is CFLASH_FILE_IO

   B = X->Dirty
   if(B==0) {     
     return
   }

   PSHS  A
   PSHS  X
   PSHS  Y
   PSHS  U  
  
   D = #0
   X->Dirty = B
   X->CurrentOffsetInSector = D
   X->CurrentCachedSector = Y

   B = X->Drive
  
   TFR Y,D
   ADDD X->StartSector
   TFR D,Y
   LEAU X->SectorCache
   X = #0

   ; B=Drive, X=SectorMSW, Y=SectorLSW, U=Buffer (return status in B)  
   JSR ROM_OS_WRITE_SECTOR
  
   PULS  U
   PULS  Y
   PULS  X 
   PULS  A

}

CACHE_SECTOR() { ; X=this, Y=sector offset, B<=status

  CFLASH_FLUSH() ; Make sure the cache is written out (if dirty)

  StructureUsage X is CFLASH_FILE_IO

  PSHS  A
  PSHS  X
  PSHS  Y
  PSHS  U  
  
  D = #0
  X->Dirty = B
  X->CurrentOffsetInSector = D
  X->CurrentCachedSector = Y

  B = X->Drive
  
  TFR Y,D
  ADDD X->StartSector
  TFR D,Y
  LEAU X->SectorCache
  X = #0

  ; B=Drive, X=SectorMSW, Y=SectorLSW, U=Buffer (return status in B)  
  JSR ROM_OS_READ_SECTOR
  
  PULS  U
  PULS  Y
  PULS  X 
  PULS  A 
  
}

CFLASH_READ_BYTES() { ; X=this, Y=number of bytes, U=destination, Y<=bytes read
  StructureUsage X is CFLASH_FILE_IO
}

CFLASH_WRITE_BYTES() { ; X=this, Y=number of bytes, U=destination, Y<=bytes wrote
  StructureUsage X is CFLASH_FILE_IO
}

CFLASH_SEEK() {
  StructureUsage X is CFLASH_FILE_IO
}

CFLASH_GET_SIZE() {
  StructureUsage X is CFLASH_FILE_IO 
  Y = X->CurrentSize
}

;</EditorTab>

;<EditorTab name="RAM FILE I/O">
;=======================================================================
; RAM FILE IO FUNCTIONS
;=======================================================================

INIT_RAM_FILE() { ; X=this
  StructureUsage X is FILE_IO

  PSHS D

  PSHS X
  PSHS Y
  PSHS U
  ; Copy RAM_DRIVE from ROM to RAM
  X = #RAM_DRIVE_ROM
  Y = #RAM_DRIVE
  U = #ZOO_END-RAM_DRIVE_ROM
  do {
    A = ,X+
    ,Y+ = A
    --U
  } while(U!=0);
  PULS U
  PULS Y
  PULS X

  D = #RAM_READ_BYTES
  X->FnReadBytes = D
  D = #RAM_WRITE_BYTES
  X->FnWriteBytes = D
  D = #RAM_FLUSH
  X->FnFlush = D
  D = #RAM_SEEK
  X->FnSeek = D
  D = #RAM_GET_SIZE
  X->FnGetSize = D
  D = #0
  X->CurrentPosition = D
  D = #ZOO_END - RAM_DRIVE_ROM
  X->CurrentSize = D  
  PULS D
}

RAM_READ_BYTES() { ; X=this, Y=number of bytes, U=destination, Y<=bytes read
  StructureUsage X is FILE_IO

  PSHS D  
  PSHS Y
  PSHS U

  PSHS X
  
  ; Limit Y to what we have
  D = X->CurrentSize
  SUBD X->CurrentPosition
  STD 4,S     ; ?? Return value?
  TFR Y,D
  if(D>4,S) { 
    D = 4,S
  }
  4,S = D
  TFR D,Y  

  ; Get the absolute RAM pointer to X
  D = X->CurrentPosition
  ADDD #RAM_DRIVE
  TFR D,X

  ; Do the copy
  do {
    A = ,X+
    ,U+ = A
    --Y
  } while(Y!=0);
  
  D = 4,S

  PULS X  
  ADDD X->CurrentPosition
  X->CurrentPosition = D
 
  PULS U
  PULS Y  
  PULS D

}

RAM_WRITE_BYTES() { ; X=this, Y=number of bytes, U=destination, Y<=bytes wrote
  StructureUsage X is FILE_IO

  PSHS D
  PSHS Y
  PSHS U
  PSHS X
  
  ; Get the absolute RAM pointer to X
  D = X->CurrentPosition
  ADDD #RAM_DRIVE
  TFR D,X
  
  D = #0
  2,S = D

  ; Do the copy
  do {
    A = ,U+
    ,X+ = A       
    if(A!=-1,X) {      
      break;   
    }
    ++2,S
    --Y
  } while(Y!=0);

  PULS X
  D = 2,S
  ADDD X->CurrentPosition
  X->CurrentPosition = D
  if(D>X->CurrentSize) {
    X->CurrentSize = D
  }
  PULS U
  PULS Y 
  PULS D
  
}

RAM_FLUSH() {  
  ; Nothing to do for RAM files  
}

RAM_SEEK() {
  StructureUsage X is FILE_IO
  if(Y>X->CurrentSize) {
    Y = X->CurrentSize
  }
  X->CurrentPosition = Y  
}

RAM_GET_SIZE() {
  StructureUsage X is FILE_IO
  Y = X->CurrentSize  
}
;</EditorTab>

;<EditorTab name="PlayZoo()">

PLAY_ZOO() { ; X=FILE_IO

  Y = #8 ; First ZOO node (after preamble)  

  PSHS X
  X = #MSG_INSTRUCTIONS
  PRINT_MESSAGE()
  PULS X

  while(true) {

    LOAD_ZOO_NODE()

    U = #NODE_BUF_CURRENT
    StructureUsage U is ZOO_NODE
    D = U->YesNextNode	

    if(D==0) {
      // Animal node
	  PSHS X
	  	  	  
	  X = #MSG_ISIT	  
	  PRINT_MESSAGE()          
	  LEAX  U->Text	  
	  PRINT_MESSAGE()
	  X = #MSG_QUESTION_MARK
	  PRINT_MESSAGE()
	  
	  X = #MSG_YN
	  PRINT_MESSAGE()
	
	  PSHS U	  
	  X = #INPUT_BUFFER
	  U = #3	  
	  INPUT_STRING()
          LINE_FEED()
	  PULS U	  

          A = ,X	  
 	  if(A==#'Y') { 	                         
            X = #MSG_I_GOT_IT
            PRINT_MESSAGE()  
            PULS X         
            return
 	  } else if(A==#'N') {
            PULS X
 	    ADD_TO_ZOO()
            return
 	  } 

          PULS X

    } else {
      // Question node
	  PSHS X	   

	  LEAX  U->Text  
	  PRINT_MESSAGE()	  

	  X = #MSG_QUESTION_MARK
	  PRINT_MESSAGE()

	  X = #MSG_YN
	  PRINT_MESSAGE()
	
	  PSHS U	  
	  X = #INPUT_BUFFER
	  U = #4	  
	  INPUT_STRING()
          LINE_FEED()
	  PULS U	

	  A = ,X	  
 	  if(A==#'Y') {
            COPY_CURRENT_TO_LAST()
 	    Y = U->YesNextNode
 	  } else if(A==#'N') {
            COPY_CURRENT_TO_LAST()
 	    Y = U->NoNextNode
 	  } 

	  PULS  X
    }

  }  

}
;</EditorTab>

;<EditorTab name="AddToZoo()">
ZOO_GATHER_INFO() {

; This function gathers all the data about the user's new animal:
; NODE_BUF_NEW_1 <= the new question (0's for links)
; NODE_BUF_NEW_2 <= the new animal (0's for links)
; TEMP_A <= the user's answer character ('Y' or 'N')

  PSHS D
  PSHS X
  PSHS Y
  PSHS U

  LDB  #96
  CLEAR_SCREEN()
  
  X = #MSG_STUMP
  PRINT_MESSAGE()

  U = #NODE_BUF_NEW_2 StructureUsage U is ZOO_NODE
  D = #0
  U->DataOffset = D
  U->YesNextNode = D
  U->NoNextNode = D
  LEAX U->Text
  U=#32
  INPUT_STRING()
  LINE_FEED()

  X=#MSG_GIVE
  PRINT_MESSAGE()
  B=#'('
  PRINT_CHARACTER()
  U = #NODE_BUF_CURRENT  
  LEAX U->Text
  PRINT_MESSAGE()
  X=#MSG_FROM
  PRINT_MESSAGE()
  U = #NODE_BUF_NEW_2
  LEAX U->Text
  PRINT_MESSAGE()
  B=#')'
  PRINT_CHARACTER()
  B=#':'
  PRINT_CHARACTER()
  LINE_FEED()

  U = #NODE_BUF_NEW_1
  D = #0
  U->DataOffset = D
  U->YesNextNode = D
  U->NoNextNode = D
  LEAX U->Text
  U= #sizeof(ZOO_NODE->Text)
  INPUT_STRING()
  LINE_FEED()

  X=#MSG_WHAT
  PRINT_MESSAGE();

  X=#INPUT_BUFFER
  U=#4
  INPUT_STRING()
  LINE_FEED()

  ; Hang on to answer for a bit
  A = ,X
  TEMP_A = A

  PULS U
  PULS Y
  PULS X
  PULS D

}

ADD_TO_ZOO() {

; ZOO_GATHER_INFO()
;
; D = STRLEN(NODE_BUF_NEW_1->Text)
; NODE_BUF_NEW_1->YesNextNode = D + 5 + X->CurrentSize
; NODE_BUF_NEW_1->NoNextNode = NODE_BUF_CURRENT->DataOffset

; if(TEMP_A != 'Y') {
;    D = NODE_BUF_NEW_1->YesNextNode
;    NODE_BUF_NEW_1->YesNextNode = NODE_BUF_NEW_1->NoNextNode
;    NODE_BUF_NEW_1->NoNextNode = D
; }
;
; B = APPEND_NODE(NODE_BUF_NEW_1)
; if(B==0) {
;   return
;   OUT_OF_DISK_SPACE()
; }
;
; B = APPEND_NODE(NODE_BUF_NEW_2)
; if(B==0) {
;   return
;   OUT_OF_DISK_SPACE()
; }
;
; D = NODE_BUF_CURRENT->DataOffset
; Y = NODE_BUF_LAST->DataOffset
; if(D!=NODE_BUF_LAST->YesNextNode) {
;   Y = Y + 2
; }
;
; X->FnSeek(Y)
; B = X->FnWriteBytes(2,NODE_BUF_NEW_1->DataOffset)
; 


; NODE_BUF_NEW_1->NoNextNode = NODE_BUF_CURRENT->DataOffset

  PSHS D  
  PSHS X
  PSHS Y
  PSHS U

  PSHS X StructureUsage X is FILE_IO

  ZOO_GATHER_INFO()  

  ; Now we have collected all the information.
  ; Build the new question node and new animal node.
  
  ; The NEW_1 contains the question. For now we'll set
  ; the YES link to the new animal and the NO link
  ; to the last guess (CURRENT)
  
  LEAX NODE_BUF_NEW_1->Text  
  STRLEN()

  ADDD #5
  X = ,S ; FileIO pointer back to X
  ADDD X->CurrentSize
  NODE_BUF_NEW_1->YesNextNode = D  
  D = NODE_BUF_CURRENT->DataOffset
  NODE_BUF_NEW_1->NoNextNode = D
 
  ; If the user's answer is not "YES" for the new animal, swap
  ; the Yes/No links

  A = TEMP_A
  if(A!=#'Y') {
    D = NODE_BUF_NEW_1->YesNextNode
    X = NODE_BUF_NEW_1->NoNextNode
    NODE_BUF_NEW_1->YesNextNode = X
    NODE_BUF_NEW_1->NoNextNode = D
  }
    
  PULS X ; Restoring the FILE_IO

  ; Append question node to end of zoo
  U = #NODE_BUF_NEW_1 StructureUsage U is ZOO_NODE
  APPEND_NODE() 
  if(B==0) {
    OUT_OF_DISK_SPACE()
    PULS U
    PULS Y
    PULS X
    PULS D  
    return
  }

  ; Append new animal node to end of zoo
  U = #NODE_BUF_NEW_2
  APPEND_NODE() 
  if(B==0) {
    OUT_OF_DISK_SPACE()
    PULS U
    PULS Y
    PULS X
    PULS D  
    return
  }

  ; At this point the nodes were added successfully.
  ; We need to change the link in the last question (LAST) to
  ; point to the new question.
  
  D = NODE_BUF_CURRENT->DataOffset 
  Y = NODE_BUF_LAST->DataOffset  
  if(D!=NODE_BUF_LAST->YesNextNode) {
    LEAY 2,Y    
  }

  ; Y points to the data offset of the link to change
  JSR [X->FnSeek]
  
  LEAU NODE_BUF_NEW_1->DataOffset
  Y = #2
  JSR [X->FnWriteBytes]

  PULS U
  PULS Y
  PULS X
  PULS D  
  
} 

APPEND_NODE() { ; X=FILE_IO, U=ZOO_NODE, B<=0 if out-of-space, or 1 if OK
  PSHS A
  PSHS Y
  PSHS U
  StructureUsage U is ZOO_NODE
  StructureUsage X is FILE_IO
  Y = X->CurrentSize
  U->DataOffset = Y  ; This is the new home
  JSR  [X->FnSeek]  
  PSHS X
  LEAX U->Text
  STRLEN()
  PULS X
  ADDD #5
  TFR D,Y
  LEAU U->YesNextNode  
  JSR [X->FnWriteBytes]
  PSHS Y
  SUBD ,S++
  if(D!=0) {
    B = #0
  } else {
    B = #1
  }  
  PULS U
  PULS Y
  PULS A
}

OUT_OF_DISK_SPACE() {
  PSHS X
  X = #MSG_OUT_OF_SPACE
  PRINT_MESSAGE()
  PULS X
}

;</EditorTab>

;<EditorTab name="Zoo Functions">
;=======================================================================
; ZOO DATABASE FUNCTIONS
;=======================================================================

LOAD_ZOO_NODE() { ; X=FILE_IO, Y=NodeOffset
  StructureUsage X is FILE_IO 
  PSHS D
  PSHS Y
  PSHS U  
  U = #NODE_BUF_CURRENT StructureUsage U is ZOO_NODE
  U->DataOffset = Y
  JSR [X->FnSeek]  
  LEAU 2,U
  Y = #4  
  JSR [X->FnReadBytes]
  LEAU 4,U
  Y = #1
  do {
    JSR [X->FnReadBytes]
    A = ,U+ 
  } while(A!=0);

  PULS U
  PULS Y
  PULS D
}

COPY_CURRENT_TO_LAST() {
   PSHS A
   PSHS X
   PSHS Y
   PSHS U
   X = #NODE_BUF_CURRENT
   U = #NODE_BUF_LAST
   Y = #sizeof(ZOO_NODE) 
   do {
     A = ,X+
     ,U+ = A
     --Y      
   } while(Y!=0);
   PULS U
   PULS Y
   PULS X
   PULS A
}

;DUMP_ZOO() { ; X=start, Y=num bytes
;   U = #$400
;   do {
;    A = ,X+
;    ,U+ = A
;    --Y
;   } while(Y!=0);
;}

;</EditorTab>

;<EditorTab name="Screen Functions">

CLEAR_SCREEN() { ; B = fill
  PSHS X
  X = #$400
  SCREEN_CURSOR = X
  while(X!=#$600) {
    ,X+ = B
  }
  PULS X
}

SET_SCREEN_CURSOR() { ; Y = ScreenCoordinate
  SCREEN_CURSOR = Y
}
GET_SCREEN_CURSOR() { ; Y<= ScreenCoordinate
  Y = SCREEN_CURSOR
}

PRINT_MESSAGE() { ; X=Message
  PSHS  B
  PSHS  X

  while(true) {
    B = ,X+
    if(B==0) {
      break;    
    }
    PRINT_CHARACTER()
  }  

  PULS  X
  PULS  B
}

PRINT_CHARACTER() { ; B = character
  PSHS D
  PSHS U
  PSHS Y

  if(B==13) {
    LINE_FEED()
  } else {
    LDU  #ASCIITRANS
    LDB  B,U
    GET_SCREEN_CURSOR()
    STB  ,Y+
    if(Y>=#$600) {
      SCROLL()
      LEAY -32,Y  
    }
    SET_ScREEN_CURSOR()
  }

  PULS Y
  PULS U
  PULS D
}

LINE_FEED() { ; Y=ScreenCoordinate to adjust
  PSHS  D
  PSHS  Y
  GET_SCREEN_CURSOR()
  TFR   Y,D
  TFR   B,A  
  ANDA  #31
  LDB   #' '
  do {   
    PRINT_CHARACTER() 
    INCA
  } while(A!=32);
  PULS  Y
  PULS  D
}

PRINT_HEX_DIGIT() { ; B = value 
  PSHS B  
  if(B<10) {
    ADDB  #'0'	
  } else {
    SUBB  #10
    ADDB  #'A'
  }
  PRINT_CHARACTER()
  PULS B
}

PRINT_HEX_WORD() { ; D = value, Y = SCREEN
  PSHS  D
  PSHS  D
  TFR   A,B
  LSRB
  LSRB
  LSRB
  LSRB
  PRINT_HEX_DIGIT()
  TFR   A,B
  ANDB  #$0F
  PRINT_HEX_DIGIT()
  PULS  D
  TFR  B,A  
  LSRB
  LSRB
  LSRB
  LSRB
  PRINT_HEX_DIGIT()
  TFR   A,B
  ANDB  #$0F
  PRINT_HEX_DIGIT()
  PULS D
}

SCROLL() {
  PSHS D
  PSHS X
  x = #$400  
  do {
    A = 32,X
    ,x+ = A
  } while(X!=#$600-32);
  A = #96 
  do {
    ,x+ = A  
  } while(X!=#$600);
  PULS x
  PULS D
}

INPUT_STRING() { ; X=Buffer, U=MaxSize

   PSHS  X
   PSHS  U
   PSHS  Y
   PSHS  D

   GET_SCREEN_CURSOR()

   PSHS X
   LEAU -1,U
   PSHS U
   TFR  X,D
   ADDD ,S
   STD  ,S
   
   U = #ASCIITRANS   

   while(true) {

     A=#128
     ,Y = A
     JSR [$A000]
     if(ZERO-SET) {
       continue;
     }

     ; Process ENTER
     if(A==13) {
       A = #0
       ,X = A
       SET_SCREEN_CURSOR()
       PULS X
       PULS X

       PULS D
       PULS Y
       PULS U
       PULS X
       return
     }

     if(A==8) {
       ; Make there is something to erase
       if(X>2,S) {
         --X
         A=#96
         ,Y = A
         --Y
       }
       continue	   
     }

     if(X==,S) {
       ; No more room in buffer
       continue
     }

     ; Store key in buffer
     ,X+ = A

     ; Echo key to screen	 
     A = A,U	 
     ,Y+ = A
     if(Y==#$600) {
       SCROLL()         
       LEAY -32,Y
     }

   }

}

ASCIITRANS:
        fcb     32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
        fcb       32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
        fcb     96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111
        fcb       112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127
        fcb     64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79
        fcb       80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95
        fcb     0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
        fcb       16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31 

;</EditorTab>


;<EditorTab name="String Functions">

; STRING FUNCTIONS
STRCPY() { ; X=source, Y=destination
  PSHS A   ; TOPHER REGSAVE(A,X,Y)
  PSHS X
  PSHS Y
  do {
    A = ,X+
    ,Y+ = A
  } while(A!=0);
  PULS Y  ; REGRESTORE()
  PULS X
  PULS A
}

STRLEN() { ; X=source, D<=length
  PSHS X
  PSHS Y
  Y = #0
  while(true) {
    A = ,X+
    if(A==0) {
      break;
    }
    ++Y
  }
  TFR Y,D
  PULS Y
  PULS X
}

;</EditorTab>

;<EditorTab name="Messages">
MSG_STUMP:        
        NTCA("YOU STUMPED ME! LET'S ADD YOUR\nANIMAL TO THE ZOO. WHAT WERE\nYOU THINKING OF?\n")

MSG_YN:
        NTCA("YES OR NO (Y/N): "

MSG_QUESTION_MARK:
        NTCA("?\n")

MSG_ISIT:
        NTCA("IS IT A ")

MSG_I_GOT_IT:
        NTCA("\nI GOT IT!\n\n")

MSG_WELCOME: 
        NTCA("WELCOME TO THE COCO ZOO!\n\n")

MSG_INSTRUCTIONS:
        NTCA("THINK OF AN ANIMAL AND I WILL\nTRY TO GUESS IT.\n\n")

MSG_GIVE:
        NTCA("ENTER A QUESTION THAT SEPARATES\nMY GUESS FROM YOUR ANIMAL\n")

MSG_FROM:
        NTCA(" FROM ")

MSG_WHAT:
        NTCA("WHAT WOULD THE ANSWER BE FOR\nYOUR ANIMAL (Y/N)? ")

MSG_OUT_OF_SPACE:
        NTCA("SORRY! NO MORE ROOM IN THE\nZOO FOR YOUR ANIMAL!\n")
;</EditorTab>

;<EditorTab name="Initial Zoo">
;=======================================================================
; INITIAL ZOO
;=======================================================================

RAM_DRIVE_ROM:
    fcc   'COCO ZOO'  ; Preamble for disk-file
ZOO_NODE_1:
    fcw   ZOO_NODE_2-RAM_DRIVE_ROM
    fcw   ZOO_NODE_3-RAM_DRIVE_ROM
    NTCA("DOES IT LIVE ON LAND")
ZOO_NODE_2:
    fcw   0
    fcw   0
    NTCA("COW")
ZOO_NODE_3:
    fcw   0
    fcw   0
    NTCA("SHARK")   
ZOO_END:          
;</EditorTab>

                                                      '

