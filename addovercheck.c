#include <stdio.h>

int main() {
    short a, b, sum;  // 16位有符号数，范围-32768 ~ 32767
    printf("请输入两个16位有符号整数（范围-32768~32767）：\n");
    printf("输入第一个数a：");
    scanf("%hd", &a);
    printf("输入第二个数b：");
    scanf("%hd", &b);

    // 计算和
    sum = a + b;

    // 溢出检测逻辑：同号相加，结果异号则溢出
    int overflow = 0;
    if ((a > 0 && b > 0 && sum < 0) || (a < 0 && b < 0 && sum > 0)) {
        overflow = 1;
    }

    // 输出结果或报错
    if (overflow) {
        printf("错误：有符号数加法溢出！\n");
    } else {
        printf("结果：%hd + %hd = %hd\n", a, b, sum);
    }

    return 0;
}