    module Conv_Data_mover_v2 # (
        parameter integer MEM0_DEPTH = 896,
        parameter integer MEM1_DEPTH = 896,
		parameter integer MEM0_ADDR_WIDTH = 7,
        parameter integer MEM1_ADDR_WIDTH = 7,
		parameter integer MEM0_DATA_WIDTH = 128,
        parameter integer MEM1_DATA_WIDTH = 128,
        parameter integer PE_SIZE = 16,
        parameter integer WEIGHT_ROW_NUM = 70, // 64 + 6
        parameter integer WEIGHT_COL_NUM = 294 // 288 + 6
    )

    (
        input clk,
        input rst_n,
        input en,

        // mem0 interface
        input  wire [MEM0_DATA_WIDTH-1:0] mem0_q0_i,
		output wire	[MEM0_ADDR_WIDTH-1:0] mem0_addr0,
		output wire	mem0_ce0,
		output wire	mem0_we0,

        // mem1 interface
        input  wire [MEM1_DATA_WIDTH-1:0] mem1_q0_i,
		output wire	[MEM1_ADDR_WIDTH-1:0] mem1_addr0,
		output wire	mem1_ce0,
		output wire	mem1_we0,

        // SA stationary interface
        output wire [MEM0_DATA_WIDTH-1:0] mem0_q0_o,
        output wire mem0_q0_vaild,

        // GLB interface
        output wire [MEM0_DATA_WIDTH-1:0] mem1_q0_o,
        output wire wren_o,
        output wire rden_o,

        // SA_DATA_MOVER_EN
        output wire sa_data_mover_en
    );
        localparam MEM0_NUM_CNT_WIDTH   = $clog2(MEM0_DEPTH);
        localparam MEM1_NUM_CNT_WIDTH   = $clog2(MEM1_DEPTH);
        localparam MEM0_WAIT_WIDTH      = $clog2(PE_SIZE-1);
        localparam WEIGHT_COL_NUM_WIDTH = $clog2(WEIGHT_COL_NUM);
        localparam SA_DATA_MOVER_EN_NUM = ((WEIGHT_COL_NUM / PE_SIZE) - 1)*WEIGHT_ROW_NUM;
        //localparam SA_DATA_MOVER_CNT_NUM = (WEIGHT_COL_NUM * PE_SIZE);

        assign mem0_q0_o = mem0_q0_i;
        assign mem1_q0_o = mem1_q0_i;
        
        reg [MEM0_NUM_CNT_WIDTH-1:0]    mem0_num_cnt;
        reg [MEM1_NUM_CNT_WIDTH-1:0]    mem1_num_cnt;
        reg mem0_read_en;
        reg mem1_read_en;

    
        wire mem1_read_en_done;
        wire mem1_num_cnt_en;
        
        reg [MEM0_WAIT_WIDTH-1:0]       mem0_wait;
        wire counter_is_done;
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                mem0_wait <= 1'b0;
            end else if(mem1_num_cnt == (WEIGHT_ROW_NUM-1)) begin
                mem0_wait <= 1'b1;
            end else if(counter_is_done) begin
                mem0_wait <= 1'b0;
            end
        end

        Counter #(
            .COUNT_NUM(PE_SIZE-3)
        ) Counter_for_mem0_wait (
            .clk(clk),
            .rst_n(rst_n),
            .start_i(mem0_wait),
            .done_o(counter_is_done)
        );
        
       

        /* set mem0 port : mem0_addr and mem0_ce */
        // first(version1): mem0_ce(mem0_read_en)
        /*
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                mem0_read_en <= 0;
            end else if(en) begin
                if((mem0_num_cnt[3:0] == (PE_SIZE-1)) || (mem1_read_en)) begin
                    mem0_read_en <= 0;
                end else begin
                    mem0_read_en <= 1;
                end
            end
        end
        */
        // first(version2): mem0_ce(mem0_read_en)
        /*
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                mem0_read_en <= 0;
            end else if(en) begin
                if((mem0_num_cnt[3:0] == (PE_SIZE-1)) || (mem1_read_en)) begin
                    mem0_read_en <= 0;
                end else if(!mem0_wait) begin
                    mem0_read_en <= 1;
                end
            end
        end
        */

        // first(version23): mem0_ce(mem0_read_en) PE_SIZE change to 14
        wire mem0_read_en_done;
         Counter #(
            .COUNT_NUM(PE_SIZE-1)
        ) Counter_for_mem0_read_en_done (
            .clk(clk),
            .rst_n(rst_n),
            .start_i(mem0_read_en),
            .done_o(mem0_read_en_done)
        );
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                mem0_read_en <= 0;
            end else if(en) begin
                if((mem0_read_en_done) || (mem1_read_en)) begin
                    mem0_read_en <= 0;
                end else if(!mem0_wait) begin
                    mem0_read_en <= 1;
                end
            end
        end

        // Second : mem0_addr(mem0_num_cnt)
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                mem0_num_cnt <= 0;
            end else if(mem0_read_en) begin
                mem0_num_cnt <= mem0_num_cnt + 1;
            end 
        end
        
        /* set mem1 port : mem1_addr and mem1_ce */
        // first : mem1_ce(mem1_read_en)
        wire mem1_read_en_run;
        Counter #(
            .COUNT_NUM(PE_SIZE-3) // or 2
        ) Counter_for_mem1_read_en_run (
            .clk(clk),
            .rst_n(rst_n),
            .start_i(mem0_read_en),
            .done_o(mem1_read_en_run)
        );
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                mem1_read_en <= 0;
            end else if(mem1_read_en_done) begin
                mem1_read_en <= 0;
            end else if(mem1_read_en_run) begin
                mem1_read_en <= 1;
            end
        end

        // Second : mem1_addr(mem1_num_cnt)
        //reg [WEIGHT_COL_NUM_WIDTH-1:0] mem1_addr_offset;
        always @(posedge clk or negedge rst_n) begin
            if(!rst_n) begin
                mem1_num_cnt <= 0;
            end else if(mem1_num_cnt == MEM1_DEPTH-1) begin
                mem1_num_cnt <= 0;
            end else if(mem1_num_cnt_en) begin
                mem1_num_cnt <= mem1_num_cnt + 1;
            end
        end
        //wire mem1_num_cnt_en;
        //wire mem1_read_en_done;
        Counter_v2 #(
            .COUNT_NUM(WEIGHT_ROW_NUM)
        ) Counter_for_mem1_addr (
            .clk(clk),
            .rst_n(rst_n),
            .start_i(mem1_read_en_run), //(changed)
            .run_o(mem1_num_cnt_en),
            .done_o(mem1_read_en_done)
        );

        //make SA_data_mover_en
        reg sa_en_counter_run_0;
        wire sa_en_counter_run_1;
        always @(*) begin
            if(mem1_num_cnt == SA_DATA_MOVER_EN_NUM + 1) begin
                sa_en_counter_run_0 = 1'b1;
            end else begin
                sa_en_counter_run_0 = 1'b0;
            end
        end
        Counter #(
            .COUNT_NUM(PE_SIZE-1)
        ) Counter_for_sa_data_mover_en_0 (
            .clk(clk),
            .rst_n(rst_n),
            .start_i(sa_en_counter_run_0),
            .done_o(sa_en_counter_run_1)
        );

        Counter_v2 #(
            .COUNT_NUM(WEIGHT_ROW_NUM)
        ) Counter_for_sa_data_mover_en_1 (
            .clk(clk),
            .rst_n(rst_n),
            .start_i(sa_en_counter_run_1),
            .run_o(sa_data_mover_en),
            .done_o()
        );

        assign mem0_addr0   = mem0_num_cnt;
        assign mem1_addr0   = mem1_num_cnt;
        assign mem0_ce0     = mem0_read_en;
        assign mem1_ce0     = mem1_read_en && (!mem1_read_en_done); //(changed)
        assign mem0_we0     = 1'b0; // *only read operation
        assign mem1_we0     = 1'b0; // *only read operation

        reg reg_mem0_q0_vaild;
        reg reg_wren_o;
        reg reg_rden_o;
        always @(posedge clk) begin
            reg_mem0_q0_vaild <= mem0_read_en;
            reg_wren_o        <= mem1_read_en;
            reg_rden_o        <= reg_wren_o;
        end
        assign mem0_q0_vaild = reg_mem0_q0_vaild;
        assign wren_o = reg_wren_o;
        assign rden_o = reg_rden_o;
    endmodule