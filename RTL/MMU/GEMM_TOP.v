module GEMM_TOP #(
    // Primitive DATA_WIDTH
    parameter DATA_WIDTH    = 8,        // Weight, Ifmap
    parameter PSUM_WIDTH    = 32,       // Partial Sum
    // HW Const(=Ifmap width)
    parameter PE_SIZE       = 14,       // Systolic Array PE NUM 
                                        // ex. if PE_SIZE = 14, use 196(=14x14) PE  
    // Model Const
    parameter IN_CH         = 32,       // Input Channel
    parameter OUT_CH        = 64,       // Output Channel
    parameter KERNAL_SIZE   = 3         // Kernal Width
    ) 
    )
    (
    
    );

    // Local Parameter
    localparam IM2COL_ROW       = IN_CH * (KERNAL_SIZE**2);                                 // 288(=32*(3**2))
    localparam WEIGHT_ROW_NUM   = IM2COL_ROW + (PE_SIZE - (IM2COL_ROW%PE_SIZE));            // 294(=288+14-(288%14))
    localparam WEIGHT_COL_NUM   = OUT_CH + (PE_SIZE - (IM2COL_ROW%PE_SIZE));                // 70(=64+14-(288%14))
    
    localparam MEM0_DEPTH       = (PE_SIZE**2)*WEIGHT_ROW_NUM / PE_SIZE;                    // 4116(=196*294/14)
    localparam MEM0_DATA_WIDTH  = PE_SIZE * DATA_WIDTH;                                     // 112(=14*8)
    localparam MEM0_ADDR_WIDTH  = $clog2(MEM0_DEPTH);                                       // 13 = clog2(4116)
    
    localparam MEM1_DEPTH       = (WEIGHT_COL_NUM)*WEIGHT_ROW_NUM / PE_SIZE;                // 1470(=70*294/14)
    localparam MEM1_DATA_WIDTH  = PE_SIZE * DATA_WIDTH;                                     // 112(=14*8)
    localparam MEM1_ADDR_WIDTH  = $clog2(MEM1_DEPTH);                                       // 11 = clog2(1470)

    localparam MEM2_DEPTH       = PE_SIZE * OUT_CH;                                         // 896(=14*64)
    localparam MEM2_DATA_WIDTH  = PE_SIZE * DATA_WIDTH;                                     // 112(=14*8)
    localparam MEM2_ADDR_WIDTH  = $clog2(MEM2_DEPTH);                                       // 10 = clog2(896)

    GEMM #(
        .DATA_WIDTH      ( DATA_WIDTH ),
        .PSUM_WIDTH      ( PSUM_WIDTH ),
        
        .PE_SIZE         ( PE_SIZE ),
        
        .WEIGHT_ROW_NUM  ( WEIGHT_ROW_NUM ),
        .WEIGHT_COL_NUM  ( WEIGHT_COL_NUM ),
        
        .MEM0_DEPTH      ( MEM0_DEPTH ),
        .MEM0_DATA_WIDTH ( MEM0_DATA_WIDTH ),
        .MEM0_ADDR_WIDTH ( MEM0_ADDR_WIDTH ),
        
        .MEM1_DEPTH      ( MEM1_DEPTH ),
        .MEM1_DATA_WIDTH ( MEM1_DATA_WIDTH ),
        .MEM1_ADDR_WIDTH ( MEM1_ADDR_WIDTH ),
        
        .MEM2_DEPTH      ( MEM2_DEPTH ),
        .MEM2_DATA_WIDTH ( MEM2_DATA_WIDTH ),
        .MEM2_ADDR_WIDTH ( MEM2_ADDR_WIDTH )
    ) u_GEMM (
        .clk             ( clk             ),
        .rst_n           ( rst_n           ),
        .gemm_start_i    ( gemm_start_i    ),
        .mem0_ce0        ( mem0_ce0        ),
        .mem0_we0        ( mem0_we0        ),
        .mem0_addr0      ( mem0_addr0      ),
        .mem0_q0_i       ( mem0_q0_i       ),
        .mem1_ce0        ( mem1_ce0        ),
        .mem1_we0        ( mem1_we0        ),
        .mem1_addr0      ( mem1_addr0      ),
        .mem1_q0_i       ( mem1_q0_i       ),
        .mem2_addr0      ( mem2_addr0      ),
        .mem2_ce0        ( mem2_ce0        ),
        .mem2_we0        ( mem2_we0        ),
        .mem2_d0         ( mem2_d0         )
    );

    true_dpbram #(
        .DWIDTH     ( 16 ),
        .AWIDTH     ( 12 ),
        .MEM_SIZE   ( 3840 )
    ) u_true_dpbram (
        .clk        ( clk     ),
        .addr0_i    ( addr0_i ),
        .ce0_i      ( ce0_i   ),
        .we0_i      ( we0_i   ),
        .d0_i       ( d0_i    ),
        .addr1_i    ( addr1_i ),
        .ce1_i      ( ce1_i   ),
        .we1_i      ( we1_i   ),
        .d1_i       ( d1_i    ),
        .q0_o       ( q0_o    ),
        .q1_o       ( q1_o    )
    );


endmodule
