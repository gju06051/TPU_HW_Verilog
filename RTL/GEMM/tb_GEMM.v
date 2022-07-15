`timescale 1ns / 1ps

`define CNT_BIT 31
`define DATA_WIDTH 8
`define MEM0_DEPTH 4116 // im2col
`define MEM1_DEPTH 1470 // reshape weight
`define MEM0_DATA_WIDTH 112
`define MEM0_ADDR_WIDTH 13
`define MEM1_DATA_WIDTH 112
`define MEM1_ADDR_WIDTH 11
`define MEM2_DATA_WIDTH 112
`define MEM2_DEPTH 896
`define MEM2_ADDR_WIDTH 10
module tb_GEMM;

    reg clk;
    reg mem0_ce1;
    reg mem0_we1;
    reg [`MEM0_DATA_WIDTH-1:0] mem0_d1;
    reg [`MEM0_ADDR_WIDTH-1:0] mem0_addr1;
    reg mem1_ce1;
    reg mem1_we1;
    reg [`MEM1_DATA_WIDTH-1:0] mem1_d1;
    reg [`MEM1_ADDR_WIDTH-1:0] mem1_addr1;

    reg [`MEM2_ADDR_WIDTH-1:0] mem2_addr1;
    reg [`MEM2_DATA_WIDTH-1:0] mem2_q1;
    reg mem2_ce1;
    reg mem2_we1;
    reg [`DATA_WIDTH-1:0]   a_0, a_1, a_2, a_3, a_4, a_5, a_6, a_7,a_8, a_9, a_10,
                            a_11, a_12, a_13;

    always begin
        #5 clk = ~clk;
    end

    integer i, fp_reshape_weight, fp_im2col_Ifmap, fp_ot_Ofmap_tb, status;

    initial begin
        // read file open, write file open
        fp_reshape_weight = $fopen("C:/FPGA_pj/CNN_golden_ref/ref_c_rand_reshape_weight.txt", "rb");
        fp_im2col_Ifmap = $fopen("C:/FPGA_pj/CNN_golden_ref/ref_c_rand_im2col_Ifmap.txt", "rb");
        fp_ot_Ofmap_tb = $fopen("C:/FPGA_pj/CNN_golden_ref/ref_c_ot_Ofmap_tb.txt", "wb");
    end

    initial begin
        clk = 0;
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

        // start GEMM operation
        //

        // make fp_ot_Ofmap_tb files
        for(i = 0; i < `MEM2_DEPTH + 1; i = i+1) begin
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
                status = $fprintf(fp_ot_Ofmap_tb, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d \n", 
                                        a_0, a_1, a_2, a_3, a_4, a_5, a_6, a_7,a_8, a_9, a_10,
                                        a_11, a_12, a_13);
            end
            if(i != `MEM2_DEPTH) begin
                @(posedge clk) #1;
                    mem2_ce1 = 1'b1;
                    mem2_we1 = 1'b0;
                    mem2_addr1 = i;
            end
        end

        // finish mem2
        mem2_ce1 = 1'b0;
        mem2_we1 = 1'b0;
        mem2_addr1 = 0;
    end


    true_dpbram #(
        .DWIDTH(`MEM0_DATA_WIDTH),
        .AWIDTH(`MEM0_ADDR_WIDTH),
        .MEM_SIZE(`MEM0_DEPTH)
    ) mem0 (
        /* Special Inputs */
        .clk(clk),

        /* input for port 0 */
        .addr0_i(),
        .ce0_i(),
        .we0_i(),
        .d0_i(),

        /* input for port 1 */
        .addr1_i(mem0_addr1),
        .ce1_i(mem0_ce1),
        .we1_i(mem0_we1),
        .d1_i(mem0_d1),

        /* output for port 0 */
        .q0_o(),

        /* output for port 1 */
        .q1_o()
    );

    true_dpbram #(
        .DWIDTH(`MEM1_DATA_WIDTH),
        .AWIDTH(`MEM1_ADDR_WIDTH),
        .MEM_SIZE(`MEM1_DEPTH)
    ) mem1 (
        /* Special Inputs */
        .clk(clk),

        /* input for port 0 */
        .addr0_i(),
        .ce0_i(),
        .we0_i(),
        .d0_i(),

        /* input for port 1 */
        .addr1_i(mem1_addr1),
        .ce1_i(mem1_ce1),
        .we1_i(mem1_we1),
        .d1_i(mem1_d1),

        /* output for port 0 */
        .q0_o(),

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
        .addr0_i(),
        .ce0_i(),
        .we0_i(),
        .d0_i(),

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