module ACC_COUNTER #(
    // Parameter
    parameter PE_SIZE = 14,
    parameter WEIGHT_ROW_NUM = 294,
    parameter WEIGHT_COL_NUM = 70
    )
    (
    // Port
    
    // Special Input
    input   clk,
    input   rst_n,
    // Control Input
    input   psum_en_i,
    // Valid Output
    output  ofmap_valid_o
    );


    // Local parameter
    localparam PSUM_CNT_NUM = WEIGHT_COL_NUM;           // 70
    localparam PSUM_CNT_WIDTH = $clog2(PSUM_CNT_NUM);
    localparam ACC_CNT_NUM = WEIGHT_ROW_NUM / PE_SIZE;  // 294 / 14 = 21
    localparam ACC_CNT_WIDTH = $clog2(ACC_CNT_NUM);
    
    
    
    // 1. Partial Sum Counter
    reg [PSUM_CNT_WIDTH-1:0] psum_cnt, psum_cnt_n;
    
    // 1-1) Psum counter seq logic
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            psum_cnt <= {(PSUM_CNT_WIDTH){1'b0}};
        end else begin
            psum_cnt <= psum_cnt_n;
        end
    end
    
    // 1-2) Psum counter comb logic
    always @(*) begin
        if (psum_cnt==WEIGHT_COL_NUM) begin
            psum_cnt_n = 0;
        end else if (psum_en_i) begin
            psum_cnt_n = psum_cnt + 'd1;
        end else begin
            psum_cnt_n = psum_cnt;  // maintain
        end
    end
    
    // 1-3) generate acc counter enable signal by using psum counter
    wire psum_cnt_done;
    assign psum_cnt_done = (psum_cnt==WEIGHT_COL_NUM);
    
    
    
    // 2. Accumulation Counter
    reg [ACC_CNT_WIDTH-1:0] acc_cnt, acc_cnt_n;
    
    // 2-1) Accumulation counter seq logic
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            acc_cnt <= {(ACC_CNT_WIDTH){1'b0}};
        end else begin
            acc_cnt <= acc_cnt_n;
        end
    end
    
    // 2-2) Accumulation counter comb logic
    always @(*) begin
        if (psum_cnt_done) begin
            if (acc_cnt==ACC_CNT_NUM-1) begin
                acc_cnt_n = 'd0;
            end else begin
                acc_cnt_n = acc_cnt + 'd1;
            end
        end else begin
            acc_cnt_n = acc_cnt;    // maintain
        end
    end
    
    // 2-3) output assignment
    assign ofmap_valid_o = (acc_cnt==ACC_CNT_NUM-1) & psum_en_i;    // ex. acc_cnt = 20, psum_en_i come

endmodule