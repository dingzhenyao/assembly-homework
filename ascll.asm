.model small
.stack 100h

.code
start:
    mov ax, @data
    mov ds, ax        ; 初始化数据段

    mov cx, 26        ; 总循环次数：26个小写字母
    mov bl, 0         ; 行内计数器（0-12，记录当前行已输出的字符数）
    mov dl, 'a'       ; 起始字符：'a'（ASCII=97）
   

print_loop:
    ; 输出当前字符
    mov ah, 02h       ; DOS中断：显示单个字符（dl为字符ASCII码）
    int 21h

    inc dl            ; 更新为下一个字符的ASCII码
    inc bl            ; 行内计数+1

    ; 判断是否需要换行（行内已输出13个字符）
    cmp bl, 13
    jne no_newline    ; 未到13个，不换行


  
    ; 输出回车（13）和换行（10）
    push dx
    mov dl, 13        ; 回车ASCII码
    int 21h
    mov dl, 10        ; 换行ASCII码
    int 21h
    pop dx

    mov bl, 0         ; 重置行内计数器
    

no_newline:
    loop print_loop   ; 总循环次数-1，直到cx=0结束
    mov ah, 4ch
    int 21h


end start