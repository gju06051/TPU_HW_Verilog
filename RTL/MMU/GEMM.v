module GEMM #(
    // Primitive DATA_WIDTH
    parameter DATA_WIDTH    = 8,        // Weight, Ifmap
    parameter PSUM_WIDTH    = 32,       // Partial Sum
    // HW Const(=Ifmap width)
    parameter PE_SIZE       = 14,       // Systolic Array PE NUM 
                                        // ex. if PE_SIZE = 14, use 196(=14x14) PE  
    // Model Const
    parameter IN_CH         = 32,       // Input Channel
    parameter OUT_CH        = 64,       // Output Channel
    parameter KERNAL_SIZE   = 3
    ) 
    (
    // Port
    
    // Special Input
    input clk,
    input rst_n,
    
    // Control Input
    input gemm_start_i,
    
    // SA_DATA_MOVER BRAM I/O PORT
    output      [MEM0_DATA_WIDTH-1:0]   mem0_d0,
    output      [MEM0_ADDR_WIDTH-1:0]   mem0_addr,
    output                              mem0_ce0,
    output                              mem0_we0

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
    
    
    // Port Declation
    wire    [MEM0_DATA_WIDTH-1:0]       ifmap_row_w;            // TOP_GLB -> SA
    wire                                ifmap_valid_w;          // TOP_GLB -> SA
    wire    [MEM1_DATA_WIDTH-1:0]       weight_col_w;           // TOP_GLB -> SA
    wire    [PE_SIZE-1:0]               weight_en_col_w;        // TOP_GLB -> SA
    
    wire                                sa_data_mover_en_w;     // TOP_GLB -> SA_DATA_MOVER
    
    wire    [PSUM_WIDTH*PE_SIZE-1:0]    psum_row_w;             // SA -> ACC
    wire    [PE_SIZE-1:0]               psum_en_row_w;          // SA -> ACC
    
    wire    [PE_SIZE-1:0]               rden_w;                 // SA_DATA_MOVER -> ACC
    wire    [MEM0_DATA_WIDTH-1:0]       actmp_row_w;            // ACC -> SA_DATA_MOVER
    
    
    
    Top_GLB #(
        .FIFO_DATA_WIDTH    ( DATA_WIDTH        ),
        .PE_SIZE            ( PE_SIZE           ),
        .MEM0_DEPTH         ( MEM0_DEPTH        ),
        .MEM1_DEPTH         ( MEM1_DEPTH        ),
        .MEM0_ADDR_WIDTH    ( MEM0_ADDR_WIDTH   ),
        .MEM1_ADDR_WIDTH    ( MEM1_ADDR_WIDTH   ),
        .MEM0_DATA_WIDTH    ( MEM0_DATA_WIDTH   ),
        .MEM1_DATA_WIDTH    ( MEM1_DATA_WIDTH   ),
        .WEIGHT_ROW_NUM     ( WEIGHT_ROW_NUM    ),
        .WEIGHT_COL_NUM     ( WEIGHT_COL_NUM    )
    ) u_Top_GLB (
        // Special Input
        .clk                ( clk                   ),
        .rst_n              ( rst_n                 ),
        // Control Input
        .en                 ( gemm_start_i          ),
        // Ifmap Output
        .mem0_q0_o          ( ifmap_row_w           ),  // ifmap
        .mem0_q0_vaild      ( ifmap_valid_w         ),  // ifmap enable signal for forwarding
        // Weight Output
        .rdata_o            ( weight_col_w          ),  // weight
        .weight_en_col_o    ( weight_en_col_w       ),  // weight enable signal for forwarding
        // Control Output
        .sa_data_mover_en   ( sa_data_mover_en_w    )   // Read Activation Map from sa_data_mover
    );
    
    
    
    SA #(
        .PE_SIZE            ( PE_SIZE          ),
        .DATA_WIDTH         ( DATA_WIDTH       ),
        .PSUM_WIDTH         ( PSUM_WIDTH       )
    ) u_SA (
        // Special Input
        .clk                ( clk              ),
        .rst_n              ( rst_n            ),
        // Primitives Input (TOP_GLB -> SA)
        .ifmap_row_i        ( ifmap_row_w      ), 
        .weight_col_i       ( weight_col_w     ), 
        .psum_row_i         ( {(PE_SIZE*PSUM_WIDTH-1){1'b0}} ),   // partial sum(In this logic, zero partial sum for SA)
        // Control Input (TOP_GBL -> SA)
        .ifmap_preload_i    ( ifmap_valid_w    ),  // preload start signal 
        .weight_en_col_i    ( weight_en_col_w  ),
        .psum_en_row_i      ( weight_en_col_w  ),  // partial sum sync with weight data
        // Primitives Output (SA -> ACC)
        .ifmap_row_o        ( ),                   // not use
        .weight_col_o       ( ),                   // not use
        .psum_row_o         ( psum_row_w       ),  // SA output -> ACC input
        // Control Output (SA -> ACC)
        .weight_en_col_o    ( ),                   // not use
        .psum_en_row_o      ( psum_en_row_w    )   // Used for FIFO write signal
    );



    ACC #(
        .PE_SIZE            ( PE_SIZE       ),
        .DATA_WIDTH         ( DATA_WIDTH    ),
        .PSUM_WIDTH         ( PSUM_WIDTH    ),
        .FIFO_DEPTH         ( OUT_CH        )
    ) u_ACC (
        // Special Input
        .clk                ( clk           ),
        .rst_n              ( rst_n         ),      // FIFO reset signal, initialize fifo R/W counter
        // Control Input 
        .psum_en_i          ( psum_en_row_w ),      // FIFO write enable signal (SA -> ACC)
        .rden_i             ( rden_w        ),      // FIFO read enable signal  (SA_DATA_MOVER -> ACC)
        // Primitives Input
        .psum_row_i         ( psum_row_w    ),      // SA output (SA -> ACC)
        // Primitives Output
        .psum_row_o         ( actmp_row_w   )       // Accumulated output activation map value (ACC -> SA_DATA_MOVER)
    );




    SA_Data_mover #(
        .FIFO_DATA_WIDTH    ( DATA_WIDTH        ),
        .PE_SIZE            ( PE_SIZE           ),
        .MEM0_DEPTH         ( MEM0_DEPTH        ),
        .MEM0_ADDR_WIDTH    ( MEM0_ADDR_WIDTH   ),
        .MEM0_DATA_WIDTH    ( MEM0_DATA_WIDTH   ),
        .OC                 ( OUT_CH            )
    ) u_SA_Data_mover (
        // Special Input
        .clk                ( clk                   ),
        .rst_n              ( rst_n                 ),
        // Control Input
        .en                 ( sa_data_mover_en_w    ),
        // Control Output
        .rden_o             ( rden_w                ),
        // Primtives Input
        .rdata_i            ( actmp_row_w           ),
        // BRAM I/O 
        .mem0_d0            ( mem0_d0               ),
        .mem0_addr0         ( mem0_addr0            ),
        .mem0_ce0           ( mem0_ce0              ),
        .mem0_we0           ( mem0_we0              )
    );



endmodule
