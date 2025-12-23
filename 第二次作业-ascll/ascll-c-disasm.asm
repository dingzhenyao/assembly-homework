; ascll-c-disasm.asm - 带注释的反汇编（来自 ascll.c 的编译产物）
; 功能：输出小写字母 a..z，每字母后空格，每行 13 个字符，行尾 CR+LF；最后若总数不是每行整除则追加换行

main:
        push    rbp                    ; 保存旧的基指针（函数序言）
        mov     rbp, rsp               ; 建立新的栈帧基址
        sub     rsp, 16                ; 为局部变量分配栈空间（16 字节）

        ; 局部变量布局（基于 [rbp - offset]）：
        ; [rbp-1]   : char ch (当前字符，初始 'a'=97)
        ; [rbp-8]   : int i   (已输出字符计数)
        ; [rbp-12]  : int total (总字符数 = 26)
        ; [rbp-16]  : int per_line (每行字符数 = 13)

        mov     BYTE PTR [rbp-1], 97   ; ch = 'a'
        mov     DWORD PTR [rbp-12], 26 ; total = 26
        mov     DWORD PTR [rbp-16], 13 ; per_line = 13
        mov     DWORD PTR [rbp-8], 0   ; i = 0
        jmp     .L2                    ; 跳到循环条件检查

.L4:                                   ; 循环体：打印一个字符并跟一个空格
        movsx   eax, BYTE PTR [rbp-1]  ; 将 BYTE ch 扩展为 EAX（符号扩展，但值为 ASCII 正数）
        mov     edi, eax               ; 将字符放入第一个整型参数寄存器 EDI（x86-64 Linux ABI）
        call    putchar                ; putchar(ch)

        mov     edi, 32                ; 32 = ' ' (空格)
        call    putchar                ; putchar(' ')

        movzx   eax, BYTE PTR [rbp-1]  ; 将 ch 零扩展到 EAX（准备自增并存回 BYTE）
        add     eax, 1                 ; ch++（在临时 EAX 上）
        mov     BYTE PTR [rbp-1], al   ; 将更新后的字符保存回 [rbp-1]

        ; 现在检查 (i+1) % per_line 是否为 0，用以决定是否换行
        mov     eax, DWORD PTR [rbp-8] ; eax = i
        add     eax, 1                 ; eax = i + 1
        cdq                            ; 将 EAX 的符号位扩展到 EDX:EAX（为 idiv 做准备）
        idiv    DWORD PTR [rbp-16]     ; signed 除法：(i+1) / per_line
                                       ; 结果：EAX = 商, EDX = 余数
        mov     eax, edx               ; 将余数放入 EAX 以便测试
        test    eax, eax               ; 设置标志：检查余数是否为 0
        jne     .L3                    ; 若余数 != 0（即不整除），跳过换行

        mov     edi, 13                ; CR (13)
        call    putchar                ; 输出回车
        mov     edi, 10                ; LF (10)
        call    putchar                ; 输出换行
.L3:
        add     DWORD PTR [rbp-8], 1   ; i++（已输出的字符数加 1）

.L2:                                   ; 循环条件检查：if (i < total) goto L4
        mov     eax, DWORD PTR [rbp-8]
        cmp     eax, DWORD PTR [rbp-12]
        jl      .L4

        ; 循环结束后，再次检查 total % per_line 是否为 0，若不为 0 则补一个换行（与 C 代码中的末尾处理对应）
        mov     eax, DWORD PTR [rbp-12] ; eax = total
        cdq
        idiv    DWORD PTR [rbp-16]      ; eax = total / per_line, edx = total % per_line
        mov     eax, edx                ; eax = remainder
        test    eax, eax                ; if (remainder == 0) 跳过补行
        je      .L5

        mov     edi, 13                 ; CR
        call    putchar                 ; 输出回车
        mov     edi, 10                 ; LF
        call    putchar                 ; 输出换行
.L5:
        mov     eax, 0                  ; 返回值 0
        leave                           ; 恢复栈帧（mov rsp, rbp; pop rbp）
        ret                             ; 返回到调用者
