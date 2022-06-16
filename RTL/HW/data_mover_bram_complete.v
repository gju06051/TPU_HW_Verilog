// Module Name: data_mover_bram
// 
// discription
//      Take input node from BRAM0 and Take weight from BRAM1
//      Then do MAC Operation and Make 4 result using 4 Core
//      moudle has 3 staus: IDLE, RUN, DONE. Outside can know the state of module by checking the state(output).
//      To use 2 brams, notice the Memory I/F(Check the Timing diagram of BRAMS.)
//      The number of Data is given from the outside, run_count_i signal
//
// inputs
//      Special Inputs
//          clk: special inputs. Clock
//          reset_n: special input. reset (active low)
//
//      Signal From Register
//          start_run_i: active high. Signal for start running the data mover.
//          run_count_i: number of data that module should take
//      
//      Memory I/F
//          q_b0_i: data that user want to write in the bram0.
//          q_b1_i: data that user want to write in the bram1.
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
//      this data mover will read the data from BRAM0 and BRAM1
//      So BRAM0 and BRAM1 is read-only 
//

`timescale 1ns / 1ps

module data_mover_bram 
# (
    parameter CNT_BIT = 31,

    /* parameter for BRAM */
    parameter DWIDTH = 32,
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
    input [CNT_BIT - 1 : 0] run_count_i, 

    /* Memory I/F Input for BRAM0 */
    input [DWIDTH - 1 : 0] q_b0_i,

    /* Memory I/F Input for BRAM0 */
    input [DWIDTH - 1 : 0] q_b1_i,

    /* State_Outputs */
    output idle_o,
    output read_o,
    output write_o,
    output done_o,

    /* Memory I/F output for BRAM0 */
    output [AWIDTH - 1 : 0] addr_b0_o,
    output ce_b0_o,
    output we_b0_o,
    output [DWIDTH - 1 : 0] d_b0_o,
 
    /* Memory I/F output for BRAM1 */
    output [AWIDTH - 1 : 0] addr_b1_o,
    output ce_b1_o,
    output we_b1_o,
    output [DWIDTH - 1 : 0] d_b1_o,

    /* result for 4 Core */
    output[DWIDTH - 1 : 0] result_0_o,
    output[DWIDTH - 1 : 0] result_1_o,
    output[DWIDTH - 1 : 0] result_2_o,
    output[DWIDTH - 1 : 0] result_3_o
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
        S_IDLE : if(start_run_i)     begin n_state_read = S_RUN; end
        S_RUN  : if(is_read_done)  begin n_state_read = S_DONE; end
        S_DONE : n_state_read = S_IDLE; 
    endcase
end

always @(*) begin
    n_state_write = c_state_write; // prevent latch
 
    case(c_state_write)
        S_IDLE : if(start_run_i)     begin n_state_write = S_RUN; end
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
reg [CNT_BIT - 1 : 0] num_cnt;
always @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        num_cnt <= 0;
    end else if (start_run_i) begin
        num_cnt <= run_count_i;
    end else if (done_o) begin // When read_run state
        num_cnt <= 0; 
    end
end

/* Increase address count */
reg [CNT_BIT - 1 : 0] addr_cnt_read;
reg [CNT_BIT - 1 : 0] addr_cnt_write;
assign is_read_done = read_o && (addr_cnt_read == num_cnt - 1); 
assign is_write_done = write_o && (addr_cnt_write == num_cnt - 1); // is_done signal is 1 tic 

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        addr_cnt_read <= 0;
    end else if (is_read_done) begin
        addr_cnt_read <= 0;
    end else if (read_o) begin // when read_run_state
        addr_cnt_read <= addr_cnt_read + 1;
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

/* Data(Input) Read From BRAM0 */
assign addr_b0_o  = addr_cnt_read;
assign ce_b0_o    = read_o;
assign we_b0_o    = 1'b0; // read only
assign d_b0_o     = {DWIDTH{1'b0}}; // read only. don't Use this

reg  r_valid; // signal to immplement 1_cycle delay of read_valid. check the timing diagram of bram
wire [DWIDTH - 1 : 0]   mem_data_0;

// Making 1 cycle latency to sync mem output
always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        r_valid <= 1'b0;
    end else begin
        r_valid <= read_o;
    end
end
assign mem_data_0 = q_b0_i;

/* Read Data(weight) From BRAM1 */
assign addr_b1_o = addr_cnt_read;
assign ce_b1_o = read_o;
assign we_b1_o = 1'b0; // read only
assign d_b1_o = {DWIDTH{1'b0}}; // no use

wire [DWIDTH - 1 : 0]   mem_data_1;

assign mem_data_1 = q_b1_i;

wire [IN_DATA_WIDTH - 1 : 0]        w_a_0 = mem_data_0[(4*IN_DATA_WIDTH) - 1 : (3*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_b_0 = mem_data_1[(4*IN_DATA_WIDTH) - 1 : (3*IN_DATA_WIDTH)];
wire [(4*IN_DATA_WIDTH) - 1 : 0]    w_result_0;
wire                                w_valid_0;

wire [IN_DATA_WIDTH - 1 : 0]        w_a_1 = mem_data_0[(3*IN_DATA_WIDTH) - 1 : (2*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_b_1 = mem_data_1[(3*IN_DATA_WIDTH) - 1 : (2*IN_DATA_WIDTH)];
wire [(4*IN_DATA_WIDTH) - 1 : 0]    w_result_1;
wire                                w_valid_1;

wire [IN_DATA_WIDTH - 1 : 0]        w_a_2 = mem_data_0[(2*IN_DATA_WIDTH) - 1 : (1*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_b_2 = mem_data_1[(2*IN_DATA_WIDTH) - 1 : (1*IN_DATA_WIDTH)];
wire [(4*IN_DATA_WIDTH) - 1 : 0]    w_result_2;
wire                                w_valid_2;

wire [IN_DATA_WIDTH - 1 : 0]        w_a_3= mem_data_0[(1*IN_DATA_WIDTH) - 1 : (0*IN_DATA_WIDTH)];
wire [IN_DATA_WIDTH - 1 : 0]        w_b_3 = mem_data_1[(1*IN_DATA_WIDTH) - 1 : (0*IN_DATA_WIDTH)];
wire [(4*IN_DATA_WIDTH) - 1 : 0]    w_result_3;
wire                                w_valid_3;

/* Core Instantiation */


/* Making Output */
assign result_valid = w_valid_0 & w_valid_1 & w_valid_2 & w_valid_3;
assign result_0_o     = w_result_0;
assign result_1_o     = w_result_1;
assign result_2_o     = w_result_2;
assign result_3_o     = w_result_3;
endmodule

