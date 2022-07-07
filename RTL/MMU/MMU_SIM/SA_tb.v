`timescale 1ps/1ps
`define DELTA 3
`define CLOCK_PERIOD 10

module SA_TB #(
    // parameter
    parameter PE_SIZE       = 16,
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
        weight_col_i    = {([DATA_WIDTH*PE_SIZE-1:0]){1'b0}}; 
        ifmap_row_i     = {([DATA_WIDTH*PE_SIZE-1:0]){1'b0}}; 
        psum_row_i      = {([PSUM_WIDTH*PE_SIZE-1:0]){1'b0}}; 
        weight_en_col_i = {(PE_SIZE-1:0){1'b0}};
        ifmap_en_row_i  = {(PE_SIZE-1:0){1'b0}};
        psum_en_row_i   = {(PE_SIZE-1:0){1'b0}};
    end
    
    
    integer i;
    
    // Stimulus
    initial begin
        
        // 1. Reset
        rst_n = 1'b1;
        #(`DELTA)
        rst_n = 1'b0;
        @(posedge clk);
        #(`DELTA)
        rst_n = 1'b1;
    
    
        // 2. Ifmap preload
        repeat (PE_SIZE) begin
            @(posedge clk);
            #(`DELTA)
            for (i=0; i < PE_SIZE; i=i+1) begin
                ifmap_en_row_i = {(PE_SIZE-1:0){1'b1}};
                ifmap_row_i[DATA_WIDTH*(PE_SIZE-i)-1 : DATA_WIDTH*(PE_SIZE-i-1)] = i;
            end
        end
        
        // 3. Ifmap preload stop(enable off)
        @(posedge clk);
        #(`DELTA)
        ifmap_en_row_i = {(PE_SIZE-1:0){1'b1}};
        
        
        // 4. Weight load & psum_enable
        repeat (PE_SIZE) begin
            @(posedge clk);
            #(`DELTA)
            for (i=0; i < PE_SIZE; i=i+1) begin
                weight_en_col_i = {(PE_SIZE-1:0){1'b1}};
                weight_col_i[DATA_WIDTH*(PE_SIZE-i)-1 : DATA_WIDTH*(PE_SIZE-i-1)] = i;
                psum_en_row_i = {(PE_SIZE-1:0){1'b1}};
                psum_row_i[PSUM_WIDTH*(PE_SIZE-i)-1 : PSUM_WIDTH*(PE_SIZE-i-1)] = 'd0;
            end
        end
        
        
        // Weight, Psum load stop(enable off)
        
        // Waiting Activation
        
        // END
    end
    
endmodule