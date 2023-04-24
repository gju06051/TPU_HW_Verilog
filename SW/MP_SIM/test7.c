// random number generator for Data_Mover_BRAM test
// 
// description
//      this code generate 2 files: 
//          ref_c_rand_input_node_MP.txt
//              generate the random number between 0 ~ 256 (because node is 8 bits)
//              1024 * 14 number generated. so each line have 4 numbers: 8bit * 4 = 32 bit
//
//          ref_c_rand_result
//              The result of pooling operation


#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>

#define MEM_DEPTH 1024
#define NUM_CORE 14 
#define POOL_SIZE 2

void max_pooling(unsigned char in_node_arr[][NUM_CORE], unsigned char* ot_result_arr); 

int main(void) {
    srand(10);
    FILE *fp_in_node, *fp_ot_result;

    fp_in_node      = fopen("ref_c_rand_input_node_MP.txt", "w");
    fp_ot_result    = fopen("ref_c_result_MP.txt", "w");

    unsigned char   IN_NODE[POOL_SIZE][NUM_CORE]; //8 bit
    unsigned char   OT_RESULT[NUM_CORE / POOL_SIZE]= {0, } ; // 8 bit

    for(int i = 0; i < (MEM_DEPTH / POOL_SIZE); i++) { // MEM DEPTH should be multiply of POOL_SIZE
        for(int pool_index = 0; pool_index < POOL_SIZE; pool_index++) {
            for(int core = 0; core < NUM_CORE; core++) {
                IN_NODE[pool_index][core] = rand()%256;
            }
        }

        for(int pool_index = 0; pool_index < POOL_SIZE; pool_index++) {
            for(int core = 0; core < NUM_CORE; core++) {
                fprintf(fp_in_node, "%d ", IN_NODE[pool_index][core]);
            }

            fprintf(fp_in_node, "\n");
        }

        max_pooling(IN_NODE, OT_RESULT);

        for(int core = 0; core < NUM_CORE; core += POOL_SIZE) {
            fprintf(fp_ot_result, "%d ", OT_RESULT[core / POOL_SIZE]);
        }

        fprintf(fp_ot_result, "\n");
    }
    
    fclose(fp_in_node);
    fclose(fp_ot_result);
    
    printf("Generation success.");
    return 0;
}

void max_pooling(unsigned char in_node_arr [][NUM_CORE], unsigned char ot_result_arr []) {
    for(int core = 0; core < NUM_CORE; core += POOL_SIZE) { // Stride
        unsigned char max = 0;

        for(int j = 0; j < POOL_SIZE; j++) {
            for(int k = 0; k < POOL_SIZE; k++) {
                max = ((in_node_arr[j][core + k])) > max ? ((in_node_arr[j][core + k])) : max;
            }
        }

        ot_result_arr[core / POOL_SIZE] = max;
        
    }
}