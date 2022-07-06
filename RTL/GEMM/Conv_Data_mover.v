    module Conv_Data_mover # (
        parameter integer MEM0_DEPTH = 896,
        parameter integer MEM1_DEPTH = 896,
		parameter integer MEM0_ADDR_WIDTH = 7,
        parameter integer MEM1_ADDR_WIDTH = 7,
		parameter integer MEM0_DATA_WIDTH = 128,
        parameter integer MEM1_DATA_WIDTH = 128,
        parameter integer PE_SIZE = 16
    )

    (
        input clk,
        input rst_n,
        input en,

        input  wire [MEM0_DATA_WIDTH-1:0] mem0_q0,
		output wire	[MEM0_ADDR_WIDTH-1:0] mem0_addr0,
		output wire	mem0_ce0,
		output wire	mem0_we0,

        input  wire [MEM1_DATA_WIDTH-1:0] mem1_q0,
		output wire	[MEM1_ADDR_WIDTH-1:0] mem1_addr0,
		output wire	mem1_ce0,
		output wire	mem1_we0
    );

        reg [MEM0_DEPTH-1:0] mem0_num_cnt;
        reg [MEM1_DEPTH-1:0] mem1_num_cnt;
        reg mem0_read_en;
        reg mem1_read_en;

        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                mem0_num_cnt <= 0;
                mem1_num_cnt <= 0;
                mem0_read_en <= 0;
                mem1_read_en <= 0;
            end else if(en) begin 
                if(mem0_num_cnt[3:0] == (PE_SIZE-1) && mem1_num_cnt != (MEM1_DEPTH-1)) begin
                    mem1_num_cnt <= mem1_num_cnt + 1;
                    mem0_read_en <= 0;
                    mem1_read_en <= 1;
                end else if(mem1_num_cnt == (MEM1_DEPTH-1)) begin
                    mem0_num_cnt <= mem0_num_cnt + 1;
                    mem1_num_cnt <= 0;
                    mem0_read_en <= 1;
                    mem1_read_en <= 0;
                end else begin
                    mem0_num_cnt <= mem0_num_cnt + 1;
                    mem0_read_en <= 1;
                    mem1_read_en <= 0;
                end
            end
        end

        assign mem0_addr0   = mem0_num_cnt;
        assign mem1_addr0   = mem1_num_cnt;
        assign mem0_ce0     = mem0_read_en;
        assign mem1_ce0     = mem1_read_en;
        assign mem0_we0     = !(mem0_read_en);
        assign mem1_we0     = !(mem1_read_en);
    
    endmodule