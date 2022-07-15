`timescale 1ps/1ps
`define DELTA 3
`define CLOCK_PERIOD 10

module ACC_COUNTER_TB #(
    // Parameter
    parameter PE_SIZE = 14,
    parameter WEIGHT_ROW_NUM = 294,
    parameter WEIGHT_COL_NUM = 70
    )
    (
    // No Port
    // This is TB
    );    
    
    reg   clk;
    reg   rst_n;
    reg   psum_en_i;
    wire  ofmap_valid_o;
    

    // DUT INST
    ACC_COUNTER #(
        .PE_SIZE        ( PE_SIZE ),
        .WEIGHT_ROW_NUM ( WEIGHT_ROW_NUM ),
        .WEIGHT_COL_NUM ( WEIGHT_COL_NUM )
    )u_ACC_COUNTER(
        .clk            ( clk            ),
        .rst_n          ( rst_n          ),
        .psum_en_i      ( psum_en_i      ),
        .ofmap_valid_o  ( ofmap_valid_o  )
    );
    
    // clock signal
    initial begin
        clk = 1'b0;
        forever begin
            #(`CLOCK_PERIOD/2) clk = ~clk;
        end
    end

    integer i;
    integer j;
    // Stimulus
    initial begin
        // 0. Initialize
        rst_n = 1'b1;
        psum_en_i = 1'b0;
        
        // 1. Reset
        @(posedge clk);
        #(`DELTA)
        rst_n = 1'b0;
        
        @(posedge clk);
        #(`DELTA)
        rst_n = 1'b1;
        
        // 2. Psum Counting & ACC Counting
        for (i=0; i < (WEIGHT_ROW_NUM/PE_SIZE) + 3; i=i+1) begin
            for (j=0; j < WEIGHT_COL_NUM; j=j+1) begin
                @(posedge clk);
                #(`DELTA)
                psum_en_i = 1'b1;
            end
        end
        
        
        // 3. check valid
        repeat (10) begin
            @(posedge clk);
            #(`DELTA)
            psum_en_i = 1'b0;        
        end
        
    end

endmodule