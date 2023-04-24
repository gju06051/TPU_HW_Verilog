module COUNTER_NOTUSE #(
    // parameter
    parameter COUNT_BIT = 2,
    )
    (
    // port
    input   clk,
    input   rst_n,
    input   en,
    input   mode,       // 1'b0 : down, 1'b1: : up
    
    output  [COUNT_BIT-1:0] cnt_o;
    );
    
    localparam DOWN = 1'b0;
    
    reg [COUNT_BIT-1:0] cnt_temp;
    
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            cnt_temp <= {(COUNT_BIT){1'b0}};
        end else begin
            if (en) begin   // enable on
                if (mode == DOWN) begin // down mode
                    cnt_temp <= cnt_temp - 'd1;
                end else begin          // up mode
                    cnt_temp <= cnt_temp + 'd1;
                end    
            end else begin  // enable off
                cnt_temp <= cnt_temp;
            end
        end
    end
    
endmodule
