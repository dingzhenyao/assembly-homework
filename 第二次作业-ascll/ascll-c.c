/*
 * ascll.c - C 实现来自 ascll.asm 的功能
 * 功能：输出小写字母 a..z，每个字母后跟一个空格，每行输出 13 个字符，行尾回车换行
 * 对应 assembly 行为：使用循环计数器控制 26 次输出，行内计数到 13 时输出回车+换行
 */

#include <stdio.h>

int main(void) {
    char ch = 'a';
    int total = 26;      /* 总共 26 个小写字母 */
    int per_line = 13;   /* 每行 13 个字符 */

    for (int i = 0; i < total; ++i) {
        putchar(ch);          /* 输出当前字符 */
        putchar(' ');         /* 输出空格 */
        ch++;

        /* 当到达每行限制时换行（CR+LF） */
        if ((i + 1) % per_line == 0) {
            putchar('\r');
            putchar('\n');
        }
    }

    /* 如果最后一行没有正好换行（如果改成非 26 的总数时），可以选择追加换行： */
    if (total % per_line != 0) {
        putchar('\r');
        putchar('\n');
    }

    return 0;
}
