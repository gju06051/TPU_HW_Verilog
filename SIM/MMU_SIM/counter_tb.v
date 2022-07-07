`timescale 1ps/1ps
`define DELTA 3
`define CLOCK_PERIOD 10

module Counter_TB #(
    // Parameter
    parameter COUNT_NUM = 16
    )
    (
    // No Port
    // This is testbench
    );
    
    reg     clk;
    reg     rst_n;
    reg     start_i;
    
    wire    done_o;
    
    // INST DUT    
    Counter #(
        .COUNT_NUM ( COUNT_NUM )
    ) COUNTER_DUT (
        .clk     ( clk     ),
        .rst_n   ( rst_n   ),
        .start_i ( start_i ),
        .done_o  ( done_o  )
    );


    // Clock Signal
    initial begin
        clk = 1'b0;
        forever begin
            #(`CLOCK_PERIOD/2) clk = ~clk;
        end
    end

    // Initialize
    initial begin
        rst_n = 'b0;
        start_i = 'b0;
    end

    // Stimulus
    // 1. Reset
    rst_n = 'b1;
    @(posedge clk);
    #(`DELTA)
    rst_n = 'b0;
    
    // 2. Start in
    
    // test1.
    @(posedge clk);
    #(`DELTA)
    start_i = 1'b1;
    
    repeat (COUNT_NUM) begin
        @(posedge clk);
        #(`DELTA)
        start_i = 1'b0;
    end
    
    repeat (3) begin
        @(posedge clk);
        #(`DELTA)
        start_i = 1'b0;
    end
    
    // test2.
    @(posedge clk);
    #(`DELTA)
    start_i = 1'b1;
    
    repeat (COUNT_NUM) begin
        @(posedge clk);
        #(`DELTA)
        start_i = 1'b0;
    end
    
    repeat (3) begin
        @(posedge clk);
        #(`DELTA)
        start_i = 1'b0;
    end
    
    
endmodule