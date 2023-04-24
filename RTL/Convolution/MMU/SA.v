module SA #(
    // parameter
    parameter PE_SIZE       = 4,
    parameter DATA_WIDTH    = 8,
    parameter PSUM_WIDTH    = 32
    )
    (
    // Special signal
    input clk,
    input rst_n,

    // input primitivies
    input   [DATA_WIDTH*PE_SIZE-1:0]    ifmap_row_i,
    input   [DATA_WIDTH*PE_SIZE-1:0]    weight_col_i,
    input   [PSUM_WIDTH*PE_SIZE-1:0]    psum_row_i,
    
    // input enable signal
    input                               ifmap_preload_i,
    input   [PE_SIZE-1:0]               weight_en_col_i,
    input   [PE_SIZE-1:0]               psum_en_row_i,
    
    // output primitivies 
    output  [DATA_WIDTH*PE_SIZE-1:0]    ifmap_row_o,
    output  [DATA_WIDTH*PE_SIZE-1:0]    weight_col_o,
    output  [PSUM_WIDTH*PE_SIZE-1:0]    psum_row_o,
    
    // output enable signal   
    output  [PE_SIZE-1:0]               weight_en_col_o,      
    output  [PE_SIZE-1:0]               psum_en_row_o       
    );
    
    
    // port delaration

    // primitives wire port
    wire    [DATA_WIDTH*PE_SIZE-1:0]    ifmap_row_w         [0:PE_SIZE];
    wire    [DATA_WIDTH*PE_SIZE-1:0]    weight_col_w        [0:PE_SIZE];
    wire    [PSUM_WIDTH*PE_SIZE-1:0]    psum_row_w          [0:PE_SIZE];
    
    // enable signal wire port
    wire                                ifmap_en_w;
    wire    [PE_SIZE-1:0]               weight_en_col_w     [0:PE_SIZE];
    wire    [PE_SIZE-1:0]               psum_en_row_w       [0:PE_SIZE];
    
    
    // Input logic
    // assignment first side input 
    
    // primitives input assign
    assign ifmap_row_w[0]       = ifmap_row_i;
    assign weight_col_w[0]      = weight_col_i;
    assign psum_row_w[0]        = psum_row_i;
    
    // enable siganl input assign
    assign weight_en_col_w[0]   = weight_en_col_i;
    assign psum_en_row_w[0]     = psum_en_row_i;


    // Preload logic
    wire preload_done_w;
    // Preload count cycle
    Counter #(
        .COUNT_NUM ( PE_SIZE-1 )
    )u_Counter(
        .clk     ( clk              ),
        .rst_n   ( rst_n            ),
        .start_i ( ifmap_preload_i  ),
        .done_o  ( preload_done_w   )
    );

    // Registering preload signal
    reg preload_r;
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            preload_r <= 1'b0;
        end else if (ifmap_preload_i) begin
            preload_r <= 1'b1;
        end else if (preload_done_w) begin
            preload_r <= 1'b0;
        end
    end 

    // assignment of ifmap_enable siganl
    // (preload start signal) OR (registerd preload signal)
    assign ifmap_en_w = (!preload_done_w) & (ifmap_preload_i | preload_r);


    // Systolic Array MAC body logic
    // PE inst(j : col_num, k : row_num)
    // ex. psum, j=1, k=1 this signal is 
    genvar j, k;
    generate
        for (j=0; j < PE_SIZE; j=j+1) begin : GEN_COL_PE
            for (k=0; k < PE_SIZE; k=k+1) begin : GEN_ROW_PE
                PE #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .PSUM_WIDTH(PSUM_WIDTH)
                ) PE_INST (   
                    // special signal
                    .clk            ( clk   ), 
                    .rst_n          ( rst_n ), 
                    // primitives(input) 2D array, var[vector_idx][bit_idx]
                    .ifmap_i        ( ifmap_row_w    [k][DATA_WIDTH*(PE_SIZE-j)-1 -: DATA_WIDTH] ), 
                    .weight_i       ( weight_col_w   [j][DATA_WIDTH*(PE_SIZE-k)-1 -: DATA_WIDTH] ), 
                    .psum_i         ( psum_row_w     [k][PSUM_WIDTH*(PE_SIZE-j)-1 -: PSUM_WIDTH] ), 
                    // enable signal(input) 2D array, var[vector_idx][bit_idx], stationary(ifmap) share enable signal with all PE in SA
                    .ifmap_en_i     ( ifmap_en_w ), 
                    .weight_en_i    ( weight_en_col_w[j][(PE_SIZE-k)-1] ), 
                    .psum_en_i      ( psum_en_row_w  [k][(PE_SIZE-j)-1] ), 
                    // primitives(output) 2D array, var[vector_idx][bit_idx]
                    .ifmap_o        ( ifmap_row_w    [k+1][DATA_WIDTH*(PE_SIZE-j)-1 -: DATA_WIDTH] ), 
                    .weight_o       ( weight_col_w   [j+1][DATA_WIDTH*(PE_SIZE-k)-1 -: DATA_WIDTH] ), 
                    .psum_o         ( psum_row_w     [k+1][PSUM_WIDTH*(PE_SIZE-j)-1 -: PSUM_WIDTH] ), 
                    // enable signal(output) 2D array, var[vector_idx][bit_idx]
                    .weight_en_o    ( weight_en_col_w[j+1][(PE_SIZE-k)-1] ), 
                    .psum_en_o      ( psum_en_row_w  [k+1][(PE_SIZE-j)-1] )
                );
            end
        end
    endgenerate



    // Output logic
    // assignment last side output
    
    // primitives output assign
    assign ifmap_row_o  = ifmap_row_w   [PE_SIZE];
    assign weight_col_o = weight_col_w  [PE_SIZE];
    assign psum_row_o   = psum_row_w    [PE_SIZE];
    
    // enable signal output assign 
    assign weight_en_col_o  = weight_en_col_w   [PE_SIZE];
    assign psum_en_row_o    = psum_en_row_w     [PE_SIZE];




endmodule