`timescale 1ns / 1ps

`define ADDR_WIDTH 2
`define DATA_WIDTH 40
`define MEM_DEPTH 2
`define IN_DATA_WIDTH 8

module tb_result_writer5();
    reg                             clk, reset_n;
    reg                             done_o;
    reg [`IN_DATA_WIDTH - 1 : 0]    result_o;
    reg [`DATA_WIDTH - 1 : 0]       q_b;

    wire [`ADDR_WIDTH - 1 : 0]      addr_b;
    wire                            ce_b;
    wire                            we_b;
    wire [`DATA_WIDTH - 1 : 0]      d_b;

    always begin
        #5 clk = ~clk;
    end

    initial begin
        // initialize
        reset_n     = 1;
        clk         = 0;
        done_o      = 0;
        result_o    = {(`IN_DATA_WIDTH){1'b0}};
        q_b         = {(`DATA_WIDTH){1'b0}};

        // reset
        $display("Reset. [%0d]", $time);
        #100    reset_n = 0;
        #10     reset_n = 1;
        #10     @(posedge clk); #3

        // test pattern
        $display("test pattern start. [%0d]", $time);
        done_o = 1'b1; result_o = 31;
        @(posedge clk); #3
        done_o = 1'b0; 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); #3

        done_o = 1'b1; result_o = 179;
        @(posedge clk); #3
        done_o = 1'b0; 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); #3

        done_o = 1'b1; result_o = 125;
        @(posedge clk); #3
        done_o = 1'b0; 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); #3

        done_o = 1'b1; result_o = 11;
        @(posedge clk); #3
        done_o = 1'b0; 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); #3

        done_o = 1'b1; result_o = 1;
        @(posedge clk); #3
        done_o = 1'b0; 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); #3

        done_o = 1'b1; result_o = 3;
        @(posedge clk); #3
        done_o = 1'b0; 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); #3

        done_o = 1'b1; result_o = 69;
        @(posedge clk); #3
        done_o = 1'b0; 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); #3

        done_o = 1'b1; result_o = 101;
        @(posedge clk); #3
        done_o = 1'b0; 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); #3

        done_o = 1'b1; result_o = 225;
        @(posedge clk); #3
        done_o = 1'b0; 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); #3

        done_o = 1'b1; result_o = 131;
        @(posedge clk); #3
        done_o = 1'b0; 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); 
        @(posedge clk); #3
        
        #100
        $display("Simulation Finish,");
        $finish;
    end


    result_writer5
    # (
        .DWIDTH(`DATA_WIDTH),
        .AWIDTH(`ADDR_WIDTH),
        .MEM_SIZE(`MEM_DEPTH)
    ) result_writer5_inst (
        .clk(clk),
        .reset_n(reset_n),

        .calc_done_i(done_o),
        .calc_result_i(result_o),

        .q_b_i(q_b),
        .addr_b_o(addr_b),
        .ce_b_o(ce_b),
        .we_b_o(we_b),
        .d_b_o(d_b)
    );


endmodule
