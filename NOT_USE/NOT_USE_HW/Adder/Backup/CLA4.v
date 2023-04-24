// Module Name: CLA4
// Desciption
//      Take Carry_in and 2 Operand(4 bits) and then calculate the Sum and Carry_out
//  Inputs
//      A, B: 4 bit operand
//      Ci: Carry_in
//  Outputs
//      S: 4 bit result(Sum)
//      Co: Carry_out
//      PG: group Propagte, If you want to Instantiation this module to make 8 bits or 16 bits ... CLA, should use Connect this signal to CLA_Logic
//      PG: group generate, If you want to Instantiation this module to make 8 bits or 16 bits ... CLA, should use Connect this signal to CLA_Logic
module CLA4(
    input [3 : 0] A, B,
    input Ci,

    output [3 : 0] S,
    output Co,
    output PG,
    output GG
);
    wire [3 : 0] G, P;
    wire [3 : 1] C;

    CLALogic CarryLogic (.G(G), .P(P), .Ci(Ci), .C(C), .Co(Co), .PG(PG), .GG(GG));
    GPFullAdder FA0 (.X(A[0]), .Y(B[0]), .Cin(Ci), .G(G[0]), .P(P[0]), .Sum(S[0]));
    GPFullAdder FA1 (.X(A[1]), .Y(B[1]), .Cin(C[1]), .G(G[1]), .P(P[1]), .Sum(S[1]));
    GPFullAdder FA2 (.X(A[2]), .Y(B[2]), .Cin(C[2]), .G(G[2]), .P(P[2]), .Sum(S[2]));
    GPFullAdder FA3 (.X(A[3]), .Y(B[3]), .Cin(C[3]), .G(G[3]), .P(P[3]), .Sum(S[3]));
endmodule