module eight_bit_multiplier_wallace(
    input           [7:0]   A,
    input           [7:0]   B,
    output  wire    [15:0]  Product
);
    wire    [8:0]   pp_1 = {1'b1, !(A[7] && B[0]), (A[6] && B[0]), (A[5] && B[0]), (A[4] && B[0]),
                            (A[3] && B[0]), (A[2] && B[0]), (A[1] && B[0]), (A[0] && B[0])};
    wire    [7:0]   pp_2 = {!(A[7] && B[1]), (A[6] && B[1]), (A[5] && B[1]), (A[4] && B[1]), 
                             (A[3] && B[1]), (A[2] && B[1]), (A[1] && B[1]), (A[0] && B[1])};
    wire    [7:0]   pp_3 = {!(A[7] && B[2]), (A[6] && B[2]), (A[5] && B[2]), (A[4] && B[2]), 
                             (A[3] && B[2]), (A[2] && B[2]), (A[1] && B[2]), (A[0] && B[2])};
    wire    [7:0]   pp_4 = {!(A[7] && B[3]), (A[6] && B[3]), (A[5] && B[3]), (A[4] && B[3]), 
                             (A[3] && B[3]), (A[2] && B[3]), (A[1] && B[3]), (A[0] && B[3])};
    wire    [7:0]   pp_5 = {!(A[7] && B[4]), (A[6] && B[4]), (A[5] && B[4]), (A[4] && B[4]), 
                             (A[3] && B[4]), (A[2] && B[4]), (A[1] && B[4]), (A[0] && B[4])};
    wire    [7:0]   pp_6 = {!(A[7] && B[5]), (A[6] && B[5]), (A[5] && B[5]), (A[4] && B[5]), 
                             (A[3] && B[5]), (A[2] && B[5]), (A[1] && B[5]), (A[0] && B[5])};
    wire    [7:0]   pp_7 = {!(A[7] && B[6]), (A[6] && B[6]), (A[5] && B[6]), (A[4] && B[6]), 
                             (A[3] && B[6]), (A[2] && B[6]), (A[1] && B[6]), (A[0] && B[6])};
    wire    [8:0]   pp_8 = {1'b1,(A[7] && B[7]), !(A[6] && B[7]), !(A[5] && B[7]), !(A[4] && B[7]), 
                            !(A[3] && B[7]), !(A[2] && B[7]), !(A[1] && B[7]), !(A[0] && B[7])};

    // stage 1
    wire            stage_1_col_0   = pp_1[0];
    wire    [1:0]   stage_1_col_1   = {pp_1[1],pp_2[0]};
    wire    [2:0]   stage_1_col_2   = {pp_1[2],pp_2[1],pp_3[0]};
    wire    [3:0]   stage_1_col_3   = {pp_1[3],pp_2[2],pp_3[1],pp_4[0]};
    wire    [4:0]   stage_1_col_4   = {pp_1[4],pp_2[3],pp_3[2],pp_4[1],pp_5[0]};
    wire    [5:0]   stage_1_col_5   = {pp_1[5],pp_2[4],pp_3[3],pp_4[2],pp_5[1],pp_6[0]};
    wire    [6:0]   stage_1_col_6   = {pp_1[6],pp_2[5],pp_3[4],pp_4[3],pp_5[2],pp_6[1],pp_7[0]};    
    wire    [7:0]   stage_1_col_7   = {pp_1[7],pp_2[6],pp_3[5],pp_4[4],pp_5[3],pp_6[2],pp_7[1],pp_8[0]};
    wire    [7:0]   stage_1_col_8   = {pp_1[8],pp_2[7],pp_3[6],pp_4[5],pp_5[4],pp_6[3],pp_7[2],pp_8[1]};
    wire    [5:0]   stage_1_col_9   = {pp_3[7],pp_4[6],pp_5[5],pp_6[4],pp_7[3],pp_8[2]};
    wire    [4:0]   stage_1_col_10  = {pp_4[7],pp_5[6],pp_6[5],pp_7[4],pp_8[3]};
    wire    [3:0]   stage_1_col_11  = {pp_5[7],pp_6[6],pp_7[5],pp_8[4]};
    wire    [2:0]   stage_1_col_12  = {pp_6[7],pp_7[6],pp_8[5]};
    wire    [1:0]   stage_1_col_13  = {pp_7[7],pp_8[6]};
    wire            stage_1_col_14  = pp_8[7];
    wire            stage_1_col_15  = pp_8[8];

    //stage 2
    wire            stage_2_col_0;
    wire            stage_2_col_1;
    wire     [1:0]  stage_2_col_2;
    wire     [2:0]  stage_2_col_3;
    wire     [2:0]  stage_2_col_4;
    wire     [3:0]  stage_2_col_5;
    wire     [4:0]  stage_2_col_6;
    wire     [5:0]  stage_2_col_7;
    wire     [5:0]  stage_2_col_8;
    wire     [5:0]  stage_2_col_9;
    wire     [3:0]  stage_2_col_10;
    wire     [3:0]  stage_2_col_11;
    wire     [3:0]  stage_2_col_12;
    wire     [1:0]  stage_2_col_13;
    wire            stage_2_col_14;
    wire            stage_2_col_15;  

    assign          stage_2_col_0   = stage_1_col_0;
    Half_adder HA_1 (.a(stage_1_col_1[0]), .b(stage_1_col_1[1]), .Csum(stage_2_col_1), .Cout(stage_2_col_2[0]));
    Full_adder FA_1 (.a(stage_1_col_2[0]), .b(stage_1_col_2[1]), .Cin(stage_1_col_2[2]), .Csum(stage_2_col_2[1]), 
                    .Cout(stage_2_col_3[0]));

    Full_adder FA_2 (.a(stage_1_col_3[0]), .b(stage_1_col_3[1]), .Cin(stage_1_col_3[2]), .Csum(stage_2_col_3[1]), 
                    .Cout(stage_2_col_4[0]));
    assign          stage_2_col_3[2] = stage_1_col_3[3];

    Full_adder FA_3 (.a(stage_1_col_4[0]), .b(stage_1_col_4[1]), .Cin(stage_1_col_4[2]), .Csum(stage_2_col_4[1]), 
                    .Cout(stage_2_col_5[0]));
    Half_adder HA_2 (.a(stage_1_col_4[3]), .b(stage_1_col_4[4]), .Csum(stage_2_col_4[2]), .Cout(stage_2_col_5[1]));

    Full_adder FA_4 (.a(stage_1_col_5[0]), .b(stage_1_col_5[1]), .Cin(stage_1_col_5[2]), .Csum(stage_2_col_5[2]), 
                    .Cout(stage_2_col_6[0]));
    Full_adder FA_5 (.a(stage_1_col_5[3]), .b(stage_1_col_5[4]), .Cin(stage_1_col_5[5]), .Csum(stage_2_col_5[3]), 
                    .Cout(stage_2_col_6[1]));

    Full_adder FA_6 (.a(stage_1_col_6[0]), .b(stage_1_col_6[1]), .Cin(stage_1_col_6[2]), .Csum(stage_2_col_6[2]), 
                    .Cout(stage_2_col_7[0]));
    Full_adder FA_7 (.a(stage_1_col_6[3]), .b(stage_1_col_6[4]), .Cin(stage_1_col_6[5]), .Csum(stage_2_col_6[3]), 
                    .Cout(stage_2_col_7[1]));               
    assign          stage_2_col_6[4] = stage_1_col_6[6];

    Full_adder FA_8 (.a(stage_1_col_7[0]), .b(stage_1_col_7[1]), .Cin(stage_1_col_7[2]), .Csum(stage_2_col_7[2]), 
                    .Cout(stage_2_col_8[0]));
    Full_adder FA_9 (.a(stage_1_col_7[3]), .b(stage_1_col_7[4]), .Cin(stage_1_col_7[5]), .Csum(stage_2_col_7[3]), 
                    .Cout(stage_2_col_8[1]));               
    assign          stage_2_col_7[4] = stage_1_col_7[6];
    assign          stage_2_col_7[5] = stage_1_col_7[7]; 

    Full_adder FA_10 (.a(stage_1_col_8[0]), .b(stage_1_col_8[1]), .Cin(stage_1_col_8[2]), .Csum(stage_2_col_8[2]), 
                    .Cout(stage_2_col_9[0]));
    Full_adder FA_11 (.a(stage_1_col_8[3]), .b(stage_1_col_8[4]), .Cin(stage_1_col_8[5]), .Csum(stage_2_col_8[3]), 
                    .Cout(stage_2_col_9[1]));               
    assign          stage_2_col_8[4] = stage_1_col_8[6];
    assign          stage_2_col_8[5] = stage_1_col_8[7]; 

    Full_adder FA_12 (.a(stage_1_col_9[1]), .b(stage_1_col_9[2]), .Cin(stage_1_col_9[3]), .Csum(stage_2_col_9[2]), 
                    .Cout(stage_2_col_10[0]));
    assign          stage_2_col_9[3] = stage_1_col_9[0];
    assign          stage_2_col_9[4] = stage_1_col_9[4];                
    assign          stage_2_col_9[5] = stage_1_col_9[5];  

    Full_adder FA_13 (.a(stage_1_col_10[0]), .b(stage_1_col_10[1]), .Cin(stage_1_col_10[2]), .Csum(stage_2_col_10[1]), 
                    .Cout(stage_2_col_11[0]));
    assign          stage_2_col_10[2] = stage_1_col_10[3];
    assign          stage_2_col_10[3] = stage_1_col_10[4];   

    Half_adder HA_3 (.a(stage_1_col_11[0]), .b(stage_1_col_11[1]), .Csum(stage_2_col_11[1]), .Cout(stage_2_col_12[0])); 
    assign          stage_2_col_11[2] = stage_1_col_11[2];
    assign          stage_2_col_11[3] = stage_1_col_11[3];

    assign          stage_2_col_12[3:1] = {stage_1_col_12[2:0]};
    assign          stage_2_col_13      = stage_1_col_13;
    assign          stage_2_col_14      = stage_1_col_14;
    assign          stage_2_col_15      = stage_1_col_15;

    // stage 3
    wire              stage_3_col_0;
    wire              stage_3_col_1;
    wire              stage_3_col_2;
    wire    [1:0]     stage_3_col_3;
    wire    [1:0]     stage_3_col_4;
    wire    [2:0]     stage_3_col_5;
    wire    [2:0]     stage_3_col_6;
    wire    [3:0]     stage_3_col_7;
    wire    [3:0]     stage_3_col_8;
    wire    [3:0]     stage_3_col_9;
    wire    [3:0]     stage_3_col_10;
    wire    [2:0]     stage_3_col_11;
    wire    [2:0]     stage_3_col_12;
    wire    [1:0]     stage_3_col_13;
    wire    [1:0]     stage_3_col_14;    
    wire              stage_3_col_15;

    assign  stage_3_col_0   = stage_2_col_0;
    assign  stage_3_col_1   = stage_2_col_1;

    Half_adder HA_4(.a(stage_2_col_2[0]), .b(stage_2_col_2[1]), .Csum(stage_3_col_2), .Cout(stage_3_col_3[0]));

    Full_adder FA_14(.a(stage_2_col_3[0]), .b(stage_2_col_3[1]), .Cin(stage_2_col_3[2]), .Csum(stage_3_col_3[1]),
                    .Cout(stage_3_col_4[0]));

    Full_adder FA_15(.a(stage_2_col_4[0]), .b(stage_2_col_4[1]), .Cin(stage_2_col_4[2]), .Csum(stage_3_col_4[1]),
                    .Cout(stage_3_col_5[0]));

    Full_adder FA_16(.a(stage_2_col_5[0]), .b(stage_2_col_5[1]), .Cin(stage_2_col_5[2]), .Csum(stage_3_col_5[1]),
                    .Cout(stage_3_col_6[0]));
    assign  stage_3_col_5[2]    = stage_2_col_5[3];

    Full_adder FA_17(.a(stage_2_col_6[0]), .b(stage_2_col_6[1]), .Cin(stage_2_col_6[2]), .Csum(stage_3_col_6[1]),
                    .Cout(stage_3_col_7[0]));
    Half_adder HA_5(.a(stage_2_col_6[3]), .b(stage_2_col_6[4]), .Csum(stage_3_col_6[2]), .Cout(stage_3_col_7[1]));

    Full_adder FA_18(.a(stage_2_col_7[0]), .b(stage_2_col_7[1]), .Cin(stage_2_col_7[2]), .Csum(stage_3_col_7[2]),
                    .Cout(stage_3_col_8[0]));
    Full_adder FA_19(.a(stage_2_col_7[3]), .b(stage_2_col_7[4]), .Cin(stage_2_col_7[5]), .Csum(stage_3_col_7[3]),
                    .Cout(stage_3_col_8[1]));
    
    Full_adder FA_20(.a(stage_2_col_8[0]), .b(stage_2_col_8[1]), .Cin(stage_2_col_8[2]), .Csum(stage_3_col_8[2]),
                    .Cout(stage_3_col_9[0]));
    Full_adder FA_21(.a(stage_2_col_8[3]), .b(stage_2_col_8[4]), .Cin(stage_2_col_8[5]), .Csum(stage_3_col_8[3]),
                    .Cout(stage_3_col_9[1]));

    Full_adder FA_22(.a(stage_2_col_9[0]), .b(stage_2_col_9[1]), .Cin(stage_2_col_9[2]), .Csum(stage_3_col_9[2]),
                    .Cout(stage_3_col_10[0]));
    Full_adder FA_23(.a(stage_2_col_9[3]), .b(stage_2_col_9[4]), .Cin(stage_2_col_9[5]), .Csum(stage_3_col_9[3]),
                    .Cout(stage_3_col_10[1]));

    Full_adder FA_24(.a(stage_2_col_10[1]), .b(stage_2_col_10[2]), .Cin(stage_2_col_10[3]), .Csum(stage_3_col_10[2]),
                    .Cout(stage_3_col_11[0]));
    assign  stage_3_col_10[3] = stage_2_col_10[0];

    Full_adder FA_25(.a(stage_2_col_11[1]), .b(stage_2_col_11[2]), .Cin(stage_2_col_11[3]), .Csum(stage_3_col_11[1]),
                    .Cout(stage_3_col_12[0]));
    assign  stage_3_col_11[2] = stage_2_col_11[0];

    Full_adder FA_26(.a(stage_2_col_12[1]), .b(stage_2_col_12[2]), .Cin(stage_2_col_12[3]), .Csum(stage_3_col_12[1]),
                    .Cout(stage_3_col_13[0]));
    assign  stage_3_col_12[2] = stage_2_col_12[0];

    Half_adder HA_6(.a(stage_2_col_13[0]), .b(stage_2_col_13[1]), .Csum(stage_3_col_13[1]), .Cout(stage_3_col_14[0]));

    assign  stage_3_col_14[1] = stage_2_col_14;
    assign  stage_3_col_15    = stage_2_col_15;

    // stage 4
    wire              stage_4_col_0;
    wire              stage_4_col_1;
    wire              stage_4_col_2;
    wire              stage_4_col_3;
    wire    [1:0]     stage_4_col_4;
    wire    [1:0]     stage_4_col_5;
    wire    [1:0]     stage_4_col_6;
    wire    [2:0]     stage_4_col_7;
    wire    [2:0]     stage_4_col_8;
    wire    [2:0]     stage_4_col_9;
    wire    [2:0]     stage_4_col_10;
    wire    [2:0]     stage_4_col_11;
    wire    [2:0]     stage_4_col_12;
    wire    [2:0]     stage_4_col_13;
    wire    [1:0]     stage_4_col_14;    
    wire              stage_4_col_15;

    assign  stage_4_col_0 = stage_3_col_0;
    assign  stage_4_col_1 = stage_3_col_1;
    assign  stage_4_col_2 = stage_3_col_2;

    Half_adder HA_8(.a(stage_3_col_3[0]), .b(stage_3_col_3[1]), .Csum(stage_4_col_3), .Cout(stage_4_col_4[0]));

    Half_adder HA_9(.a(stage_3_col_4[0]), .b(stage_3_col_4[1]), .Csum(stage_4_col_4[1]), .Cout(stage_4_col_5[0]));

    Full_adder FA_27(.a(stage_3_col_5[0]), .b(stage_3_col_5[1]), .Cin(stage_3_col_5[2]), .Csum(stage_4_col_5[1]),
                    .Cout(stage_4_col_6[0]));

    Full_adder FA_28(.a(stage_3_col_6[0]), .b(stage_3_col_6[1]), .Cin(stage_3_col_6[2]), .Csum(stage_4_col_6[1]),
                    .Cout(stage_4_col_7[0]));

    Full_adder FA_29(.a(stage_3_col_7[0]), .b(stage_3_col_7[1]), .Cin(stage_3_col_7[2]), .Csum(stage_4_col_7[1]),
                    .Cout(stage_4_col_8[0]));
    assign  stage_4_col_7[2] = stage_3_col_7[3];

    Full_adder FA_30(.a(stage_3_col_8[0]), .b(stage_3_col_8[1]), .Cin(stage_3_col_8[2]), .Csum(stage_4_col_8[1]),
                    .Cout(stage_4_col_9[0]));
    assign  stage_4_col_8[2] = stage_3_col_8[3];

    Full_adder FA_31(.a(stage_3_col_9[0]), .b(stage_3_col_9[1]), .Cin(stage_3_col_9[2]), .Csum(stage_4_col_9[1]),
                    .Cout(stage_4_col_10[0]));
    assign  stage_4_col_9[2] = stage_3_col_9[3];

    Full_adder FA_32(.a(stage_3_col_10[0]), .b(stage_3_col_10[1]), .Cin(stage_3_col_10[2]), .Csum(stage_4_col_10[1]),
                    .Cout(stage_4_col_11[0]));
    assign  stage_4_col_10[2] = stage_3_col_10[3];

    Half_adder HA_10(.a(stage_3_col_11[0]), .b(stage_3_col_11[1]), .Csum(stage_4_col_11[1]), .Cout(stage_4_col_12[0]));
    assign  stage_4_col_11[2] = stage_3_col_11[2];

    Half_adder HA_11(.a(stage_3_col_12[0]), .b(stage_3_col_12[1]), .Csum(stage_4_col_12[1]), .Cout(stage_4_col_13[0]));
    assign  stage_4_col_12[2] = stage_3_col_12[2];

    assign  stage_4_col_13[2:1] = stage_3_col_13;
    assign  stage_4_col_14      = stage_3_col_14;
    assign  stage_4_col_15      = stage_3_col_15;

    // stage 5
    wire              stage_5_col_0;
    wire              stage_5_col_1;
    wire              stage_5_col_2;
    wire              stage_5_col_3;
    wire              stage_5_col_4;
    wire    [1:0]     stage_5_col_5;
    wire    [1:0]     stage_5_col_6;
    wire    [1:0]     stage_5_col_7;
    wire    [1:0]     stage_5_col_8;
    wire    [1:0]     stage_5_col_9;
    wire    [1:0]     stage_5_col_10;
    wire    [1:0]     stage_5_col_11;
    wire    [1:0]     stage_5_col_12;
    wire    [1:0]     stage_5_col_13;
    wire    [1:0]     stage_5_col_14;    
    wire    [1:0]     stage_5_col_15;

    assign  stage_5_col_0      = stage_4_col_0;
    assign  stage_5_col_1      = stage_4_col_1;
    assign  stage_5_col_2      = stage_4_col_2;
    assign  stage_5_col_3      = stage_4_col_3;

    Half_adder HA_12(.a(stage_4_col_4[0]), .b(stage_4_col_4[1]), .Csum(stage_5_col_4), .Cout(stage_5_col_5[0]));

    Half_adder HA_13(.a(stage_4_col_5[0]), .b(stage_4_col_5[1]), .Csum(stage_5_col_5[1]), .Cout(stage_5_col_6[0]));

    Half_adder HA_14(.a(stage_4_col_6[0]), .b(stage_4_col_6[1]), .Csum(stage_5_col_6[1]), .Cout(stage_5_col_7[0]));

    Full_adder FA_33(.a(stage_4_col_7[0]), .b(stage_4_col_7[1]), .Cin(stage_4_col_7[2]), .Csum(stage_5_col_7[1]),
                    .Cout(stage_5_col_8[0]));
    
    Full_adder FA_34(.a(stage_4_col_8[0]), .b(stage_4_col_8[1]), .Cin(stage_4_col_8[2]), .Csum(stage_5_col_8[1]),
                    .Cout(stage_5_col_9[0]));
    
    Full_adder FA_35(.a(stage_4_col_9[0]), .b(stage_4_col_9[1]), .Cin(stage_4_col_9[2]), .Csum(stage_5_col_9[1]),
                    .Cout(stage_5_col_10[0]));

    Full_adder FA_36(.a(stage_4_col_10[0]), .b(stage_4_col_10[1]), .Cin(stage_4_col_10[2]), .Csum(stage_5_col_10[1]),
                    .Cout(stage_5_col_11[0]));

    Full_adder FA_37(.a(stage_4_col_11[0]), .b(stage_4_col_11[1]), .Cin(stage_4_col_11[2]), .Csum(stage_5_col_11[1]),
                    .Cout(stage_5_col_12[0]));

    Full_adder FA_38(.a(stage_4_col_12[0]), .b(stage_4_col_12[1]), .Cin(stage_4_col_12[2]), .Csum(stage_5_col_12[1]),
                    .Cout(stage_5_col_13[0]));

    Full_adder FA_39(.a(stage_4_col_13[0]), .b(stage_4_col_13[1]), .Cin(stage_4_col_13[2]), .Csum(stage_5_col_13[1]),
                    .Cout(stage_5_col_14[0]));

    Half_adder HA_15(.a(stage_4_col_14[0]), .b(stage_4_col_14[1]), .Csum(stage_5_col_14[1]), .Cout(stage_5_col_15[0]));

    assign  stage_5_col_15[1]      = stage_4_col_15;

    CLA_16 CLA(
        .A({stage_5_col_15[0], stage_5_col_14[0], stage_5_col_13[0], stage_5_col_12[0], stage_5_col_11[0], 
                     stage_5_col_10[0], stage_5_col_9[0], stage_5_col_8[0], stage_5_col_7[0], stage_5_col_6[0], 
                     stage_5_col_5[0], stage_5_col_4, stage_5_col_3, stage_5_col_2, stage_5_col_1, stage_5_col_0}), 
        .B({stage_5_col_15[1], stage_5_col_14[1], stage_5_col_13[1], stage_5_col_12[1], stage_5_col_11[1], 
                     stage_5_col_10[1], stage_5_col_9[1], stage_5_col_8[1], stage_5_col_7[1], stage_5_col_6[1], 
                     stage_5_col_5[1], 5'b0}),
        .Ci(1'b0),
        .sum(Product),
        .cout()
    );
endmodule