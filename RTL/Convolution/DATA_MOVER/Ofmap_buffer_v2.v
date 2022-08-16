module Ofmap_buffer # (
    parameter FIFO_DATA_WIDTH = 8,
    parameter PE_SIZE = 14,
    parameter integer MEM_DEPTH = 896,
    parameter integer MEM_ADDR_WIDTH = 10,
    parameter integer MEM_DATA_WIDTH = 112,
    parameter integer OC = 64
)
(
    input clk,
    input rst_n,

    input wire en,
    input wire [(FIFO_DATA_WIDTH)*(PE_SIZE)-1:0] ofmap_row_i,

    output wire [MEM_DATA_WIDTH-1:0] mem_d_o,
    output wire [MEM_ADDR_WIDTH-1:0] mem_addr_o,
    output wire mem_ce_o,
    output wire mem_we_o,
    output wire finish_o
);
    localparam MEM_CNT = (PE_SIZE)*(OC); //896
    localparam MEM_CNT_ADDR_WIDTH = $clog2(MEM_CNT); //10

    localparam OVERALL_BUFF_ADDR = $clog2(PE_SIZE*PE_SIZE);
    localparam SINGLE_BUFF_ADDR = $clog2(PE_SIZE);
    localparam OC_ADDR_WIDTH = $clog2(OC);
    localparam  buffer_index_overflow = OC / PE_SIZE;
    localparam  buffer_index_overflow_width = $clog2((OC / PE_SIZE)+1);
    localparam  buffer_index_remainder = (OC % PE_SIZE);
    genvar i;

    // make buffer_en signals for #PE_SIZE buffers
    reg [0:PE_SIZE-2] r_buffer_en;
    wire [0:PE_SIZE-1] buffer_en;
        generate
            for (i=0; i < PE_SIZE-2; i=i+1) begin 
                always @(posedge clk) begin
                    r_buffer_en[i+1] <= r_buffer_en[i];
                end
            end
        endgenerate

    always @(posedge clk) begin
        r_buffer_en[0] <= en;
    end
    //genvar i;
        generate
            for (i=1; i < PE_SIZE; i=i+1) begin 
                assign buffer_en[i] = r_buffer_en[i-1]; 
            end
        endgenerate
    assign buffer_en[0] = en;

    // make buffer address for # PE_SIZE buffers
    wire [(OVERALL_BUFF_ADDR)*(PE_SIZE)-1:0] buffer_addr;
    reg  [(OVERALL_BUFF_ADDR)*(PE_SIZE-1)-1:0] reg_buffer_addr;
    wire buffer_is_done;

    up_counter_v3 #(
        .CNT(PE_SIZE),
        .CNT_WIDTH(OVERALL_BUFF_ADDR),
        .OFFSET(PE_SIZE)
    ) up_counter (
        .clk(clk),
        .rst_n(rst_n),
        .en(buffer_en[0]),
        .cnt_o(buffer_addr[OVERALL_BUFF_ADDR-1:0]),
        .is_done_o(buffer_is_done)
    );

    generate
        for (i=0; i < PE_SIZE-2; i=i+1) begin 
            always @(posedge clk) begin
                reg_buffer_addr[(OVERALL_BUFF_ADDR)*(i+1)+:OVERALL_BUFF_ADDR] <= reg_buffer_addr[OVERALL_BUFF_ADDR*i+:OVERALL_BUFF_ADDR];
            end
        end
    endgenerate
    always @(posedge clk) begin
        reg_buffer_addr[0 +: OVERALL_BUFF_ADDR] <= buffer_addr[0 +: OVERALL_BUFF_ADDR];
    end
    generate
        for (i=1; i < PE_SIZE; i=i+1) begin 
            assign buffer_addr[i*OVERALL_BUFF_ADDR+:OVERALL_BUFF_ADDR] = reg_buffer_addr[(i-1)*OVERALL_BUFF_ADDR+:OVERALL_BUFF_ADDR]; 
        end
    endgenerate

    reg [(FIFO_DATA_WIDTH)*(PE_SIZE)*(PE_SIZE)-1:0] buffer;
    generate
        for (i=0; i < PE_SIZE; i=i+1) begin 
            always @(posedge clk) begin
                if(buffer_en[i]) begin
                    buffer[(i+buffer_addr[i*OVERALL_BUFF_ADDR+:OVERALL_BUFF_ADDR])+FIFO_DATA_WIDTH-:FIFO_DATA_WIDTH] <= ofmap_row_i[(FIFO_DATA_WIDTH)*(PE_SIZE)-1-(i*FIFO_DATA_WIDTH)-:FIFO_DATA_WIDTH];
                end
            end
        end
    endgenerate

    // Overall operating count
    wire data_mover_done;
    Counter #(
        .COUNT_NUM(OC-1)
    ) Counter_for_mem0_wait (
        .clk(clk),
        .rst_n(rst_n),
        .start_i(buffer_is_done),
        .done_o(data_mover_done)
    );

    reg reg_mem0_ce0;
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            reg_mem0_ce0 <= 0;
        end else if(data_mover_done) begin
            reg_mem0_ce0 <= 0;
        end else if(buffer_is_done) begin
            reg_mem0_ce0 <= 1'b1;
        end
    end

    // make mem0_addr
    wire [MEM_ADDR_WIDTH-1:0] wire_mem0_addr;
    reg  [SINGLE_BUFF_ADDR-1:0] mem0_addr_offset;
    wire offset_up;
    up_counter_v3#(
        .CNT(OC),
        .CNT_WIDTH(MEM_ADDR_WIDTH),
        .OFFSET(PE_SIZE)
    ) up_counter_for_mem0_addr (
        .clk(clk),
        .rst_n(rst_n),
        .en(reg_mem0_ce0),
        .cnt_o(wire_mem0_addr),
        .is_done_o(offset_up)
    );    

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            mem0_addr_offset <= 0;
        end else if(offset_up) begin
            mem0_addr_offset <= mem0_addr_offset + 1;
        end else if(mem0_addr_offset == PE_SIZE) begin
            mem0_addr_offset <= 0;
        end
    end

    wire [OVERALL_BUFF_ADDR-1:0] buffer_index;
    wire buffer_index_done_1;
    wire buffer_index_done_2;

    reg         [buffer_index_overflow_width-1:0] buffer_index_overflow_check;
    reg         buffer_index_sel;
    up_counter_v4 #(
        .CNT_1(PE_SIZE),
        .CNT_2(buffer_index_remainder),
        .CNT_WIDTH(OVERALL_BUFF_ADDR),
        .OFFSET(PE_SIZE)
    ) up_counter_for_buffer_index (
        .clk(clk),
        .rst_n(rst_n),
        .en(reg_mem0_ce0),
        .sel(buffer_index_sel),
        .cnt_o(buffer_index),
        .is_done_o_1(buffer_index_done_1),
        .is_done_o_2(buffer_index_done_2)
    );

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            buffer_index_overflow_check <= 0;
            buffer_index_sel <= 0;
        end else if(buffer_index_overflow_check == buffer_index_overflow) begin
            buffer_index_overflow_check <= 0;
            buffer_index_sel <= 1;
        end else if(buffer_index_done_2) begin
            buffer_index_overflow_check <= 0;
            buffer_index_sel <= 0;
        end else if(buffer_index_done_1) begin
            buffer_index_overflow_check <= buffer_index_overflow_check + 1;
        end
    end    

    assign mem2_addr_o   = wire_mem0_addr + mem0_addr_offset;
    assign mem2_ce_o     = reg_mem0_ce0;
    assign mem2_we_o     = 1'b1;
    generate
        for (i=0; i < PE_SIZE; i=i+1) begin   
            assign mem_d_o[(PE_SIZE)*(FIFO_DATA_WIDTH)-1-(i*(FIFO_DATA_WIDTH))-: FIFO_DATA_WIDTH] = buffer[buffer_index + i*(FIFO_DATA_WIDTH)-1-:FIFO_DATA_WIDTH];
        end
    endgenerate

    reg r_finish;
    always @(*) begin
        if(mem2_addr_o == MEM_DEPTH-1) begin
            r_finish <= 1'b1;
        end else begin
            r_finish <= 1'b0;
        end
    end
    assign finish = r_finish;
endmodule