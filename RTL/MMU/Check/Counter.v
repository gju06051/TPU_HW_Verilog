module Counter #(
    // Parameter
    parameter COUNT_NUM = 16
    )
    (
    // Port
    input   clk,
    input   rst_n,
    input   en,
    
    output  finish_o
    );
    
    localparam COUNT_LG2 = $clog2(COUNT_NUM);
    
    reg [COUNT_LG2-1:0] cnt_temp;
    
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            cnt_temp <= {(COUNT_LG2){1'b0}};
        end else begin
            if (en) begin
                cnt_temp <= cnt_temp + 'd1;
            end    
        end
    end
    
endmodule
