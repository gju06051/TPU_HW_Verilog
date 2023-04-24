`timescale 1ns / 1ps
`define IN_DATA_WIDTH 8

module tb_Max_Pooling_core();
    reg                             clk, reset_n;
    reg [`IN_DATA_WIDTH - 1 : 0]    node1_i, node2_i, node3_i, node4_i;
    reg                             valid_i;
    reg                             run_i;

    wire                            valid_o;
    wire [`IN_DATA_WIDTH - 1 : 0]   result_o;


    always begin
        #5 clk = ~clk;
    end

    reg [`IN_DATA_WIDTH - 1 : 0] node_array [0 : 15];
    integer i = 0;

    initial begin // initialize
        clk = 1'b0;
        reset_n = 1'b0;
        valid_i = 1'b0;
        run_i = 1'b0;

        node1_i = {(`IN_DATA_WIDTH){1'b0}};
        node2_i = {(`IN_DATA_WIDTH){1'b0}};
        node3_i = {(`IN_DATA_WIDTH){1'b0}};
        node4_i = {(`IN_DATA_WIDTH){1'b0}};

        node_array[0] = 8'd1;
        node_array[1] = 8'd3;
        node_array[2] = 8'd2;
        node_array[3] = 8'd4;
        node_array[4] = 8'd58;
        node_array[5] = 8'd11;
        node_array[6] = 8'd14;
        node_array[7] = 8'd33;
        node_array[8] = 8'd111;
        node_array[9] = 8'd211;
        node_array[10] = 8'd186;
        node_array[11] = 8'd11;
        node_array[12] = 8'd22;
        node_array[13] = 8'd29;
        node_array[14] = 8'd31;
        node_array[15] = 8'd41;

        @(posedge clk) #1 reset_n = 1'b1; run_i = 1'b1;

        for(i = 0; i < 15; i = i + 4) begin
            @(posedge clk) #1
            valid_i = 1'b1;
            run_i = 1'b0;
            node1_i = node_array[i];
            node2_i = node_array[i + 1];
            node3_i = node_array[i + 2];
            node4_i = node_array[i + 3];
        end
    end

    Max_Pooling_Core  
    #(.IN_DATA_WIDTH(`IN_DATA_WIDTH))
    Max_Pooling_inst1 (
        .clk(clk), 
        .reset_n(reset_n),

        /* node to be compared */
        .node1_i(node1_i), .node2_i(node2_i), .node3_i(node3_i), .node4_i(node4_i),
    
        .valid_i(valid_i),
        .run_i(run_i),
        .valid_o(valid_o),
        .result_o(result_o)    
    );
endmodule
