.model small
.stack 100h
.code
start:
    mov ax, @data
    mov ds, ax        ; 初始化数据段

input:
    mov ax, 0
    mov ah, 02h
    test al,01h
    int 16h
    jnz end_input
    test al,02h
    int 16h
    jnz end_input

    mov ah, 01h
    int 16h
    jz input
    mov ah, 00h
    int 16h
    mov ah, 0Eh
    int 10h
    jmp input

end_input:
    mov ah, 4Ch
    int 21h
end start