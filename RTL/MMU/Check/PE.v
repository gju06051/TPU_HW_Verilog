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
    input   [DATA_WIDTH-1:0]        ifmap_i,
    input   [DATA_WIDTH-1:0]        weight_i,
    input   [PSUM_WIDTH-1:0]        psum_i,
    
    // Register enable signal(output)
    input                           ifmap_en_i,
    input                           weight_en_i,
    input                           psum_en_i,
    
    // Primitives(input)
    output  [DATA_WIDTH-1:0]        ifmap_o,
    output  [DATA_WIDTH-1:0]        weight_o,
    output  [PSUM_WIDTH-1:0]        psum_o,

    // Register enable signal(output)
    output                          weight_en_o,
    output                          psum_en_o
    );
    
    
    // Register declaration 
    
    // Primitives 
    reg     [DATA_WIDTH-1:0]        ifmap_r;
    reg     [DATA_WIDTH-1:0]        weight_r;
    reg     [PSUM_WIDTH-1:0]        psum_r;
    
    // Multiply out buf
    reg     [(DATA_WIDTH*2)-1:0]    product_r;      // buffering multiply out(prevent timing issue)  
    
    // Enable signal
    reg                             weight_en_r;
    reg                             psum_en_r;
    

    // Forwarding control signal(sync with primitives)
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            weight_en_r <= 1'b0;
            psum_en_r   <= 1'b0;
        end else begin
            weight_en_r <= weight_en_i;
            psum_en_r   <= psum_en_i;
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
    
    // Registering weight
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            weight_r <= {(DATA_WIDTH){1'b0}};
        end 
        else if (weight_en_i) begin
            weight_r <= weight_i;
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
        end else if (weight_en_i) begin
            product_r <= ifmap_r * weight_i;
        end
    end
    
    
    // Accumulation(using dedicatied logic)
    assign psum_o = product_r + psum_r;

    // Assignment output(primitives forwarding)
    assign ifmap_o  = ifmap_r;
    assign weight_o = weight_r;
    
    // Assignment output(control forwarding)
    assign weight_en_o  = weight_en_r;
    assign psum_en_o    = psum_en_r;

endmodule