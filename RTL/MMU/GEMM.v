module GEMM #(
    // Primitive DATA_WIDTH
    parameter DATA_WIDTH    = 8,            // Weight, Ifmap
    parameter PSUM_WIDTH    = 32,           // Partial Sum
    
    // HW Const
    parameter PE_SIZE       = 14,           // Systolic Array PE NUM 
                                            // ex. if PE_SIZE = 14, use 196(=14x14) PE
    // Quantization parameter
    parameter SLICING_IDX   = 32,           // This is msb of slicing bit
                                            // ex. if SLICING_IDX = 32, slice 32bit output with data_width 8 => [31:24]

    // GEMM parameter
    parameter WEIGHT_ROW_NUM   = 294,       // 294(=288+14-(288%14))
    parameter WEIGHT_COL_NUM   = 70,        // 70(=64+14-(288%14))
    
    // BRAM0(Ifmap)
    parameter MEM0_DEPTH       = 4116,      // 4116(=196*294/14)
    parameter MEM0_DATA_WIDTH  = 112,       // 112(=14*8)
    parameter MEM0_ADDR_WIDTH  = 13,        // 13 = clog2(4116)
    // BRAM1(Weight)
    parameter MEM1_DEPTH       = 1470,      // 1470(=70*294/14)
    parameter MEM1_DATA_WIDTH  = 112,       // 112(=14*8)
    parameter MEM1_ADDR_WIDTH  = 11,        // 11 = clog2(1470)
    // BRAM2(Activation Map)
    parameter MEM2_DEPTH        = 896,      // 896(=14*64)
    parameter MEM2_DATA_WIDTH   = 112,      // 112(=14*8)
    parameter MEM2_ADDR_WIDTH   = 10        // 10 = clog2(896)
    )
    (
    // Port
    
    // Special Input
    input clk,
    input rst_n,
    
    // Control Input
    input gemm_start_i,
    
    // BRAM0(Ifmap) I/O 
    output                          mem0_ce0,  
    output                          mem0_we0,  
    output  [MEM0_ADDR_WIDTH-1:0]   mem0_addr0,
    input   [MEM0_DATA_WIDTH-1:0]   mem0_q0_i, 
    
    // BRAM1(Weight) I/O
    output                          mem1_ce0,  
    output                          mem1_we0,  
    output  [MEM1_ADDR_WIDTH-1:0]   mem1_addr0,
    input   [MEM1_DATA_WIDTH-1:0]   mem1_q0_i, 

    // BRAM2(Activation map) I/O
    output                          mem2_ce0,
    output                          mem2_we0,
    output  [MEM2_ADDR_WIDTH-1:0]   mem2_addr0,
    output  [MEM2_DATA_WIDTH-1:0]   mem2_d0

    );
    
    
    
    // Port Declation
    wire    [MEM0_DATA_WIDTH-1:0]       ifmap_row_w;            // TOP_GLB -> SA
    wire                                ifmap_valid_w;          // TOP_GLB -> SA
    wire    [MEM1_DATA_WIDTH-1:0]       weight_col_w;           // TOP_GLB -> SA
    wire    [PE_SIZE-1:0]               weight_en_col_w;        // TOP_GLB -> SA
    
    wire                                sa_data_mover_en_w;     // TOP_GLB -> SA_DATA_MOVER     // Need Modify
    
    wire    [PSUM_WIDTH*PE_SIZE-1:0]    psum_row_w;             // SA -> ACC
    wire    [PE_SIZE-1:0]               psum_en_row_w;          // SA -> ACC
    
    wire    [PE_SIZE-1:0]               rden_w;                 // SA_DATA_MOVER -> ACC
    wire    [MEM0_DATA_WIDTH-1:0]       ofmap_row_w;            // ACC -> SA_DATA_MOVER
    wire                                ofmap_valid_w;
    
    
    
    Top_GLB #(
        .FIFO_DATA_WIDTH    ( DATA_WIDTH      ),
        .PE_SIZE            ( PE_SIZE         ),
        .MEM0_DEPTH         ( MEM0_DEPTH      ),
        .MEM1_DEPTH         ( MEM1_DEPTH      ),
        .MEM0_ADDR_WIDTH    ( MEM0_ADDR_WIDTH ),
        .MEM1_ADDR_WIDTH    ( MEM1_ADDR_WIDTH ),
        .MEM0_DATA_WIDTH    ( MEM0_DATA_WIDTH ),
        .MEM1_DATA_WIDTH    ( MEM1_DATA_WIDTH ),
        .WEIGHT_ROW_NUM     ( WEIGHT_ROW_NUM  ),
        .WEIGHT_COL_NUM     ( WEIGHT_COL_NUM  )
    ) u_Top_GLB (
        // Special Input
        .clk                ( clk   ),
        .rst_n              ( rst_n ),
        // SA activation signal (outside -> GEMM)
        .en                 ( gemm_start_i  ),
        // BRAM0(Ifmap) control signal (Top_GLB -> BRAM0)
        .mem0_ce0           ( mem0_ce0      ),
        .mem0_we0           ( mem0_we0      ),
        .mem0_addr0         ( mem0_addr0    ),
        // BRAM0(Ifmap) data (BRAM0 -> Top_GLB)
        .mem0_q0_i          ( mem0_q0_i     ),
        // BRAM1(Weight) control signal (Top_GLB -> BRAM1)
        .mem1_ce0           ( mem1_ce0      ),
        .mem1_we0           ( mem1_we0      ),
        .mem1_addr0         ( mem1_addr0    ),
        // BRAM1(Weight) data (BRAM1 -> Top_GLB)
        .mem1_q0_i          ( mem1_q0_i     ),
        // BRAM0(Ifmap) output  (Top_GLB -> SA)
        .mem0_q0_o          ( ifmap_row_w   ),
        .mem0_q0_vaild      ( ifmap_valid_w ),
        // BRAM1(Weight) output (Top_GLB -> SA)
        .rdata_o            ( weight_col_w  ),
        .weight_en_col_o    ( weight_en_col_w ),
        // Activation map read enable signal from SA_DATA_MOVER (GLB -> SA_DATA_MOVER)
        .sa_data_mover_en   ( sa_data_mover_en )        // Need Modify
    );




    SA #(
        .PE_SIZE            ( PE_SIZE ),
        .DATA_WIDTH         ( DATA_WIDTH ),
        .PSUM_WIDTH         ( PSUM_WIDTH )
    ) u_SA (
        // Special Input
        .clk                ( clk   ),
        .rst_n              ( rst_n ),
        // Primitives Input (TOP_GLB -> SA)
        .ifmap_row_i        ( ifmap_row_w  ), 
        .weight_col_i       ( weight_col_w ), 
        .psum_row_i         ( {(PE_SIZE*PSUM_WIDTH-1){1'b0}} ),   // partial sum(In this logic, zero partial sum for SA)
        // Control Input (TOP_GBL -> SA)
        .ifmap_preload_i    ( ifmap_valid_w   ),  // preload start signal 
        .weight_en_col_i    ( weight_en_col_w ),
        .psum_en_row_i      ( weight_en_col_w ),  // partial sum sync with weight data
        // Primitives Output (SA -> ACC)
        .ifmap_row_o        ( ),                   // not use
        .weight_col_o       ( ),                   // not use
        .psum_row_o         ( psum_row_w ),  // SA output -> ACC input
        // Control Output (SA -> ACC)
        .weight_en_col_o    ( ),                   // not use
        .psum_en_row_o      ( psum_en_row_w )   // Used for FIFO write signal
    );


    ACC_v2 #(
        .PE_SIZE        ( PE_SIZE ),
        .DATA_WIDTH     ( DATA_WIDTH ),
        .PSUM_WIDTH     ( PSUM_WIDTH ),
        .SLICING_IDX    ( SLICING_IDX ),
        .WEIGHT_ROW_NUM ( WEIGHT_ROW_NUM ),
        .WEIGHT_COL_NUM ( WEIGHT_COL_NUM )
    )u_ACC_v2(
        // Special Input
        .clk            ( clk            ),
        .rst_n          ( rst_n          ),
        // Control Input
        .psum_en_row_i  ( psum_en_row_w  ),     // FIFO write enable signal (SA -> ACC)
        // Data I/O
        .psum_row_i     ( psum_row_w     ),     // SA output (SA -> ACC)
        .ofmap_row_o    ( ofmap_row_w    ),     // Accumulated output activation map value (ACC -> SA_DATA_MOVER)
        .ofmap_valid_o  ( ofmap_valid_w  )
    );




    SA_Data_mover #(
        .FIFO_DATA_WIDTH    ( DATA_WIDTH      ),
        .PE_SIZE            ( PE_SIZE         ),
        .MEM0_DEPTH         ( MEM0_DEPTH      ),
        .MEM0_ADDR_WIDTH    ( MEM0_ADDR_WIDTH ),
        .MEM0_DATA_WIDTH    ( MEM0_DATA_WIDTH ),
        .OC                 ( OUT_CH          )
    ) u_SA_Data_mover (
        // Special Input
        .clk                ( clk   ),
        .rst_n              ( rst_n ),
        // Control Input
        .en                 ( sa_data_mover_en_w ),
        // Control Output
        .rden_o             ( rden_w ),             // Need Modify
        // Primtives Input
        .rdata_i            ( ofmap_row_w ),
        // BRAM I/O 
        .mem0_d0            ( mem2_d0     ),
        .mem0_addr0         ( mem2_addr0  ),
        .mem0_ce0           ( mem2_ce0    ),
        .mem0_we0           ( mem2_we0    )
    );



endmodule
