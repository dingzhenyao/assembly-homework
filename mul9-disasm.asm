; mul9-disasm.asm - 带注释的反汇编（打印 9×9 乘法表）
; 功能概述：打印 9*9 乘法表，外层行数从 9 递减到 1，内层列数从 1 到当前行数
; 局部变量（基于栈帧 rbp）：
;   [rbp-4] := row（当前行，从 9 开始，逐次减 1）
;   [rbp-8] := col（当前列，从 1 开始，逐次加 1）

.LC0:
        .string "The 9*9 table:"
.LC1:
        .string "%d*%d=%d "               ; 格式：row*col=product<space>

main:
        push    rbp                        ; 保存旧的基指针，建立栈帧
        mov     rbp, rsp
        sub     rsp, 16                    ; 分配局部栈空间（容纳 row, col 等）

        mov     edi, OFFSET FLAT:.LC0      ; 第一个参数：字符串常量地址
        call    puts                       ; puts("The 9*9 table:")

        mov     DWORD PTR [rbp-4], 9       ; row = 9（初始化外层循环）
        jmp     .L2                        ; 先检查外层循环条件

.L5:                                       ; 外层循环体开始：初始化内层计数器 col = 1
        mov     DWORD PTR [rbp-8], 1      ; col = 1
        jmp     .L3                        ; 进入内层循环检查

.L4:                                       ; 内层循环体：打印 row * col 的格式化字符串
        mov     eax, DWORD PTR [rbp-4]    ; eax = row（临时）
        imul    eax, DWORD PTR [rbp-8]    ; eax = row * col （有符号乘法，结果放 eax）
        mov     ecx, eax                  ; ecx = product（第三参数，用于 printf 的 %d）
        mov     edx, DWORD PTR [rbp-8]    ; edx = col（第二参数）
        mov     eax, DWORD PTR [rbp-4]    ; eax = row（准备放入 esi）
        mov     esi, eax                  ; esi = row（第一个参数）
        mov     edi, OFFSET FLAT:.LC1     ; edi = 格式字符串地址（第 0 个参数）
        mov     eax, 0                    ; 根据 ABI，调用 variadic 函数前清零 eax
        call    printf                    ; printf("%d*%d=%d ", row, col, product)

        add     DWORD PTR [rbp-8], 1      ; col++

.L3:                                       ; 内层循环条件检查：if (col <= row) goto L4
        mov     eax, DWORD PTR [rbp-8]
        cmp     eax, DWORD PTR [rbp-4]
        jle     .L4

        mov     edi, 10                   ; 输出换行（putchar(10)）
        call    putchar

        sub     DWORD PTR [rbp-4], 1      ; row--（进入下一行）

.L2:                                       ; 外层循环条件：if (row > 0) goto L5
        cmp     DWORD PTR [rbp-4], 0
        jg      .L5

        mov     eax, 0                    ; main 返回值 0
        leave                             ; 恢复栈帧（mov rsp, rbp; pop rbp）
        ret
