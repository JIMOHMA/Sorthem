;; NAME:: MUYIDEEN A. JIMOH 
;; STUDENT #:: 001327114
;; MAC ID:: jimohma 
;; COURSE:: COMP SCI 2XA3 
;; FINAL PROJECT FALL 2018 

%include "asm_io.inc"

SECTION .data
InitialConfigMssg: db " Initial Configuration",0
FinalConfigMssg: db " Final Configuration",0
baseSorthem: db "XXXXXXXXXXXXXXXXXXXXXXX",0
err1: db "Incorrect number of command line arguments",0
err2: db "Length of argument is not 1",0
err3: db "Parameter is not btw 1 and 10. Enter argument from 2 to 9!",0
globalPegAddress: dd 0,0,0,0,0,0,0,0,0,0      ; gloabl array/holder of disks

SECTION .bss
pegslot: resd 9
spaces: resd 1
counter: resd 1
numbCharacter: resd 1
numDisk: resd 1
tempValue: resd 1
globalDiskSize: resd 1        ; global holder of the original number of disks 

SECTION .text
   global  asm_main

sorthem: 
   enter 0,0 
   pusha

   mov ebx, [ebp+8]          ; address of our of our array 
   mov ecx, [ebp+12]         ; address of our parameter which is the number of disks
   sub ecx, dword 1          ;; reduce the disk size by one ==> so ecx has n-1 disks before next recursion
   mov edi, ecx               ;; local disk size for a recursive call and storage of the number of disks 
   mov esi, ebx               ;; pointing the array address to the esi for later reference 

   cmp ecx, dword 1          ;; compairing the disk size to one so as to stop the receusive call. 
                              ;; basically a base case for the sorting procedure 
   je term_Cond
   push ecx                   ;; number of disk is being pushed onto the stack for recursion
   add ebx, dword 4           ;; ebx now holds the address of the array from the second number in the array 
   push ebx                   ;; now the array address from second positio has been pushed 
   call sorthem               ;; recursive call on the new array and disk size           

   ;; this is where we always return after finish sorting a disk size and wanna sort the next one
   ;; initializing the counter to 0 for sorting purpose... 
   mov [counter], dword 0
   mov edx, edi
   SORT_LOOP:
      inc dword [counter]
      mov edx, [esi]       ;; location of element in first position TO COMPARE
      mov ecx, [esi+4]     ;; location of element in thee second position TO COMPARE
      cmp edx, ecx         ;; comparing numbers together to determine if swapping should occur
      jl SWAP_NUMBERS
      jmp CONTINUE

      SWAP_NUMBERS:
         mov [esi+4], edx  
         mov [esi], ecx
         add esi, dword 4
         cmp [counter], edi 
         jl SORT_LOOP
         jmp FINISH_SORT 

      CONTINUE:
         add esi, dword 4     ;; this sets the next position for the to be compared with another in the array
         cmp [counter], edi       ;; comparing counter to edi; our number of disks 
         jl SORT_LOOP

   FINISH_SORT:
      add esp, 8                 ;; cleaning of stack cause of the first two pushes 
      jmp end_sorthem

   term_Cond:
      ;; ideally the last number in the array is always sorted so we don't do anything to it.
      mov edx, [esi]
      mov ecx, [esi+4]
      cmp edx, ecx

      jl first_swap
      jmp end_sorthem

      first_swap:
         mov [esi+4], edx  
         mov [esi], ecx

end_sorthem: 

   mov eax, [globalDiskSize]
   push eax                   ;; pushing the number of actual disks for showp to display 
   mov ebx, globalPegAddress
   push ebx                   ;; pushing the sorted array on the stack  
   call showp                 ;; showing the configuration after a complete sort of a semi-array
   
   add esp, 8                 ;; reset the stack 
   popa 
   leave
   ret 

showp:
   enter 0,0 ; enter subroutine
   pusha ; save all registers

   mov ebx, [ebp+8]              ;; address of our of our peg[0]  i.e ebx = peg
   mov eax, [ebp+12]         ; address of our parameter which is the number of disks 
   mov [pegslot], ebx            ;; pointing the reserved peg to our array configuration
   mov [numDisk], eax     ;; the numebr of disk is now stored into numDisk

   ;; idea here is to try and get the number of the peg.... so if we have 
   ;; 4 disks e.g [4,3,1,2,0,0,0,0,0]  we wanna access the 4th number which is the #2
   ;; and then access the 3rd number which is #3 and then the 2nd and 1st respectively. This 
   ;; is done this way because the display of the peg is from the right to the left. 
   ;; Therefor to get the number at ith position with n number of disks, we do the 
   ;; following --> [peg + position] where position = n * (n - counter) 
   ;; where counter is a variable iniatially initialized to 1. 
   ;; so for the first iteration of the above array which represents 4 disks i.e n = 4,
   ;; we would be for getting the number '2'.................
   ;; so n = 4, i = 1 and position = 4 * (4 - 1) = 12
   ;; Therefore [peg + 12] gets us the position of the '2' on the array and 
   ;; [peg + 8] gets '1', [peg + 4] gets us '3' and so on. 
   mov ecx, dword 0   ;; intializing our counter ecx = 0
   SHAPE_LOOP:
      inc ecx   ;; increments ecx each time so we can check if iteration is complete
      mov eax, 4            ;; storing 4 in eax which would be used to later find the index of the number i.e 4bytes increment (line 137)
      mov [tempValue], dword 0      ;; initiallizing tempValue to 0
      mov edi, [numDisk]
      mov [tempValue], edi    ;; then copying the number of disks into tempValue 
      sub [tempValue], ecx          ;; counter value is subtracted from the tempValue 
      mul dword [tempValue]         ;; since eax => number of disks, we are doing numDisk * tempValue 
      mov edi, eax                    ;; edi is now holding the tempValue 
      add edi, dword [pegslot]       ;; and edi now is a pointer to the adrress location of the number in our array 
      mov eax, dword [edi]    ;; hopefully this contains the value size of a disk 
      mov [numbCharacter], eax

   SHOW_SPACES: 
      mov [spaces], dword 11          ;; intializing the number of space to 9 
      mov edi, [numbCharacter]
      sub [spaces], edi  ;; this is used to calculate the number of spaces needed before writing the 'o's 
      
      mov [counter], dword 0        ;; intializing counter to 0 
      mov eax, [spaces]

   SPACE_LOOP: 
      inc dword [counter]
      mov eax, ' '
      call print_char              ;; prints the spaces needed before displaying any character 
      mov edi, [spaces]
      cmp [counter], edi       ;; exits this loop once counter is greater than number of spaces 
      jb SPACE_LOOP

      ;; AFTER DONE PRINTING SPACES 
      ;; we wanna display the 'o's 
      mov [counter], dword 0       ;; also initializing the counter to 0 
   CHAR_LOOP:
      inc dword [counter]
      mov eax, 'o'
      call print_char
      mov edi, [numbCharacter]
      cmp [counter], edi   ;; extst loop once we've printed all the characterd needed 
      jb CHAR_LOOP

      ;; AFTER ALL THE CHARACTERS ARE DISPLAYED, WE FOLLOW IT WITH '|' 
      ;; then with more characters 'o' and more spaces 
      mov eax, '|' 
      call print_char

      mov [counter], dword 0       ;; also initializing the counter to 0 
   CHAR_LOOP2:
      inc dword [counter]
      mov eax, 'o'
      call print_char
      mov edi, [numbCharacter]
      cmp [counter], edi   ;; extst loop once we've printed all the characterd needed 
      jb CHAR_LOOP2

      mov [counter], dword 0        ;; intializing counter to 0 
   SPACE_LOOP2: 
      inc dword [counter]
      mov eax, ' '
      call print_char              ;; prints the spaces needed before displaying any character 
      mov edi, [spaces]
      cmp [counter], edi       ;; exits this loop once counter is greater than number of spaces 
      jb SPACE_LOOP2 

      ;; at this point we should have displayed a line which should look sort of like this 
      ;; "_______oo|oo_______" given than the number is '2'
      cmp ecx, [numDisk]    ;; comparing our counter ecx to the number of disks
      call print_nl        ;; makes sure next display is on the next line
      jb SHAPE_LOOP        ;; next iteration happens if counter is less than the number of disks

      mov eax, baseSorthem    ;; displays the bottom stuffs "XXXXXXXXXXXXXXXXXXXXXXX"
      call print_string
      call print_nl
      call print_nl

      call read_char             ;; used for getting a continuation signal from user 

end_showp:
   popa                  ; restore all registers
   leave
   ret

asm_main:
   enter 0,0 ; enter subroutine
   pusha ; save all registers

   mov eax, dword [ebp+8]  ; argc
   cmp eax, dword 2 ;;checks to make sure that # of command arguments (argc) is 2
   jne ERR1 ;; jumps to error function1 to display error and terminate 

   ; so we have the right number of arguments
   mov ebx, dword [ebp+12]  ; address of argv[]
   mov eax, dword [ebx+4]   ; argv[1]  EAX POINTING TO THE THE argv[1]
   
	;; check the first 2 bytes to get the lenght of the argv[1] ----- must be one 
   mov bl, byte [eax]       ; 1st byte of argv[1]
   try1: 
      cmp bl, byte 0  ;; checking if first byte is a null character
      ;; byte 1 is okat i.e not null
      jne try2
      jmp ERR1 

   try2: ;;CHECKS THE last BYTE OF argv[1] to see if it's a null
      mov bl, byte [eax+1]
      cmp bl, byte 0
      jne ERR2   ;; MEANS THE LENGTH OF ARGV[1] IS NOT 1
      ;;if you get here it is the case that we have on only one parameter with a length of 1

      ;;now we check if it's a digit from 2 to 9 
   S1:  
      mov bl, byte [eax]
      cmp bl, byte '2'
      jb ERR3
      ;; it is the case that byte is above or equal to '2'
      cmp bl, byte '9'
      ja ERR3
      ;; it is the case that byte is below or equal to '9'

      ;; now we know we have the right argument from command line 
      ;; so we make the digit into a number
      sub bl, '0'
      mov ecx, 0

      ;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      mov cl, bl   ; so ecx holds the digit
      mov edi, ecx   ;; edi holds the number of disks now 
      mov [globalDiskSize], ecx  ;; storing the actual disk size into a global variable for the first time 
      ;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

      ;; if you get here it is the case that 2 <= parameter <=9 and is a number ofcourse
   S2:

      push ecx                      ;; pushin the number onto the stack so rconf can use it to generate init confifguration
      mov eax, globalPegAddress      ;; makes eax point to the starting index of peg
      push eax                      ;; pushed the peg to stack 
      call rconf
      call print_nl
      mov eax, InitialConfigMssg
      call print_string
      call print_nl
      call showp 

      ;; at this point the initial ocnfiguration should be displayed by showp already 
      ;; now we can shuffle the configuration to make sure they are ordered ascending order 
   S3: 
      call sorthem      ;; calling this sorthem the current array on the stack along with the size of the disc 

      mov eax, FinalConfigMssg
      call print_string
      call print_nl
      call showp

      add esp, 8
      jmp asm_main_end

   ERR1:
      mov eax, err1   ;; moves the error message 1 into register a in order to be displayed 
      call print_string ;; prints the error mssg 1 to the consolr
      call print_nl  ;; prints a new line
      jmp asm_main_end

   ERR2:
      mov eax, err2   ;; error display for length of parameter not equal to 1 
      call print_string ;; prints the error mssg 1 to the consolr
      call print_nl  ;; prints a new line
      jmp asm_main_end
      
   ERR3:
      mov eax, err3 ;; error display for number not from 2 to 9 
      call print_string
      call print_nl
      jmp asm_main_end

asm_main_end:
  popa         ;; restore all registers
  leave
  ret