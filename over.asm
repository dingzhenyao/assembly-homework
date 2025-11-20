; 8位有符号数加法（溢出检测）
data segment
    num1 db -120       ; 有符号数1（范围：-128~127）
    num2 db 20         ; 有符号数2
    msg_overflow db 'Overflow! (8-bit signed addition)$'  ; 溢出提示
    msg_result db 'Result: $'                            ; 结果提示
    crlf db 0dh, 0ah, '$'                                ; 回车换行
data ends

code segment
    assume cs:code, ds:data

start:
    mov ax, data
    mov ds, ax        ; 初始化数据段

    ; 1. 执行8位有符号数加法
    mov al, num1      ; al = 被加数（num1）
    add al, num2      ; al = num1 + num2（结果存于al）

    ; 2. 检测溢出标志OF（有符号数溢出时OF=1）
    jo overflow       ; 若OF=1，跳转到溢出处理

    ; 3. 无溢出：输出结果（处理正负）
    mov ah, 9
    lea dx, msg_result
    int 21h           ; 显示"Result: "

    call print_byte   ; 调用子程序显示al中的有符号数

    jmp exit          ; 跳转到程序结束

overflow:
    ; 溢出处理：输出错误信息
    mov ah, 9
    lea dx, msg_overflow
    int 21h
    lea dx, crlf
    int 21h

exit:
    ; 程序退出
    mov ah, 4ch
    int 21h


; 子程序：显示al中的8位有符号数（支持正负）
print_byte proc
    push ax
    push bx
    push cx
    push dx

    mov bl, al
    test bl, 80h      ; 检测最高位（符号位：1为负，0为正）
    jz positive       ; 符号位为0，是正数

    ; 负数处理：输出'-'，并取绝对值
    mov ah, 2
    mov dl, '-'
    int 21h
    neg bl            ; bl = |bl|（绝对值）

positive:
    ; 正数处理：将字节转为十进制字符串显示
    mov al, bl
    mov ah, 0         ; ax = 待转换的数（0~127）
    mov cx, 0         ; 计数器：记录位数
    mov bx, 10        ; 除数为10（十进制）

divide:
    div bx            ; ax / 10 → al=商，ah=余数（0~9）
    push ah           ; 余数入栈（逆序存储）
    inc cx            ; 位数+1
    mov ah, 0         ; 清空余数，准备下一次除法
    cmp al, 0         ; 商为0时结束
    jne divide

    ; 弹出栈中余数，转为字符显示（正序）
print_loop:
    pop dx            ; dx=余数（0~9）
    add dl, '0'       ; 转为ASCII字符
    mov ah, 2
    int 21h
    loop print_loop

    ; 输出换行
    lea dx, crlf
    mov ah, 9
    int 21h

    ; 恢复寄存器
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_byte endp

code ends
end start