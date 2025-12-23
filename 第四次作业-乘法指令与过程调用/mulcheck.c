/* mulcheck.c - C 实现 mulcheck.asm 的功能
 * 功能：对内置的 9x9 乘法表（含错误项）进行校验，输出所有不正确的 (i, j) 条目，格式为："i j error"
 *       程序开始打印标题 "x y"，结束打印 "accomplish!" 并换行。
 */

#include <stdio.h>

int main(void) {
    /* 与汇编中相同的 9x9 表（逐行存储），某些位置故意有错误 */
    unsigned char table[9*9] = {
        7,2,3,4,5,6,7,8,9,
        2,4,7,8,10,12,14,16,18,
        3,6,9,12,15,18,21,24,27,
        4,8,12,16,7,24,28,32,36,
        5,10,15,20,25,30,35,40,45,
        6,12,18,24,30,7,42,48,54,
        7,14,21,28,35,42,49,56,63,
        8,16,24,32,40,48,56,7,72,
        9,18,27,36,45,54,63,72,81
    };

    /* 标题（对应汇编中的 msg1） */
    printf("x y\r\n");

    for (int i = 1; i <= 9; ++i) {
        for (int j = 1; j <= 9; ++j) {
            unsigned char val = table[(i-1)*9 + (j-1)];
            int correct = i * j;
            if (val != (unsigned char)correct) {
                /* 输出格式与汇编相似：i 空格 j 然后 " error" 和换行 */
                printf("%d %d error\r\n", i, j);
            }
        }
    }

    /* 完成提示（对应 overmsg），加上换行 */
    printf("\r\naccomplish!\r\n");

    return 0;
}
