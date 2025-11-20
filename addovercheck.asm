; 功能：16位有符号数加法，溢出时（OF=1）报错
; 编译：ml signed_add.asm
; 运行：DOSBox中执行signed_add.exe

.model small
.stack 100h
.data
    msg_input1 db 'first num(-32768~32767):$'
    msg_input2 db 0ah,0dh,'second num(-32768~32767):$'
    msg_overflow db 0ah,0dh,'error! overflow$'
    msg_result db 0ah,0dh,'add result:$'
    buf db 7,0,7 dup(0)  ; 输入缓冲区：支持±32767（最多6字符+回车）
    a dw 0               ; 存储第一个有符号数（字）
    b dw 0               ; 存储第二个有符号数（字）
    sum dw 0             ; 存储和（字）
.code
start:
    mov ax, @data
    mov ds, ax

    ; 1. 输入第一个有符号数
    mov ah, 09h
    lea dx, msg_input1
    int 21h
    call input_signed    ; 调用输入子程序，结果存a
    mov a, ax

    ; 2. 输入第二个有符号数
    mov ah, 09h
    lea dx, msg_input2
    int 21h
    call input_signed    ; 调用输入子程序，结果存b
    mov b, ax

    ; 3. 有符号数加法+溢出检测（调用子程序）
    mov ax, a
    mov bx, b
    call add_signed      ; 加法：ax + bx，结果存sum，检测OF
    jc overflow_err      ; 若OF=1，跳转报错（jo等价于jc检测OF）

    ; 4. 输出结果
    mov ah, 09h
    lea dx, msg_result
    int 21h
    mov ax, sum
    call print_signed    ; 调用输出有符号数子程序
    jmp exit

    ; 溢出报错
overflow_err:
    mov ah, 09h
    lea dx, msg_overflow
    int 21h

    ; 程序退出
exit:
    mov ah, 4ch
    int 21h


; 子程序1：输入字符串并转换为16位有符号字（补码）
; 输入：无（读取buf缓冲区）
; 输出：ax = 转换后的有符号字（范围-32768~32767）
input_signed proc
    push bx
    push cx
    push dx
    push si

    ; 读取输入字符串
    mov ah, 0ah
    lea dx, buf
    int 21h

    lea si, buf+2        ; si指向输入字符串首字符
    mov cl, buf+1        ; cl = 实际输入字符数
    mov ch, 0
    mov bx, 0            ; bx存储绝对值（初始0）
    mov dl, 0            ; dl标记是否为负数（0=正，1=负）

    ; 检查是否以'-'开头（负数）
    cmp byte ptr [si], '-'
    jne is_positive
    mov dl, 1            ; 标记为负数
    inc si               ; 跳过负号
    dec cx               ; 字符数减1

is_positive:
    ; 转换数字字符串为无符号数（bx存储）
loop_conv:
    mov al, [si]
    sub al, '0'          ; 字符→数字
    mov ah, 0
    push ax
    mov ax, bx
    mov dx, 10
    mul dx               ; bx = bx * 10
    pop bx
    add bx, ax           ; bx = bx * 10 + 当前数字
    inc si
    loop loop_conv

    ; 若为负数，转换为补码（取反+1）
    cmp dl, 1
    jne conv_end
    neg bx               ; 负数：bx = -bx（补码形式）

conv_end:
    mov ax, bx           ; ax = 最终有符号数
    pop si
    pop dx
    pop cx
    pop bx
    ret
input_signed endp


; 子程序2：16位有符号数加法+溢出检测
; 输入：ax = 被加数，bx = 加数
; 输出：sum = ax + bx；OF标志位（溢出时OF=1）
add_signed proc
    push ax
    add ax, bx           ; 有符号数加法，OF自动置1（溢出时）
    mov sum, ax          ; 保存和
    pop ax
    ret
add_signed endp


; 子程序3：输出16位有符号字（补码→字符串）
; 输入：ax = 要输出的有符号数
; 输出：屏幕显示该数（含正负号）
print_signed proc
    push ax
    push bx
    push cx
    push dx

    ; 检查是否为负数
    cmp ax, 0
    jge print_positive
    ; 输出负号
    mov ah, 02h
    mov dl, '-'
    int 21h
    neg ax               ; 取绝对值（ax变为正数）

print_positive:
    ; 转换为十进制字符串（逆序入栈）
    mov cx, 0
    mov bx, 10
loop_div:
    mov dx, 0
    div bx               ; ax=商，dx=余数（当前位）
    push dx
    inc cx
    cmp ax, 0
    jne loop_div

    ; 正序出栈输出
print_loop:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_loop

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_signed endp

end start