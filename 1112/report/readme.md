1. Which Direction flag setting causes index registers to move backward through memory when executing string primitives?

Answer:
DF = 1
std


2. When a repeat prefix is used with STOSW, what value is added to or subtracted from the index register?

Answer:
2 bytes per iteration.
DF = 0: EDI increases by 2.
DF = 1: EDI decreases by 2.


3. In what way is the CMPS instruction ambiguous?

Answer:
Its explicit operands do not determine the actual memory addresses compared. In 32-bit mode, CMPS compares the values at DS:[ESI] and ES:[EDI].


4. When the Direction flag is clear and SCASB has found a matching character, where does EDI point?

Answer:
EDI points one byte past the matching character. The matching character’s address is EDI - 1.


5. When scanning an array for the first occurrence of a particular character, which repeat prefix would be best?

Answer:
REPNE (or REPNZ)

cld
mov edi, OFFSET array
mov ecx, LENGTHOF array
mov al, targetChar
repne scasb


6. What Direction flag setting is used in the Str_trim procedure from Section 9.3?

Answer:
DF = 1

std
repe scasb


7. Why does the Str_trim procedure from Section 9.3 use the JNE instruction?

Answer:
To detect when SCASB finds a character that does not match the character being trimmed and branch to the code that places the null terminator.

    repe scasb
    jne  L1
    dec  edi
L1: mov  BYTE PTR [edi+2], 0


8. What happens in the Str_ucase procedure from Section 9.3 if the target string contains a digit?

Answer:
The digit remains unchanged.


9. If the Str_length procedure from Section 9.3 used SCASB, which repeat prefix would be most appropriate?

Answer:
REPNE (or REPNZ)

xor al, al
repne scasb


10. If the Str_length procedure from Section 9.3 used SCASB, how would it calculate and return the string length?

Answer:
String length = final EDI - initial EDI - 1

Str_length PROC USES ecx edi,
    pString:PTR BYTE

    cld
    mov edi, pString
    mov ecx, -1
    xor eax, eax
    repne scasb

    mov eax, edi
    sub eax, pString
    dec eax
    ret

Str_length ENDP


11. What is the maximum number of comparisons needed by the binary search algorithm when an array contains 1,024 elements?

Answer:
11 comparisons.


12. In the FillArray procedure from the Binary Search example in Section 9.5, why must the Direction flag be cleared by the CLD instruction?

Answer:
To make STOSD advance EDI by 4 bytes after each store, filling the array in the forward direction.

cld


13. In the BinarySearch procedure from Section 9.5, why could the statement at label L2 be removed without affecting the outcome?

Answer:
The earlier CMP already set the flags, and JGE does not change them. The duplicate CMP at L2 is unnecessary.


14. In the BinarySearch procedure from Section 9.5, how might the statement at label L4 be eliminated?

Answer:
Replace each JMP L4 with JMP L1, then remove the L4 label and its JMP L1 instruction.
