; sum-disasm.asm - 带注释的反汇编
; 对应 C 程序：计算 1 到 100 的和并调用 printf 输出（格式："sum 1 to 100 = %d\r\n"）

.LC0:
        .string "sum 1 to 100 = %d\r\n"

main:
        push    rbp                    ; 保存旧的基指针
        mov     rbp, rsp               ; 建立栈帧基址
        sub     rsp, 16                ; 为局部变量分配栈空间（16 字节）

        ; 局部变量布局（相对 rbp）
        ; [rbp-4] := total (int)
        ; [rbp-8] := i (int), 从 1 开始
        mov     DWORD PTR [rbp-4], 0   ; total = 0
        mov     DWORD PTR [rbp-8], 1   ; i = 1
        jmp     .L2                    ; 跳转到循环条件检查

.L3:                                ; 循环体：total += i; i++
        mov     eax, DWORD PTR [rbp-8] ; eax = i
        add     DWORD PTR [rbp-4], eax ; total += eax
        add     DWORD PTR [rbp-8], 1   ; i++

.L2:                                ; 条件：if (i <= 100) goto L3
        cmp     DWORD PTR [rbp-8], 100
        jle     .L3

        ; 循环结束后，准备调用 printf 输出 total
        mov     eax, DWORD PTR [rbp-4] ; eax = total (作为临时)
        mov     esi, eax               ; 第二个参数（%d） -> ESI
        mov     edi, OFFSET FLAT:.LC0  ; 第一个参数：格式字符串 -> EDI
        mov     eax, 0                 ; 对于 variadic functions，RAX 用作寄存器清零（ABI 约定）
        call    printf                 ; printf(format, total)

        mov     eax, 0                 ; 返回值 0
        leave                          ; 恢复栈帧（mov rsp, rbp; pop rbp）
        ret                            ; 返回
