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
    reg     [DATA_WIDTH-1:0]        weight_r;
    reg     [DATA_WIDTH-1:0]        ifmap_r;
    reg     [PSUM_WIDTH-1:0]        psum_r;
    
    reg     [(DATA_WIDTH*2)-1:0]    product_r;  
    
    reg                             weight_en_r;
    reg                             ifmap_en_r;
    reg                             psum_en_r;
    

    // forwarding control signal(sync with primitives)
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            weight_en_r <= 1'b0;
            ifmap_en_r  <= 1'b0;
            psum_en_r   <= 1'b0;
        end else begin
            weight_en_r <= weight_en_i;
            ifmap_en_r  <= ifmap_en_i;
            psum_en_r   <= psum_en_i;
        end
    end

    // Registering weight
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            weight_r <= {(DATA_WIDTH){1'b0}};
        end 
        else if (weight_en_i) begin
            weight_r <= weight_i;
        end
    end
    
    // Registering ifmap
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            ifmap_r <= {(DATA_WIDTH){1'b0}};
        end
        else if (ifmap_en_i) begin
            ifmap_r <= ifmap_i;
        end
    end
    
    // Registering psum
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            psum_r <= {(PSUM_WIDTH){1'b0}};
        end
        else if (psum_en_i) begin
            psum_r <= psum_i;        
        end
    end
    
    // Registering multiplication product(using dedicated logic for multiplication)
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            product_r <= {(DATA_WIDTH*2){1'b0}};
        end else begin
            product_r <= ifmap_r * weight_i
        end
    end
    
    // accumulation(using dedicatied logic)
    assign psum_o = product_r + psum_r;

    // assignment output(primitives forwarding)
    assign weight_o = weight_r;
    assign ifmap_o  = ifmap_r;
    
    // assignment output(control forwarding)
    assign weight_en_o  = weight_en_r;
    assign ifmap_en_o   = ifmap_en_r;
    assign psum_en_o    = psum_en_r;

endmodule