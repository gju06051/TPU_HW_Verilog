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
    (
    
    // I/O Port
    
    // Special Input
    input   clk,
    input   rst_n,
    // Control Input
    input   gemm_start_i,
    // Memory I/O Port
    input   [MEM0_DATA_WIDTH-1:0]   mem0_d0_i,      // ifmap  input     (Outside -> BRAM0)
    input   [MEM1_DATA_WIDTH-1:0]   mem1_d0_i,      // weight input     (Outside -> BRAM1)
    output  [MEM2_DATA_WIDTH-1:0]   mem2_q0_o       // Actmap output    (BRAM2 -> Outside)
    
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



    // Wire Decalation
    wire                            mem0_ce0_w;     // GEMM -> BRAM0
    wire                            mem0_we0_w;     // GEMM -> BRAM0
    wire    [MEM0_ADDR_WIDTH-1:0]   mem0_addr0_w;   // GEMM -> BRAM0
    wire    [MEM0_DATA_WIDTH-1:0]   mem0_d0_w;      // input -> BRAM0
    wire    [MEM0_DATA_WIDTH-1:0]   mem0_q0_w;      // BRAM0 -> GEMM
    
    // BRAM1(Weight) I/O
    wire                            mem1_ce0_w;     // GEMM -> BRAM1
    wire                            mem1_we0_w;     // GEMM -> BRAM1
    wire    [MEM1_ADDR_WIDTH-1:0]   mem1_addr0_w;   // GEMM -> BRAM1
    wire    [MEM1_DATA_WIDTH-1:0]   mem1_d0_w;      // input -> BRAM1
    wire    [MEM1_DATA_WIDTH-1:0]   mem1_q0_w;      // BRAM1 -> GEMM

    // BRAM2(Activation map) I/O
    wire                            mem2_ce0_w;     // GEMM -> BRAM2
    wire                            mem2_we0_w;     // GEMM -> BRAM2
    wire    [MEM2_ADDR_WIDTH-1:0]   mem2_addr0_w;   // GEMM -> BRAM2
    wire    [MEM2_DATA_WIDTH-1:0]   mem2_d0_w;      // GEMM -> BRAM2
    wire    [MEM2_DATA_WIDTH-1:0]   mem2_q0_w;      // BRAM2 -> output
    
    
    // Input assignments
    assign  mem0_d0_w = mem0_d0_i;
    assign  mem1_d0_w = mem0_d0_i;
    
    
    // CORE INST
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
        // Special Input
        .clk             ( clk ),
        .rst_n           ( rst_n ),
        // Gemm Start control signal
        .gemm_start_i    ( gemm_start_i ),  // input -> GEMM
        // BRAM0
        .mem0_ce0        ( mem0_ce0_w   ),  // GEMM -> BRAM0
        .mem0_we0        ( mem0_we0_w   ),  // GEMM -> BRAM0
        .mem0_addr0      ( mem0_addr0_W ),  // GEMM -> BRAM0
        .mem0_q0_i       ( mem0_q0_w    ),  // BRAM0 -> GEMM
        // BRAM1
        .mem1_ce0        ( mem1_ce0_w   ),  // GEMM -> BRAM1
        .mem1_we0        ( mem1_we0_w   ),  // GEMM -> BRAM1
        .mem1_addr0      ( mem1_addr0_w ),  // GEMM -> BRAM1
        .mem1_q0_i       ( mem1_q0_w    ),  // BRAM1 -> GEMM
        // BRAM2
        .mem2_ce0        ( mem2_ce0_w   ),  // GEMM -> BRAM2
        .mem2_we0        ( mem2_we0_w   ),  // GEMM -> BRAM2
        .mem2_addr0      ( mem2_addr0_w ),  // GEMM -> BRAM2
        .mem2_d0         ( mem2_d0_w    )   // GEMM -> BRAM2
    );



    //  MEMORY PART  //
    
    
    // BRAM0(Ifmap)
    true_dpbram #(
        .DWIDTH     ( MEM0_DATA_WIDTH ),
        .AWIDTH     ( MEM0_ADDR_WIDTH ),
        .MEM_SIZE   ( MEM0_DEPTH )
    ) mem0 (
        .clk        ( clk ),
        // Mem0 Input Port0
        .addr0_i    ( mem0_addr0_W ),   // GEMM -> BRAM0
        .ce0_i      ( mem0_ce0_w   ),   // GEMM -> BRAM0
        .we0_i      ( mem0_we0_w   ),   // GEMM -> BRAM0
        
        .d0_i       ( mem0_d0_w    ),   // input -> BRAM0
        // Mem0 Input Port1
        .addr1_i    ( ),
        .ce1_i      ( ),
        .we1_i      ( ),
        .d1_i       ( ),
        // Mem0 Output Port0
        .q0_o       ( mem0_q0_w ),      // BRAM0 -> GEMM
        // Mem0 Output Port1
        .q1_o       ( )
    );


    // BRAM1(Weight)
    true_dpbram #(
        .DWIDTH     ( MEM1_DATA_WIDTH ),
        .AWIDTH     ( MEM1_ADDR_WIDTH ),
        .MEM_SIZE   ( MEM1_DEPTH )
    ) mem1 (
        .clk        ( clk ),
        // Mem1 Input Port0
        .addr0_i    ( mem1_addr0_W ),   // GEMM -> BRAM1
        .ce0_i      ( mem1_ce0_w   ),   // GEMM -> BRAM1
        .we0_i      ( mem1_we0_w   ),   // GEMM -> BRAM1
        
        .d0_i       ( mem1_d0_w    ),   // input -> BRAM1
        // Mem1 Input Port1 (not use)
        .addr1_i    ( ),
        .ce1_i      ( ),
        .we1_i      ( ),
        .d1_i       ( ),
        // Mem1 Output Port0
        .q0_o       ( mem1_q0_w ),      // BRAM1 -> GEMM
        // Mem1 Output Port1 (not use)
        .q1_o       ( )
    );
    
    
    // BRAM2(Activation Map)
    true_dpbram #(
        .DWIDTH     ( MEM0_DATA_WIDTH ),
        .AWIDTH     ( MEM0_ADDR_WIDTH ),
        .MEM_SIZE   ( MEM0_DEPTH )
    ) mem2 (
        .clk        ( clk ),
        // Mem2 Input Port0
        .addr0_i    ( mem2_addr0_W ),   // GEMM -> BRAM2
        .ce0_i      ( mem2_ce0_w   ),   // GEMM -> BRAM2
        .we0_i      ( mem2_we0_w   ),   // GEMM -> BRAM2
        
        .d0_i       ( mem2_d0_w    ),   // GEMM -> BRAM2
        // Mem2 Input Port1 (not use)
        .addr1_i    ( ),
        .ce1_i      ( ),
        .we1_i      ( ),
        .d1_i       ( ),
        // Mem2 Output Port0
        .q0_o       ( mem2_q0_w ),      // BRAM2 -> output
        // Mem2 Output Port1 (not use)
        .q1_o       ( )
    );
    
    // Output assignment
    assign mem2_q0_o = mem2_q0_w;
    
endmodule
