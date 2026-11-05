includelib msvcrt.lib
includelib legacy_stdio_definitions.lib

extrn printf:proc

.data
msgID   db "학번: 2023864046", 10, 0
msgName db "이름: 하도윤", 10, 0

.code
main proc
    sub rsp, 40
    
    lea rcx, msgID
    call printf
    
    lea rcx, msgName
    call printf
    
    xor rax, rax
    add rsp, 40
    ret
main endp
end
