; sum3.asm - 结果保存在栈中（push 到栈顶并保留）
.model small
.stack 100h
.data
    msg db 'sum 1 to 100 = $'
.code
start:
    mov ax, @data
    mov ds, ax

    mov cx, 1
    mov ax, 0       ; AX 用作累加器

loop1:
    add ax, cx
    inc cx
    cmp cx, 101
    jl loop1

    ; 将结果压入栈顶并保留（不立即 pop），以演示“把结果放在栈中”
    push ax         ; 栈顶现在保存结果

    mov ah, 09h
    lea dx, msg
    int 21h         ; 输出提示字符串

    ; 为打印，从栈顶读出值到 AX（但不弹出），然后调用打印例程
    ; 注：直接使用 [sp] 在 16 位模式下会导致非法寻址，改为使用 BP 访问 SS 段的栈地址（先保存 BP）
    push bp
    mov bp, sp
    mov ax, [bp+2]  ; 读取先前 push AX 的结果（结果位于保存的 BP 之后两个字节）
    pop bp
    call print_num  ; print_num 会保存/恢复寄存器，返回后栈上仍保留原始结果

    ; 注意：此处我们故意不 pop 结果，以证明结果仍然存放在栈中

    mov ah, 4ch
    int 21h

; 打印 AX 中的正整数（十进制）
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
