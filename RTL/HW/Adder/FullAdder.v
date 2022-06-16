// Module Name: FullAdder
module FullAdder(
    input a, b, cin,
    output sum, cout
);
    assign sum = a ^ b ^ cin;
    assign carry = (a & b) | (cin & b) | (a & cin);
endmodule