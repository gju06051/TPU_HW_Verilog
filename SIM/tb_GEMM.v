`timescale 1ns / 1ps
`define DELTA 1

// Primitive param
`define DATA_WIDTH 8
`define PSUM_WIDTH 32
`define PE_SIZE 14

// Model Param
`define SLICING_IDX 8
`define IN_CH 32
`define OUT_CH 64

// IM2COL param
`define WEIGHT_ROW_NUM 70
`define WEIGHT_COL_NUM 294


// BRAM0(Ifmap) Param
`define MEM0_DEPTH 4116 // im2col
`define MEM0_DATA_WIDTH 112
`define MEM0_ADDR_WIDTH 13

// BRAM1(Weight) Param
`define MEM1_DEPTH 1470 // reshape weight
`define MEM1_DATA_WIDTH 112
`define MEM1_ADDR_WIDTH 11

// BRAM2(Ofmap) Param
`define MEM2_DATA_WIDTH 112
`define MEM2_DEPTH 896
`define MEM2_ADDR_WIDTH 10

module tb_GEMM;

    // Special signal
    reg clk;
    reg rst_n;
    
    reg start_i;
    
    // Port for BRAM - GEMM
    
    // BRAM0(Ifmap) I/O 
    wire                                mem0_ce0_w;  
    wire                                mem0_we0_w;  
    wire    [`MEM0_ADDR_WIDTH-1:0]      mem0_addr0_w;
    wire    [`MEM0_DATA_WIDTH-1:0]      mem0_q0_w; 
    
    // BRAM1(Weight) I/O
    wire                                mem1_ce0_w;  
    wire                                mem1_we0_w;  
    wire    [`MEM1_ADDR_WIDTH-1:0]      mem1_addr0_w;
    wire    [`MEM1_DATA_WIDTH-1:0]      mem1_q0_w; 

    // BRAM2(Activation map) I/O
    wire                                mem2_ce0_w;
    wire                                mem2_we0_w;
    wire    [`MEM2_ADDR_WIDTH-1:0]      mem2_addr0_w;
    wire    [`MEM2_DATA_WIDTH-1:0]      mem2_d0_w;
    
    // Output
    wire    finish;
    
    
    // Port for TB - BRAM
    
    // BRAM0(Ifmap) I/O
    reg mem0_ce1;
    reg mem0_we1;
    reg [`MEM0_DATA_WIDTH-1:0] mem0_d1;
    reg [`MEM0_ADDR_WIDTH-1:0] mem0_addr1;
    
    // BRAM1(Weight) I/O
    reg mem1_ce1;
    reg mem1_we1;
    reg [`MEM1_DATA_WIDTH-1:0] mem1_d1;
    reg [`MEM1_ADDR_WIDTH-1:0] mem1_addr1;

    // BRAM2(Activation map) I/O
    reg [`MEM2_ADDR_WIDTH-1:0] mem2_addr1;
    wire [`MEM2_DATA_WIDTH-1:0] mem2_q1;
    reg mem2_ce1;
    reg mem2_we1;
    reg [`DATA_WIDTH-1:0]   a_0, a_1, a_2, a_3, a_4, a_5, a_6, a_7,a_8, a_9, a_10,
                            a_11, a_12, a_13;




// TB Stimulus
// ----------------------------------------------------------------------------------------------------------------------


    always begin
        #5 clk = ~clk;
    end

    integer i, fp_reshape_weight, fp_im2col_Ifmap, fp_ot_Ofmap_tb, status;

    initial begin
        // read file open, write file open
        fp_reshape_weight = $fopen("C:/FPGA_Proj/CNN_golden_ref/ref_c_rand_reshape_weight.txt", "rb");
        fp_im2col_Ifmap = $fopen("C:/FPGA_Proj/CNN_golden_ref/ref_c_rand_im2col_Ifmap.txt", "rb");
        fp_ot_Ofmap_tb = $fopen("C:/FPGA_Proj/CNN_golden_ref/ref_c_ot_Ofmap_tb.txt", "wb");
    end

    initial begin
        clk = 0;
        rst_n = 1'b1;
        start_i = 1'b0;
        mem0_ce1    = 0;
        mem0_we1    = 0;
        mem0_d1     = 0;
        mem0_addr1  = 0;
        mem1_ce1    = 0;
        mem1_we1    = 0;
        mem1_d1     = 0;
        mem1_addr1  = 0;

        // start mem0 & mem1 initialization
        #20
        for(i = 0; i < `MEM0_DEPTH; i = i+1) begin
            @(posedge clk) #1;
                status = $fscanf(fp_im2col_Ifmap, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d \n", 
                                    a_0, a_1, a_2, a_3, a_4, a_5, a_6, a_7,a_8, a_9, a_10,
                                    a_11, a_12, a_13);
                mem0_d1 =   {a_0, a_1, a_2, a_3, a_4, a_5, a_6, a_7,a_8, a_9, a_10,
                                a_11, a_12, a_13};
                mem0_ce1 = 1'b1;
                mem0_we1 = 1'b1;
                mem0_addr1 = i;
                if(i < `MEM1_DEPTH) begin
                    status = $fscanf(fp_reshape_weight, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d \n", 
                                        a_0, a_1, a_2, a_3, a_4, a_5, a_6, a_7,a_8, a_9, a_10,
                                        a_11, a_12, a_13);
                    mem1_d1 =   {a_0, a_1, a_2, a_3, a_4, a_5, a_6, a_7,a_8, a_9, a_10,
                                    a_11, a_12, a_13};
                    mem1_ce1 = 1'b1;
                    mem1_we1 = 1'b1;
                    mem1_addr1 = i;
                end else begin
                    mem1_ce1 = 1'b0;
                    mem1_we1 = 1'b0;
                    mem1_addr1 = 0;
                end
            end

        // finish mem0 & mem1 initialization
        @(posedge clk) #1;
            mem0_ce1 = 0;
            mem0_we1 = 0;
            mem0_d1  = 0;
            mem0_addr1 = 0;
            mem1_ce1 = 0;
            mem1_we1 = 0;
            mem1_d1  = 0;   
            mem1_addr1 = 0;

        // TB strategy
        // start GEMM operation
        @(posedge clk);
        #(`DELTA)
        rst_n = 1'b0;

        @(posedge clk);
        #(`DELTA)
        rst_n = 1'b1;

        
        @(posedge clk);
        #(`DELTA)
        start_i = 1'b1;
        
        wait(finish)
        @(posedge clk);
        #(`DELTA)
        start_i = 1'b0;
        rst_n = 1'b0;


        // make fp_ot_Ofmap_tb files
        for(i = 0; i < `MEM2_DEPTH + 1; i = i+1) begin
            @(posedge clk) #1;
                if(i != 0) begin
                    a_0  = mem2_q1[(`MEM2_DATA_WIDTH-1)-((0) *(`DATA_WIDTH)) -:`DATA_WIDTH];
                    a_1  = mem2_q1[(`MEM2_DATA_WIDTH-1)-((1) *(`DATA_WIDTH)) -:`DATA_WIDTH];
                    a_2  = mem2_q1[(`MEM2_DATA_WIDTH-1)-((2) *(`DATA_WIDTH)) -:`DATA_WIDTH];
                    a_3  = mem2_q1[(`MEM2_DATA_WIDTH-1)-((3) *(`DATA_WIDTH)) -:`DATA_WIDTH];
                    a_4  = mem2_q1[(`MEM2_DATA_WIDTH-1)-((4) *(`DATA_WIDTH)) -:`DATA_WIDTH];
                    a_5  = mem2_q1[(`MEM2_DATA_WIDTH-1)-((5) *(`DATA_WIDTH)) -:`DATA_WIDTH];
                    a_6  = mem2_q1[(`MEM2_DATA_WIDTH-1)-((6) *(`DATA_WIDTH)) -:`DATA_WIDTH];
                    a_7  = mem2_q1[(`MEM2_DATA_WIDTH-1)-((7) *(`DATA_WIDTH)) -:`DATA_WIDTH];
                    a_8  = mem2_q1[(`MEM2_DATA_WIDTH-1)-((8) *(`DATA_WIDTH)) -:`DATA_WIDTH];
                    a_9  = mem2_q1[(`MEM2_DATA_WIDTH-1)-((9) *(`DATA_WIDTH)) -:`DATA_WIDTH];
                    a_10 = mem2_q1[(`MEM2_DATA_WIDTH-1)-((10)*(`DATA_WIDTH)) -:`DATA_WIDTH];
                    a_11 = mem2_q1[(`MEM2_DATA_WIDTH-1)-((11)*(`DATA_WIDTH)) -:`DATA_WIDTH];
                    a_12 = mem2_q1[(`MEM2_DATA_WIDTH-1)-((12)*(`DATA_WIDTH)) -:`DATA_WIDTH];
                    a_13 = mem2_q1[(`MEM2_DATA_WIDTH-1)-((13)*(`DATA_WIDTH)) -:`DATA_WIDTH];
                    $fwrite(fp_ot_Ofmap_tb, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d \n", 
                                            a_0, a_1, a_2, a_3, a_4, a_5, a_6, a_7,a_8, a_9, a_10,
                                            a_11, a_12, a_13);
                end
                if(i != `MEM2_DEPTH) begin
                        mem2_ce1 = 1'b1;
                        mem2_we1 = 1'b0;
                        mem2_addr1 = i;
                end else begin
                    mem2_ce1 = 1'b0;
                    mem2_we1 = 1'b0;
                    mem2_addr1 = 0;
                end
        end
        
    end



// DUT INST
// ----------------------------------------------------------------------------------------------------------------------


    // Core INST
    GEMM #(
        .DATA_WIDTH      ( `DATA_WIDTH  ),
        .PSUM_WIDTH      ( `PSUM_WIDTH  ),
        .PE_SIZE         ( `PE_SIZE     ),
        
        .SLICING_IDX     ( `SLICING_IDX ),
        .OUT_CH          ( `OUT_CH ),
        
        .WEIGHT_ROW_NUM  ( `WEIGHT_ROW_NUM ),
        .WEIGHT_COL_NUM  ( `WEIGHT_COL_NUM ),
        
        .MEM0_DEPTH      ( `MEM0_DEPTH ),
        .MEM0_DATA_WIDTH ( `MEM0_DATA_WIDTH ),
        .MEM0_ADDR_WIDTH ( `MEM0_ADDR_WIDTH ),
        
        .MEM1_DEPTH      ( `MEM1_DEPTH ),
        .MEM1_DATA_WIDTH ( `MEM1_DATA_WIDTH ),
        .MEM1_ADDR_WIDTH ( `MEM1_ADDR_WIDTH ),
        
        .MEM2_DEPTH      ( `MEM2_DEPTH ),
        .MEM2_DATA_WIDTH ( `MEM2_DATA_WIDTH ),
        .MEM2_ADDR_WIDTH ( `MEM2_ADDR_WIDTH )
    )u_GEMM(
        .clk             ( clk              ),
        .rst_n           ( rst_n            ),
        
        .gemm_start_i    ( start_i ),
        
        .mem0_ce0        ( mem0_ce0_w       ),
        .mem0_we0        ( mem0_we0_w       ),
        .mem0_addr0      ( mem0_addr0_w     ),
        .mem0_q0_i       ( mem0_q0_w        ),
        
        .mem1_ce0        ( mem1_ce0_w       ),
        .mem1_we0        ( mem1_we0_w       ),
        .mem1_addr0      ( mem1_addr0_w     ),
        .mem1_q0_i       ( mem1_q0_w        ),
        
        .mem2_ce0        ( mem2_ce0_w       ),
        .mem2_we0        ( mem2_we0_w       ),
        .mem2_addr0      ( mem2_addr0_w     ),
        .mem2_d0         ( mem2_d0_w        ),
        
        .finish_o        (finish)
    );

    



    true_dpbram #(
        .DWIDTH(`MEM0_DATA_WIDTH),
        .AWIDTH(`MEM0_ADDR_WIDTH),
        .MEM_SIZE(`MEM0_DEPTH)
    ) mem0 (
        /* Special Inputs */
        .clk(clk),

        /* input for port 0 */
        .addr0_i(mem0_addr0_w),
        .ce0_i(mem0_ce0_w),
        .we0_i(mem0_we0_w),
        .d0_i(),    // not use

        /* input for port 1 */
        .addr1_i(mem0_addr1),
        .ce1_i(mem0_ce1),
        .we1_i(mem0_we1),
        .d1_i(mem0_d1),

        /* output for port 0 */
        .q0_o(mem0_q0_w),

        /* output for port 1 */
        .q1_o()     // not use
    );

    true_dpbram #(
        .DWIDTH(`MEM1_DATA_WIDTH),
        .AWIDTH(`MEM1_ADDR_WIDTH),
        .MEM_SIZE(`MEM1_DEPTH)
    ) mem1 (
        /* Special Inputs */
        .clk(clk),

        /* input for port 0 */
        .addr0_i(mem1_addr0_w),
        .ce0_i(mem1_ce0_w),
        .we0_i(mem1_we0_w),
        .d0_i(),

        /* input for port 1 */
        .addr1_i(mem1_addr1),
        .ce1_i(mem1_ce1),
        .we1_i(mem1_we1),
        .d1_i(mem1_d1),

        /* output for port 0 */
        .q0_o(mem1_q0_w),

        /* output for port 1 */
        .q1_o()
    );

    true_dpbram #(
        .DWIDTH(`MEM2_DATA_WIDTH),
        .AWIDTH(`MEM2_ADDR_WIDTH),
        .MEM_SIZE(`MEM2_DEPTH)
    ) mem2 (
        /* Special Inputs */
        .clk(clk),

        /* input for port 0 */
        .addr0_i(mem2_addr0_w),
        .ce0_i(mem2_ce0_w),
        .we0_i(mem2_we0_w),
        .d0_i(mem2_d0_w),

        /* input for port 1 */
        .addr1_i(mem2_addr1),
        .ce1_i(mem2_ce1),
        .we1_i(mem2_we1),
        .d1_i(),

        /* output for port 0 */
        .q0_o(),

        /* output for port 1 */
        .q1_o(mem2_q1)
    );
    





endmodule