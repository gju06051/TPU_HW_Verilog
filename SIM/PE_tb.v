`timescale 1ps/1ps
`define DELTA 3
`define CLOCK_PERIOD 10

module PE_TB #(
    parameter DATA_WIDTH = 8,
    parameter PSUM_WIDTH = 32
    )
    (
    // no inout
    // this is testbench
    );
    
    // Special Input
    reg   clk;
    reg   rst_n;
    
    // Primitives(input)
    reg   [DATA_WIDTH-1:0]    ifmap_i;
    reg   [DATA_WIDTH-1:0]    weight_i;
    reg   [PSUM_WIDTH-1:0]    psum_i;
    
    // Register enable signal(output)
    reg                       ifmap_en_i;
    reg                       weight_en_i;
    reg                       psum_en_i;
    
    // Primitives(input)
    wire  [DATA_WIDTH-1:0]    ifmap_o;
    wire  [DATA_WIDTH-1:0]    weight_o;
    wire  [PSUM_WIDTH-1:0]    psum_o;

    // Register enable signal(output)
    wire                      weight_en_o;
    wire                      psum_en_o; 


    // DUT INST
    PE #(
        // Parameter
        .DATA_WIDTH(DATA_WIDTH), 
        .PSUM_WIDTH(PSUM_WIDTH) 
    ) PE_DUT (
        // Special Input
        .clk(clk),
        .rst_n(rst_n),
        
        // Primitives(input)
        .ifmap_i(ifmap_i),
        .weight_i(weight_i),
        .psum_i(psum_i),
        
        // Register enable signal(output)
        .ifmap_en_i(ifmap_en_i),
        .weight_en_i(weight_en_i),
        .psum_en_i(psum_en_i),
        
        // Primitives(input)
        .ifmap_o(ifmap_o),
        .weight_o(weight_o),
        .psum_o(psum_o),
    
        // Register enable signal(output)
        .weight_en_o(weight_en_o),
        .psum_en_o(psum_en_o)  
    );
    
    // clock signal
    initial begin
        clk = 1'b0;
        forever begin
            #(`CLOCK_PERIOD/2) clk = ~clk;
        end
    end

    
    // initialization
    initial begin
        weight_i = {(DATA_WIDTH){1'b0}};
        ifmap_i = {(DATA_WIDTH){1'b0}};
        psum_i = {(PSUM_WIDTH){1'b0}};
        
        weight_en_i = 1'b0;
        ifmap_en_i = 1'b0;
        psum_en_i = 1'b0;
    end
    
    // test stimulus
    initial begin
        // reset
        rst_n = 1'b1;
        #(`DELTA)
        rst_n = 1'b0;
        @(posedge clk);
        #(`DELTA)
        rst_n = 1'b1;
        
        // weight preload
        @(posedge clk);
        #(`DELTA)
        ifmap_i = 'd10;
        ifmap_en_i = 'b1;
        
        @(posedge clk);
        #(`DELTA)
        ifmap_en_i = 'b0;

        repeat(3) begin
            @(posedge clk);
            #(`DELTA)
            ifmap_i = 'd13;
        end
        
        @(posedge clk);
        #(`DELTA)
        psum_en_i = 'b1;
        psum_i = 'd1;
        weight_en_i = 'b1;
        weight_i = 'd11;

        @(posedge clk);
        #(`DELTA)
        psum_en_i = 'b1;
        psum_i = 'd2;
        weight_en_i = 'b1;
        weight_i ='d22;
        
        @(posedge clk);
        #(`DELTA)
        
        psum_en_i = 'b0;
        psum_i = 'd3;
        weight_en_i = 'b0;
        weight_i = 'd33;
        
        @(posedge clk);
        #(`DELTA)
        repeat (3) begin
            @(posedge clk);
            weight_en_i = 'b0;
            weight_i = 'd0;
            psum_en_i = 'b0;
            psum_i = 'd0;
        end
        $display("finished testbench");
        
        
    end

endmodule