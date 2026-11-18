1. Improved Str_copy Procedure

The Str_copy procedure shown in this chapter does not limit the number of characters to be copied. Create a new version (named Str_copyN) that receives an additional input parameter indicating the maximum number of characters to be copied.

Answer:
Str_copyN PROC USES eax ecx esi edi,
    pSource:PTR BYTE,
    pTarget:PTR BYTE,
    maxChars:DWORD

    mov esi, pSource
    mov edi, pTarget
    mov ecx, maxChars

SCN_Loop:
    test ecx, ecx
    jz SCN_Terminate

    mov al, [esi]
    test al, al
    jz SCN_Terminate

    mov [edi], al
    inc esi
    inc edi
    dec ecx
    jmp SCN_Loop

SCN_Terminate:
    mov BYTE PTR [edi], 0
    ret
Str_copyN ENDP

INVOKE Str_copyN, ADDR sourceStr, ADDR targetStr, 8


2. Str_concat Procedure

Write a procedure named Str_concat that concatenates a source string to the end of a target string. Sufficient space must exist in the target string to accommodate the new characters. Pass pointers to the source and target strings.

Answer:
Str_concat PROC USES eax esi edi,
    pTarget:PTR BYTE,
    pSource:PTR BYTE

    mov edi, pTarget

SCT_FindEnd:
    cmp BYTE PTR [edi], 0
    je SCT_CopyStart
    inc edi
    jmp SCT_FindEnd

SCT_CopyStart:
    mov esi, pSource

SCT_Copy:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    test al, al
    jnz SCT_Copy
    ret
Str_concat ENDP

INVOKE Str_concat, ADDR targetStr, ADDR sourceStr


3. Str_remove Procedure

Write a procedure named Str_remove that removes n characters from a string. Pass a pointer to the position in the string where the characters are to be removed. Pass an integer specifying the number of characters to remove.

Answer:
Str_remove PROC USES eax ecx esi edi,
    pPosition:PTR BYTE,
    removeCount:DWORD

    mov edi, pPosition
    mov esi, edi
    mov ecx, removeCount

SR_Skip:
    test ecx, ecx
    jz SR_Copy
    cmp BYTE PTR [esi], 0
    je SR_Copy
    inc esi
    dec ecx
    jmp SR_Skip

SR_Copy:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    test al, al
    jnz SR_Copy
    ret
Str_remove ENDP

INVOKE Str_remove, ADDR target[3], 4


4. Str_find Procedure

Write a procedure named Str_find that searches for the first matching occurrence of a source string inside a target string and returns the matching position. The input parameters should be a pointer to the source string and a pointer to the target string. If a match is found, the procedure sets the Zero flag and EAX points to the matching position in the target string. Otherwise, the Zero flag is clear and EAX is undefined.

Answer:
Str_find PROC USES edx esi edi,
    pSource:PTR BYTE,
    pTarget:PTR BYTE

    mov edi, pTarget

SF_Try:
    mov esi, pSource
    mov edx, edi

SF_Compare:
    mov al, [esi]
    test al, al
    jz SF_Found

    cmp BYTE PTR [edx], 0
    je SF_Missing

    cmp al, [edx]
    jne SF_Next

    inc esi
    inc edx
    jmp SF_Compare

SF_Next:
    inc edi
    jmp SF_Try

SF_Found:
    mov eax, edi
    cmp eax, eax
    ret

SF_Missing:
    xor eax, eax
    cmp eax, 1
    ret
Str_find ENDP

INVOKE Str_find, ADDR source, ADDR target
jnz notFound
mov pos, eax


5. Str_nextWord Procedure

Write a procedure called Str_nextWord that scans a string for the first occurrence of a certain delimiter character and replaces the delimiter with a null byte. If the delimiter is found, the Zero flag is set and EAX contains the offset of the next character beyond the delimiter. Otherwise, the Zero flag is clear and EAX is undefined.

Answer:
Str_nextWord PROC USES edx esi,
    pString:PTR BYTE,
    delimiter:BYTE

    mov esi, pString
    mov dl, delimiter

SNW_Loop:
    mov al, [esi]
    test al, al
    jz SNW_Missing

    cmp al, dl
    je SNW_Found

    inc esi
    jmp SNW_Loop

SNW_Found:
    mov BYTE PTR [esi], 0
    lea eax, [esi+1]
    cmp eax, eax
    ret

SNW_Missing:
    xor eax, eax
    cmp eax, 1
    ret
Str_nextWord ENDP

INVOKE Str_nextWord, ADDR target, ',' 
jnz notFound


6. Constructing a Frequency Table

Write a procedure named Get_frequencies that constructs a character frequency table. Input to the procedure should be a pointer to a string and a pointer to an array of 256 doublewords initialized to all zeros. Each array position is indexed by its corresponding ASCII code.

Answer:
Get_frequencies PROC USES eax esi edi,
    pString:PTR BYTE,
    pTable:PTR DWORD

    mov esi, pString
    mov edi, pTable

GF_Loop:
    movzx eax, BYTE PTR [esi]
    test eax, eax
    jz GF_Done

    inc DWORD PTR [edi+eax*4]
    inc esi
    jmp GF_Loop

GF_Done:
    ret
Get_frequencies ENDP

INVOKE Get_frequencies, ADDR target, ADDR freqTable


7. Sieve of Eratosthenes

Create a 65,000-element array and display all primes between 2 and 65,000. Declare the array in an uninitialized data segment and use STOSB to fill it with zeros.

Answer:
LIMIT = 65000

.data?
sieve BYTE LIMIT DUP(?)

.code
BuildSieve PROC USES eax ebx ecx edx edi
    cld
    mov edi, OFFSET sieve
    mov ecx, LIMIT
    xor eax, eax
    rep stosb

    mov BYTE PTR sieve[0], 1
    mov ebx, 2

BS_Candidate:
    mov eax, ebx
    mul ebx
    cmp eax, LIMIT
    ja BS_Done

    cmp BYTE PTR sieve[ebx-1], 0
    jne BS_Next

    mov edx, eax

BS_Mark:
    mov BYTE PTR sieve[edx-1], 1
    add edx, ebx
    cmp edx, LIMIT
    jbe BS_Mark

BS_Next:
    inc ebx
    jmp BS_Candidate

BS_Done:
    ret
BuildSieve ENDP

PrintPrimes PROC USES eax ebx
    mov ebx, 2

PP_Loop:
    cmp BYTE PTR sieve[ebx-1], 0
    jne PP_Next

    mov eax, ebx
    call WriteDec
    mov al, ' '
    call WriteChar

PP_Next:
    inc ebx
    cmp ebx, LIMIT
    jbe PP_Loop
    call Crlf
    ret
PrintPrimes ENDP


8. Bubble Sort

Add an exchange flag to the BubbleSort procedure. Set it to 1 whenever a pair of values is exchanged within the inner loop. Use it to exit the sort early if no exchanges occur during a complete pass.

Answer:
BubbleSort PROC USES eax ecx esi,
    pArray:PTR SDWORD,
    itemCount:DWORD

    LOCAL exchanged:DWORD

    mov ecx, itemCount
    cmp ecx, 2
    jb BUB_Done
    dec ecx

BUB_Outer:
    mov exchanged, 0
    mov esi, pArray
    push ecx

BUB_Inner:
    mov eax, [esi]
    cmp eax, [esi+4]
    jle BUB_NoSwap
    xchg eax, [esi+4]
    mov [esi], eax
    mov exchanged, 1

BUB_NoSwap:
    add esi, 4
    loop BUB_Inner

    pop ecx
    cmp exchanged, 0
    je BUB_Done
    loop BUB_Outer

BUB_Done:
    ret
BubbleSort ENDP


9. Binary Search

Rewrite the binary search procedure using registers for mid, first, and last. Add comments to clarify the registers’ usage.

Answer:
OPTION PROLOGUE:NONE
OPTION EPILOGUE:NONE

BinarySearch PROC
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; ECX = array base
    ; EDX = search value
    ; ESI = first index
    ; EDI = last index
    ; EBX = mid index

    mov ecx, [ebp+8]
    mov edi, [ebp+12]
    test edi, edi
    jz BIN_Missing
    dec edi
    xor esi, esi
    mov edx, [ebp+16]

BIN_Loop:
    cmp esi, edi
    jg BIN_Missing

    mov eax, edi
    sub eax, esi
    shr eax, 1
    add eax, esi
    mov ebx, eax

    mov eax, [ecx+ebx*4]
    cmp eax, edx
    je BIN_Found
    jl BIN_Right

    lea edi, [ebx-1]
    jmp BIN_Loop

BIN_Right:
    lea esi, [ebx+1]
    jmp BIN_Loop

BIN_Found:
    mov eax, ebx
    jmp BIN_Done

BIN_Missing:
    mov eax, -1

BIN_Done:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    mov esp, ebp
    pop ebp
    ret 12
BinarySearch ENDP

OPTION PROLOGUE:PrologueDef
OPTION EPILOGUE:EpilogueDef


10. Letter Matrix

Create a procedure that generates a four-by-four matrix of randomly chosen capital letters. Each letter must have a 50% probability of being a vowel. Write a test program that calls your procedure five times and displays each matrix.

Answer:
GenerateMatrix PROC USES eax ebx esi,
    pMatrix:PTR BYTE

    mov esi, pMatrix
    xor ebx, ebx

GM_Loop:
    mov eax, 2
    call RandomRange
    test eax, eax
    jz GM_Vowel

    mov eax, LENGTHOF consonants
    call RandomRange
    mov al, consonants[eax]
    jmp GM_Store

GM_Vowel:
    mov eax, LENGTHOF vowels
    call RandomRange
    mov al, vowels[eax]

GM_Store:
    mov [esi+ebx], al
    inc ebx
    cmp ebx, 16
    jb GM_Loop
    ret
GenerateMatrix ENDP

DisplayMatrix PROC USES eax ebx esi,
    pMatrix:PTR BYTE

    mov esi, pMatrix
    xor ebx, ebx

DM_Loop:
    mov al, [esi+ebx]
    call WriteChar
    mov al, ' '
    call WriteChar

    inc ebx
    test ebx, 3
    jnz DM_Next
    call Crlf

DM_Next:
    cmp ebx, 16
    jb DM_Loop
    ret
DisplayMatrix ENDP

; Call five times:
mov ebx, 5
LM_Loop:
    INVOKE GenerateMatrix, ADDR matrix
    INVOKE DisplayMatrix, ADDR matrix
    call Crlf
    dec ebx
    jnz LM_Loop


11. Letter Matrix/Sets with Vowels

Generate a random four-by-four letter matrix in which each letter has a 50% probability of being a vowel. Traverse each row, column, and diagonal. Display only four-letter sets containing exactly two vowels.

Answer:
DisplaySetIfTwo PROC USES eax ebx ecx esi edi,
    pStart:PTR BYTE,
    stepSize:DWORD

    mov esi, pStart
    mov edi, stepSize
    xor ebx, ebx
    mov ecx, 4

DST_Count:
    mov al, [esi]
    cmp al, 'A'
    je DST_Vowel
    cmp al, 'E'
    je DST_Vowel
    cmp al, 'I'
    je DST_Vowel
    cmp al, 'O'
    je DST_Vowel
    cmp al, 'U'
    jne DST_Next

DST_Vowel:
    inc ebx

DST_Next:
    add esi, edi
    loop DST_Count

    cmp ebx, 2
    jne DST_Done

    mov esi, pStart
    mov ebx, 4

DST_Print:
    mov al, [esi]
    call WriteChar
    add esi, edi
    dec ebx
    jnz DST_Print
    call Crlf

DST_Done:
    ret
DisplaySetIfTwo ENDP

; Rows
mov esi, OFFSET matrix
mov ebx, 4
LMS_Rows:
    INVOKE DisplaySetIfTwo, esi, 1
    add esi, 4
    dec ebx
    jnz LMS_Rows

; Columns
mov esi, OFFSET matrix
mov ebx, 4
LMS_Columns:
    INVOKE DisplaySetIfTwo, esi, 4
    inc esi
    dec ebx
    jnz LMS_Columns

; Diagonals
INVOKE DisplaySetIfTwo, ADDR matrix, 5
INVOKE DisplaySetIfTwo, ADDR matrix[3], 3


12. Calculating the Sum of an Array Row

Write a procedure named calc_row_sum that calculates the sum of a single row in a two-dimensional array of bytes, words, or doublewords. Use explicit stack parameters: array offset, row size, array type, and row index. Return the sum in EAX.

Answer:
; Parameters:
; [EBP+8]  = array offset
; [EBP+12] = row size in bytes
; [EBP+16] = element size in bytes
; [EBP+20] = row index

OPTION PROLOGUE:NONE
OPTION EPILOGUE:NONE

calc_row_sum PROC
    push ebp
    mov ebp, esp
    push ebx
    push ecx
    push edx
    push esi

    mov eax, [ebp+12]
    mul DWORD PTR [ebp+20]
    mov esi, [ebp+8]
    add esi, eax

    mov ebx, [ebp+16]
    mov eax, [ebp+12]
    xor edx, edx
    div ebx
    mov ecx, eax
    xor eax, eax
    jecxz CRS_Done

CRS_Loop:
    cmp ebx, 1
    je CRS_Byte
    cmp ebx, 2
    je CRS_Word

    mov edx, [esi]
    jmp CRS_Add

CRS_Byte:
    movzx edx, BYTE PTR [esi]
    jmp CRS_Add

CRS_Word:
    movzx edx, WORD PTR [esi]

CRS_Add:
    add eax, edx
    add esi, ebx
    loop CRS_Loop

CRS_Done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    mov esp, ebp
    pop ebp
    ret 16
calc_row_sum ENDP

OPTION PROLOGUE:PrologueDef
OPTION EPILOGUE:EpilogueDef

; Example call:
push rowIndex
push TYPE byteArray
push BYTE_ROW_SIZE
push OFFSET byteArray
call calc_row_sum


13. Trimming Leading Characters

Create a variant of the Str_trim procedure that lets the caller remove all instances of a leading character from a string.

Answer:
Str_trimLeading PROC USES eax edx esi edi,
    pString:PTR BYTE,
    trimChar:BYTE

    mov esi, pString
    mov edi, esi
    mov dl, trimChar

STL_Skip:
    mov al, [esi]
    test al, al
    jz STL_Copy
    cmp al, dl
    jne STL_Copy
    inc esi
    jmp STL_Skip

STL_Copy:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    test al, al
    jnz STL_Copy
    ret
Str_trimLeading ENDP

INVOKE Str_trimLeading, ADDR target, '#'


14. Trimming a Set of Characters

Create a variant of the Str_trim procedure that lets the caller remove all instances of a set of characters from the end of a string.

Answer:
Str_trimSet PROC USES eax ebx edx esi edi,
    pString:PTR BYTE,
    pFilter:PTR BYTE

    mov ebx, pString
    mov edi, ebx

STS_FindEnd:
    cmp BYTE PTR [edi], 0
    je STS_CheckLast
    inc edi
    jmp STS_FindEnd

STS_CheckLast:
    cmp edi, ebx
    je STS_Finish

    mov al, [edi-1]
    mov esi, pFilter

STS_FilterLoop:
    mov dl, [esi]
    test dl, dl
    jz STS_Finish

    cmp al, dl
    je STS_Remove

    inc esi
    jmp STS_FilterLoop

STS_Remove:
    dec edi
    jmp STS_CheckLast

STS_Finish:
    mov BYTE PTR [edi], 0
    ret
Str_trimSet ENDP

INVOKE Str_trimSet, ADDR target, ADDR filterChars
