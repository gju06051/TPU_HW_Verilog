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

typedef struct  {
        unsigned int data_0 : DATA_WIDTH;
        unsigned int data_1 : DATA_WIDTH;  
        unsigned int data_2 : DATA_WIDTH;
        unsigned int data_3 : DATA_WIDTH;
} Flags;

int main(void) {

    


    return 0;
}
