module tb_Conv_Data_mover;

        parameter integer MEM0_DEPTH = 896;
        parameter integer MEM1_DEPTH = 896;
		parameter integer MEM0_ADDR_WIDTH = 10;
        parameter integer MEM1_ADDR_WIDTH = 10;
		parameter integer MEM0_DATA_WIDTH = 128;
        parameter integer MEM1_DATA_WIDTH = 128;
        parameter integer PE_SIZE = 16;

        reg clk;
        reg rst_n;
        reg en;

        wire [MEM0_DATA_WIDTH-1:0] mem0_q0;
        wire [MEM1_DATA_WIDTH-1:0] mem1_q0;

        //wire  [MEM0_DATA_WIDTH-1:0] mem0_q0;
		wire [MEM0_ADDR_WIDTH-1:0] mem0_addr0;
		wire mem0_ce0;
		wire mem0_we0;

        //wire  [MEM1_DATA_WIDTH-1:0] mem1_q0;
		wire [MEM1_ADDR_WIDTH-1:0] mem1_addr0;
		wire mem1_ce0;
		wire mem1_we0;
        
        always #5 clk = ~clk;
        initial begin
            clk = 0;
            rst_n = 0;
            en = 0;
            #30
            rst_n = 1;
            en = 1;
        end

Conv_Data_mover # (
        .MEM0_DEPTH(MEM0_DEPTH),
        .MEM1_DEPTH(MEM1_DEPTH),
		.MEM0_ADDR_WIDTH(MEM0_ADDR_WIDTH),
        .MEM1_ADDR_WIDTH(MEM1_ADDR_WIDTH),
		.MEM0_DATA_WIDTH(MEM0_DATA_WIDTH),
        .MEM1_DATA_WIDTH(MEM1_DATA_WIDTH),
        .PE_SIZE(PE_SIZE)
    ) DUT
    (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),

        .mem0_q0(),
		.mem0_addr0(mem0_addr0),
		.mem0_ce0(mem0_ce0),
		.mem0_we0(mem0_we0),

        .mem1_q0(),
		.mem1_addr0(mem1_addr0),
		.mem1_ce0(mem1_ce0),
		.mem1_we0(mem1_we0),
        .mem0_q0_vaild(mem0_q0_vaild)
    );

    true_dpbram #(
        .DWIDTH(MEM0_DATA_WIDTH),
        .AWIDTH(MEM0_ADDR_WIDTH),
        .MEM_SIZE(MEM0_DEPTH)
    ) mem0 (
        /* Special Inputs */
        .clk(clk),

        /* input for port 0 */
        .addr0_i(mem0_addr0),
        .ce0_i(mem0_ce0),
        .we0_i(mem0_we0),
        .d0_i(),

        /* input for port 1 */
        .addr1_i(),
        .ce1_i(),
        .we1_i(),
        .d1_i(),

        /* output for port 0 */
        .q0_o(mem0_q0),

        /* output for port 1 */
        .q1_o()
    );

    true_dpbram #(
        .DWIDTH(MEM1_DATA_WIDTH),
        .AWIDTH(MEM1_ADDR_WIDTH),
        .MEM_SIZE(MEM1_DEPTH)
    ) mem1 (
        /* Special Inputs */
        .clk(clk),

        /* input for port 0 */
        .addr0_i(mem1_addr0),
        .ce0_i(mem1_ce0),
        .we0_i(mem1_we0),
        .d0_i(),

        /* input for port 1 */
        .addr1_i(),
        .ce1_i(),
        .we1_i(),
        .d1_i(),

        /* output for port 0 */
        .q0_o(mem1_q0),

        /* output for port 1 */
        .q1_o()
    );
    
endmodule