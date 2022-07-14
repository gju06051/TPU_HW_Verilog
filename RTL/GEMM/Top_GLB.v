module Top_GLB # (
    parameter FIFO_DATA_WIDTH = 8,
    parameter PE_SIZE = 16,
    parameter integer MEM0_DEPTH = 896,
    parameter integer MEM1_DEPTH = 896,
    parameter integer MEM0_ADDR_WIDTH = 7,
    parameter integer MEM1_ADDR_WIDTH = 7,
    parameter integer MEM0_DATA_WIDTH = 128,
    parameter integer MEM1_DATA_WIDTH = 128,
    parameter integer WEIGHT_ROW_NUM = 70, // 64 + 6
    parameter integer WEIGHT_COL_NUM = 294 // 288 + 6
)
(
    input clk,
    input rst_n,
    input en,

    output wire mem0_ce0,
    output wire mem0_we0,
    output wire [MEM0_ADDR_WIDTH-1:0] mem0_addr0,
    input  wire [MEM0_DATA_WIDTH-1:0] mem0_q0_i,

    output wire mem1_ce0,
    output wire mem1_we0,
    output wire [MEM1_ADDR_WIDTH-1:0] mem1_addr0,
    input  wire [MEM1_DATA_WIDTH-1:0] mem1_q0_i,

    output wire [MEM0_DATA_WIDTH-1:0] mem0_q0_o,
    output wire mem0_q0_vaild,
    output [MEM1_DATA_WIDTH-1:0] rdata_o,
    output [PE_SIZE-1:0] weight_en_col_o,
    output wire sa_data_mover_en
);
    wire    wren_o;
   // wire    mem1_ce0;
   // wire    mem1_we0;
   // wire    mem0_ce0;
   // wire    mem0_we0;
   // wire    [MEM0_ADDR_WIDTH-1:0] mem0_addr0;
   // wire    [MEM1_ADDR_WIDTH-1:0] mem1_addr0;
   // wire    [MEM0_DATA_WIDTH-1:0] mem0_q0_i;
   // wire    [MEM1_DATA_WIDTH-1:0] mem1_q0_i;
    wire    [MEM1_DATA_WIDTH-1:0] mem1_q0_o;
    wire    rden_o;   
    
    Conv_Data_mover_v2 #(
        .MEM0_DEPTH(MEM0_DEPTH),
        .MEM1_DEPTH(MEM1_DEPTH),
		.MEM0_ADDR_WIDTH(MEM0_ADDR_WIDTH),
        .MEM1_ADDR_WIDTH(MEM1_ADDR_WIDTH),
		.MEM0_DATA_WIDTH(MEM0_DATA_WIDTH),
        .MEM1_DATA_WIDTH(MEM1_DATA_WIDTH),
        .PE_SIZE(PE_SIZE),
        .WEIGHT_ROW_NUM(WEIGHT_ROW_NUM), // 64 + 6
        .WEIGHT_COL_NUM(WEIGHT_COL_NUM) // 288 + 6
    ) Conv_data_mover
    (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),

        .mem0_q0_i(mem0_q0_i),
		.mem0_addr0(mem0_addr0),
		.mem0_ce0(mem0_ce0),
		.mem0_we0(mem0_we0),

        .mem1_q0_i(mem1_q0_i),
		.mem1_addr0(mem1_addr0),
		.mem1_ce0(mem1_ce0),
		.mem1_we0(mem1_we0),
        .mem0_q0_o(mem0_q0_o),
        .mem1_q0_o(mem1_q0_o),
        .wren_o(wren_o),
        .mem0_q0_vaild(mem0_q0_vaild),
        .rden_o(rden_o),
        .sa_data_mover_en(sa_data_mover_en)
    );

    GLB #(
        .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH),
        .PE_SIZE(PE_SIZE)
    ) GLB
    (
        .clk(clk),
        .rst_n(rst_n),
        .wren_i(wren_o),
        .rden_i(rden_o),

        .full_o(full_o),
        .empty_o(empty_o),
        
        .wdata_i(mem1_q0_o),
        .rdata_o(rdata_o),

        .weight_en_col_o(weight_en_col_o)
    );

endmodule