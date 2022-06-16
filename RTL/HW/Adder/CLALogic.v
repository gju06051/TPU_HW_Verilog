// Module Name: CLA4
// Desciption
//      Calculate PG(group Propagte) and GG(Group Generate) From the Carry_in and G, P Signal from GPFullAdder 
module CLALogic (
    input [3 : 0] G, P,
    input Ci,

    output [3 : 1] C,
    output Co,
    output PG,
    output GG
);
    wire GG_int;
    wire PG_int;

    assign C[1] = G[0] | (P[0] & Ci);
    assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & Ci);
    assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & Ci);

    assign PG_int = P[3] & P[2] & P[1] & P[0];
    assign GG_int = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]);
    
    assign Co = GG_int | (PG_int & Ci);
    assign PG = PG_int;
    assign GG = GG_int;
endmodule