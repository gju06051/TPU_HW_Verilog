module AXI_to_MEM_buffer #(
        parameter   AXI_DATA_WIDTH          = 32,
        parameter   MEM_DATA_WIDTH          = 128
    )
    (
        input       clk,
        input       rst,
        input       [AXI_DATA_WIDTH-1:0]    AXI_wdata_i,
        input       [MEM_DATA_WIDTH-1:0]    MEM_rdata_i,
        input                               AXI_read_req,
        input                               AXI_write_req,
        output      [AXI_DATA_WIDTH-1:0]    AXI_rdata_o,
        output      [MEM_DATA_WIDTH-1:0]    MEM_wdata_o
    );

    reg                                     AXI_read_req_delay;
     always@(posedge clk) begin
       AXI_read_req_delay <= AXI_read_req;
    end

    reg             [1:0]                   write_idx;
    reg             [1:0]                   read_idx;
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            write_idx       <= 2'b0;
            read_idx        <= 2'b0;
        end else begin
            if(AXI_write_req) begin
                write_idx   <= write_idx + 1;
            end
            if(AXI_read_req) begin
                read_idx    <= read_idx + 1;
            end
        end
    end


    reg             [MEM_DATA_WIDTH-1:0]    AXI_wbuff;
    reg             [MEM_DATA_WIDTH-1:0]    AXI_rbuff;

    always@(posedge clk) begin
        if(AXI_write_req) begin
            AXI_wbuff[(write_idx*AXI_DATA_WIDTH)+:AXI_DATA_WIDTH] <= AXI_wdata_i;
        end
        if(AXI_read_req_delay) begin
            AXI_rbuff <= MEM_rdata_i;
        end

    end



    assign mem0_addr1 	= mem0_addr_cnt[MEM0_ADDR_WIDTH-1:0]			; 
	assign mem0_ce1		= mem0_data_write_hit || mem0_data_read_hit		;
	assign mem0_we1		= mem0_data_write_hit 							;
	assign mem0_d1		= mem0_data_reg									;
endmodule