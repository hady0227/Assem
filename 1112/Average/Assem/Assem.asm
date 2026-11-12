.386
.model flat, stdcall
option casemap:none

; 필요한 라이브러리 링크
includelib libcmt.lib
includelib legacy_stdio_definitions.lib
includelib ucrt.lib
includelib kernel32.lib

extern printf:near
extern scanf:near
extern exit:near

.data
    prompt  db "5개의 숫자를 입력하세요 (정수): ", 0
    fmtIn   db "%d", 0
    fmtOut  db 0Ah, "입력한 숫자들의 평균: %d", 0Ah, 0
    
    num     dd ?
    sum     dd 0

.code
start:
    ; 안내 문구 출력
    push offset prompt
    call printf
    add esp, 4

    mov ecx, 5          ; 반복 횟수 5번 설정
input_loop:
    push ecx            ; ECX 레지스터 보존
    push offset num
    push offset fmtIn
    call scanf
    add esp, 8
    pop ecx             ; ECX 레지스터 복원

    mov eax, num
    add sum, eax        ; sum += 입력받은 숫자

    dec ecx
    jnz input_loop

    ; 평균 계산 (sum / 5)
    mov eax, sum
    cdq
    mov ebx, 5
    idiv ebx            ; EAX = 총합 / 5

    ; 결과 출력
    push eax
    push offset fmtOut
    call printf
    add esp, 8

    ; 프로그램 종료
    push 0
    call exit

end start