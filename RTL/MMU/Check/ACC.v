module ACC #(
    // Parameter
    parameter PE_SIZE       = 4,
    parameter DATA_WIDTH    = 8,
    parameter PSUM_WIDTH    = 32,
    parameter FIFO_DEPTH    = 4
    )
    (
    // Special input
    input   clk,
    input   rst_n,
    
    // R/W enable signal
    input   [PE_SIZE-1:0]   psum_en_i,          // signal from SA, used for fifo write signal
    input   [PE_SIZE-1:0]   rden_i,             // signal from Top control, read data from fifo to GLB
    
    // I/O data
    input   [PSUM_WIDTH*PE_SIZE-1:0]    psum_row_i,
    output  [DATA_WIDTH*PE_SIZE-1:0]    psum_row_o
    
    );
    
    // Wire port for data, 2D array var[fifo_col_idx][bit_idx]
    wire    [PSUM_WIDTH-1:0]    psum_w      [0:PE_SIZE-1];
    wire    [PSUM_WIDTH-1:0]    fifo_in_w   [0:PE_SIZE-1];  // FIFO wdata
    wire    [PSUM_WIDTH-1:0]    fifo_out_w  [0:PE_SIZE-1];  // FIFO rdate
    wire    [PSUM_WIDTH-1:0]    feedback_w  [0:PE_SIZE-1];  // Zero or FIFO rdata
    
    // Wire port for control
    wire    [PE_SIZE-1:0]       rden_w;                     // FIFO read enable signal
    wire    [PE_SIZE-1:0]       acc_en_w;                   // Accumulation enable signal(use for reset fifo rdata)
    
    
    
    // Data flow of accumulation FIFO
    // (fifo_out + psum -> fifo_in)
    genvar j;
    generate
        for (j=0; j < PE_SIZE; j=j+1) begin : GEN_ACC_OP
            // flatten input data with each wire
            assign psum_w[j] = psum_row_i[PSUM_WIDTH*(PE_SIZE-j)-1 : PSUM_WIDTH*(PE_SIZE-j-1)];     
            
            // checking preload psum, not_full -> preload psum by giving feedback zero
            assign feedback_w[j] = acc_en_w[j] ? fifo_out_w[j] : {(PSUM_WIDTH){1'b0}};              
            
            // FIFO accumulation
            assign fifo_in_w[j] = feedback_w[j] + psum_w[j];
            
            // Read FIFO when accumulation or GLB read activation
            assign rden_w[j] = (psum_en_i[j] & acc_en_w[j]) | rden_i[j];
        end
    endgenerate
    
    
    // FIFO Inst(i : col num)
    genvar i;
    generate
        for (i=0; i < PE_SIZE; i=i+1) begin : GEN_FIFO
            FIFO #(
                // Parameter
                .DATA_WIDTH (PSUM_WIDTH),       // data bit width
                .FIFO_DEPTH (FIFO_DEPTH)        // FIFO entry num
            ) FIFO_INST (   
                // special signal
                .clk        (clk),              // clock signal
                .rst_n      (rst_n),            // negedge pointer reset signal(don't need to reset data in fifo)
                // R/W input signal
                .wren_i     (psum_en_i[i]),     // write enable signal
                .rden_i     (rden_w[i]),        // read denable signal
                // F/E output signal
                .full_o     (acc_en_w[i]),      // check fifo is full, if full the signal is high
                .empty_o    (),                 // chcek fifo is empty, if empty the signal is high
                // In/Out data signal
                .wdata_i    (fifo_in_w[i]),     // write data
                .rdata_o    (fifo_out_w[i])     // read data
            );
        end
    endgenerate
    
    
    // Output assignment
    // Output need to be quantized with high 8bit num
    genvar k;
    generate
        for (k=0; k < PE_SIZE; k=k+1) begin : GEN_OUT
            // concatenate flatten output data
            assign psum_row_o[DATA_WIDTH*(PE_SIZE-k)-1 : DATA_WIDTH*(PE_SIZE-k-1)] = fifo_out_w[k][PSUM_WIDTH-1:PSUM_WIDTH-DATA_WIDTH];
        end
    endgenerate
    
endmodule