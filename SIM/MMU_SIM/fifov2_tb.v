`timescale 1ps/1ps
`define DELTA 3
`define CLOCK_PERIOD 10

module FIFO_v2_TB #(
    // Parameter
    parameter DATA_WIDTH = 8,  // data bit width
    parameter FIFO_DEPTH = 6    // fifo entry num
    )
    (
    // No Port
    // This is TB
    );
    reg     clk;          // clock signal
    reg     rst_n;        // negedge pointer reset signal(don't need to reset data in fifo)
    reg     wren_i;       // write enable signal
    reg     rden_i;       // read denable signal
    
    wire    full_o;      // check fifo is full, if full the signal is high
    wire    empty_o;     // chcek fifo is empty, if empty the signal is high
    
    reg     [DATA_WIDTH-1:0] wdata_i;     // write data
    wire    [DATA_WIDTH-1:0] rdata_o;     // read data
    
    
    // DUT INST    
    FIFO_v2 #(
        .DATA_WIDTH ( DATA_WIDTH ),
        .FIFO_DEPTH ( FIFO_DEPTH )
    )u_FIFO_v2(
        .clk        ( clk        ),
        .rst_n      ( rst_n      ),
        .wren_i     ( wren_i     ),
        .rden_i     ( rden_i     ),
        .full_o     ( full_o     ),
        .empty_o    ( empty_o    ),
        .wdata_i    ( wdata_i    ),
        .rdata_o    ( rdata_o    )
    );


    // clock signal
    initial begin
        clk = 1'b0;
        forever begin
            #(`CLOCK_PERIOD/2) clk = ~clk;
        end
    end

    integer i;

    // Stimulus
    initial begin
        // 0. Initialize
        rst_n = 1'b1;
        wren_i = 1'b0;
        rden_i = 1'b0;
        wdata_i = {(DATA_WIDTH){1'b0}};
    
        // 1. reset
        @(posedge clk);
        #(`DELTA)
        rst_n = 1'b0;   // reset on
        
        @(posedge clk);
        #(`DELTA)
        rst_n = 1'b0;   // reset off
        
        
        // 2. Write activation
        for (i=0; i < FIFO_DEPTH+2; i=i+1) begin
            @(posedge clk);
            #(`DELTA)
            wren_i = 1'b1;
            wdata_i = i;
        end
        
        // Write off
        @(posedge clk);
        #(`DELTA)
        wren_i = 1'b0;    
        
        // 3. Read activation
        for (i=0; i< FIFO_DEPTH+2; i=i+1) begin
            @(posedge clk);
            #(`DELTA)
            rden_i = 1'b1;
        end

        // Read off
        @(posedge clk);
        #(`DELTA)
        rden_i = 1'b0;
    end
    
    endmodule