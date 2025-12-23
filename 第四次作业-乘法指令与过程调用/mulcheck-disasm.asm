; mulcheck-disasm.asm - 带注释的反汇编（检查 9×9 表中错误项）
; 说明：编译器将常量表数据放在函数栈空间（通过 movabs 写入局部内存），
; 我们后续通过偏移计算访问表中某个 (i,j) 的值。

.LC0:
        .string "x y\r"                ; 标题输出（同汇编）
.LC1:
        .string "%d %d error\r\n"      ; 错误输出格式
.LC2:
        .string "\r\naccomplish!\r"   ; 完成提示

main:
        push    rbp
        mov     rbp, rsp
        sub     rsp, 112                ; 为局部数据和表数据分配栈空间

        ; 以下若干 movabs/mov 将表的原始字节常量写入到 [rbp-112]..[rbp-40] 的区域
        ; 这些 64-bit 常量是编译器对 table 字节块的打包表示（便于初始化）
        movabs  rax, 578437695752307207
        movabs  rdx, 1012195045845238281
        mov     QWORD PTR [rbp-112], rax
        mov     QWORD PTR [rbp-104], rdx
        movabs  rax, 1301272050228466192
        movabs  rdx, 508919986461022229
        mov     QWORD PTR [rbp-96], rax
        mov     QWORD PTR [rbp-88], rdx
        movabs  rax, 1445385022606416920
        movabs  rdx, 1300421183419915801
        mov     QWORD PTR [rbp-80], rax
        mov     QWORD PTR [rbp-72], rdx
        movabs  rax, 1010836221859405336
        movabs  rdx, 594255459647691797
        mov     QWORD PTR [rbp-64], rax
        mov     QWORD PTR [rbp-56], rdx
        movabs  rax, 5190178875050563600
        movabs  rdx, 5205939261770764809
        mov     QWORD PTR [rbp-48], rax
        mov     QWORD PTR [rbp-40], rdx
        mov     BYTE PTR [rbp-32], 81     ; 表的最后一个字节（81）写入位置

        mov     edi, OFFSET FLAT:.LC0
        call    puts                     ; 打印标题 "x y"

        mov     DWORD PTR [rbp-4], 1     ; row i = 1
        jmp     .L2

.L6:                                   ; 外层循环体：初始化 col = 1
        mov     DWORD PTR [rbp-8], 1     ; col j = 1
        jmp     .L3

.L5:                                   ; 内层循环体：计算表索引并比较值
        mov     eax, DWORD PTR [rbp-4]   ; eax = i
        lea     edx, [rax-1]             ; edx = i - 1
        mov     eax, edx
        sal     eax, 3                   ; eax = (i-1) * 8  (左移3相当于 *8)
        add     edx, eax                 ; edx = (i-1) + (i-1)*8 = (i-1)*9  -> 行偏移

        mov     eax, DWORD PTR [rbp-8]   ; eax = j
        sub     eax, 1                   ; eax = j - 1
        add     eax, edx                 ; eax = (i-1)*9 + (j-1)  -> 总偏移（0-based index）

        cdqe                              ; 将 32-bit EAX 符号扩展为 64-bit RAX（用于 64-bit 地址寻址）
        movzx   eax, BYTE PTR [rbp-112+rax] ; 从表的存储区读取 1 字节：table[index]
        mov     BYTE PTR [rbp-9], al     ; 将读取的字节保存到局部变量 [rbp-9]

        mov     eax, DWORD PTR [rbp-4]
        imul    eax, DWORD PTR [rbp-8]   ; eax = i * j（正确的乘积）
        mov     DWORD PTR [rbp-16], eax  ; 保存计算结果到 [rbp-16]
        mov     eax, DWORD PTR [rbp-16]  ; 将结果放到 eax，用作比较

        cmp     BYTE PTR [rbp-9], al     ; 比较表中的值（byte）和正确结果的低8位（al）
        je      .L4                       ; 若相等则跳过错误输出

        ; 若不相等，调用 printf 输出 "i j error"
        mov     edx, DWORD PTR [rbp-8]   ; edx = j (第二个参数)
        mov     eax, DWORD PTR [rbp-4]   ; eax = i
        mov     esi, eax                 ; esi = i (第二个 printf 参数位置)
        mov     edi, OFFSET FLAT:.LC1    ; edi = format string
        mov     eax, 0                   ; 清零 eax（variadic 函数调用约定要求）
        call    printf

.L4:
        add     DWORD PTR [rbp-8], 1     ; j++

.L3:
        cmp     DWORD PTR [rbp-8], 9     ; if (j <= 9) 重复内层循环
        jle     .L5
        add     DWORD PTR [rbp-4], 1     ; i++（下一行）

.L2:
        cmp     DWORD PTR [rbp-4], 9     ; if (i <= 9) 重复外层循环
        jle     .L6

        mov     edi, OFFSET FLAT:.LC2
        call    puts                     ; 打印 "accomplish!"
        mov     eax, 0
        leave
        ret