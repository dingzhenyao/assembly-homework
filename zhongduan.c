#include <stdio.h>

// 溢出提示字符串（需以$结尾，配合DOS中断09h输出）
char msg_overflow[] = "错误：有符号数加法溢出！$";

// 自定义INTO中断服务程序：输出溢出提示并返回
void into_service() {
    __asm__ __volatile__ (
        "push ax\n"   // 现场保护：保存AX
        "push dx\n"   // 现场保护：保存DX
        "mov ah, 09h\n"  // DOS功能：输出字符串
        "lea dx, %1\n"   // 加载字符串地址到DX
        "int 21h\n"      // 执行输出
        "pop dx\n"    // 现场恢复：恢复DX
        "pop ax\n"    // 现场恢复：恢复AX
        "iret\n"      // 中断返回（实模式用iret）
        :
        : "m" (msg_overflow)  // 输入：msg_overflow的地址
    );
}

// 修改4号中断向量，指向自定义服务程序
void set_interrupt_vector() {
    __asm__ __volatile__ (
        "cli\n"       // 关中断（避免修改向量时被中断打断）
        "mov ax, 0\n"
        "mov es, ax\n" // 段寄存器ES指向0段（中断向量表在0段）
        "mov word ptr es:[16], %0\n"    // 设置4号中断的偏移地址（4*4=16）
        "mov word ptr es:[18], cs\n"    // 设置4号中断的段地址（当前代码段）
        "sti\n"       // 开中断
        :
        : "r" (into_service)  // 输入：into_service的地址
    );
}

int main() {
    short a = 32767;  // 16位有符号数最大值
    short b = 1;      // 触发溢出的加数
    short sum;

    // 步骤1：修改4号中断向量，指向自定义服务程序
    set_interrupt_vector();

    // 步骤2：执行有符号数加法，构造溢出（OF=1）并触发INTO
    __asm__ __volatile__ (
        "mov ax, %1\n"  // 加载第一个数到AX
        "mov bx, %2\n"  // 加载第二个数到BX
        "add ax, bx\n"  // 有符号数加法：32767 + 1 → 溢出，OF=1
        "into\n"        // 触发INTO中断（因OF=1，执行4号中断服务程序）
        "mov %0, ax\n"  // 将结果保存到sum
        : "=r" (sum)    // 输出：sum
        : "r" (a), "r" (b)  // 输入：a和b
    );

    return 0;
}
