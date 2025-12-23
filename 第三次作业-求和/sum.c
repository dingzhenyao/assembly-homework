/* sum.c - C 实现 sum.asm 的功能
 * 功能：计算 1 到 100 的累加和，并打印结果
 * 对应汇编：sum.asm 将结果存入数据段变量 sum 并调用 print_num 输出
 */

#include <stdio.h>

int main(void) {
    int total = 0;
    for (int i = 1; i <= 100; ++i) {
        total += i;
    }

    /* 与汇编中输出格式相似 */
    printf("sum 1 to 100 = %d\r\n", total);
    return 0;
}
