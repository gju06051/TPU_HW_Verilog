module top(
    input           clk,
    input   [3:0]   din,
    output  [3:0]   out
);
    
    parameter TRUE = 1;

    generate
        if (TRUE == 1) begin
            sub U1 (.clk(clk), .din(w1), .dout(out));
            wire [3:0] w1;
        end
    endgenerate
    
    assign w1 = ~din;

endmodule

module sub(
    input clk,
    input [3:0] din,
    output reg [3:0] dout
);
    always@(posedge clk)
        dout <= din;

endmodule