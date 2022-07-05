module ACC #(
    // parameter
    parameter PE_SIZE       = 16,
    parameter DATA_WIDTH    = 32,
    parameter FIFO_DEPTH    = 16
    )
    (
    // special input
    input                   clk,
    input                   rst_n,
    
    // R/W enable signal
    input   [PE_SIZE-1:0]   wren_i,
    input   [PE_SIZE-1:0]   rden_i,
    
    // inout data
    input   [DATA_WIDTH*PE_SIZE-1:0]    psum_row_i,
    output  [DATA_WIDTH*PE_SIZE-1:0]    psum_row_o
    
    );
    
    // wire declartion
    wire    [DATA_WIDTH-1:0]    psum_w      [0:PE_SIZE-1];
    wire    [DATA_WIDTH-1:0]    fifo_in_w   [0:PE_SIZE-1];  // wdata
    wire    [DATA_WIDTH-1:0]    fifo_out_w  [0:PE_SIZE-1];  // rdate
    wire    [DATA_WIDTH-1:0]    feedback_w  [0:PE_SIZE-1];  // sel zero/fifo_out

    
    genvar j;
    generate
        for (j=0; j < PE_SIZE; j=j+1) begin : GEN_ACC_OP
            assign psum_w[j] = psum_row_i[DATA_WIDTH*(PE_SIZE-j)-1 : DATA_WIDTH*(PE_SIZE-j-1)];
            assign feedback_w[j] = sel[j] ? fifo_out_w[j] : {(DATA_WIDTH){1'b0}};
            assign fifo_in_w[j] = feedback_w[j] + psum_w[j];
        end
    endgenerate
    
    // FIFO inst
    genvar i;
    generate
        for (i=0; i < PE_SIZE; i=i+1) begin : GEN_FIFO
            FIFO #(
                // Parameter
                .DATA_WIDTH(DATA_WIDTH)         // data bit width
                .FIFO_DEPTH(FIFO_DEPTH)         // fifo entry num
            ) FIFO_INST (   
                // special signal
                .clk        (clk),              // clock signal
                .rst_n      (rst_n),            // negedge pointer reset signal(don't need to reset data in fifo)
                // R/W input signal
                .wren_i     (wren_i[i]),        // write enable signal
                .rden_i     (rden_i[i]),        // read denable signal
                // F/E output signal
                .full_o     (),                 // check fifo is full, if full the signal is high
                .empty_o    (),                 // chcek fifo is empty, if empty the signal is high
                // In/Out data signal
                .wdata_i    (fifo_in_w[i]),     // write data
                .rdata_o    (fifo_out_w[i])     // read data
            );
        end
    endgenerate
    
    genvar k;
    generate
        for (k=0; k < PE_SIZE; k=k+1) begin : GEN_OUT
            assign psum_row_o[DATA_WIDTH*(PE_SIZE-k)-1 : DATA_WIDTH*(PE_SIZE-k-1)] = feedback_w[k];
        end
    endgenerate
    
endmodule