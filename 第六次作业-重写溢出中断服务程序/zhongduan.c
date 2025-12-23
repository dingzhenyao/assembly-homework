#include <stdio.h>

char msg_overflow[] = "error!overflow$";

void into_service() {
    __asm__ __volatile__ (
        "push ax\n"    /* 保存 AX */
        "push dx\n"    /* 保存 DX */
        "mov ah, 09h\n"  
        "lea dx, %1\n"   
        "int 21h\n"      
        "pop dx\n"    
        "pop ax\n"   
        "iret\n"      
        :
        : "m" (msg_overflow)  
}


/*
 * 将新的中断服务程序安装为 INT 4（使用 into_service_new）
 * 说明与之前相同：写入 IVT（偏移在 16，段在 18）。
 */
void into_service_new() {
    /* 更稳健的中断服务程序（保存更多寄存器并恢复） */
    __asm__ __volatile__ (
        "push ax\n"
        "push bx\n"
        "push cx\n"
        "push dx\n"
        "push si\n"
        "push di\n"
        "push bp\n"
        "push ds\n"

        "mov ah, 09h\n"
        "lea dx, %1\n"
        "int 21h\n"

        "pop ds\n"
        "pop bp\n"
        "pop di\n"
        "pop si\n"
        "pop dx\n"
        "pop cx\n"
        "pop bx\n"
        "pop ax\n"
        "iret\n"
        :
        : "m" (msg_overflow)
    );
}

void set_interrupt_vector() {
    __asm__ __volatile__ (
        "cli\n"
        "mov ax, 0\n"
        "mov es, ax\n"
        "mov word ptr es:[16], %0\n"
        "mov word ptr es:[18], cs\n"
        "sti\n"
        :
        : "r" (into_service_new)
    );
}
int main() {
    /* 两个 16-bit 有符号数示例：32767 + 1 会引发有符号溢出（OF=1） */
    short a = 32767;  
    short b = 1;      
    short sum;

    /* 在实模式下把 INT4 指向 into_service，用于处理 INTO 触发的溢出 */
    set_interrupt_vector();

    /*
     * 使用内联汇编做加法并用 INTO 检测溢出：
     * - add 指令会设置溢出标志（OF）
     * - INTO 指令在 OF=1 时触发 INT 4，从而调用我们安装的 into_service
     * - 无论是否发生溢出，最后将 AX 的值写回 sum（AX 会是截断后的 16-bit 结果）
     * 注意：在现代受保护/托管环境中直接修改中断向量或执行 IRET/INT 21h 是不安全的。
     */
    __asm__ __volatile__ (
        "mov ax, %1\n"  /* AX = a */
        "mov bx, %2\n"  /* BX = b */
        "add ax, bx\n"  /* AX = AX + BX，可能设置 OF */
        "into\n"        /* 如果 OF=1，触发 INT 4 */
        "mov %0, ax\n"  /* sum = AX */
        : "=r" (sum)      
        : "r" (a), "r" (b) 
    );

    return 0;
}