`timescale 1ps/1ps
`define DELTA 1
`define CLOCK_PERIOD 10

module GEMM_TB #(
    // Primitive DATA_WIDTH
    parameter DATA_WIDTH    = 8,        // Weight, Ifmap
    parameter PSUM_WIDTH    = 32,       // Partial Sum
    // HW Const(=Ifmap width)
    parameter PE_SIZE       = 14,       // Systolic Array PE NUM 
                                        // ex. if PE_SIZE = 14, use 196(=14x14) PE  
    // Model Const
    parameter IN_CH         = 32,       // Input Channel
    parameter OUT_CH        = 64,       // Output Channel
    parameter KERNAL_SIZE   = 3
    ) 
    (
    // No Port
    // This is TB
    );



    // Special Input
    reg     clk;
    reg     rst_n;
    
    // Control Input
    reg     gemm_start_i;
    
    // SA_DATA_MOVER BRAM I/O PORT
    wire    [MEM0_DATA_WIDTH-1:0]   mem0_d0;
    wire    [MEM0_ADDR_WIDTH-1:0]   mem0_addr;
    wire                            mem0_ce0;
    wire                            mem0_we0;


    // Module INST
    GEMM #(
        .DATA_WIDTH   ( DATA_WIDTH      ),
        .PSUM_WIDTH   ( PSUM_WIDTH      ),
        .PE_SIZE      ( PE_SIZE         ),
        .IN_CH        ( IN_CH           ),
        .OUT_CH       ( OUT_CH          ),
        .KERNAL_SIZE  ( KERNAL_SIZE     )
    ) u_GEMM (
        .clk          ( clk             ),
        .rst_n        ( rst_n           ),
        .gemm_start_i ( gemm_start_i    ),
        .mem0_d0      ( mem0_d0         ),
        .mem0_addr    ( mem0_addr       ),
        .mem0_ce0     ( mem0_ce0        ),
        .mem0_we0     ( mem0_we0        )
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
        cycle = 0;
        rst_n = 1'b1;
        psum_en_i = {(PE_SIZE){1'b0}};
        rden_i = {(PE_SIZE){1'b0}};
        psum_row_i = {(DATA_WIDTH*PE_SIZE){1'b0}};
    end



endmodule
