// random number generator for Data_Mover_BRAM test
// 
// description
//      this code generate 3 files: 
//          ref_c_rand_input_node.txt
//              generate the random number between 0 ~ 256 (because node is 8 bits)
//              4096 * 4 number generated. so each line have 4 numbers: 8bit * 4 = 32 bit
//
//          ref_c_rand_input_weight.txt
//              same as ref_c_rand_input_node.txt but this numbers considered as weight
//
//          ref_c_rand_result
//              The result of MAC operation of 2 file's numbers.
//              The first number is result of 1st column of 2 file's number: result[0] = file1[0][0] * file2[0][0] + file1[1][0] * file2[1][0] + file1[2][0] * file2[2][0] ...


#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>

#define MEM_DEPTH 4096
#define NUM_CORE 7

int main(void) {
    
    srand(10);
    FILE *fp_in_node, *fp_in_weight, *fp_ot_result;

    fp_in_node      = fopen("ref_c_rand_input_node_7.txt", "w");
    fp_in_weight    = fopen("ref_c_rand_input_weight_7.txt", "w");
    fp_ot_result    = fopen("ref_c_result_7.txt", "w");

    unsigned char   IN_NODE[NUM_CORE]; //8 bit
    unsigned char   IN_WEIGHT[NUM_CORE]; // 8 bit
    unsigned        OT_RESULT[NUM_CORE] = {0, }; // 32 bit

    for(int i = 0; i < MEM_DEPTH; i++) {
        for(int core = 0; core < NUM_CORE; core++) {
            IN_NODE[core] = rand()%256; // 0 ~ 256, 8 bits!
            IN_WEIGHT[core] = rand()%256; // 0 ~ 256, 8 bits!

            OT_RESULT[core] += IN_NODE[core] * IN_WEIGHT[core];
            fprintf(fp_in_node, "%d ", IN_NODE[core]);
            fprintf(fp_in_weight, "%d ", IN_WEIGHT[core]);
        }

        fprintf(fp_in_node, "\n");
        fprintf(fp_in_weight, "\n");
    }

    for(int core = 0; core < NUM_CORE; core++) {
        fprintf(fp_ot_result, "%d ", OT_RESULT[core]);
    }
    
    fclose(fp_in_node);
    fclose(fp_in_weight);
    fclose(fp_ot_result);
    
    printf("Generation success.");
    return 0;
}