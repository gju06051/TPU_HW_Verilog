    module GLB # (
        parameter FIFO_DATA_WIDTH = 8,
        parameter PE_SIZE = 16
    )

    (
        input   clk,
        input   rst_n,
        input   wren_i,
        input   rden_i,

        output  [PE_SIZE-1:0] full_o,
        output  [PE_SIZE-1:0] empty_o,
        
        input   [FIFO_DATA_WIDTH*PE_SIZE-1:0]   wdata_i,
        output  [FIFO_DATA_WIDTH*PE_SIZE-1:0]   rdata_o,
        output  [PE_SIZE-1:0]                   weight_en_col_o
    );

        // shift_register for delayed rden_i 
        reg rden_i_row [0:PE_SIZE-2];
        genvar k;
            generate
                for (k=0; k < PE_SIZE-2; k=k+1) begin 
                    always @(posedge clk) begin
                    rden_i_row[k+1] <= rden_i_row[k];
                    end
                end
            endgenerate

        always @(posedge clk) begin
            rden_i_row[0] <= rden_i;
        end

        // wiring rden_i_row's to w_rden_i_row's
        wire w_rden_i_row [0:PE_SIZE-1];
        
        genvar i;
            generate
                for (i=1; i < PE_SIZE; i=i+1) begin 
                    assign w_rden_i_row[i] = rden_i_row[i-1]; 
                end
            endgenerate
        assign w_rden_i_row[0] = rden_i;

        genvar l;
            generate
                for (l=0; l < PE_SIZE; l=l+1) begin 
                    assign weight_en_col_o[l] = w_rden_i_row[PE_SIZE-1-l]; //changed 
                end
            endgenerate

        // instance 16(PE_SIZE) FIFOs
        genvar j;
            generate
                for (j=0; j < PE_SIZE; j=j+1) begin : Buffer
                        FIFO #(
                            .DATA_WIDTH(FIFO_DATA_WIDTH),
                            .FIFO_DEPTH(PE_SIZE)
                        ) FIFO_INST (   
                            .clk            (clk), 
                            .rst_n          (rst_n), 
                            .wren_i         (wren_i), 
                            .rden_i         (w_rden_i_row[j]),    
                            .full_o         (full_o[j]), 
                            .empty_o        (empty_o[j]), 
                            .wdata_i        (wdata_i[FIFO_DATA_WIDTH*(PE_SIZE-j)-1 -: FIFO_DATA_WIDTH]), 
                            .rdata_o        (rdata_o[FIFO_DATA_WIDTH*(PE_SIZE-j)-1 -: FIFO_DATA_WIDTH])
                        );
                end
            endgenerate
    endmodule