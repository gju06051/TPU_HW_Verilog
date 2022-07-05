#include <stdio.h>
#include <stdint.h>
#include "xparameters.h"
#include "xil_io.h"
#include "xtime_l.h"  // To measure of processing time
#include <stdlib.h>	  // To generate rand value

#define AXI_DATA_WIDTH 32
#define DATA_WIDTH 8
#define IN_X 14//16
#define IN_Y 14//16
#define IC 32//32
#define OC 64//64
#define K 3
#define OUT_X 288//288
#define OUT_Y 196//196
#define PE_SIZE 16
#define padding 1

typedef struct  {
        unsigned int data_0 : DATA_WIDTH;
        unsigned int data_1 : DATA_WIDTH;  
        unsigned int data_2 : DATA_WIDTH;
        unsigned int data_3 : DATA_WIDTH;
    } Flags;

int main(void) {
    
    unsigned int INIT_IN_TENSOR[IC][IN_X][IN_Y];
    for(int i = 0; i < IC ; i++) {
        for(int k = 0; k < IN_X; k++){
            for(int l = 0; l <IN_Y; l++){
                INIT_IN_TENSOR[i][k][l] = (l+1)+(k*IN_X)+i;
                switch (l % 4){
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
                            Xil_Out32((XPAR_LAB13_MATBI_0_BASEADDR) + ((MEM0_DATA_REG+l*4)*AXI_DATA_BYTE), bitfild);
                            break;
                    };
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
    

    //// AXI_READ ////

    /* no padding
    Flags bitfild[4];
    unsigned int IN_TENSOR[IC][IN_X][IN_Y];
    for(int i = 0; i < IC ; i++) {
        for(int k = 0; k < IN_X; k++){
            if(k != 0 && k != IN_X-1) {
                bitfild[0] = Xil_In32((XPAR_LAB13_MATBI_0_BASEADDR) + (MEM0_DATA_REG*AXI_DATA_BYTE));
                bitfild[1] = Xil_In32((XPAR_LAB13_MATBI_0_BASEADDR) + (MEM0_DATA_REG*AXI_DATA_BYTE));
                bitfild[2] = Xil_In32((XPAR_LAB13_MATBI_0_BASEADDR) + (MEM0_DATA_REG*AXI_DATA_BYTE));
                bitfild[3] = Xil_In32((XPAR_LAB13_MATBI_0_BASEADDR) + (MEM0_DATA_REG*AXI_DATA_BYTE));
                for(int l = 0 ; l < IN_Y; l++){
                    if(l != 0 && l != 1){
                        switch (l % 4){
                                case 0:
                                    IN_TENSOR[i][k][l] = bitfild[((l-2)/4)+1].data_1;
                                    break;
                                case 1:
                                    IN_TENSOR[i][k][l] = bitfild[((l-2)/4)+1].data_0;
                                    break;
                                case 2:
                                    IN_TENSOR[i][k][l] = bitfild[((l-2)/4)+1].data_3;
                                    break;
                                case 3:
                                    IN_TENSOR[i][k][l] = bitfild[((l-2)/4)+1].data_2;
                                    //printf("%d ",bitfild);
                                    //Xil_Out32
                                    break;
                        };
                    } else {
                        switch (l % 2){
                                case 0:
                                    IN_TENSOR[i][k][l] = bitfild[0].data_1;
                                    break;
                                case 1:
                                    IN_TENSOR[i][k][l] = bitfild[0].data_0;
                                    break;
                        }
                    }
                };
            } else {
              for(int l = 0 ; l < IN_Y; l++) {
                IN_TENSOR[i][k][l] = 0;
              }      
            }
        };
    };
    */

    // padding
    unsigned int IN_TENSOR[IC][IN_X+2][IN_Y+2];
    for(int i = 0; i < IC ; i++) {
        for(int k = 0; k < IN_X+2; k++){
            if(k != 0 && k != IN_X-1) {
                bitfild[0] = Xil_In32((XPAR_LAB13_MATBI_0_BASEADDR) + (MEM0_DATA_REG*AXI_DATA_BYTE));
                bitfild[1] = Xil_In32((XPAR_LAB13_MATBI_0_BASEADDR) + (MEM0_DATA_REG*AXI_DATA_BYTE));
                bitfild[2] = Xil_In32((XPAR_LAB13_MATBI_0_BASEADDR) + (MEM0_DATA_REG*AXI_DATA_BYTE));
                bitfild[3] = Xil_In32((XPAR_LAB13_MATBI_0_BASEADDR) + (MEM0_DATA_REG*AXI_DATA_BYTE));
                for(int l = 0 ; l < IN_Y+2; l++){
                    if(l != 0 && l != IN_Y+1) {
                        if(l != 1 && l != 2){
                            switch (l % 4){
                                    case 0:
                                        IN_TENSOR[i][k][l] = bitfild[((l-2)/4)+1].data_2;
                                        break;
                                    case 1:
                                        IN_TENSOR[i][k][l] = bitfild[((l-2)/4)+1].data_1;
                                        break;
                                    case 2:
                                        IN_TENSOR[i][k][l] = bitfild[((l-2)/4)+1].data_0;
                                        break;
                                    case 3:
                                        IN_TENSOR[i][k][l] = bitfild[((l-2)/4)+1].data_3;
                                        //printf("%d ",bitfild);
                                        //Xil_Out32
                                        break;
                            };
                        } else {
                        switch (l % 2){
                                case 0:
                                    IN_TENSOR[i][k][l] = bitfild[0].data_0;
                                    break;
                                case 1:
                                    IN_TENSOR[i][k][l] = bitfild[0].data_1;
                                    break;
                        }
                    }
                } else {
                    IN_TENSOR[i][k][l] = 0;
                };
            } 
        } else {
              for(int l = 0 ; l < IN_Y+2; l++) {
                IN_TENSOR[i][k][l] = 0;
              }      
            }
        };
    };

    //// im2col transform ////
    unsigned int OUT_MATRIX[OUT_X][OUT_Y];
    unsigned int in_channel;
    unsigned int row;
    unsigned int col;
     for(int i = 0; i < OUT_Y; i++){
         for(int k = 0; k < OUT_X; k++){
             in_channel = k / (K*K);
             row = (i / 12) + (k / K) % K; // change 14 to variable = striding num
             col = (k % K) + (i % 12);
             OUT_MATRIX[k][i] = IN_TENSOR[in_channel][row][col];
         };
     }
     /*
     for(int i = 0; i < OUT_X; i++){
         for(int k = 0; k < OUT_Y; k++){
            printf("%-2d ",OUT_MATRIX[i][k]);
         };
         printf("\n");
         if(i!=0 && i%9 == 8)
             printf("\n");
     };
    */

    //// AXI_WRITE ////
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
                            Xil_Out32((XPAR_LAB13_MATBI_0_BASEADDR) + ((MEM0_DATA_REG+m*4)*AXI_DATA_BYTE), bitfild);
                        break;
                    };
                };
            //printf("\n");
            };
        };
    }
    
    return 0;
}   