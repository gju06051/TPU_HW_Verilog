module GEMM #(
    // Primitive DATA_WIDTH
    parameter DATA_WIDTH = 8,       // Weight, Ifmap
    parameter PSUM_WIDTH = 32,      // Partial Sum
    
    parameter PE_SIZE = 14,         // Systolic Array PE NUM 
                                    // ex. if PE_SIZE = 14, use 196(=14x14) PE  
    
    parameter IC = 32,              // Input Channel
    parameter OC = 64,              // Output Channel
    parameter KERNAL_SIZE = 3
    ) 
    (
    // Port
    input clk,
    input rst_n



    );
    
    localparam IM2COL_ROW = IC * (KERNAL_SIZE**2);                              // 288(=32*3*3)
    localparam WEIGHT_ROW_NUM = IM2COL_ROW + (PE_SIZE - (IM2COL_ROW%PE_SIZE));  // 294(=288+14-8)
    localparam WEIGHT_COL_NUM = OC + (PE_SIZE - (IM2COL_ROW%PE_SIZE));          // 70(=64+14-8)
    
    localparam MEM0_DEPTH = (PE_SIZE**2)*WEIGHT_ROW_NUM / PE_SIZE;              // 4116(=196*294/14)
    localparam MEM0_DATA_WIDTH = PE_SIZE * DATA_WIDTH;                          // 112(=14*8)
    localparam MEM0_ADDR_WIDTH = $clog2(MEM0_DEPTH);                            // 13 = clog2(4116)
    
    localparam MEM1_DEPTH = (WEIGHT_COL_NUM)*WEIGHT_ROW_NUM / PE_SIZE;          // 1470(=70*294/14)
    localparam MEM1_DATA_WIDTH = PE_SIZE * DATA_WIDTH;                          // 112(=14*8)
    localparam MEM1_ADDR_WIDTH = $clog2(MEM1_DEPTH);                            // 11 = clog2(1470)
    
    Top_GLB #(
        .FIFO_DATA_WIDTH    ( DATA_WIDTH),
        .PE_SIZE            ( PE_SIZE),
        .MEM0_DEPTH         (MEM0_DEPTH),
        .MEM1_DEPTH         (),
        .MEM0_ADDR_WIDTH    (),
        .MEM1_ADDR_WIDTH    (),
        .MEM0_DATA_WIDTH    (),
        .MEM1_DATA_WIDTH    (),
        .WEIGHT_ROW_NUM     (),
        .WEIGHT_COL_NUM     ()
    ) u_Top_GLB (
        .clk                ( clk               ),
        .rst_n              ( rst_n             ),
        .en                 ( en                ),
        .mem0_q0_o          ( mem0_q0_o         ),
        .mem0_q0_vaild      ( mem0_q0_vaild     ),
        .rdata_o            ( rdata_o           ),
        .weight_en_col_o    ( weight_en_col_o   ),
        .sa_data_mover_en   ( sa_data_mover_en  )
    );
    
    
    
    SA #(
        .PE_SIZE         ( 4    ),
        .DATA_WIDTH      ( 8    ),
        .PSUM_WIDTH      ( 32   )
    ) u_SA (
        .clk             ( clk             ),
        .rst_n           ( rst_n           ),
        .ifmap_row_i     ( ifmap_row_i     ),
        .weight_col_i    ( weight_col_i    ),
        .psum_row_i      ( psum_row_i      ),
        .ifmap_preload_i ( ifmap_preload_i ),
        .weight_en_col_i ( weight_en_col_i ),
        .psum_en_row_i   ( psum_en_row_i   ),
        .ifmap_row_o     ( ifmap_row_o     ),
        .weight_col_o    ( weight_col_o    ),
        .psum_row_o      ( psum_row_o      ),
        .weight_en_col_o ( weight_en_col_o ),
        .psum_en_row_o   ( psum_en_row_o   )
    );

    
    
    ACC #(
        .PE_SIZE    ( 4             ),
        .DATA_WIDTH ( 32            ),
        .FIFO_DEPTH ( 4             )
    ) u_ACC (
        .clk        ( clk           ),
        .rst_n      ( rst_n         ),
        .psum_en_i  ( psum_en_i     ),
        .rden_i     ( rden_i        ),
        .psum_row_i ( psum_row_i    ),
        .psum_row_o ( psum_row_o    )
    );

    

    
        
    Conv_Data_mover_v2 #(
        .MEM0_DEPTH      ( 896 ),
        .MEM1_DEPTH      ( 896 ),
        .MEM0_ADDR_WIDTH ( 7 ),
        .MEM1_ADDR_WIDTH ( 7 ),
        .MEM0_DATA_WIDTH ( 128 ),
        .MEM1_DATA_WIDTH ( 128 ),
        .PE_SIZE         ( 16 ),
        .WEIGHT_ROW_NUM  ( 70 ),
        .WEIGHT_COL_NUM  ( 294 )
    ) u_Conv_Data_mover_v2 (
        .clk                ( clk             ),
        .rst_n              ( rst_n           ),
        .en                 ( en              ),
        .mem0_q0_i          ( mem0_q0_i       ),
        .mem0_addr0         ( mem0_addr0      ),
        .mem0_ce0           ( mem0_ce0        ),
        .mem0_we0           ( mem0_we0        ),
        .mem1_q0_i          ( mem1_q0_i       ),
        .mem1_addr0         ( mem1_addr0      ),
        .mem1_ce0           ( mem1_ce0        ),
        .mem1_we0           ( mem1_we0        ),
        .mem0_q0_o          ( mem0_q0_o       ),
        .mem0_q0_vaild      ( mem0_q0_vaild   ),
        .mem1_q0_o          ( mem1_q0_o       ),
        .wren_o             ( wren_o          ),
        .rden_o             ( rden_o          ),
        .sa_data_mover_en   ( sa_data_mover_en  )
    );


endmodule
