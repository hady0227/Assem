1. Show an example of a base-index operand in 32-bit mode.

Answer:
mov eax, [ebx+esi]


2. Show an example of a base-index-displacement operand in 32-bit mode.

Answer:
mov eax, [ebx+esi+8]


3. Suppose a two-dimensional array of doublewords has three logical rows and four logical columns. Write an expression using ESI and EDI that addresses the third column in the second row. (Numbering for rows and columns starts at zero.)

Answer:
mov esi, 1 * (4 * TYPE myArray)
mov edi, 2
mov eax, myArray[esi+edi*4]


4. Write instructions using CMPSW that compare two arrays of 16-bit values named sourcew and targetw.

Answer:
cld
mov esi, OFFSET sourcew
mov edi, OFFSET targetw
mov ecx, LENGTHOF sourcew

repe cmpsw
jne ArraysDifferent
jmp CompareDone

ArraysDifferent:
; Arrays differ

CompareDone:


5. Write instructions that use SCASW to scan for the 16-bit value 0100h in an array named wordArray, and copy the offset of the matching member into the EAX register.

Answer:
cld
mov edi, OFFSET wordArray
mov ecx, LENGTHOF wordArray
mov ax, 0100h

jecxz NotFound
repne scasw
jne NotFound

lea eax, [edi-2]
jmp ScanDone

NotFound:
mov eax, -1

ScanDone:


6. Use the Str_compare procedure to determine the larger of two input strings and write it to the console window.

Answer:
INVOKE Str_compare, ADDR string1, ADDR string2
ja PrintString1

mov edx, OFFSET string2
jmp PrintSelected

PrintString1:
mov edx, OFFSET string1

PrintSelected:
call WriteString
call Crlf


7. Show how to call the Str_trim procedure and remove all trailing "@" characters from a string.

Answer:
INVOKE Str_trim, ADDR myString, '@'
cld


8. Modify the Str_ucase procedure from the Irvine32 library so it changes all characters to lower case.

Answer:
Str_lcase PROC USES eax esi,
    pString:PTR BYTE

    mov esi, pString

L1:
    mov al, [esi]
    cmp al, 0
    je  L3

    cmp al, 'A'
    jb  L2
    cmp al, 'Z'
    ja  L2

    or BYTE PTR [esi], 00100000b

L2:
    inc esi
    jmp L1

L3:
    ret

Str_lcase ENDP

INVOKE Str_lcase, ADDR myString


9. Create a 64-bit version of the Str_trim procedure.

Answer:
Str_trim PROC
    mov r8, rcx

FindEnd:
    cmp BYTE PTR [r8], 0
    je  TrimLoop
    inc r8
    jmp FindEnd

TrimLoop:
    cmp r8, rcx
    je  SetNull

    cmp BYTE PTR [r8-1], dl
    jne SetNull

    dec r8
    jmp TrimLoop

SetNull:
    mov BYTE PTR [r8], 0
    ret

Str_trim ENDP


10. Show an example of a base-index operand in 64-bit mode.

Answer:
mov rax, [rbx+rsi]


11. Assuming that EBX contains a row index into a two-dimensional array of 32-bit integers named myArray and EDI contains the index of a column, write a single statement that moves the content of the given array element into the EAX register.

Answer (assuming EBX contains the row's byte offset):
mov eax, myArray[ebx+edi*4]


12. Assuming that RBX contains a row index into a two-dimensional array of 64-bit integers named myArray and RDI contains the index of a column, write a single statement that moves the content of the given array element into the RAX register.

Answer (assuming RBX contains the row's byte offset):
mov rax, myArray[rbx+rdi*8]
