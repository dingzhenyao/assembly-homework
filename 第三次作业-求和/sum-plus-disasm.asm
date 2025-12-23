; sum-plus-disasm.asm - 带注释的反汇编（对应 sum-plus.c）
; 功能：提示输入一个数字 x（字符串读入，去掉尾部换行，验证字符都是数字，调用 strtol 得到数字，验证 1..100，计算 1..x 的和并 printf 输出）

.LC0:
        .string "input:"
.LC1:
        .string "error,please input again\r\n"
.LC2:
        .string "\r\nsum 1 to %ld = %ld\r\n"

main:
        push    rbp                    ; 函数序言
        mov     rbp, rsp
        sub     rsp, 80                ; 分配 80 字节局部空间（缓冲区、临时变量）

        ; 打印提示 "input:"
        mov     edi, OFFSET FLAT:.LC0
        mov     eax, 0
        call    printf

        ; 调用 fgets(buf, 32, stdin)
        mov     rdx, QWORD PTR stdin[rip] ; 第三个参数：stdin
        lea     rax, [rbp-80]            ; buf 的地址（rbp-80）
        mov     esi, 32                  ; 第二个参数：size = 32
        mov     rdi, rax                 ; 第一个参数：缓冲区指针
        call    fgets

        ; 检查 fgets 返回值（RAX）：若为 NULL（0）则视为读取失败，打印错误并返回
        test    rax, rax
        sete    al                       ; AL = (RAX==0) ? 1 : 0
        test    al, al
        je      .L2                      ; 如果 AL == 0（即 RAX != 0），跳到 .L2 继续处理

        ; fgets 返回 NULL（读取失败），打印错误信息到 stderr 并返回 1
        mov     rax, QWORD PTR stderr[rip]
        mov     rcx, rax
        mov     edx, 26
        mov     esi, 1
        mov     edi, OFFSET FLAT:.LC1
        call    fwrite
        mov     eax, 1
        jmp     .L15

.L2:
        ; 去掉尾部换行（LF 或 CRLF）
        lea     rax, [rbp-80]
        mov     rdi, rax
        call    strlen                    ; 返回字符串长度放 RAX
        mov     QWORD PTR [rbp-32], rax    ; 保存长度到 [rbp-32]
        cmp     QWORD PTR [rbp-32], 0
        je      .L4                       ; 空字符串则跳转错误处理

        ; 检查最后一个字符是否为 LF (10)，若是则去掉
        mov     rax, QWORD PTR [rbp-32]
        sub     rax, 1
        movzx   eax, BYTE PTR [rbp-80+rax]
        cmp     al, 10
        je      .L5
        ; 否则检查是否为 CR (13)，若是也去掉（处理 CRLF 情况）
        mov     rax, QWORD PTR [rbp-32]
        sub     rax, 1
        movzx   eax, BYTE PTR [rbp-80+rax]
        cmp     al, 13
        jne     .L4
.L5:
        sub     QWORD PTR [rbp-32], 1     ; 长度减 1
        lea     rdx, [rbp-80]
        mov     rax, QWORD PTR [rbp-32]
        add     rax, rdx
        mov     BYTE PTR [rax], 0         ; 在新的末尾写入 NUL

.L4:
        ; 检查是否为空字符串（首字符为 NUL）
        lea     rax, [rbp-80]
        mov     QWORD PTR [rbp-8], rax    ; 保存字符串指针到 [rbp-8]
        mov     rax, QWORD PTR [rbp-8]
        movzx   eax, BYTE PTR [rax]       ; 读取首字符
        test    al, al
        jne     .L7                       ; 若非 0，继续验证字符

        ; 否则打印错误并返回 1
        mov     rax, QWORD PTR stderr[rip]
        mov     rcx, rax
        mov     edx, 26
        mov     esi, 1
        mov     edi, OFFSET FLAT:.LC1
        call    fwrite
        mov     eax, 1
        jmp     .L15

.L10:
        ; 验证每个字符是否为数字（'0'..'9' 即 48..57）
        mov     rax, QWORD PTR [rbp-8]
        movzx   eax, BYTE PTR [rax]
        cmp     al, 47                    ; 如果 <= '/' (47) 则不是数字
        jle     .L8
        mov     rax, QWORD PTR [rbp-8]
        movzx   eax, BYTE PTR [rax]
        cmp     al, 57                    ; 如果 <= '9' (57) 则是数字
        jle     .L9
.L8:
        ; 非数字字符 -> 打印错误并返回 1
        mov     rax, QWORD PTR stderr[rip]
        mov     rcx, rax
        mov     edx, 26
        mov     esi, 1
        mov     edi, OFFSET FLAT:.LC1
        call    fwrite
        mov     eax, 1
        jmp     .L15
.L9:
        add     QWORD PTR [rbp-8], 1      ; 指针++（移动到下一个字符）
.L7:
        mov     rax, QWORD PTR [rbp-8]
        movzx   eax, BYTE PTR [rax]
        test    al, al
        jne     .L10                      ; 如果不是 NUL，则继续检查

        ; 所有字符均为数字，调用 strtol(buf, NULL, 10)
        lea     rax, [rbp-80]
        mov     edx, 10                   ; base = 10
        mov     esi, 0                    ; endptr = NULL
        mov     rdi, rax                  ; nptr = buf
        call    strtol
        mov     QWORD PTR [rbp-40], rax   ; 保存转换结果（long）到 [rbp-40]

        ; 验证范围 1..100
        cmp     QWORD PTR [rbp-40], 0
        jle     .L11
        cmp     QWORD PTR [rbp-40], 100
        jle     .L12
.L11:
        ; 超出范围 -> 打印错误并返回 1
        mov     rax, QWORD PTR stderr[rip]
        mov     rcx, rax
        mov     edx, 26
        mov     esi, 1
        mov     edi, OFFSET FLAT:.LC1
        call    fwrite
        mov     eax, 1
        jmp     .L15

.L12:
        ; 计算 1..n 的累加和（使用 64-bit 寄存器）
        mov     QWORD PTR [rbp-16], 0     ; sum = 0
        mov     QWORD PTR [rbp-24], 1     ; i = 1
        jmp     .L13
.L14:
        mov     rax, QWORD PTR [rbp-24]
        add     QWORD PTR [rbp-16], rax   ; sum += i
        add     QWORD PTR [rbp-24], 1     ; i++
.L13:
        mov     rax, QWORD PTR [rbp-24]
        cmp     rax, QWORD PTR [rbp-40]
        jle     .L14                      ; if (i <= n) goto L14

        ; 输出格式化结果：printf("\r\nsum 1 to %ld = %ld\r\n", n, sum)
        mov     rdx, QWORD PTR [rbp-16]   ; second arg -> sum (RDX)
        mov     rax, QWORD PTR [rbp-40]   ; temp = n
        mov     rsi, rax                  ; first arg -> n (RSI)
        mov     edi, OFFSET FLAT:.LC2     ; format string -> RDI
        mov     eax, 0
        call    printf
        mov     eax, 0
.L15:
        leave
        ret