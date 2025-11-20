#include <stdio.h>

int main() {
    printf("The 9*9 table:\n");
    for (int i = 9; i >= 1; i--) {
        for (int j = 1; j <= i; j++) {
            printf("%d*%d=%d ", i, j, i*j);
        }
        printf("\n");
    }
    return 0;
}