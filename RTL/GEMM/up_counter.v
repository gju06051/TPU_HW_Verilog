module up_counter #(
    parameter CNT = 14,
    parameter CNT_WIDTH = 4
)
(
    input clk,
    input rst_n,
    input en,
    output wire [CNT_WIDTH-1:0] cnt_o,
    output wire is_done_o
);
    reg [CNT_WIDTH-1:0] cnt;
    always @(posedge clk or rst_n) begin
        if(!rst_n) begin
            cnt <= 0;
        end else if(en) begin
            if(is_done_o) begin
                cnt <= 0;
            end else begin
                cnt <= cnt + 1;
            end
        end
    end
    assign cnt_o = cnt;
    assign is_done_o = (en) && (cnt == CNT_WIDTH-1);
endmodule