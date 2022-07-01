#include <stdio.h>

#define DATA_WIDTH 8
#define IN_X 16
#define IN_Y 16
#define IC 32
#define OC 64
#define K 3
#define OUT_X 288
#define OUT_Y 196


int main(void) {
    unsigned int IN_TENSOR[IC][IN_X][IN_Y];
    unsigned int OUT_MATRIX[OUT_X][OUT_Y];
    /*
    for(){
        Xil_In32()
    };
    */
    for(int i = 0; i < OUT_Y; i++){
        for(int k = 0; k < OUT_X; k++){
            in_channel = k % (K^2)
            OUT_MATRIX[k][i] = IN_TENSOR[in_channel][];
        };
      
    }
    return 0;
}