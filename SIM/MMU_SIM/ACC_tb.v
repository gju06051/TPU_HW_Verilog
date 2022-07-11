`timescale 1ps/1ps
`define DELTA 3
`define CLOCK_PERIOD 10

module ACC_TB #(
    // Parameter
    parameter PE_SIZE       = 4,
    parameter DATA_WIDTH    = 32,
    parameter FIFO_DEPTH    = 4
    )
    (
    // No Port
    // This is TB
    );
    
    // Special input
    reg     clk;
    reg     rst_n;
    
    // R/W enable signal
    reg     [PE_SIZE-1:0]   psum_en_i;          // signal from SA, used for fifo write signal
    reg     [PE_SIZE-1:0]   rden_i;             // signal from Top control, read data from fifo to GLB
    
    // I/O data
    reg     [DATA_WIDTH*PE_SIZE-1:0]    psum_row_i;
    wire    [DATA_WIDTH*PE_SIZE-1:0]    psum_row_o;
    
    
    
    
    ACC #(
        .PE_SIZE    ( 4 ),
        .DATA_WIDTH ( 32 ),
        .FIFO_DEPTH ( 4 )
    ) ACC_INST (
        .clk        ( clk        ),
        .rst_n      ( rst_n      ),
        .psum_en_i  ( psum_en_i  ),
        .rden_i     ( rden_i     ),
        .psum_row_i ( psum_row_i ),
        .psum_row_o ( psum_row_o )
    );

    // Clock Signal
    initial begin
        clk = 1'b0;
        forever begin
            #(`CLOCK_PERIOD/2) clk = ~clk;
        end
    end
    
    integer cycle;

    // Initialization
    initial begin
        cycle = 0;
        rst_n = 1'b1;
        psum_en_i = {(PE_SIZE){1'b0}};
        rden_i = {(PE_SIZE){1'b0}};
        psum_row_i = {(DATA_WIDTH*PE_SIZE){1'b0}};
    end


    /*
    Test strategy
    1. Reset module
    2. give psum enable and psum value 4line -> psum preload(not full)
    3. give psum enable and psum value 4line * 3times -> accumulation(full)
    4. give rden signal and check fifo reading activation
    */
    


    // Stimulus
    initial begin
        // 1. RESET
        #(`DELTA)
        rst_n = 1'b0;
        @(posedge clk);
        cycle = cycle + 1;
        #(`DELTA)
        rst_n = 1'b1;
        
        // 2. Psum preload
        // 2-1) psum row1
        @(posedge clk);
        cycle = cycle + 1;
        #(`DELTA)
        psum_en_i = 4'b1111;
        psum_row_i = 'h01_02_03_04;
        
        // 2-2) psum row2
        @(posedge clk);
        cycle = cycle + 1;
        #(`DELTA)
        psum_en_i = 4'b1111;
        psum_row_i = 'h02_03_04_05;
        
        // 2-3) psum row3
        @(posedge clk);
        cycle = cycle + 1;
        #(`DELTA)
        psum_en_i = 4'b1111;
        psum_row_i = 'h03_04_05_06;
        
        // 2-4) psum row4
        @(posedge clk);
        cycle = cycle + 1;
        #(`DELTA)
        psum_en_i = 4'b1111;
        psum_row_i = 'h04_05_06_07;
        
        // 3. Accumulation
        repeat (12) begin
            @(posedge clk);
            cycle = cycle + 1;
            #(`DELTA)
            psum_en_i = 4'b1111;
            psum_row_i = 'h01_01_01_01;
        end
        
        // 4. Rden give for checking value
        repeat (4) begin
            @(posedge clk);
            psum_en_i = 4'b0000;
            cycle = cycle + 1;
            #(`DELTA)
            rden_i = 4'b1111;
        end
        
        // 5. Waiting Activation
        repeat (4) begin
            @(posedge clk);
            psum_en_i = 4'b0000;
            cycle = cycle + 1;
        end
    
    end


endmodule