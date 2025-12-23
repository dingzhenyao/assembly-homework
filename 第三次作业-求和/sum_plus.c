/* sum_plus.c - C 实现 sum-plus.asm 的功能
 * 功能：提示用户输入一个 1..100 的整数 x，计算并输出 1 到 x 的累加和；若输入无效或超出范围则报错
 * 对应汇编：sum-plus.asm 使用缓冲区读取字符串，调用 dec_str2num 转换并验证范围，然后计算累加和并调用 print_num 输出
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(void) {
    char buf[32];
    long n;

    printf("input:");
    if (!fgets(buf, sizeof(buf), stdin)) {
        fprintf(stderr, "error,please input again\r\n");
        return 1;
    }

    /* 去掉换行 */
    size_t len = strlen(buf);
    if (len > 0 && (buf[len-1] == '\n' || buf[len-1] == '\r')) buf[--len] = '\0';

    /* 将字符串转换为整数，并验证所有字符均为数字 */
    char *p = buf;
    if (*p == '\0') {
        fprintf(stderr, "error,please input again\r\n");
        return 1;
    }

    for (; *p; ++p) {
        if (*p < '0' || *p > '9') {
            fprintf(stderr, "error,please input again\r\n");
            return 1;
        }
    }

    n = strtol(buf, NULL, 10);
    if (n < 1 || n > 100) {
        fprintf(stderr, "error,please input again\r\n");
        return 1;
    }

    long sum = 0;
    for (long i = 1; i <= n; ++i) sum += i;

    printf("\r\nsum 1 to %ld = %ld\r\n", n, sum);
    return 0;
}
