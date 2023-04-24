module TRI_STATE_BUS #(
    // parameter
    parameter   DATA_WIDTH = 64
    )
    (
    // port
    input                       clk,
    input                       rst_n,
    input                       en,
    input                       con1, con2,     // bi-direction(con == 1'b1 -> data, 1'b0 -> highz)
    input   [DATA_WIDTH-1:0]    a, b,
    output  [DATA_WIDTH-1:0]    q
    );

    // tri_state_buffer
    tri [DATA_WIDTH-1:0]    tri_bus;
    reg [DATA_WIDTH-1:0]    temp;

    // buffer bus
    TRI_BUF #( .DATA_WIDTH(DATA_WIDTH) ) driverA ( .in(a), .con(con1), .out(tri_bus) );
    TRI_BUF #( .DATA_WIDTH(DATA_WIDTH) ) driverB ( .in(b), .con(con2), .out(tri_bus) );

    // register data from bus
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            temp <= {(DATA_WIDTH){1'b0}};
        end else if (en) begin
            temp <= tri_bus;
        end 
    end
    
    assign q = temp;

endmodule
