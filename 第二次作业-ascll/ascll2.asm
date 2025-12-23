; ascll2.asm - 使用双重循环输出小写字母，每行13个，共两行（a..z）
; 模式：small

.model small
.stack 100h

.code
start:
    mov ax, @data
    mov ds, ax        ; 初始化数据段

    mov bh, 2         ; 外层循环：行数（2行）
    mov dl, 'a'       ; 当前字符，从 'a' 开始
    push dx           ; 保存 DL

outer_loop:
    mov cx, 13        ; 内层循环：每行输出13个字符

inner_loop:
    pop dx            ; 恢复 DL（当前字符）
    mov ah, 02h       ; DOS 中断 02h：显示单字符，字符在 DL
    int 21h

    push dx           ; 保存 DL（当前字符）
    mov dl, ' '       ; 输出空格作为分隔
    mov ah, 02h
    int 21h
    pop dx            ; 恢复 DL

    inc dl            ; 下一个字符
    push dx           ; 保存 DL
    loop inner_loop   ; 内层计数器 CX--，直至0

    ; 输出回车+换行
    mov ah, 02h
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h

    dec bh            ; 行数--
    jnz outer_loop    ; 还有行则继续
    pop dx            ; 恢复 DL

    mov ah, 4ch       ; 结束程序
    int 21h

end start
