.386
.model flat, stdcall
option casemap:none

includelib kernel32.lib

GetStdHandle PROTO stdcall :DWORD
WriteConsoleA PROTO stdcall :DWORD, :PTR BYTE, :DWORD, :PTR DWORD, :PTR DWORD
ReadConsoleA  PROTO stdcall :DWORD, :PTR BYTE, :DWORD, :PTR DWORD, :PTR DWORD
ExitProcess   PROTO stdcall :DWORD

STD_INPUT_HANDLE  equ -10
STD_OUTPUT_HANDLE equ -11

.data
    hStdIn       dd 0
    hStdOut      dd 0
    bytesRW      dd 0
    inBuf        db 32 dup(0)

    msgPrompt1   db "첫 번째 정수를 입력하세요: "
    lenPrompt1   equ $ - msgPrompt1

    msgPrompt2   db "두 번째 정수를 입력하세요: "
    lenPrompt2   equ $ - msgPrompt2

    msgDivZero   db 0Dh, 0Ah, "[주의] 0으로 나눌 수 없어 나눗셈 결과는 0으로 처리합니다.", 0Dh, 0Ah
    lenDivZero   equ $ - msgDivZero

    hdrResult    db 0Dh, 0Ah, "=== 사칙연산 결과 ===", 0Dh, 0Ah
    lenHdrResult equ $ - hdrResult

    lblAdd       db "덧셈 결과 = "
    lenLblAdd    equ $ - lblAdd

    lblSub       db "뺄셈 결과 = "
    lenLblSub    equ $ - lblSub

    lblMul       db "곱셈 결과 = "
    lenLblMul    equ $ - lblMul

    lblQuot      db "나눗셈 몫 = "
    lenLblQuot   equ $ - lblQuot

    lblRem       db ", 나머지 = "
    lenLblRem    equ $ - lblRem

    hdrRegs      db 0Dh, 0Ah, "=== 연산 후 레지스터 상태 (16-bit Hex / Signed Dec) ===", 0Dh, 0Ah
    lenHdrRegs   equ $ - hdrRegs

    lblAX        db "AX = 0x"
    lenLblAX     equ $ - lblAX

    lblBX        db "BX = 0x"
    lenLblBX     equ $ - lblBX

    lblCX        db "CX = 0x"
    lenLblCX     equ $ - lblCX

    lblDX        db "DX = 0x"
    lenLblDX     equ $ - lblDX

    midHexDec    db " ("
    lenMidHexDec equ $ - midHexDec

    endParenCrLf db ")", 0Dh, 0Ah
    lenEndParen  equ $ - endParenCrLf

    crlf         db 0Dh, 0Ah
    lenCrlf      equ $ - crlf

    num1         dd 0
    num2         dd 0

    sumRes       dd 0
    subRes       dd 0
    mulRes       dd 0
    quotRes      dd 0
    remRes       dd 0

    saveAX       dw 0
    saveBX       dw 0
    saveCX       dw 0
    saveDX       dw 0

    numStrBuf    db 16 dup(0)
    hexStrBuf    db 4 dup(0)

.code

; 문자열 출력 헬퍼: eax=주소, ecx=길이
PrintStr PROC
    push ebx
    push esi
    push edi

    push 0
    push offset bytesRW
    push ecx
    push eax
    push hStdOut
    call WriteConsoleA

    pop edi
    pop esi
    pop ebx
    ret
PrintStr ENDP

; 정수(EAX)를 부호 있는 10진수 문자열로 변환 -> ECX=시작주소, EDX=길이
IntToDec PROC
    push ebx
    push esi
    push edi

    mov edi, offset numStrBuf
    add edi, 15
    mov byte ptr [edi], 0

    xor esi, esi          ; 음수 플래그 (0=양수, 1=음수)
    cmp eax, 0
    jge itd_positive
    mov esi, 1
    neg eax

itd_positive:
    mov ebx, 10
    cmp eax, 0
    jne itd_loop
    dec edi
    mov byte ptr [edi], '0'
    jmp itd_sign

itd_loop:
    cmp eax, 0
    je itd_sign
    xor edx, edx
    div ebx               ; EAX = 몫, EDX = 나머지(0~9)
    add dl, '0'
    dec edi
    mov [edi], dl
    jmp itd_loop

itd_sign:
    cmp esi, 1
    jne itd_done
    dec edi
    mov byte ptr [edi], '-'

itd_done:
    mov ecx, edi
    mov eax, offset numStrBuf
    add eax, 15
    sub eax, edi
    mov edx, eax

    pop edi
    pop esi
    pop ebx
    ret
IntToDec ENDP

; 16비트 값(AX)을 4자리 16진수 문자열로 변환 -> hexStrBuf[0..3]
WordToHex PROC
    push ebx
    push ecx
    push edx
    push edi

    mov edi, offset hexStrBuf
    mov ecx, 4

wth_loop:
    rol ax, 4
    mov dl, al
    and dl, 0Fh
    cmp dl, 9
    jg wth_hex_alpha
    add dl, '0'
    jmp wth_store
wth_hex_alpha:
    add dl, 'A' - 10
wth_store:
    mov [edi], dl
    inc edi
    loop wth_loop

    pop edi
    pop edx
    pop ecx
    pop ebx
    ret
WordToHex ENDP

; 콘솔에서 한 줄 읽어 32비트 부호 있는 정수로 변환 -> EAX
ReadIntConsole PROC
    push ebx
    push ecx
    push edx
    push esi

    push 0
    push offset bytesRW
    push 30
    push offset inBuf
    push hStdIn
    call ReadConsoleA

    mov esi, offset inBuf
    xor eax, eax
    xor ebx, ebx          ; 부호 플래그 (0=+, 1=-)

    ; 공백/개행 스킵
ric_skip:
    mov cl, [esi]
    cmp cl, 0
    je ric_done
    cmp cl, ' '
    je ric_next_skip
    cmp cl, 0Dh
    je ric_next_skip
    cmp cl, 0Ah
    je ric_next_skip
    jmp ric_check_sign

ric_next_skip:
    inc esi
    jmp ric_skip

ric_check_sign:
    cmp cl, '-'
    jne ric_check_plus
    mov ebx, 1
    inc esi
    jmp ric_digits

ric_check_plus:
    cmp cl, '+'
    jne ric_digits
    inc esi

ric_digits:
    xor eax, eax
ric_loop:
    mov cl, [esi]
    cmp cl, '0'
    jl ric_apply_sign
    cmp cl, '9'
    jg ric_apply_sign

    sub cl, '0'
    movzx edx, cl
    imul eax, eax, 10
    add eax, edx
    inc esi
    jmp ric_loop

ric_apply_sign:
    cmp ebx, 1
    jne ric_done
    neg eax

ric_done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
ReadIntConsole ENDP

main PROC
    push STD_OUTPUT_HANDLE
    call GetStdHandle
    mov hStdOut, eax

    push STD_INPUT_HANDLE
    call GetStdHandle
    mov hStdIn, eax

    ; 1. 첫 번째 숫자 입력
    mov eax, offset msgPrompt1
    mov ecx, lenPrompt1
    call PrintStr

    call ReadIntConsole
    mov num1, eax

    ; 2. 두 번째 숫자 입력
    mov eax, offset msgPrompt2
    mov ecx, lenPrompt2
    call PrintStr

    call ReadIntConsole
    mov num2, eax

    ; 3. 덧셈
    mov eax, num1
    add eax, num2
    mov sumRes, eax

    ; 4. 뺄셈
    mov eax, num1
    sub eax, num2
    mov subRes, eax

    ; 5. 곱셈 (16비트: AX * BX -> DX:AX)
    mov eax, num1
    mov ebx, num2
    imul bx
    movsx ecx, ax
    mov mulRes, ecx

    ; 6. 나눗셈 (16비트: DX:AX / BX -> 몫 AX, 나머지 DX)
    mov eax, num1
    mov ebx, num2
    cmp bx, 0
    je div_zero

    cwd
    idiv bx
    mov saveAX, ax
    mov saveBX, bx
    mov cx, 0004h
    mov saveCX, cx
    mov saveDX, dx

    movsx eax, ax
    mov quotRes, eax
    movsx eax, dx
    mov remRes, eax
    jmp print_results

div_zero:
    mov saveAX, 0
    mov saveBX, bx
    mov cx, 0004h
    mov saveCX, cx
    mov saveDX, 0
    mov quotRes, 0
    mov remRes, 0

    mov eax, offset msgDivZero
    mov ecx, lenDivZero
    call PrintStr

print_results:
    mov eax, offset hdrResult
    mov ecx, lenHdrResult
    call PrintStr

    ; 덧셈 출력
    mov eax, offset lblAdd
    mov ecx, lenLblAdd
    call PrintStr
    mov eax, sumRes
    call IntToDec
    mov eax, ecx
    mov ecx, edx
    call PrintStr
    mov eax, offset crlf
    mov ecx, lenCrlf
    call PrintStr

    ; 뺄셈 출력
    mov eax, offset lblSub
    mov ecx, lenLblSub
    call PrintStr
    mov eax, subRes
    call IntToDec
    mov eax, ecx
    mov ecx, edx
    call PrintStr
    mov eax, offset crlf
    mov ecx, lenCrlf
    call PrintStr

    ; 곱셈 출력
    mov eax, offset lblMul
    mov ecx, lenLblMul
    call PrintStr
    mov eax, mulRes
    call IntToDec
    mov eax, ecx
    mov ecx, edx
    call PrintStr
    mov eax, offset crlf
    mov ecx, lenCrlf
    call PrintStr

    ; 나눗셈 몫 & 나머지 출력
    mov eax, offset lblQuot
    mov ecx, lenLblQuot
    call PrintStr
    mov eax, quotRes
    call IntToDec
    mov eax, ecx
    mov ecx, edx
    call PrintStr

    mov eax, offset lblRem
    mov ecx, lenLblRem
    call PrintStr
    mov eax, remRes
    call IntToDec
    mov eax, ecx
    mov ecx, edx
    call PrintStr

    mov eax, offset crlf
    mov ecx, lenCrlf
    call PrintStr

    ; 레지스터 상태 출력
    mov eax, offset hdrRegs
    mov ecx, lenHdrRegs
    call PrintStr

    ; AX
    mov eax, offset lblAX
    mov ecx, lenLblAX
    call PrintStr
    mov ax, saveAX
    call WordToHex
    mov eax, offset hexStrBuf
    mov ecx, 4
    call PrintStr
    mov eax, offset midHexDec
    mov ecx, lenMidHexDec
    call PrintStr
    movsx eax, saveAX
    call IntToDec
    mov eax, ecx
    mov ecx, edx
    call PrintStr
    mov eax, offset endParenCrLf
    mov ecx, lenEndParen
    call PrintStr

    ; BX
    mov eax, offset lblBX
    mov ecx, lenLblBX
    call PrintStr
    mov ax, saveBX
    call WordToHex
    mov eax, offset hexStrBuf
    mov ecx, 4
    call PrintStr
    mov eax, offset midHexDec
    mov ecx, lenMidHexDec
    call PrintStr
    movsx eax, saveBX
    call IntToDec
    mov eax, ecx
    mov ecx, edx
    call PrintStr
    mov eax, offset endParenCrLf
    mov ecx, lenEndParen
    call PrintStr

    ; CX
    mov eax, offset lblCX
    mov ecx, lenLblCX
    call PrintStr
    mov ax, saveCX
    call WordToHex
    mov eax, offset hexStrBuf
    mov ecx, 4
    call PrintStr
    mov eax, offset midHexDec
    mov ecx, lenMidHexDec
    call PrintStr
    movsx eax, saveCX
    call IntToDec
    mov eax, ecx
    mov ecx, edx
    call PrintStr
    mov eax, offset endParenCrLf
    mov ecx, lenEndParen
    call PrintStr

    ; DX
    mov eax, offset lblDX
    mov ecx, lenLblDX
    call PrintStr
    mov ax, saveDX
    call WordToHex
    mov eax, offset hexStrBuf
    mov ecx, 4
    call PrintStr
    mov eax, offset midHexDec
    mov ecx, lenMidHexDec
    call PrintStr
    movsx eax, saveDX
    call IntToDec
    mov eax, ecx
    mov ecx, edx
    call PrintStr
    mov eax, offset endParenCrLf
    mov ecx, lenEndParen
    call PrintStr

    push 0
    call ExitProcess
main ENDP

END main