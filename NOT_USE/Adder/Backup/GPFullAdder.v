module GPFullAdder (
    input X, Y,
    input Cin,

    output G, P, Sum
);
    wire P_int;

    assign G = X & Y;
    assign P = P_int;
    assign P_int = X ^ Y;
    assign Sum = P_int ^ Cin;
endmodule