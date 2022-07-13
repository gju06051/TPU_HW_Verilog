module tb_Top_GLB;
    parameter FIFO_DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 16;
    parameter PE_SIZE = 14;
    parameter integer MEM0_DEPTH = 4116;
    parameter integer MEM1_DEPTH = 1470;
    parameter integer MEM0_ADDR_WIDTH = 13;
    parameter integer MEM1_ADDR_WIDTH = 11;
    parameter integer MEM0_DATA_WIDTH = 112;
    parameter integer MEM1_DATA_WIDTH = 112;
    parameter integer WEIGHT_ROW_NUM = 70;
    parameter integer WEIGHT_COL_NUM = 294;

    reg clk;
    reg rst_n;
    reg en;
    wire [MEM0_DATA_WIDTH-1:0] mem0_q0_o;
    wire mem0_q0_vaild;
    wire [MEM1_DATA_WIDTH-1:0] rdata_o;
    wire [PE_SIZE-1:0] weight_en_col_o;
    wire sa_data_mover_en;
    Top_GLB # (
        .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH),
        .PE_SIZE(PE_SIZE),
        .MEM0_DEPTH(MEM0_DEPTH),
        .MEM1_DEPTH(MEM1_DEPTH),
        .MEM0_ADDR_WIDTH(MEM0_ADDR_WIDTH),
        .MEM1_ADDR_WIDTH(MEM1_ADDR_WIDTH),
        .MEM0_DATA_WIDTH(MEM0_DATA_WIDTH),
        .MEM1_DATA_WIDTH(MEM1_DATA_WIDTH),
        .WEIGHT_ROW_NUM(WEIGHT_ROW_NUM), // 64 + 6
        .WEIGHT_COL_NUM(WEIGHT_COL_NUM) // 288 + 6
    ) DUT
    (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),

        .mem0_q0_o(mem0_q0_o),
        .mem0_q0_vaild(mem0_q0_vaild),
        .rdata_o(rdata_o),
        .weight_en_col_o(weight_en_col_o),
        .sa_data_mover_en(sa_data_mover_en)
    );
    always #5 clk = ~clk;
    initial begin
        clk = 0;
        rst_n = 0;
        en = 0;

        #50
            rst_n = 1;
        #20
             en = 1;
    end

endmodule