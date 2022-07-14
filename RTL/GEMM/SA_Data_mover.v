module SA_Data_mover # (
    parameter FIFO_DATA_WIDTH = 8,
    parameter PE_SIZE = 16,
    parameter integer MEM0_DEPTH = 896,
    parameter integer MEM0_ADDR_WIDTH = 7,
    parameter integer MEM0_DATA_WIDTH = 112,
    parameter integer OC = 64
)
(
    input clk,
    input rst_n,
    input  wire en,
    output wire [PE_SIZE-1:0] rden_o,
    input  wire [(FIFO_DATA_WIDTH*PE_SIZE)-1:0] rdata_i,
    output wire [MEM0_DATA_WIDTH-1:0] mem0_d0,
    output wire [MEM0_ADDR_WIDTH-1:0] mem0_addr0,
    output wire mem0_ce0,
    output wire mem0_we0
);
    localparam BUFF_ADDR = $clog2(PE_SIZE);
    localparam OC_ADDR_WIDTH = $clog2(OC);

    // (fixed)
    localparam OUT_CNT = OC;
    
    localparam OUT_CNT_ADDR = $clog2(PE_SIZE*OC);

    //(added)
    localparam  buffer_index_overflow = OC / PE_SIZE;
    localparam  buffer_index_overflow_width = $clog2((OC / PE_SIZE)+1);
    localparam  buffer_index_remainder = (OC % PE_SIZE);
    
    // make #(PE_SIZE-1) buffer_en signal
    reg r_buffer_en [0:PE_SIZE-2];
    wire buffer_en [0:PE_SIZE-1];
    genvar i;
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
    generate
        for (i=0; i < PE_SIZE; i=i+1) begin 
            assign rden_o[i] = buffer_en[i]; 
        end
    endgenerate


    wire [BUFF_ADDR-1:0] buffer_addr [0:PE_SIZE-1];
    reg  [BUFF_ADDR-1:0] reg_buffer_addr [0:PE_SIZE-2];
    wire buffer_is_done;

    // Check 1st row complete
    up_counter #(
        .CNT(PE_SIZE),
        .CNT_WIDTH(BUFF_ADDR)
    ) up_counter (
        .clk(clk),
        .rst_n(rst_n),
        .en(buffer_en[0]),
        .cnt_o(buffer_addr[0]),
        .is_done_o(buffer_is_done)
    );

    generate
        for (i=0; i < PE_SIZE-2; i=i+1) begin 
            always @(posedge clk) begin
                reg_buffer_addr[i+1] <= reg_buffer_addr[i];
            end
        end
    endgenerate
    always @(posedge clk) begin
        reg_buffer_addr[0] <= buffer_addr[0];
    end
    generate
        for (i=1; i < PE_SIZE; i=i+1) begin 
            assign buffer_addr[i] = reg_buffer_addr[i-1]; 
        end
    endgenerate

    reg [FIFO_DATA_WIDTH-1:0] buffer[0:(PE_SIZE)*(PE_SIZE)-1];
    generate
        for (i=0; i < PE_SIZE; i=i+1) begin 
            always @(posedge clk) begin
                if(buffer_en[i]) begin
                    buffer[(PE_SIZE*i)+buffer_addr[i]] <= rdata_i[(FIFO_DATA_WIDTH)*(PE_SIZE)-1-(i*FIFO_DATA_WIDTH)-:FIFO_DATA_WIDTH];
                end
            end
        end
    endgenerate

    // overall operating count
    wire data_mover_done;
    Counter #(
        .COUNT_NUM(OUT_CNT-1)
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
    wire [OC_ADDR_WIDTH-1:0] wire_mem0_addr;
    reg  [BUFF_ADDR-1:0] mem0_addr_offset;
    wire offset_up;
    up_counter #(
        .CNT(OC),
        .CNT_WIDTH(OC_ADDR_WIDTH)
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
    wire [BUFF_ADDR-1:0] buffer_index;
    wire buffer_index_done_1;
    wire buffer_index_done_2;
    /*
    up_counter #(
        .CNT(PE_SIZE),
        .CNT_WIDTH(BUFF_ADDR)
    ) up_counter_for_buffer_index (
        .clk(clk),
        .rst_n(rst_n),
        .en(reg_mem0_ce0),
        .cnt_o(buffer_index),
        .is_done_o(buffer_index_done)
    );
    */
    
    reg         [buffer_index_overflow_width-1:0] buffer_index_overflow_check;
    reg         buffer_index_sel;
    up_counter_v2 #(
        .CNT_1(PE_SIZE),
        .CNT_2(buffer_index_remainder),
        .CNT_WIDTH(BUFF_ADDR)
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

    assign mem0_addr0   = wire_mem0_addr * (PE_SIZE) + mem0_addr_offset;
    assign mem0_ce0     = reg_mem0_ce0;
    assign mem0_we0     = 1'b1;
    generate
        for (i=0; i < PE_SIZE; i=i+1) begin   
            assign mem0_d0[(PE_SIZE)*(FIFO_DATA_WIDTH)-1-(i*(FIFO_DATA_WIDTH))-: FIFO_DATA_WIDTH] = buffer[buffer_index*(PE_SIZE) + i];
        end
    endgenerate

endmodule