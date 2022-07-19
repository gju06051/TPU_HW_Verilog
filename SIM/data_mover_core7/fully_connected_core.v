// Module Name: true_dpbram
// 
// description
//      Fully Connected Core. take input node value and output node value "consequently"
//      then Multiply the operand and accumulate it
//      it has 2 cycle latency. when Module gets valid_i signal then give result after 2 clk
//      
//
// inputs
//      clk, reset_n: special inputs. Clock and negative reset
//      run_i: start signal.
//      valid_i: when it take the vlaid_i, finish the calculate and give result after 2 clk
//      node_i: input node value
//      weight_i: weight value
// 
// outputs
//      valid_o: 1 tick if the result is valid
//      result_o: result. it will be 1 output neuron's result
//
// Notice
//      it gets "x bits" weight and input and output is "4x bits" because there is Multiplication.

`timescale 1ns / 1ps
module fully_connected_core
#(
	parameter IN_DATA_WIDTH = 8
)
(
    input 								clk,
    input 								reset_n,
	input								run_i,
	input 								valid_i,
	input 	[IN_DATA_WIDTH - 1:0]		node_i,
	input 	[IN_DATA_WIDTH - 1:0]		weight_i,

	output  							valid_o,
	output  [(7*IN_DATA_WIDTH) - 1:0]	result_o
);

// 2 cycle delay - 1 MAC operation need more than 1 clk period
reg 	[1 : 0]					  r_valid;
reg 	[(4*IN_DATA_WIDTH) - 1:0] r_mult;
wire  	[(2*IN_DATA_WIDTH) - 1:0] w_mult;
reg 	[(4*IN_DATA_WIDTH) - 1:0] r_result;

always @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        r_valid <= 2'b0;  
    end else if (run_i) begin
        r_valid <= 2'b0;  
    end else begin
		r_valid <= {r_valid[0], valid_i};
	end
end

always @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        r_mult <= {(2*IN_DATA_WIDTH){1'b0}};  
    end else if (run_i) begin
        r_mult <= {(2*IN_DATA_WIDTH){1'b0}};  
    end else if (valid_i) begin
		r_mult <= w_mult;
	end
end

always @(posedge clk or negedge reset_n) begin
    if(!reset_n) begin
        r_result <= {(4*IN_DATA_WIDTH){1'b0}};  
    end else if (run_i) begin
        r_result <= {(4*IN_DATA_WIDTH){1'b0}};  // initial value is 0 and then accumulate start
    end else if (r_valid[0]) begin  // valid == enable.
		r_result <= r_result + r_mult; // accumulate
	end
end

assign valid_o 	= r_valid[1];
assign w_mult = node_i * weight_i; // separate '+' stage and '*' stage to pipelining becayse only 1 stage cause timing violation(Retiming)
assign result_o = r_result;

endmodule
