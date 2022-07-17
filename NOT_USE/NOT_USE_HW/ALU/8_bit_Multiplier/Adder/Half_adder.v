module Half_adder(
    input       a,b,
    output wire Csum, Cout
);
    assign Csum = a ^ b;
    assign Cout = a && b;
endmodule