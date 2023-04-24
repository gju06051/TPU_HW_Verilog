// Module Name: result_writer4
// 
// description
//      Take Calculation result from the data_mover_bram module and write it to BRAM
//      This module is attached to Fully Connected layer 1 so it should
//      store the 4 numbers to BRAM's each row.
//      so this module write result to BRAM when every time it receive "4" result.
//      it concatenate the 4 result and write
//
// inputs
//      Special Inputs
//          clk: special inputs. Clock
//          reset_n: special input. reset (active low)
//
//      Signal From Controller
//          calc_done_i: the done state of data_mover_bram's module. it is 1 tick
//                       if it is 1 then calc_result_i is valid
//          calc_result_i: calculation result from data_mover
//      
//      Memory I/F
//          q_b0_i: data that read from bram (not used! the bram attached to this module is write-only)
//          
// outputs
//      Memory I/F
//          addr_b_o: address of memory that user want to access.
//          ce_b_o: chip enable
//          we_b_o: write enable. 0 means read mode and 1 means write mode
//          d_b_o: data that user wants to write
//
module result_writer4
# (
    parameter DWIDTH        = 32,
    parameter AWIDTH        = 2,
    parameter IN_DATA_WIDTH = 8
)
(
    input clk,
    input reset_n,

    /* signal from data mover that the calculation is finish */
    input calc_done_i,

    /* calculation result */
    input [IN_DATA_WIDTH - 1 : 0] calc_result_i,

    /* Memory I/F Input for BRAM */
    input [DWIDTH - 1 : 0] q_b_i,

    /* Memory I/F output for BRAM */
    output [AWIDTH - 1 : 0] addr_b_o,
    output ce_b_o,
    output we_b_o,
    output [DWIDTH - 1 : 0] d_b_o
);

    // Capture the result of data mover when done state is rise
    reg [IN_DATA_WIDTH - 1 : 0] result_capture;
    reg [$clog2(DWIDTH / IN_DATA_WIDTH) : 0] capture_success; 

    wire next_row_trigger;
    assign next_row_trigger = (capture_success == (DWIDTH / IN_DATA_WIDTH));

    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            result_capture  <= 0;
            capture_success <= 0;
        end else if(calc_done_i) begin
            result_capture  <= calc_result_i;
            capture_success <= capture_success + 1;
        end else if(next_row_trigger) begin
            result_capture  <= 0;
            capture_success <= 0;
        end
    end
    
    reg [DWIDTH - 1 : 0] temp_d;
    always@(*) begin
        case (capture_success) // should modify the case when parameter is changed
            4: begin
                temp_d[1*(IN_DATA_WIDTH) - 1 : 0*(IN_DATA_WIDTH)] = result_capture;
            end
            3: begin
                temp_d[2*(IN_DATA_WIDTH) - 1 : 1*(IN_DATA_WIDTH)] = result_capture;
            end
            2: begin
                temp_d[3*(IN_DATA_WIDTH) - 1 : 2*(IN_DATA_WIDTH)] = result_capture;
            end
            1: begin
                temp_d[4*(IN_DATA_WIDTH) - 1 : 3*(IN_DATA_WIDTH)] = result_capture;
            end
            default: begin
                temp_d = 0;
            end
        endcase
    end

    reg [AWIDTH - 1 : 0] addr;
    always@(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            addr <= 0;
        end else if(next_row_trigger) begin
            addr <= addr + 1;
        end
    end

    assign addr_b_o = addr;
    assign ce_b_o   = next_row_trigger;
    assign we_b_o   = next_row_trigger;
    assign d_b_o    = temp_d;
endmodule
