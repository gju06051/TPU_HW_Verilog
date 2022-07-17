#include <stdio.h>
#include <stdint.h>
#include <malloc.h>
//#include "xparameters.h"
//#include "xil_io.h"
//#include "xtime_l.h"  // To measure of processing time
#include <stdlib.h>	  // To generate rand value
#include <assert.h>
#define AXI_DATA_BYTE 4
#define AXI_DATA_WIDTH 32
#define DATA_WIDTH 8
#define IN_X 14
#define IN_Y 14
#define IC 32
#define OC 64
#define K 3
#define OUT_X 288
#define OUT_Y 208
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
	printf("start\n");

	uint8_t*** INIT_IN_TENSOR;
    INIT_IN_TENSOR = (uint8_t***)malloc(sizeof(uint8_t**)*IC);
    for(int i = 0; i < IC ; i++) {
        INIT_IN_TENSOR[i] = (uint8_t**)malloc(sizeof(uint8_t*)*IN_X);
    }
    for(int i = 0; i < IC ; i++) {
        for(int k = 0; k < IN_X; k++){
            INIT_IN_TENSOR[i][k] = (uint8_t*)malloc(sizeof(uint8_t)*IN_Y);
        }
    }


    for(int i = 0; i < IC ; i++) {
        for(int k = 0; k < IN_X; k++){
            for(int l = 0; l <IN_Y; l++){
                INIT_IN_TENSOR[i][k][l] = (l+1)+(k*IN_X)+i;
                printf("%-2u ", INIT_IN_TENSOR[i][k][l]);
            }
            printf("\n");
        }
        printf("\n\n");
        printf("finish\n");
    };

    // Padding
    uint8_t*** IN_TENSOR;
    IN_TENSOR = (uint8_t***)malloc(sizeof(uint8_t**)*IC);
	for(int i = 0; i < IC ; i++) {
		IN_TENSOR[i] = (uint8_t**)malloc(sizeof(uint8_t*)*(IN_X+2));
		for(int k = 0; k < (IN_X+2); k++){
					IN_TENSOR[i][k] = (uint8_t*)malloc(sizeof(uint8_t)*(IN_Y+2));
				}
	}
	printf("finish_step_2");

	for(int i = 0; i < IC ; i++) {
			for(int k = 0; k < IN_X+2; k++){
				if((k != 0) && (k != IN_X+1)) {
					for(int l = 0 ; l < IN_Y+2; l++){
						if( (l != 0) && (l != IN_Y+1)) {
							IN_TENSOR[i][k][l] = INIT_IN_TENSOR[i][k-1][l-1];
							printf("%d ",IN_TENSOR[i][k][l]);
						} else {
							IN_TENSOR[i][k][l] = 0;
						}
						//printf("%-3u ",IN_TENSOR[i][k][l]);
					}
					printf("\n");
				} else {
					for(int l = 0 ; l < IN_Y+2; l++){
						IN_TENSOR[i][k][l] = 0;
						//printf("%-3u ",IN_TENSOR[i][k][l]);
					}
				}
			}
		}
	/*
    // free INIT_IN_TENSOR
    for(int i = 0; i < IC ; i++) {
		for(int k = 0; k < IN_X; k++){
			free(INIT_IN_TENSOR[i][k]);
		}
	}
    for(int i = 0; i < IC ; i++) {
		free(INIT_IN_TENSOR[i]);
	}
	free(INIT_IN_TENSOR);
*/

	printf("hello finish_first_step!");
	printf("hello finish_first_step!");
	printf("hello finish_first_step!");


    return 0;
}
