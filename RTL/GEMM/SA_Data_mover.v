module SA_Data_mover # (
    parameter FIFO_DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 16,
    parameter PE_SIZE = 16,
    parameter integer MEM0_DEPTH = 896,
    parameter integer MEM1_DEPTH = 896,
    parameter integer MEM0_ADDR_WIDTH = 7,
    parameter integer MEM1_ADDR_WIDTH = 7,
    parameter integer MEM0_DATA_WIDTH = 128,
    parameter integer MEM1_DATA_WIDTH = 128,
    parameter integer OC = 64
)
(
    input clk,
    input rst_n,
    input wire en,
    input wire [(FIFO_DATA_WIDTH*PE_SIZE)-1:0] rdata_i
);
    localparam BUFF_ADDR = $clog2(PE_SIZE);
    localparam OUT_CNT = PE_SIZE*OC;
    localparam OUT_CNT_ADDR = $clog2(PE_SIZE*OC);
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



    wire [BUFF_ADDR-1:0] buffer_addr [0:PE_SIZE-1];
    reg  [BUFF_ADDR-1:0] reg_buffer_addr [0:PE_SIZE-2];
    wire buffer_is_done;

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
                    buffer[(PE_SIZE*i)+buffer_addr[i]] <= rdata_i[(FIFO_DATA_WIDTH)*(PE_SIZE-1-i)+:FIFO_DATA_WIDTH];
                end
            end
        end
    endgenerate

    // overall operating count
    wire data_mover_done;
    Counter #(
        .COUNT_NUM(OUT_CNT)
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
        end else if(buffer_is_done) begin
            reg_mem0_ce0 <= 1'b1;
        end else if(data_mover_done) begin
            reg_mem0_ce0 <= 0;
        end
    end
    assign mem0_addr0 = 
    assign mem0_ce0 = reg_mem0_ce0;

endmodule