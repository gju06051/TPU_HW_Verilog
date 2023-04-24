// Module Name: Max_Pooling_Core
// 
// description
//      Max Pooling core. get 4 value and find the largest number and
//      give it to output
//      
//
// inputs
//      clk, reset_n: special inputs. Clock and negative reset
//      run_i: start signal.
//      valid_i: when it take the vlaid_i, finish the calculate and give result after 1 clk
//      node1_i, node2_i, node3_i, node4_i: input node value
// 
// outputs
//      valid_o: 1 tick if the result is valid
//      result_o: result. it will be 1 output neuron's result
//
// Notice
//      this module has 2 cycle latency

`timescale 1ns / 1ps
module Max_Pooling_Core 
# (
    parameter IN_DATA_WIDTH = 8
)
(
    input clk, reset_n,

    /* node to be compared */
    input [IN_DATA_WIDTH - 1 : 0] node1_i, node2_i, node3_i, node4_i,
    
    input valid_i,
    input run_i,

    output valid_o,
    output [IN_DATA_WIDTH - 1 : 0] result_o     
);

// 2 cycle delay
    reg [1 : 0]                 r_valid; // modified
    reg [IN_DATA_WIDTH - 1 : 0] r_result;
    

    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            r_valid <= 2'b0;
        end else if (run_i) begin
            r_valid <= 2'b0;
        end else begin
            r_valid <= {r_valid[0], valid_i};
        end
    end

    reg [IN_DATA_WIDTH - 1 : 0] temp1;
    reg [IN_DATA_WIDTH - 1 : 0] temp2;
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            r_result    <= {(IN_DATA_WIDTH){1'b0}};
            temp1       <= {(IN_DATA_WIDTH){1'b0}};
            temp2       <= {(IN_DATA_WIDTH){1'b0}};
        end else if (run_i) begin
            r_result <= {(IN_DATA_WIDTH){1'b0}};
        end else if (valid_i) begin
            if(node1_i < node2_i)   temp1 <= node2_i;
            else                    temp1 <= node1_i;  
        //  if(node1_i == node2_i)  temp1 <= node1_i;
            if(node3_i < node4_i)   temp2 <= node4_i;
            else                    temp2 <= node3_i;  
        //  if(node3_i == node4_i)  temp2 <= node3_i;
            if(temp1 < temp2)       r_result <= temp2;
            else                    r_result <= temp1;
        //  if(temp1 == temp2) r_result <= temp1;
        end
    end

    assign valid_o  = r_valid[1]; 
    assign result_o = r_result;
endmodule