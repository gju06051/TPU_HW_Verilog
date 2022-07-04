module PE_subcol #(
    parameter SA_HEIGHT     = 4,
    parameter DATA_WIDTH    = 8,
    parameter PSUM_WIDTH    = 32
    )
    (
    
    // special input
    input clk,
    input rst_n,

    // input weight
    input   [DATA_WIDTH-1:0]    weight_col0_i,        
    
    // input ifmap
    input   [DATA_WIDTH-1:0]    ifmap_row0_i,
    input   [DATA_WIDTH-1:0]    ifmap_row1_i,
    input   [DATA_WIDTH-1:0]    ifmap_row2_i,
    input   [DATA_WIDTH-1:0]    ifmap_row3_i,
    
    // input psum
    input   [DATA_WIDTH-1:0]    psum_col0_i,        
    
    
    // input enable signal(weight, psum forwarding 1col)
    input                       weight_en_i,
    input   [SA_WIDTH-1:0]      ifmap_en_i,
    input                       psum_en_i,
    
    // output weight
    output  [DATA_WIDTH-1:0]    weight_col0_i
    
    // output ifmap 
    output  [DATA_WIDTH-1:0]    ifmap_row0_o,
    output  [DATA_WIDTH-1:0]    ifmap_row1_o,
    output  [DATA_WIDTH-1:0]    ifmap_row2_o,
    output  [DATA_WIDTH-1:0]    ifmap_row3_o,
    
    // output psum 
    output  [PSUM_WIDTH-1:0]    psum_col0_o,
    
    output                      weight_en_o,
    output  [SA_WIDTH-1:0]      ifmap_en_o,
    output                      psum_en_o
    );
    
    // wire & reg
    wire    [DATA_WIDTH-1:0]    weight_col_w    [0:SA_WIDTH-1];
    wire    [PSUM_WIDTH-1:0]    psum_col_w      [0:SA_WIDTH-1];
    
    wire                        weight_en_w     [0:SA_WIDTH-1];
    wire                        psum_en_w       [0:SA_WIDTH-1];
    
    // assignment input weight
    assign weight_col_w[0] =  weight_col0_i; 

    // assignemnt input psum 
    assign psum_col_w[0] =  psum_col0_i; 
    
    // assignment weight enable signal
    assign weight_en_w[0] = weight_en_i;
    
    // assignment psum enable signal
    assign psum_en_w[0] = psum_en_i;
    
    
    PE #(
        .DATA_WIDTH(DATA_WIDTH)
        .PSUM_WIDTH(PSUM_WIDTH)
    ) PE11 (   
        .clk(clk), .rst_n(rst_n), 
        .weight_i(weight_col_w[0]), .ifmap_i(ifmap_row0_i), .psum_i(psum_col_w[0]), 
        .weight_en_i(weight_en_w[0]), .ifmap_en_i(ifmap_en_w[0]), .psum_en_i(psum_en_w[0]), 
        .weight_o(weight_col_w[1]), .ifmap_o(ifmap_row0_o), .psum_o(psum_col_w[1]), 
        .weight_en_o(weight_en_w[1]), .ifmap_en_o(ifmap_en_w[1]), .psum_en_o(psum_en_w[1])
    );
    
    PE #(
        .DATA_WIDTH(DATA_WIDTH)
        .PSUM_WIDTH(PSUM_WIDTH)
    ) PE21 (   
        .clk(clk), .rst_n(rst_n), 
        .weight_i(weight_col_w[1]), .ifmap_i(ifmap_row1_i), .psum_i(psum_col_w[1]), 
        .weight_en_i(weight_en_w[1]), .ifmap_en_i(ifmap_en_w[1]), .psum_en_i(psum_en_w[1]), 
        .weight_o(weight_col_w[2]), .ifmap_o(ifmap_row1_o), .psum_o(psum_col_w[2]), 
        .weight_en_o(weight_en_w[2]), .ifmap_en_o(ifmap_en_w[2]), .psum_en_o(psum_en_w[2])
    );
    
    PE #(
        .DATA_WIDTH(DATA_WIDTH)
        .PSUM_WIDTH(PSUM_WIDTH)
    ) PE31 (   
        .clk(clk), .rst_n(rst_n), 
        .weight_i(weight_col_w[2]), .ifmap_i(ifmap_row2_i), .psum_i(psum_col_w[2]), 
        .weight_en_i(weight_en_w[2]), .ifmap_en_i(ifmap_en_w[2]), .psum_en_i(psum_en_w[2]), 
        .weight_o(weight_col_w[3]), .ifmap_o(ifmap_row2_o), .psum_o(psum_col_w[3]), 
        .weight_en_o(weight_en_w[3]), .ifmap_en_o(ifmap_en_w[3]), .psum_en_o(psum_en_w[3])
    );
    
    PE #(
        .DATA_WIDTH(DATA_WIDTH)
        .PSUM_WIDTH(PSUM_WIDTH)
    ) PE41 (   
        .clk(clk), .rst_n(rst_n), 
        .weight_i(weight_col_w[3]), .ifmap_i(ifmap_row3_i), .psum_i(psum_col_w[3]), 
        .weight_en_i(weight_en_w[3]), .ifmap_en_i(ifmap_en_w[3]), .psum_en_i(psum_en_w[3]), 
        .weight_o(weight_col_w[4]), .ifmap_o(ifmap_row0_o), .psum_o(psum_col_w[1]), 
        .weight_en_o(weight_en_w[4]), .ifmap_en_o(ifmap_en_w[1]), .psum_en_o(psum_en_w[1])
    );
    
    
    // assignment last row of psum values
    
    // assignment last row of psum enable value(for fifo accumulation)
    
    // assignment feature map out
    
    // assignemnt feature map enable out
    
endmodule