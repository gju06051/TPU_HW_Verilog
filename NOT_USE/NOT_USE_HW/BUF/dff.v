module DFF #(
    parameter DATA_WIDTH = 8
    )
    (
    // port
    input   clk,
    input   rst_n,
    input   en,
    
    input   [DATA_WIDTH-1:0]    d,
    output  [DATA_WIDTH-1:0]    q

    );
    
    // wire & reg
    reg     [DATA_WIDTH-1:0]    q_temp;
    
    // flipflop update
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            q_temp <= {(DATA_WIDTH){1'b0}};
        end else if (en) begin
            q_temp <= d;
        end
    end

    // output assignment
    assign q = q_temp;

endmodule