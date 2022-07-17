module Proposed_InExact_4_to_2_Comp(
    input           IN1,IN2,IN3,IN4,
    output  wire    Ccy,Csum
);
    assign Csum = (IN2 && IN1) || (IN4 ^ IN3 ^ IN2 ^ IN1);
    assign Ccy  = (IN4 && IN3) || (IN2 && IN1) 
                    || ((IN4 ^ IN3) && (IN2 ^ IN1)); 
endmodule