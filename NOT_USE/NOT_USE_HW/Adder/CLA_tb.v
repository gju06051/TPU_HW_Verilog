`timescale 1ps/1ps
`define DELAY 10

module CLA_tb
# (
    parameter WIDTH = 16 // change this to 32 then 32 Data WIDTH will be tested
)
(

);

    reg Ci;
    reg [WIDTH - 1 : 0] A;
    reg [WIDTH - 1 : 0] B;

    wire Co;
    wire [WIDTH - 1: 0] S;

    CLA # (
        .WIDTH(WIDTH)
    )  CLA_inst_1 (
        .A(A), .B(B), .Ci(Ci), .S(S), .Co(Co)
    );

    initial begin
        A = {WIDTH{1'b0}};
        B = {WIDTH{1'b0}};
        Ci = 1'b0;
    end

    initial begin
        #(`DELAY) 
        #(`DELAY)  A = 16'd10;
        #(`DELAY)  A = 16'd20;
        #(`DELAY)  B = 16'd10;
        #(`DELAY)  B = 16'd20;
        #(`DELAY)  B = 16'd0;
        #(`DELAY*3)  A = 16'hFFFF; B = 16'hFFFF;
        #(`DELAY*3)  A = 16'h7FFF; B = 16'hFFFF;
        #(`DELAY*3)  A = 16'hBFFF; B = 16'hFFFF;
    end
endmodule        
