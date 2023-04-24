module Ofmap_buffer # (
    parameter FIFO_DATA_WIDTH = 8,
    parameter PE_SIZE = 14,
    parameter integer MEM_DEPTH = 896,
    parameter integer MEM_ADDR_WIDTH = 10,
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

    localparam OVERALL_BUFF_ADDR = $clog2(PE_SIZE*PE_SIZE);
    localparam SINGLE_BUFF_ADDR = $clog2(PE_SIZE);
    localparam OC_ADDR_WIDTH = $clog2(OC);
    localparam  buffer_index_overflow = OC / PE_SIZE;
    localparam  buffer_index_overflow_width = $clog2((OC / PE_SIZE)+1);
    localparam  buffer_index_remainder = (OC % PE_SIZE);
    
    genvar i;
    wire [FIFO_DATA_WIDTH*PE_SIZE-1:0] buff_data_i;
    generate
        for(i = 1 ; i < PE_SIZE; i = i + 1) begin
            shift_buffer # (
                .DATA_WIDTH(FIFO_DATA_WIDTH),
                .SIZE(PE_SIZE-i)
            ) shift_buffer_inst (
                .clk(clk),
                .en(en[i]),
                .data_i(ofmap_row_i[(PE_SIZE-i+1)*FIFO_DATA_WIDTH-1 -:FIFO_DATA_WIDTH]),
                .data_o(buff_data_i[(PE_SIZE-i+1)*FIFO_DATA_WIDTH-1 -:FIFO_DATA_WIDTH])
            );
        end
    endgenerate
    assign buff_data_i[FIFO_DATA_WIDTH-1 -:FIFO_DATA_WIDTH] = ofmap_row_i[FIFO_DATA_WIDTH-1 -:FIFO_DATA_WIDTH];

    reg [FIFO_DATA_WIDTH*PE_SIZE-1 : 0] buff;
    generate
        for(i = 0 ; i < PE_SIZE; i = i + 1) begin
            always @(posedge clk) begin
                if(buff_en) begin
                    buff[(PE_SIZE-i)*FIFO_DATA_WIDTH-1 -:FIFO_DATA_WIDTH] = buff_data_i[(PE_SIZE-i)*FIFO_DATA_WIDTH-1 -:FIFO_DATA_WIDTH];
                end
            end
        end
    endgenerate

endmodule