`timescale 1ps/1ps
`define DELTA 3
`define CLOCK_PERIOD 10

module FIFO_TB #(
    // Parameter
    parameter DATA_WIDTH = 32,  // data bit width
    parameter FIFO_DEPTH = 8    // fifo entry num
    )
    (
    // no inout
    // this is testbench
    );
    
    // Port
    reg     CLK;    
    reg     RST_N;    
    reg     WE;   
    reg     RE;  
    
    wire    FULL;   
    wire    EMPTY;  
    
    reg    [DATA_WIDTH-1:0] WD;
    wire   [DATA_WIDTH-1:0] RD; 


    FIFO #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) DUT (
        // Port
        .clk    (CLK),    
        .rst_n  (RST_N),    
        .wren_i (WE),   
        .rden_i (RE),  
        
        .full_o (FULL),   
        .empty_o(EMPTY),  
        
        .wdata_i(WD),
        .rdata_o(RD) 
    );


    // clock signal
    initial begin
        CLK = 1'b0;
        forever begin
            #(`CLOCK_PERIOD/2) CLK = ~CLK;
        end
    end


    // monitor func
    initial begin 
        $monitor("RESET_N = %b, Write_EN = %b, Read_EN = %b, FULL = %b, EMPTY = %b, Write_DATA = %b, Read_DATA = %b",
                    RST_N, WE, RE, FULL, EMPTY, WD, RD);
    end
    
    integer i;
    
    // test stimulus
    initial begin
        // initialize
        RST_N = 1'b1;
        WE = 1'b0;
        RE = 1'b0;
        WD = {(DATA_WIDTH){1'b0}};

        // Reset pointer
        RST_N = 1'b0;
        @(posedge CLK);
        RST_N = 1'b1;
        
        @(posedge CLK);
        #(`DELTA)
        // write
        for (i=0; i<FIFO_DEPTH; i=i+1) begin
            $display("Write %d", i);
            #(`DELTA)
            WE = 1'b1;
            WD = i;
            @(posedge CLK);
        end
        
        // write off
        WE = 1'b0;
        WD = {(DATA_WIDTH){1'b0}};
        
        @(posedge CLK);
        #(`DELTA)
        
        // read
        for (i=0; i<FIFO_DEPTH; i=i+1) begin
            $display("Read %d", i);
            #(`DELTA)
            RE = 1'b1;
            @(posedge CLK);
        end
        
        #(`DELTA)
        RE = 1'b0;
        $display("finished testbench");
        @(posedge CLK);
    end

endmodule