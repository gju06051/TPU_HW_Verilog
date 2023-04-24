module Exact_4_to_2_Comp (
    input           IN1,IN2,IN3,IN4,
    input           Cin,
    output  wire    Cout,
    output  wire    Ccy,Csum
);
    assign Csum = Cin ^ IN1 ^ IN2 ^ IN3 ^ IN4;
    assign Cout = (IN1 && !(IN2 ^ IN1) ) || (IN3 && (IN2 ^ IN1));
    assign Ccy  = (IN4 && (!(IN4 ^ IN3 ^ IN2 ^ IN1))) 
                    || (Cin && (IN4 ^ IN3 ^ IN2 ^ IN1));
endmodule  