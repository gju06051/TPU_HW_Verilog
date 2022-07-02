#include <stdio.h>
#include <stdint.h>
#define DATA_WIDTH 8
#define IN_X 8//16
#define IN_Y 8//16
#define IC 8//32
#define OC 16//64
#define K 3
#define OUT_X 72//288
#define OUT_Y 36//196
#define PE_SIZE 16

typedef struct  {
        unsigned int data_0 : 8;
        unsigned int data_1 : 8;  
        unsigned int data_2 : 8;
        unsigned int data_3 : 8;
    } Flags;

int main(void) {
    unsigned int IN_TENSOR[IC][IN_X][IN_Y];
    for(int i = 0; i < IC ; i++) {
        for(int k = 0; k < IN_X; k++){
            for(int l = 0; l <IN_Y; l++){
                IN_TENSOR[i][k][l] = (l+1)+(k*IN_X)+i;
            }
        }
    }
    for(int i = 0; i < IC ; i++) {
        for(int k = 0; k < IN_X; k++){
            for(int l = 0; l <IN_Y; l++){
                printf("%-2d ",IN_TENSOR[i][k][l]);
            }
            printf("\n");
        }
        printf("\n\n\n");
    }
    unsigned int OUT_MATRIX[OUT_X][OUT_Y];
    /*
    for(){
        Xil_In32()
    };
    */
   unsigned int in_channel;
   unsigned int row;
   unsigned int col;
    for(int i = 0; i < OUT_Y; i++){
        for(int k = 0; k < OUT_X; k++){
            in_channel = k / (K*K);
            row = (i / 6) + (k / K) % K; // change 14 to variable
            col = (k % K) + (i % 6);
            OUT_MATRIX[k][i] = IN_TENSOR[in_channel][row][col];
        };
    }
    for(int i = 0; i < OUT_X; i++){
        for(int k = 0; k < OUT_Y; k++){
           printf("%-2d ",OUT_MATRIX[i][k]);
        };
        printf("\n");
        if(i!=0 && i%9 == 8)
            printf("\n");
    }

    Flags bitfild;
    int out_col = OUT_Y / PE_SIZE;
    int out_row = OUT_X / PE_SIZE;

    for(int i = 0; i < out_col; i++){
        for(int k = 0; k < out_row; k++){
            for(int l = 0; l < PE_SIZE; l++){
                for(int m = 0; m < PE_SIZE; m++){
                    printf("%d %d ",(k*PE_SIZE)+PE_SIZE-1-l,m+(PE_SIZE*i));
                    switch (m % 4){
                        case 0:
                            bitfild.data_3 = OUT_MATRIX[(k*PE_SIZE)+PE_SIZE-1-l][m+(PE_SIZE*i)];
                            break;
                        case 1:
                            bitfild.data_2 = OUT_MATRIX[(k*PE_SIZE)+PE_SIZE-1-l][m+(PE_SIZE*i)];
                            break;
                        case 2:
                            bitfild.data_1 = OUT_MATRIX[(k*PE_SIZE)+PE_SIZE-1-l][m+(PE_SIZE*i)];
                            break;
                        case 3:
                            bitfild.data_0 = OUT_MATRIX[(k*PE_SIZE)+PE_SIZE-1-l][m+(PE_SIZE*i)];
                            //printf("%d ",bitfild);
                            //Xil_Out32
                            break;
                    };
                };
                printf("\n");
            };
        };
    }
    return 0;
}