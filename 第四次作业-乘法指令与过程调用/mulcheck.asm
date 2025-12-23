.model small
.stack 100h
data segment
    ; 错误的九九乘法表（共9行9列，存储在数据段）
    table db 7,2,3,4,5,6,7,8,9       ; 第1行（i=1）
          db 2,4,7,8,10,12,14,16,18  ; 第2行（i=2）
          db 3,6,9,12,15,18,21,24,27 ; 第3行（i=3）
          db 4,8,12,16,7,24,28,32,36 ; 第4行（i=4）
          db 5,10,15,20,25,30,35,40,45 ; 第5行（i=5）
          db 6,12,18,24,30,7,42,48,54 ; 第6行（i=6）
          db 7,14,21,28,35,42,49,56,63 ; 第7行（i=7）
          db 8,16,24,32,40,48,56,7,72 ; 第8行（i=8）
          db 9,18,27,36,45,54,63,72,81 ; 第9行（i=9）
    crlf  db 0dh, 0ah, '$'           ; 回车换行符（用于格式化输出）
    errmsg db ' error', '$'          ; 错误提示字符串
    overmsg db 'accomplish!$', 0dh, 0ah ; 完成提示字符串
    msg1 db 'x y$'

data ends

code segment
    assume cs:code, ds:data

start:
    mov ax, data    ; 初始化数据段（DOS下必须显式设置DS）
    mov ds, ax
    mov ah, 09h    ; 输出提示信息
    lea dx, msg1
    int 21h
    lea dx, crlf
    int 21h

    ; 外层循环：i从1到9（行循环）
    mov cx, 9       ; CX=9（循环次数）
    mov si, 0       ; SI记录当前行索引（0-based，对应i=si+1）
i_loop:
    push cx         ; 保存外层循环计数器（CX会被内层循环修改）
    ; 内层循环：j从1到9（列循环）
    mov cx, 9       ; CX=9（内层循环次数）
    mov di, 0       ; DI记录当前列索引（0-based，对应j=di+1）
j_loop:

    ; 计算table中当前位置的偏移量：(i-1)*9 + (j-1) = si*9 + di
    mov ax, si
    mov bx, 9
    mul bx          ; AX = si*9（行偏移）
    add ax, di      ; AX = si*9 + di（总偏移）
    mov bp, ax      ; BP暂存偏移量

    ; 取出table中的值并比较
    mov dl, table[bp] ; DL = 表中当前值
    mov dh, 0       ; DX = 表中值（扩展为16位）
    push dx         ; 保存表中值以备后用
    mov ax, si
    inc ax          ; AX = i
    mov bx, di
    inc bx          ; 恢复BX = j
    mul bx          ; AX = 正确结果（i*j）
    pop dx          ; 恢复表中值到DX
    cmp dl, al      ; 比较表中值与正确结果
    je no_error     ; 相等则无错误，跳过输出

    ; 输出错误位置：i j error（依赖DOS的int 21h中断）
    ; 1. 输出i（数字转字符：+48='0'）
    mov ax, si
    inc ax          ; AX = i
    mov ah, 2       ; DOS功能：显示字符（DL=字符）
    mov dl, al      ; AL=ax的低8位（i的值，因i<=9）
    add dl, 48      ; 转为ASCII字符
    int 21h

    ; 2. 输出空格
    mov dl, ' '
    int 21h

    ; 3. 输出j
    mov dl, bl      ; BL=bx的低8位（j的值）
    add dl, 48
    int 21h

    ; 4. 输出" error"
    mov ah, 9       ; DOS功能：显示字符串（DS:DX=字符串首地址，以'$'结尾）
    lea dx, errmsg
    int 21h

    ; 5. 输出回车换行
    lea dx, crlf
    int 21h

no_error:
    inc di          ; 列索引+1
    loop j_loop     ; 内层循环结束（CX--，若CX!=0则重复）

    pop cx          ; 恢复外层循环计数器
    inc si          ; 行索引+1
    loop i_loop     ; 外层循环结束

    ; 程序结束：输出完成提示并退出DOS
    mov ah, 9
    lea dx, crlf    ; 先换行
    int 21h
    lea dx, overmsg ; 输出完成提示
    int 21h

    mov ah, 4ch     ; DOS功能：程序退出（返回码在AL）
    int 21h

code ends
end start