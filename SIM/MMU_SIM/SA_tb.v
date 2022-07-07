`timescale 1ps/1ps
`define DELTA 3
`define CLOCK_PERIOD 10

module SA_TB #(
    // parameter
    parameter PE_SIZE       = 2,
    parameter DATA_WIDTH    = 8,
    parameter PSUM_WIDTH    = 32
    )
    (
    // no inout
    // this is testbench
    );
    
    // special input
    reg clk;
    reg rst_n;

    // input primitivies
    reg     [DATA_WIDTH*PE_SIZE-1:0]    weight_col_i;
    reg     [DATA_WIDTH*PE_SIZE-1:0]    ifmap_row_i;
    reg     [PSUM_WIDTH*PE_SIZE-1:0]    psum_row_i;
    
    // input enable signal
    reg     [PE_SIZE-1:0]               weight_en_col_i;
    reg     [PE_SIZE-1:0]               ifmap_en_row_i;
    reg     [PE_SIZE-1:0]               psum_en_row_i;
    
    // output primitivies 
    wire    [DATA_WIDTH*PE_SIZE-1:0]    weight_col_o;
    wire    [DATA_WIDTH*PE_SIZE-1:0]    ifmap_row_o;
    wire    [PSUM_WIDTH*PE_SIZE-1:0]    psum_row_o;
    
    // output enable signal
    wire    [PE_SIZE-1:0]               weight_en_col_o;      
    wire    [PE_SIZE-1:0]               ifmap_en_row_o;      
    wire    [PE_SIZE-1:0]               psum_en_row_o;      


    // DUT INST
    SA #(
        .PE_SIZE         ( PE_SIZE ),
        .DATA_WIDTH      ( DATA_WIDTH),
        .PSUM_WIDTH      ( PSUM_WIDTH )
    ) SA_DUT (
        .clk             ( clk             ),
        .rst_n           ( rst_n           ),
        .weight_col_i    ( weight_col_i    ),
        .ifmap_row_i     ( ifmap_row_i     ),
        .psum_row_i      ( psum_row_i      ),
        .weight_en_col_i ( weight_en_col_i ),
        .ifmap_en_row_i  ( ifmap_en_row_i  ),
        .psum_en_row_i   ( psum_en_row_i   ),
        .weight_col_o    ( weight_col_o    ),
        .ifmap_row_o     ( ifmap_row_o     ),
        .psum_row_o      ( psum_row_o      ),
        .weight_en_col_o ( weight_en_col_o ),
        .ifmap_en_row_o  ( ifmap_en_row_o  ),
        .psum_en_row_o   ( psum_en_row_o   )
    );

    // Clock Signal
    initial begin
        clk = 1'b0;
        forever begin
            #(`CLOCK_PERIOD/2) clk = ~clk;
        end
    end
    
    // Initialization
    initial begin
        clk             = 1'b0;
        rst_n           = 1'b1;
        weight_col_i    = {(DATA_WIDTH*PE_SIZE){1'b0}}; 
        ifmap_row_i     = {(DATA_WIDTH*PE_SIZE){1'b0}}; 
        psum_row_i      = {(PSUM_WIDTH*PE_SIZE){1'b0}}; 
        weight_en_col_i = {(PE_SIZE){1'b0}};
        ifmap_en_row_i  = {(PE_SIZE){1'b0}};
        psum_en_row_i   = {(PE_SIZE){1'b0}};
    end
    
    
    integer cycle;
    
    // Stimulus
    initial begin
        
        // 1. Reset
        #(`DELTA)
        rst_n = 1'b0;
        @(posedge clk);
        cycle = 0;
        #(`DELTA)
        rst_n = 1'b1;
    
    
        // 2. Ifmap preload
        // 2-1) ifmap row1
        @(posedge clk);
        cycle = 1;
        #(`DELTA)
        ifmap_en_row_i = {(PE_SIZE){1'b1}};
        ifmap_row_i = 'h0204;
        
        // 2-2) ifmap row2
        @(posedge clk);
        cycle = 2;
        #(`DELTA)
        ifmap_en_row_i = {(PE_SIZE){1'b0}};
        ifmap_row_i = 'h0103;
        
        // 3. Ifmap preload stop(enable off)
        @(posedge clk);
        cycle = 3;
        #(`DELTA)
        ifmap_en_row_i = {(PE_SIZE){1'b0}};
        ifmap_row_i = 'h00_00;  // uncorrect val
        
        // sleep sa weight & psum 
        repeat (3) begin
            @(posedge clk);
            cycle = 3;
            #(`DELTA)
            ifmap_row_i = 'h00_00;  // uncorrect val
        end
        
        // 4. Weight load & psum_enable
        // 4-1. weight col1
        @(posedge clk);
        cycle = 4; 
        #(`DELTA)
        weight_en_col_i = {(PE_SIZE){1'b1}};
        weight_col_i = 'h01_00;
        psum_en_row_i = {(PE_SIZE){1'b1}};
        psum_row_i = 'h0000000000000000;
        
        // 4-2. weight col2
        @(posedge clk);
        cycle = 5;
        #(`DELTA)
        weight_en_col_i = {(PE_SIZE){1'b1}};
        weight_col_i = 'h02_03;
        psum_en_row_i = {(PE_SIZE){1'b1}};
        psum_row_i = 'h0000000000000000;
        
        
        // 4-2. weight col3
        @(posedge clk);
        cycle = 6;
        #(`DELTA)
        weight_en_col_i = {(PE_SIZE){1'b1}};
        weight_col_i = 'h00_04;
        psum_en_row_i = {(PE_SIZE){1'b1}};
        psum_row_i = 'h0000000000000000;
        
        // Weight, Psum load stop(enable off)
        @(posedge clk);
        cycle = 7;
        #(`DELTA)
        weight_en_col_i = {(PE_SIZE){1'b1}};
        weight_col_i = 'h00_00;
        psum_en_row_i = {(PE_SIZE){1'b1}};
        psum_row_i = 'h0000000000000000;
        
        
        // Waiting Activation
        repeat (3) begin
            @(posedge clk);
            cycle = cycle + 1;
            #(`DELTA)
            ifmap_en_row_i = {(PE_SIZE){1'b0}};
            weight_en_col_i = {(PE_SIZE){1'b0}};
            psum_en_row_i = {(PE_SIZE){1'b0}};
        end
        
        
    end
    
endmodule