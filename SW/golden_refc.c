#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <time.h>
#define RESHAPE_WEIGHT_COL  288 
#define COL_EXTENSION  6
#define RESHAPE_WEIGHT_ROW  64  
#define ROW_EXTENSION  6

#define IM2COL_IFMAP_COL  196
#define IM2COL_IFMAP_ROW  288

#define OFMAP_COL 196
#define OFMAP_ROW 64

#define PE_SIZE 14
#define MEM_DEPTH 4096 
#define NUM_CORE 4

typedef union {
    int result;
    struct {
        uint8_t b0;
        uint8_t b1;
        uint8_t b2;
        uint8_t b3;
    } bdata;
} Bitfild;


int main(int argc, char **argv) {
	srand(time(NULL));

	FILE *fp_reshape_weight, *fp_im2col_Ifmap, *fp_ot_Ofmap;
	fp_reshape_weight = fopen("C:/FPGA_Proj/CNN_golden_ref/ref_c_rand_reshape_weight.txt","w");
	fp_im2col_Ifmap = fopen("C:/FPGA_Proj/CNN_golden_ref/ref_c_rand_im2col_Ifmap.txt","w");
	fp_ot_Ofmap = fopen("C:/FPGA_Proj/CNN_golden_ref/ref_c_ot_Ofmap.txt","w");
	

    // make random reshape_weight_matrix
    uint8_t reshape_weight_matrix[RESHAPE_WEIGHT_ROW + ROW_EXTENSION][RESHAPE_WEIGHT_COL + COL_EXTENSION];
    for (int i = 0; i < RESHAPE_WEIGHT_ROW + ROW_EXTENSION; i++){
        if(i < RESHAPE_WEIGHT_ROW){
            for (int k = 0; k < RESHAPE_WEIGHT_COL + COL_EXTENSION; k++) {
                if(k < RESHAPE_WEIGHT_COL) {
                    reshape_weight_matrix[i][k] = rand()%256;
                } else {
                    reshape_weight_matrix[i][k] = 0; // extension to zeros
                }
            }
        } else {
            for (int k = 0; k < RESHAPE_WEIGHT_COL + COL_EXTENSION; k++) {
                reshape_weight_matrix[i][k] = 0; // extension to zeros
            }
        }
    }
    for(int i = 0; i < ((RESHAPE_WEIGHT_COL + COL_EXTENSION) / PE_SIZE); i++){
        for(int k = 0; k < ((RESHAPE_WEIGHT_ROW + ROW_EXTENSION)/PE_SIZE); k++){
            //printf("time i = %d, k = %d\n",i,k);
            for(int l = 0; l < PE_SIZE; l++){
                for(int m = 0; m < PE_SIZE; m++){
                    fprintf (fp_reshape_weight, "%u ", reshape_weight_matrix[l + k*(PE_SIZE)][m + i*(PE_SIZE)]);
                    //printf("%d ",im2col_ifmap_matrix[m + k*(PE_SIZE)][(PE_SIZE-1)-l + i*(PE_SIZE)]);
                }
                fprintf (fp_reshape_weight, "\n"); 
            }
            //printf("\n\n");
        }
        //printf("\n\n");
    }

    uint8_t check_weight[RESHAPE_WEIGHT_COL + COL_EXTENSION];
    for(int i = 0; i < RESHAPE_WEIGHT_COL + COL_EXTENSION; i++) {
        check_weight[i] = reshape_weight_matrix[0][i];
    }
    


    // make random im2col_ifmap_matrix
    uint8_t im2col_ifmap_matrix[IM2COL_IFMAP_ROW + ROW_EXTENSION][IM2COL_IFMAP_COL];
    for (int i = 0; i < IM2COL_IFMAP_ROW + ROW_EXTENSION; i++){
        if(i < IM2COL_IFMAP_ROW){
            for (int k = 0; k < IM2COL_IFMAP_COL; k++) {
                    im2col_ifmap_matrix[i][k] = rand()%256;
            }
        } else {
            for (int k = 0; k < IM2COL_IFMAP_COL; k++) {
                im2col_ifmap_matrix[i][k] = 0; // extension to zeros
            }
        }
    }

    

    uint8_t check_im2col[IM2COL_IFMAP_ROW + ROW_EXTENSION];
    for(int i = 0; i < IM2COL_IFMAP_ROW + ROW_EXTENSION; i++) {
        check_im2col[i] = im2col_ifmap_matrix[i][0];
    }

    int check = 0;
    for(int i = 0; i < RESHAPE_WEIGHT_COL + COL_EXTENSION; i++) {
       check += check_im2col[i] * check_weight[i];
    }
    printf("check!! %d ",check);

    printf("start");
    for(int i = 0; i < (IM2COL_IFMAP_COL / PE_SIZE); i++){
        for(int k = 0; k < ((IM2COL_IFMAP_ROW + ROW_EXTENSION)/PE_SIZE); k++){
            //printf("time i = %d, k = %d\n",i,k);
            for(int l = 0; l < PE_SIZE; l++){
                for(int m = 0; m < PE_SIZE; m++){
                    fprintf (fp_im2col_Ifmap, "%u ", im2col_ifmap_matrix[(PE_SIZE-1)-l + k*(PE_SIZE)][m + i*(PE_SIZE)]);
                    //printf("%d ",im2col_ifmap_matrix[m + k*(PE_SIZE)][(PE_SIZE-1)-l + i*(PE_SIZE)]);
                    //printf("%d %d ",m + k*(PE_SIZE), ((PE_SIZE-1)-l) + (i*(PE_SIZE)));
                }
                fprintf (fp_im2col_Ifmap, "\n"); 
            }
            //printf("\n\n");
        }
        //printf("\n\n");
    }
    printf("print result\n");
    Bitfild bitfild; 
    // make Ofmap
    uint8_t Ofmap_matrix[OFMAP_ROW][OFMAP_COL];
    int result;
    for(int i = 0 ; i < OFMAP_ROW; i++) {
        for(int k = 0; k < OFMAP_COL; k++) {
            result = 0;
            for(int l = 0; l < IM2COL_IFMAP_ROW; l++){
                result += reshape_weight_matrix[i][l] * im2col_ifmap_matrix[l][k];
            }
            bitfild.result = result;
            Ofmap_matrix[i][k] = bitfild.bdata.b0;
            //printf("%d ",result);
        }
        //printf("\n\n");
    }

    for(int i = 0; i < OFMAP_ROW; i++) {
        for(int k = 0; k < OFMAP_COL; k++) {
            fprintf (fp_ot_Ofmap, "%u ", Ofmap_matrix[i][k]);
            if((k % 14) == 13)
                fprintf (fp_ot_Ofmap, "\n");
        }
    }

    printf("first\n");
    int acc_check_arr[PE_SIZE][PE_SIZE];
    for(int i = 0 ; i < PE_SIZE; i++) {
        for(int k = 0; k < PE_SIZE; k++) {
            result = 0;
            for(int l = 0; l < PE_SIZE; l++){
                result += reshape_weight_matrix[i][l] * im2col_ifmap_matrix[l][k];
            }
            acc_check_arr[i][k] = result;
            printf("%d ",acc_check_arr[i][k]);
        }
        printf("\n\n");
    }

    printf("second\n");
    int acc_check_arr_2[PE_SIZE][PE_SIZE];
    for(int i = 0 ; i < PE_SIZE; i++) {
        for(int k = 0; k < PE_SIZE; k++) {
            result = 0;
            for(int l = 0; l < PE_SIZE; l++){
                result += reshape_weight_matrix[i][14+l] * im2col_ifmap_matrix[l+14][k];
            }
            acc_check_arr_2[i][k] = result;
            printf("%d ",acc_check_arr_2[i][k]);
        }
        printf("\n\n");
    }

    printf("result\n");
    int acc_check_arr_3[PE_SIZE][PE_SIZE];
    for(int i = 0 ; i < PE_SIZE; i++) {
        for(int k = 0; k < PE_SIZE; k++) {
            acc_check_arr_3[i][k] = acc_check_arr[i][k] + acc_check_arr_2[i][k];
            printf("%d ",acc_check_arr_3[i][k]);
        }
        printf("\n\n");
    }

	fclose(fp_reshape_weight);
	fclose(fp_im2col_Ifmap);
	fclose(fp_ot_Ofmap);
    
	return 0;
}
