.model small
.stack 100h
.data
    msg1 db 'input:$'       ; 输入提示
    msg_err db 0ah,0dh,'error,please input again$'  ; 错误提示
    msg_res db 0ah,0dh,'sum 1 to x =$'  ; 结果提示
    buf db 4,0,4 dup(0)  
    n dw 0               
    sum dw 0             
.code
start:
    mov ax, @data
    mov ds, ax

; 步骤1：输出提示并获取用户输入
input:
    mov ah, 09h
    lea dx, msg1
    int 21h               

    mov ah, 0ah
    lea dx, buf
    int 21h               

; 步骤2：将输入的字符串转换为十进制数值（调用子程序）
    lea si, buf+2         ; si指向输入的第一个字符
    mov cl, buf+1         ; cl = 实际输入的字符数
    mov ch, 0
    call dec_str2num      ; 转换后数值存入n

; 步骤3：验证输入是否在1-100之间
    mov ax, n
    cmp ax, 1
    jl error              ; 若小于1，跳转至错误处理
    cmp ax, 100
    jg error              ; 若大于100，跳转至错误处理

; 步骤4：计算1到n的累加和
    mov cx, 1             ; 计数器从1开始
    mov ax, 0             ; 累加器初始化为0
sum_loop:
    add ax, cx            ; 累加：ax = ax + cx
    inc cx                ; 计数器+1
    cmp cx, n
    jle sum_loop          ; 若cx <= n，继续循环
    mov sum, ax           ; 保存累加结果

; 步骤5：输出累加结果
    mov ah, 09h
    lea dx, msg_res
    int 21h               ; 显示"1到该数的累加和是："

    mov ax, sum
    call print_num        ; 输出累加结果（十进制）
    jmp exit              ; 跳至程序退出

; 错误处理：输入超出范围时提示
error:
    mov ah, 09h
    lea dx, msg_err
    int 21h               ; 显示错误提示

; 程序退出
exit:
    mov ah, 4ch
    int 21h


; 子程序：十进制字符串转数值
; 输入：si=字符串首地址，cx=字符数
; 输出：n=转换后的数值（16位）
dec_str2num proc
    mov n, 0              ; 初始化结果为0
loop_dec:
    mov al, [si]          ; 取当前字符（ASCII码）
    sub al, '0'           ; 转换为数字（'0'→0，'9'→9）
    mov bl, al
    mov bh, 0             ; bx = 当前数字

    mov ax, n             ; ax = 之前的结果
    mov dx, 10
    mul dx                ; ax = 结果 × 10
    add ax, bx            ; ax = 结果 × 10 + 当前数字
    mov n, ax             ; 更新结果

    inc si                ; 下一个字符
    loop loop_dec         ; 循环处理所有字符
    ret
dec_str2num endp


; 子程序：十进制数值输出
; 输入：ax=要输出的数值
; 功能：将数值转换为字符串并显示
print_num proc
    push ax
    push bx
    push cx
    push dx
    mov cx, 0             ; 计数位数
    mov bx, 10            ; 除数为10
divide:
    mov dx, 0             ; 高位清零
    div bx                ; ax = 商，dx = 余数（当前位）
    push dx               ; 保存余数（逆序）
    inc cx                ; 位数+1
    cmp ax, 0
    jne divide            ; 未除尽则继续
print_loop:
    pop dx
    add dl, '0'           ; 转换为ASCII码
    mov ah, 02h
    int 21h               ; 输出单个字符
    loop print_loop       ; 循环输出所有位
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_num endp

end start