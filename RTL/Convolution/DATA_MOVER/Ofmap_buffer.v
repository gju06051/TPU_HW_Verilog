module Ofmap_buffer # (
    parameter FIFO_DATA_WIDTH = 8,
    parameter PE_SIZE = 16,
    parameter integer MEM_DEPTH = 896,
    parameter integer MEM_ADDR_WIDTH = 7,
    parameter integer MEM_DATA_WIDTH = 112,
    parameter integer OC = 64
)
(
    input clk,
    input rst_n,

    input wire en,
    input wire [(FIFO_DATA_WIDTH)*(PE_SIZE)-1:0] ofmap_row_i,

    output wire [MEM_DATA_WIDTH-1:0] mem_d_o,
    output wire [MEM_ADDR_WIDTH-1:0] mem_addr_o,
    output wire mem_ce_o,
    output wire mem_we_o,
    output wire finish_o
);
    localparam MEM_CNT = (PE_SIZE)*(OC); //896
    localparam MEM_CNT_ADDR_WIDTH = $clog2(MEM_CNT); //10
    genvar i;

    // make buffer_en signals for #PE_SIZE buffers
    reg [0:PE_SIZE-2] r_buffer_en;
    wire [0:PE_SIZE-1] buffer_en;
        generate
            for (i=0; i < PE_SIZE-2; i=i+1) begin 
                always @(posedge clk) begin
                    r_buffer_en[i+1] <= r_buffer_en[i];
                end
            end
        endgenerate

    always @(posedge clk) begin
        r_buffer_en[0] <= en;
    end
    //genvar i;
        generate
            for (i=1; i < PE_SIZE; i=i+1) begin 
                assign buffer_en[i] = r_buffer_en[i-1]; 
            end
        endgenerate
    assign buffer_en[0] = en;


endmodule