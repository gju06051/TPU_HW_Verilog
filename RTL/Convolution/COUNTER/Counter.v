module Counter #(
    // Parameter
    parameter COUNT_NUM = 4
    )
    (
    // Port
    input   clk,
    input   rst_n,
    input   start_i,
    
    output  done_o
    );
    
    localparam COUNT_LG2 = $clog2(COUNT_NUM);
    
    localparam IDLE = 2'b00;
    localparam RUN  = 2'b01;
    localparam DONE = 2'b10;
    
    reg [1:0] c_state, n_state;
    reg [COUNT_LG2-1:0] cnt_num;
    
    // state register(seq)
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            c_state <= IDLE;
        end else begin
            c_state <= n_state;
        end
    end
    
    // next state logic(comb)
    always @(*) begin 
        n_state = c_state;  // latch prevent
        case (c_state)
            IDLE    : begin
                if (start_i) begin
                    n_state = RUN;
                end
            end
            RUN     : begin
                if (cnt_num==COUNT_NUM-1) begin
                    n_state = DONE;
                end
            end
            DONE    : begin
                n_state = IDLE;
            end
            default : begin
                n_state = IDLE;
            end
        endcase
    end
    
    
    // Counter logic
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            cnt_num <= {(COUNT_LG2){1'b0}};
        end else begin
            case (c_state)
                IDLE    : cnt_num <= {(COUNT_LG2){1'b0}};
                RUN     : cnt_num <= cnt_num + 'd1;
                DONE    : cnt_num <= {(COUNT_LG2){1'b0}};
                default : cnt_num <= {(COUNT_LG2){1'b0}};
            endcase
        end
    end
    
    // Output logic
    assign done_o = (c_state==DONE);
    
endmodule
