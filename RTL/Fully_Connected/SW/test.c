# define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>

#define MEM_DEPTH 4096
#define NUM_CORE 4

int main(void) {
    
    srand(10);
    FILE *fp_in_node, *fp_in_weight, *fp_ot_result;

    fp_in_node      = fopen("ref_c_rand_input_node.txt", "w");
    fp_in_weight    = fopen("ref_c_rand_input_weight.txt", "w");
    fp_ot_result    = fopen("ref_c_result.txt", "w");

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