module up_counter_v3 #(
    parameter CNT = 14,
    parameter CNT_WIDTH = 4,
    parameter OFFSET = 14
)
(
    input clk,
    input rst_n,
    input en,
    output wire [CNT_WIDTH-1:0] cnt_o,
    output wire is_done_o
);
    reg [CNT_WIDTH-1:0] cnt;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt <= 0;
        end else if(en) begin
            if(is_done_o) begin
                cnt <= 0;
            end else begin
                cnt <= cnt + OFFSET;
            end
        end
    end
    assign cnt_o = cnt;
    assign is_done_o = (en) && (cnt == CNT*OFFSET-1);
endmodule