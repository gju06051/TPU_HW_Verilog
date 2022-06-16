module FIFO_PARAMETER #(
    //// Parameter
    parameter DATA_WIDTH = 32,  // data bit width
    parameter FIFO_DEPTH = 8,   // fifo entry num
)
(   //// Port
    input clk,      // clock signal
    input rstn,     // negedge reset signal
    input wren,     // write enable signal
    input rden,     // read denable signal
    
    output full,    // check fifo is full, if full the signal is high
    output empty,   // chcek fifo is empty, if empty the signal is high
    
    input   [DATA_WIDTH-1:0] wdata,   // write data
    output  [DATA_WIDTH-1:0] rdata    // read data
    
);
    //// Localparam
    localparam FIFO_DEPTH_LG2 = $clog2(FIFO_DEPTH);     //! making param log2 of entry size
                                                        //! ex) depth is 8 -> log(8) = 3

    //// Pointers
    reg [FIFO_DEPTH_LG2:0] wrptr, wrptr_n;  //! one extra bit for full checking
    reg [FIFO_DEPTH_LG2:0] rdptr, rdptr_n;  //! one extra bit for full checking

    //// sequential logic
    always @(posedge clk, negedge rstn) begin
        if (!rstn) begin
            wrptr   <= {(FIFO_DEPTH_LG2+1){1'b0}};      // reset with zero
            rdptr   <= {(FIFO_DEPTH_LG2+1){1'b0}};      // reset with zero
        end else begin
            wrptr   <= wrptr_n;                         // next state porting
            rdptr   <= rdptr_n;                         // next state porting
        end
    end
    
    //// combination logic for pointer modify
    always @(*) begin
        //* write pointer modfiy
        if (wren) begin
            wrptr_n = wrptr + 'd1;                      // update wrptr add 1 after write activation
        end else begin
            wrptr_n = wrptr;                            // maintain
        end
        //* read pointer modify
        if (rden) begin
            rdptr_n = rdptr + 'd1;                      // update rdptr add1 after read activation
        end else begin
            rdptr_n = rdptr;                            // maintain
        end
    end
    
    //// FIFO Storage
    reg [DATA_WIDTH-1:0] mem [FIFO_DEPTH-1:0];          // consist with 32bit 8 entry
                                                        // It will be modify when using real architecture
    //// Write activation
    always @(posedge clk) begin
        if (wren) begin
            mem[wrptr[FIFO_DEPTH_LG2-1:0]]  <= wdata;   // write activation access memory by write pointer
        end
    end
    
    //// ouput assignment
    //// Read activation
    assign rdata    = mem[rdptr[FIFO_DEPTH_LG2-1:0]];   // read actiavation access memory by read pointer
    
    //// empty check
    assign empty    = ( wrptr == rdptr );
    assign full     = ( wrptr[FIFO_DEPTH_LG2-1:0] == rdptr[FIFO_DEPTH_LG2-1:0] )    //! full checking checking under addr is equal
                        & ( wrptr[FIFO_DEPTH_LG2] != rdptr[FIFO_DEPTH_LG2] );       //! checking msb for full(msb is equal -> empty, otherwise full)
    
endmodule
