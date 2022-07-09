`timescale 1ps/1ps
`define DELTA 3
`define CLOCK_PERIOD 10

module SA_TB #(
    // parameter
    parameter PE_SIZE       = 4,
    parameter DATA_WIDTH    = 8,
    parameter PSUM_WIDTH    = 32
    )
    (
    // Not port
    // This is testbench
    );
    // special input
    reg clk;
    reg rst_n;

    // input primitivies
    reg     [DATA_WIDTH*PE_SIZE-1:0]    ifmap_row_i;
    reg     [DATA_WIDTH*PE_SIZE-1:0]    weight_col_i;
    reg     [PSUM_WIDTH*PE_SIZE-1:0]    psum_row_i;
    
    // input enable signal
    reg                               ifmap_preload_i;
    reg     [PE_SIZE-1:0]               weight_en_col_i;
    reg     [PE_SIZE-1:0]               psum_en_row_i;
    
    
    // output primitivies 
    wire    [DATA_WIDTH*PE_SIZE-1:0]    ifmap_row_o;
    wire    [DATA_WIDTH*PE_SIZE-1:0]    weight_col_o;
    wire    [PSUM_WIDTH*PE_SIZE-1:0]    psum_row_o;
    
    // output enable signal     
    wire    [PE_SIZE-1:0]               weight_en_col_o;      
    wire    [PE_SIZE-1:0]               psum_en_row_o;    
    
    
    

    SA #(
        .PE_SIZE         ( PE_SIZE      ),
        .DATA_WIDTH      ( DATA_WIDTH   ),
        .PSUM_WIDTH      ( PSUM_WIDTH   )
    )u_SA(
        // Special signal
        .clk             ( clk             ),
        .rst_n           ( rst_n           ),
        // input primitivies
        .ifmap_row_i     ( ifmap_row_i     ),
        .weight_col_i    ( weight_col_i    ),
        .psum_row_i      ( psum_row_i      ),
        // input enable signal
        .ifmap_preload_i ( ifmap_preload_i ),
        .weight_en_col_i ( weight_en_col_i ),
        .psum_en_row_i   ( psum_en_row_i   ),
        // output primitives
        .ifmap_row_o     ( ifmap_row_o     ),
        .weight_col_o    ( weight_col_o    ),
        .psum_row_o      ( psum_row_o      ),
        // output enable siganl
        .weight_en_col_o ( weight_en_col_o ),
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
        clk                 = 1'b0;
        rst_n               = 1'b1;
        weight_col_i        = {(DATA_WIDTH*PE_SIZE){1'b0}}; 
        ifmap_row_i         = {(DATA_WIDTH*PE_SIZE){1'b0}}; 
        psum_row_i          = {(PSUM_WIDTH*PE_SIZE){1'b0}}; 
        ifmap_preload_i     = 1'b0;
        weight_en_col_i     = {(PE_SIZE){1'b0}};
        psum_en_row_i       = {(PE_SIZE){1'b0}};
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
        // 2-1) ifmap row4
        @(posedge clk);
        cycle = cycle + 1;
        #(`DELTA)
        ifmap_preload_i = 1'b1;
        ifmap_row_i = 'h04_04_04_04;
        
        // 2-2) ifmap row3
        @(posedge clk);
        cycle = cycle + 1;
        #(`DELTA)
        ifmap_preload_i = 1'b0;
        ifmap_row_i = 'h03_03_03_03;
        
        // 2-3) ifmap row2
        @(posedge clk);
        cycle = cycle + 1;
        #(`DELTA)
        ifmap_preload_i = 1'b0;
        ifmap_row_i = 'h02_02_02_02;
        
        // 2-4) ifmap row1
        @(posedge clk);
        cycle = cycle + 1;
        #(`DELTA)
        ifmap_preload_i = 1'b0;
        ifmap_row_i = 'h01_01_01_01;
        
        
        // 3. check ifmap enable signal for give uncorrect number
        // 3-1) give 1row
        @(posedge clk);
        cycle = cycle + 1;
        #(`DELTA)
        ifmap_row_i = 'h10_10_10_10;  // uncorrect val
        
        // 3-2) sleep sa weight & psum 
        repeat (3) begin
            @(posedge clk);
            cycle = cycle + 1;
            #(`DELTA)
            ifmap_row_i = 'h00_00_00_00;  // uncorrect val
        end
        
        
        // 4. Weight load & psum_enable
        // 4-1) weight col1
        @(posedge clk);
        cycle = cycle + 1;
        #(`DELTA)
        weight_en_col_i = 4'b1000;
        weight_col_i = 'h01_00_00_00;
        psum_en_row_i = {(PE_SIZE){1'b1}};
        psum_row_i = 'h00000000_00000000_00000000_00000000;
        
        // 4. Weight load & psum_enable
        // 4-2) weight col2
        @(posedge clk);
        cycle = cycle + 1;
        #(`DELTA)
        weight_en_col_i = 4'b1100;
        weight_col_i = 'h02_01_00_00;
        psum_en_row_i = {(PE_SIZE){1'b1}};
        psum_row_i = 'h00000000_00000000_00000000_00000000;
        
        // 4. Weight load & psum_enable
        // 4-3) weight col3
        @(posedge clk);
        cycle = cycle + 1;
        #(`DELTA)
        weight_en_col_i = 4'b1110;
        weight_col_i = 'h03_02_01_00;
        psum_en_row_i = {(PE_SIZE){1'b1}};
        psum_row_i = 'h00000000_00000000_00000000_00000000;
        
        // 4. Weight load & psum_enable
        // 4-4) weight col4
        @(posedge clk);
        cycle = cycle + 1;
        #(`DELTA)
        weight_en_col_i = 4'b1111;
        weight_col_i = 'h04_03_02_01;
        psum_en_row_i = {(PE_SIZE){1'b1}};
        psum_row_i = 'h00000000_00000000_00000000_00000000;
        
        // 4. Weight load & psum_enable
        // 4-5. weight col5
        @(posedge clk);
        cycle = cycle + 1;
        #(`DELTA)
        weight_en_col_i = 4'b0111;
        weight_col_i = 'h00_04_03_02;
        psum_en_row_i = {(PE_SIZE){1'b1}};
        psum_row_i = 'h00000000_00000000_00000000_00000000;
        
        // 4. Weight load & psum_enable
        // 4-6. weight col6
        @(posedge clk);
        cycle = cycle + 1;
        #(`DELTA)
        weight_en_col_i = 4'b0011;
        weight_col_i = 'h00_00_04_03;
        psum_en_row_i = {(PE_SIZE){1'b1}};
        psum_row_i = 'h00000000_00000000_00000000_00000000;
        
        // 4. Weight load & psum_enable
        // 4-5. weight col7
        @(posedge clk);
        cycle = cycle + 1;
        #(`DELTA)
        weight_en_col_i = 4'b0001;
        weight_col_i = 'h00_00_00_04;
        psum_en_row_i = {(PE_SIZE){1'b1}};
        psum_row_i = 'h00000000_00000000_00000000_00000000;
        
        // 4. Weight load & psum_enable
        // 4-5. weight col5
        @(posedge clk);
        cycle = cycle + 1;
        #(`DELTA)
        weight_en_col_i = 4'b0000;
        weight_col_i = 'h00_00_00_00;
        psum_en_row_i = {(PE_SIZE){1'b1}};
        psum_row_i = 'h00000000_00000000_00000000_00000000;
        
        
        // 5. Weight, Psum load stop(enable off)
        @(posedge clk);
        cycle = cycle + 1;
        #(`DELTA)
        weight_en_col_i = 4'b0000;
        weight_col_i = 'h00_00_00_00;
        psum_en_row_i = {(PE_SIZE){1'b1}};
        psum_row_i = 'h00000000_00000000_00000000_00000000;
        
        
        // 6. Waiting Activation
        repeat (3) begin
            @(posedge clk);
            cycle = cycle + 1;
            #(`DELTA)
            weight_en_col_i = {(PE_SIZE){1'b0}};
            psum_en_row_i = {(PE_SIZE){1'b0}};
        end
        
        
    end
    
endmodule