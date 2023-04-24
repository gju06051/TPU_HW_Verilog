// Module Name: CLA16
// Desciption
//      Take Carry_in and 2 Operand(16 bits) and then calculate the Sum and Carry_out
//  Inputs
//      A, B: 16 bit operand
//      Ci: Carry_in
//  Outputs
//      sum: 16 bit result(Sum)
//      Co: Carry_out

module CLA_16(
    input [15 : 0] A, B,
    input Ci,

    output [15 : 0] sum,
    output cout
);
    wire PG0,PG1,PG2,PG3;
    wire GG0,GG1,GG2,GG3;
    wire c1,c2,c3;
    CLA4 CLA_inst_1 (.A(A[3 : 0]), .B(B[3 : 0]), .Ci(Ci), .S(sum[3 : 0]), .Co(), .PG(PG0), .GG(GG0));
    CLA4 CLA_inst_2 (.A(A[7 : 4]), .B(B[7 : 4]), .Ci(c1), .S(sum[7 : 4]), .Co(), .PG(PG1), .GG(GG1));
    CLA4 CLA_inst_3 (.A(A[11 : 8]), .B(B[11 : 8]), .Ci(c2), .S(sum[11 : 8]), .Co(), .PG(PG2), .GG(GG2));
    CLA4 CLA_inst_4 (.A(A[15 : 12]), .B(B[15 : 12]), .Ci(c3), .S(sum[15 : 12]), .Co(cout), .PG(PG3), .GG(GG3));
    assign c1 = GG0 || (PG0 && Ci); 
    assign c2 = GG1 || (PG1 && GG0) || (PG1 && PG0 && Ci);
    assign c3 = GG2 || (PG2 && GG1) || (PG2 && PG1 && GG0) || (PG2 && PG1 && PG0 && Ci);
endmodule