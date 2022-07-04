module SA #(
    parameter PE_SIZE       = 4,
    parameter DATA_WIDTH    = 8,
    parameter PSUM_WIDTH    = 32
    )
    (
    // special input
    input clk,
    input rst_n,

    // input primitivies
    input   [(DATA_WIDTH)*(PE_SIZE)-1:0]    weight_row_i,
    input   [(DATA_WIDTH)*(PE_SIZE)-1:0]    ifmap_col_i,
    input   [(PSUM_WIDTH)*(PE_SIZE)-1:0]    psum_row_i,
    
    // input enable signal
    input   [PE_SIZE-1:0]                   weight_en_i,
    input   [PE_SIZE-1:0]                   ifmap_en_i,
    input   [PE_SIZE-1:0]                   psum_en_i,
    
    // output primitivies 
    output  [(DATA_WIDTH)*(PE_SIZE)-1:0]    weight_row_o,
    output  [(DATA_WIDTH)*(PE_SIZE)-1:0]    ifmap_col_o,
    output  [(PSUM_WIDTH)*(PE_SIZE)-1:0]    psum_row_o,
    
    // output enable signal
    output  [PE_SIZE-1:0]                   weight_en_o,      
    output  [PE_SIZE-1:0]                   ifmap_en_o,      
    output  [PE_SIZE-1:0]                   psum_en_o       
    );

    // primitives wire port
    wire    [DATA_WIDTH-1:0]    weight_row_w    [0:PE_SIZE][0:PE_SIZE];
    wire    [DATA_WIDTH-1:0]    ifmap_col_w     [0:PE_SIZE][0:PE_SIZE];
    wire    [PSUM_WIDTH-1:0]    psum_row_w      [0:PE_SIZE][0:PE_SIZE];
    
    // enable signal wire port
    wire    weight_en_w     [0:PE_SIZE][0:PE_SIZE];
    wire    ifmap_en_w      [0:PE_SIZE][0:PE_SIZE];
    wire    psum_en_w       [0:PE_SIZE][0:PE_SIZE];
    
    // assignment first col & row IF of filter & ifmap 
    genvar i;
    generate
        for (i=0; i < PE_SIZE; i=i+1) begin : GEN_INPUT_ASSIGN
            // primitives input assign
            assign weight_col_w[i][0] = weight_col_i[(DATA_WIDTH)*(PE_SIZE-i)-1:(DATA_WIDTH)*(PE_SIZE-i-1)];
            assign ifmap_row_w[0][i] = ifmap_row_i[(DATA_WIDTH)*(PE_SIZE-i)-1:(DATA_WIDTH)*(PE_SIZE-i-1)];
            assign psum_row_w[0][i] = psum_row_i[(PSUM_WIDTH)*(PE_SIZE-i)-1:(PSUM_WIDTH)*(PE_SIZE-i-1)];
            // enable siganl input assign
            assign weight_en_w[i][0] = weight_en_i[i];
            assign ifmap_en_w[0][i] = ifmap_en_i[i];
            assign psum_en_w[0][i] = psum_en_i[i];
        end
    endgenerate


    // PE inst(j : col_num, k : row_num)
    genvar j, k;
    generate
        for (j=0; j < PE_SIZE; j=j+1) begin : GEN_COL_PE
            for (k=0; k < PE_SIZE; k=k+1) begin : GEN_ROW_PE
                PE #(
                    .DATA_WIDTH(DATA_WIDTH)
                    .PSUM_WIDTH(PSUM_WIDTH)
                ) PE_INST (   
                    // special signal
                    .clk            (clk), 
                    .rst_n          (rst_n), 
                    // primitives(input)
                    .weight_i       (weight_col_w[k][j]), 
                    .ifmap_i        (ifmap_row_w[k][j]), 
                    .psum_i         (psum_row_w[k][j]), 
                    // enable signal(input)
                    .weight_en_i    (weight_en_w[k][j]), 
                    .ifmap_en_i     (ifmap_en_w[k][j]), 
                    .psum_en_i      (psum_en_w[k][j]), 
                    // primitives(output)
                    .weight_o       (weight_col_w[k+1][j+1]), 
                    .ifmap_o        (ifmap_row_w[k+1][j+1]), 
                    .psum_o         (psum_row_w[k+1][j+1]), 
                    // enable signal(output)
                    .weight_en_o    (weight_en_w[k+1][j+1]), 
                    .ifmap_en_o     (ifmap_en_w[k+1][j+1]), 
                    .psum_en_o      (psum_en_w[k+1][j+1])
                );
            end
        end
    endgenerate


    // assignment last row of psum values
    genvar l;
    generate
        for (l=0; l < PE_SIZE; l=l+1) begin
            // primitives output assign
            assign weight_col_o[(DATA_WIDTH)*(PE_SIZE-l)-1:(DATA_WIDTH)*(PE_SIZE-l-1)] = weight_col_w[l][PE_SIZE];
            assign ifmap_row_o[(DATA_WIDTH)*(PE_SIZE-l)-1:(DATA_WIDTH)*(PE_SIZE-l-1)] = ifmap_row_w[PE_SIZE][l];
            assign psum_row_o[(PSUM_WIDTH)*(PE_SIZE-l)-1:(PSUM_WIDTH)*(PE_SIZE-l-1)] = psum_row_w[PE_SIZE][l];
            // enable signal output assign 
            assign weight_en_o[l] = weight_en_w[l][PE_SIZE];
            assign ifmap_en_o[l] = ifmap_en_w[PE_SIZE][l];
            assign psum_en_o[l] = psum_en_w[PE_SIZE][l];
        end
    endgenerate



endmodule