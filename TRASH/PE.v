module PE #(
    // Parameter
    parameter DATA_WIDTH = 8,
    parameter PSUM_WIDTH = 32
    )
    (
    // Special Input
    input   clk,
    input   rst_n,
    
    // Primitives(input)
    input   [DATA_WIDTH-1:0]    weight_i,
    input   [DATA_WIDTH-1:0]    ifmap_i,
    input   [PSUM_WIDTH-1:0]    psum_i,
    
    // Register enable signal(output)
    input                       weight_en_i,
    input                       ifmap_en_i,
    input                       psum_en_i,
    
    // Primitives(input)
    output  [DATA_WIDTH-1:0]    weight_o,
    output  [DATA_WIDTH-1:0]    ifmap_o,
    output  [PSUM_WIDTH-1:0]    psum_o,

    // Register enable signal(output)
    output                      weight_en_o,
    output                      ifmap_en_o,
    output                      psum_en_o
    );
    
    // temp signal 
    wire    [DATA_WIDTH-1:0]        weight_w;
    wire    [DATA_WIDTH-1:0]        ifmap_w;
    wire    [PSUM_WIDTH-1:0]        psum_w;
    wire    [(DATA_WIDTH*2)-1:0]    product_w;  // product of weight * ifmap
    wire    [(DATA_WIDTH*2)-1:0]    product_temp;  // product of weight * ifmap
    
    wire                            weight_en_w;
    wire                            ifmap_en_w;
    wire                            psum_en_w;
    


    // forwarding control signal(sync with primitives)
    DFF  #( .DATA_WIDTH(1) ) Weight_en_buf  ( .clk(clk), .rst_n(rst_n), .en('b1), .d(weight_en_i), .q(weight_en_w) );
    DFF  #( .DATA_WIDTH(1) ) Ifmap_en_buf   ( .clk(clk), .rst_n(rst_n), .en('b1), .d(ifmap_en_i),  .q(ifmap_en_w)  );
    DFF  #( .DATA_WIDTH(1) ) Psum_en_buf    ( .clk(clk), .rst_n(rst_n), .en('b1), .d(psum_en_i),   .q(psum_en_w)   );
    
    // forwarding primitives
    DFF  #( .DATA_WIDTH(DATA_WIDTH) ) Weight_Reg    ( .clk(clk), .rst_n(rst_n), .en(weight_en_i),   .d(weight_i),   .q(weight_w) );
    DFF  #( .DATA_WIDTH(DATA_WIDTH) ) Ifmap_Reg     ( .clk(clk), .rst_n(rst_n), .en(ifmap_en_i),    .d(ifmap_i),    .q(ifmap_w)  );
    DFF  #( .DATA_WIDTH(PSUM_WIDTH) ) Psum_Reg      ( .clk(clk), .rst_n(rst_n), .en(psum_en_i),     .d(psum_i),     .q(psum_w)   );


    // multiplication(using dedicatied logic)
    assign product_w = ifmap_i * weight_w;

    DFF  #( .DATA_WIDTH(DATA_WIDTH*2) ) Product_Reg ( .clk(clk), .rst_n(rst_n), .en('b1), .d(product_w), .q(product_temp) );    

    // accumulation(using dedicatied logic)
    assign psum_o = product_temp + psum_w;

    // forwarding(primitives)
    assign weight_o = weight_w;
    assign ifmap_o  = ifmap_w;
    
    // forwarding(control signal)
    assign weight_en_o  = weight_en_w;
    assign ifmap_en_o   = ifmap_en_w;
    assign psum_en_o    = psum_en_w;

endmodule