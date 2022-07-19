// Module Name: data_mover_bram_Pooling7
// 
// description
//      Take input node from BRAM0 
//      Then do Max_Pooling Operation and Make 7 result using 7 Core
//      moudle has 3 staus: IDLE, RUN, DONE. Outside can know the state of module by checking the state(output).
//      To use 2 brams, notice the Memory I/F(Check the Timing diagram of BRAMS.)
//      The number of Data is given from the outside, run_count_i0, run_count_i1 signal
//      run_count_i0 gives number of input neuron and run_count_i1 gives number of output neuron
//      this module do max_pooling so the 2 number will be different
//
// Flow
//      0. Write Input node to the BRAM 0
//      1. give start_run_i signal with run_count_i
//      2. wait for done_state
//      3. The data mover bram will write the result to the BRAM1
//
// inputs
//      Special Inputs
//          clk: special inputs. Clock
//          reset_n: special input. reset (active low)
//
//      Signal From Controller
//          start_run_i: active high. Signal for start running the data mover.
//          run_count_i0: number of data that module should read - data from BRAM0
//          run_count_i1: number of data that module should write - data to BRAM1
//      
//      Memory I/F
//          q_b0_i0/i1: data that read from the BRAM0 port0/port1
//          q_b1_i: data that user want to read from the bram1.
//          
// outputs
//      State_Outputs
//          idle_o: state of module. represent idle state. also represent the right after of done_o state.
//          read_o: state of module. represent that module is read the data now.
//          write_o: state of module. reapresent that module is write the data now.
//          done_o: state of module. represent the done state. 
//      
//      Memory I/F
//          addr_b0_o/addr_b1_o: address of memory that user want to access.
//          ce_b0_o/ce_b1_o: chip enable
//          we_b0_o/we_b1_o: write enable. 0 means read mode and 1 means write mode
//          d_b0_o/d_b1_o: data that user wants to write
// Notice
//      this data mover will read the data from BRAM0 and then write to BRAM1
//      doing read from BRAM0, it use dual port: one port for odd addr(1,3,5...) one port for even addr(0,2,4...) 
//

`timescale 1ns / 1ps

module data_mover_bram_Pooling7
# (
    parameter CNT_BIT = 31,

    /* parameter for BRAM */
    parameter DWIDTH = 112,
    parameter DWIDTH_P = 56, // reduced because of pooling
    parameter AWIDTH = 12,
    parameter MEM_SIZE = 4096,
    parameter IN_DATA_WIDTH = 8
)
(
    /* Special Inputs*/
    input clk,
    input reset_n,

    /* Signal From Register */
    input start_run_i, 
    input [CNT_BIT - 1 : 0] run_count_i0, // the number of "input" - BRAM0's item 
    input [CNT_BIT - 1 : 0] run_count_i1, // the number of "output" - BRAM1's item

    /* Memory I/F Input for BRAM0 */
    input [DWIDTH - 1 : 0] q_b0_i1,
    input [DWIDTH - 1 : 0] q_b0_i2,

    /* Memory I/F Input for BRAM1 */
    input [DWIDTH_P - 1 : 0] q_b1_i,

    /* State_Outputs */
    output idle_o,
    output read_o,
    output write_o,
    output done_o,

    /* Memory I/F output for BRAM0 */
    output [AWIDTH - 1 : 0] addr0_b0_o,
    output [AWIDTH - 1 : 0] addr1_b0_o,
    output ce_b0_o,
    output we_b0_o,
    output [DWIDTH - 1 : 0] d_b0_o,
 
    /* Memory I/F output for BRAM1 */
    output [AWIDTH - 1 : 0] addr_b1_o,
    output ce_b1_o,
    output we_b1_o,
    output [DWIDTH_P - 1 : 0] d_b1_o
);

/* localparam to define the state */
localparam S_IDLE = 2'b00;
localparam S_RUN = 2'b01;
localparam S_DONE = 2'b10;

/* For FSM */
reg [1 : 0] c_state_read; // current state Read
reg [1 : 0] n_state_read; // Next state Write
reg [1 : 0] c_state_write; // current state Write
reg [1 : 0] n_state_write; // Next state Write

/* wire for compute the next state block */
wire is_write_done; // temporal write done siganl
wire is_read_done; // temporal write done signal 

/* Always Block to update the state (both R/W) */
always @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        c_state_read <= S_IDLE;
    end else begin
        c_state_read <= n_state_read;
    end
end

always @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        c_state_write <= S_IDLE;
    end else begin
        c_state_write <= n_state_write;
    end
end

/* Always block to compute n_state_R/W */
always @(*) begin
    n_state_read = c_state_read; // to prevent latch
    
    case(c_state_read)
        S_IDLE : if(start_run_i)   begin n_state_read = S_RUN; end
        S_RUN  : if(is_read_done)  begin n_state_read = S_DONE; end
        S_DONE : n_state_read = S_IDLE; 
    endcase
end

always @(*) begin
    n_state_write = c_state_write; // prevent latch
 
    case(c_state_write)
        S_IDLE : if(start_run_i)   begin n_state_write = S_RUN; end
        S_RUN  : if(is_write_done) begin n_state_write = S_DONE; end
        S_DONE : n_state_write = S_IDLE; 
    endcase
end

/* compute Output */
assign idle_o   = (c_state_read == S_IDLE) && (c_state_write == S_IDLE);
assign read_o   = (c_state_read == S_RUN);
assign write_o  = (c_state_write == S_RUN);
assign done_o   = (c_state_write == S_DONE); // Write will always finish after the read
// done_state is synchronized with wirte_done because Write is always later than read

/* Capture number of Count(number of data to move) */
reg [CNT_BIT - 1 : 0] num_cnt0;
always @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        num_cnt0 <= 0;
    end else if (start_run_i) begin
        num_cnt0 <= run_count_i0;
    end else if (done_o) begin // When read_run state
        num_cnt0 <= 0; 
    end
end

reg [CNT_BIT - 1 : 0] num_cnt1;
always @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        num_cnt1 <= 0;
    end else if (start_run_i) begin
        num_cnt1 <= run_count_i1;
    end else if (done_o) begin // When read_run state
        num_cnt1 <= 0; 
    end
end
/* Increase address count */
reg [CNT_BIT - 1 : 0] addr_cnt_read_odd; // odd row read
reg [CNT_BIT - 1 : 0] addr_cnt_read_even; // even row read
reg [CNT_BIT - 1 : 0] addr_cnt_write; 
assign is_read_done = read_o && (addr_cnt_read_odd == num_cnt0 - 1); // change odd to even if the num_cnt is odd
assign is_write_done = write_o && (addr_cnt_write == num_cnt1 - 1); // is_done signal is 1 tic 

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        addr_cnt_read_even <= 0;
    end else if (is_read_done) begin
        addr_cnt_read_even <= 0;
    end else if (read_o) begin // when read_run_state
        addr_cnt_read_even <= addr_cnt_read_even + 2;
    end
end

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        addr_cnt_read_odd <= 1;
    end else if (is_read_done) begin
        addr_cnt_read_odd <= 1;
    end else if (read_o) begin // when read_run_state
        addr_cnt_read_odd <= addr_cnt_read_odd + 2;
    end
end

// we_b1_o signal is write enable signal that even consider calc_delay
// notice that we_b1_o signal is needed because module have to consider the calc_delay
// so that address of write count will increase when module "really" do write
wire result_valid;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        addr_cnt_write <= 0;
    end else if (is_write_done) begin
        addr_cnt_write <= 0;
    // end else if (write_o && we_b1_o) begin // when write_run_state
    end else if (write_o && result_valid) begin // consider core_delay
        addr_cnt_write <= addr_cnt_write + 1;
    end
end

/* Data(node) Read From BRAM0 */
assign addr0_b0_o  = addr_cnt_read_even;
assign addr1_b0_o  = addr_cnt_read_odd;
assign ce_b0_o    = read_o;
assign we_b0_o    = 1'b0; // read only
assign d_b0_o     = {DWIDTH{1'b0}}; // read only. don't Use this

reg  r_valid; // signal to immplement 1_cycle delay of read_valid. check the timing diagram of bram
wire [DWIDTH - 1 : 0]   mem_data_0;
wire [DWIDTH - 1 : 0]   mem_data_1;

// Making 1 cycle latency to sync mem output
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        r_valid <= 1'b0;
    end else begin
        r_valid <= read_o;
    end
end
assign mem_data_0 = q_b0_i1;
assign mem_data_1 = q_b0_i2;

/* Write Data to BRAM1 */
wire [DWIDTH_P - 1 : 0] core_result; 

assign addr_b1_o = addr_cnt_write;
assign ce_b1_o = result_valid;
assign we_b1_o = result_valid; 
assign d_b1_o = core_result; 

wire [IN_DATA_WIDTH - 1 : 0]        w_a_6 = mem_data_0[(14*IN_DATA_WIDTH) - 1 : (13*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_b_6 = mem_data_0[(13*IN_DATA_WIDTH) - 1 : (12*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_c_6 = mem_data_1[(14*IN_DATA_WIDTH) - 1 : (13*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_d_6 = mem_data_1[(13*IN_DATA_WIDTH) - 1 : (12*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_result_6;
wire                                w_valid_6;

wire [IN_DATA_WIDTH - 1 : 0]        w_a_5 = mem_data_0[(12*IN_DATA_WIDTH) - 1 : (11*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_b_5 = mem_data_0[(11*IN_DATA_WIDTH) - 1 : (10*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_c_5 = mem_data_1[(12*IN_DATA_WIDTH) - 1 : (11*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_d_5 = mem_data_1[(11*IN_DATA_WIDTH) - 1 : (10*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_result_5;
wire                                w_valid_5;

wire [IN_DATA_WIDTH - 1 : 0]        w_a_4 = mem_data_0[(10*IN_DATA_WIDTH) - 1 : (9*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_b_4 = mem_data_0[(9*IN_DATA_WIDTH) - 1 : (8*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_c_4 = mem_data_1[(10*IN_DATA_WIDTH) - 1 : (9*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_d_4 = mem_data_1[(9*IN_DATA_WIDTH) - 1 : (8*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_result_4;
wire                                w_valid_4;

wire [IN_DATA_WIDTH - 1 : 0]        w_a_3 = mem_data_0[(8*IN_DATA_WIDTH) - 1 : (7*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_b_3 = mem_data_0[(7*IN_DATA_WIDTH) - 1 : (6*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_c_3 = mem_data_1[(8*IN_DATA_WIDTH) - 1 : (7*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_d_3 = mem_data_1[(7*IN_DATA_WIDTH) - 1 : (6*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_result_3;
wire                                w_valid_3;

wire [IN_DATA_WIDTH - 1 : 0]        w_a_2 = mem_data_0[(6*IN_DATA_WIDTH) - 1 : (5*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_b_2 = mem_data_0[(5*IN_DATA_WIDTH) - 1 : (4*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_c_2 = mem_data_1[(6*IN_DATA_WIDTH) - 1 : (5*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_d_2 = mem_data_1[(5*IN_DATA_WIDTH) - 1 : (4*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_result_2;
wire                                w_valid_2;

wire [IN_DATA_WIDTH - 1 : 0]        w_a_1 = mem_data_0[(4*IN_DATA_WIDTH) - 1 : (3*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_b_1 = mem_data_0[(3*IN_DATA_WIDTH) - 1 : (2*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_c_1 = mem_data_1[(4*IN_DATA_WIDTH) - 1 : (3*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_d_1 = mem_data_1[(3*IN_DATA_WIDTH) - 1 : (2*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_result_1;
wire                                w_valid_1;

wire [IN_DATA_WIDTH - 1 : 0]        w_a_0 = mem_data_0[(2*IN_DATA_WIDTH) - 1 : (1*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_b_0 = mem_data_0[(1*IN_DATA_WIDTH) - 1 : (0*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_c_0 = mem_data_1[(2*IN_DATA_WIDTH) - 1 : (1*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_d_0 = mem_data_1[(1*IN_DATA_WIDTH) - 1 : (0*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_result_0;
wire                                w_valid_0;

/* Core Instantiation */
Max_Pooling_Core 
# (
    .IN_DATA_WIDTH(IN_DATA_WIDTH) 
) Max_Pooling_core_inst_1 (
    .clk(clk), .reset_n(reset_n),

    /* node to be compared */
    .node1_i(w_a_6), .node2_i(w_b_6), .node3_i(w_c_6), .node4_i(w_d_6),
    
    .valid_i(r_valid),
    .run_i(start_run_i),

    .valid_o(w_valid_6),
    .result_o(w_result_6)    
);

Max_Pooling_Core 
# (
    .IN_DATA_WIDTH(IN_DATA_WIDTH) 
) Max_Pooling_core_inst_2 (
    .clk(clk), .reset_n(reset_n),

    /* node to be compared */
    .node1_i(w_a_5), .node2_i(w_b_5), .node3_i(w_c_5), .node4_i(w_d_5),
    
    .valid_i(r_valid),
    .run_i(start_run_i),

    .valid_o(w_valid_5),
    .result_o (w_result_5)    
);

Max_Pooling_Core 
# (
    .IN_DATA_WIDTH(IN_DATA_WIDTH) 
) Max_Pooling_core_inst_3 (
    .clk(clk), .reset_n(reset_n),

    /* node to be compared */
    .node1_i(w_a_4), .node2_i(w_b_4), .node3_i(w_c_4), .node4_i(w_d_4),
    
    .valid_i(r_valid),
    .run_i(start_run_i),

    .valid_o(w_valid_4),
    .result_o (w_result_4)    
);

Max_Pooling_Core 
# (
    .IN_DATA_WIDTH(IN_DATA_WIDTH) 
) Max_Pooling_core_inst_4 (
    .clk(clk), .reset_n(reset_n),

    /* node to be compared */
    .node1_i(w_a_3), .node2_i(w_b_3), .node3_i(w_c_3), .node4_i(w_d_3),
    
    .valid_i(r_valid),
    .run_i(start_run_i),

    .valid_o(w_valid_3),
    .result_o (w_result_3)    
);

Max_Pooling_Core 
# (
    .IN_DATA_WIDTH(IN_DATA_WIDTH) 
) Max_Pooling_core_inst_5 (
    .clk(clk), .reset_n(reset_n),

    /* node to be compared */
    .node1_i(w_a_2), .node2_i(w_b_2), .node3_i(w_c_2), .node4_i(w_d_2),
    
    .valid_i(r_valid),
    .run_i(start_run_i),

    .valid_o(w_valid_2),
    .result_o (w_result_2)    
);

Max_Pooling_Core 
# (
    .IN_DATA_WIDTH(IN_DATA_WIDTH) 
) Max_Pooling_core_inst_6 (
    .clk(clk), .reset_n(reset_n),

    /* node to be compared */
    .node1_i(w_a_1), .node2_i(w_b_1), .node3_i(w_c_1), .node4_i(w_d_1),
    
    .valid_i(r_valid),
    .run_i(start_run_i),

    .valid_o(w_valid_1),
    .result_o (w_result_1)    
);

Max_Pooling_Core 
# (
    .IN_DATA_WIDTH(IN_DATA_WIDTH) 
) Max_Pooling_core_inst_7 (
    .clk(clk), .reset_n(reset_n),

    /* node to be compared */
    .node1_i(w_a_0), .node2_i(w_b_0), .node3_i(w_c_0), .node4_i(w_d_0),
    
    .valid_i(r_valid),
    .run_i(start_run_i),

    .valid_o(w_valid_0),
    .result_o (w_result_0)    
);

/* Making Output */
assign result_valid = w_valid_0 & w_valid_1 & w_valid_2 & w_valid_3 & w_valid_4 & w_valid_5 & w_valid_6;
assign core_result  = {w_result_6, w_result_5, w_result_4, w_result_3, w_result_2, w_result_1, w_result_0}; 
endmodule

