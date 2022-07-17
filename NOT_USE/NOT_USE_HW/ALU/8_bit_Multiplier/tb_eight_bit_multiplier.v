module tb_eigth_bit_multiplier;
    reg [7:0] A;
    reg [7:0] B;
    wire [16:0] Product;
    eight_bit_multiplier DUT(
        .A(A),
        .B(B),
        .Product(Product)
    );
    initial begin
        A = 8'b0011_0011;
        B = 8'b0100_0010;
        #80;
        A = 8'b1011_0011;
        B = 8'b0100_0010;
        #80;
        A = 8'b1011_0011;
        B = 8'b1100_0010;
    end
endmodule