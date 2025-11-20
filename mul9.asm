.model small
.stack 100h
.data
    title_msg db 'The 9*9 table:$'
.code
start:
    mov ax, @data
    mov ds, ax

    ; 输出标题
    mov ah, 09h
    lea dx, title_msg
    int 21h
    mov ah, 02h
    mov dl, 0dh
    int 21h
    mov dl, 0ah
    int 21h

    ; 外层循环：控制行数（i从9到1）
    mov cx, 9
    mov bx, 9        ; bx作为外层循环变量i
outer_loop:
    ; 内层循环：控制列数（j从1到i）
    mov di, bx       ; di作为内层循环变量j的上限（即当前i的值）
    mov si, 1        ; si作为内层循环变量j，从1开始
inner_loop:
    ; 调用过程输出一项：i*j=result
    push bx          ; 保存外层i（bx）
    push si          ; 保存内层j（si）
    call print_item  ; 调用输出项的过程
    pop si           ; 恢复j
    pop bx           ; 恢复i

    inc si           ; j++
    cmp si, di       ; 判断j是否<=i
    jle inner_loop   ; 是则继续内层循环

    ; 换行（每一行结束后换行）
    mov ah, 02h
    mov dl, 0dh
    int 21h
    mov dl, 0ah
    int 21h

    dec bx           ; i--
    loop outer_loop  ; 外层循环继续，直到cx=0

    ; 程序退出
    mov ah, 4ch
    int 21h

; 过程：输出一项 i*j=result
; 输入：栈顶为j（si），栈顶+2为i（bx）
print_item proc
    push ax
    push bx
    push cx
    push dx

    ; 计算 i*j（用mul指令）
    mov ax, bx
    mul si           ; ax = i*j（结果）
    push ax          ; 保存结果

    ; 输出 i
    mov dl, bl
    add dl, '0'
    mov ah, 02h
    int 21h

    ; 输出 '*'
    mov dl, '*'
    int 21h

    ; 输出 j
    mov dx, si
    add dl, '0'
    int 21h

    ; 输出 '='
    mov dl, '='
    int 21h

    ; 输出 result（ax）
    pop ax           ; 恢复结果
    mov cx, 0
    mov dx, 0
    mov bx, 10
divide:
    mov dx, 0
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne divide
print_result:
    pop dx
    add dl, '0'
    push ax
    mov ah, 02h
    int 21h
    pop ax
    loop print_result

    ; 输出空格分隔
    mov dl, ' '
    mov ah, 02h
    int 21h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_item endp

end start