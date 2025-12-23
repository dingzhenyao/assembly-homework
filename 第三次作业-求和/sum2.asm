; sum2.asm - 结果保存在寄存器（AX）
.model small
.stack 100h
.data
    msg db 'sum 1 to 100 = $'
.code
start:
    mov ax, @data
    mov ds, ax

    mov cx, 1       ; 循环计数
    mov ax, 0       ; AX 用作累加器（结果最终保存在 AX）

loop1:
    add ax, cx
    inc cx
    cmp cx, 101
    jl loop1

    ; 结果现在保存在 AX（寄存器）
    push ax         ; 保存 AX（结果），因为随后设置 AH 会修改 AX

    mov ah, 09h
    lea dx, msg
    int 21h         ; 输出提示字符串

    pop ax          ; 恢复 AX（结果）
    ; 直接使用 AX 调用打印例程（print_num 以 AX 为输入）
    call print_num

    mov ah, 4ch
    int 21h

; 打印 AX 中的正整数（十进制），与原文件 print_num 等效
print_num proc
    push ax
    push bx
    push cx
    push dx

    mov cx, 0
    mov bx, 10

divide:
    mov dx, 0
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne divide

print_loop:
    pop dx
    add dl, 30h
    mov ah, 02h
    int 21h
    loop print_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_num endp

end start
