module FIFO_v2 #(
    // Parameter
    parameter DATA_WIDTH = 32,  // data bit width
    parameter FIFO_DEPTH = 70   // fifo entry num
    )
    (   
    // Port
    input clk,          // clock signal
    input rst_n,        // negedge pointer reset signal(don't need to reset data in fifo)
    input wren_i,       // write enable signal
    input rden_i,       // read denable signal
    
    output full_o,      // check fifo is full, if full the signal is high
    output empty_o,     // chcek fifo is empty, if empty the signal is high
    
    input   [DATA_WIDTH-1:0] wdata_i,   // write data
    output  [DATA_WIDTH-1:0] rdata_o    // read data
    );
    
    // Localparam
    // making param log2 of entry size
    // ex) depth is 8 -> log(8) = 3
    localparam FIFO_DEPTH_LG2 = $clog2(FIFO_DEPTH);     
                                                        

    // Pointers
    // one extra bit for full checking
    reg [FIFO_DEPTH_LG2:0] wrptr, wrptr_n;  
    reg [FIFO_DEPTH_LG2:0] rdptr, rdptr_n;  

    // Sequential logic
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            wrptr   <= {(FIFO_DEPTH_LG2+1){1'b0}};      // reset with zero
            rdptr   <= {(FIFO_DEPTH_LG2+1){1'b0}};      // reset with zero
        end else begin
            wrptr   <= wrptr_n;                         // next state porting
            rdptr   <= rdptr_n;                         // next state porting
        end
    end
    
    // Combination logic for pointer modify
    // (add overflow logic)
    always @(*) begin
        // write pointer modfiy
        if (wren_i) begin
            if (wrptr[FIFO_DEPTH_LG2-1:0]==FIFO_DEPTH-1) begin              // overflow case
                wrptr_n[FIFO_DEPTH_LG2] = wrptr[FIFO_DEPTH_LG2] + 'd1;      // update msb
                wrptr_n[FIFO_DEPTH_LG2-1:0] = {(FIFO_DEPTH_LG2){1'b0}};     // reset fifo addr
            end else begin
                wrptr_n = wrptr + 'd1;      // update wrptr add 1 after write activation
            end
        end else begin
            wrptr_n = wrptr;    
        end
        
        // read pointer modify
        if (rden_i) begin
            if (rdptr[FIFO_DEPTH_LG2-1:0]==FIFO_DEPTH-1) begin              // overflow case
                rdptr_n[FIFO_DEPTH_LG2] = rdptr[FIFO_DEPTH_LG2] + 'd1;      // update msb
                rdptr_n[FIFO_DEPTH_LG2-1:0] = {(FIFO_DEPTH_LG2){1'b0}};     // reset fifo addr
            end else begin
                rdptr_n = rdptr + 'd1;      // update rdptr add1 after read activation
            end
        end else begin
            rdptr_n = rdptr;
        end
    end
    
    // FIFO Storage
    // consist with 32bit 8 entry
    // it will be modify when using real architecture(ex. ture_dp_bram_inst)
    reg [DATA_WIDTH-1:0] mem [FIFO_DEPTH-1:0];          
                                                            
    // Write Activation
    // write activation access memory by write pointer
    // wrptr not use full index(not use msb), overflow -> target first fifo
    always @(posedge clk) begin
        if (wren_i) begin
            mem[wrptr[FIFO_DEPTH_LG2-1:0]] <= wdata_i;      
        end                                                 
    end
    
    // Read activation ouput assignment
    // read actiavation access memory by read pointer
    assign rdata_o  = mem[rdptr[FIFO_DEPTH_LG2-1:0]];       
    
    // Empty & Full check
    // full checking checking under addr is equal
    // checking msb for full(msb is equal -> empty, otherwise full)
    assign empty_o  = (wrptr == rdptr);
    assign full_o   = (wrptr[FIFO_DEPTH_LG2-1:0] == rdptr[FIFO_DEPTH_LG2-1:0])      
                        & (wrptr[FIFO_DEPTH_LG2] != rdptr[FIFO_DEPTH_LG2]);         

endmodule
