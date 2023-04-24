`timescale 1ps/1ps
`define DELTA 3
`define CLOCK_PERIOD 10

module DFF_TB #(
    parameter DATA_WIDTH = 16
    )
    (
    // no inout
    // this is testbench
    );
    
    reg     CLK;
    reg     RST_N;
    reg     EN;
    reg     [DATA_WIDTH-1:0] D;
    wire    [DATA_WIDTH-1:0] Q;

    DFF #(
        .DATA_WIDTH(DATA_WIDTH)
    ) DUT (
        // port
        .clk    (CLK),
        .rst_n  (RST_N),
        .en     (EN),
        .d      (D),
        .q      (Q)
    );
    
    // clock signal
    initial begin
        CLK = 1'b0;
        forever begin
            #(`CLOCK_PERIOD/2) CLK = ~CLK;
        end
    end

    // generate reset signal
    initial begin
        RST_N = 1'b1;
        EN = 1'b0;
        #(`DELTA)
        RST_N = 1'b0;
    end
    
    // monitor func
    initial begin 
        $monitor("time = %3d, RESET = %b, ENABLE = %b, Data_in = %b, DATA_OUT = %b \n",
            $time, RST_N, EN, D, Q);
    end
    
    // test stimulus
    initial begin
        // initialize
        RST_N = 1'b1;
        EN = 1'b0;
        D = {(DATA_WIDTH){1'b0}};
        
        
        // stimulus
        
        // reset signal
        repeat(3) begin
            @(posedge CLK);
        end
        #(`DELTA)
            RST_N = 1'b1;
        #(`DELTA)
            RST_N = 1'b0;
        #(`DELTA*3)
            RST_N = 1'b1;
        
        
        // data in
        @(posedge CLK);
        #(`DELTA)
            D = 'd3;
            
        // enable on
        @(posedge CLK);
        #(`DELTA)
            EN = 1'b1;
        
        // data change
        repeat(3) begin
            @(posedge CLK);
        end
        #(`DELTA)
            D = 'd4;
        
        // enable off
        @(posedge CLK);
        #(`DELTA)
            EN = 1'b0;
            
        // data change
        @(posedge CLK);
        #(`DELTA)
            D = 'd8;
        
        // finish wait 
        repeat(3) begin
            @(posedge CLK);
        end
        
        $display("finished testbench");
        $finish;
        
    end

endmodule