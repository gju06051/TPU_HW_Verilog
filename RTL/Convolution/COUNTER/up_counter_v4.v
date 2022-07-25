// another veriosn of up_counter_v2
// add OFFSET parameter to up_counter_v2
module up_counter_v4 #(
    parameter CNT_1 = 14,
    parameter CNT_2 = 8,
    parameter CNT_WIDTH = 4,
    parameter OFFSET = 14
)
(
    input clk,
    input rst_n,
    input en,
    input sel,
    output wire [CNT_WIDTH-1:0] cnt_o,
    output wire is_done_o_1,
    output wire is_done_o_2
);
    reg [CNT_WIDTH-1:0] cnt;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            cnt <= 0;
        end else if(en) begin
            if(sel == 1'b0) begin
                if(is_done_o_1) begin
                    cnt <= 0;
                end else begin
                    cnt <= cnt + OFFSET;
                end
            end else begin
                if(is_done_o_2) begin
                    cnt <= 0;
                end else begin
                    cnt <= cnt + OFFSET;
                end
            end
        end
    end
    assign cnt_o = cnt;
    assign is_done_o_1 = (en) && (sel == 1'b0) && (cnt == CNT_1*OFFSET-1);
    assign is_done_o_2 = (en) && (sel == 1'b1) && (cnt == CNT_2*OFFSET-1);
endmodule