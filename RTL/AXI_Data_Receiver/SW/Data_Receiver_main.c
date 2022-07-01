// AXI_Data_Recevier test file
// 
// description
//      generate random number and Write the number to BRAM
//      and then Read from Bram. then Compare 2 numbers.
//
//      User decide what action to run by give 1 or 2 (see the message below)
//      User give srand value
//


#include <stdio.h>
#include "xparameters.h"
#include "xil_io.h"
#include <stdlib.h>

#define WRITE 1
#define READ 2
#define AXI_DATA_BYTE 4

#define MEM0_ADDR_REG 2
#define MEM0_DATA_REG 3

#define MEM_DEPTH 512

int main(void) {
    int user_data; // User give the data
    int read_data // data from the HW(BRAM)

    int write_buf [MEM_DEPTH];
    int read_buf [MEM_DEPTH]; // buffer to get R/W data from HW

    while(1) {
        printf("input Run mode\n");
        printf("1. To write, enter the '1'\n");
        printf("2. To Read, enter the '2'\n");
    
        scanf("%d", &user_data);

        if(user_data == WRITE) {
            Xil_Out32(() + (MEM0_ADDR_REG * AXI_DATA_BYTE) , (u32)(0x00000000)); // Reset(Clear)

            printf("input the srand value: ");
            scanf("%d", &user_data);
            srand(user_data)

            for(int i = 0; i < MEM_DEPTH; i++) {
                write_buf[i] = rand(); // generate random number
                Xil_out32(() + (MEM0_DATA_REG * AXI_DATA_BYTE), write_buf[i])  // write random number to bram
            }
        } else if (user_data == READ) {
            Xil_Out32(() + (MEM0_ADDR_REG * AXI_DATA_BYTE), (u32)(0x00000000)) // Reset(Clear)
            for(int i = 0; i < MEM_DEPTH; i++) {
                read_data = Xil_In32(() + (MEM0_DATA_REG * AXI_DATA_BYTE));

                if(read_data != write_buf[i]) {
                    printf("Data MissMatch. index: %d, Write_data: %d, Read_data: %d\n", i, write_buf[i], read_buf[i]);
                }
            }

            printf("There is no MissMatch. \n");
        } else {
            printf("Please Enter 1 or 2. 1 is Write and 2 is Read\n");
            continue;
        }
    }

    return 0;
}