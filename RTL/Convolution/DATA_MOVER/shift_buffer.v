module shift_buffer # (
    parameter DATA_WIDTH = 8,
    parameter SIZE = 14
) (
    input clk,
    input en,
    input [DATA_WIDTH-1:0] data_i,
    output [DATA_WIDTH-1:0] data_o
);
    genvar i;
    reg [DATA_WIDTH*SIZE-1:0] buff;
    generate
        for(i = 1; i < SIZE; i = i + 1) begin
            always @(posedge clk) begin
                if(en) begin
                    buff[i*DATA_WIDTH +:DATA_WIDTH] <= buff[(i-1)*DATA_WIDTH +:DATA_WIDTH];
                end
            end
        end
    endgenerate

    always @(posedge clk) begin
        if(en)
            buff[0+:DATA_WIDTH] <= data_i;
    end

endmodule