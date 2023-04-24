module CLA
#(
    parameter WIDTH = 32
)
(
    input [WIDTH - 1 : 0] A, B,
    input Ci,

    output [WIDTH - 1 : 0] S,
    output Co 
);
    wire [WIDTH - 1 : 0] G; // Generate
    wire [WIDTH - 1 : 0] P; // Propagate
    wire [WIDTH : 0] C_tmp;

    genvar i, j;
    generate
        assign C_tmp[0] = Ci;

        for(j = 0; j < WIDTH; j = j + 1) begin: carry_generator
            assign G[j] = A[j] & B[j];
            assign P[j] = A[j] | B[j];
            assign C_tmp[j + 1] = G[j] | P[j] & C_tmp[j];
        end

        assign Co = C_tmp[WIDTH];

        for( i = 0; i < WIDTH; i = i + 1) begin: Sum_without_Carry
            assign S[i] = A[i] ^ B[i] ^ C_tmp[i];
        end
    endgenerate
endmodule