module Systolic_Array #(
    parameter SA_WIDTH      = 4,
    parameter DATA_WIDTH    = 8,
    parameter PSUM_WIDTH    = 32
    )
    (
    
    // special input
    input clk,
    input rst_n,

    // input weight
    input   [DATA_WIDTH-1:0]    weight_col0_i        
    input   [DATA_WIDTH-1:0]    weight_col1_i        
    input   [DATA_WIDTH-1:0]    weight_col2_i        
    input   [DATA_WIDTH-1:0]    weight_col3_i        
    
    // input ifmap
    input   [DATA_WIDTH-1:0]    ifmap_row0_i
    input   [DATA_WIDTH-1:0]    ifmap_row1_i
    input   [DATA_WIDTH-1:0]    ifmap_row2_i
    input   [DATA_WIDTH-1:0]    ifmap_row3_i
    
    // enable signal
    input   [SA_WIDTH-1:0]      weight_en_i,
    input   [SA_WIDTH-1:0]      ifmap_en_i,
    input   [SA_WIDTH-1:0]      psum_en_i,
    
    // output partial sum 
    output  [PSUM_WIDTH-1:0]    psum_col0_o,
    output  [PSUM_WIDTH-1:0]    psum_col1_o,
    output  [PSUM_WIDTH-1:0]    psum_col2_o,
    output  [PSUM_WIDTH-1:0]    psum_col3_o,
    
    output  [SA_WIDTH-1:0]      psum_en_o       // this signal is used in accumulation
    );
    
    // wire & reg
    wire    [DATA_WIDTH-1:0]    weight_col_w    [0:SA_WIDTH-1][0:SA_WIDTH-1];
    wire    [DATA_WIDTH-1:0]    ifmap_row_w     [0:SA_WIDTH-1][0:SA_WIDTH-1];
    wire    [PSUM_WIDTH-1:0]    psum_col_w      [0:SA_WIDTH-1][0:SA_WIDTH-1];
    
    wire    [SA_WIDTH-1:0]      weight_en_w     [0:SA_WIDTH-1];
    wire    [SA_WIDTH-1:0]      ifmap_en_w      [0:SA_WIDTH-1];
    wire    [SA_WIDTH-1:0]      psum_en_w       [0:SA_WIDTH-1];
    
    // assignment first col & row IF of filter & ifmap 
    assign weight_col_w[0][0] =  weight_col0_i; 
    assign weight_col_w[0][1] =  weight_col1_i;
    assign weight_col_w[0][2] =  weight_col2_i;
    assign weight_col_w[0][3] =  weight_col3_i;
    
    assign ifmap_row_w[0][0] =  ifmap_row0_i;
    assign ifmap_row_w[1][0] =  ifmap_row1_i;
    assign ifmap_row_w[2][0] =  ifmap_row2_i;
    assign ifmap_row_w[3][0] =  ifmap_row3_i;
    
    assign psum_col_w[0][0] =  {(PSUM_WIDTH){1'b0}}; 
    assign psum_col_w[0][1] =  {(PSUM_WIDTH){1'b0}};
    assign psum_col_w[0][2] =  {(PSUM_WIDTH){1'b0}};
    assign psum_col_w[0][3] =  {(PSUM_WIDTH){1'b0}};
    
    
    // assignment first col & row enable siganl 
    assign weight_en_w[0][0] = weight_en_i[3];
    assign weight_en_w[0][1] = weight_en_i[2];
    assign weight_en_w[0][2] = weight_en_i[1];
    assign weight_en_w[0][3] = weight_en_i[0];
    
    assign ifmap_en_w[0][0] = ifmap_en_i[3];
    assign ifmap_en_w[1][0] = ifmap_en_i[2];
    assign ifmap_en_w[2][0] = ifmap_en_i[1];
    assign ifmap_en_w[3][0] = ifmap_en_i[0];
    
    assign psum_en_w[0][0] = psum_en_i[3];
    assign psum_en_w[0][1] = psum_en_i[2];
    assign psum_en_w[0][2] = psum_en_i[1];
    assign psum_en_w[0][3] = psum_en_i[0];
    
    
    
    PE_V2 #(
        .DATA_WIDTH(DATA_WIDTH)
        .PSUM_WIDTH(PSUM_WIDTH)
    ) PE11 (   
        .clk(clk), .rst_n(rst_n), 
        .weight_i(weight_col_w[0][0]), .ifmap_i(ifmap_row_w[0][0]), .psum_i(psum_col_w[0][0]), 
        .weight_en_i(), .ifmap_en_i(), .psum_en_i(), 
        .weight_o(), .ifmap_o(), .psum_o(), 
        .weight_en_o(), .ifmap_en_o(), .psum_en_o()
    );
   
    
    // assignment last row of psum values
    assign psum_col0_o = psum_col_w[3][0];
    assign psum_col0_1 = psum_col_w[3][1];
    assign psum_col0_2 = psum_col_w[3][2];
    assign psum_col0_3 = psum_col_w[3][3];
    
    assign psum_en_o = {psum_en_w[3][0:3]};
    
endmodule