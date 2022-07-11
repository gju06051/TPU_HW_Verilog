#include <stdio.h>
#include <stdint.h>

#include <stdlib.h>

#define AXI_DATA_BYTE 4
#define AXI_DATA_WIDTH 32
#define DATA_WIDTH 8
#define IN_X 14//16
#define IN_Y 14//16
#define IC 32//32
#define OC 64//64
#define K 3
#define OUT_X 288//288
#define OUT_Y 208//196 + 12 for extension
#define PE_SIZE 16
#define padding 1

int main(){
    int *** A = (int***)malloc(sizeof(int**)*IC);
    for(int i = 0; i < IC ; i++) {
        A[i] = (int**)malloc(sizeof(int*)*IN_X);
        for(int k = 0; k < IN_X; k++){
            A[i][k] = (int*)malloc(sizeof(int)*IN_Y);
        }
    }

    for(int i = 0; i < IC ; i++) {
        for(int k = 0; k < IN_X; k++){
            for(int l = 0; l <IN_Y; l++){
                A[i][k][l] = (l+1)+(k*IN_X)+i;
                printf("%2d ",A[i][k][l]);
            }
            printf("\n");
        }
        printf("\n\n");
    }

    for(int i = 0; i < IC ; i++) {
        for(int k = 0; k < IN_X; k++){
            free(A[i][k]);
        }
    }

    for(int i = 0; i < IC ; i++) {
            free(A[i]);
    }

    free(A);
    
     for(int i = 0; i < IC ; i++) {
        for(int k = 0; k < IN_X; k++){
            for(int l = 0; l <IN_Y; l++){
                A[i][k][l] = (l+1)+(k*IN_X)+i;
                printf("second\n");
                printf("%2d ",A[i][k][l]);
            }
            printf("\n");
        }
        printf("\n\n");
    }
    return 0;
}