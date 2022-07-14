module Full_adder(
    input a,b,Cin,
    output wire Csum, Cout
);
    assign Csum = (a ^ b) ^ Cin;
    assign Cout = ((a ^ b) && Cin ) || (a && b);
endmodule