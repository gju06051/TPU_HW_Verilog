module tb_Top_GLB;
    parameter FIFO_DATA_WIDTH = 8;
    parameter FIFO_DEPTH = 16;
    parameter PE_SIZE = 16;
    parameter integer MEM0_DEPTH = 896;
    parameter integer MEM1_DEPTH = 896;
    parameter integer MEM0_ADDR_WIDTH = 10;
    parameter integer MEM1_ADDR_WIDTH = 10;
    parameter integer MEM0_DATA_WIDTH = 128;
    parameter integer MEM1_DATA_WIDTH = 128;

    reg clk;
    reg rst_n;
    reg en;
    wire [MEM0_DATA_WIDTH-1:0] mem0_q0_o;
    wire mem0_q0_vaild;
    Top_GLB # (
        .FIFO_DATA_WIDTH(FIFO_DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH),
        .PE_SIZE(PE_SIZE),
        .MEM0_DEPTH(MEM0_DEPTH),
        .MEM1_DEPTH(MEM1_DEPTH),
        .MEM0_ADDR_WIDTH(MEM0_ADDR_WIDTH),
        .MEM1_ADDR_WIDTH(MEM1_ADDR_WIDTH),
        .MEM0_DATA_WIDTH(MEM0_DATA_WIDTH),
        .MEM1_DATA_WIDTH(MEM1_DATA_WIDTH)
    ) DUT
    (
        .clk(clk),
        .rst_n(rst_n),
        .en(en),

        .mem0_q0_o(mem0_q0_o),
        .mem0_q0_vaild(mem0_q0_vaild)
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