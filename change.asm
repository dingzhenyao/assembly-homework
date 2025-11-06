.model small
.stack 100h
.data
    msg_input db 'input a hex number:$'
    msg_error db 0ah,0dh,'error: invalid character!$'  ; 非法字符提示
    msg_result db 0ah,0dh,'the decimal number is:$'     ; 结果提示
    buf db 5,0,5 dup(0)  ; 输入缓冲区：最大4位十六进制数+回车
    hex_num dw 0         ; 存储转换后的十六进制数值（16位）
.code
start:
    mov ax, @data
    mov ds, ax

; 步骤1：输出提示并获取用户输入
    mov ah, 09h
    lea dx, msg_input
    int 21h               ; 显示输入提示

    mov ah, 0ah
    lea dx, buf
    int 21h               ; 读取用户输入的字符串

; 步骤2：验证输入合法性并转换为十六进制数值
    lea si, buf+2         ; si指向输入字符串的第一个字符
    mov cl, buf+1         ; cl = 实际输入的字符数
    mov ch, 0             ; cx = 字符数（循环次数）
    call hex_str2num      ; 调用转换子程序，结果存hex_num

; 步骤3：若转换成功，输出十进制结果
    mov ah, 09h
    lea dx, msg_result
    int 21h               ; 显示结果提示

    mov ax, hex_num
    call print_dec        ; 调用十进制输出子程序

; 程序退出
exit:
    mov ah, 4ch
    int 21h


; 子程序：十六进制字符串转数值（含合法性验证）
; 输入：si=字符串首地址，cx=字符数
; 输出：hex_num=转换后的16位数值；若非法则跳转至error
hex_str2num proc
    mov hex_num, 0        ; 初始化结果为0
    cmp cx, 0
    je error              ; 空输入视为错误

loop_hex:
    mov al, [si]          ; 取当前字符（ASCII码）
    ; 判断是否为数字（0-9）
    cmp al, '0'
    jb error              ; 小于'0'，非法
    cmp al, '9'
    jbe is_digit          ; 是数字

    ; 判断是否为大写字母（A-F）
    cmp al, 'A'
    jb error
    cmp al, 'F'
    jbe is_upper

    ; 判断是否为小写字母（a-f）
    cmp al, 'a'
    jb error
    cmp al, 'f'
    jbe is_lower

error:                    ; 非法字符处理
    mov ah, 09h
    lea dx, msg_error
    int 21h
    jmp exit              ; 出错后退出程序

is_digit:                 ; 数字字符转换（0-9）
    sub al, '0'
    jmp convert_end

is_upper:                 ; 大写字母转换（A-F → 10-15）
    sub al, 'A'
    add al, 10
    jmp convert_end

is_lower:                 ; 小写字母转换（a-f → 10-15）
    sub al, 'a'
    add al, 10

convert_end:
    mov bl, al
    mov bh, 0             ; bx = 当前字符对应的数值（0-15）

    mov ax, hex_num       ; ax = 之前的结果
    mov dx, 16
    mul dx                ; ax = 结果 × 16（十六进制进位）
    add ax, bx            ; ax = 结果 × 16 + 当前数值
    mov hex_num, ax       ; 更新结果

    inc si                ; 处理下一个字符
    loop loop_hex         ; 循环直到所有字符处理完毕
    ret
hex_str2num endp


; 子程序：十进制数值输出（将16位数值转换为字符串并显示）
; 输入：ax=要输出的数值（0~65535）
print_dec proc
    push ax
    push bx
    push cx
    push dx
    mov cx, 0             ; 计数器：记录位数
    mov bx, 10            ; 除数为10（十进制基数）

divide:                   ; 拆分每一位（逆序存入栈）
    mov dx, 0             ; dx清零（高位扩展）
    div bx                ; ax = 商，dx = 余数（当前位）
    push dx               ; 余数入栈（逆序保存）
    inc cx                ; 位数+1
    cmp ax, 0
    jne divide            ; 商不为0则继续拆分

print_loop:               ; 弹出栈并输出（正序）
    pop dx
    add dl, '0'           ; 转换为ASCII码（0→'0'，9→'9'）
    mov ah, 02h
    int 21h               ; 输出单个字符
    loop print_loop       ; 循环输出所有位

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_dec endp

end start