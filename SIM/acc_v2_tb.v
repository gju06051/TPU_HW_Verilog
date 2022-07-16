`timescale 1ps/1ps
`define DELTA 3
`define CLOCK_PERIOD 10

module ACC_v2_TB #(
    // Parameter
    
    // Primitives Param
    parameter PE_SIZE           = 14,
    parameter DATA_WIDTH        = 8,
    parameter PSUM_WIDTH        = 32,
    // Quantization Param
    parameter SLICING_IDX       = 32,
    // Matrix Param for counter
    parameter WEIGHT_ROW_NUM    = 294,
    parameter WEIGHT_COL_NUM    = 70
    )
    (
    // No Port
    // This is TB
    );
    
    // Special input
    reg   clk;
    reg   rst_n;
    
    // R/W enable signal
    reg    [PE_SIZE-1:0]   psum_en_row_i;              // signal from SA, used for fifo write signal
    
    // I/O data
    reg    [PSUM_WIDTH*PE_SIZE-1:0]     psum_row_i;
    wire   [DATA_WIDTH*PE_SIZE-1:0]     ofmap_row_o;
    wire                                ofmap_valid_o;   // first fifo ofmap valid signal
    
    reg [PSUM_WIDTH-1:0]    test_num;
    
    
    // DUT INST
    ACC_v2 #(
        .PE_SIZE        ( PE_SIZE ),
        .DATA_WIDTH     ( DATA_WIDTH ),
        .PSUM_WIDTH     ( PSUM_WIDTH ),
        .SLICING_IDX    ( SLICING_IDX ),
        .WEIGHT_ROW_NUM ( WEIGHT_ROW_NUM ),
        .WEIGHT_COL_NUM ( WEIGHT_COL_NUM )
    )u_ACC_v2(
        .clk            ( clk            ),
        .rst_n          ( rst_n          ),
        .psum_en_row_i  ( psum_en_row_i  ),
        .psum_row_i     ( psum_row_i     ),
        .ofmap_row_o    ( ofmap_row_o    ),
        .ofmap_valid_o  ( ofmap_valid_o  )
    );

    // Clock Signal
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
        psum_en_row_i = {(PE_SIZE){1'b0}};
        psum_row_i = {(DATA_WIDTH){1'b0}};
        
        // 1. Reset
        // 1-1) reset on
        @(posedge clk);
        #(`DELTA)
        rst_n = 1'b0;       
        // 1-2) reset off
        @(posedge clk);
        #(`DELTA)
        rst_n = 1'b1;       
        
        test_num = 'h0000_1000;
        
        // 2. Psum preload
        // 2-1) psum load
        for (i=0; i < PE_SIZE; i=i+1) begin
            @(posedge clk);
            #(`DELTA)
            psum_en_row_i[(PE_SIZE-i)-1] = 1'b1;
            psum_row_i = {(PE_SIZE){test_num}};
        end
        
        test_num = 'h0000_0100;
        
        for (i=0; i < PE_SIZE*4; i=i+1) begin
            @(posedge clk);
            #(`DELTA)
            psum_en_row_i = {(PE_SIZE){1'b1}};
            psum_row_i = {(PE_SIZE){test_num}};
        end
        
        test_num = 'h0000_0010;
        
        for (i=0; i < PE_SIZE-1; i=i+1) begin
            @(posedge clk);
            #(`DELTA)
            psum_en_row_i[(PE_SIZE-i)-1] = 1'b0;
            psum_row_i = {(PE_SIZE){test_num}};
        end
        
        test_num = 'd0;
        
        // 2-2) ifmap preload delay
        repeat (5) begin
            @(posedge clk);
            #(`DELTA)
            psum_en_row_i = {(PE_SIZE){1'b0}};
            psum_row_i = {(PE_SIZE){test_num}};
        end
        
        // 3. Psum accumulation
        
        repeat (19) begin   // preload 1time, acc 19time -> 21th value ofmap
            
            test_num = 'h0100_0000;
            
            for (i=0; i < PE_SIZE; i=i+1) begin
                @(posedge clk);
                #(`DELTA)
                psum_en_row_i[(PE_SIZE-i)-1] = 1'b1;
                psum_row_i = {(PE_SIZE){test_num}};
            end
            
            for (i=0; i < PE_SIZE*4; i=i+1) begin
                @(posedge clk);
                #(`DELTA)
                psum_en_row_i = {(PE_SIZE){1'b1}};
                psum_row_i = {(PE_SIZE){test_num}};
            end
            
            for (i=0; i < PE_SIZE; i=i+1) begin
                @(posedge clk);
                #(`DELTA)
                psum_en_row_i[(PE_SIZE-i)-1] = 1'b0;
                psum_row_i = {(PE_SIZE){test_num}};
            end
            
            
            // ifmap preload delay
            
            test_num = 0;
            
            repeat (5) begin
                @(posedge clk);
                #(`DELTA)
                psum_en_row_i = {(PE_SIZE){1'b0}};
                psum_row_i = {(PE_SIZE){test_num}};
            end
            
        end
        
        
        // 4. Ofmap check
        
        test_num = 'h0100_0000;
        
        for (i=0; i < PE_SIZE; i=i+1) begin
                @(posedge clk);
                #(`DELTA)
                psum_en_row_i[(PE_SIZE-i)-1] = 1'b1;
                psum_row_i = {(PE_SIZE){test_num}};
            end
            
        for (i=0; i < PE_SIZE*4; i=i+1) begin
            @(posedge clk);
            #(`DELTA)
            psum_en_row_i = {(PE_SIZE){1'b1}};
            psum_row_i = {(PE_SIZE){test_num}};
        end
            
        for (i=0; i < PE_SIZE-1; i=i+1) begin
            @(posedge clk);
            #(`DELTA)
            psum_en_row_i[(PE_SIZE-i)-1] = 1'b0;
            psum_row_i = {(PE_SIZE){test_num}};
        end
        

        // 5. end
        
        test_num = 0;
        repeat (5) begin
            @(posedge clk);
            #(`DELTA)
            psum_en_row_i = {(PE_SIZE){1'b0}};
            psum_row_i = {(PE_SIZE){test_num}};
        end

    end


endmodule
