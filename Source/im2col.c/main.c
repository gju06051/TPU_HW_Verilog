#include <stdio.h>
#include <stdint.h>
//#include "xparameters.h"
//#include "xil_io.h"
//#include "xtime_l.h"  // To measure of processing time
#include <stdlib.h>	  // To generate rand value

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

typedef union  {
		unsigned int axi_write_data;
		struct {
			uint8_t data_0;
			uint8_t data_1;
			uint8_t data_2;
			uint8_t data_3;
		} bit_data;
    } Flags;

int main(void) {

    // AXI_WRITE for test
	printf("hello dwadwf");

    Flags bitfild_init;
    uint8_t INIT_IN_TENSOR[IC][IN_X][IN_Y];
    for(int i = 0; i < IC ; i++) {
        for(int k = 0; k < IN_X; k++){
            for(int l = 0; l <IN_Y; l++){
                INIT_IN_TENSOR[i][k][l] = (l+1)+(k*IN_X)+i;
                //printf("%2d \n",(l+1)+(k*IN_X)+i);

                if(l != 0 && l != 1){
                	//printf("index : %d mod : %d  data : %d ",l,(l%4),INIT_IN_TENSOR[i][k][l]);
                    switch (l % 4){
                            case 0:
                            	printf("%u ",INIT_IN_TENSOR[i][k][l]);
                                bitfild_init.bit_data.data_1 = INIT_IN_TENSOR[i][k][l];
                                printf("%u \n",bitfild_init.bit_data.data_1);
                                break;
                            case 1:
                            	printf("%u ",INIT_IN_TENSOR[i][k][l]);
                                bitfild_init.bit_data.data_0 = INIT_IN_TENSOR[i][k][l];
                                printf("%u \n",bitfild_init.bit_data.data_0);
                                printf("result %d \n\n",bitfild_init.axi_write_data);
                                //Xil_Out32((XPAR_MYIP_V1_0_0_BASEADDR) + ( (((l-2)/4)+1)*AXI_DATA_BYTE), bitfild_init.axi_write_data);
                                break;
                            case 2:
                            	printf("%u ",INIT_IN_TENSOR[i][k][l]);
                                bitfild_init.bit_data.data_3 = INIT_IN_TENSOR[i][k][l];
                                printf("%u \n",bitfild_init.bit_data.data_3);
                                break;
                            case 3:
                            	printf("%u ",INIT_IN_TENSOR[i][k][l]);
                                bitfild_init.bit_data.data_2 = INIT_IN_TENSOR[i][k][l];
                                printf("%u \n",bitfild_init.bit_data.data_2);
                                break;
                    }
                } else {
                    switch (l % 2){
                            case 0:
                            	bitfild_init.bit_data.data_3 = 0;
                            	bitfild_init.bit_data.data_2 = 0;
                            	bitfild_init.bit_data.data_1 = INIT_IN_TENSOR[i][k][l];
                                break;
                            case 1:
                            	bitfild_init.bit_data.data_0 = INIT_IN_TENSOR[i][k][l];
                            	//printf("%d ",bitfild_init.axi_write_data);
                                //Xil_Out32((XPAR_MYIP_V1_0_0_BASEADDR)+(0*AXI_DATA_BYTE), bitfild_init.axi_write_data);
                                break;
                    }
                }

            }
            //printf("\n");
        }
        //printf("\n\n");
    }


    /*
    for(int i = 0; i < IC ; i++) {
        for(int k = 0; k < IN_X; k++){
            for(int l = 0; l <IN_Y; l++){
                printf("%-2d ",IN_TENSOR[i][k][l]);
            }
            printf("\n");
        }
        printf("\n\n\n");
    }
    */

    //// AXI_READ ////
    //Flags bitfild[4];

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
    uint8_t IN_TENSOR[IC][IN_X+2][IN_Y+2];
    for(int i = 0; i < IC ; i++) {
        for(int k = 0; k < IN_X+2; k++){
            if(k != 0 && k != IN_X+1) {
                for(int l = 0 ; l < IN_Y+2; l++){
                    if(l != 0 && l != IN_Y+1) {
                        IN_TENSOR[i][k][l] = INIT_IN_TENSOR[i][k-1][l-1];
                    } else {
                        IN_TENSOR[i][k][l] = 0;
                    }
                    printf("%-3d ",IN_TENSOR[i][k][l]);
                }
            } else {
                for(int l = 0 ; l < IN_Y+2; l++){
                    IN_TENSOR[i][k][l] = 0;
                    printf("%-3d ",IN_TENSOR[i][k][l]);
                }
            }
            printf("\n");
        }
        printf("\n\n");
    }
    printf("%d",IN_TENSOR[3][2][2]);


    /*
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
                                        IN_TENSOR[i][k][l] = bitfild[((l-3)/4)+1].data_2;
                                        break;
                                    case 1:
                                        IN_TENSOR[i][k][l] = bitfild[((l-3)/4)+1].data_1;
                                        break;
                                    case 2:
                                        IN_TENSOR[i][k][l] = bitfild[((l-3)/4)+1].data_0;
                                        break;
                                    case 3:
                                        IN_TENSOR[i][k][l] = bitfild[((l-3)/4)+1].data_3;
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
    */



    //// im2col transform + extension ////
    uint8_t OUT_MATRIX[OUT_X][OUT_Y] = {0,};
    unsigned int in_channel;
    unsigned int row;
    unsigned int col;
     for(int i = 0; i < OUT_Y; i++){
         for(int k = 0; k < OUT_X; k++){
                if(i < OUT_Y-12){
                    in_channel = k / (K*K);
                    row = (i / 14) + (k / K) % K; // change 14 to variable = striding num
                    col = (k % K) + (i % 14);
                    OUT_MATRIX[k][i] = IN_TENSOR[in_channel][row][col];

                    //printf("[%d %d %d] : %d \n",in_channel, row, col, OUT_MATRIX[k][i]);
                } else {
                    OUT_MATRIX[k][i] = 0;
                }
         }
         //printf("\n\n");
     }



     for(int i = 0; i < OUT_X; i++){
         for(int k = 0; k < OUT_Y; k++){
            printf("%d ",OUT_MATRIX[i][k]);
         }
         printf("\n\n");
         if(i!=0 && i%9 == 8)
             printf("\n");
     }



    //// AXI_WRITE ////
     
    Flags bitfild_write;
    uint8_t check_arr[3744][16];
    int out_col = OUT_Y / PE_SIZE;
    int out_row = OUT_X / PE_SIZE;

    for(int i = 0; i < out_col; i++){
        for(int k = 0; k < out_row; k++){
            for(int l = 0; l < PE_SIZE; l++){
                for(int m = 0; m < PE_SIZE; m++){
                	check_arr[i+k+l][m] = OUT_MATRIX[(k*PE_SIZE)+PE_SIZE-1-l][m+(PE_SIZE*i)];
                    printf("%d %d ",(k*PE_SIZE)+PE_SIZE-1-l,m+(PE_SIZE*i));
                    switch (m % 4){
                        case 0:
                        	bitfild_write.bit_data.data_3 = OUT_MATRIX[(k*PE_SIZE)+PE_SIZE-1-l][m+(PE_SIZE*i)];
                            break;
                        case 1:
                        	bitfild_write.bit_data.data_2 = OUT_MATRIX[(k*PE_SIZE)+PE_SIZE-1-l][m+(PE_SIZE*i)];
                            break;
                        case 2:
                        	bitfild_write.bit_data.data_1 = OUT_MATRIX[(k*PE_SIZE)+PE_SIZE-1-l][m+(PE_SIZE*i)];
                            break;
                        case 3:
                        	bitfild_write.bit_data.data_0 = OUT_MATRIX[(k*PE_SIZE)+PE_SIZE-1-l][m+(PE_SIZE*i)];
                            //printf("%d ",bitfild);
                            //Xil_Out32((XPAR_MYIP_V1_0_0_BASEADDR) + ((m/4)*AXI_DATA_BYTE), bitfild_write.axi_write_data);
                        break;
                    };
                };
            //printf("\n");
            };
        };
    }

    //AXI_READ_FOR_TEST
    Flags bitfild_read[4];
    uint8_t axi_check_arr[3744][16];
    for(int i = 0 ; i < 3744 ; i ++){
    	 bitfild_read[0].axi_write_data = Xil_In32((XPAR_MYIP_V1_0_0_BASEADDR) + (4*AXI_DATA_BYTE));
    	 bitfild_read[1].axi_write_data = Xil_In32((XPAR_MYIP_V1_0_0_BASEADDR) + (5*AXI_DATA_BYTE));
    	 bitfild_read[2].axi_write_data = Xil_In32((XPAR_MYIP_V1_0_0_BASEADDR) + (6*AXI_DATA_BYTE));
    	 bitfild_read[3].axi_write_data = Xil_In32((XPAR_MYIP_V1_0_0_BASEADDR) + (7*AXI_DATA_BYTE));

		 for(int m = 0 ; m < 13 ; m = m + 4)
		 {
			 axi_check_arr[i][m]   = bitfild_read[m/4].bit_data.data_3;
			 axi_check_arr[i][m+1] = bitfild_read[m/4].bit_data.data_2;
			 axi_check_arr[i][m+2] = bitfild_read[m/4].bit_data.data_1;
			 axi_check_arr[i][m+3] = bitfild_read[m/4].bit_data.data_0;
		 };
	};

    for(int i = 0 ; i<3744; i ++) {
    	for ( int k = 0 ; k < 16; k++){
    		if(axi_check_arr[i][k]!=check_arr[i][k]){
    			printf("error!\n");
    			break;
    		} else {
    			printf("success!! sw : %d hw : %d\n",check_arr[i][k],axi_check_arr[i][k]);
    		}
    	};
    };


    return 0;
}
